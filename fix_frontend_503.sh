#!/bin/bash

# 프론트엔드 503 오류 해결 스크립트 (2024-12-19)
# 설명: 프론트엔드 503 Service Unavailable 오류를 해결합니다.

set -e

echo "🔧 프론트엔드 503 오류를 해결합니다..."

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

echo "=========================================="
echo "🔧 프론트엔드 503 오류 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 프로젝트 디렉토리 설정
CURRENT_DIR=$(pwd)
FRONTEND_DIR="$CURRENT_DIR/frontend"
BACKEND_DIR="$CURRENT_DIR/backend"

log_info "프로젝트 디렉토리: $CURRENT_DIR"
log_info "프론트엔드 디렉토리: $FRONTEND_DIR"

# 1. 현재 상태 확인
log_info "1. 현재 상태를 확인합니다..."

echo "=== 현재 디렉토리 ==="
pwd
ls -la

echo ""
echo "=== 프론트엔드 디렉토리 확인 ==="
if [ -d "$FRONTEND_DIR" ]; then
    log_success "프론트엔드 디렉토리가 존재합니다."
    ls -la "$FRONTEND_DIR"
else
    log_error "프론트엔드 디렉토리가 존재하지 않습니다!"
    exit 1
fi

# 2. 포트 사용 상태 확인
log_info "2. 포트 사용 상태를 확인합니다..."

echo "=== 포트 3000 사용 상태 ==="
if lsof -i :3000 2>/dev/null; then
    log_warning "포트 3000이 사용 중입니다."
    PORT_3000_PIDS=$(lsof -i :3000 -t 2>/dev/null)
    echo "  - 사용 중인 프로세스 PID: $PORT_3000_PIDS"
else
    log_success "포트 3000이 사용되지 않습니다."
fi

# 3. PM2 프로세스 확인
log_info "3. PM2 프로세스를 확인합니다..."
echo "=== PM2 프로세스 상태 ==="
pm2 status 2>/dev/null || echo "PM2가 설치되지 않았거나 실행되지 않습니다."

# 4. 프론트엔드 파일 확인
log_info "4. 프론트엔드 파일을 확인합니다..."

echo "=== package.json 확인 ==="
if [ -f "$FRONTEND_DIR/package.json" ]; then
    log_success "package.json이 존재합니다."
    cat "$FRONTEND_DIR/package.json" | head -20
else
    log_error "package.json이 존재하지 않습니다!"
    exit 1
fi

echo ""
echo "=== nuxt.config.ts 확인 ==="
if [ -f "$FRONTEND_DIR/nuxt.config.ts" ]; then
    log_success "nuxt.config.ts가 존재합니다."
    cat "$FRONTEND_DIR/nuxt.config.ts"
else
    log_error "nuxt.config.ts가 존재하지 않습니다!"
fi

echo ""
echo "=== ecosystem.config.cjs 확인 ==="
if [ -f "$FRONTEND_DIR/ecosystem.config.cjs" ]; then
    log_success "ecosystem.config.cjs가 존재합니다."
    cat "$FRONTEND_DIR/ecosystem.config.cjs"
else
    log_error "ecosystem.config.cjs가 존재하지 않습니다!"
fi

# 5. 기존 프로세스 정리
log_info "5. 기존 프로세스를 정리합니다..."

# 포트 3000 프로세스 종료
if [ ! -z "$PORT_3000_PIDS" ]; then
    log_info "포트 3000 프로세스를 종료합니다..."
    for pid in $PORT_3000_PIDS; do
        log_info "  - PID $pid 종료 중..."
        kill -KILL $pid 2>/dev/null || true
    done
    sleep 2
fi

# PM2 프로세스 정리
log_info "PM2 프로세스를 정리합니다..."
pm2 delete qr-frontend 2>/dev/null || true
pm2 delete frontend 2>/dev/null || true
pm2 kill 2>/dev/null || true

sleep 3

# 6. 프론트엔드 의존성 재설치
log_info "6. 프론트엔드 의존성을 재설치합니다..."
cd "$FRONTEND_DIR"

