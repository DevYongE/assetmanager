#!/bin/bash

# =============================================================================
# QR 자산관리 시스템 Rocky Linux 배포 스크립트
# =============================================================================
#
# 이 스크립트는 Rocky Linux 서버에 QR 자산관리 시스템을 배포합니다.
# 백엔드, 프론트엔드, 데이터베이스, Nginx 설정을 포함합니다.
#
# 작성일: 2025-01-27
# =============================================================================

set -e  # 오류 발생 시 스크립트 중단

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

# 변수 설정
PROJECT_DIR="/home/dmanager/assetmanager"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"
DB_NAME="assetmanager"
DB_USER="assetmanager"
DB_PASSWORD="assetmanager_secure_2025"
JWT_SECRET="your_super_secret_jwt_key_2025"

log_info "🚀 QR 자산관리 시스템 Rocky Linux 배포 시작"

# =============================================================================
# 1. 시스템 업데이트 및 필수 패키지 설치
# =============================================================================
log_info "📦 시스템 업데이트 및 필수 패키지 설치 중..."

sudo dnf update -y
sudo dnf install -y git nodejs npm nginx mysql mysql-server pm2

# Node.js 최신 버전 설치 (필요시)
if ! command -v node &> /dev/null; then
    log_info "Node.js 설치 중..."
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo dnf install -y nodejs
fi

# =============================================================================
# 2. 프로젝트 디렉토리 설정
# =============================================================================
log_info "📁 프로젝트 디렉토리 설정 중..."

# 기존 프로젝트 백업
if [ -d "$PROJECT_DIR" ]; then
    log_warning "기존 프로젝트를 백업합니다..."
    sudo mv "$PROJECT_DIR" "${PROJECT_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
fi

# 프로젝트 디렉토리 생성
sudo mkdir -p "$PROJECT_DIR"
sudo chown -R dmanager:dmanager "$PROJECT_DIR"

# =============================================================================
# 3. 프로젝트 파일 복사
# =============================================================================
log_info "📋 프로젝트 파일 복사 중..."

# 현재 스크립트가 있는 디렉토리에서 파일 복사
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo cp -r "$SCRIPT_DIR/backend" "$PROJECT_DIR/"
sudo cp -r "$SCRIPT_DIR/frontend" "$PROJECT_DIR/"
sudo cp "$SCRIPT_DIR/nginx_config_fix.conf" "$PROJECT_DIR/"
sudo chown -R dmanager:dmanager "$PROJECT_DIR"

# =============================================================================
# 4. 데이터베이스 설정
# =============================================================================
log_info "🗄️ 데이터베이스 설정 중..."

# MySQL 서비스 시작
sudo systemctl start mysqld
sudo systemctl enable mysqld

# MySQL 보안 설정
sudo mysql_secure_installation << EOF

y
0
$DB_PASSWORD
$DB_PASSWORD
y
y
y
y
EOF

# 데이터베이스 및 사용자 생성
sudo mysql -u root -p"$DB_PASSWORD" << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

log_success "데이터베이스 설정 완료"

# =============================================================================
# 5. 백엔드 설정
# =============================================================================
log_info "🔧 백엔드 설정 중..."

cd "$BACKEND_DIR"

# 의존성 설치
npm install

# 환경변수 파일 생성
cat > .env << EOF
DB_HOST=localhost
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
JWT_SECRET=$JWT_SECRET
PORT=4000
NODE_ENV=production
EOF

# 데이터베이스 마이그레이션 실행
log_info "데이터베이스 마이그레이션 실행 중..."
node run-migration.js

log_success "백엔드 설정 완료"

# =============================================================================
# 6. 프론트엔드 설정
# =============================================================================
log_info "🎨 프론트엔드 설정 중..."

cd "$FRONTEND_DIR"

# 의존성 설치
npm install

# 프로덕션 빌드
log_info "프론트엔드 빌드 중..."
npm run build:prod

log_success "프론트엔드 설정 완료"

# =============================================================================
# 7. PM2 설정
# =============================================================================
log_info "⚡ PM2 설정 중..."

# PM2 글로벌 설치
sudo npm install -g pm2

# 백엔드 PM2 설정
cd "$BACKEND_DIR"
pm2 start index.js --name "assetmanager-backend" --env production

# 프론트엔드 PM2 설정 (정적 파일 서빙)
cd "$FRONTEND_DIR"
pm2 start "npx serve .output/public -p 3000" --name "assetmanager-frontend"

# PM2 설정 저장 및 자동 시작
pm2 save
pm2 startup

