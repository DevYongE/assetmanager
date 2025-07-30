#!/bin/bash

# QR 자산관리 시스템 진단 스크립트 (2024-12-19)
# 설명: 현재 배포 상태를 진단하고 문제점을 파악합니다.

set -e

echo "🔍 QR 자산관리 시스템 진단을 시작합니다..."

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
FRONTEND_DIR="$CURRENT_DIR/frontend"

echo "=========================================="
echo "🔍 QR 자산관리 시스템 진단"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# =============================================================================
# 1단계: 시스템 정보 확인
# =============================================================================
log_info "1단계: 시스템 정보를 확인합니다..."

echo "=== 시스템 정보 ==="
echo "  - OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  - Kernel: $(uname -r)"
echo "  - CPU: $(nproc) cores"
echo "  - Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "  - Disk: $(df -h / | tail -1 | awk '{print $4}') available"

# NCP 환경 확인
if [ -f "/etc/ncp-info" ] || [ -d "/etc/ncp" ]; then
    log_success "NCP 환경이 감지되었습니다."
    echo "  - NCP Instance: $(cat /etc/ncp-info | grep instance_id | cut -d'=' -f2 2>/dev/null || echo 'N/A')"
else
    log_info "일반 서버 환경입니다."
fi

# =============================================================================
# 2단계: 프로젝트 구조 확인
# =============================================================================
log_info "2단계: 프로젝트 구조를 확인합니다..."

echo "=== 프로젝트 구조 ==="
echo "  - 현재 디렉토리: $CURRENT_DIR"
echo "  - 백엔드 디렉토리: $([ -d "$BACKEND_DIR" ] && echo '존재' || echo '없음')"
echo "  - 프론트엔드 디렉토리: $([ -d "$FRONTEND_DIR" ] && echo '존재' || echo '없음')"

if [ ! -d "$BACKEND_DIR" ] || [ ! -d "$FRONTEND_DIR" ]; then
    log_error "프로젝트 구조에 문제가 있습니다!"
    exit 1
fi

# =============================================================================
# 3단계: 백엔드 상태 확인
# =============================================================================
log_info "3단계: 백엔드 상태를 확인합니다..."

echo "=== 백엔드 상태 ==="

# 백엔드 파일 확인
if [ -f "$BACKEND_DIR/package.json" ]; then
    log_success "package.json이 존재합니다."
else
    log_error "백엔드 package.json이 없습니다!"
fi

if [ -f "$BACKEND_DIR/index.js" ]; then
    log_success "index.js가 존재합니다."
else
    log_error "백엔드 index.js가 없습니다!"
fi

# .env 파일 확인
if [ -f "$BACKEND_DIR/.env" ]; then
    log_success ".env 파일이 존재합니다."
    echo "=== .env 파일 내용 ==="
    cat "$BACKEND_DIR/.env"
else
    log_error ".env 파일이 없습니다!"
fi

# PM2 백엔드 상태
echo "=== PM2 백엔드 상태 ==="
pm2 list | grep qr-backend || echo "qr-backend 프로세스가 없습니다."

# 백엔드 포트 확인
echo "=== 백엔드 포트 상태 ==="
if ss -tlnp | grep ':4000 '; then
    log_success "포트 4000이 사용 중입니다."
else
    log_error "포트 4000이 사용되지 않습니다."
fi

# 백엔드 연결 테스트
echo "=== 백엔드 연결 테스트 ==="
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "백엔드가 정상적으로 응답합니다."
else
    log_error "백엔드가 응답하지 않습니다."
    echo "  - 백엔드 로그:"
    pm2 logs qr-backend --lines 5 2>/dev/null || echo "로그를 확인할 수 없습니다."
fi

# =============================================================================
# 4단계: 프론트엔드 상태 확인
# =============================================================================
log_info "4단계: 프론트엔드 상태를 확인합니다..."

echo "=== 프론트엔드 상태 ==="

# 프론트엔드 파일 확인
if [ -f "$FRONTEND_DIR/package.json" ]; then
    log_success "프론트엔드 package.json이 존재합니다."
else
    log_error "프론트엔드 package.json이 없습니다!"
fi

if [ -f "$FRONTEND_DIR/nuxt.config.ts" ]; then
    log_success "nuxt.config.ts가 존재합니다."
else
    log_error "nuxt.config.ts가 없습니다!"
fi

