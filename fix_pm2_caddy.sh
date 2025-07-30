#!/bin/bash

# =============================================================================
# PM2 + Caddy 문제 해결 스크립트
# =============================================================================

echo "🔧 PM2 + Caddy 문제를 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📊 1단계: 현재 상태 확인"

echo "프론트엔드 빌드 파일 확인:"
if [ -d "frontend/.output" ]; then
    echo "✅ frontend/.output 디렉토리 존재"
    ls -la frontend/.output/
    echo ""
    if [ -d "frontend/.output/server" ]; then
        echo "✅ frontend/.output/server 디렉토리 존재"
        ls -la frontend/.output/server/
    else
        echo "❌ frontend/.output/server 디렉토리 없음"
    fi
else
    echo "❌ frontend/.output 디렉토리 없음"
fi

echo ""
echo "PM2 프로세스 확인:"
pm2 status

echo ""
echo "Caddy 상태 확인:"
sudo systemctl status caddy --no-pager

echo ""

# =============================================================================
# 2. 기존 프로세스 정리
# =============================================================================
echo "🛑 2단계: 기존 프로세스 정리"

echo "PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "Caddy 중지..."
sudo systemctl stop caddy

echo "포트 사용 프로세스 확인 및 중지..."
sudo lsof -ti:3000 | xargs -r sudo kill -9
sudo lsof -ti:4000 | xargs -r sudo kill -9
sudo lsof -ti:80 | xargs -r sudo kill -9
sudo lsof -ti:443 | xargs -r sudo kill -9

echo "✅ 기존 프로세스 정리 완료"
echo ""

# =============================================================================
# 3. 프론트엔드 서버 파일 확인
# =============================================================================
echo "🔍 3단계: 프론트엔드 서버 파일 확인"

echo "프론트엔드 서버 파일 찾기:"
find frontend/.output -name "*.mjs" -o -name "*.js" | head -10

echo ""
echo "프론트엔드 서버 디렉토리 내용:"
if [ -d "frontend/.output/server" ]; then
    ls -la frontend/.output/server/
else
    echo "❌ server 디렉토리가 없습니다"
fi

echo ""

# =============================================================================
# 4. PM2 설정 수정
# =============================================================================
echo "⚙️ 4단계: PM2 설정 수정"

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
# 5. 로그 디렉토리 생성
# =============================================================================
echo "📁 5단계: 로그 디렉토리 생성"

mkdir -p logs
echo "✅ 로그 디렉토리 생성 완료"
echo ""

# =============================================================================
# 6. PM2로 애플리케이션 시작
# =============================================================================
echo "🚀 6단계: PM2로 애플리케이션 시작"

echo "PM2로 애플리케이션 시작..."
pm2 start ecosystem.config.js --env production

echo "PM2 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 7. Caddy 설정 수정
# =============================================================================
echo "🌐 7단계: Caddy 설정 수정"

# Caddy 설정 파일 생성 (더 간단한 버전)
cat > Caddyfile << 'EOF'
invenone.it.kr {
    # SSL 자동 설정
    tls {
        on_demand
    }
    
    # 정적 파일 서빙 (Nuxt.js 빌드 파일)
    @static {
        path /_nuxt/*
    }
    handle @static {
        root * /home/dmanager/assetmanager/frontend/.output/public
        file_server
        header Cache-Control "public, max-age=31536000"
    }
    
    # API 요청을 백엔드로 프록시
    @api {
        path /api/*
    }
    handle @api {
        reverse_proxy localhost:4000
    }
    
    # 나머지 요청을 프론트엔드로 프록시
    handle {
        reverse_proxy localhost:3000
    }
}

# HTTP를 HTTPS로 리다이렉트
:80 {
    redir https://invenone.it.kr{uri} permanent
}
EOF

echo "✅ Caddy 설정 파일 생성 완료"
echo ""

# =============================================================================
# 8. Caddy 설정 적용
# =============================================================================
echo "🌐 8단계: Caddy 설정 적용"

echo "Caddy 설정 파일 복사..."
sudo cp Caddyfile /etc/caddy/Caddyfile

echo "Caddy 설정 테스트..."
sudo caddy validate --config /etc/caddy/Caddyfile

if [ $? -eq 0 ]; then
    echo "✅ Caddy 설정 유효"
    
    echo "Caddy 서비스 시작..."
    sudo systemctl enable caddy
    sudo systemctl start caddy
    
    # Caddy 상태 확인
    if sudo systemctl is-active --quiet caddy; then
        echo "✅ Caddy 시작 완료"
    else
        echo "❌ Caddy 시작 실패"
        echo "Caddy 로그 확인:"
        sudo journalctl -u caddy --no-pager -n 20
        exit 1
    fi
else
    echo "❌ Caddy 설정 오류"
    exit 1
fi

echo ""

# =============================================================================
# 9. 최종 테스트
# =============================================================================
echo "🧪 9단계: 최종 테스트"

echo "PM2 프로세스 상태:"
pm2 status

echo ""
echo "Caddy 상태:"
sudo systemctl status caddy --no-pager

echo ""
echo "포트 상태:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "curl 테스트:"
curl -I https://invenone.it.kr/api/health

echo ""
echo "🎉 PM2 + Caddy 문제 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo "   4. 정적 파일들이 정상적으로 로드되는지 확인"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 