# node_modules 삭제
log_info "node_modules를 삭제합니다..."
rm -rf node_modules package-lock.json

# npm cache 정리
log_info "npm cache를 정리합니다..."
npm cache clean --force

# 의존성 재설치
log_info "의존성을 재설치합니다..."
npm install

# 7. 프론트엔드 빌드
log_info "7. 프론트엔드를 빌드합니다..."

# 기존 빌드 파일 삭제
log_info "기존 빌드 파일을 삭제합니다..."
rm -rf .output .nuxt

# 빌드 실행
log_info "프론트엔드를 빌드합니다..."
npm run build

# 빌드 결과 확인
log_info "빌드 결과를 확인합니다..."
if [ -d ".output/server" ]; then
    log_success "빌드가 성공했습니다!"
    ls -la .output/server/
else
    log_error "빌드가 실패했습니다!"
    exit 1
fi

# 8. PM2 설정 파일 생성
log_info "8. PM2 설정 파일을 생성합니다..."

# ecosystem.config.cjs 생성
cat > ecosystem.config.cjs << 'EOF'
module.exports = {
  apps: [{
    name: 'qr-frontend',
    script: 'node',
    args: '.output/server/index.mjs',
    cwd: process.cwd(),
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      NITRO_HOST: '0.0.0.0',
      NITRO_PORT: 3000
    }
  }]
}
EOF

log_success "ecosystem.config.cjs가 생성되었습니다."

# 9. 프론트엔드 시작
log_info "9. 프론트엔드를 시작합니다..."

# PM2로 프론트엔드 시작
log_info "PM2로 프론트엔드를 시작합니다..."
pm2 start ecosystem.config.cjs

sleep 5

# 10. 프론트엔드 상태 확인
log_info "10. 프론트엔드 상태를 확인합니다..."

echo "=== PM2 상태 ==="
pm2 status

echo ""
echo "=== 포트 3000 상태 ==="
if lsof -i :3000 2>/dev/null; then
    log_success "포트 3000이 사용 중입니다."
else
    log_error "포트 3000이 사용되지 않습니다!"
fi

echo ""
echo "=== 프론트엔드 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "프론트엔드가 정상적으로 응답합니다!"
else
    log_error "프론트엔드가 응답하지 않습니다!"
    echo "=== PM2 로그 ==="
    pm2 logs qr-frontend --lines 10
fi

# 11. Nginx 상태 확인
log_info "11. Nginx 상태를 확인합니다..."

echo "=== Nginx 상태 ==="
if systemctl is-active --quiet nginx; then
    log_success "Nginx가 실행 중입니다."
else
    log_warning "Nginx가 실행되지 않습니다."
fi

echo ""
echo "=== Nginx 설정 테스트 ==="
nginx -t 2>/dev/null && log_success "Nginx 설정이 정상입니다." || log_error "Nginx 설정에 문제가 있습니다."

# 12. 최종 연결 테스트
log_info "12. 최종 연결을 테스트합니다..."

echo "=== 로컬 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "로컬 프론트엔드 연결: 정상"
else
    log_error "로컬 프론트엔드 연결: 실패"
fi

echo ""
echo "=== 도메인 연결 테스트 ==="
if curl -s https://invenone.it.kr &> /dev/null; then
    log_success "도메인 프론트엔드 연결: 정상"
else
    log_warning "도메인 프론트엔드 연결: 실패 (Nginx 재시작 필요할 수 있음)"
fi

echo ""
echo "=========================================="
echo "🔧 프론트엔드 503 오류 해결 완료!"
echo "=========================================="
echo ""

log_success "프론트엔드 503 오류 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 다음 단계:"
echo "  1. 브라우저에서 https://invenone.it.kr 접속 테스트"
echo "  2. 여전히 503 오류가 발생하면 Nginx 재시작: sudo systemctl restart nginx"
echo "  3. PM2 로그 확인: pm2 logs qr-frontend"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 포트 확인: lsof -i :3000"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - Nginx 재시작: sudo systemctl restart nginx" 