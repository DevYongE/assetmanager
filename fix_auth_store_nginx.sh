#!/bin/bash

# =============================================================================
# useAuthStore Import 문제 해결 스크립트 (Nginx 기반)
# =============================================================================

echo "🔧 useAuthStore import 문제를 해결합니다 (Nginx 기반)..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📋 1단계: 현재 상태 확인"

echo "PM2 상태 확인..."
pm2 status

echo ""
echo "프론트엔드 빌드 파일 확인..."
ls -la frontend/.output/server/ 2>/dev/null || echo "❌ 빌드 파일 없음"

echo ""
echo "Nginx 상태 확인..."
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 2. 프론트엔드 재빌드
# =============================================================================
echo "🔨 2단계: 프론트엔드 재빌드"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "기존 빌드 파일 정리..."
rm -rf .output
rm -rf .nuxt

echo "의존성 확인..."
npm list --depth=0 | grep -E "(nuxt|pinia|@pinia)" || echo "필수 패키지 없음"

echo ""
echo "프론트엔드 빌드 시작..."
NODE_ENV=production npm run build

if [ $? -eq 0 ]; then
    echo "✅ 프론트엔드 빌드 성공"
else
    echo "❌ 프론트엔드 빌드 실패"
    exit 1
fi

cd ..

echo ""

# =============================================================================
# 3. PM2 재시작
# =============================================================================
echo "⚙️ 3단계: PM2 재시작"

echo "기존 PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "PM2 설정 확인..."
if [ -f "ecosystem.config.js" ]; then
    echo "✅ ecosystem.config.js 존재"
else
    echo "❌ ecosystem.config.js 없음 - 생성합니다"
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'qr-backend',
      script: 'index.js',
      cwd: './backend',
      instances: 1,
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: 'production',
        PORT: 4000
      }
    },
    {
      name: 'qr-frontend',
      script: '.output/server/index.mjs',
      cwd: './frontend',
      instances: 1,
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      }
    }
  ]
};
EOF
fi

echo "PM2로 시작..."
pm2 start ecosystem.config.js

echo "PM2 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 4. 서버 테스트
# =============================================================================
echo "🧪 4단계: 서버 테스트"

echo "5초 대기..."
sleep 5

echo "백엔드 테스트..."
curl -I http://localhost:4000/api/health 2>/dev/null && echo "✅ 백엔드 정상" || echo "❌ 백엔드 실패"

echo "프론트엔드 테스트..."
curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 정상" || echo "❌ 프론트엔드 실패"

echo ""

# =============================================================================
# 5. Nginx 재시작
# =============================================================================
echo "🌐 5단계: Nginx 재시작"

echo "Nginx 설정 테스트..."
sudo nginx -t

echo "Nginx 재시작..."
sudo systemctl restart nginx

echo "Nginx 상태 확인..."
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 6. 최종 테스트
# =============================================================================
echo "🎯 6단계: 최종 테스트"

echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "웹사이트 테스트..."
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""

# =============================================================================
# 7. 완료
# =============================================================================
echo "🎉 useAuthStore 문제 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Console 탭 확인"
echo ""
echo "🔧 관리 명령어:"
echo "   PM2 상태: pm2 status"
echo "   PM2 로그: pm2 logs"
echo "   Nginx 상태: sudo systemctl status nginx"
echo "   Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 