#!/bin/bash

# Nginx 설정 스크립트
# 작성일: 2024-12-19
# 설명: QR Asset Management를 위한 Nginx 설정을 생성하고 적용합니다.

set -e

echo "🔧 Nginx 설정을 시작합니다..."

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

# 기존 Nginx 설정 백업
log_info "기존 Nginx 설정을 백업합니다..."
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)

# Nginx 사이트 설정 생성
log_info "QR Asset Management Nginx 설정을 생성합니다..."
sudo tee /etc/nginx/sites-available/qr-asset-management << 'EOF'
# QR Asset Management Nginx Configuration
# 작성일: 2024-12-19

server {
    listen 80;
    server_name localhost;
    
    # 로그 설정
    access_log /var/log/nginx/qr-asset-access.log;
    error_log /var/log/nginx/qr-asset-error.log;

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

    # Frontend (Nuxt.js)
    location / {
        root /var/www/qr-asset-management/frontend/.output/public;
        try_files $uri $uri/ /index.html;
        
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

    # Backend API
    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # API 요청 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
    
    # 파일 업로드 크기 제한
    client_max_body_size 10M;
}

# HTTP에서 HTTPS로 리다이렉트 (선택사항)
# server {
#     listen 80;
#     server_name localhost;
#     return 301 https://$server_name$request_uri;
# }

# HTTPS 설정 (SSL 인증서가 있는 경우)
# server {
#     listen 443 ssl http2;
#     server_name localhost;
#     
#     ssl_certificate /path/to/certificate.crt;
#     ssl_certificate_key /path/to/private.key;
#     
#     # SSL 설정
#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
#     ssl_prefer_server_ciphers off;
#     
#     # 나머지 설정은 위와 동일
# }
EOF

# 기존 사이트 비활성화
log_info "기존 사이트를 비활성화합니다..."
sudo rm -f /etc/nginx/sites-enabled/default

# 새 사이트 활성화
log_info "QR Asset Management 사이트를 활성화합니다..."
sudo ln -sf /etc/nginx/sites-available/qr-asset-management /etc/nginx/sites-enabled/

# Nginx 설정 테스트
log_info "Nginx 설정을 테스트합니다..."
if sudo nginx -t; then
    log_success "Nginx 설정이 유효합니다!"
else
    log_error "Nginx 설정에 오류가 있습니다!"
    exit 1
fi

# Nginx 재시작
log_info "Nginx를 재시작합니다..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# 방화벽 설정 확인
log_info "방화벽 설정을 확인합니다..."
sudo ufw status | grep -q "Nginx Full" || {
    log_warning "Nginx 방화벽 규칙이 설정되지 않았습니다. 설정합니다..."
    sudo ufw allow 'Nginx Full'
}

# 상태 확인
log_info "서비스 상태를 확인합니다..."
echo ""
echo "📊 Nginx 상태:"
echo "  - Status: $(sudo systemctl is-active nginx)"
echo "  - Enabled: $(sudo systemctl is-enabled nginx)"
echo ""
echo "🌐 접속 정보:"
echo "  - Frontend: http://localhost"
echo "  - Backend API: http://localhost/api"
echo "  - Health Check: http://localhost/health"
echo ""
echo "📝 유용한 명령어:"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - Nginx 재시작: sudo systemctl restart nginx"
echo "  - Nginx 설정 테스트: sudo nginx -t"
echo "  - Nginx 로그 확인: sudo tail -f /var/log/nginx/qr-asset-error.log"
echo ""
log_success "Nginx 설정이 완료되었습니다! 🎉" 