log_success "PM2 설정 완료"

# =============================================================================
# 8. Nginx 설정
# =============================================================================
log_info "🌐 Nginx 설정 중..."

# 기존 Nginx 설정 백업
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Nginx 설정 파일 생성
sudo tee /etc/nginx/conf.d/assetmanager.conf > /dev/null << EOF
server {
    listen 80;
    server_name _;  # 모든 도메인 허용

    # 보안 헤더
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # 프론트엔드 (정적 파일)
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
        
        # 정적 파일 캐싱
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # 백엔드 API
    location /api {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # API 요청 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 에러 페이지
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
EOF

# Nginx 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx
sudo systemctl enable nginx

log_success "Nginx 설정 완료"

# =============================================================================
# 9. 방화벽 설정
# =============================================================================
log_info "🔥 방화벽 설정 중..."

# 방화벽 활성화
sudo systemctl enable firewalld
sudo systemctl start firewalld

# 포트 허용
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=4000/tcp

# 방화벽 재시작
sudo firewall-cmd --reload

log_success "방화벽 설정 완료"

# =============================================================================
# 10. 백업 스크립트 생성
# =============================================================================
log_info "💾 백업 스크립트 생성 중..."

cat > /home/dmanager/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/dmanager/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# 데이터베이스 백업
mysqldump -u assetmanager -p'assetmanager_secure_2025' assetmanager > $BACKUP_DIR/db_backup_$DATE.sql

# 애플리케이션 백업
tar -czf $BACKUP_DIR/app_backup_$DATE.tar.gz /home/dmanager/assetmanager

# 30일 이상 된 백업 삭제
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /home/dmanager/backup.sh

# 자동 백업 설정 (매일 새벽 2시)
echo "0 2 * * * /home/dmanager/backup.sh" | crontab -

log_success "백업 스크립트 생성 완료"

# =============================================================================
# 11. 모니터링 스크립트 생성
# =============================================================================
log_info "📊 모니터링 스크립트 생성 중..."

cat > /home/dmanager/monitor.sh << 'EOF'
#!/bin/bash
echo "=== QR 자산관리 시스템 상태 ==="
echo "시간: $(date)"
echo ""

echo "=== PM2 상태 ==="
pm2 status
echo ""

echo "=== Nginx 상태 ==="
sudo systemctl status nginx --no-pager -l
echo ""

echo "=== MySQL 상태 ==="
sudo systemctl status mysqld --no-pager -l
echo ""

echo "=== 포트 사용 현황 ==="
sudo netstat -tlnp | grep -E ':(80|3000|4000)'
echo ""

echo "=== 디스크 사용량 ==="
df -h
echo ""

echo "=== 메모리 사용량 ==="
free -h
echo ""

echo "=== 최근 로그 (마지막 10줄) ==="
echo "Nginx 에러 로그:"
sudo tail -10 /var/log/nginx/error.log
echo ""
echo "백엔드 로그:"
pm2 logs assetmanager-backend --lines 10
EOF

chmod +x /home/dmanager/monitor.sh

log_success "모니터링 스크립트 생성 완료"

# =============================================================================
# 12. 배포 완료 확인
# =============================================================================
log_info "🔍 배포 완료 확인 중..."

# 서비스 상태 확인
sleep 5

echo ""
echo "=== 배포 완료 확인 ==="
echo ""

# PM2 상태 확인
echo "PM2 상태:"
pm2 status
echo ""

# Nginx 상태 확인
echo "Nginx 상태:"
sudo systemctl status nginx --no-pager -l
echo ""

# 포트 확인
echo "포트 사용 현황:"
sudo netstat -tlnp | grep -E ':(80|3000|4000)'
echo ""

log_success "🎉 QR 자산관리 시스템 배포 완료!"
echo ""
echo "=== 접속 정보 ==="
echo "웹사이트: http://$(hostname -I | awk '{print $1}')"
echo "API 엔드포인트: http://$(hostname -I | awk '{print $1}')/api"
echo ""
echo "=== 관리 명령어 ==="
echo "상태 확인: /home/dmanager/monitor.sh"
echo "백업 실행: /home/dmanager/backup.sh"
echo "PM2 재시작: pm2 restart all"
echo "Nginx 재시작: sudo systemctl restart nginx"
echo ""
echo "=== 로그 확인 ==="
echo "백엔드 로그: pm2 logs assetmanager-backend"
echo "프론트엔드 로그: pm2 logs assetmanager-frontend"
echo "Nginx 로그: sudo tail -f /var/log/nginx/access.log" 