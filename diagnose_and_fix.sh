#!/bin/bash

# =============================================================================
# 완전 초기화 및 재설정 스크립트
# =============================================================================
#
# 모든 것을 처음부터 다시 설정합니다.
# 기존 설정을 정리하고 새로 시작합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔄 완전 초기화 및 재설정을 시작합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📊 1단계: 현재 상태 확인"

echo "현재 디렉토리: $(pwd)"
echo ""

echo "프로젝트 구조 확인:"
ls -la
echo ""

echo "프론트엔드 빌드 상태:"
if [ -d "frontend/.output" ]; then
    echo "✅ frontend/.output 디렉토리 존재"
    ls -la frontend/.output/
    echo ""
    if [ -d "frontend/.output/public/_nuxt" ]; then
        echo "✅ _nuxt 디렉토리 존재"
        ls -la frontend/.output/public/_nuxt/ | head -10
    else
        echo "❌ _nuxt 디렉토리 없음"
    fi
else
    echo "❌ frontend/.output 디렉토리 없음"
fi

echo ""
echo "PM2 프로세스 확인:"
pm2 status

echo ""
echo "포트 사용 상태:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "nginx 상태:"
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 2. 모든 프로세스 중지
# =============================================================================
echo "🛑 2단계: 모든 프로세스 중지"

echo "PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "nginx 중지..."
sudo systemctl stop nginx

echo "포트 사용 프로세스 확인 및 중지..."
sudo lsof -ti:3000 | xargs -r sudo kill -9
sudo lsof -ti:4000 | xargs -r sudo kill -9
sudo lsof -ti:80 | xargs -r sudo kill -9
sudo lsof -ti:443 | xargs -r sudo kill -9

echo "✅ 모든 프로세스 중지 완료"
echo ""

# =============================================================================
# 3. 기존 빌드 파일 정리
# =============================================================================
echo "🧹 3단계: 기존 빌드 파일 정리"

echo "프론트엔드 빌드 파일 정리..."
if [ -d "frontend/.output" ]; then
    rm -rf frontend/.output
    echo "✅ frontend/.output 삭제 완료"
fi

if [ -d "frontend/.nuxt" ]; then
    rm -rf frontend/.nuxt
    echo "✅ frontend/.nuxt 삭제 완료"
fi

if [ -d "frontend/node_modules" ]; then
    rm -rf frontend/node_modules
    echo "✅ frontend/node_modules 삭제 완료"
fi

echo "백엔드 node_modules 정리..."
if [ -d "backend/node_modules" ]; then
    rm -rf backend/node_modules
    echo "✅ backend/node_modules 삭제 완료"
fi

echo "✅ 빌드 파일 정리 완료"
echo ""

# =============================================================================
# 4. 의존성 재설치
# =============================================================================
echo "📦 4단계: 의존성 재설치"

echo "백엔드 의존성 설치..."
cd backend
npm install
cd ..

echo "프론트엔드 의존성 설치..."
cd frontend
npm install
cd ..

echo "✅ 의존성 설치 완료"
echo ""

# =============================================================================
# 5. 프론트엔드 새로 빌드
# =============================================================================
echo "🔨 5단계: 프론트엔드 새로 빌드"

echo "프론트엔드 빌드 시작..."
cd frontend

# 환경 변수 설정
export NODE_ENV=production
export API_BASE_URL=https://invenone.it.kr/api

echo "빌드 명령어: npm run build"
npm run build

# 빌드 결과 확인
if [ -d ".output/public/_nuxt" ]; then
    echo "✅ 빌드 성공!"
    echo "빌드된 파일들:"
    ls -la .output/public/_nuxt/ | head -10
    echo ""
    echo "CSS 파일 확인:"
    find .output/public/_nuxt/ -name "*.css" | head -5
    echo ""
    echo "JS 파일 확인:"
    find .output/public/_nuxt/ -name "*.js" | head -5
else
    echo "❌ 빌드 실패!"
    exit 1
fi

cd ..

echo ""

# =============================================================================
# 6. 백엔드 시작
# =============================================================================
echo "🚀 6단계: 백엔드 시작"

echo "백엔드 PM2 시작..."
cd backend
pm2 start index.js --name "backend" -- --port 4000
cd ..

echo "백엔드 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 7. 프론트엔드 시작
# =============================================================================
echo "🌐 7단계: 프론트엔드 시작"

echo "프론트엔드 PM2 시작..."
cd frontend
pm2 start .output/server/index.mjs --name "frontend" -- --port 3000
cd ..

echo "프론트엔드 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 8. nginx 설정 완전 재작성
# =============================================================================
echo "🌐 8단계: nginx 설정 완전 재작성"

# 현재 nginx 설정 백업
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)

# 새로운 nginx 설정 작성
cat > nginx-clean.conf << 'EOF'
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
        
        # 정적 파일 서빙 (Nuxt.js 빌드 파일)
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

# nginx 설정 적용
sudo cp nginx-clean.conf /etc/nginx/nginx.conf

# nginx 설정 테스트
echo "🔍 nginx 설정 테스트..."
if sudo nginx -t; then
    echo "✅ nginx 설정 유효"
    
    # nginx 시작
    echo "🔄 nginx 시작..."
    sudo systemctl start nginx
    
    # nginx 상태 확인
    if sudo systemctl is-active --quiet nginx; then
        echo "✅ nginx 시작 완료"
    else
        echo "❌ nginx 시작 실패"
        exit 1
    fi
else
    echo "❌ nginx 설정 오류"
    exit 1
fi

echo ""

# =============================================================================
# 9. 파일 권한 설정
# =============================================================================
echo "🔐 9단계: 파일 권한 설정"

echo "프론트엔드 빌드 파일 권한 설정..."
if [ -d "frontend/.output/public" ]; then
    # 소유자 변경
    sudo chown -R nginx:nginx frontend/.output/public/
    
    # 권한 설정
    sudo chmod -R 755 frontend/.output/public/
    
    echo "✅ 파일 권한 설정 완료"
    
    # 권한 확인
    echo "설정된 권한 확인:"
    ls -la frontend/.output/public/ | head -5
    echo ""
    ls -la frontend/.output/public/_nuxt/ | head -5
else
    echo "❌ 프론트엔드 빌드 파일을 찾을 수 없습니다"
    exit 1
fi

echo ""

# =============================================================================
# 10. 최종 테스트
# =============================================================================
echo "🧪 10단계: 최종 테스트"

echo "PM2 프로세스 상태:"
pm2 status

echo ""
echo "포트 상태:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "nginx 상태:"
sudo systemctl status nginx --no-pager

echo ""
echo "파일 접근 테스트:"
CSS_FILE=$(find frontend/.output/public/_nuxt/ -name "*.css" | head -1)
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

# =============================================================================
# 11. 완료
# =============================================================================
echo "🎉 완전 초기화 및 재설정 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo "   4. 404 오류가 해결되었는지 확인"
echo ""
echo "🌐 접속 URL:"
echo "   웹사이트: https://invenone.it.kr"
echo "   로그인: https://invenone.it.kr/login"
echo "   API 서버: https://invenone.it.kr/api"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 