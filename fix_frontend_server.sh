#!/bin/bash

# =============================================================================
# 프론트엔드 서버 실행 문제 해결 스크립트
# =============================================================================
#
# 이 스크립트는 프론트엔드 서버가 포트 3000에서 실행되지 않는
# 문제를 정확히 해결합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 프론트엔드 서버 실행 문제를 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 상황 확인
# =============================================================================
echo "📋 1단계: 현재 상황 확인"

echo "현재 디렉토리:"
pwd

echo ""
echo "프로젝트 구조:"
ls -la

echo ""
echo "PM2 상태:"
pm2 status

echo ""
echo "포트 상태:"
sudo netstat -tlnp | grep -E ':(3000|4000)'

echo ""

# =============================================================================
# 2. 모든 프로세스 정리
# =============================================================================
echo "🧹 2단계: 모든 프로세스 정리"

echo "PM2 완전 정리..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pm2 kill 2>/dev/null

echo "Node.js 프로세스 종료..."
sudo pkill -f "node" 2>/dev/null

echo "포트 3000, 4000 사용 프로세스 종료..."
sudo lsof -ti:3000 | xargs -r sudo kill -9
sudo lsof -ti:4000 | xargs -r sudo kill -9

echo "5초 대기..."
sleep 5

echo ""

# =============================================================================
# 3. 프론트엔드 빌드 파일 확인
# =============================================================================
echo "🔨 3단계: 프론트엔드 빌드 파일 확인"

echo "프론트엔드 디렉토리 확인:"
if [ -d "frontend" ]; then
    echo "✅ frontend 디렉토리 존재"
    cd frontend
    
    echo ""
    echo "package.json 확인:"
    if [ -f "package.json" ]; then
        echo "✅ package.json 존재"
        echo "스크립트 확인:"
        grep -A 5 -B 5 "scripts" package.json
    else
        echo "❌ package.json 없음"
        exit 1
    fi
    
    echo ""
    echo "기존 빌드 파일 정리..."
    rm -rf .output .nuxt node_modules package-lock.json
    
    echo "의존성 재설치..."
    npm install
    
    echo "프론트엔드 재빌드..."
    npm run build
    
    if [ $? -eq 0 ]; then
        echo "✅ 프론트엔드 빌드 성공"
        
        echo ""
        echo "빌드 파일 확인:"
        ls -la .output/
        
        echo ""
        echo "서버 파일 확인:"
        ls -la .output/server/
        
    else
        echo "❌ 프론트엔드 빌드 실패"
        exit 1
    fi
    
    cd ..
else
    echo "❌ frontend 디렉토리 없음"
    exit 1
fi

echo ""

# =============================================================================
# 4. 백엔드 확인
# =============================================================================
echo "⚙️ 4단계: 백엔드 확인"

echo "백엔드 디렉토리 확인:"
if [ -d "backend" ]; then
    echo "✅ backend 디렉토리 존재"
    
    echo ""
    echo "백엔드 파일 확인:"
    ls -la backend/
    
    echo ""
    echo "백엔드 환경 변수 확인:"
    if [ -f "backend/.env" ]; then
        echo "✅ .env 파일 존재"
        echo "PORT 설정:"
        grep "PORT=" backend/.env || echo "PORT=4000"
    else
        echo "❌ .env 파일 없음 - 생성합니다"
        cat > backend/.env << 'EOF'
# Supabase Configuration
SUPABASE_URL=https://miiagipiurokjjotbuol.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNTI1MDUsImV4cCI6MjA2NDkyODUwNX0.9S7zWwA5fw2WSJgMJb8iZ7Nnq-Cml0l7vfULCy-Qz5g
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzM1MjUwNSwiZXhwIjoyMDY0OTI4NTA1fQ.YOM-UqbSIZPi0qWtM0jlUb4oS9mBDi-CMs95FYTPAXg

# Server Configuration
PORT=4000
NODE_ENV=production

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=https://invenone.it.kr
EOF
        echo "✅ .env 파일 생성 완료"
    fi
else
    echo "❌ backend 디렉토리 없음"
    exit 1
fi

echo ""

# =============================================================================
# 5. PM2 설정 파일 생성
# =============================================================================
echo "📄 5단계: PM2 설정 파일 생성"

echo "ecosystem.config.js 파일 생성..."
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
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 4000
      },
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true
    },
    {
      name: 'qr-frontend',
      script: '.output/server/index.mjs',
      cwd: './frontend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true
    }
  ]
};
EOF

echo "✅ ecosystem.config.js 파일 생성 완료"

echo ""
echo "로그 디렉토리 생성..."
mkdir -p logs

echo ""

# =============================================================================
# 6. PM2로 서비스 시작
# =============================================================================
echo "⚙️ 6단계: PM2로 서비스 시작"

echo "PM2로 백엔드 시작..."
pm2 start ecosystem.config.js --only qr-backend

echo "3초 대기..."
sleep 3

echo "PM2로 프론트엔드 시작..."
pm2 start ecosystem.config.js --only qr-frontend

echo "5초 대기..."
sleep 5

echo "PM2 상태 확인..."
pm2 status

echo ""
echo "PM2 로그 확인:"
pm2 logs --lines 5

echo ""

# =============================================================================
# 7. 포트 테스트
# =============================================================================
echo "🧪 7단계: 포트 테스트"

echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(3000|4000)'

echo ""
echo "백엔드 직접 테스트:"
for i in {1..3}; do
    echo "시도 $i:"
    curl -I http://localhost:4000/api/health 2>/dev/null && echo "✅ 백엔드 정상" && break || echo "❌ 백엔드 실패"
    sleep 2
done

echo ""
echo "프론트엔드 직접 테스트:"
for i in {1..3}; do
    echo "시도 $i:"
    curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 정상" && break || echo "❌ 프론트엔드 실패"
    sleep 2
done

echo ""

# =============================================================================
# 8. Nginx 재시작
# =============================================================================
echo "🌐 8단계: Nginx 재시작"

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
# 9. 최종 테스트
# =============================================================================
echo "🎯 9단계: 최종 테스트"

echo "15초 대기..."
sleep 15

echo "포트 최종 확인:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "웹사이트 테스트:"
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""
echo "API 테스트:"
curl -I https://invenone.it.kr/api/health 2>/dev/null && echo "✅ API 정상" || echo "❌ API 실패"

echo ""

# =============================================================================
# 10. 완료
# =============================================================================
echo "🎉 프론트엔드 서버 실행 문제 해결 완료!"
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
echo "   백엔드 로그: pm2 logs qr-backend"
echo "   프론트엔드 로그: pm2 logs qr-frontend"
echo "   Nginx 상태: sudo systemctl status nginx"
echo "   Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 