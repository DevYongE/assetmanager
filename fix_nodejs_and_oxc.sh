#!/bin/bash

# =============================================================================
# Node.js 20 업그레이드 및 oxc-parser 문제 즉시 해결 스크립트
# =============================================================================

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

echo "🔧 Node.js 20 업그레이드 및 oxc-parser 문제 해결"
echo "================================================"
echo ""

# 1. 현재 Node.js 버전 확인
log_info "1. 현재 Node.js 버전 확인"
echo "현재 Node.js 버전:"
node --version
npm --version
echo ""

# 2. Node.js 20 설치
log_info "2. Node.js 20.x LTS 설치 중..."

# 기존 Node.js 제거
log_info "기존 Node.js 패키지 제거 중..."
sudo dnf remove -y nodejs npm 2>/dev/null || true

# DNF 캐시 정리
sudo dnf clean all

# Node.js 20.x 설치
log_info "Node.js 20.x LTS 설치 중..."
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

# 설치 확인
log_info "Node.js 20 설치 확인:"
node --version
npm --version

# 3. 프론트엔드 의존성 재설치
log_info "3. 프론트엔드 의존성 재설치 중..."

cd /home/dmanager/assetmanager/frontend

# 기존 의존성 완전 제거
log_info "기존 의존성 파일 제거 중..."
rm -rf node_modules package-lock.json

# npm 캐시 정리
npm cache clean --force

# 의존성 재설치
log_info "의존성 재설치 중..."
npm install

# 4. 빌드 테스트
log_info "4. 빌드 테스트 중..."
npm run build:prod

if [ $? -eq 0 ]; then
    log_success "✅ 빌드 성공!"
    echo ""
    echo "🎉 모든 문제가 해결되었습니다!"
    echo ""
    echo "✅ 해결된 문제들:"
    echo "   - Node.js 20.x 설치 완료"
    echo "   - oxc-parser 문제 해결"
    echo "   - Nuxt 4.0.3 호환성 확보"
    echo "   - 프론트엔드 빌드 성공"
    echo ""
    echo "🌐 다음 단계:"
    echo "   - 배포 스크립트 실행: ./deploy_rocky_linux.sh"
    echo "   - 또는 수동 배포 진행"
else
    log_error "❌ 빌드 실패!"
    echo ""
    echo "🔧 추가 해결 방법:"
    echo "   1. ESLint 설정 확인: cat eslint.config.mjs"
    echo "   2. 수동 빌드 시도: npm run build:prod"
    echo "   3. 로그 확인: npm run build:prod 2>&1 | tail -20"
    exit 1
fi 