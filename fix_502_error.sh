#!/bin/bash

# =============================================================================
# 502 오류 해결 스크립트
# =============================================================================
#
# 이 스크립트는 502 Bad Gateway 오류를 해결합니다.
# 프론트엔드 서버가 실행되지 않는 문제를 해결합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 502 오류를 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📋 1단계: 현재 상태 확인"

echo "PM2 상태 확인:"
pm2 status

echo ""
echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "프론트엔드 프로세스 확인:"
ps aux | grep -E "(node|nuxt)" | grep -v grep

echo ""

# =============================================================================
# 2. PM2 완전 정리
# =============================================================================
echo "🧹 2단계: PM2 완전 정리"

echo "기존 PM2 프로세스 중지 및 삭제..."
pm2 stop all
pm2 delete all
pm2 kill

echo "PM2 상태 확인:"
pm2 status

echo ""

# =============================================================================
# 3. 포트 사용 프로세스 확인 및 종료
# =============================================================================
echo "🔌 3단계: 포트 사용 프로세스 확인 및 종료"

echo "포트 3000 사용 프로세스 확인:"
sudo lsof -i :3000 || echo "포트 3000 사용 프로세스 없음"

echo ""
echo "포트 4000 사용 프로세스 확인:"
sudo lsof -i :3000 || echo "포트 4000 사용 프로세스 없음"

echo ""
echo "Node.js 프로세스 종료:"
sudo pkill -f "node" || echo "Node.js 프로세스 없음"

echo ""

# =============================================================================
# 4. 프론트엔드 빌드 확인
# =============================================================================
echo "🔨 4단계: 프론트엔드 빌드 확인"

echo "프론트엔드 빌드 파일 확인:"
if [ -d "frontend/.output" ]; then
    echo "✅ .output 디렉토리 존재"
    ls -la frontend/.output/
else
    echo "❌ .output 디렉토리 없음 - 재빌드 필요"
fi

echo ""
echo "프론트엔드 재빌드 중..."
cd frontend
rm -rf .output .nuxt
npm run build
cd ..

if [ $? -eq 0 ]; then
    echo "✅ 프론트엔드 빌드 성공"
else
    echo "❌ 프론트엔드 빌드 실패"
    exit 1
fi

echo ""

# =============================================================================
# 5. 백엔드 확인
# =============================================================================
echo "⚙️ 5단계: 백엔드 확인"

echo "백엔드 디렉토리 확인:"
if [ -d "backend" ]; then
    echo "✅ backend 디렉토리 존재"
    ls -la backend/
else
    echo "❌ backend 디렉토리 없음"
    exit 1
fi

echo ""
echo "백엔드 환경 변수 확인:"
if [ -f "backend/.env" ]; then
    echo "✅ .env 파일 존재"
    echo "PORT 설정 확인:"
    grep "PORT=" backend/.env || echo "❌ PORT 설정 없음"
else
    echo "❌ .env 파일 없음"
fi

echo ""

# =============================================================================
# 6. PM2 설정 파일 확인
# =============================================================================
echo "📄 6단계: PM2 설정 파일 확인"

echo "ecosystem.config.js 파일 확인:"
if [ -f "ecosystem.config.js" ]; then
    echo "✅ ecosystem.config.js 파일 존재"
    cat ecosystem.config.js
else
    echo "❌ ecosystem.config.js 파일 없음 - 생성합니다"
    
    # ecosystem.config.js 파일 생성
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
    echo "✅ ecosystem.config.js 파일 생성 완료"
fi

echo ""

# =============================================================================
# 7. PM2 재시작
# =============================================================================
echo "⚙️ 7단계: PM2 재시작"

echo "PM2로 서비스 시작..."
pm2 start ecosystem.config.js

echo "PM2 상태 확인..."
pm2 status

echo ""
echo "5초 대기..."
sleep 5

echo "PM2 로그 확인:"
pm2 logs --lines 10

echo ""

# =============================================================================
# 8. 포트 테스트
# =============================================================================
echo "🧪 8단계: 포트 테스트"

echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "백엔드 직접 테스트:"
curl -I http://localhost:4000/api/health 2>/dev/null && echo "✅ 백엔드 정상" || echo "❌ 백엔드 실패"

echo ""
echo "프론트엔드 직접 테스트:"
curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 정상" || echo "❌ 프론트엔드 실패"

echo ""

# =============================================================================
# 9. Nginx 재시작
# =============================================================================
echo "🌐 9단계: Nginx 재시작"

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
# 10. 최종 테스트
# =============================================================================
echo "🎯 10단계: 최종 테스트"

echo "10초 대기..."
sleep 10

echo "웹사이트 테스트:"
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""
echo "API 테스트:"
curl -I https://invenone.it.kr/api/health 2>/dev/null && echo "✅ API 정상" || echo "❌ API 실패"

echo ""

# =============================================================================
# 11. 완료
# =============================================================================
echo "🎉 502 오류 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Console 탭 확인"
echo "   4. 502 오류가 해결되었는지 확인"
echo ""
echo "🔧 관리 명령어:"
echo "   PM2 상태: pm2 status"
echo "   PM2 로그: pm2 logs"
echo "   Nginx 상태: sudo systemctl status nginx"
echo "   Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 