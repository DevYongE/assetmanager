#!/bin/bash

# =============================================================================
# Nginx 권한 문제 해결 스크립트
# =============================================================================
#
# 이 스크립트는 Nginx가 정적 파일에 접근할 수 있도록
# 권한을 설정합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔐 Nginx 권한 문제를 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 권한 확인
# =============================================================================
echo "📋 1단계: 현재 권한 확인"

echo "현재 사용자:"
whoami

echo ""
echo "Nginx 프로세스 사용자:"
ps aux | grep nginx | grep -v grep | head -1

echo ""
echo "정적 파일 디렉토리 권한:"
ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ | head -5

echo ""

# =============================================================================
# 2. 권한 수정
# =============================================================================
echo "🔐 2단계: 권한 수정"

echo "전체 프로젝트 디렉토리 권한 수정..."
sudo chown -R dmanager:dmanager /home/dmanager/assetmanager/
sudo chmod -R 755 /home/dmanager/assetmanager/

echo ""
echo "정적 파일 디렉토리 권한 수정..."
sudo chmod -R 755 /home/dmanager/assetmanager/frontend/.output/public/
sudo chown -R dmanager:dmanager /home/dmanager/assetmanager/frontend/.output/public/

echo ""
echo "Nginx 사용자에게 읽기 권한 부여..."
# Nginx 사용자가 파일에 접근할 수 있도록 디렉토리 권한 설정
sudo chmod 755 /home/dmanager/
sudo chmod 755 /home/dmanager/assetmanager/
sudo chmod 755 /home/dmanager/assetmanager/frontend/
sudo chmod 755 /home/dmanager/assetmanager/frontend/.output/
sudo chmod 755 /home/dmanager/assetmanager/frontend/.output/public/
sudo chmod 755 /home/dmanager/assetmanager/frontend/.output/public/_nuxt/

echo ""

# =============================================================================
# 3. 권한 확인
# =============================================================================
echo "✅ 3단계: 권한 확인"

echo "수정된 권한 확인:"
ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/ | head -5

echo ""
echo "특정 파일 권한 확인:"
if [ -f "/home/dmanager/assetmanager/frontend/.output/public/_nuxt/DlAUqK2U.js" ]; then
    ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/DlAUqK2U.js
else
    echo "❌ DlAUqK2U.js 파일 없음"
fi

echo ""

# =============================================================================
# 4. Nginx 재시작
# =============================================================================
echo "⚙️ 4단계: Nginx 재시작"

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
    exit 1
fi

echo ""

# =============================================================================
# 5. 테스트
# =============================================================================
echo "🧪 5단계: 테스트"

echo "5초 대기..."
sleep 5

echo "Nginx를 통한 정적 파일 테스트:"
curl -I https://invenone.it.kr/_nuxt/DlAUqK2U.js 2>/dev/null && echo "✅ 정적 파일 접근 성공" || echo "❌ 정적 파일 접근 실패"

echo ""
echo "웹사이트 테스트:"
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""

# =============================================================================
# 6. 완료
# =============================================================================
echo "🎉 Nginx 권한 문제 해결 완료!"
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