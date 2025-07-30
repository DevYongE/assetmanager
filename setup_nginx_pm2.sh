#!/bin/bash

# QR Asset Management - Nginx + PM2 배포 스크립트
# 작성일: 2024-12-19
# 설명: Nginx를 사용하여 프론트엔드와 백엔드를 배포하고 PM2로 프로세스를 관리합니다.

set -e

echo "🚀 QR Asset Management 배포를 시작합니다..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 시스템 업데이트
log_info "시스템 패키지를 업데이트합니다..."
sudo apt update && sudo apt upgrade -y

# 필수 패키지 설치
log_info "필수 패키지들을 설치합니다..."
sudo apt install -y curl wget git build-essential

# Node.js 설치 (v18 LTS)
log_info "Node.js 18 LTS를 설치합니다..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# PM2 전역 설치
log_info "PM2를 설치합니다..."
sudo npm install -g pm2

# Nginx 설치
log_info "Nginx를 설치합니다..."
sudo apt install -y nginx

# 방화벽 설정
log_info "방화벽을 설정합니다..."
sudo ufw allow 'Nginx Full'
sudo ufw allow ssh
sudo ufw --force enable

# 프로젝트 디렉토리 설정
PROJECT_DIR="/var/www/qr-asset-management"
log_info "프로젝트 디렉토리를 설정합니다: $PROJECT_DIR"

# 디렉토리 생성
sudo mkdir -p $PROJECT_DIR
sudo chown -R $USER:$USER $PROJECT_DIR

# 백엔드 설정
log_info "백엔드를 설정합니다..."
cd $PROJECT_DIR/backend

# 백엔드 의존성 설치
log_info "백엔드 의존성을 설치합니다..."
npm install

# 환경 변수 파일 생성
log_info "백엔드 환경 변수를 설정합니다..."
cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_USER=qr_user
DB_PASSWORD=qr_password_2024
DB_NAME=qr_asset_db
DB_PORT=3306

# Server Configuration
PORT=3000
NODE_ENV=production

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_2024
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
EOF

# MySQL 설치 및 설정
log_info "MySQL을 설치하고 설정합니다..."
sudo apt install -y mysql-server

# MySQL 보안 설정
sudo mysql_secure_installation

# 데이터베이스 및 사용자 생성
log_info "데이터베이스를 설정합니다..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS qr_asset_db;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'qr_user'@'localhost' IDENTIFIED BY 'qr_password_2024';"
sudo mysql -e "GRANT ALL PRIVILEGES ON qr_asset_db.* TO 'qr_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# 데이터베이스 마이그레이션 실행
log_info "데이터베이스 마이그레이션을 실행합니다..."
node run-migration.js

# 백엔드를 PM2로 시작
log_info "백엔드를 PM2로 시작합니다..."
pm2 start index.js --name "qr-backend" --env production

# 프론트엔드 설정
log_info "프론트엔드를 설정합니다..."
cd $PROJECT_DIR/frontend

# 프론트엔드 의존성 설치
log_info "프론트엔드 의존성을 설치합니다..."
npm install

# 프론트엔드 빌드
log_info "프론트엔드를 빌드합니다..."
npm run build

# Nginx 설정
log_info "Nginx 설정을 생성합니다..."
sudo tee /etc/nginx/sites-available/qr-asset-management << EOF
server {
    listen 80;
    server_name localhost;

    # Frontend (Nuxt.js)
    location / {
        root /var/www/qr-asset-management/frontend/.output/public;
        try_files \$uri \$uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
EOF

# Nginx 사이트 활성화
log_info "Nginx 사이트를 활성화합니다..."
sudo ln -sf /etc/nginx/sites-available/qr-asset-management /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Nginx 설정 테스트
log_info "Nginx 설정을 테스트합니다..."
sudo nginx -t

# Nginx 재시작
log_info "Nginx를 재시작합니다..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# PM2 자동 시작 설정
log_info "PM2 자동 시작을 설정합니다..."
pm2 startup
pm2 save

# 상태 확인
log_info "서비스 상태를 확인합니다..."
echo ""
log_success "배포가 완료되었습니다!"
echo ""
echo "📊 서비스 상태:"
echo "  - Nginx: $(sudo systemctl is-active nginx)"
echo "  - MySQL: $(sudo systemctl is-active mysql)"
echo "  - PM2 Backend: $(pm2 status | grep qr-backend || echo 'Not running')"
echo ""
echo "🌐 접속 정보:"
echo "  - Frontend: http://localhost"
echo "  - Backend API: http://localhost/api"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태 확인: pm2 status"
echo "  - PM2 로그 확인: pm2 logs"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - MySQL 상태: sudo systemctl status mysql"
echo ""
log_success "QR Asset Management가 성공적으로 배포되었습니다! 🎉" 