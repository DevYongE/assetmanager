#!/bin/bash

# =============================================================================
# TDD 스타일 배포 테스트 스크립트 (2025-08-08)
# =============================================================================
# 이 스크립트는 배포 프로세스의 모든 단계를 검증합니다.
# TDD(Test-Driven Development) 원칙에 따라 테스트를 먼저 작성하고 검증합니다.

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 로그 함수들
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

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

log_validation() {
    echo -e "${CYAN}[VALIDATION]${NC} $1"
}

# 테스트 결과 추적
TEST_RESULTS=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 테스트 결과 기록 함수
record_test() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_success "✅ $test_name: $message"
        TEST_RESULTS+=("PASS: $test_name")
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "❌ $test_name: $message"
        TEST_RESULTS+=("FAIL: $test_name")
    fi
}

# =============================================================================
# 1. 환경 검증 테스트
# =============================================================================
log_test "=== 환경 검증 테스트 시작 ==="

# 1.1 시스템 요구사항 검증
log_validation "1.1 시스템 요구사항 검증"

# Node.js 버전 확인
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        record_test "Node.js 버전" "PASS" "Node.js $NODE_VERSION.x (권장: 18.x 이상)"
    else
        record_test "Node.js 버전" "FAIL" "Node.js $NODE_VERSION.x (권장: 18.x 이상)"
    fi
else
    record_test "Node.js 설치" "FAIL" "Node.js가 설치되지 않음"
fi

# npm 버전 확인
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    record_test "npm 설치" "PASS" "npm $NPM_VERSION"
else
    record_test "npm 설치" "FAIL" "npm이 설치되지 않음"
fi

# Git 확인
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    record_test "Git 설치" "PASS" "Git $GIT_VERSION"
else
    record_test "Git 설치" "FAIL" "Git이 설치되지 않음"
fi

# 1.2 디렉토리 구조 검증
log_validation "1.2 디렉토리 구조 검증"

PROJECT_DIR="/home/dmanager/assetmanager"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

if [ -d "$PROJECT_DIR" ]; then
    record_test "프로젝트 디렉토리" "PASS" "$PROJECT_DIR 존재"
else
    record_test "프로젝트 디렉토리" "FAIL" "$PROJECT_DIR 없음"
fi

if [ -d "$BACKEND_DIR" ]; then
    record_test "백엔드 디렉토리" "PASS" "$BACKEND_DIR 존재"
else
    record_test "백엔드 디렉토리" "FAIL" "$BACKEND_DIR 없음"
fi

if [ -d "$FRONTEND_DIR" ]; then
    record_test "프론트엔드 디렉토리" "PASS" "$FRONTEND_DIR 존재"
else
    record_test "프론트엔드 디렉토리" "FAIL" "$FRONTEND_DIR 없음"
fi

# 1.3 필수 파일 검증
log_validation "1.3 필수 파일 검증"

if [ -f "$BACKEND_DIR/package.json" ]; then
    record_test "백엔드 package.json" "PASS" "존재"
else
    record_test "백엔드 package.json" "FAIL" "없음"
fi

if [ -f "$FRONTEND_DIR/package.json" ]; then
    record_test "프론트엔드 package.json" "PASS" "존재"
else
    record_test "프론트엔드 package.json" "FAIL" "없음"
fi

if [ -f "$BACKEND_DIR/.env" ]; then
    record_test "백엔드 .env" "PASS" "존재"
else
    record_test "백엔드 .env" "FAIL" "없음"
fi

# =============================================================================
# 2. 의존성 검증 테스트
# =============================================================================
log_test "=== 의존성 검증 테스트 시작 ==="

# 2.1 백엔드 의존성 검증
log_validation "2.1 백엔드 의존성 검증"

cd "$BACKEND_DIR" 2>/dev/null || {
    record_test "백엔드 디렉토리 접근" "FAIL" "접근 불가"
    exit 1
}

if [ -d "node_modules" ]; then
    record_test "백엔드 node_modules" "PASS" "존재"
else
    record_test "백엔드 node_modules" "FAIL" "없음 (npm install 필요)"
fi