# 빌드 파일 확인
if [ -d "$FRONTEND_DIR/.output" ]; then
    log_success ".output 디렉토리가 존재합니다."
    echo "=== .output 내용 ==="
    ls -la "$FRONTEND_DIR/.output/"
    
    if [ -f "$FRONTEND_DIR/.output/server/index.mjs" ] || [ -f "$FRONTEND_DIR/.output/server/index.js" ]; then
        log_success "서버 파일이 존재합니다."
    else
        log_error "서버 파일이 없습니다!"
    fi
else
    log_error ".output 디렉토리가 없습니다!"
fi

# PM2 프론트엔드 상태
echo "=== PM2 프론트엔드 상태 ==="
pm2 list | grep qr-frontend || echo "qr-frontend 프로세스가 없습니다."

# 프론트엔드 포트 확인
echo "=== 프론트엔드 포트 상태 ==="
if ss -tlnp | grep ':3000 '; then
    log_success "포트 3000이 사용 중입니다."
else
    log_error "포트 3000이 사용되지 않습니다."
fi

# 프론트엔드 연결 테스트
echo "=== 프론트엔드 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "프론트엔드가 정상적으로 응답합니다."
else
    log_error "프론트엔드가 응답하지 않습니다."
    echo "  - 프론트엔드 로그:"
    pm2 logs qr-frontend --lines 5 2>/dev/null || echo "로그를 확인할 수 없습니다."
fi

# =============================================================================
# 5단계: Nginx 상태 확인
# =============================================================================
log_info "5단계: Nginx 상태를 확인합니다..."

echo "=== Nginx 상태 ==="

# Nginx 서비스 상태
if systemctl is-active --quiet nginx; then
    log_success "Nginx가 실행 중입니다."
else
    log_error "Nginx가 실행되지 않습니다."
    systemctl status nginx --no-pager -l
fi

# Nginx 설정 확인
if sudo nginx -t; then
    log_success "Nginx 설정이 유효합니다."
else
    log_error "Nginx 설정에 오류가 있습니다!"
fi

# Nginx 설정 파일 확인
echo "=== Nginx 설정 파일 ==="
if [ -f "/etc/nginx/conf.d/invenone.it.kr.conf" ]; then
    log_success "invenone.it.kr.conf가 존재합니다."
    echo "=== 설정 파일 내용 ==="
    cat /etc/nginx/conf.d/invenone.it.kr.conf
else
    log_error "invenone.it.kr.conf가 없습니다!"
fi

# Nginx 포트 확인
echo "=== Nginx 포트 상태 ==="
if ss -tlnp | grep ':80 '; then
    log_success "포트 80이 사용 중입니다."
else
    log_error "포트 80이 사용되지 않습니다."
fi

if ss -tlnp | grep ':443 '; then
    log_success "포트 443이 사용 중입니다."
else
    log_error "포트 443이 사용되지 않습니다."
fi

# =============================================================================
# 6단계: SSL 인증서 확인
# =============================================================================
log_info "6단계: SSL 인증서를 확인합니다..."

echo "=== SSL 인증서 상태 ==="

if [ -f "/etc/letsencrypt/live/invenone.it.kr/fullchain.pem" ]; then
    log_success "SSL 인증서가 존재합니다."
    echo "  - 인증서 만료일: $(openssl x509 -in /etc/letsencrypt/live/invenone.it.kr/fullchain.pem -noout -enddate | cut -d'=' -f2)"
else
    log_error "SSL 인증서가 없습니다!"
fi

if [ -f "/etc/letsencrypt/live/invenone.it.kr/privkey.pem" ]; then
    log_success "SSL 개인키가 존재합니다."
else
    log_error "SSL 개인키가 없습니다!"
fi

# =============================================================================
# 7단계: 방화벽 상태 확인
# =============================================================================
log_info "7단계: 방화벽 상태를 확인합니다..."

echo "=== 방화벽 상태 ==="

if command -v firewall-cmd &> /dev/null; then
    # Rocky Linux firewalld
    if systemctl is-active --quiet firewalld; then
        log_success "firewalld가 실행 중입니다."
        echo "  - 활성화된 포트:"
        sudo firewall-cmd --list-ports
    else
        log_error "firewalld가 실행되지 않습니다."
    fi
