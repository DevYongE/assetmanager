#!/bin/bash

# QR 자산관리 시스템 통합 배포 스크립트 (2024-12-19)
# 설명: NCP Rocky Linux 서버에 QR 자산관리 시스템을 배포합니다.
# 도메인: invenone.it.kr
# SSL: Let's Encrypt (/etc/letsencrypt/live/invenone.it.kr/)

set -e

echo "🚀 QR 자산관리 시스템 배포를 시작합니다..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 프로젝트 디렉토리 설정 (현재 디렉토리 기준)
CURRENT_DIR=$(pwd)
BACKEND_DIR="$CURRENT_DIR/backend"
FRONTEND_DIR="$CURRENT_DIR/frontend"

echo "=========================================="
echo "🚀 QR 자산관리 시스템 배포"
echo "작성일: 2024-12-19"
echo "도메인: invenone.it.kr"
echo "=========================================="
echo ""

# =============================================================================
# 1단계: 시스템 환경 확인
# =============================================================================
log_info "1단계: 시스템 환경을 확인합니다..."

# OS 확인
if [ -f "/etc/redhat-release" ]; then
    log_success "Rocky Linux 환경이 감지되었습니다."
    OS_TYPE="rocky"
elif [ -f "/etc/debian_version" ]; then
    log_warning "Debian/Ubuntu 환경이 감지되었습니다."
    OS_TYPE="debian"
else
    log_warning "알 수 없는 OS 환경입니다."
    OS_TYPE="unknown"
fi

# NCP 환경 확인
if [ -f "/etc/ncp-info" ] || [ -d "/etc/ncp" ]; then
    log_success "NCP 환경이 감지되었습니다."
    NCP_ENV=true
else
    log_info "일반 서버 환경입니다."
    NCP_ENV=false
fi

# 현재 디렉토리 확인
log_info "현재 디렉토리를 확인합니다..."
echo "  - 현재 디렉토리: $CURRENT_DIR"
echo "  - 백엔드 디렉토리: $BACKEND_DIR"
echo "  - 프론트엔드 디렉토리: $FRONTEND_DIR"

# 프로젝트 파일 확인
if [ ! -d "$BACKEND_DIR" ] || [ ! -d "$FRONTEND_DIR" ]; then
    log_error "백엔드 또는 프론트엔드 디렉토리가 없습니다!"
    echo "  - 백엔드: $([ -d "$BACKEND_DIR" ] && echo '존재' || echo '없음')"
    echo "  - 프론트엔드: $([ -d "$FRONTEND_DIR" ] && echo '존재' || echo '없음')"
    exit 1
fi

log_success "프로젝트 구조가 올바릅니다."

# =============================================================================
# 2단계: 시스템 패키지 설치
# =============================================================================
log_info "2단계: 시스템 패키지를 설치합니다..."

if [ "$OS_TYPE" = "rocky" ]; then
    # Rocky Linux 패키지 설치
    log_info "Rocky Linux 패키지를 설치합니다..."
    
    # EPEL 저장소 활성화
    sudo dnf install -y epel-release
    
    # Node.js 저장소 추가
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    
    # 필수 패키지 설치
    sudo dnf install -y nodejs nginx firewalld
    
    # PM2 설치
    sudo npm install -g pm2
    
    # 시스템 서비스 활성화
    sudo systemctl enable nginx
    sudo systemctl enable firewalld
    
elif [ "$OS_TYPE" = "debian" ]; then
    # Ubuntu/Debian 패키지 설치
    log_info "Ubuntu/Debian 패키지를 설치합니다..."
    
    # Node.js 저장소 추가
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    
    # 필수 패키지 설치
    sudo apt update
    sudo apt install -y nodejs nginx ufw
    
    # PM2 설치
    sudo npm install -g pm2
fi

log_success "시스템 패키지 설치가 완료되었습니다."

# =============================================================================
# 3단계: 방화벽 설정
# =============================================================================
log_info "3단계: 방화벽을 설정합니다..."

if [ "$OS_TYPE" = "rocky" ]; then
    # Rocky Linux firewalld 설정
    sudo systemctl start firewalld
    
    # 포트 허용
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-port=3000/tcp
    sudo firewall-cmd --permanent --add-port=4000/tcp
    
    # 방화벽 재시작
    sudo firewall-cmd --reload
    
