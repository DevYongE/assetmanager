#!/bin/bash

# =============================================================================
# 현재 서버 설정 확인 스크립트
# =============================================================================

echo "🔍 현재 서버 설정을 확인합니다..."
echo ""

# =============================================================================
# 1. 실행 중인 서비스 확인
# =============================================================================
echo "📋 1단계: 실행 중인 서비스 확인"

echo "PM2 상태:"
pm2 status 2>/dev/null || echo "PM2가 설치되지 않았습니다."

echo ""
echo "시스템 서비스 상태:"
echo "Nginx:"
sudo systemctl status nginx --no-pager 2>/dev/null || echo "Nginx가 설치되지 않았습니다."

echo ""
echo "Caddy:"
sudo systemctl status caddy --no-pager 2>/dev/null || echo "Caddy가 설치되지 않았습니다."

echo ""
echo "Apache:"
sudo systemctl status httpd --no-pager 2>/dev/null || echo "Apache가 설치되지 않았습니다."

echo ""

# =============================================================================
# 2. 포트 사용 현황
# =============================================================================
echo "🌐 2단계: 포트 사용 현황"

echo "현재 열린 포트:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000|8080|8000)' || echo "관련 포트가 열려있지 않습니다."

echo ""

# =============================================================================
# 3. 프로세스 확인
# =============================================================================
echo "⚙️ 3단계: 프로세스 확인"

echo "Node.js 프로세스:"
ps aux | grep -E "(node|npm|nuxt)" | grep -v grep || echo "Node.js 프로세스가 없습니다."

echo ""
echo "웹 서버 프로세스:"
ps aux | grep -E "(nginx|apache|httpd|caddy)" | grep -v grep || echo "웹 서버 프로세스가 없습니다."

echo ""

# =============================================================================
# 4. 설정 파일 확인
# =============================================================================
echo "📁 4단계: 설정 파일 확인"

echo "Nginx 설정:"
if [ -f "/etc/nginx/nginx.conf" ]; then
    echo "✅ Nginx 설정 파일 존재"
    ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "sites-enabled 디렉토리 없음"
else
    echo "❌ Nginx 설정 파일 없음"
fi

echo ""
echo "Caddy 설정:"
if [ -f "/etc/caddy/Caddyfile" ]; then
    echo "✅ Caddy 설정 파일 존재"
else
    echo "❌ Caddy 설정 파일 없음"
fi

echo ""
echo "Apache 설정:"
if [ -f "/etc/httpd/conf/httpd.conf" ]; then
    echo "✅ Apache 설정 파일 존재"
else
    echo "❌ Apache 설정 파일 없음"
fi

echo ""

# =============================================================================
# 5. 현재 접근 방식 확인
# =============================================================================
echo "🎯 5단계: 현재 접근 방식 확인"

echo "도메인 확인:"
nslookup invenone.it.kr 2>/dev/null || echo "도메인 확인 실패"

echo ""
echo "SSL 인증서 확인:"
if [ -d "/etc/letsencrypt/live/invenone.it.kr" ]; then
    echo "✅ Let's Encrypt 인증서 존재"
else
    echo "❌ Let's Encrypt 인증서 없음"
fi

echo ""

# =============================================================================
# 6. 완료
# =============================================================================
echo "✅ 현재 서버 설정 확인 완료!"
echo ""
echo "📋 요약:"
echo "   - PM2: $(pm2 status 2>/dev/null && echo '실행 중' || echo '설치 안됨')"
echo "   - Nginx: $(sudo systemctl is-active nginx 2>/dev/null && echo '실행 중' || echo '설치 안됨')"
echo "   - Caddy: $(sudo systemctl is-active caddy 2>/dev/null && echo '실행 중' || echo '설치 안됨')"
echo "   - Apache: $(sudo systemctl is-active httpd 2>/dev/null && echo '실행 중' || echo '설치 안됨')"
echo ""
echo "🔧 다음 단계:"
echo "   현재 설정에 맞는 배포 스크립트를 생성하겠습니다." 