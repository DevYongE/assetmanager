#!/bin/bash

# 포트 충돌 문제 해결 스크립트 (2024-12-19)
# 설명: 포트 3000, 4000 충돌 문제를 해결합니다.

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

# 1. 현재 포트 사용 상태 확인
log_info "1. 현재 포트 사용 상태를 확인합니다..."

echo "=== 포트 3000 사용 상태 ==="
if ss -tlnp | grep ':3000 '; then
    log_warning "포트 3000이 사용 중입니다."
    PORT_3000_PID=$(ss -tlnp | grep ':3000 ' | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2 | head -1)
    echo "  - 사용 중인 프로세스 PID: $PORT_3000_PID"
else
    log_success "포트 3000이 사용되지 않습니다."
fi

echo ""
echo "=== 포트 4000 사용 상태 ==="
if ss -tlnp | grep ':4000 '; then
    log_warning "포트 4000이 사용 중입니다."
    PORT_4000_PID=$(ss -tlnp | grep ':4000 ' | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2 | head -1)
    echo "  - 사용 중인 프로세스 PID: $PORT_4000_PID"
else
    log_success "포트 4000이 사용되지 않습니다."
fi

echo ""
echo "=== 모든 LISTEN 포트 ==="
ss -tlnp | grep LISTEN

# 2. PM2 프로세스 확인
log_info "2. PM2 프로세스를 확인합니다..."
echo "=== PM2 프로세스 상태 ==="
pm2 status

# 3. 포트를 사용하는 프로세스 상세 확인
log_info "3. 포트를 사용하는 프로세스를 상세 확인합니다..."

if [ ! -z "$PORT_3000_PID" ]; then
    echo "=== 포트 3000 사용 프로세스 상세 정보 ==="
    ps -p $PORT_3000_PID -o pid,ppid,cmd,comm
fi

if [ ! -z "$PORT_4000_PID" ]; then
    echo "=== 포트 4000 사용 프로세스 상세 정보 ==="
    ps -p $PORT_4000_PID -o pid,ppid,cmd,comm
fi

# 4. 웹 서버 프로세스 확인
log_info "4. 웹 서버 프로세스를 확인합니다..."
echo "=== Node.js 프로세스 ==="
pgrep -f "node" | xargs ps -o pid,ppid,cmd 2>/dev/null || echo "Node.js 프로세스가 없습니다."

echo ""
echo "=== PM2 프로세스 ==="
pgrep -f "pm2" | xargs ps -o pid,ppid,cmd 2>/dev/null || echo "PM2 프로세스가 없습니다."

# 5. 포트 충돌 해결
log_info "5. 포트 충돌을 해결합니다..."

# 포트 3000 해결
if [ ! -z "$PORT_3000_PID" ]; then
    log_info "포트 3000을 사용하는 프로세스를 종료합니다..."
    
    # 프로세스 정보 확인
    PROCESS_INFO=$(ps -p $PORT_3000_PID -o pid,ppid,cmd,comm 2>/dev/null)
    echo "  - 종료할 프로세스 정보:"
    echo "$PROCESS_INFO"
    
    # PM2 프로세스인지 확인
    if echo "$PROCESS_INFO" | grep -q "pm2"; then
        log_info "PM2 프로세스입니다. PM2로 종료합니다..."
        pm2 delete qr-frontend 2>/dev/null || true
        pm2 delete frontend 2>/dev/null || true
    else
        log_info "일반 프로세스입니다. 강제 종료합니다..."
        kill -9 $PORT_3000_PID 2>/dev/null || true
    fi
    
    sleep 2
    
    # 포트 해제 확인
    if ss -tlnp | grep ':3000 '; then
        log_error "포트 3000이 여전히 사용 중입니다!"
    else
        log_success "포트 3000이 해제되었습니다."
    fi
fi

# 포트 4000 해결
if [ ! -z "$PORT_4000_PID" ]; then
    log_info "포트 4000을 사용하는 프로세스를 종료합니다..."
    
    # 프로세스 정보 확인
    PROCESS_INFO=$(ps -p $PORT_4000_PID -o pid,ppid,cmd,comm 2>/dev/null)
    echo "  - 종료할 프로세스 정보:"
    echo "$PROCESS_INFO"
    
    # PM2 프로세스인지 확인
    if echo "$PROCESS_INFO" | grep -q "pm2"; then
        log_info "PM2 프로세스입니다. PM2로 종료합니다..."
        pm2 delete qr-backend 2>/dev/null || true
    else
        log_info "일반 프로세스입니다. 강제 종료합니다..."
        kill -9 $PORT_4000_PID 2>/dev/null || true
    fi
    
    sleep 2
    
    # 포트 해제 확인
    if ss -tlnp | grep ':4000 '; then
        log_error "포트 4000이 여전히 사용 중입니다!"
    else
        log_success "포트 4000이 해제되었습니다."
    fi
fi

# 6. PM2 프로세스 정리
log_info "6. PM2 프로세스를 정리합니다..."
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

sleep 3

# 7. 포트 상태 재확인
log_info "7. 포트 상태를 재확인합니다..."
echo "=== 포트 상태 재확인 ==="
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 4000: $(ss -tlnp | grep ':4000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"

# 8. 백엔드 재시작
log_info "8. 백엔드를 재시작합니다..."
cd "$CURRENT_DIR/backend"

if [ -f "index.js" ]; then
    log_info "백엔드를 PM2로 시작합니다..."
    pm2 start index.js --name "qr-backend" --env production
    
    sleep 5
    
    # 백엔드 상태 확인
    if curl -s http://localhost:4000/api/health &> /dev/null; then
        log_success "백엔드가 정상적으로 실행됩니다!"
    else
        log_error "백엔드가 응답하지 않습니다!"
        pm2 logs qr-backend --lines 5
    fi
else
    log_error "백엔드 index.js 파일이 없습니다!"
fi

# 9. 프론트엔드 재시작
log_info "9. 프론트엔드를 재시작합니다..."
cd "$CURRENT_DIR/frontend"

if [ -f "ecosystem.config.cjs" ]; then
    log_info "프론트엔드를 PM2로 시작합니다..."
    pm2 start ecosystem.config.cjs
    
    sleep 5
    
    # 프론트엔드 상태 확인
    if curl -s http://localhost:3000 &> /dev/null; then
        log_success "프론트엔드가 정상적으로 실행됩니다!"
    else
        log_error "프론트엔드가 응답하지 않습니다!"
        pm2 logs qr-frontend --lines 5
    fi
else
    log_error "프론트엔드 ecosystem.config.cjs 파일이 없습니다!"
fi

# 10. 최종 상태 확인
log_info "10. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - PM2 Backend: $(pm2 list | grep qr-backend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - PM2 Frontend: $(pm2 list | grep qr-frontend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - 포트 3000: $(ss -tlnp | grep ':3000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 4000: $(ss -tlnp | grep ':4000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "로컬 프론트엔드 연결: 정상"
else
    log_error "로컬 프론트엔드 연결: 실패"
fi

if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "로컬 백엔드 연결: 정상"
else
    log_error "로컬 백엔드 연결: 실패"
fi

echo ""
echo "=========================================="
echo "🔧 포트 충돌 문제 해결 완료!"
echo "=========================================="
echo ""

log_success "포트 충돌 문제 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 포트 확인: ss -tlnp | grep ':3000\\|:4000'"
echo "  - 프로세스 확인: ps aux | grep node" 