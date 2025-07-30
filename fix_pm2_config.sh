#!/bin/bash

# PM2 설정 파일 문제 해결 스크립트 (2024-12-19)
# 설명: ES 모듈 오류를 해결하고 올바른 PM2 설정을 생성합니다.

set -e

echo "🔧 PM2 설정 파일 문제를 해결합니다..."

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
FRONTEND_DIR="$CURRENT_DIR/frontend"

echo "=========================================="
echo "🔧 PM2 설정 파일 문제 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 프론트엔드 디렉토리 확인
log_info "1. 프론트엔드 디렉토리를 확인합니다..."
if [ ! -d "$FRONTEND_DIR" ]; then
    log_error "프론트엔드 디렉토리가 없습니다!"
    exit 1
fi

cd "$FRONTEND_DIR"
log_success "프론트엔드 디렉토리로 이동했습니다."

# 2. package.json 확인
log_info "2. package.json을 확인합니다..."
if [ -f "package.json" ]; then
    log_success "package.json이 존재합니다."
    echo "=== package.json type 설정 ==="
    grep '"type"' package.json || echo "type 설정이 없습니다."
else
    log_error "package.json이 없습니다!"
    exit 1
fi

# 3. 기존 PM2 설정 파일 정리
log_info "3. 기존 PM2 설정 파일을 정리합니다..."
if [ -f "ecosystem.config.js" ]; then
    log_info "기존 ecosystem.config.js를 삭제합니다..."
    rm -f ecosystem.config.js
fi

if [ -f "ecosystem.config.cjs" ]; then
    log_info "기존 ecosystem.config.cjs를 삭제합니다..."
    rm -f ecosystem.config.cjs
fi

# 4. 올바른 PM2 설정 파일 생성
log_info "4. 올바른 PM2 설정 파일을 생성합니다..."

# CommonJS 형식으로 생성 (.cjs 확장자)
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

log_success "ecosystem.config.cjs 파일이 생성되었습니다."

# 5. 빌드 파일 확인
log_info "5. 빌드 파일을 확인합니다..."
if [ -d ".output" ]; then
    log_success ".output 디렉토리가 존재합니다."
    
    if [ -f ".output/server/index.mjs" ] || [ -f ".output/server/index.js" ]; then
        log_success "서버 파일이 존재합니다."
    else
        log_error "서버 파일이 없습니다!"
        echo "  - .output/server 내용:"
        ls -la .output/server/ 2>/dev/null || echo "server 디렉토리가 없습니다."
        exit 1
    fi
else
    log_error ".output 디렉토리가 없습니다!"
    echo "프론트엔드를 먼저 빌드해주세요: npm run build"
    exit 1
fi

# 6. 기존 PM2 프로세스 정리
log_info "6. 기존 PM2 프로세스를 정리합니다..."
pm2 delete qr-frontend 2>/dev/null || true
pm2 delete frontend 2>/dev/null || true

# 7. PM2로 프론트엔드 시작
log_info "7. PM2로 프론트엔드를 시작합니다..."
pm2 start ecosystem.config.cjs

sleep 5

# 8. PM2 상태 확인
log_info "8. PM2 상태를 확인합니다..."
pm2 status

# 9. 프론트엔드 연결 테스트
log_info "9. 프론트엔드 연결을 테스트합니다..."
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "프론트엔드가 정상적으로 응답합니다!"
else
    log_error "프론트엔드가 응답하지 않습니다!"
    echo "  - PM2 로그:"
    pm2 logs qr-frontend --lines 5
fi

# 10. 최종 상태 확인
log_info "10. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - PM2 Frontend: $(pm2 list | grep qr-frontend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 설정 파일: ecosystem.config.cjs"

echo ""
echo "=========================================="
echo "🔧 PM2 설정 파일 문제 해결 완료!"
echo "=========================================="
echo ""

log_success "PM2 설정 파일 문제 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 프론트엔드 재시작: pm2 restart qr-frontend"
echo "  - 설정 파일 확인: cat ecosystem.config.cjs" 