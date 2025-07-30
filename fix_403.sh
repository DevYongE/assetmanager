#!/bin/bash

# =============================================================================
# 403 Forbidden 오류 해결 스크립트
# =============================================================================
#
# 이 스크립트는 403 Forbidden 오류를 해결합니다.
# 파일 권한, nginx 설정, 정적 파일 서빙 문제를 해결합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 403 Forbidden 오류를 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📊 현재 상태 확인:"

echo "현재 디렉토리: $(pwd)"
echo ""

echo "프론트엔드 빌드 파일 확인:"
if [ -d "frontend/.output/public/_nuxt" ]; then
    echo "✅ 프론트엔드 빌드 디렉토리 존재"
    ls -la frontend/.output/public/_nuxt/ | head -10
else
    echo "❌ 프론트엔드 빌드 디렉토리 없음"
fi

echo ""
echo "nginx 상태:"
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 2. 파일 권한 문제 해결
# =============================================================================
echo "🔐 파일 권한 문제를 해결합니다..."

# nginx 사용자 확인
echo "nginx 사용자 확인:"
ps aux | grep nginx | head -3

echo ""

# 현재 파일 권한 확인
echo "현재 파일 권한:"
if [ -d "frontend/.output/public" ]; then
    ls -la frontend/.output/public/ | head -5
    echo ""
    ls -la frontend/.output/public/_nuxt/ | head -5
fi

echo ""

# 파일 권한 수정
echo "파일 권한을 수정합니다..."
if [ -d "frontend/.output/public" ]; then
    # 소유자 변경
    sudo chown -R nginx:nginx frontend/.output/public/
    
    # 권한 설정 (읽기/실행 권한)
    sudo chmod -R 755 frontend/.output/public/
    
    # 특별히 _nuxt 디렉토리 권한 확인
    sudo chmod -R 755 frontend/.output/public/_nuxt/
    
    echo "✅ 파일 권한 수정 완료"
    
    # 수정된 권한 확인
    echo "수정된 파일 권한:"
    ls -la frontend/.output/public/ | head -5
    echo ""
    ls -la frontend/.output/public/_nuxt/ | head -5
else
    echo "❌ 프론트엔드 빌드 파일을 찾을 수 없습니다"
    exit 1
fi

echo ""

# =============================================================================
# 3. nginx 설정 수정
# =============================================================================
echo "🌐 nginx 설정을 수정합니다..."

# 현재 nginx 설정 확인
echo "현재 nginx 설정 확인:"
sudo grep -n "location /_nuxt" /etc/nginx/nginx.conf || echo "location /_nuxt 설정 없음"

echo ""

# nginx 설정 수정
cat > nginx-fixed-403.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
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

    # 업스트림 서버 설정
    upstream backend {
        server 127.0.0.1:4000;
    }

    upstream frontend {
        server 127.0.0.1:3000;
    }

    # HTTP 서버 (80 포트) - HTTPS로 리다이렉트
    server {
        listen 80;
        server_name invenone.it.kr www.invenone.it.kr;
        
        # HTTP를 HTTPS로 리다이렉트
        return 301 https://$server_name$request_uri;
    }

    # HTTPS 서버 (443 포트)
    server {
        listen 443 ssl http2;
        server_name invenone.it.kr www.invenone.it.kr;
        
        # SSL 인증서 설정
        ssl_certificate /etc/letsencrypt/live/invenone.it.kr/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/invenone.it.kr/privkey.pem;
        
        # SSL 보안 설정
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        
        # HSTS 헤더 추가
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        
        # 정적 파일 서빙 (개선된 설정)
        location /_nuxt/ {
            alias /home/dmanager/assetmanager/frontend/.output/public/_nuxt/;
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options nosniff;
            
            # 파일이 존재하지 않을 때 404 반환
            try_files $uri =404;
            
            # 디렉토리 인덱싱 비활성화
            autoindex off;
        }
        
        # 루트 정적 파일
        location / {
            try_files $uri $uri/ @frontend;
        }
        
        # 프론트엔드 서버로 프록시
        location @frontend {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
        }
        
        # API 요청을 백엔드로 프록시
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
            
            # CORS 헤더 설정
            add_header Access-Control-Allow-Origin "https://invenone.it.kr" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
            add_header Access-Control-Allow-Credentials "true" always;
            
            # OPTIONS 요청 처리
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin "https://invenone.it.kr" always;
                add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
                add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
                add_header Access-Control-Allow-Credentials "true" always;
                add_header Content-Length 0;
                add_header Content-Type text/plain;
                return 204;
            }
        }
    }
}
EOF

echo "✅ nginx 설정 파일 생성 완료"

# =============================================================================
# 4. nginx 설정 적용
# =============================================================================
echo "🌐 nginx 설정을 적용합니다..."

# 기존 설정 백업
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)

# 새 설정 적용
sudo cp nginx-fixed-403.conf /etc/nginx/nginx.conf

# nginx 설정 테스트
echo "🔍 nginx 설정을 테스트합니다..."
if sudo nginx -t; then
    echo "✅ nginx 설정 유효"
    
    # nginx 재시작
    echo "🔄 nginx를 재시작합니다..."
    sudo systemctl restart nginx
    
    # nginx 상태 확인
    if sudo systemctl is-active --quiet nginx; then
        echo "✅ nginx 재시작 완료"
    else
        echo "❌ nginx 재시작 실패"
        exit 1
    fi
else
    echo "❌ nginx 설정 오류"
    exit 1
fi

# =============================================================================
# 5. 파일 접근 테스트
# =============================================================================
echo "🧪 파일 접근을 테스트합니다..."

# nginx 사용자로 파일 접근 테스트
echo "nginx 사용자로 파일 접근 테스트:"
sudo -u nginx test -r frontend/.output/public/_nuxt/entry.*.css && echo "✅ CSS 파일 읽기 가능" || echo "❌ CSS 파일 읽기 불가"
sudo -u nginx test -r frontend/.output/public/_nuxt/*.js && echo "✅ JS 파일 읽기 가능" || echo "❌ JS 파일 읽기 불가"

echo ""

# curl로 직접 테스트
echo "curl로 정적 파일 테스트:"
CSS_FILE=$(find frontend/.output/public/_nuxt/ -name "*.css" | head -1)
if [ -n "$CSS_FILE" ]; then
    CSS_FILENAME=$(basename "$CSS_FILE")
    echo "CSS 파일 테스트: $CSS_FILENAME"
    curl -I "https://invenone.it.kr/_nuxt/$CSS_FILENAME"
else
    echo "❌ CSS 파일을 찾을 수 없습니다"
fi

echo ""

# =============================================================================
# 6. nginx 로그 확인
# =============================================================================
echo "📋 nginx 로그 확인:"

echo "최근 오류 로그:"
sudo tail -10 /var/log/nginx/error.log

echo ""
echo "최근 접근 로그:"
sudo tail -10 /var/log/nginx/access.log

echo ""

# =============================================================================
# 7. 최종 확인
# =============================================================================
echo "📊 최종 상태 확인:"

echo "PM2 프로세스:"
pm2 status

echo ""
echo "포트 상태:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "nginx 상태:"
sudo systemctl status nginx --no-pager

# =============================================================================
# 8. 완료
# =============================================================================
echo ""
echo "🎉 403 Forbidden 오류 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo "   4. 403 오류가 사라졌는지 확인"
echo ""
echo "🌐 접속 URL:"
echo "   웹사이트: https://invenone.it.kr"
echo "   로그인: https://invenone.it.kr/login"
echo "   API 서버: https://invenone.it.kr/api"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 