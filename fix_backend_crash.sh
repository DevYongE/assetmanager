#!/bin/bash

# 백엔드 크래시 문제 해결 스크립트 (NCP Rocky Linux용)
# 작성일: 2024-12-19
# 설명: PM2 프로세스 오류를 진단하고 수정합니다.

set -e

echo "🔧 백엔드 크래시 문제를 해결합니다..."

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

# 프로젝트 디렉토리 설정 (현재 디렉토리 기준)
CURRENT_DIR=$(pwd)
PROJECT_DIR="$CURRENT_DIR"
BACKEND_DIR="$PROJECT_DIR/backend"

echo "=========================================="
echo "🔧 백엔드 크래시 문제 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 현재 PM2 상태 확인
log_info "1. 현재 PM2 상태를 확인합니다..."
pm2 status

# 2. 백엔드 로그 상세 확인
log_info "2. 백엔드 로그를 상세히 확인합니다..."
echo "=== qr-backend 에러 로그 ==="
pm2 logs qr-backend --err --lines 20

echo ""
echo "=== qr-backend 출력 로그 ==="
pm2 logs qr-backend --out --lines 20

# 3. 백엔드 파일 확인
log_info "3. 백엔드 파일을 확인합니다..."
if [ -d "$BACKEND_DIR" ]; then
    echo "  - 백엔드 디렉토리: $BACKEND_DIR"
    echo "  - package.json: $([ -f "$BACKEND_DIR/package.json" ] && echo '존재' || echo '없음')"
    echo "  - index.js: $([ -f "$BACKEND_DIR/index.js" ] && echo '존재' || echo '없음')"
    echo "  - .env: $([ -f "$BACKEND_DIR/.env" ] && echo '존재' || echo '없음')"
    
    # package.json 내용 확인
    if [ -f "$BACKEND_DIR/package.json" ]; then
        echo ""
        echo "=== package.json 내용 ==="
        cat "$BACKEND_DIR/package.json"
    fi
    
    # index.js 내용 확인 (첫 20줄)
    if [ -f "$BACKEND_DIR/index.js" ]; then
        echo ""
        echo "=== index.js 내용 (첫 20줄) ==="
        head -20 "$BACKEND_DIR/index.js"
    fi
else
    log_error "백엔드 디렉토리가 존재하지 않습니다!"
    exit 1
fi

# 4. 환경 변수 확인
log_info "4. 환경 변수를 확인합니다..."
if [ -f "$BACKEND_DIR/.env" ]; then
    echo "=== .env 파일 내용 ==="
    cat "$BACKEND_DIR/.env"
else
    log_error ".env 파일이 없습니다!"
fi

# 5. Node.js 버전 확인
log_info "5. Node.js 버전을 확인합니다..."
node --version
npm --version

# 6. 의존성 확인
log_info "6. 백엔드 의존성을 확인합니다..."
if [ -d "$BACKEND_DIR/node_modules" ]; then
    log_success "node_modules가 존재합니다."
    echo "  - 의존성 개수: $(ls "$BACKEND_DIR/node_modules" | wc -l)"
else
    log_warning "node_modules가 없습니다. 의존성을 설치합니다..."
    cd "$BACKEND_DIR"
    npm install
fi

# 7. 백엔드 직접 실행 테스트
log_info "7. 백엔드를 직접 실행해봅니다..."
cd "$BACKEND_DIR"

# 기존 PM2 프로세스 중지
log_info "기존 PM2 프로세스를 중지합니다..."
pm2 stop qr-backend 2>/dev/null || true
pm2 delete qr-backend 2>/dev/null || true

# 백엔드 직접 실행 테스트
log_info "백엔드를 직접 실행해봅니다..."
timeout 10s node index.js || {
    log_error "백엔드 직접 실행에 실패했습니다!"
    echo "  - 오류 로그:"
    node index.js 2>&1 | head -10
}

# 8. PM2로 다시 시작
log_info "8. PM2로 백엔드를 다시 시작합니다..."
cd "$BACKEND_DIR"

# PM2 설정 파일 생성
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'qr-backend',
    script: 'index.js',
    cwd: '/var/www/qr-asset-management/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      NODE_ENV: 'production',
      PORT: 4000
    },
    error_file: '/var/log/pm2/qr-backend-error.log',
    out_file: '/var/log/pm2/qr-backend-out.log',
    log_file: '/var/log/pm2/qr-backend-combined.log',
    time: true
  }]
}
EOF

# 로그 디렉토리 생성
sudo mkdir -p /var/log/pm2
sudo chown -R $USER:$USER /var/log/pm2

# PM2로 시작
pm2 start ecosystem.config.js

# 9. 상태 확인
log_info "9. 시작 후 상태를 확인합니다..."
sleep 3
pm2 status

# 10. 연결 테스트
log_info "10. 백엔드 연결을 테스트합니다..."
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "백엔드 API가 정상적으로 응답합니다!"
else
    log_error "백엔드 API가 응답하지 않습니다!"
    echo "  - 최근 로그:"
    pm2 logs qr-backend --lines 5
fi

# 11. Nginx 재시작
log_info "11. Nginx를 재시작합니다..."
sudo systemctl restart nginx

# 12. 최종 상태 확인
log_info "12. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - Nginx: $(systemctl is-active nginx)"
echo "  - PM2 Backend: $(pm2 list | grep qr-backend | awk '{print $10}')"
echo "  - 포트 4000: $(ss -tlnp | grep ':4000 ' || echo '사용되지 않음')"
echo "  - 백엔드 응답: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/api/health)"

echo ""
echo "=========================================="
echo "🔧 해결 완료!"
echo "=========================================="
echo ""

if systemctl is-active --quiet nginx && pm2 list | grep -q "qr-backend.*online"; then
    log_success "모든 서비스가 정상적으로 실행 중입니다!"
    echo "  - Frontend: https://invenone.it.kr"
    echo "  - Backend API: https://invenone.it.kr/api"
    echo "  - Health Check: https://invenone.it.kr/health"
else
    log_warning "일부 서비스에 문제가 있을 수 있습니다."
    echo "  - 추가 진단이 필요합니다."
fi

echo ""
echo "📝 유용한 명령어:"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - 백엔드 재시작: pm2 restart qr-backend"
echo "  - Nginx 로그: sudo tail -f /var/log/nginx/invenone.it.kr-error.log"
echo "  - 전체 상태: ./check_deployment_ncp_rocky.sh"

echo ""
log_success "백엔드 크래시 문제 해결이 완료되었습니다! 🎉" 