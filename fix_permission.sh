#!/bin/bash

# =============================================================================
# 권한 문제 해결 스크립트
# =============================================================================

echo "🔐 권한 문제를 해결합니다..."
echo ""

# 현재 디렉토리 확인
echo "현재 디렉토리: $(pwd)"
echo ""

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
else
    echo "❌ frontend/.output/public 디렉토리가 없습니다"
    exit 1
fi

echo ""

# 권한 수정
echo "🔧 권한을 수정합니다..."

# 1. 소유자 변경
echo "1. 소유자를 nginx로 변경..."
sudo chown -R nginx:nginx frontend/.output/public/

# 2. 권한 설정
echo "2. 권한을 755로 설정..."
sudo chmod -R 755 frontend/.output/public/

# 3. 특별히 _nuxt 디렉토리 권한 확인
echo "3. _nuxt 디렉토리 권한 확인..."
sudo chmod -R 755 frontend/.output/public/_nuxt/

echo "✅ 권한 수정 완료"
echo ""

# 수정된 권한 확인
echo "수정된 권한 확인:"
ls -la frontend/.output/public/ | head -5
echo ""
ls -la frontend/.output/public/_nuxt/ | head -5

echo ""

# nginx 사용자로 파일 접근 테스트
echo "🧪 nginx 사용자로 파일 접근 테스트:"
CSS_FILE=$(find frontend/.output/public/_nuxt/ -name "*.css" | head -1)
if [ -n "$CSS_FILE" ]; then
    echo "CSS 파일 테스트: $CSS_FILE"
    sudo -u nginx test -r "$CSS_FILE" && echo "✅ CSS 파일 읽기 가능" || echo "❌ CSS 파일 읽기 불가"
else
    echo "❌ CSS 파일을 찾을 수 없습니다"
fi

JS_FILE=$(find frontend/.output/public/_nuxt/ -name "*.js" | head -1)
if [ -n "$JS_FILE" ]; then
    echo "JS 파일 테스트: $JS_FILE"
    sudo -u nginx test -r "$JS_FILE" && echo "✅ JS 파일 읽기 가능" || echo "❌ JS 파일 읽기 불가"
else
    echo "❌ JS 파일을 찾을 수 없습니다"
fi

echo ""

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

echo ""

# curl로 테스트
echo "🌐 curl로 정적 파일 테스트:"
if [ -n "$CSS_FILE" ]; then
    CSS_FILENAME=$(basename "$CSS_FILE")
    echo "CSS 파일 테스트: $CSS_FILENAME"
    curl -I "https://invenone.it.kr/_nuxt/$CSS_FILENAME"
else
    echo "❌ CSS 파일을 찾을 수 없습니다"
fi

echo ""

# nginx 오류 로그 확인
echo "📋 nginx 오류 로그 확인:"
sudo tail -5 /var/log/nginx/error.log

echo ""
echo "🎉 권한 문제 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo "   4. Permission denied 오류가 해결되었는지 확인"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 