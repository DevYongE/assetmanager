#!/bin/bash

# QR Asset Management - Rocky Linux용 Nginx + PM2 배포 스크립트
# 작성일: 2024-12-19
# 설명: Rocky Linux용 완전한 배포 스크립트
# - dnf 패키지 관리자 사용
# - Rocky Linux 특성 반영
# - invenone.it.kr 도메인과 SSL 인증서 포함

set -e

echo "🚀 QR Asset Management Rocky Linux 배포를 시작합니다..."

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

# Rocky Linux 확인
log_info "Rocky Linux 시스템을 확인합니다..."
if ! grep -q "Rocky Linux" /etc/os-release; then
    log_warning "이 스크립트는 Rocky Linux용입니다. 다른 시스템에서는 문제가 발생할 수 있습니다."
fi

# 시스템 업데이트 (Rocky Linux용)
log_info "시스템 패키지를 업데이트합니다..."
sudo dnf update -y

# EPEL 저장소 활성화 (Rocky Linux용)
log_info "EPEL 저장소를 활성화합니다..."
sudo dnf install -y epel-release

# 필수 패키지 설치 (Rocky Linux용)
log_info "필수 패키지들을 설치합니다..."
sudo dnf install -y curl wget git gcc gcc-c++ make

# Node.js 설치 (Rocky Linux용)
log_info "Node.js 18 LTS를 설치합니다..."
if ! command -v node &> /dev/null; then
    # NodeSource 저장소 추가 (Rocky Linux용)
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo dnf install -y nodejs
fi

# PM2 전역 설치
log_info "PM2를 설치합니다..."
sudo npm install -g pm2

# Nginx 설치 (Rocky Linux용)
log_info "Nginx를 설치합니다..."
sudo dnf install -y nginx

# 방화벽 설정 (Rocky Linux용 - firewalld 사용)
log_info "방화벽을 설정합니다..."
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

# 프로젝트 디렉토리 설정
PROJECT_DIR="/var/www/qr-asset-management"
log_info "프로젝트 디렉토리를 설정합니다: $PROJECT_DIR"

# 디렉토리 생성
sudo mkdir -p $PROJECT_DIR
sudo chown -R $USER:$USER $PROJECT_DIR

# 프로젝트 파일 복사 또는 Git 클론
log_info "프로젝트 파일들을 설정합니다..."
if [ -d "backend" ] && [ -d "frontend" ]; then
    log_info "로컬 프로젝트 파일을 서버로 복사합니다..."
    cp -r backend $PROJECT_DIR/
    cp -r frontend $PROJECT_DIR/
    log_success "프로젝트 파일 복사가 완료되었습니다."
elif [ -d ".git" ]; then
    log_info "Git 저장소를 서버로 복사합니다..."
    cp -r . $PROJECT_DIR/
    cd $PROJECT_DIR
    log_success "Git 프로젝트 복사가 완료되었습니다."
else
    log_warning "로컬 프로젝트 파일이 없습니다."
    echo ""
    echo "🔧 프로젝트 파일 복사 옵션:"
    echo "1. 수동으로 파일 복사"
    echo "2. Git 저장소에서 클론"
    echo "3. 스크립트 중단"
    echo ""
    read -p "선택하세요 (1-3): " copy_choice
    
    case $copy_choice in
        1)
            log_info "수동으로 프로젝트를 복사해주세요."
            echo "다음 명령어로 프로젝트를 복사하세요:"
            echo "  scp -r backend/ user@server:/var/www/qr-asset-management/"
            echo "  scp -r frontend/ user@server:/var/www/qr-asset-management/"
            echo ""
            read -p "프로젝트 파일을 복사한 후 Enter를 누르세요..."
            ;;
        2)
            log_info "Git 저장소 URL을 입력해주세요:"
            read -p "Git URL: " git_url
            if [ ! -z "$git_url" ]; then
                cd $PROJECT_DIR
                git clone $git_url .
                log_success "Git 프로젝트 클론이 완료되었습니다."
            else
                log_error "Git URL이 입력되지 않았습니다."
                exit 1
            fi
            ;;
        3)
            log_info "스크립트를 중단합니다."
            exit 0
            ;;
        *)
            log_error "잘못된 선택입니다."
            exit 1
            ;;
    esac
