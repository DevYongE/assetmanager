#!/bin/bash

# 프론트엔드 빌드 문제 해결 스크립트 (NCP Rocky Linux용)
# 작성일: 2024-12-19
# 설명: Nuxt.js 프론트엔드를 빌드하고 PM2로 시작합니다.

set -e

echo "🔧 프론트엔드 빌드 문제를 해결합니다..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 프로젝트 디렉토리 설정
PROJECT_DIR="/var/www/qr-asset-management"
FRONTEND_DIR="$PROJECT_DIR/frontend"

echo "=========================================="
echo "🔧 프론트엔드 빌드 문제 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 프론트엔드 디렉토리 확인
log_info "1. 프론트엔드 디렉토리를 확인합니다..."
if [ -d "$FRONTEND_DIR" ]; then
    log_success "프론트엔드 디렉토리가 존재합니다."
    echo "  - 경로: $FRONTEND_DIR"
else
    log_error "프론트엔드 디렉토리가 존재하지 않습니다!"
    exit 1
fi

# 2. 프론트엔드 파일 확인
log_info "2. 프론트엔드 파일을 확인합니다..."
cd "$FRONTEND_DIR"

echo "=== 파일 확인 ==="
echo "  - package.json: $([ -f "package.json" ] && echo '존재' || echo '없음')"
echo "  - nuxt.config.ts: $([ -f "nuxt.config.ts" ] && echo '존재' || echo '없음')"
echo "  - .output: $([ -d ".output" ] && echo '존재' || echo '없음')"

if [ -f "package.json" ]; then
    echo "  - package.json 내용:"
    cat package.json | head -10
else
    log_error "package.json 파일이 없습니다!"
    exit 1
fi

# 3. Node.js 버전 확인
log_info "3. Node.js 버전을 확인합니다..."
node --version
npm --version

# 4. 의존성 확인 및 설치
log_info "4. 의존성을 확인하고 설치합니다..."
if [ -d "node_modules" ]; then
    log_success "node_modules가 존재합니다."
    echo "  - 의존성 개수: $(ls node_modules | wc -l)"
else
    log_warning "node_modules가 없습니다. 설치합니다..."
    npm install
fi

# 5. 기존 빌드 파일 확인
log_info "5. 기존 빌드 파일을 확인합니다..."
if [ -d ".output" ]; then
    log_success ".output 디렉토리가 존재합니다."
    echo "  - .output 내용:"
    ls -la .output/
    
    if [ -f ".output/server/index.mjs" ]; then
        log_success "서버 파일이 존재합니다."
    else
        log_warning "서버 파일이 없습니다. 재빌드가 필요합니다."
    fi
else
    log_warning ".output 디렉토리가 없습니다. 빌드가 필요합니다."
fi

# 6. 기존 PM2 프로세스 정리
log_info "6. 기존 PM2 프로세스를 정리합니다..."
pm2 delete qr-frontend 2>/dev/null || true
pm2 delete frontend 2>/dev/null || true

# 7. 프론트엔드 빌드
log_info "7. 프론트엔드를 빌드합니다..."
echo "  - 빌드 시작..."

# 기존 .output 삭제 (깨끗한 빌드를 위해)
if [ -d ".output" ]; then
    log_info "기존 빌드 파일을 삭제합니다..."
    rm -rf .output
fi

# 빌드 실행
if npm run build; then
    log_success "프론트엔드 빌드가 완료되었습니다!"
else
    log_error "프론트엔드 빌드에 실패했습니다!"
    echo "  - 빌드 오류 로그:"
    npm run build 2>&1 | tail -10
    exit 1
fi

# 8. 빌드 결과 확인
log_info "8. 빌드 결과를 확인합니다..."
if [ -d ".output" ]; then
    log_success ".output 디렉토리가 생성되었습니다."
    echo "  - .output 내용:"
    ls -la .output/
    
    if [ -f ".output/server/index.mjs" ]; then
        log_success "서버 파일이 생성되었습니다."
        echo "  - 파일 크기: $(ls -lh .output/server/index.mjs | awk '{print $5}')"
    else
        log_error "서버 파일이 생성되지 않았습니다!"
        exit 1
    fi
else
    log_error ".output 디렉토리가 생성되지 않았습니다!"
    exit 1
fi

# 9. PM2 설정 파일 생성
log_info "9. PM2 설정 파일을 생성합니다..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'qr-frontend',
    script: 'node',
    args: '.output/server/index.mjs',
    cwd: '/var/www/qr-asset-management/frontend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      NITRO_HOST: '0.0.0.0',
      NITRO_PORT: 3000
    },
    error_file: '/var/log/pm2/qr-frontend-error.log',
    out_file: '/var/log/pm2/qr-frontend-out.log',
    log_file: '/var/log/pm2/qr-frontend-combined.log',
    time: true,
    min_uptime: '10s',
    max_restarts: 10
  }]
}
EOF

# 10. 로그 디렉토리 생성
log_info "10. 로그 디렉토리를 생성합니다..."
sudo mkdir -p /var/log/pm2
sudo chown -R $USER:$USER /var/log/pm2

# 11. 프론트엔드 시작
log_info "11. 프론트엔드를 PM2로 시작합니다..."
pm2 start ecosystem.config.js

# 12. 프론트엔드 상태 확인
log_info "12. 프론트엔드 상태를 확인합니다..."
sleep 5
pm2 status

# 프론트엔드 연결 테스트
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "프론트엔드가 정상적으로 응답합니다!"
else
    log_error "프론트엔드가 응답하지 않습니다!"
    echo "  - 프론트엔드 로그:"
    pm2 logs qr-frontend --lines 5
fi

# 13. 포트 확인
log_info "13. 포트 사용 상태를 확인합니다..."
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' || echo '사용되지 않음')"

# 14. Nginx 재시작 (프록시 설정 적용)
log_info "14. Nginx를 재시작합니다..."
sudo systemctl restart nginx

# 15. 최종 상태 확인
log_info "15. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - PM2 Frontend: $(pm2 list | grep qr-frontend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - Nginx: $(systemctl is-active nginx)"

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "로컬 프론트엔드 연결: 정상"
else
    log_error "로컬 프론트엔드 연결: 실패"
fi

if curl -s http://invenone.it.kr &> /dev/null; then
    log_success "도메인 프론트엔드 연결: 정상"
else
    log_warning "도메인 프론트엔드 연결: 실패"
fi

echo ""
echo "=========================================="
echo "🔧 프론트엔드 빌드 문제 해결 완료!"
echo "=========================================="
echo ""

if pm2 list | grep -q "qr-frontend.*online"; then
    log_success "프론트엔드가 정상적으로 실행 중입니다!"
    echo "  - Frontend: http://invenone.it.kr"
    echo "  - Backend API: http://invenone.it.kr/api"
    echo "  - Health Check: http://invenone.it.kr/health"
else
    log_warning "프론트엔드 실행에 문제가 있을 수 있습니다."
    echo "  - 로그 확인: pm2 logs qr-frontend"
fi

echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 프론트엔드 재시작: pm2 restart qr-frontend"
echo "  - 빌드 재실행: npm run build"
echo "  - Nginx 로그: sudo tail -f /var/log/nginx/invenone.it.kr-error.log"

echo ""
log_success "프론트엔드 빌드 문제 해결이 완료되었습니다! 🎉" 