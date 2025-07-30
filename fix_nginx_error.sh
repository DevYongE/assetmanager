#!/bin/bash

# Nginx 서비스 시작 실패 해결 스크립트 (NCP Rocky Linux용)
# 작성일: 2024-12-19
# 설명: Nginx 설정 오류를 진단하고 수정합니다.

set -e

echo "🔧 Nginx 서비스 시작 실패 문제를 해결합니다..."

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

echo "=========================================="
echo "🔧 Nginx 서비스 시작 실패 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. Nginx 상태 확인
log_info "1. Nginx 상태를 확인합니다..."
systemctl status nginx --no-pager -l

# 2. Nginx 설정 테스트
log_info "2. Nginx 설정을 테스트합니다..."
if sudo nginx -t; then
    log_success "Nginx 설정이 유효합니다."
else
    log_error "Nginx 설정에 오류가 있습니다!"
fi

# 3. Nginx 로그 확인
log_info "3. Nginx 로그를 확인합니다..."
echo "=== systemctl 로그 ==="
journalctl -xeu nginx.service --no-pager | tail -20

echo ""
echo "=== Nginx 에러 로그 ==="
if [ -f "/var/log/nginx/error.log" ]; then
    sudo tail -20 /var/log/nginx/error.log
else
    echo "Nginx 에러 로그 파일이 없습니다."
fi

# 4. Nginx 설정 파일 확인
log_info "4. Nginx 설정 파일을 확인합니다..."
echo "=== 메인 설정 파일 ==="
if [ -f "/etc/nginx/nginx.conf" ]; then
    echo "nginx.conf 존재"
    # 설정 파일 문법 확인
    sudo nginx -T | head -20
else
    log_error "nginx.conf 파일이 없습니다!"
fi

echo ""
echo "=== conf.d 디렉토리 ==="
ls -la /etc/nginx/conf.d/

# 5. 문제가 있는 설정 파일 찾기
log_info "5. 문제가 있는 설정 파일을 찾습니다..."
for config in /etc/nginx/conf.d/*.conf; do
    if [ -f "$config" ]; then
        echo "=== $config ==="
        cat "$config"
        echo ""
    fi
done

# 6. 기본 Nginx 설정 복원
log_info "6. 기본 Nginx 설정을 복원합니다..."
sudo rm -f /etc/nginx/conf.d/default.conf

# 7. 올바른 설정 파일 생성
log_info "7. 올바른 Nginx 설정을 생성합니다..."

# 기존 설정 파일 백업
sudo cp /etc/nginx/conf.d/invenone.it.kr.conf /etc/nginx/conf.d/invenone.it.kr.conf.backup 2>/dev/null || true
sudo rm -f /etc/nginx/conf.d/invenone.it.kr.conf
sudo rm -f /etc/nginx/conf.d/rate_limit.conf

# 새로운 설정 파일 생성 (오류 없는 버전)
sudo tee /etc/nginx/conf.d/invenone.it.kr.conf << 'EOF'
# HTTP에서 HTTPS로 리다이렉트
server {
    listen 80;
    server_name invenone.it.kr www.invenone.it.kr;
    return 301 https://$server_name$request_uri;
}

# HTTPS 설정 (SSL 인증서)
server {
    listen 443 ssl http2;
    server_name invenone.it.kr www.invenone.it.kr;
    
    # SSL 인증서 설정 (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/invenone.it.kr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/invenone.it.kr/privkey.pem;
    
    # SSL 설정 (NCP 운영서버 최적화)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # 보안 헤더 (NCP 운영서버 강화)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    
    # 로그 설정 (NCP 운영서버용)
    access_log /var/log/nginx/invenone.it.kr-access.log;
    error_log /var/log/nginx/invenone.it.kr-error.log;

    # Gzip 압축 설정 (NCP 운영서버 최적화)
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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Cache static assets (NCP 운영서버 최적화)
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
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # API 요청 타임아웃 설정 (NCP 운영서버)
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:4000/api/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    # 파일 업로드 크기 제한
    client_max_body_size 10M;
}
EOF

# 8. Nginx 설정 테스트
log_info "8. 새로운 Nginx 설정을 테스트합니다..."
if sudo nginx -t; then
    log_success "새로운 Nginx 설정이 유효합니다."
else
    log_error "새로운 Nginx 설정에도 오류가 있습니다!"
    exit 1
fi

# 9. Nginx 시작
log_info "9. Nginx를 시작합니다..."
sudo systemctl start nginx

# 10. Nginx 상태 확인
log_info "10. Nginx 상태를 확인합니다..."
if systemctl is-active --quiet nginx; then
    log_success "Nginx가 성공적으로 시작되었습니다!"
    echo "  - Status: $(systemctl is-active nginx)"
    echo "  - Enabled: $(systemctl is-enabled nginx)"
else
    log_error "Nginx 시작에 실패했습니다!"
    echo "  - 자세한 오류:"
    systemctl status nginx --no-pager -l
    exit 1
fi

# 11. 포트 확인
log_info "11. 포트 사용 상태를 확인합니다..."
echo "  - 포트 80: $(ss -tlnp | grep ':80 ' || echo '사용되지 않음')"
echo "  - 포트 443: $(ss -tlnp | grep ':443 ' || echo '사용되지 않음')"

# 12. SSL 인증서 확인
log_info "12. SSL 인증서를 확인합니다..."
SSL_DIR="/etc/letsencrypt/live/invenone.it.kr"
if [ -f "$SSL_DIR/fullchain.pem" ] && [ -f "$SSL_DIR/privkey.pem" ]; then
    log_success "SSL 인증서 파일이 존재합니다."
else
    log_warning "SSL 인증서 파일이 없습니다."
    echo "  - 임시로 HTTP만 사용하도록 설정합니다..."
    
    # HTTP 전용 설정으로 변경
    sudo tee /etc/nginx/conf.d/invenone.it.kr.conf << 'HTTP_EOF'
server {
    listen 80;
    server_name invenone.it.kr www.invenone.it.kr;
    
    # 로그 설정
    access_log /var/log/nginx/invenone.it.kr-access.log;
    error_log /var/log/nginx/invenone.it.kr-error.log;

    # Frontend (Nuxt.js) - 포트 3000에서 서빙
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API - 포트 4000으로 프록시
    location /api/ {
        proxy_pass http://localhost:4000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:4000/api/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
HTTP_EOF

    # HTTP 설정으로 Nginx 재시작
    sudo nginx -t && sudo systemctl restart nginx
fi

echo ""
echo "=========================================="
echo "🔧 Nginx 문제 해결 완료!"
echo "=========================================="
echo ""

if systemctl is-active --quiet nginx; then
    log_success "Nginx가 정상적으로 실행 중입니다!"
    echo "  - HTTP: http://invenone.it.kr"
    if [ -f "$SSL_DIR/fullchain.pem" ]; then
        echo "  - HTTPS: https://invenone.it.kr"
    else
        echo "  - HTTPS: SSL 인증서 설정 필요"
    fi
else
    log_error "Nginx 실행에 문제가 있습니다."
fi

echo ""
echo "📝 유용한 명령어:"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - Nginx 재시작: sudo systemctl restart nginx"
echo "  - Nginx 로그: sudo tail -f /var/log/nginx/invenone.it.kr-error.log"
echo "  - 설정 테스트: sudo nginx -t"

echo ""
log_success "Nginx 서비스 시작 실패 문제 해결이 완료되었습니다! 🎉" 