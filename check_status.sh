#!/bin/bash

# =============================================================================
# 서버 상태 확인 스크립트
# =============================================================================
#
# 이 스크립트는 현재 서버의 상태를 확인합니다.
# nginx, PM2, SSL 인증서, 포트 상태 등을 점검합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔍 서버 상태를 확인합니다..."
echo ""

# =============================================================================
# 1. SSL 인증서 확인
# =============================================================================
echo "🔒 SSL 인증서 상태:"
if [ -f "/etc/letsencrypt/live/invenone.it.kr/fullchain.pem" ]; then
    echo "✅ SSL 인증서 파일 존재"
    echo "   위치: /etc/letsencrypt/live/invenone.it.kr/fullchain.pem"
else
    echo "❌ SSL 인증서 파일 없음"
fi

if [ -f "/etc/letsencrypt/live/invenone.it.kr/privkey.pem" ]; then
    echo "✅ SSL 개인키 파일 존재"
    echo "   위치: /etc/letsencrypt/live/invenone.it.kr/privkey.pem"
else
    echo "❌ SSL 개인키 파일 없음"
fi
echo ""

# =============================================================================
# 2. nginx 상태 확인
# =============================================================================
echo "🌐 nginx 상태:"
if systemctl is-active --quiet nginx; then
    echo "✅ nginx 실행 중"
else
    echo "❌ nginx 중지됨"
fi

echo "nginx 설정 테스트:"
if sudo nginx -t 2>/dev/null; then
    echo "✅ nginx 설정 유효"
else
    echo "❌ nginx 설정 오류"
fi
echo ""

# =============================================================================
# 3. PM2 프로세스 확인
# =============================================================================
echo "📊 PM2 프로세스 상태:"
if command -v pm2 &> /dev/null; then
    pm2 status
else
    echo "❌ PM2가 설치되지 않음"
fi
echo ""

# =============================================================================
# 4. 포트 상태 확인
# =============================================================================
echo "🔌 포트 상태:"
echo "포트 80 (HTTP):"
if sudo netstat -tlnp | grep -q ":80 "; then
    echo "✅ 포트 80 열림"
else
    echo "❌ 포트 80 닫힘"
fi

echo "포트 443 (HTTPS):"
if sudo netstat -tlnp | grep -q ":443 "; then
    echo "✅ 포트 443 열림"
else
    echo "❌ 포트 443 닫힘"
fi

echo "포트 3000 (프론트엔드):"
if sudo netstat -tlnp | grep -q ":3000 "; then
    echo "✅ 포트 3000 열림"
else
    echo "❌ 포트 3000 닫힘"
fi

echo "포트 4000 (백엔드):"
if sudo netstat -tlnp | grep -q ":4000 "; then
    echo "✅ 포트 4000 열림"
else
    echo "❌ 포트 4000 닫힘"
fi
echo ""

# =============================================================================
# 5. 애플리케이션 파일 확인
# =============================================================================
echo "📁 애플리케이션 파일 확인:"
echo "프론트엔드 빌드 파일:"
if [ -d "/home/dmanager/assetmanager/frontend/.output/public/_nuxt" ]; then
    echo "✅ 프론트엔드 빌드 파일 존재"
    ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ | head -5
else
    echo "❌ 프론트엔드 빌드 파일 없음"
fi

echo "백엔드 파일:"
if [ -f "/home/dmanager/assetmanager/backend/index.js" ]; then
    echo "✅ 백엔드 파일 존재"
else
    echo "❌ 백엔드 파일 없음"
fi
echo ""

# =============================================================================
# 6. nginx 설정 확인
# =============================================================================
echo "⚙️ nginx 설정 확인:"
echo "현재 nginx 설정 파일:"
if [ -f "/etc/nginx/nginx.conf" ]; then
    echo "✅ nginx.conf 파일 존재"
    echo "설정 내용 (일부):"
    head -20 /etc/nginx/nginx.conf
else
    echo "❌ nginx.conf 파일 없음"
fi
echo ""

# =============================================================================
# 7. 방화벽 상태 확인
# =============================================================================
echo "🔥 방화벽 상태:"
if command -v ufw &> /dev/null; then
    echo "UFW 상태:"
    sudo ufw status
else
    echo "UFW가 설치되지 않음"
fi
echo ""

echo "🔍 상태 확인 완료!"
echo ""
echo "💡 다음 단계:"
echo "1. PM2 프로세스가 실행되지 않았다면: ./deploy.sh 실행"
echo "2. nginx 설정이 잘못되었다면: nginx.conf 파일 확인"
echo "3. 포트가 닫혀있다면: 방화벽 설정 확인" 