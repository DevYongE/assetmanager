#!/bin/bash

# =============================================================================
# 프론트엔드 디버깅 스크립트
# =============================================================================
#
# 이 스크립트는 프론트엔드 문제를 진단합니다.
# 빌드 파일, 포트, nginx 설정 등을 확인합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔍 프론트엔드 문제를 진단합니다..."
echo ""

# =============================================================================
# 1. 프론트엔드 빌드 파일 확인
# =============================================================================
echo "📁 프론트엔드 빌드 파일 확인:"

if [ -d "frontend/.output/public/_nuxt" ]; then
    echo "✅ 프론트엔드 빌드 파일 존재"
    echo "📄 빌드 파일 목록:"
    ls -la frontend/.output/public/_nuxt/ | head -10
else
    echo "❌ 프론트엔드 빌드 파일 없음"
    echo "💡 해결: npm run build 실행 필요"
fi

echo ""

# =============================================================================
# 2. PM2 프론트엔드 프로세스 확인
# =============================================================================
echo "📊 PM2 프론트엔드 프로세스 확인:"
pm2 status

echo ""

# =============================================================================
# 3. 포트 상태 확인
# =============================================================================
echo "🔌 포트 상태 확인:"

echo "포트 3000 (프론트엔드):"
if sudo netstat -tlnp | grep -q ":3000 "; then
    echo "✅ 포트 3000 열림"
    sudo netstat -tlnp | grep ":3000"
else
    echo "❌ 포트 3000 닫힘"
fi

echo "포트 443 (HTTPS):"
if sudo netstat -tlnp | grep -q ":443 "; then
    echo "✅ 포트 443 열림"
    sudo netstat -tlnp | grep ":443"
else
    echo "❌ 포트 443 닫힘"
fi

echo ""

# =============================================================================
# 4. nginx 설정 확인
# =============================================================================
echo "🌐 nginx 설정 확인:"

echo "nginx 상태:"
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
# 5. nginx 로그 확인
# =============================================================================
echo "📋 nginx 로그 확인:"
echo "최근 오류 로그:"
sudo tail -10 /var/log/nginx/error.log

echo ""
echo "최근 접근 로그:"
sudo tail -10 /var/log/nginx/access.log

echo ""

# =============================================================================
# 6. 프론트엔드 서버 직접 테스트
# =============================================================================
echo "🧪 프론트엔드 서버 직접 테스트:"

echo "curl로 localhost:3000 테스트:"
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ localhost:3000 응답함"
else
    echo "❌ localhost:3000 응답 안함"
fi

echo "curl로 HTTPS 테스트:"
if curl -s -k https://invenone.it.kr > /dev/null; then
    echo "✅ https://invenone.it.kr 응답함"
else
    echo "❌ https://invenone.it.kr 응답 안함"
fi

echo ""

# =============================================================================
# 7. 파일 권한 확인
# =============================================================================
echo "🔐 파일 권한 확인:"

if [ -d "frontend/.output/public/_nuxt" ]; then
    echo "프론트엔드 빌드 파일 권한:"
    ls -la frontend/.output/public/_nuxt/ | head -5
    
    echo ""
    echo "nginx 사용자 확인:"
    ps aux | grep nginx | head -3
fi

echo ""

# =============================================================================
# 8. 문제 해결 제안
# =============================================================================
echo "💡 문제 해결 제안:"

echo "1. 프론트엔드 재빌드:"
echo "   cd frontend"
echo "   npm run build"
echo ""

echo "2. PM2 프론트엔드 재시작:"
echo "   pm2 delete frontend"
echo "   pm2 start npm --name frontend -- run preview"
echo ""

echo "3. nginx 재시작:"
echo "   sudo systemctl restart nginx"
echo ""

echo "4. 파일 권한 수정:"
echo "   sudo chown -R nginx:nginx frontend/.output/public/"
echo "   sudo chmod -R 755 frontend/.output/public/"
echo ""

echo "5. 브라우저 캐시 삭제 후 재접속"
echo ""

echo "🔍 진단 완료!" 