#!/bin/bash

# 고집스러운 프로세스 강제 종료 스크립트 (2024-12-19)
# 설명: 포트 3000, 4000을 사용하는 프로세스를 강제로 종료합니다.

set -e

echo "🔧 고집스러운 프로세스를 강제 종료합니다..."

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
echo "🔧 고집스러운 프로세스 강제 종료"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 현재 포트 사용 상태 확인
log_info "1. 현재 포트 사용 상태를 확인합니다..."

echo "=== 포트 3000 사용 상태 ==="
if lsof -i :3000 2>/dev/null; then
    log_warning "포트 3000이 사용 중입니다."
    PORT_3000_PIDS=$(lsof -i :3000 -t 2>/dev/null)
    echo "  - 사용 중인 프로세스 PID: $PORT_3000_PIDS"
else
    log_success "포트 3000이 사용되지 않습니다."
fi

echo ""
echo "=== 포트 4000 사용 상태 ==="
if lsof -i :4000 2>/dev/null; then
    log_warning "포트 4000이 사용 중입니다."
    PORT_4000_PIDS=$(lsof -i :4000 -t 2>/dev/null)
    echo "  - 사용 중인 프로세스 PID: $PORT_4000_PIDS"
else
    log_success "포트 4000이 사용되지 않습니다."
fi

# 2. 프로세스 상세 정보 확인
log_info "2. 프로세스 상세 정보를 확인합니다..."

if [ ! -z "$PORT_3000_PIDS" ]; then
    echo "=== 포트 3000 프로세스 상세 정보 ==="
    for pid in $PORT_3000_PIDS; do
        echo "  - PID $pid:"
        ps -p $pid -o pid,ppid,user,comm,cmd 2>/dev/null || echo "    프로세스 정보를 가져올 수 없습니다."
    done
fi

if [ ! -z "$PORT_4000_PIDS" ]; then
    echo "=== 포트 4000 프로세스 상세 정보 ==="
    for pid in $PORT_4000_PIDS; do
        echo "  - PID $pid:"
        ps -p $pid -o pid,ppid,user,comm,cmd 2>/dev/null || echo "    프로세스 정보를 가져올 수 없습니다."
    done
fi

# 3. PM2 프로세스 확인
log_info "3. PM2 프로세스를 확인합니다..."
echo "=== PM2 프로세스 상태 ==="
pm2 status 2>/dev/null || echo "PM2가 설치되지 않았거나 실행되지 않습니다."

# 4. Node.js 프로세스 확인
log_info "4. Node.js 프로세스를 확인합니다..."
echo "=== Node.js 프로세스 ==="
pgrep -f "node" | xargs ps -o pid,ppid,user,comm,cmd 2>/dev/null || echo "Node.js 프로세스가 없습니다."

# 5. 강제 종료 시작
log_info "5. 프로세스를 강제 종료합니다..."

# 포트 3000 프로세스 강제 종료
if [ ! -z "$PORT_3000_PIDS" ]; then
    log_info "포트 3000 프로세스를 강제 종료합니다..."
    for pid in $PORT_3000_PIDS; do
        log_info "  - PID $pid 종료 중..."
        
        # 프로세스 정보 확인
        PROCESS_INFO=$(ps -p $pid -o pid,ppid,user,comm,cmd 2>/dev/null)
        echo "    프로세스 정보:"
        echo "$PROCESS_INFO"
        
        # SIGTERM 시도
        log_info "    SIGTERM 신호 전송..."
        kill -TERM $pid 2>/dev/null || true
        sleep 2
        
        # 프로세스가 여전히 살아있는지 확인
        if kill -0 $pid 2>/dev/null; then
            log_warning "    프로세스가 여전히 살아있습니다. SIGKILL 시도..."
            kill -KILL $pid 2>/dev/null || true
            sleep 1
            
            # 최종 확인
            if kill -0 $pid 2>/dev/null; then
                log_error "    프로세스가 여전히 살아있습니다! 수동으로 종료해야 합니다."
            else
                log_success "    프로세스가 종료되었습니다."
            fi
        else
            log_success "    프로세스가 종료되었습니다."
        fi
    done