# 핵심 백엔드 패키지 확인
BACKEND_DEPS=("express" "@supabase/supabase-js" "bcryptjs" "jsonwebtoken" "cors" "dotenv")
for dep in "${BACKEND_DEPS[@]}"; do
    if [ -d "node_modules/$dep" ]; then
        record_test "백엔드 $dep" "PASS" "설치됨"
    else
        record_test "백엔드 $dep" "FAIL" "설치되지 않음"
    fi
done

# 2.2 프론트엔드 의존성 검증
log_validation "2.2 프론트엔드 의존성 검증"

cd "$FRONTEND_DIR" 2>/dev/null || {
    record_test "프론트엔드 디렉토리 접근" "FAIL" "접근 불가"
    exit 1
}

if [ -d "node_modules" ]; then
    record_test "프론트엔드 node_modules" "PASS" "존재"
else
    record_test "프론트엔드 node_modules" "FAIL" "없음 (npm install 필요)"
fi

# oxc-parser 문제 확인
if [ -d "node_modules/oxc-parser" ]; then
    # oxc-parser 네이티브 바인딩 테스트
    if node -e "require('oxc-parser'); console.log('oxc-parser 로드 성공')" 2>/dev/null; then
        record_test "oxc-parser 네이티브 바인딩" "PASS" "정상 작동"
    else
        record_test "oxc-parser 네이티브 바인딩" "FAIL" "로드 실패 (우회 설정 필요)"
    fi
else
    record_test "oxc-parser 설치" "FAIL" "설치되지 않음"
fi

# 핵심 프론트엔드 패키지 확인
FRONTEND_DEPS=("nuxt" "vue" "@pinia/nuxt" "@nuxtjs/tailwindcss")
for dep in "${FRONTEND_DEPS[@]}"; do
    if [ -d "node_modules/$dep" ]; then
        record_test "프론트엔드 $dep" "PASS" "설치됨"
    else
        record_test "프론트엔드 $dep" "FAIL" "설치되지 않음"
    fi
done

# =============================================================================
# 3. 환경변수 검증 테스트
# =============================================================================
log_test "=== 환경변수 검증 테스트 시작 ==="

# 3.1 백엔드 환경변수 검증
log_validation "3.1 백엔드 환경변수 검증"

cd "$BACKEND_DIR"

# .env 파일 로드 테스트
if node -e "
require('dotenv').config();
const required = ['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY', 'JWT_SECRET'];
const missing = required.filter(key => !process.env[key]);
if (missing.length > 0) {
    console.error('Missing:', missing.join(', '));
    process.exit(1);
} else {
    console.log('All required env vars present');
}
" 2>/dev/null; then
    record_test "백엔드 환경변수" "PASS" "모든 필수 변수 존재"
else
    record_test "백엔드 환경변수" "FAIL" "필수 변수 누락"
fi

# Supabase 연결 테스트
if node -e "
require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
console.log('Supabase client created successfully');
" 2>/dev/null; then
    record_test "Supabase 클라이언트" "PASS" "생성 성공"
else
    record_test "Supabase 클라이언트" "FAIL" "생성 실패"
fi

# =============================================================================
# 4. 빌드 검증 테스트
# =============================================================================
log_test "=== 빌드 검증 테스트 시작 ==="

# 4.1 백엔드 빌드 테스트
log_validation "4.1 백엔드 빌드 테스트"

cd "$BACKEND_DIR"

if npm run build 2>/dev/null; then
    record_test "백엔드 빌드" "PASS" "성공"
else
    record_test "백엔드 빌드" "FAIL" "실패"
fi

# 4.2 프론트엔드 빌드 테스트
log_validation "4.2 프론트엔드 빌드 테스트"

cd "$FRONTEND_DIR"

# oxc-parser 문제 우회 후 빌드 테스트
if npm run build:prod 2>/dev/null; then
    record_test "프론트엔드 빌드" "PASS" "성공"
else
    record_test "프론트엔드 빌드" "FAIL" "실패 (oxc-parser 문제 가능)"
fi

# =============================================================================
# 5. 서비스 검증 테스트
# =============================================================================
log_test "=== 서비스 검증 테스트 시작 ==="

