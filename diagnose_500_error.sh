#!/bin/bash

# =============================================================================
# 500 오류 진단 및 해결 스크립트
# =============================================================================

echo "🔍 500 오류를 진단하고 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📋 1단계: 현재 상태 확인"

echo "PM2 상태 확인..."
pm2 status

echo ""
echo "포트 상태 확인..."
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "Nginx 상태 확인..."
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 2. 로그 확인
# =============================================================================
echo "📋 2단계: 로그 확인"

echo "PM2 로그 확인..."
echo "=== 백엔드 로그 ==="
pm2 logs qr-backend --lines 10 2>/dev/null || echo "백엔드 로그 없음"

echo ""
echo "=== 프론트엔드 로그 ==="
pm2 logs qr-frontend --lines 10 2>/dev/null || echo "프론트엔드 로그 없음"

echo ""
echo "Nginx 에러 로그 확인..."
sudo tail -20 /var/log/nginx/error.log 2>/dev/null || echo "Nginx 에러 로그 없음"

echo ""

# =============================================================================
# 3. 빌드 파일 확인
# =============================================================================
echo "📋 3단계: 빌드 파일 확인"

echo "프론트엔드 빌드 파일 확인..."
if [ -d "frontend/.output" ]; then
    echo "✅ .output 디렉토리 존재"
    ls -la frontend/.output/
    
    if [ -d "frontend/.output/server" ]; then
        echo "✅ server 디렉토리 존재"
        ls -la frontend/.output/server/
    else
        echo "❌ server 디렉토리 없음"
    fi
    
    if [ -d "frontend/.output/public" ]; then
        echo "✅ public 디렉토리 존재"
        ls -la frontend/.output/public/ | head -10
    else
        echo "❌ public 디렉토리 없음"
    fi
else
    echo "❌ .output 디렉토리 없음"
fi

echo ""

# =============================================================================
# 4. 서버 연결 테스트
# =============================================================================
echo "📋 4단계: 서버 연결 테스트"

echo "로컬 서버 테스트..."
echo "백엔드 (포트 4000):"
curl -I http://localhost:4000/api/health 2>/dev/null && echo "✅ 백엔드 정상" || echo "❌ 백엔드 실패"

echo ""
echo "프론트엔드 (포트 3000):"
curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 정상" || echo "❌ 프론트엔드 실패"

echo ""
echo "도메인 테스트..."
echo "HTTP:"
curl -I http://invenone.it.kr 2>/dev/null && echo "✅ HTTP 정상" || echo "❌ HTTP 실패"

echo ""
echo "HTTPS:"
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ HTTPS 정상" || echo "❌ HTTPS 실패"

echo ""

# =============================================================================
# 5. 문제 해결
# =============================================================================
echo "🔧 5단계: 문제 해결"

echo "프론트엔드 재빌드 시작..."
cd frontend

echo "기존 빌드 파일 정리..."
rm -rf .output .nuxt

echo "의존성 재설치..."
npm install

echo "프론트엔드 빌드..."
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
# 6. PM2 재시작
# =============================================================================
echo "⚙️ 6단계: PM2 재시작"

echo "PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "PM2 설정 파일 생성..."
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

echo "PM2로 시작..."
pm2 start ecosystem.config.js

echo "PM2 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 7. Nginx 설정 확인
# =============================================================================
echo "🌐 7단계: Nginx 설정 확인"

echo "Nginx 설정 테스트..."
sudo nginx -t

echo "Nginx 재시작..."
sudo systemctl restart nginx

echo "Nginx 상태 확인..."
sudo systemctl status nginx --no-pager

echo ""

# =============================================================================
# 8. 최종 테스트
# =============================================================================
echo "🎯 8단계: 최종 테스트"

echo "5초 대기..."
sleep 5

echo "서버 연결 테스트..."
curl -I http://localhost:4000/api/health 2>/dev/null && echo "✅ 백엔드 정상" || echo "❌ 백엔드 실패"
curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 정상" || echo "❌ 프론트엔드 실패"

echo ""
echo "도메인 연결 테스트..."
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""

# =============================================================================
# 9. 완료
# =============================================================================
echo "🎉 500 오류 해결 완료!"
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