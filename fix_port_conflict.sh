#!/bin/bash

# 포트 충돌 문제 해결 스크립트 (NCP Rocky Linux용)
# 작성일: 2024-12-19
# 설명: 포트 80, 443을 사용하는 프로세스를 찾아서 해결합니다.

set -e

echo "🔧 포트 충돌 문제를 해결합니다..."

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
echo "🔧 포트 충돌 문제 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 포트 사용 상태 확인
log_info "1. 포트 사용 상태를 확인합니다..."
echo "=== 포트 80 사용 상태 ==="
ss -tlnp | grep ':80 ' || echo "포트 80이 사용되지 않습니다."

echo ""
echo "=== 포트 443 사용 상태 ==="
ss -tlnp | grep ':443 ' || echo "포트 443이 사용되지 않습니다."

echo ""
echo "=== 모든 LISTEN 포트 ==="
ss -tlnp | grep LISTEN

# 2. 포트를 사용하는 프로세스 확인
log_info "2. 포트를 사용하는 프로세스를 확인합니다..."

# 포트 80 사용 프로세스
PORT_80_PID=$(ss -tlnp | grep ':80 ' | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2 | head -1)
if [ ! -z "$PORT_80_PID" ]; then
    echo "=== 포트 80 사용 프로세스 (PID: $PORT_80_PID) ==="
    ps -p $PORT_80_PID -o pid,ppid,cmd
else
    echo "포트 80을 사용하는 프로세스가 없습니다."
fi

# 포트 443 사용 프로세스
PORT_443_PID=$(ss -tlnp | grep ':443 ' | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2 | head -1)
if [ ! -z "$PORT_443_PID" ]; then
    echo "=== 포트 443 사용 프로세스 (PID: $PORT_443_PID) ==="
    ps -p $PORT_443_PID -o pid,ppid,cmd
else
    echo "포트 443을 사용하는 프로세스가 없습니다."
fi

# 3. 웹 서버 프로세스 확인
log_info "3. 웹 서버 프로세스를 확인합니다..."
echo "=== Nginx 프로세스 ==="
pgrep nginx | xargs ps -o pid,ppid,cmd 2>/dev/null || echo "Nginx 프로세스가 없습니다."

echo ""
echo "=== Apache 프로세스 ==="
pgrep httpd | xargs ps -o pid,ppid,cmd 2>/dev/null || echo "Apache 프로세스가 없습니다."

echo ""
echo "=== Caddy 프로세스 ==="
pgrep caddy | xargs ps -o pid,ppid,cmd 2>/dev/null || echo "Caddy 프로세스가 없습니다."

# 4. 서비스 상태 확인
log_info "4. 웹 서버 서비스 상태를 확인합니다..."
echo "=== Nginx 서비스 ==="
systemctl status nginx --no-pager -l | head -10

echo ""
echo "=== Apache 서비스 ==="
systemctl status httpd --no-pager -l 2>/dev/null | head -10 || echo "Apache 서비스가 없습니다."

# 5. 포트 충돌 해결
log_info "5. 포트 충돌을 해결합니다..."

# 포트 80 해결
if [ ! -z "$PORT_80_PID" ]; then
    echo "포트 80을 사용하는 프로세스 (PID: $PORT_80_PID)를 중지합니다..."
    
    # 프로세스 정보 확인
    PROCESS_NAME=$(ps -p $PORT_80_PID -o comm= 2>/dev/null)
    echo "  - 프로세스 이름: $PROCESS_NAME"
    
    case $PROCESS_NAME in
        nginx)
            echo "  - Nginx 프로세스를 중지합니다..."
            sudo systemctl stop nginx
            ;;
        httpd|apache2)
            echo "  - Apache 프로세스를 중지합니다..."
            sudo systemctl stop httpd
            ;;
        caddy)
            echo "  - Caddy 프로세스를 중지합니다..."
            sudo systemctl stop caddy
            ;;
        *)
            echo "  - 알 수 없는 프로세스를 강제 종료합니다..."
            sudo kill -9 $PORT_80_PID
            ;;
    esac
fi

