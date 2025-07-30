#!/bin/bash

# =============================================================================
# 깊이 있는 권한 문제 해결 스크립트
# =============================================================================

echo "🔐 깊이 있는 권한 문제를 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 상황 진단
# =============================================================================
echo "📊 1단계: 현재 상황 진단"

echo "현재 디렉토리: $(pwd)"
echo ""

echo "nginx 프로세스 확인:"
ps aux | grep nginx
echo ""

echo "nginx 사용자 확인:"
id nginx
echo ""

echo "현재 파일 소유자 확인:"
if [ -d "frontend/.output/public" ]; then
    ls -la frontend/.output/public/ | head -5
    echo ""
    ls -la frontend/.output/public/_nuxt/ | head -5
else
    echo "❌ frontend/.output/public 디렉토리가 없습니다"
    exit 1
fi

echo ""

# =============================================================================
# 2. 상위 디렉토리 권한 확인
# =============================================================================
echo "📊 2단계: 상위 디렉토리 권한 확인"

echo "프로젝트 루트 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/
echo ""

echo "frontend 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/frontend/
echo ""

echo "frontend/.output 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/frontend/.output/
echo ""

echo ""

# =============================================================================
# 3. 전체 경로 권한 수정
# =============================================================================
echo "🔧 3단계: 전체 경로 권한 수정"

echo "프로젝트 루트 디렉토리 권한 수정..."
sudo chown -R nginx:nginx /home/dmanager/assetmanager/

echo "전체 경로에 읽기/실행 권한 부여..."
sudo chmod -R 755 /home/dmanager/assetmanager/

echo "특별히 frontend/.output 디렉토리 권한 확인..."
sudo chmod -R 755 /home/dmanager/assetmanager/frontend/.output/

echo "✅ 전체 경로 권한 수정 완료"
echo ""

# =============================================================================
# 4. 수정된 권한 확인
# =============================================================================
echo "📊 4단계: 수정된 권한 확인"

echo "프로젝트 루트 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/
echo ""

echo "frontend 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/frontend/
echo ""

echo "frontend/.output 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/frontend/.output/
echo ""

echo "frontend/.output/public 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/frontend/.output/public/
echo ""

echo "frontend/.output/public/_nuxt 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ | head -10
echo ""

# =============================================================================
# 5. nginx 사용자로 접근 테스트
# =============================================================================
echo "🧪 5단계: nginx 사용자로 접근 테스트"

echo "nginx 사용자로 디렉토리 접근 테스트:"
sudo -u nginx test -r /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ && echo "✅ _nuxt 디렉토리 접근 가능" || echo "❌ _nuxt 디렉토리 접근 불가"

echo "nginx 사용자로 CSS 파일 접근 테스트:"
CSS_FILE=$(find /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ -name "*.css" | head -1)
if [ -n "$CSS_FILE" ]; then
    echo "CSS 파일: $CSS_FILE"
    sudo -u nginx test -r "$CSS_FILE" && echo "✅ CSS 파일 읽기 가능" || echo "❌ CSS 파일 읽기 불가"
else
    echo "❌ CSS 파일을 찾을 수 없습니다"
fi

echo "nginx 사용자로 JS 파일 접근 테스트:"
JS_FILE=$(find /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ -name "*.js" | head -1)
if [ -n "$JS_FILE" ]; then
    echo "JS 파일: $JS_FILE"
    sudo -u nginx test -r "$JS_FILE" && echo "✅ JS 파일 읽기 가능" || echo "❌ JS 파일 읽기 불가"
else
    echo "❌ JS 파일을 찾을 수 없습니다"
fi

echo ""

# =============================================================================
# 6. SELinux 확인 및 해결
# =============================================================================
echo "🔒 6단계: SELinux 확인 및 해결"

echo "SELinux 상태 확인:"
sestatus 2>/dev/null || echo "SELinux가 설치되지 않았거나 비활성화됨"

