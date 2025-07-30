#!/bin/bash

# QR Asset Management - Nginx + PM2 배포 스크립트 (수정된 버전)
# 작성일: 2024-12-19
# 설명: 프로젝트 분석 결과를 바탕으로 올바른 설정으로 배포합니다.
# - Supabase 데이터베이스 사용
# - 백엔드 포트: 4000
# - 프론트엔드 포트: 3000

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

# 환경 변수 파일 생성 (Supabase 설정)
log_info "백엔드 환경 변수를 설정합니다..."
cat > .env << EOF
# Supabase Configuration (2024-12-19: MySQL이 아닌 Supabase 사용)
SUPABASE_URL=your_supabase_url_here
SUPABASE_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# Server Configuration
PORT=4000
NODE_ENV=production

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_2024
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
EOF

log_warning "⚠️  Supabase 환경 변수를 설정해주세요!"
log_warning "   - SUPABASE_URL"
log_warning "   - SUPABASE_KEY" 
log_warning "   - SUPABASE_SERVICE_ROLE_KEY"

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

# Nginx 설정 (올바른 포트 설정)
log_info "Nginx 설정을 생성합니다..."
sudo tee /etc/nginx/sites-available/qr-asset-management << EOF
server {
    listen 80;
    server_name localhost;

    # Frontend (Nuxt.js) - 포트 3000에서 서빙
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Backend API - 포트 4000으로 프록시
    location /api/ {
        proxy_pass http://localhost:4000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:4000/api/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
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
echo "  - PM2 Backend: $(pm2 status | grep qr-backend || echo 'Not running')"
echo ""
echo "🌐 접속 정보:"
echo "  - Frontend: http://localhost"
echo "  - Backend API: http://localhost/api"
echo "  - Health Check: http://localhost/health"
echo ""
echo "⚠️  중요: Supabase 환경 변수를 설정해주세요!"
echo "   백엔드 .env 파일에서 다음 변수들을 설정하세요:"
echo "   - SUPABASE_URL"
echo "   - SUPABASE_KEY"
echo "   - SUPABASE_SERVICE_ROLE_KEY"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태 확인: pm2 status"
echo "  - PM2 로그 확인: pm2 logs"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - 백엔드 재시작: pm2 restart qr-backend"
echo ""
log_success "QR Asset Management가 성공적으로 배포되었습니다! 🎉" 