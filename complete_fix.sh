#!/bin/bash

# =============================================================================
# 완전한 문제 해결 스크립트
# =============================================================================
#
# 이 스크립트는 모든 문제를 해결합니다:
# - nginx 설정 문제
# - 프론트엔드 빌드 문제
# - PM2 프로세스 문제
# - 파일 권한 문제
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 완전한 문제 해결을 시작합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📊 현재 상태 확인:"

echo "현재 디렉토리: $(pwd)"
echo ""

echo "PM2 프로세스:"
pm2 status

echo ""
echo "포트 상태:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)' || echo "포트 정보 없음"

echo ""
echo "nginx 상태:"
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 2. 모든 프로세스 중지
# =============================================================================
echo "⏹️ 모든 프로세스를 중지합니다..."

# PM2 프로세스 중지
pm2 delete all 2>/dev/null || true
echo "✅ PM2 프로세스 중지 완료"

# nginx 중지
sudo systemctl stop nginx
echo "✅ nginx 중지 완료"

echo ""

# =============================================================================
# 3. 실제 경로 확인
# =============================================================================
echo "📁 실제 경로를 확인합니다..."

# 현재 작업 디렉토리 확인
CURRENT_DIR=$(pwd)
echo "현재 디렉토리: $CURRENT_DIR"

# 프론트엔드 빌드 경로 확인
FRONTEND_BUILD_PATH="$CURRENT_DIR/frontend/.output/public/_nuxt"
echo "프론트엔드 빌드 경로: $FRONTEND_BUILD_PATH"

if [ -d "$FRONTEND_BUILD_PATH" ]; then
    echo "✅ 프론트엔드 빌드 디렉토리 존재"
    ls -la "$FRONTEND_BUILD_PATH" | head -5
else
    echo "❌ 프론트엔드 빌드 디렉토리 없음"
fi

echo ""

# =============================================================================
# 4. nginx 설정 수정
# =============================================================================
echo "🌐 nginx 설정을 수정합니다..."

# 실제 경로로 nginx 설정 수정
cat > nginx-fixed.conf << EOF
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
    
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';
    
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
        return 301 https://\$server_name\$request_uri;
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
        
        # 정적 파일 서빙 (실제 경로 사용)
        location /_nuxt/ {
            alias $FRONTEND_BUILD_PATH/;
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options nosniff;
        }
        
        # 루트 정적 파일
        location / {
            try_files \$uri \$uri/ @frontend;
        }
        
        # 프론트엔드 서버로 프록시
        location @frontend {
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_set_header X-Forwarded-Host \$host;
            proxy_set_header X-Forwarded-Port \$server_port;
        }
        
        # API 요청을 백엔드로 프록시
        location /api/ {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            proxy_set_header X-Forwarded-Host \$host;
            proxy_set_header X-Forwarded-Port \$server_port;
            
            # CORS 헤더 설정
            add_header Access-Control-Allow-Origin "https://invenone.it.kr" always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
            add_header Access-Control-Allow-Credentials "true" always;
            
            # OPTIONS 요청 처리
            if (\$request_method = 'OPTIONS') {
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
# 5. 백엔드 배포
# =============================================================================
echo "🔧 백엔드를 배포합니다..."

cd backend

# 의존성 설치
echo "📦 백엔드 의존성을 설치합니다..."
npm install

# PM2로 백엔드 시작
echo "🚀 백엔드 서버를 시작합니다..."
pm2 start index.js --name backend --watch

cd ..
echo "✅ 백엔드 배포 완료"

# =============================================================================
# 6. 프론트엔드 재빌드 및 배포
# =============================================================================
echo "🔧 프론트엔드를 재빌드하고 배포합니다..."

cd frontend

# 의존성 설치
echo "📦 프론트엔드 의존성을 설치합니다..."
npm install

# 기존 빌드 파일 삭제
echo "🗑️ 기존 빌드 파일을 삭제합니다..."
rm -rf .output

# 프로덕션 빌드
echo "🏗️ 프론트엔드를 빌드합니다..."
npm run build

# 빌드 결과 확인
if [ -d ".output/public/_nuxt" ]; then
    echo "✅ 프론트엔드 빌드 성공"
    ls -la .output/public/_nuxt/ | head -5
else
    echo "❌ 프론트엔드 빌드 실패"
    exit 1
fi

# PM2로 프론트엔드 시작
echo "🚀 프론트엔드 서버를 시작합니다..."
pm2 start npm --name frontend -- run preview

cd ..
echo "✅ 프론트엔드 배포 완료"

# =============================================================================
# 7. 파일 권한 설정
# =============================================================================
echo "🔐 파일 권한을 설정합니다..."

if [ -d "frontend/.output/public" ]; then
    sudo chown -R nginx:nginx frontend/.output/public/
    sudo chmod -R 755 frontend/.output/public/
    echo "✅ 파일 권한 설정 완료"
else
    echo "❌ 프론트엔드 빌드 파일을 찾을 수 없습니다"
    exit 1
fi

# =============================================================================
# 8. nginx 설정 적용
# =============================================================================
echo "🌐 nginx 설정을 적용합니다..."

# nginx 설정 파일 복사
sudo cp nginx-fixed.conf /etc/nginx/nginx.conf

# nginx 설정 테스트
echo "🔍 nginx 설정을 테스트합니다..."
if sudo nginx -t; then
    echo "✅ nginx 설정 유효"
    
    # nginx 시작
    echo "🔄 nginx를 시작합니다..."
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

# =============================================================================
# 9. 방화벽 설정
# =============================================================================
echo "🔥 방화벽 설정을 확인합니다..."

# 필요한 포트 열기
sudo ufw allow 80 2>/dev/null || true
sudo ufw allow 443 2>/dev/null || true
sudo ufw allow 3000 2>/dev/null || true
sudo ufw allow 4000 2>/dev/null || true

echo "✅ 방화벽 설정 완료"

# =============================================================================
# 10. 최종 확인
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
# 11. 테스트
# =============================================================================
echo "🧪 연결을 테스트합니다..."

echo "HTTP 테스트:"
curl -I http://invenone.it.kr

echo ""
echo "HTTPS 테스트:"
curl -I -k https://invenone.it.kr

echo ""
echo "API 테스트:"
curl -I -k https://invenone.it.kr/api/health

# =============================================================================
# 12. 완료
# =============================================================================
echo ""
echo "🎉 완전한 문제 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 오류 확인"
echo ""
echo "🌐 접속 URL:"
echo "   웹사이트: https://invenone.it.kr"
echo "   API 서버: https://invenone.it.kr/api"
echo "   헬스체크: https://invenone.it.kr/api/health"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 