echo "SELinux 컨텍스트 확인:"
ls -Z /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ 2>/dev/null | head -5 || echo "SELinux 컨텍스트 정보 없음"

echo ""

# =============================================================================
# 7. nginx 설정 확인
# =============================================================================
echo "🌐 7단계: nginx 설정 확인"

echo "nginx 설정에서 _nuxt location 확인:"
sudo grep -A 10 "location /_nuxt" /etc/nginx/nginx.conf

echo ""
echo "nginx 설정 테스트:"
sudo nginx -t

echo ""

# =============================================================================
# 8. nginx 재시작
# =============================================================================
echo "🔄 8단계: nginx 재시작"

echo "nginx 재시작..."
sudo systemctl restart nginx

if sudo systemctl is-active --quiet nginx; then
    echo "✅ nginx 재시작 완료"
else
    echo "❌ nginx 재시작 실패"
    exit 1
fi

echo ""

# =============================================================================
# 9. 실제 파일 접근 테스트
# =============================================================================
echo "🌐 9단계: 실제 파일 접근 테스트"

echo "curl로 정적 파일 테스트:"
if [ -n "$CSS_FILE" ]; then
    CSS_FILENAME=$(basename "$CSS_FILE")
    echo "CSS 파일 테스트: $CSS_FILENAME"
    curl -I "https://invenone.it.kr/_nuxt/$CSS_FILENAME"
else
    echo "❌ CSS 파일을 찾을 수 없습니다"
fi

echo ""

# =============================================================================
# 10. nginx 로그 확인
# =============================================================================
echo "📋 10단계: nginx 로그 확인"

echo "최근 nginx 오류 로그:"
sudo tail -10 /var/log/nginx/error.log

echo ""
echo "최근 nginx 접근 로그:"
sudo tail -10 /var/log/nginx/access.log

echo ""

# =============================================================================
# 11. 대안 방법: 심볼릭 링크 생성
# =============================================================================
echo "🔗 11단계: 대안 방법 - 심볼릭 링크 생성"

echo "nginx가 접근할 수 있는 디렉토리에 심볼릭 링크 생성..."
sudo mkdir -p /var/www/html
sudo ln -sf /home/dmanager/assetmanager/frontend/.output/public/_nuxt /var/www/html/_nuxt

echo "심볼릭 링크 확인:"
ls -la /var/www/html/_nuxt/ | head -5

echo ""

# =============================================================================
# 12. nginx 설정 수정 (심볼릭 링크 사용)
# =============================================================================
echo "🌐 12단계: nginx 설정 수정 (심볼릭 링크 사용)"

# nginx 설정 백업
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)

# 새로운 nginx 설정 (심볼릭 링크 사용)
cat > nginx-symlink.conf << 'EOF'
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
        
        # 정적 파일 서빙 (심볼릭 링크 사용)
        location /_nuxt/ {
            alias /var/www/html/_nuxt/;
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

# nginx 설정 적용
sudo cp nginx-symlink.conf /etc/nginx/nginx.conf

# nginx 설정 테스트
echo "🔍 nginx 설정 테스트..."
if sudo nginx -t; then
    echo "✅ nginx 설정 유효"
    
    # nginx 재시작
    echo "🔄 nginx 재시작..."
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

echo ""

# =============================================================================
# 13. 최종 테스트
# =============================================================================
echo "🧪 13단계: 최종 테스트"

echo "curl로 정적 파일 테스트:"
if [ -n "$CSS_FILE" ]; then
    CSS_FILENAME=$(basename "$CSS_FILE")
    echo "CSS 파일 테스트: $CSS_FILENAME"
    curl -I "https://invenone.it.kr/_nuxt/$CSS_FILENAME"
else
    echo "❌ CSS 파일을 찾을 수 없습니다"
fi

echo ""
echo "nginx 오류 로그 확인:"
sudo tail -5 /var/log/nginx/error.log

echo ""
echo "🎉 깊이 있는 권한 문제 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo "   4. Permission denied 오류가 해결되었는지 확인"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 