elif [ "$OS_TYPE" = "debian" ]; then
    # Ubuntu/Debian ufw 설정
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 3000/tcp
    sudo ufw allow 4000/tcp
    
    # UFW 활성화
    echo "y" | sudo ufw enable
fi

log_success "방화벽 설정이 완료되었습니다."

# =============================================================================
# 4단계: 백엔드 설정
# =============================================================================
log_info "4단계: 백엔드를 설정합니다..."

cd "$BACKEND_DIR"

# 의존성 설치
log_info "백엔드 의존성을 설치합니다..."
npm install

# .env 파일 생성
log_info "백엔드 환경 변수를 설정합니다..."
cat > .env << 'EOF'
# Supabase Configuration - 실제값으로 교체하세요
SUPABASE_URL=https://miiagipiurokjjotbuol.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNTI1MDUsImV4cCI6MjA2NDkyODUwNX0.9S7zWwA5fw2WSJgMJb8iZ7Nnq-Cml0l7vfULCy-Qz5g
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzM1MjUwNSwiZXhwIjoyMDY0OTI4NTA1fQ.YOM-UqbSIZPi0qWtM0jlUb4oS9mBDi-CMs95FYTPAXg

# Server Configuration
PORT=4000
NODE_ENV=production

# JWT Secret 강력한 비밀키로 교체하세요
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=https://invenone.it.kr
EOF

log_success "백엔드 환경 변수가 설정되었습니다."

# 백엔드 시작
log_info "백엔드를 PM2로 시작합니다..."
pm2 delete qr-backend 2>/dev/null || true
pm2 start index.js --name "qr-backend" --env production

sleep 5

# 백엔드 상태 확인
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "백엔드가 정상적으로 실행됩니다!"
else
    log_error "백엔드가 응답하지 않습니다!"
    pm2 logs qr-backend --lines 5
fi

# =============================================================================
# 5단계: 프론트엔드 설정
# =============================================================================
log_info "5단계: 프론트엔드를 설정합니다..."

cd "$FRONTEND_DIR"

# 의존성 설치
log_info "프론트엔드 의존성을 설치합니다..."
npm install

# 기존 빌드 파일 정리
if [ -d ".output" ]; then
    log_info "기존 빌드 파일을 정리합니다..."
    rm -rf .output
fi

if [ -d ".nuxt" ]; then
    log_info "기존 .nuxt 디렉토리를 정리합니다..."
    rm -rf .nuxt
fi

# Nuxt 설정 수정
log_info "Nuxt 설정을 수정합니다..."
cat > nuxt.config.ts << 'EOF'
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  ssr: true,
  nitro: {
    preset: 'node-server'
  },
  runtimeConfig: {
    public: {
      apiBase: process.env.API_BASE || 'http://localhost:4000'
    }
  }
})
EOF

# 프론트엔드 빌드
log_info "프론트엔드를 빌드합니다..."
if npm run build; then
    log_success "프론트엔드 빌드가 완료되었습니다!"
else
    log_error "프론트엔드 빌드에 실패했습니다!"
    exit 1
fi

# 빌드 결과 확인
if [ -d ".output" ]; then
    log_success ".output 디렉토리가 생성되었습니다."
    
    # 서버 파일 확인
    if [ -f ".output/server/index.mjs" ] || [ -f ".output/server/index.js" ]; then
        log_success "서버 파일이 생성되었습니다."
    else
        log_warning "서버 파일이 없습니다. 개발 서버로 실행합니다."
        pm2 delete qr-frontend 2>/dev/null || true
        pm2 start npm --name "qr-frontend" -- run dev
        log_success "개발 서버가 시작되었습니다."
        exit 0
    fi
else
    log_error ".output 디렉토리가 생성되지 않았습니다!"
    exit 1
fi

# PM2 설정 파일 생성
log_info "PM2 설정 파일을 생성합니다..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'qr-frontend',
    script: 'node',
    args: '.output/server/index.mjs',
    cwd: process.cwd(),
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      NITRO_HOST: '0.0.0.0',
      NITRO_PORT: 3000
    }
  }]
}
EOF

# 프론트엔드 시작
log_info "프론트엔드를 PM2로 시작합니다..."
pm2 delete qr-frontend 2>/dev/null || true
pm2 start ecosystem.config.js

sleep 5

