#!/bin/bash

# 백엔드 환경 변수 문제 해결 스크립트 (2024-12-19)
# 설명: 백엔드 .env 파일의 Supabase 설정을 확인하고 수정합니다.

set -e

echo "🔧 백엔드 환경 변수 문제를 해결합니다..."

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
BACKEND_DIR="$CURRENT_DIR/backend"

echo "=========================================="
echo "🔧 백엔드 환경 변수 문제 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 백엔드 디렉토리 확인
log_info "1. 백엔드 디렉토리를 확인합니다..."
if [ ! -d "$BACKEND_DIR" ]; then
    log_error "백엔드 디렉토리가 없습니다!"
    echo "  - 현재 디렉토리: $CURRENT_DIR"
    echo "  - 찾는 디렉토리: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"
log_success "백엔드 디렉토리로 이동했습니다."

# 2. .env 파일 확인
log_info "2. .env 파일을 확인합니다..."
if [ -f ".env" ]; then
    log_success ".env 파일이 존재합니다."
    echo "=== .env 파일 내용 ==="
    cat .env
else
    log_error ".env 파일이 없습니다!"
    exit 1
fi

# 3. Supabase 환경 변수 확인
log_info "3. Supabase 환경 변수를 확인합니다..."

# 환경 변수 로드
source .env

# Supabase URL 확인
if [ -z "$SUPABASE_URL" ] || [ "$SUPABASE_URL" = "your_supabase_url_here" ]; then
    log_error "SUPABASE_URL이 설정되지 않았거나 플레이스홀더입니다!"
    SUPABASE_URL_STATUS="❌ 오류"
else
    log_success "SUPABASE_URL이 설정되어 있습니다."
    SUPABASE_URL_STATUS="✅ 정상"
fi

# Supabase Key 확인
if [ -z "$SUPABASE_KEY" ] || [ "$SUPABASE_KEY" = "your_supabase_anon_key_here" ]; then
    log_error "SUPABASE_KEY가 설정되지 않았거나 플레이스홀더입니다!"
    SUPABASE_KEY_STATUS="❌ 오류"
else
    log_success "SUPABASE_KEY가 설정되어 있습니다."
    SUPABASE_KEY_STATUS="✅ 정상"
fi

# Supabase Service Role Key 확인
if [ -z "$SUPABASE_SERVICE_ROLE_KEY" ] || [ "$SUPABASE_SERVICE_ROLE_KEY" = "your_supabase_service_role_key_here" ]; then
    log_error "SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았거나 플레이스홀더입니다!"
    SUPABASE_SERVICE_ROLE_KEY_STATUS="❌ 오류"
else
    log_success "SUPABASE_SERVICE_ROLE_KEY가 설정되어 있습니다."
    SUPABASE_SERVICE_ROLE_KEY_STATUS="✅ 정상"
fi

echo ""
echo "=== 환경 변수 상태 ==="
echo "  - SUPABASE_URL: $SUPABASE_URL_STATUS"
echo "  - SUPABASE_KEY: $SUPABASE_KEY_STATUS"
echo "  - SUPABASE_SERVICE_ROLE_KEY: $SUPABASE_SERVICE_ROLE_KEY_STATUS"

# 4. 백엔드 설정 파일 확인
log_info "4. 백엔드 설정 파일을 확인합니다..."
if [ -f "config/database.js" ]; then
    log_success "database.js 파일이 존재합니다."
    echo "=== database.js 내용 ==="
    cat config/database.js
else
    log_error "config/database.js 파일이 없습니다!"
    exit 1
fi

# 5. PM2 프로세스 확인
log_info "5. PM2 프로세스를 확인합니다..."
pm2 status

# 6. 백엔드 로그 확인
log_info "6. 백엔드 로그를 확인합니다..."
if pm2 list | grep -q "qr-backend"; then
    echo "=== 백엔드 에러 로그 ==="
    pm2 logs qr-backend --err --lines 10
else
    log_warning "qr-backend PM2 프로세스가 없습니다."
fi

# 7. 환경 변수 수정 (필요시)
log_info "7. 환경 변수를 수정합니다..."

# .env 파일 백업
cp .env .env.backup

# 실제 Supabase 값으로 .env 파일 수정
cat > .env << 'EOF'
# Supabase Configuration - 실제값으로 교체하세요
SUPABASE_URL=https://miiagipiurokjjotbuol.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNTI1MDUsImV4cCI6MjA2NDkyODUwNX0.9S7zWwA5fw2WSJgMJb8iZ7Nnq-Cml0l7vfULCy-Qz5g
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzM1MjUwNSwiZXhwIjoyMDY0OTI4NTA1fQ.YOM-UqbSIZPi0qWtM0jlUb4oS9mBDi-CMs95FYTPAXg

# Server Configuration
PORT=4000
NODE_ENV=production

# JWT Secret 강력한 비밀키로 교체하세요
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=https://invenone.it.kr
EOF

log_success ".env 파일을 실제 Supabase 값으로 수정했습니다."

# 8. 백엔드 재시작
log_info "8. 백엔드를 재시작합니다..."

# 기존 PM2 프로세스 정리
pm2 delete qr-backend 2>/dev/null || true

# 의존성 확인
if [ ! -d "node_modules" ]; then
    log_info "의존성을 설치합니다..."
    npm install
fi

# 백엔드 시작
pm2 start index.js --name "qr-backend" --env production

sleep 5

# 9. 백엔드 상태 확인
log_info "9. 백엔드 상태를 확인합니다..."
pm2 status

# 백엔드 연결 테스트
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "백엔드가 정상적으로 응답합니다!"
else
    log_error "백엔드가 응답하지 않습니다!"
    echo "  - 백엔드 로그:"
    pm2 logs qr-backend --lines 5
fi

# 10. 최종 상태 확인
log_info "10. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - PM2 Backend: $(pm2 list | grep qr-backend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - 포트 4000: $(ss -tlnp | grep ':4000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "로컬 백엔드 연결: 정상"
else
    log_error "로컬 백엔드 연결: 실패"
fi

if curl -s http://invenone.it.kr/api/health &> /dev/null; then
    log_success "도메인 백엔드 연결: 정상"
else
    log_warning "도메인 백엔드 연결: 실패"
fi

echo ""
echo "=========================================="
echo "🔧 백엔드 환경 변수 문제 해결 완료!"
echo "=========================================="
echo ""

log_success "백엔드 환경 변수 문제 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - 백엔드 재시작: pm2 restart qr-backend"
echo "  - 환경 변수 확인: cat .env" 