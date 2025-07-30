#!/bin/bash

# API Health 체크 스크립트 (2024-12-19)
# 설명: 백엔드 API 상태를 종합적으로 확인합니다.

set -e

echo "🔧 API Health를 확인합니다..."

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
echo "🔧 API Health 체크"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 백엔드 프로세스 확인
log_info "1. 백엔드 프로세스를 확인합니다..."

echo "=== 포트 4000 사용 상태 ==="
if lsof -i :4000 2>/dev/null; then
    log_success "포트 4000이 사용 중입니다."
    PORT_4000_PIDS=$(lsof -i :4000 -t 2>/dev/null)
    echo "  - 사용 중인 프로세스 PID: $PORT_4000_PIDS"
else
    log_error "포트 4000이 사용되지 않습니다!"
fi

echo ""
echo "=== PM2 백엔드 상태 ==="
pm2 status 2>/dev/null | grep -E "(qr-backend|backend)" || echo "백엔드 PM2 프로세스가 없습니다."

# 2. 백엔드 파일 확인
log_info "2. 백엔드 파일을 확인합니다..."

CURRENT_DIR=$(pwd)
BACKEND_DIR="$CURRENT_DIR/backend"

echo "=== 백엔드 디렉토리 확인 ==="
if [ -d "$BACKEND_DIR" ]; then
    log_success "백엔드 디렉토리가 존재합니다: $BACKEND_DIR"
    ls -la "$BACKEND_DIR"
else
    log_error "백엔드 디렉토리가 존재하지 않습니다!"
    exit 1
fi

echo ""
echo "=== package.json 확인 ==="
if [ -f "$BACKEND_DIR/package.json" ]; then
    log_success "package.json이 존재합니다."
    cat "$BACKEND_DIR/package.json" | head -20
else
    log_error "package.json이 존재하지 않습니다!"
fi

echo ""
echo "=== index.js 확인 ==="
if [ -f "$BACKEND_DIR/index.js" ]; then
    log_success "index.js가 존재합니다."
    head -20 "$BACKEND_DIR/index.js"
else
    log_error "index.js가 존재하지 않습니다!"
fi

echo ""
echo "=== .env 확인 ==="
if [ -f "$BACKEND_DIR/.env" ]; then
    log_success ".env 파일이 존재합니다."
    echo "  - SUPABASE_URL: $(grep SUPABASE_URL "$BACKEND_DIR/.env" | cut -d'=' -f2 | head -c 50)..."
    echo "  - SUPABASE_KEY: $(grep SUPABASE_KEY "$BACKEND_DIR/.env" | cut -d'=' -f2 | head -c 20)..."
else
    log_error ".env 파일이 존재하지 않습니다!"
fi

# 3. 백엔드 의존성 확인
log_info "3. 백엔드 의존성을 확인합니다..."

cd "$BACKEND_DIR"

echo "=== node_modules 확인 ==="
if [ -d "node_modules" ]; then
    log_success "node_modules가 존재합니다."
    echo "  - 크기: $(du -sh node_modules | cut -f1)"
else
    log_error "node_modules가 존재하지 않습니다!"
fi

echo ""
echo "=== 핵심 의존성 확인 ==="
if [ -f "package.json" ]; then
    echo "  - express: $(grep -o '"express": "[^"]*"' package.json || echo '없음')"
    echo "  - cors: $(grep -o '"cors": "[^"]*"' package.json || echo '없음')"
    echo "  - dotenv: $(grep -o '"dotenv": "[^"]*"' package.json || echo '없음')"
    echo "  - @supabase/supabase-js: $(grep -o '"@supabase/supabase-js": "[^"]*"' package.json || echo '없음')"
fi

# 4. API Health 체크
log_info "4. API Health를 체크합니다..."

echo "=== 로컬 API Health 체크 ==="
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:4000/api/health 2>/dev/null || echo "연결 실패")
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$HEALTH_RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    log_success "API Health 체크 성공 (HTTP $HTTP_CODE)"
    echo "  - 응답: $RESPONSE_BODY"
else
    log_error "API Health 체크 실패 (HTTP $HTTP_CODE)"
    echo "  - 응답: $RESPONSE_BODY"
fi

echo ""
echo "=== 도메인 API Health 체크 ==="
DOMAIN_HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" https://invenone.it.kr/api/health 2>/dev/null || echo "연결 실패")
DOMAIN_HTTP_CODE=$(echo "$DOMAIN_HEALTH_RESPONSE" | tail -n1)
DOMAIN_RESPONSE_BODY=$(echo "$DOMAIN_HEALTH_RESPONSE" | head -n -1)

if [ "$DOMAIN_HTTP_CODE" = "200" ]; then
    log_success "도메인 API Health 체크 성공 (HTTP $DOMAIN_HTTP_CODE)"
    echo "  - 응답: $DOMAIN_RESPONSE_BODY"
else
    log_warning "도메인 API Health 체크 실패 (HTTP $DOMAIN_HTTP_CODE)"
    echo "  - 응답: $DOMAIN_RESPONSE_BODY"
fi

# 5. API 엔드포인트 테스트
log_info "5. API 엔드포인트를 테스트합니다..."

echo "=== 기본 API 엔드포인트 테스트 ==="

# 루트 엔드포인트
echo "  - GET /api/health:"
ROOT_RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:4000/api/health 2>/dev/null || echo "연결 실패")
ROOT_CODE=$(echo "$ROOT_RESPONSE" | tail -n1)
if [ "$ROOT_CODE" = "200" ]; then
    log_success "    성공 (HTTP $ROOT_CODE)"
else
    log_error "    실패 (HTTP $ROOT_CODE)"
fi

# 사용자 엔드포인트
echo "  - GET /api/users:"
USERS_RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:4000/api/users 2>/dev/null || echo "연결 실패")
USERS_CODE=$(echo "$USERS_RESPONSE" | tail -n1)
if [ "$USERS_CODE" = "200" ] || [ "$USERS_CODE" = "401" ]; then
    log_success "    응답 (HTTP $USERS_CODE)"
else
    log_error "    실패 (HTTP $USERS_CODE)"
fi

# 디바이스 엔드포인트
echo "  - GET /api/devices:"
DEVICES_RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:4000/api/devices 2>/dev/null || echo "연결 실패")
DEVICES_CODE=$(echo "$DEVICES_RESPONSE" | tail -n1)
if [ "$DEVICES_CODE" = "200" ] || [ "$DEVICES_CODE" = "401" ]; then
    log_success "    응답 (HTTP $DEVICES_CODE)"