fi

# 백엔드 설정
log_info "백엔드를 설정합니다..."
cd $PROJECT_DIR/backend

# 백엔드 의존성 설치
log_info "백엔드 의존성을 설치합니다..."
if [ -f "package.json" ]; then
    npm install
    log_success "백엔드 의존성 설치가 완료되었습니다."
else
    log_error "backend/package.json 파일을 찾을 수 없습니다!"
    log_error "프로젝트 파일이 올바르게 복사되었는지 확인해주세요."
    exit 1
fi

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

# CORS Configuration (invenone.it.kr 도메인 포함)
CORS_ORIGIN=https://invenone.it.kr
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
if [ -f "package.json" ]; then
    npm install
    log_success "프론트엔드 의존성 설치가 완료되었습니다."
    
    # 프론트엔드 빌드
    log_info "프론트엔드를 빌드합니다..."
    npm run build
    log_success "프론트엔드 빌드가 완료되었습니다."
else
    log_error "frontend/package.json 파일을 찾을 수 없습니다!"
    log_error "프로젝트 파일이 올바르게 복사되었는지 확인해주세요."
    exit 1
fi

# Let's Encrypt 인증서 디렉토리 확인
log_info "Let's Encrypt 인증서 디렉토리를 확인합니다..."
sudo mkdir -p /etc/letsencrypt/live/invenone.it.kr

# Nginx 설정 (SSL 포함) - Rocky Linux용 경로
log_info "Nginx 설정을 생성합니다 (SSL 포함)..."
sudo tee /etc/nginx/conf.d/invenone.it.kr.conf << EOF
# HTTP에서 HTTPS로 리다이렉트
server {
    listen 80;
    server_name invenone.it.kr www.invenone.it.kr;
    return 301 https://\$server_name\$request_uri;
}

# HTTPS 설정 (SSL 인증서)
server {
    listen 443 ssl http2;
    server_name invenone.it.kr www.invenone.it.kr;
    
    # SSL 인증서 설정 (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/invenone.it.kr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/invenone.it.kr/privkey.pem;
    
    # SSL 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # 보안 헤더
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
    
    # 로그 설정
    access_log /var/log/nginx/invenone.it.kr-access.log;
    error_log /var/log/nginx/invenone.it.kr-error.log;

    # Gzip 압축 설정
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

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
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header Vary Accept-Encoding;
        }
        
        # HTML 파일은 캐시하지 않음
        location ~* \.html$ {
            expires -1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
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
        
        # API 요청 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:4000/api/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
    
    # 파일 업로드 크기 제한
    client_max_body_size 10M;
}
EOF

# 기본 Nginx 설정 비활성화 (Rocky Linux용)
log_info "기본 Nginx 설정을 비활성화합니다..."
sudo rm -f /etc/nginx/conf.d/default.conf

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
echo "  - Firewalld: $(sudo systemctl is-active firewalld)"
echo "  - PM2 Backend: $(pm2 status | grep qr-backend || echo 'Not running')"
echo ""
echo "🌐 접속 정보:"
echo "  - Frontend: https://invenone.it.kr"
echo "  - Backend API: https://invenone.it.kr/api"
echo "  - Health Check: https://invenone.it.kr/health"
echo ""
echo "⚠️  중요: 다음 설정을 완료해주세요!"
echo "   1. Supabase 환경 변수 설정"
echo "   2. Let's Encrypt SSL 인증서 설정:"
echo "      - /etc/letsencrypt/live/invenone.it.kr/fullchain.pem"
echo "      - /etc/letsencrypt/live/invenone.it.kr/privkey.pem"
echo ""
echo "📝 유용한 명령어 (Rocky Linux용):"
echo "  - PM2 상태 확인: pm2 status"
echo "  - PM2 로그 확인: pm2 logs"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - 백엔드 재시작: pm2 restart qr-backend"
echo "  - SSL 인증서 확인: sudo nginx -t"
echo "  - 방화벽 상태: sudo firewall-cmd --list-all"
echo ""
log_success "QR Asset Management가 Rocky Linux에 성공적으로 배포되었습니다! 🎉" 