# 포트 443 해결
if [ ! -z "$PORT_443_PID" ]; then
    echo "포트 443을 사용하는 프로세스 (PID: $PORT_443_PID)를 중지합니다..."
    
    # 프로세스 정보 확인
    PROCESS_NAME=$(ps -p $PORT_443_PID -o comm= 2>/dev/null)
    echo "  - 프로세스 이름: $PROCESS_NAME"
    
    case $PROCESS_NAME in
        nginx)
            echo "  - Nginx 프로세스를 중지합니다..."
            sudo systemctl stop nginx
            ;;
        httpd|apache2)
            echo "  - Apache 프로세스를 중지합니다..."
            sudo systemctl stop httpd
            ;;
        caddy)
            echo "  - Caddy 프로세스를 중지합니다..."
            sudo systemctl stop caddy
            ;;
        *)
            echo "  - 알 수 없는 프로세스를 강제 종료합니다..."
            sudo kill -9 $PORT_443_PID
            ;;
    esac
fi

# 6. 포트 해제 확인
log_info "6. 포트 해제를 확인합니다..."
sleep 2

echo "=== 포트 80 상태 ==="
ss -tlnp | grep ':80 ' || echo "포트 80이 해제되었습니다."

echo ""
echo "=== 포트 443 상태 ==="
ss -tlnp | grep ':443 ' || echo "포트 443이 해제되었습니다."

# 7. Nginx 시작
log_info "7. Nginx를 시작합니다..."

# Nginx 설정 테스트
if sudo nginx -t; then
    log_success "Nginx 설정이 유효합니다."
    
    # Nginx 시작
    sudo systemctl start nginx
    
    # Nginx 상태 확인
    if systemctl is-active --quiet nginx; then
        log_success "Nginx가 성공적으로 시작되었습니다!"
        echo "  - Status: $(systemctl is-active nginx)"
        echo "  - 포트 80: $(ss -tlnp | grep ':80 ' || echo '사용되지 않음')"
        echo "  - 포트 443: $(ss -tlnp | grep ':443 ' || echo '사용되지 않음')"
    else
        log_error "Nginx 시작에 실패했습니다!"
        systemctl status nginx --no-pager -l
    fi
else
    log_error "Nginx 설정에 오류가 있습니다!"
    exit 1
fi

# 8. 서비스 자동 시작 설정
log_info "8. 서비스 자동 시작을 설정합니다..."
sudo systemctl enable nginx

# 9. 최종 상태 확인
log_info "9. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 서비스 상태 ==="
echo "  - Nginx: $(systemctl is-active nginx)"
echo "  - Nginx Enabled: $(systemctl is-enabled nginx)"

echo ""
echo "=== 최종 포트 상태 ==="
echo "  - 포트 80: $(ss -tlnp | grep ':80 ' || echo '사용되지 않음')"
echo "  - 포트 443: $(ss -tlnp | grep ':443 ' || echo '사용되지 않음')"

# 10. 연결 테스트
log_info "10. 연결을 테스트합니다..."
if curl -s -I http://localhost 2>/dev/null | head -1; then
    log_success "HTTP 연결이 정상입니다."
else
    log_warning "HTTP 연결에 문제가 있습니다."
fi

echo ""
echo "=========================================="
echo "🔧 포트 충돌 문제 해결 완료!"
echo "=========================================="
echo ""

if systemctl is-active --quiet nginx; then
    log_success "Nginx가 정상적으로 실행 중입니다!"
    echo "  - HTTP: http://invenone.it.kr"
    echo "  - HTTPS: https://invenone.it.kr (SSL 인증서 설정 시)"
else
    log_error "Nginx 실행에 문제가 있습니다."
fi

echo ""
echo "📝 유용한 명령어:"
echo "  - 포트 확인: ss -tlnp | grep -E ':(80|443)'"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - Nginx 재시작: sudo systemctl restart nginx"
echo "  - 프로세스 확인: ps aux | grep -E '(nginx|httpd|caddy)'"

echo ""
log_success "포트 충돌 문제 해결이 완료되었습니다! 🎉" 