else
    log_error "    실패 (HTTP $DEVICES_CODE)"
fi

# 6. 백엔드 로그 확인
log_info "6. 백엔드 로그를 확인합니다..."

echo "=== PM2 백엔드 로그 (최근 10줄) ==="
pm2 logs qr-backend --lines 10 2>/dev/null || echo "백엔드 로그를 가져올 수 없습니다."

# 7. 데이터베이스 연결 확인
log_info "7. 데이터베이스 연결을 확인합니다..."

echo "=== Supabase 연결 확인 ==="
if [ -f ".env" ]; then
    SUPABASE_URL=$(grep SUPABASE_URL .env | cut -d'=' -f2)
    if [ ! -z "$SUPABASE_URL" ]; then
        log_success "Supabase URL이 설정되어 있습니다."
        echo "  - URL: $SUPABASE_URL"
        
        # Supabase 연결 테스트
        echo "  - 연결 테스트:"
        DB_TEST_RESPONSE=$(curl -s -w "\n%{http_code}" "$SUPABASE_URL/rest/v1/" 2>/dev/null || echo "연결 실패")
        DB_TEST_CODE=$(echo "$DB_TEST_RESPONSE" | tail -n1)
        if [ "$DB_TEST_CODE" = "200" ] || [ "$DB_TEST_CODE" = "401" ]; then
            log_success "    Supabase 연결 성공 (HTTP $DB_TEST_CODE)"
        else
            log_error "    Supabase 연결 실패 (HTTP $DB_TEST_CODE)"
        fi
    else
        log_error "Supabase URL이 설정되지 않았습니다!"
    fi
else
    log_error ".env 파일이 없어 Supabase 연결을 확인할 수 없습니다!"
fi

# 8. 백엔드 성능 확인
log_info "8. 백엔드 성능을 확인합니다..."

echo "=== 백엔드 응답 시간 테스트 ==="
for i in {1..5}; do
    START_TIME=$(date +%s%N)
    curl -s http://localhost:4000/api/health >/dev/null 2>&1
    END_TIME=$(date +%s%N)
    RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 ))
    echo "  - 테스트 $i: ${RESPONSE_TIME}ms"
done

# 9. 최종 상태 요약
log_info "9. 최종 상태를 요약합니다..."

echo ""
echo "=========================================="
echo "📊 API Health 체크 결과 요약"
echo "=========================================="

# 백엔드 프로세스 상태
if lsof -i :4000 >/dev/null 2>&1; then
    echo "✅ 백엔드 프로세스: 실행 중"
else
    echo "❌ 백엔드 프로세스: 중지됨"
fi

# PM2 상태
if pm2 list | grep -q "qr-backend.*online"; then
    echo "✅ PM2 백엔드: 정상"
else
    echo "❌ PM2 백엔드: 문제 있음"
fi

# 로컬 API 연결
if curl -s http://localhost:4000/api/health >/dev/null 2>&1; then
    echo "✅ 로컬 API 연결: 정상"
else
    echo "❌ 로컬 API 연결: 실패"
fi

# 도메인 API 연결
if curl -s https://invenone.it.kr/api/health >/dev/null 2>&1; then
    echo "✅ 도메인 API 연결: 정상"
else
    echo "❌ 도메인 API 연결: 실패"
fi

# 데이터베이스 연결
if [ -f ".env" ] && grep -q "SUPABASE_URL" .env; then
    echo "✅ 데이터베이스 설정: 완료"
else
    echo "❌ 데이터베이스 설정: 누락"
fi

echo ""
echo "=========================================="
echo "🔧 API Health 체크 완료!"
echo "=========================================="
echo ""

log_success "API Health 체크가 완료되었습니다! 🎉"
echo ""
echo "📝 다음 단계:"
echo "  1. 문제가 발견되면 해당 스크립트로 해결"
echo "  2. 백엔드 재시작: pm2 restart qr-backend"
echo "  3. 로그 확인: pm2 logs qr-backend"
echo ""
echo "📝 유용한 명령어:"
echo "  - 백엔드 상태: pm2 status"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - API 테스트: curl http://localhost:4000/api/health"
echo "  - 포트 확인: lsof -i :4000"
echo "  - 백엔드 재시작: pm2 restart qr-backend" 