# 5.1 PM2 상태 확인
log_validation "5.1 PM2 상태 확인"

if command -v pm2 &> /dev/null; then
    PM2_VERSION=$(pm2 --version)
    record_test "PM2 설치" "PASS" "PM2 $PM2_VERSION"
    
    # PM2 프로세스 확인
    if pm2 list | grep -q "assetmanager"; then
        record_test "PM2 프로세스" "PASS" "assetmanager 프로세스 실행 중"
    else
        record_test "PM2 프로세스" "FAIL" "assetmanager 프로세스 없음"
    fi
else
    record_test "PM2 설치" "FAIL" "PM2 설치되지 않음"
fi

# 5.2 Nginx 상태 확인
log_validation "5.2 Nginx 상태 확인"

if command -v nginx &> /dev/null; then
    NGINX_VERSION=$(nginx -v 2>&1 | cut -d'/' -f2)
    record_test "Nginx 설치" "PASS" "Nginx $NGINX_VERSION"
    
    # Nginx 설정 테스트
    if nginx -t 2>/dev/null; then
        record_test "Nginx 설정" "PASS" "설정 파일 유효"
    else
        record_test "Nginx 설정" "FAIL" "설정 파일 오류"
    fi
    
    # Nginx 서비스 상태
    if systemctl is-active --quiet nginx; then
        record_test "Nginx 서비스" "PASS" "실행 중"
    else
        record_test "Nginx 서비스" "FAIL" "중지됨"
    fi
else
    record_test "Nginx 설치" "FAIL" "Nginx 설치되지 않음"
fi

# 5.3 포트 사용 확인
log_validation "5.3 포트 사용 확인"

# 포트 80 (HTTP)
if netstat -tlnp 2>/dev/null | grep -q ":80 "; then
    record_test "포트 80 (HTTP)" "PASS" "사용 중"
else
    record_test "포트 80 (HTTP)" "FAIL" "사용되지 않음"
fi

# 포트 443 (HTTPS)
if netstat -tlnp 2>/dev/null | grep -q ":443 "; then
    record_test "포트 443 (HTTPS)" "PASS" "사용 중"
else
    record_test "포트 443 (HTTPS)" "FAIL" "사용되지 않음"
fi

# 포트 4000 (백엔드 API)
if netstat -tlnp 2>/dev/null | grep -q ":4000 "; then
    record_test "포트 4000 (API)" "PASS" "사용 중"
else
    record_test "포트 4000 (API)" "FAIL" "사용되지 않음"
fi

# =============================================================================
# 6. API 검증 테스트
# =============================================================================
log_test "=== API 검증 테스트 시작 ==="

# 6.1 백엔드 API 헬스체크
log_validation "6.1 백엔드 API 헬스체크"

if curl -s http://localhost:4000/api/health 2>/dev/null | grep -q "ok"; then
    record_test "백엔드 API 헬스체크" "PASS" "응답 성공"
else
    record_test "백엔드 API 헬스체크" "FAIL" "응답 실패"
fi

# 6.2 프론트엔드 접근 테스트
log_validation "6.2 프론트엔드 접근 테스트"

if curl -s -I http://localhost 2>/dev/null | grep -q "200 OK"; then
    record_test "프론트엔드 접근" "PASS" "HTTP 200 응답"
else
    record_test "프론트엔드 접근" "FAIL" "접근 실패"
fi

# 6.3 HTTPS 리다이렉트 테스트
log_validation "6.3 HTTPS 리다이렉트 테스트"

if curl -s -I http://invenone.it.kr 2>/dev/null | grep -q "301\|302"; then
    record_test "HTTPS 리다이렉트" "PASS" "리다이렉트 작동"
else
    record_test "HTTPS 리다이렉트" "FAIL" "리다이렉트 실패"
fi

# =============================================================================
# 7. 보안 검증 테스트
# =============================================================================
log_test "=== 보안 검증 테스트 시작 ==="

# 7.1 SSL 인증서 확인
log_validation "7.1 SSL 인증서 확인"

if openssl s_client -connect invenone.it.kr:443 -servername invenone.it.kr < /dev/null 2>/dev/null | grep -q "subject="; then
    record_test "SSL 인증서" "PASS" "유효한 인증서"
