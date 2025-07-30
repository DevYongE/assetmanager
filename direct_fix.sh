#!/bin/bash

# =============================================================================
# 직접 문제 해결 스크립트
# =============================================================================

echo "🔧 직접 문제를 해결합니다..."
echo ""

# =============================================================================
# 1. 모든 프로세스 정리
# =============================================================================
echo "🛑 1단계: 모든 프로세스 정리"

echo "PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "Caddy 중지..."
sudo systemctl stop caddy

echo "포트 사용 프로세스 강제 종료..."
sudo lsof -ti:3000 | xargs -r sudo kill -9
sudo lsof -ti:4000 | xargs -r sudo kill -9
sudo lsof -ti:80 | xargs -r sudo kill -9
sudo lsof -ti:443 | xargs -r sudo kill -9

echo "✅ 모든 프로세스 정리 완료"
echo ""

# =============================================================================
# 2. 백엔드 직접 시작
# =============================================================================
echo "🚀 2단계: 백엔드 직접 시작"

echo "백엔드 디렉토리로 이동..."
cd backend

echo "백엔드 환경 변수 확인..."
if [ -f ".env" ]; then
    echo "✅ .env 파일 존재"
    echo "환경 변수 내용:"
    grep -E "^(SUPABASE|NODE_ENV|PORT)" .env || echo "환경 변수 없음"
else
    echo "❌ .env 파일 없음"
fi

echo ""
echo "백엔드 의존성 확인..."
npm list --depth=0 | grep -E "(express|cors|dotenv)" || echo "필수 패키지 없음"

echo ""
echo "백엔드 서버 시작..."
NODE_ENV=production PORT=4000 node index.js &
BACKEND_PID=$!

echo "백엔드 PID: $BACKEND_PID"
sleep 5

echo "백엔드 서버 테스트..."
curl -I http://localhost:4000/api/health 2>/dev/null && echo "✅ 백엔드 서버 정상" || echo "❌ 백엔드 서버 실패"

cd ..

echo ""

# =============================================================================
# 3. 프론트엔드 직접 시작
# =============================================================================
echo "🌐 3단계: 프론트엔드 직접 시작"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "프론트엔드 서버 파일 확인..."
if [ -f ".output/server/index.mjs" ]; then
    echo "✅ 서버 파일 존재: .output/server/index.mjs"
    SERVER_FILE=".output/server/index.mjs"
elif [ -f ".output/server/index.js" ]; then
    echo "✅ 서버 파일 존재: .output/server/index.js"
    SERVER_FILE=".output/server/index.js"
else
    echo "❌ 서버 파일을 찾을 수 없습니다"
    echo "사용 가능한 파일들:"
    find .output -name "*.mjs" -o -name "*.js" | head -5
    exit 1
fi

echo ""
echo "프론트엔드 서버 시작..."
NODE_ENV=production PORT=3000 node $SERVER_FILE &
FRONTEND_PID=$!

echo "프론트엔드 PID: $FRONTEND_PID"
sleep 5

echo "프론트엔드 서버 테스트..."
curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 서버 정상" || echo "❌ 프론트엔드 서버 실패"

cd ..

echo ""

# =============================================================================
# 4. Caddy 설정 단순화
# =============================================================================
echo "🌐 4단계: Caddy 설정 단순화"

echo "간단한 Caddy 설정 생성..."
cat > Caddyfile << 'EOF'
invenone.it.kr {
    # 정적 파일 서빙
    @static {
        path /_nuxt/*
    }
    handle @static {
        root * /home/dmanager/assetmanager/frontend/.output/public
        file_server
    }
    
    # API 요청
    @api {
        path /api/*
    }
    handle @api {
        reverse_proxy localhost:4000
    }
    
    # 나머지 요청
    handle {
        reverse_proxy localhost:3000
    }
}

:80 {
    redir https://invenone.it.kr{uri} permanent
}
EOF

echo "Caddy 설정 적용..."
sudo cp Caddyfile /etc/caddy/Caddyfile

echo "Caddy 시작..."
sudo systemctl start caddy

echo "Caddy 상태 확인..."
sudo systemctl status caddy --no-pager

echo ""

# =============================================================================
# 5. 최종 테스트
# =============================================================================
echo "🧪 5단계: 최종 테스트"

echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "개별 서버 테스트:"
echo "백엔드:"
curl -I http://localhost:4000/api/health 2>/dev/null || echo "❌ 백엔드 실패"

echo ""
echo "프론트엔드:"
curl -I http://localhost:3000 2>/dev/null || echo "❌ 프론트엔드 실패"

echo ""
echo "Caddy를 통한 테스트:"
curl -I https://invenone.it.kr/api/health 2>/dev/null || echo "❌ Caddy 실패"

echo ""

# =============================================================================
# 6. PM2로 전환
# =============================================================================
echo "⚙️ 6단계: PM2로 전환"

echo "기존 프로세스 종료..."
kill $BACKEND_PID 2>/dev/null
kill $FRONTEND_PID 2>/dev/null

echo "PM2 설정 생성..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'backend',
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
      name: 'frontend',
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
# 7. 완료
# =============================================================================
echo "🎉 직접 문제 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo ""
echo "🔧 관리 명령어:"
echo "   PM2 상태: pm2 status"
echo "   PM2 로그: pm2 logs"
echo "   Caddy 상태: sudo systemctl status caddy"
echo "   Caddy 로그: sudo journalctl -u caddy -f"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 