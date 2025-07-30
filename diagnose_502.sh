#!/bin/bash

# =============================================================================
# 502 Bad Gateway 오류 진단 및 해결 스크립트
# =============================================================================

echo "🔍 502 Bad Gateway 오류를 진단합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📊 1단계: 현재 상태 확인"

echo "PM2 프로세스 상태:"
pm2 status

echo ""
echo "포트 사용 상태:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "Caddy 상태:"
sudo systemctl status caddy --no-pager

echo ""

# =============================================================================
# 2. 개별 서버 테스트
# =============================================================================
echo "🧪 2단계: 개별 서버 테스트"

echo "백엔드 서버 테스트 (포트 4000):"
curl -I http://localhost:4000/api/health 2>/dev/null || echo "❌ 백엔드 서버 응답 없음"

echo ""
echo "프론트엔드 서버 테스트 (포트 3000):"
curl -I http://localhost:3000 2>/dev/null || echo "❌ 프론트엔드 서버 응답 없음"

echo ""

# =============================================================================
# 3. PM2 로그 확인
# =============================================================================
echo "📋 3단계: PM2 로그 확인"

echo "백엔드 로그:"
pm2 logs backend --lines 10 --nostream

echo ""
echo "프론트엔드 로그:"
pm2 logs frontend --lines 10 --nostream

echo ""

# =============================================================================
# 4. Caddy 로그 확인
# =============================================================================
echo "📋 4단계: Caddy 로그 확인"

echo "Caddy 오류 로그:"
sudo journalctl -u caddy --no-pager -n 20

echo ""

# =============================================================================
# 5. 프로세스 재시작
# =============================================================================
echo "🔄 5단계: 프로세스 재시작"

echo "PM2 프로세스 재시작..."
pm2 restart all

echo ""
echo "재시작 후 PM2 상태:"
pm2 status

echo ""
echo "재시작 후 포트 상태:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""

# =============================================================================
# 6. 서버 재테스트
# =============================================================================
echo "🧪 6단계: 서버 재테스트"

echo "백엔드 서버 재테스트:"
sleep 3
curl -I http://localhost:4000/api/health 2>/dev/null || echo "❌ 백엔드 서버 여전히 응답 없음"

echo ""
echo "프론트엔드 서버 재테스트:"
curl -I http://localhost:3000 2>/dev/null || echo "❌ 프론트엔드 서버 여전히 응답 없음"

echo ""

# =============================================================================
# 7. 수동으로 서버 시작 테스트
# =============================================================================
echo "🔧 7단계: 수동으로 서버 시작 테스트"

echo "백엔드 수동 시작 테스트..."
cd backend
timeout 10s node index.js &
BACKEND_PID=$!
sleep 3
curl -I http://localhost:4000/api/health 2>/dev/null || echo "❌ 백엔드 수동 시작 실패"
kill $BACKEND_PID 2>/dev/null
cd ..

echo ""
echo "프론트엔드 수동 시작 테스트..."
cd frontend
if [ -f ".output/server/index.mjs" ]; then
    timeout 10s node .output/server/index.mjs &
    FRONTEND_PID=$!
    sleep 3
    curl -I http://localhost:3000 2>/dev/null || echo "❌ 프론트엔드 수동 시작 실패"
    kill $FRONTEND_PID 2>/dev/null
else
    echo "❌ 프론트엔드 서버 파일을 찾을 수 없습니다"
    echo "사용 가능한 파일들:"
    find .output -name "*.mjs" -o -name "*.js" | head -5
fi
cd ..

echo ""

# =============================================================================
# 8. PM2 설정 수정
# =============================================================================
echo "⚙️ 8단계: PM2 설정 수정"

# 프론트엔드 서버 파일 찾기
echo "프론트엔드 서버 파일 찾기:"
find frontend/.output -name "*.mjs" -o -name "*.js" | head -5

# 실제 서버 파일 찾기
SERVER_FILE=$(find frontend/.output -name "*.mjs" | head -1)
if [ -z "$SERVER_FILE" ]; then
    SERVER_FILE=$(find frontend/.output -name "*.js" | head -1)
fi

if [ -n "$SERVER_FILE" ]; then
    echo "발견된 서버 파일: $SERVER_FILE"
    # 상대 경로로 변환
    RELATIVE_PATH=$(echo $SERVER_FILE | sed 's|frontend/||')
    echo "상대 경로: $RELATIVE_PATH"
else
    echo "❌ 서버 파일을 찾을 수 없습니다"
    exit 1
fi

# PM2 설정 파일 수정
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'backend',
      script: 'index.js',
      cwd: './backend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 4000
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 4000
      },
      error_file: '../logs/backend-error.log',
      out_file: '../logs/backend-out.log',
      log_file: '../logs/backend-combined.log',
      time: true
    },
    {
      name: 'frontend',
      script: '$RELATIVE_PATH',
      cwd: './frontend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: '../logs/frontend-error.log',
      out_file: '../logs/frontend-out.log',
      log_file: '../logs/frontend-combined.log',
      time: true
    }
  ]
};
EOF

echo "✅ PM2 설정 파일 수정 완료"
echo ""

# =============================================================================
# 9. PM2 재시작
# =============================================================================
echo "🔄 9단계: PM2 재시작"

echo "PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "PM2로 애플리케이션 재시작..."
pm2 start ecosystem.config.js --env production

echo "PM2 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 10. 최종 테스트
# =============================================================================
echo "🧪 10단계: 최종 테스트"

echo "3초 대기 후 테스트..."
sleep 3

echo "백엔드 최종 테스트:"
curl -I http://localhost:4000/api/health 2>/dev/null || echo "❌ 백엔드 서버 응답 없음"

echo ""
echo "프론트엔드 최종 테스트:"
curl -I http://localhost:3000 2>/dev/null || echo "❌ 프론트엔드 서버 응답 없음"

echo ""
echo "Caddy를 통한 테스트:"
curl -I https://invenone.it.kr/api/health 2>/dev/null || echo "❌ Caddy를 통한 접근 실패"

echo ""

# =============================================================================
# 11. 완료
# =============================================================================
echo "🎉 502 Bad Gateway 오류 진단 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo "   4. 502 오류가 해결되었는지 확인"
echo ""
echo "🔧 추가 디버깅 명령어:"
echo "   PM2 로그 확인: pm2 logs"
echo "   Caddy 로그 확인: sudo journalctl -u caddy -f"
echo "   포트 확인: sudo netstat -tlnp | grep -E ':(3000|4000)'"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 