else
    record_test "SSL 인증서" "FAIL" "인증서 문제"
fi

# 7.2 방화벽 설정 확인
log_validation "7.2 방화벽 설정 확인"

if firewall-cmd --list-services 2>/dev/null | grep -q "http"; then
    record_test "HTTP 방화벽" "PASS" "HTTP 허용"
else
    record_test "HTTP 방화벽" "FAIL" "HTTP 차단"
fi

if firewall-cmd --list-services 2>/dev/null | grep -q "https"; then
    record_test "HTTPS 방화벽" "PASS" "HTTPS 허용"
else
    record_test "HTTPS 방화벽" "FAIL" "HTTPS 차단"
fi

# =============================================================================
# 8. 성능 검증 테스트
# =============================================================================
log_test "=== 성능 검증 테스트 시작 ==="

# 8.1 응답 시간 테스트
log_validation "8.1 응답 시간 테스트"

START_TIME=$(date +%s.%N)
if curl -s http://localhost:4000/api/health > /dev/null 2>&1; then
    END_TIME=$(date +%s.%N)
    RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc -l 2>/dev/null || echo "0.1")
    
    if (( $(echo "$RESPONSE_TIME < 1.0" | bc -l) )); then
        record_test "API 응답 시간" "PASS" "${RESPONSE_TIME}s (1초 미만)"
    else
        record_test "API 응답 시간" "FAIL" "${RESPONSE_TIME}s (1초 초과)"
    fi
else
    record_test "API 응답 시간" "FAIL" "응답 실패"
fi

# 8.2 메모리 사용량 확인
log_validation "8.2 메모리 사용량 확인"

if command -v pm2 &> /dev/null; then
    MEMORY_USAGE=$(pm2 list | grep assetmanager | awk '{print $4}' | sed 's/M//')
    if [ -n "$MEMORY_USAGE" ] && [ "$MEMORY_USAGE" -lt 500 ]; then
        record_test "메모리 사용량" "PASS" "${MEMORY_USAGE}MB (500MB 미만)"
    else
        record_test "메모리 사용량" "FAIL" "${MEMORY_USAGE}MB (500MB 초과)"
    fi
else
    record_test "메모리 사용량" "FAIL" "PM2 없음"
fi

# =============================================================================
# 9. 테스트 결과 요약
# =============================================================================
log_test "=== 테스트 결과 요약 ==="

echo ""
echo "📊 테스트 결과 통계:"
echo "   총 테스트: $TOTAL_TESTS"
echo "   성공: $PASSED_TESTS"
echo "   실패: $FAILED_TESTS"
echo "   성공률: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    log_success "🎉 모든 테스트 통과! 배포가 성공적으로 완료되었습니다."
    echo ""
    echo "✅ 배포 검증 완료 사항:"
    echo "   - 환경 요구사항 충족"
    echo "   - 의존성 설치 완료"
    echo "   - 환경변수 설정 완료"
    echo "   - 빌드 성공"
    echo "   - 서비스 실행 중"
    echo "   - API 정상 작동"
    echo "   - 보안 설정 완료"
    echo "   - 성능 기준 충족"
    echo ""
    echo "🌐 접속 URL: https://invenone.it.kr"
    echo "🔧 관리 도구: /home/dmanager/fix_oxc_parser.sh"
    echo "📋 로그 확인: pm2 logs assetmanager"
    exit 0
else
    log_error "❌ $FAILED_TESTS개 테스트 실패. 배포에 문제가 있습니다."
    echo ""
    echo "🔧 해결 방법:"
    echo "   1. oxc-parser 문제 해결: ./fix_oxc_parser.sh"
    echo "   2. 환경변수 설정: ./setup_supabase_env.sh"
    echo "   3. 전체 재배포: ./deploy_rocky_linux.sh"
    echo "   4. 시스템 진단: ./troubleshoot.sh"
    echo ""
    echo "📋 실패한 테스트:"
    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == FAIL* ]]; then
            echo "   - ${result#FAIL: }"
        fi
    done
    exit 1
fi 