# 프론트엔드 상태 확인
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "프론트엔드가 정상적으로 실행됩니다!"
else
    log_error "프론트엔드가 응답하지 않습니다!"
    pm2 logs qr-frontend --lines 5
fi

# =============================================================================
# 6단계: Nginx 설정
# =============================================================================
log_info "6단계: Nginx를 설정합니다..."

# Nginx 설정 파일 생성
sudo tee /etc/nginx/conf.d/invenone.it.kr.conf > /dev/null << 'EOF'
# Rate limiting 설정
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

# HTTP 서버 (80 포트)
server {
    listen 80;
    server_name invenone.it.kr www.invenone.it.kr;
    
    # HTTP에서 HTTPS로 리다이렉트
    return 301 https://$server_name$request_uri;
}

# HTTPS 서버 (443 포트)
server {
    listen 443 ssl http2;
    server_name invenone.it.kr www.invenone.it.kr;
    
    # SSL 인증서 설정
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
    
    # 프록시 설정
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # API 요청 타임아웃 설정
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
    
    # Rate limiting 적용
    limit_req zone=api burst=20 nodelay;
    
    # 프론트엔드 (Nuxt.js)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }
    
    # 백엔드 API
    location /api/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }
    
    # 정적 파일 캐싱
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }
}
EOF

# Nginx 설정 테스트
if sudo nginx -t; then
    log_success "Nginx 설정이 유효합니다."
else
    log_error "Nginx 설정에 오류가 있습니다!"
    exit 1
fi

# Nginx 시작
sudo systemctl restart nginx

# Nginx 상태 확인
if sudo systemctl is-active --quiet nginx; then
    log_success "Nginx가 정상적으로 실행됩니다!"
else
    log_error "Nginx가 실행되지 않습니다!"
    sudo systemctl status nginx
    exit 1
fi

# =============================================================================
# 7단계: SSL 인증서 확인
# =============================================================================
log_info "7단계: SSL 인증서를 확인합니다..."

# SSL 인증서 파일 확인
if [ -f "/etc/letsencrypt/live/invenone.it.kr/fullchain.pem" ] && [ -f "/etc/letsencrypt/live/invenone.it.kr/privkey.pem" ]; then
    log_success "SSL 인증서가 존재합니다."
else
    log_warning "SSL 인증서가 없습니다. HTTP로만 실행됩니다."
    # HTTP 전용 설정으로 변경
    sudo tee /etc/nginx/conf.d/invenone.it.kr.conf > /dev/null << 'EOF'
server {
    listen 80;
    server_name invenone.it.kr www.invenone.it.kr;
    
    # 프록시 설정
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # 프론트엔드 (Nuxt.js)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }
    
    # 백엔드 API
    location /api/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
    sudo nginx -t && sudo systemctl restart nginx
fi

# =============================================================================
# 8단계: 최종 상태 확인
# =============================================================================
log_info "8단계: 최종 상태를 확인합니다..."

echo ""
echo "=== 배포 상태 확인 ==="
echo "  - PM2 Backend: $(pm2 list | grep qr-backend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - PM2 Frontend: $(pm2 list | grep qr-frontend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - Nginx: $(systemctl is-active nginx)"
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 4000: $(ss -tlnp | grep ':4000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 80: $(ss -tlnp | grep ':80 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 443: $(ss -tlnp | grep ':443 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "로컬 프론트엔드 연결: 정상"
else
    log_error "로컬 프론트엔드 연결: 실패"
fi

if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "로컬 백엔드 연결: 정상"
else
    log_error "로컬 백엔드 연결: 실패"
fi

if curl -s http://invenone.it.kr &> /dev/null; then
    log_success "도메인 프론트엔드 연결: 정상"
else
    log_warning "도메인 프론트엔드 연결: 실패"
fi

if curl -s http://invenone.it.kr/api/health &> /dev/null; then
    log_success "도메인 백엔드 연결: 정상"
else
    log_warning "도메인 백엔드 연결: 실패"
fi

echo ""
echo "=========================================="
echo "🎉 QR 자산관리 시스템 배포 완료!"
echo "=========================================="
echo ""

log_success "배포가 완료되었습니다! 🎉"
echo ""
echo "📝 접속 정보:"
echo "  - Frontend: http://invenone.it.kr"
echo "  - Backend API: http://invenone.it.kr/api"
echo "  - Health Check: http://invenone.it.kr/api/health"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo "  - 서비스 재시작: pm2 restart all" 