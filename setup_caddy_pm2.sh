#!/bin/bash

# =============================================================================
# Caddy + PM2 배포 설정 스크립트
# =============================================================================
#
# nginx 대신 Caddy를 사용하여 더 간단하고 안정적인 배포
# PM2로 프로세스 관리
#
# 작성일: 2025-01-27
# =============================================================================

echo "🚀 Caddy + PM2 배포 설정을 시작합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📊 1단계: 현재 상태 확인"

echo "현재 디렉토리: $(pwd)"
echo ""

echo "프로젝트 구조 확인:"
ls -la
echo ""

echo "PM2 프로세스 확인:"
pm2 status

echo ""

# =============================================================================
# 2. 기존 프로세스 정리
# =============================================================================
echo "🛑 2단계: 기존 프로세스 정리"

echo "PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "포트 사용 프로세스 확인 및 중지..."
sudo lsof -ti:3000 | xargs -r sudo kill -9
sudo lsof -ti:4000 | xargs -r sudo kill -9
sudo lsof -ti:80 | xargs -r sudo kill -9
sudo lsof -ti:443 | xargs -r sudo kill -9

echo "✅ 기존 프로세스 정리 완료"
echo ""

# =============================================================================
# 3. 의존성 설치
# =============================================================================
echo "📦 3단계: 의존성 설치"

echo "백엔드 의존성 설치..."
cd backend
npm install
cd ..

echo "프론트엔드 의존성 설치..."
cd frontend
npm install
cd ..

echo "✅ 의존성 설치 완료"
echo ""

# =============================================================================
# 4. 프론트엔드 빌드
# =============================================================================
echo "🔨 4단계: 프론트엔드 빌드"

echo "프론트엔드 빌드 시작..."
cd frontend

# 환경 변수 설정
export NODE_ENV=production
export API_BASE_URL=https://invenone.it.kr/api

echo "빌드 명령어: npm run build"
npm run build

# 빌드 결과 확인
if [ -d ".output/public/_nuxt" ]; then
    echo "✅ 빌드 성공!"
    echo "빌드된 파일들:"
    ls -la .output/public/_nuxt/ | head -10
else
    echo "❌ 빌드 실패!"
    exit 1
fi

cd ..

echo ""

# =============================================================================
# 5. PM2 설정 파일 생성
# =============================================================================
echo "⚙️ 5단계: PM2 설정 파일 생성"

cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'backend',
      script: './backend/index.js',
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
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true
    },
    {
      name: 'frontend',
      script: './frontend/.output/server/index.mjs',
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
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true
    }
  ]
};
EOF

echo "✅ PM2 설정 파일 생성 완료"
echo ""

# =============================================================================
# 6. 로그 디렉토리 생성
# =============================================================================
echo "📁 6단계: 로그 디렉토리 생성"

mkdir -p logs
echo "✅ 로그 디렉토리 생성 완료"
echo ""

# =============================================================================
# 7. PM2로 애플리케이션 시작
# =============================================================================
echo "🚀 7단계: PM2로 애플리케이션 시작"

echo "PM2로 애플리케이션 시작..."
pm2 start ecosystem.config.js --env production

echo "PM2 상태 확인..."
pm2 status

echo ""

# =============================================================================
# 8. Caddy 설치 및 설정
# =============================================================================
echo "🌐 8단계: Caddy 설치 및 설정"

echo "Caddy 설치 확인..."
if ! command -v caddy &> /dev/null; then
    echo "Caddy가 설치되지 않았습니다. 설치를 시작합니다..."
    
    # Caddy 설치 (Rocky Linux/RHEL/CentOS)
    sudo dnf install -y 'dnf-command(copr)'
    sudo dnf copr enable -y @caddy/caddy
    sudo dnf install -y caddy
    
    echo "✅ Caddy 설치 완료"
else
    echo "✅ Caddy가 이미 설치되어 있습니다"
fi

echo ""

# =============================================================================
# 9. Caddy 설정 파일 생성
# =============================================================================
echo "⚙️ 9단계: Caddy 설정 파일 생성"

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
        reverse_proxy localhost:4000 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up X-Forwarded-For {remote}
            header_up X-Forwarded-Proto {scheme}
        }
    }
    
    # 나머지 요청을 프론트엔드로 프록시
    handle {
        reverse_proxy localhost:3000 {
            header_up Host {host}
            header_up X-Real-IP {remote}
            header_up X-Forwarded-For {remote}
            header_up X-Forwarded-Proto {scheme}
        }
    }
    
    # 보안 헤더
    header {
        # HSTS
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        # XSS 보호
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        # 참조 정책
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    # 로그 설정
    log {
        output file /var/log/caddy/invenone.it.kr.log
        format json
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
# 10. Caddy 설정 적용
# =============================================================================
echo "🌐 10단계: Caddy 설정 적용"

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
        exit 1
    fi
else
    echo "❌ Caddy 설정 오류"
    exit 1
fi

echo ""

# =============================================================================
# 11. 방화벽 설정
# =============================================================================
echo "🔥 11단계: 방화벽 설정"

echo "필요한 포트 열기..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=4000/tcp
sudo firewall-cmd --reload

echo "✅ 방화벽 설정 완료"
echo ""

# =============================================================================
# 12. 최종 테스트
# =============================================================================
echo "🧪 12단계: 최종 테스트"

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

# =============================================================================
# 13. 완료
# =============================================================================
echo "🎉 Caddy + PM2 배포 설정 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Network 탭 확인"
echo "   4. 정적 파일들이 정상적으로 로드되는지 확인"
echo ""
echo "🌐 접속 URL:"
echo "   웹사이트: https://invenone.it.kr"
echo "   로그인: https://invenone.it.kr/login"
echo "   API 서버: https://invenone.it.kr/api"
echo ""
echo "🔧 관리 명령어:"
echo "   PM2 상태 확인: pm2 status"
echo "   PM2 로그 확인: pm2 logs"
echo "   Caddy 상태 확인: sudo systemctl status caddy"
echo "   Caddy 로그 확인: sudo journalctl -u caddy -f"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 