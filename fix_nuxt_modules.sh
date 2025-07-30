#!/bin/bash

# Nuxt.js 모듈 오류 해결 스크립트 (2024-12-19)
# 설명: c12 모듈 오류 및 기타 Nuxt.js 의존성 문제를 해결합니다.

set -e

echo "🔧 Nuxt.js 모듈 오류를 해결합니다..."

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
echo "🔧 Nuxt.js 모듈 오류 해결"
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

# 2. 현재 상태 확인
log_info "2. 현재 상태를 확인합니다..."
echo "=== 현재 디렉토리 ==="
pwd
echo "=== package.json 확인 ==="
if [ -f "package.json" ]; then
    cat package.json
else
    log_error "package.json이 없습니다!"
    exit 1
fi

# 3. 기존 빌드 파일 및 캐시 정리
log_info "3. 기존 빌드 파일 및 캐시를 정리합니다..."

# 기존 빌드 파일 삭제
if [ -d ".output" ]; then
    log_info ".output 디렉토리를 삭제합니다..."
    rm -rf .output
fi

if [ -d ".nuxt" ]; then
    log_info ".nuxt 디렉토리를 삭제합니다..."
    rm -rf .nuxt
fi

# node_modules 삭제
if [ -d "node_modules" ]; then
    log_info "node_modules를 삭제합니다..."
    rm -rf node_modules
fi

# package-lock.json 삭제
if [ -f "package-lock.json" ]; then
    log_info "package-lock.json을 삭제합니다..."
    rm -f package-lock.json
fi

# npm 캐시 정리
log_info "npm 캐시를 정리합니다..."
npm cache clean --force

# 4. Node.js 버전 확인
log_info "4. Node.js 버전을 확인합니다..."
NODE_VERSION=$(node --version)
echo "  - Node.js 버전: $NODE_VERSION"

# Node.js 버전이 18 이상인지 확인
NODE_MAJOR=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
    log_error "Node.js 18 이상이 필요합니다. 현재 버전: $NODE_VERSION"
    echo "Node.js를 업그레이드해주세요."
    exit 1
fi

log_success "Node.js 버전이 적절합니다."

# 5. 의존성 재설치
log_info "5. 의존성을 재설치합니다..."
npm install

if [ $? -eq 0 ]; then
    log_success "의존성 설치가 완료되었습니다."
else
    log_error "의존성 설치에 실패했습니다!"
    exit 1
fi

# 6. c12 모듈 확인
log_info "6. c12 모듈을 확인합니다..."
if [ -d "node_modules/c12" ]; then
    log_success "c12 모듈이 존재합니다."
    echo "  - c12 모듈 내용:"
    ls -la node_modules/c12/
else
    log_error "c12 모듈이 없습니다!"
    echo "c12 모듈을 수동으로 설치합니다..."
    npm install c12
fi

# 7. Nuxt 설정 확인 및 수정
log_info "7. Nuxt 설정을 확인하고 수정합니다..."

# nuxt.config.ts 백업
if [ -f "nuxt.config.ts" ]; then
    cp nuxt.config.ts nuxt.config.ts.backup
    log_info "기존 nuxt.config.ts를 백업했습니다."
fi

# 간단한 Nuxt 설정으로 수정
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
  },
  // 모듈 설정
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt'
  ],
  // CSS 설정
  css: ['~/assets/css/main.css'],
  // PostCSS 설정
  postcss: {
    plugins: {
      tailwindcss: {},
      autoprefixer: {}
    }
  }
})
EOF

log_success "Nuxt 설정을 수정했습니다."

# 8. 프론트엔드 빌드
log_info "8. 프론트엔드를 빌드합니다..."
echo "  - 빌드 시작..."

if npm run build; then
    log_success "프론트엔드 빌드가 완료되었습니다!"
else
    log_error "프론트엔드 빌드에 실패했습니다!"
    echo "  - 빌드 오류 로그:"
    npm run build 2>&1 | tail -10
    exit 1
fi

# 9. 빌드 결과 확인
log_info "9. 빌드 결과를 확인합니다..."
if [ -d ".output" ]; then
    log_success ".output 디렉토리가 생성되었습니다."
    echo "  - .output 내용:"
    ls -la .output/
    
    if [ -d ".output/server" ]; then
        log_success "server 디렉토리가 생성되었습니다."
        echo "  - server 디렉토리 내용:"
        ls -la .output/server/
        
        if [ -f ".output/server/index.mjs" ] || [ -f ".output/server/index.js" ]; then
            log_success "서버 파일이 생성되었습니다."
        else
            log_error "서버 파일이 없습니다!"
            exit 1
        fi
    else
        log_error "server 디렉토리가 생성되지 않았습니다!"
        exit 1
    fi
else
    log_error ".output 디렉토리가 생성되지 않았습니다!"
    exit 1
fi

# 10. PM2 설정 파일 업데이트
log_info "10. PM2 설정 파일을 업데이트합니다..."

# 기존 PM2 설정 파일 정리
if [ -f "ecosystem.config.js" ]; then
    rm -f ecosystem.config.js
fi

if [ -f "ecosystem.config.cjs" ]; then
    rm -f ecosystem.config.cjs
fi

# 새로운 PM2 설정 파일 생성
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

log_success "PM2 설정 파일이 업데이트되었습니다."

# 11. 기존 PM2 프로세스 정리 및 재시작
log_info "11. PM2 프로세스를 재시작합니다..."
pm2 delete qr-frontend 2>/dev/null || true
pm2 delete frontend 2>/dev/null || true

pm2 start ecosystem.config.cjs

sleep 10

# 12. PM2 상태 확인
log_info "12. PM2 상태를 확인합니다..."
pm2 status

# 13. 프론트엔드 연결 테스트
log_info "13. 프론트엔드 연결을 테스트합니다..."
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "프론트엔드가 정상적으로 응답합니다!"
else
    log_error "프론트엔드가 응답하지 않습니다!"
    echo "  - PM2 로그:"
    pm2 logs qr-frontend --lines 10
fi

# 14. 최종 상태 확인
log_info "14. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - PM2 Frontend: $(pm2 list | grep qr-frontend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - .output 디렉토리: $([ -d ".output" ] && echo '존재' || echo '없음')"
echo "  - c12 모듈: $([ -d "node_modules/c12" ] && echo '존재' || echo '없음')"

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "로컬 프론트엔드 연결: 정상"
else
    log_error "로컬 프론트엔드 연결: 실패"
fi

echo ""
echo "=========================================="
echo "🔧 Nuxt.js 모듈 오류 해결 완료!"
echo "=========================================="
echo ""

log_success "Nuxt.js 모듈 오류 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 프론트엔드 재시작: pm2 restart qr-frontend"
echo "  - 빌드 재실행: npm run build"
echo "  - 의존성 확인: npm list c12" 