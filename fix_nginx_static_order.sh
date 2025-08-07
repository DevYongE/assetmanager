#!/bin/bash

# =============================================================================
# Nginx 정적 파일 처리 순서 수정 스크립트
# =============================================================================
#
# 이 스크립트는 Nginx에서 _nuxt 경로가 우선적으로 프론트엔드로
# 프록시되도록 설정 순서를 수정합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 Nginx 정적 파일 처리 순서를 수정합니다..."
echo ""

# =============================================================================
# 1. 현재 설정 백업
# =============================================================================
echo "📋 1단계: 현재 설정 백업"

BACKUP_FILE="/etc/nginx/conf.d/assetmanager.conf.backup.$(date +%Y%m%d_%H%M%S)"
sudo cp /etc/nginx/conf.d/assetmanager.conf "$BACKUP_FILE"
echo "✅ 백업 완료: $BACKUP_FILE"

echo ""

# =============================================================================
# 2. 새로운 Nginx 설정 적용 (순서 중요!)
# =============================================================================
echo "⚙️ 2단계: 새로운 Nginx 설정 적용"

# 새로운 Nginx 설정 생성 (순서가 중요!)
sudo tee /etc/nginx/conf.d/assetmanager.conf > /dev/null << 'EOF'
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

    # 2025-01-27: 백엔드 API (가장 우선순위 높음)
    location /api/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }

    # 2025-01-27: _nuxt 디렉토리 (두 번째 우선순위)
    # 이 설정이 정적 파일 확장자 설정보다 먼저 와야 함
    location ^~ /_nuxt/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
        
        # 정적 파일 캐싱
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }

    # 2025-01-27: 기타 정적 파일들 (세 번째 우선순위)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map)$ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
        
        # 정적 파일 캐싱
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }

    # 2025-01-27: 프론트엔드 (마지막 우선순위)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
        
        # SPA 라우팅을 위한 설정
        try_files $uri $uri/ @fallback;
    }

    # 2025-01-27: SPA 라우팅 폴백
    location @fallback {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

echo "✅ 새로운 Nginx 설정 적용 완료"

echo ""

# =============================================================================
# 3. Nginx 설정 테스트 및 재시작
# =============================================================================
echo "🧪 3단계: Nginx 설정 테스트 및 재시작"

echo "Nginx 설정 테스트..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx 설정 테스트 성공"
    
    echo "Nginx 재시작..."
    sudo systemctl restart nginx
    
    echo "Nginx 상태 확인..."
    sudo systemctl status nginx --no-pager
else
    echo "❌ Nginx 설정 테스트 실패"
    echo "백업 파일에서 복원합니다..."
    sudo cp "$BACKUP_FILE" /etc/nginx/conf.d/assetmanager.conf
    sudo nginx -t
    sudo systemctl restart nginx
    exit 1
fi

echo ""

# =============================================================================
# 4. 프론트엔드 상태 확인
# =============================================================================
echo "🔨 4단계: 프론트엔드 상태 확인"

echo "프론트엔드 빌드 파일 확인..."
if [ -d "/home/dmanager/assetmanager/frontend/.output/public/_nuxt" ]; then
    echo "✅ _nuxt 디렉토리 존재: /home/dmanager/assetmanager/frontend/.output/public/_nuxt"
    ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ | head -5
else
    echo "❌ _nuxt 디렉토리 없음"
fi

echo ""
echo "PM2 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 5. 최종 테스트
# =============================================================================
echo "🎯 5단계: 최종 테스트"

echo "5초 대기..."
sleep 5

echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "프론트엔드 직접 테스트:"
curl -I http://localhost:3000/_nuxt/ 2>/dev/null && echo "✅ 프론트엔드 _nuxt 경로 정상" || echo "❌ 프론트엔드 _nuxt 경로 실패"

echo ""
echo "웹사이트 테스트:"
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""
echo "정적 파일 테스트:"
curl -I https://invenone.it.kr/_nuxt/ 2>/dev/null && echo "✅ 정적 파일 경로 정상" || echo "❌ 정적 파일 경로 실패"

echo ""

# =============================================================================
# 6. 완료
# =============================================================================
echo "🎉 Nginx 정적 파일 처리 순서 수정 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Console 탭 확인"
echo "   4. Network 탭에서 _nuxt 파일들이 정상 로드되는지 확인"
echo ""
echo "🔧 관리 명령어:"
echo "   PM2 상태: pm2 status"
echo "   PM2 로그: pm2 logs"
echo "   Nginx 상태: sudo systemctl status nginx"
echo "   Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 