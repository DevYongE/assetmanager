#!/bin/bash

# 502 Bad Gateway 오류 진단 스크립트 (NCP Rocky Linux용)
# 작성일: 2024-12-19
# 설명: invenone.it.kr 도메인에서 발생하는 502 오류를 진단합니다.

set -e

echo "🔍 502 Bad Gateway 오류 진단을 시작합니다..."

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
PROJECT_DIR="$CURRENT_DIR"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"
DOMAIN="invenone.it.kr"

echo "=========================================="
echo "🔍 502 Bad Gateway 오류 진단"
echo "도메인: $DOMAIN"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. Nginx 상태 확인
log_info "1. Nginx 상태를 확인합니다..."
if systemctl is-active --quiet nginx; then
    log_success "Nginx가 실행 중입니다."
    echo "  - Status: $(systemctl is-active nginx)"
else
    log_error "Nginx가 실행되지 않습니다!"
    echo "  - Nginx 시작: sudo systemctl start nginx"
fi

# 2. Nginx 설정 테스트
log_info "2. Nginx 설정을 테스트합니다..."
if sudo nginx -t &> /dev/null; then
    log_success "Nginx 설정이 유효합니다."
else
    log_error "Nginx 설정에 오류가 있습니다!"
    echo "  - 설정 오류 확인: sudo nginx -t"
fi

# 3. 포트 사용 상태 확인
log_info "3. 포트 사용 상태를 확인합니다..."
echo "  - 포트 80 (HTTP): $(ss -tlnp | grep ':80 ' || echo '사용되지 않음')"
echo "  - 포트 443 (HTTPS): $(ss -tlnp | grep ':443 ' || echo '사용되지 않음')"
echo "  - 포트 3000 (프론트엔드): $(ss -tlnp | grep ':3000 ' || echo '사용되지 않음')"
echo "  - 포트 4000 (백엔드): $(ss -tlnp | grep ':4000 ' || echo '사용되지 않음')"

# 4. PM2 상태 확인
log_info "4. PM2 상태를 확인합니다..."
if command -v pm2 &> /dev/null; then
    log_success "PM2가 설치되어 있습니다."
    pm2 status
else
    log_error "PM2가 설치되지 않았습니다!"
fi

# 5. 백엔드 프로세스 확인
log_info "5. 백엔드 프로세스를 확인합니다..."
if pm2 list | grep -q "qr-backend"; then
    log_success "백엔드 프로세스가 실행 중입니다."
    pm2 logs qr-backend --lines 10
else
    log_error "백엔드 프로세스가 실행되지 않습니다!"
    echo "  - 백엔드 시작: pm2 start /var/www/qr-asset-management/backend/index.js --name qr-backend"
fi

# 6. 백엔드 디렉토리 확인
log_info "6. 백엔드 디렉토리를 확인합니다..."
if [ -d "$BACKEND_DIR" ]; then
    log_success "백엔드 디렉토리가 존재합니다."
    echo "  - 경로: $BACKEND_DIR"
    echo "  - package.json: $([ -f "$BACKEND_DIR/package.json" ] && echo '존재' || echo '없음')"
    echo "  - index.js: $([ -f "$BACKEND_DIR/index.js" ] && echo '존재' || echo '없음')"
    echo "  - .env: $([ -f "$BACKEND_DIR/.env" ] && echo '존재' || echo '없음')"
else
    log_error "백엔드 디렉토리가 존재하지 않습니다!"
fi

# 7. 백엔드 직접 테스트
log_info "7. 백엔드 직접 연결을 테스트합니다..."
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "백엔드 API가 응답합니다 (포트 4000)."
else
    log_error "백엔드 API가 응답하지 않습니다 (포트 4000)!"
    echo "  - 백엔드 로그 확인: pm2 logs qr-backend"
    echo "  - 백엔드 재시작: pm2 restart qr-backend"
fi

# 8. 환경 변수 확인
log_info "8. 환경 변수를 확인합니다..."
if [ -f "$BACKEND_DIR/.env" ]; then
    log_success ".env 파일이 존재합니다."
    echo "  - SUPABASE_URL: $(grep SUPABASE_URL "$BACKEND_DIR/.env" | cut -d'=' -f2 | head -c 30)..."
    echo "  - PORT: $(grep PORT "$BACKEND_DIR/.env" | cut -d'=' -f2)"
