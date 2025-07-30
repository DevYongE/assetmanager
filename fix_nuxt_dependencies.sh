#!/bin/bash

# Nuxt.js 의존성 문제 해결 스크립트 (2024-12-19)
# 설명: @nuxt/kit 등 Nuxt.js 의존성 문제를 해결합니다.

set -e

echo "🔧 Nuxt.js 의존성 문제를 해결합니다..."

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
echo "🔧 Nuxt.js 의존성 문제 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 프로젝트 디렉토리 설정
CURRENT_DIR=$(pwd)
FRONTEND_DIR="$CURRENT_DIR/frontend"

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

# 2. Node.js 버전 확인
log_info "2. Node.js 버전을 확인합니다..."

echo "=== Node.js 버전 ==="
NODE_VERSION=$(node --version 2>/dev/null || echo "Node.js가 설치되지 않음")
echo "  - Node.js: $NODE_VERSION"

NPM_VERSION=$(npm --version 2>/dev/null || echo "npm이 설치되지 않음")
echo "  - npm: $NPM_VERSION"

# Node.js 버전 체크 (18 이상 필요)
if [[ "$NODE_VERSION" =~ v([0-9]+) ]]; then
    MAJOR_VERSION=${BASH_REMATCH[1]}
    if [ "$MAJOR_VERSION" -lt 18 ]; then
        log_error "Node.js 18 이상이 필요합니다. 현재 버전: $NODE_VERSION"
        exit 1
    else
        log_success "Node.js 버전이 적절합니다: $NODE_VERSION"
    fi
else
    log_error "Node.js 버전을 확인할 수 없습니다: $NODE_VERSION"
    exit 1
fi

# 3. 기존 파일 완전 정리
log_info "3. 기존 파일을 완전 정리합니다..."

cd "$FRONTEND_DIR"

# 모든 캐시 및 빌드 파일 삭제
log_info "캐시 및 빌드 파일을 삭제합니다..."
rm -rf node_modules package-lock.json .output .nuxt .cache .temp

# npm cache 완전 정리
log_info "npm cache를 완전 정리합니다..."
npm cache clean --force

# 4. package.json 확인 및 수정
log_info "4. package.json을 확인하고 수정합니다..."

if [ -f "package.json" ]; then
    log_success "package.json이 존재합니다."
    echo "=== 현재 package.json 내용 ==="
    cat package.json
else
    log_error "package.json이 존재하지 않습니다!"
    exit 1
fi

# 5. 핵심 Nuxt.js 의존성 확인
log_info "5. 핵심 Nuxt.js 의존성을 확인합니다..."

echo "=== 필요한 의존성 목록 ==="
REQUIRED_DEPS=(
    "nuxt"
    "@nuxt/kit"
    "@nuxt/cli"
    "@nuxt/schema"
    "@nuxt/telemetry"
    "vue"
    "@vue/runtime-core"
    "@vue/compiler-sfc"
    "nitropack"
    "unimport"
    "unstorage"
    "defu"
    "hookable"
    "c12"
    "exsolve"
)

for dep in "${REQUIRED_DEPS[@]}"; do
    echo "  - $dep"
done

# 6. 의존성 재설치
log_info "6. 의존성을 재설치합니다..."

# npm install 실행
log_info "npm install을 실행합니다..."
npm install

# 설치 결과 확인
log_info "설치 결과를 확인합니다..."
if [ -d "node_modules" ]; then
    log_success "node_modules가 생성되었습니다."
    echo "  - 크기: $(du -sh node_modules | cut -f1)"
else
    log_error "node_modules 생성에 실패했습니다!"
    exit 1
fi

# 7. 핵심 모듈 존재 확인
log_info "7. 핵심 모듈 존재를 확인합니다..."

echo "=== 핵심 모듈 확인 ==="
for dep in "${REQUIRED_DEPS[@]}"; do
    if [ -d "node_modules/$dep" ]; then
        log_success "  ✅ $dep"
    else
        log_error "  ❌ $dep"
    fi
done

# 8. Nuxt.js 버전 확인
log_info "8. Nuxt.js 버전을 확인합니다..."

echo "=== Nuxt.js 버전 정보 ==="
if [ -f "node_modules/nuxt/package.json" ]; then
    NUXT_VERSION=$(grep '"version"' node_modules/nuxt/package.json | cut -d'"' -f4)
    echo "  - Nuxt.js: $NUXT_VERSION"
else
    log_error "Nuxt.js가 설치되지 않았습니다!"
fi

# 9. 빌드 테스트
log_info "9. 빌드를 테스트합니다..."

# 개발 서버 테스트
log_info "개발 서버를 테스트합니다..."
timeout 30s npm run dev > /dev/null 2>&1 &
DEV_PID=$!

sleep 10

# 프로세스가 살아있는지 확인
if kill -0 $DEV_PID 2>/dev/null; then
    log_success "개발 서버가 정상적으로 시작되었습니다."
    kill $DEV_PID 2>/dev/null || true
else
    log_error "개발 서버 시작에 실패했습니다!"
fi

# 10. 프로덕션 빌드
log_info "10. 프로덕션 빌드를 실행합니다..."

# 빌드 실행
log_info "프로덕션 빌드를 실행합니다..."
npm run build

# 빌드 결과 확인
log_info "빌드 결과를 확인합니다..."
if [ -d ".output/server" ]; then
    log_success "빌드가 성공했습니다!"
    echo "  - 서버 파일: $(ls -la .output/server/)"
else
    log_error "빌드가 실패했습니다!"
    exit 1
fi

# 11. PM2 설정 파일 생성
log_info "11. PM2 설정 파일을 생성합니다..."

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

# 12. 프론트엔드 시작
log_info "12. 프론트엔드를 시작합니다..."

# 기존 PM2 프로세스 정리
pm2 delete qr-frontend 2>/dev/null || true

# PM2로 프론트엔드 시작
log_info "PM2로 프론트엔드를 시작합니다..."
pm2 start ecosystem.config.cjs

sleep 5

# 13. 프론트엔드 상태 확인
log_info "13. 프론트엔드 상태를 확인합니다..."

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

# 14. 최종 상태 확인
log_info "14. 최종 상태를 확인합니다..."

echo ""
echo "=== 최종 상태 ==="
echo "  - Node.js 버전: $NODE_VERSION"
echo "  - npm 버전: $NPM_VERSION"
echo "  - Nuxt.js 버전: $NUXT_VERSION"
echo "  - node_modules 크기: $(du -sh node_modules | cut -f1)"
echo "  - 프론트엔드 프로세스: $(lsof -i :3000 >/dev/null 2>&1 && echo '실행 중' || echo '중지됨')"

echo ""
echo "=== 핵심 모듈 최종 확인 ==="
for dep in "${REQUIRED_DEPS[@]}"; do
    if [ -d "node_modules/$dep" ]; then
        echo "  ✅ $dep"
    else
        echo "  ❌ $dep"
    fi
done

echo ""
echo "=========================================="
echo "🔧 Nuxt.js 의존성 문제 해결 완료!"
echo "=========================================="
echo ""

log_success "Nuxt.js 의존성 문제 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 다음 단계:"
echo "  1. 브라우저에서 https://invenone.it.kr 접속 테스트"
echo "  2. 여전히 문제가 있으면 로그 확인: pm2 logs qr-frontend"
echo "  3. 추가 문제가 있으면 개별 스크립트 실행"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 포트 확인: lsof -i :3000"
echo "  - Nuxt 버전 확인: npm list nuxt"
echo "  - 의존성 확인: npm list @nuxt/kit" 