elif command -v ufw &> /dev/null; then
    # Ubuntu/Debian ufw
    if sudo ufw status | grep -q "Status: active"; then
        log_success "ufw가 활성화되어 있습니다."
        echo "  - ufw 상태:"
        sudo ufw status
    else
        log_error "ufw가 비활성화되어 있습니다."
    fi
else
    log_warning "방화벽이 설치되지 않았습니다."
fi

# =============================================================================
# 8단계: 도메인 연결 테스트
# =============================================================================
log_info "8단계: 도메인 연결을 테스트합니다..."

echo "=== 도메인 연결 테스트 ==="

# DNS 확인
if nslookup invenone.it.kr &> /dev/null; then
    log_success "도메인 DNS 확인이 성공했습니다."
else
    log_error "도메인 DNS 확인에 실패했습니다."
fi

# HTTP 연결 테스트
if curl -s http://invenone.it.kr &> /dev/null; then
    log_success "HTTP 연결이 성공했습니다."
else
    log_error "HTTP 연결에 실패했습니다."
fi

# HTTPS 연결 테스트
if curl -s https://invenone.it.kr &> /dev/null; then
    log_success "HTTPS 연결이 성공했습니다."
else
    log_warning "HTTPS 연결에 실패했습니다."
fi

# API 연결 테스트
if curl -s http://invenone.it.kr/api/health &> /dev/null; then
    log_success "API 연결이 성공했습니다."
else
    log_error "API 연결에 실패했습니다."
fi

# =============================================================================
# 9단계: 시스템 리소스 확인
# =============================================================================
log_info "9단계: 시스템 리소스를 확인합니다..."

echo "=== 시스템 리소스 ==="

# CPU 사용률
echo "  - CPU 사용률: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"

# 메모리 사용률
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
echo "  - 메모리 사용률: ${MEMORY_USAGE}%"

# 디스크 사용률
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
echo "  - 디스크 사용률: ${DISK_USAGE}%"

# 로드 평균
LOAD_AVERAGE=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | cut -d',' -f1)
echo "  - 로드 평균: $LOAD_AVERAGE"

# =============================================================================
# 10단계: 문제점 요약
# =============================================================================
log_info "10단계: 문제점을 요약합니다..."

echo ""
echo "=========================================="
echo "🔍 진단 결과 요약"
echo "=========================================="
echo ""

# 문제점 카운터
ERROR_COUNT=0
WARNING_COUNT=0

# 백엔드 문제 확인
if ! curl -s http://localhost:4000/api/health &> /dev/null; then
    echo "❌ 백엔드가 응답하지 않습니다."
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# 프론트엔드 문제 확인
if ! curl -s http://localhost:3000 &> /dev/null; then
    echo "❌ 프론트엔드가 응답하지 않습니다."
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# Nginx 문제 확인
if ! systemctl is-active --quiet nginx; then
    echo "❌ Nginx가 실행되지 않습니다."
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

# SSL 인증서 문제 확인
if [ ! -f "/etc/letsencrypt/live/invenone.it.kr/fullchain.pem" ]; then
    echo "⚠️  SSL 인증서가 없습니다."
    WARNING_COUNT=$((WARNING_COUNT + 1))
fi

# 도메인 연결 문제 확인
if ! curl -s http://invenone.it.kr &> /dev/null; then
    echo "❌ 도메인 연결에 실패했습니다."
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi

echo ""
echo "=== 문제점 통계 ==="
echo "  - 오류: $ERROR_COUNT개"
echo "  - 경고: $WARNING_COUNT개"

if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
    log_success "모든 시스템이 정상적으로 작동하고 있습니다! 🎉"
elif [ $ERROR_COUNT -eq 0 ]; then
    log_warning "경고가 $WARNING_COUNT개 있습니다. 확인이 필요합니다."
else
    log_error "오류가 $ERROR_COUNT개 있습니다. 즉시 수정이 필요합니다."
fi

echo ""
echo "📝 다음 단계:"
if [ $ERROR_COUNT -gt 0 ]; then
    echo "1. ./deploy.sh 실행하여 시스템 재배포"
    echo "2. 문제가 지속되면 로그를 확인하세요"
fi
if [ $WARNING_COUNT -gt 0 ]; then
    echo "3. SSL 인증서 설정 확인"
fi
echo "4. PM2 로그 확인: pm2 logs"
echo "5. Nginx 로그 확인: sudo tail -f /var/log/nginx/error.log"

echo ""
log_success "진단이 완료되었습니다! 🔍" 