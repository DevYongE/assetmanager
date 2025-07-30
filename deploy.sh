#!/bin/bash

# =============================================================================
# QR 자산관리 시스템 배포 스크립트
# =============================================================================
#
# 이 스크립트는 백엔드와 프론트엔드를 자동으로 배포합니다.
# PM2를 사용하여 프로세스를 관리하고 nginx를 설정합니다.
#
# 주요 기능:
# - 백엔드 빌드 및 배포
# - 프론트엔드 빌드 및 배포
# - PM2 프로세스 관리
# - nginx 설정 적용
# - SSL 인증서 확인
#
# 작성일: 2025-01-27
# =============================================================================

echo "🚀 QR 자산관리 시스템 배포를 시작합니다..."

# =============================================================================
# 1. SSL 인증서 확인
# =============================================================================
echo "🔒 SSL 인증서를 확인합니다..."

if [ ! -f "/etc/letsencrypt/live/invenone.it.kr/fullchain.pem" ]; then
    echo "❌ SSL 인증서를 찾을 수 없습니다: /etc/letsencrypt/live/invenone.it.kr/fullchain.pem"
    echo "⚠️  Let's Encrypt 인증서를 먼저 설치해주세요."
    exit 1
fi

if [ ! -f "/etc/letsencrypt/live/invenone.it.kr/privkey.pem" ]; then
    echo "❌ SSL 개인키를 찾을 수 없습니다: /etc/letsencrypt/live/invenone.it.kr/privkey.pem"
    echo "⚠️  Let's Encrypt 인증서를 먼저 설치해주세요."
    exit 1
fi

echo "✅ SSL 인증서가 정상적으로 설치되어 있습니다."

# =============================================================================
# 2. 백엔드 배포
# =============================================================================
echo "🔧 백엔드를 배포합니다..."

cd backend

# 의존성 설치
echo "📦 백엔드 의존성을 설치합니다..."
npm install

# PM2로 백엔드 시작
echo "🚀 백엔드 서버를 시작합니다..."
pm2 delete backend 2>/dev/null || true
pm2 start index.js --name backend --watch

echo "✅ 백엔드 배포가 완료되었습니다."

# =============================================================================
# 3. 프론트엔드 배포
# =============================================================================
echo "🔧 프론트엔드를 배포합니다..."

cd ../frontend

# 의존성 설치
echo "📦 프론트엔드 의존성을 설치합니다..."
npm install

# 프로덕션 빌드
echo "🏗️ 프론트엔드를 빌드합니다..."
npm run build

# PM2로 프론트엔드 시작
echo "🚀 프론트엔드 서버를 시작합니다..."
pm2 delete frontend 2>/dev/null || true
pm2 start npm --name frontend -- run preview

echo "✅ 프론트엔드 배포가 완료되었습니다."

# =============================================================================
# 4. nginx 설정 적용
# =============================================================================
echo "🌐 nginx 설정을 적용합니다..."

# nginx 설정 파일 복사
sudo cp ../nginx.conf /etc/nginx/nginx.conf

# nginx 설정 테스트
echo "🔍 nginx 설정을 테스트합니다..."
if sudo nginx -t; then
    echo "✅ nginx 설정이 유효합니다."
    
    # nginx 재시작
    echo "🔄 nginx를 재시작합니다..."
    sudo systemctl restart nginx
    
    # nginx 상태 확인
    if sudo systemctl is-active --quiet nginx; then
        echo "✅ nginx가 정상적으로 실행 중입니다."
    else
        echo "❌ nginx 시작에 실패했습니다."
        exit 1
    fi
else
    echo "❌ nginx 설정에 오류가 있습니다."
    exit 1
fi

# =============================================================================
# 5. 방화벽 설정 확인
# =============================================================================
echo "🔥 방화벽 설정을 확인합니다..."

# HTTPS 포트(443) 확인
if sudo ufw status | grep -q "443"; then
    echo "✅ HTTPS 포트(443)가 열려있습니다."
else
    echo "⚠️ HTTPS 포트(443)를 열어주세요: sudo ufw allow 443"
fi

# HTTP 포트(80) 확인
if sudo ufw status | grep -q "80"; then
    echo "✅ HTTP 포트(80)가 열려있습니다."
else
    echo "⚠️ HTTP 포트(80)를 열어주세요: sudo ufw allow 80"
fi

# =============================================================================
# 6. 배포 완료 및 확인
# =============================================================================
echo ""
echo "🎉 배포가 완료되었습니다!"
echo ""
echo "📋 배포 정보:"
echo "   🌐 웹사이트: https://invenone.it.kr"
echo "   🔗 API 서버: https://invenone.it.kr/api"
echo "   📊 헬스체크: https://invenone.it.kr/api/health"
echo ""
echo "🔧 관리 명령어:"
echo "   PM2 상태 확인: pm2 status"
echo "   PM2 로그 확인: pm2 logs"
echo "   nginx 상태 확인: sudo systemctl status nginx"
echo "   nginx 로그 확인: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "⚠️  주의사항:"
echo "   - SSL 인증서는 90일마다 갱신이 필요합니다"
echo "   - Let's Encrypt 갱신: sudo certbot renew"
echo "   - nginx 설정 변경 후: sudo systemctl reload nginx"
echo ""

# PM2 상태 출력
echo "📊 현재 PM2 프로세스 상태:"
pm2 status

echo ""
echo "✅ 모든 설정이 완료되었습니다!" 