#!/bin/bash

# Nuxt 빌드 문제 해결 스크립트 (2024-12-19)
# 설명: Nuxt 3 빌드 문제를 진단하고 해결합니다.

set -e

echo "🔧 Nuxt 빌드 문제를 진단하고 해결합니다..."

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
echo "🔧 Nuxt 빌드 문제 진단 및 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 프론트엔드 디렉토리 확인
log_info "1. 프론트엔드 디렉토리를 확인합니다..."
if [ ! -d "$FRONTEND_DIR" ]; then
    log_error "프론트엔드 디렉토리가 없습니다!"
    echo "  - 현재 디렉토리: $CURRENT_DIR"
    echo "  - 찾는 디렉토리: $FRONTEND_DIR"
    exit 1
fi

cd "$FRONTEND_DIR"
log_success "프론트엔드 디렉토리로 이동했습니다."

# 2. Nuxt 설정 확인
log_info "2. Nuxt 설정을 확인합니다..."
if [ -f "nuxt.config.ts" ]; then
    log_success "nuxt.config.ts 파일이 존재합니다."
    echo "=== nuxt.config.ts 내용 ==="
    cat nuxt.config.ts
else
    log_error "nuxt.config.ts 파일이 없습니다!"
    exit 1
fi

# 3. package.json 확인
log_info "3. package.json을 확인합니다..."
if [ -f "package.json" ]; then
    log_success "package.json 파일이 존재합니다."
    echo "=== package.json 스크립트 ==="
    grep -A 10 '"scripts"' package.json
else
    log_error "package.json 파일이 없습니다!"
    exit 1
fi

# 4. 의존성 확인
log_info "4. 의존성을 확인합니다..."
if [ ! -d "node_modules" ]; then
    log_warning "node_modules가 없습니다. 의존성을 설치합니다..."
    npm install
else
    log_success "의존성이 설치되어 있습니다."
fi

# 5. 기존 빌드 파일 정리
log_info "5. 기존 빌드 파일을 정리합니다..."
if [ -d ".output" ]; then
    log_info "기존 .output 디렉토리를 삭제합니다..."
    rm -rf .output
fi

if [ -d ".nuxt" ]; then
    log_info "기존 .nuxt 디렉토리를 삭제합니다..."
    rm -rf .nuxt
fi

# 6. Nuxt 설정 수정 (필요시)
log_info "6. Nuxt 설정을 확인하고 수정합니다..."

# nuxt.config.ts 백업
cp nuxt.config.ts nuxt.config.ts.backup

# 기본 설정으로 수정
cat > nuxt.config.ts << 'EOF'
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  ssr: true,
  nitro: {
    preset: 'node-server'
  },
  runtimeConfig: {
    public: {
      apiBase: process.env.API_BASE || 'http://localhost:4000'
    }
  }
})
EOF

log_success "Nuxt 설정을 기본값으로 수정했습니다."

# 7. 빌드 실행
log_info "7. Nuxt를 빌드합니다..."
echo "  - 빌드 시작..."

if npm run build; then
    log_success "Nuxt 빌드가 완료되었습니다!"
else
    log_error "Nuxt 빌드에 실패했습니다!"
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
    
    if [ -d ".output/server" ]; then
        log_success "server 디렉토리가 생성되었습니다."
        echo "  - server 디렉토리 내용:"
        ls -la .output/server/
        
        if [ -f ".output/server/index.mjs" ]; then
            log_success "서버 파일이 생성되었습니다!"
            echo "  - 파일 크기: $(ls -lh .output/server/index.mjs | awk '{print $5}')"
        elif [ -f ".output/server/index.js" ]; then
            log_success "서버 파일이 생성되었습니다 (index.js)!"
            echo "  - 파일 크기: $(ls -lh .output/server/index.js | awk '{print $5}')"
        else
            log_warning "서버 파일이 없습니다. 다른 방법을 시도합니다."
        fi
    else
        log_error "server 디렉토리가 생성되지 않았습니다!"
    fi
else
    log_error ".output 디렉토리가 생성되지 않았습니다!"
fi

# 9. 개발 서버 테스트
log_info "9. 개발 서버를 테스트합니다..."
echo "  - 개발 서버 시작 중..."

# 기존 PM2 프로세스 정리
pm2 delete qr-frontend-dev 2>/dev/null || true

# 개발 서버로 시작
pm2 start npm --name "qr-frontend-dev" -- run dev

sleep 10

# 연결 테스트
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "개발 서버가 정상적으로 실행됩니다!"
    echo "  - 개발 서버: http://localhost:3000"
else
    log_error "개발 서버가 응답하지 않습니다!"
    echo "  - PM2 로그:"
    pm2 logs qr-frontend-dev --lines 5
fi

# 10. 최종 상태 확인
log_info "10. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - PM2 Frontend Dev: $(pm2 list | grep qr-frontend-dev | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"

echo ""
echo "=========================================="
echo "🔧 Nuxt 빌드 문제 해결 완료!"
echo "=========================================="
echo ""

log_success "Nuxt 빌드 문제 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 다음 단계:"
echo "1. 개발 서버 확인: http://localhost:3000"
echo "2. PM2 상태 확인: pm2 status"
echo "3. 로그 확인: pm2 logs qr-frontend-dev"
echo "4. 프로덕션 빌드 재시도: npm run build" 