else
    log_error ".env 파일이 없습니다!"
fi

# 9. Nginx 로그 확인
log_info "9. Nginx 로그를 확인합니다..."
if [ -f "/var/log/nginx/invenone.it.kr-error.log" ]; then
    log_success "Nginx 에러 로그가 존재합니다."
    echo "  - 최근 에러 로그:"
    sudo tail -10 /var/log/nginx/invenone.it.kr-error.log
else
    log_warning "Nginx 에러 로그가 없습니다."
fi

# 10. 방화벽 확인
log_info "10. 방화벽 상태를 확인합니다..."
if systemctl is-active --quiet firewalld; then
    log_success "firewalld가 활성화되어 있습니다."
    echo "  - 허용된 서비스: $(sudo firewall-cmd --list-services)"
else
    log_warning "firewalld가 비활성화되어 있습니다."
fi

# 11. 도메인 DNS 확인
log_info "11. 도메인 DNS를 확인합니다..."
if nslookup $DOMAIN &> /dev/null; then
    log_success "DNS 확인이 정상입니다."
    echo "  - IP Address: $(nslookup $DOMAIN | grep 'Address:' | tail -1 | awk '{print $2}')"
else
    log_error "DNS 확인에 실패했습니다!"
fi

# 12. 로컬 연결 테스트
log_info "12. 로컬 연결을 테스트합니다..."
echo "  - HTTP 연결: $(curl -s -I http://localhost 2>/dev/null | head -1 || echo '실패')"
echo "  - HTTPS 연결: $(curl -s -I https://localhost 2>/dev/null | head -1 || echo '실패')"

# 13. 프로세스 확인
log_info "13. 관련 프로세스를 확인합니다..."
echo "  - Nginx 프로세스: $(pgrep nginx | wc -l)개"
echo "  - Node.js 프로세스: $(pgrep node | wc -l)개"
echo "  - PM2 프로세스: $(pgrep pm2 | wc -l)개"

# 14. 시스템 리소스 확인
log_info "14. 시스템 리소스를 확인합니다..."
echo "  - CPU 사용률: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "  - 메모리 사용률: $(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')%"
echo "  - 디스크 사용률: $(df / | tail -1 | awk '{print $5}')"

echo ""
echo "=========================================="
echo "🔧 502 오류 해결 방법"
echo "=========================================="
echo ""

# 문제 진단 결과에 따른 해결 방법 제시
if ! systemctl is-active --quiet nginx; then
    echo "❌ 문제: Nginx가 실행되지 않습니다."
    echo "   해결: sudo systemctl start nginx"
elif ! pm2 list | grep -q "qr-backend"; then
    echo "❌ 문제: 백엔드 프로세스가 실행되지 않습니다."
    echo "   해결: pm2 start /var/www/qr-asset-management/backend/index.js --name qr-backend"
elif ! curl -s http://localhost:4000/api/health &> /dev/null; then
    echo "❌ 문제: 백엔드 API가 응답하지 않습니다."
    echo "   해결: pm2 restart qr-backend"
    echo "   로그 확인: pm2 logs qr-backend"
elif ! [ -f "$BACKEND_DIR/.env" ]; then
    echo "❌ 문제: .env 파일이 없습니다."
    echo "   해결: 백엔드 환경 변수를 설정하세요"
else
    echo "✅ 모든 기본 설정이 정상입니다."
    echo "   추가 진단이 필요할 수 있습니다."
fi

echo ""
echo "📝 유용한 명령어:"
echo "  - 백엔드 재시작: pm2 restart qr-backend"
echo "  - Nginx 재시작: sudo systemctl restart nginx"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - Nginx 로그: sudo tail -f /var/log/nginx/invenone.it.kr-error.log"
echo "  - 포트 확인: ss -tlnp | grep -E ':(80|443|3000|4000)'"
echo "  - 프로세스 확인: ps aux | grep -E '(nginx|node|pm2)'"

echo ""
log_success "502 오류 진단이 완료되었습니다! 🎉" 