fi

# 포트 4000 프로세스 강제 종료
if [ ! -z "$PORT_4000_PIDS" ]; then
    log_info "포트 4000 프로세스를 강제 종료합니다..."
    for pid in $PORT_4000_PIDS; do
        log_info "  - PID $pid 종료 중..."
        
        # 프로세스 정보 확인
        PROCESS_INFO=$(ps -p $pid -o pid,ppid,user,comm,cmd 2>/dev/null)
        echo "    프로세스 정보:"
        echo "$PROCESS_INFO"
        
        # SIGTERM 시도
        log_info "    SIGTERM 신호 전송..."
        kill -TERM $pid 2>/dev/null || true
        sleep 2
        
        # 프로세스가 여전히 살아있는지 확인
        if kill -0 $pid 2>/dev/null; then
            log_warning "    프로세스가 여전히 살아있습니다. SIGKILL 시도..."
            kill -KILL $pid 2>/dev/null || true
            sleep 1
            
            # 최종 확인
            if kill -0 $pid 2>/dev/null; then
                log_error "    프로세스가 여전히 살아있습니다! 수동으로 종료해야 합니다."
            else
                log_success "    프로세스가 종료되었습니다."
            fi
        else
            log_success "    프로세스가 종료되었습니다."
        fi
    done
fi

# 6. PM2 프로세스 정리
log_info "6. PM2 프로세스를 정리합니다..."
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

sleep 3

# 7. 모든 Node.js 프로세스 강제 종료
log_info "7. 모든 Node.js 프로세스를 강제 종료합니다..."
NODE_PIDS=$(pgrep -f "node" 2>/dev/null || true)
if [ ! -z "$NODE_PIDS" ]; then
    log_info "Node.js 프로세스 종료 중..."
    for pid in $NODE_PIDS; do
        log_info "  - Node.js PID $pid 종료 중..."
        kill -KILL $pid 2>/dev/null || true
    done
    sleep 2
else
    log_success "Node.js 프로세스가 없습니다."
fi

# 8. 포트 상태 재확인
log_info "8. 포트 상태를 재확인합니다..."
echo "=== 포트 상태 재확인 ==="
echo "  - 포트 3000: $(lsof -i :3000 >/dev/null 2>&1 && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 4000: $(lsof -i :4000 >/dev/null 2>&1 && echo '사용 중' || echo '사용 안 함')"

# 9. 포트 사용 프로세스 최종 확인
echo ""
echo "=== 포트 사용 프로세스 최종 확인 ==="
echo "  - 포트 3000:"
lsof -i :3000 2>/dev/null || echo "    사용 중인 프로세스 없음"
echo "  - 포트 4000:"
lsof -i :4000 2>/dev/null || echo "    사용 중인 프로세스 없음"

# 10. Node.js 프로세스 최종 확인
echo ""
echo "=== Node.js 프로세스 최종 확인 ==="
pgrep -f "node" | xargs ps -o pid,ppid,user,comm 2>/dev/null || echo "Node.js 프로세스 없음"

# 11. PM2 상태 확인
echo ""
echo "=== PM2 상태 확인 ==="
pm2 status 2>/dev/null || echo "PM2 프로세스 없음"

echo ""
echo "=========================================="
echo "🔧 고집스러운 프로세스 강제 종료 완료!"
echo "=========================================="
echo ""

log_success "고집스러운 프로세스 강제 종료가 완료되었습니다! 🎉"
echo ""
echo "📝 다음 단계:"
echo "  1. 포트가 해제되었는지 확인: lsof -i :3000"
echo "  2. PM2로 서비스 재시작: pm2 start [프로세스명]"
echo "  3. 연결 테스트: curl http://localhost:3000"
echo ""
echo "📝 유용한 명령어:"
echo "  - 포트 확인: lsof -i :3000"
echo "  - 프로세스 확인: ps aux | grep node"
echo "  - PM2 상태: pm2 status"
echo "  - 강제 종료: kill -9 [PID]" 