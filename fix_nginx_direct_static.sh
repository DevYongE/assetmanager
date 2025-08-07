#!/bin/bash

# =============================================================================
# Nginx 정적 파일 직접 서빙 설정 스크립트
# =============================================================================
#
# 이 스크립트는 Nginx에서 정적 파일들을 직접 서빙하도록 설정을 변경합니다.
# 프록시 대신 실제 파일 경로를 사용하여 404 오류를 해결합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 Nginx 정적 파일 직접 서빙 설정을 적용합니다..."
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
# 2. 새로운 Nginx 설정 적용 (직접 서빙)
# =============================================================================
echo "⚙️ 2단계: 새로운 Nginx 설정 적용"

# 새로운 Nginx 설정 생성 (정적 파일 직접 서빙)
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

    # 2025-01-27: _nuxt 디렉토리 직접 서빙 (두 번째 우선순위)
    # 실제 파일 경로를 사용하여 직접 서빙
    location ^~ /_nuxt/ {
        alias /home/dmanager/assetmanager/frontend/.output/public/_nuxt/;
        
        # 정적 파일 캐싱
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        
        # 파일이 없으면 프론트엔드로 폴백
        try_files $uri @fallback;
    }

    # 2025-01-27: 기타 정적 파일들 직접 서빙 (세 번째 우선순위)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|map)$ {
        root /home/dmanager/assetmanager/frontend/.output/public;
        
        # 정적 파일 캐싱
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
        
        # 파일이 없으면 프론트엔드로 폴백
        try_files $uri @fallback;
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
# 3. 파일 권한 확인 및 수정
# =============================================================================
echo "🔐 3단계: 파일 권한 확인 및 수정"

echo "정적 파일 디렉토리 권한 확인:"
ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ | head -5

echo ""
echo "Nginx 사용자 권한 확인:"
nginx_user=$(ps aux | grep nginx | grep -v grep | head -1 | awk '{print $1}')
echo "Nginx 실행 사용자: $nginx_user"

echo ""
echo "파일 권한 수정 (필요시):"
sudo chmod -R 755 /home/dmanager/assetmanager/frontend/.output/public/
sudo chown -R dmanager:dmanager /home/dmanager/assetmanager/frontend/.output/public/

echo ""

# =============================================================================
# 4. Nginx 설정 테스트 및 재시작
# =============================================================================
echo "🧪 4단계: Nginx 설정 테스트 및 재시작"

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
# 5. 정적 파일 직접 테스트
# =============================================================================
echo "🎯 5단계: 정적 파일 직접 테스트"

echo "5초 대기..."
sleep 5

echo "정적 파일 직접 접근 테스트:"
if [ -f "/home/dmanager/assetmanager/frontend/.output/public/_nuxt/DlAUqK2U.js" ]; then
    echo "✅ DlAUqK2U.js 파일 존재"
    file_size=$(ls -lh /home/dmanager/assetmanager/frontend/.output/public/_nuxt/DlAUqK2U.js | awk '{print $5}')
    echo "파일 크기: $file_size"
else
    echo "❌ DlAUqK2U.js 파일 없음"
fi

echo ""
echo "Nginx를 통한 정적 파일 테스트:"
curl -I https://invenone.it.kr/_nuxt/DlAUqK2U.js 2>/dev/null && echo "✅ Nginx를 통한 정적 파일 접근 성공" || echo "❌ Nginx를 통한 정적 파일 접근 실패"

echo ""
echo "웹사이트 테스트:"
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""

# =============================================================================
# 6. 완료
# =============================================================================
echo "🎉 Nginx 정적 파일 직접 서빙 설정 완료!"
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