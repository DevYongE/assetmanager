#!/bin/bash

# 완전한 사용자 권한 문제 해결 스크립트 (2024-12-19)
# 설명: 백엔드와 프론트엔드 모두 dmanager 계정으로 실행하도록 설정합니다.

set -e

echo "🔧 완전한 사용자 권한 문제를 해결합니다..."

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
echo "🔧 완전한 사용자 권한 문제 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 현재 사용자 확인
log_info "1. 현재 사용자를 확인합니다..."
CURRENT_USER=$(whoami)
echo "  - 현재 사용자: $CURRENT_USER"

if [ "$CURRENT_USER" = "root" ]; then
    log_warning "root 계정으로 실행 중입니다. dmanager 계정으로 전환해야 합니다."
else
    log_success "올바른 사용자 계정으로 실행 중입니다: $CURRENT_USER"
fi

# dmanager 계정 존재 확인
log_info "2. dmanager 계정을 확인합니다..."
if id "dmanager" &>/dev/null; then
    log_success "dmanager 계정이 존재합니다."
    DMANAGER_HOME=$(eval echo ~dmanager)
    echo "  - dmanager 홈 디렉토리: $DMANAGER_HOME"
else
    log_error "dmanager 계정이 존재하지 않습니다!"
    exit 1
fi

# 프로젝트 디렉토리 확인
log_info "3. 프로젝트 디렉토리를 확인합니다..."
PROJECT_DIR="/home/dmanager/assetmanager"
if [ -d "$PROJECT_DIR" ]; then
    log_success "프로젝트 디렉토리가 존재합니다: $PROJECT_DIR"
else
    log_error "프로젝트 디렉토리가 존재하지 않습니다: $PROJECT_DIR"
    exit 1
fi

# 현재 PM2 프로세스 확인
log_info "4. 현재 PM2 프로세스를 확인합니다..."
echo "=== 현재 PM2 프로세스 ==="
pm2 status

# PM2 프로세스 소유자 확인
log_info "5. PM2 프로세스 소유자를 확인합니다..."
echo "=== PM2 프로세스 소유자 ==="
pm2 list | grep -E "(qr-backend|qr-frontend)" | while read line; do
    if echo "$line" | grep -q "qr-backend\|qr-frontend"; then
        PID=$(echo "$line" | awk '{print $6}')
        if [ ! -z "$PID" ] && [ "$PID" != "0" ]; then
            OWNER=$(ps -o user= -p $PID 2>/dev/null || echo "알 수 없음")
            echo "  - PID $PID 소유자: $OWNER"
        fi
    fi
done

# PM2 프로세스 정리
log_info "6. 현재 PM2 프로세스를 정리합니다..."
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

sleep 3

# dmanager 계정으로 전환하여 PM2 설정
log_info "7. dmanager 계정으로 PM2를 설정합니다..."

# PM2 startup 설정 (dmanager 계정용)
if [ "$CURRENT_USER" = "root" ]; then
    log_info "root에서 dmanager 계정으로 PM2 startup을 설정합니다..."
    su - dmanager -c "pm2 startup"
    PM2_STARTUP=$(su - dmanager -c "pm2 startup" | grep "sudo" | head -1)
    if [ ! -z "$PM2_STARTUP" ]; then
        log_info "PM2 startup 명령어를 실행합니다:"
        echo "  $PM2_STARTUP"
        eval $PM2_STARTUP
    fi
else
    log_info "현재 사용자로 PM2 startup을 설정합니다..."
    pm2 startup
fi

# 8. 백엔드 시작 (dmanager 계정으로)
log_info "8. 백엔드를 dmanager 계정으로 시작합니다..."
cd "$PROJECT_DIR/backend"

if [ -f "index.js" ]; then
    if [ "$CURRENT_USER" = "root" ]; then
        log_info "root에서 dmanager로 백엔드를 시작합니다..."
        su - dmanager -c "cd $PROJECT_DIR/backend && pm2 start index.js --name 'qr-backend' --env production"
    else
        log_info "현재 사용자로 백엔드를 시작합니다..."
        pm2 start index.js --name "qr-backend" --env production
    fi
    
    sleep 5
    
    # 백엔드 상태 확인
    if curl -s http://localhost:4000/api/health &> /dev/null; then
        log_success "백엔드가 정상적으로 실행됩니다!"
    else
        log_error "백엔드가 응답하지 않습니다!"
        if [ "$CURRENT_USER" = "root" ]; then
            su - dmanager -c "pm2 logs qr-backend --lines 5"
        else
            pm2 logs qr-backend --lines 5
        fi
    fi
else
    log_error "백엔드 index.js 파일이 없습니다!"
fi

# 9. 프론트엔드 시작 (dmanager 계정으로)
log_info "9. 프론트엔드를 dmanager 계정으로 시작합니다..."
cd "$PROJECT_DIR/frontend"

if [ -f "ecosystem.config.cjs" ]; then
    if [ "$CURRENT_USER" = "root" ]; then
        log_info "root에서 dmanager로 프론트엔드를 시작합니다..."
        su - dmanager -c "cd $PROJECT_DIR/frontend && pm2 start ecosystem.config.cjs"
    else
        log_info "현재 사용자로 프론트엔드를 시작합니다..."
        pm2 start ecosystem.config.cjs
    fi
    
    sleep 5
    
    # 프론트엔드 상태 확인
    if curl -s http://localhost:3000 &> /dev/null; then
        log_success "프론트엔드가 정상적으로 실행됩니다!"
    else
        log_error "프론트엔드가 응답하지 않습니다!"
        if [ "$CURRENT_USER" = "root" ]; then
            su - dmanager -c "pm2 logs qr-frontend --lines 5"
        else
            pm2 logs qr-frontend --lines 5
        fi
    fi
else
    log_error "프론트엔드 ecosystem.config.cjs 파일이 없습니다!"
    
    # ecosystem.config.cjs 파일이 없으면 생성
    log_info "ecosystem.config.cjs 파일을 생성합니다..."
    if [ "$CURRENT_USER" = "root" ]; then
        su - dmanager -c "cd $PROJECT_DIR/frontend && cat > ecosystem.config.cjs << 'EOF'
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
EOF"
        
        # 다시 프론트엔드 시작
        su - dmanager -c "cd $PROJECT_DIR/frontend && pm2 start ecosystem.config.cjs"
    else
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
        
        # 다시 프론트엔드 시작
        pm2 start ecosystem.config.cjs
    fi
    
    sleep 5
    
    # 프론트엔드 상태 재확인
    if curl -s http://localhost:3000 &> /dev/null; then
        log_success "프론트엔드가 정상적으로 실행됩니다!"
    else
        log_error "프론트엔드가 여전히 응답하지 않습니다!"
        if [ "$CURRENT_USER" = "root" ]; then
            su - dmanager -c "pm2 logs qr-frontend --lines 10"
        else
            pm2 logs qr-frontend --lines 10
        fi
    fi
fi

# 10. PM2 프로세스 소유자 재확인
log_info "10. PM2 프로세스 소유자를 재확인합니다..."
echo "=== PM2 프로세스 상태 ==="
if [ "$CURRENT_USER" = "root" ]; then
    su - dmanager -c "pm2 status"
else
    pm2 status
fi

echo ""
echo "=== PM2 프로세스 소유자 ==="
if [ "$CURRENT_USER" = "root" ]; then
    su - dmanager -c "pm2 list" | grep -E "(qr-backend|qr-frontend)" | while read line; do
        if echo "$line" | grep -q "qr-backend\|qr-frontend"; then
            PID=$(echo "$line" | awk '{print $6}')
            if [ ! -z "$PID" ] && [ "$PID" != "0" ]; then
                OWNER=$(ps -o user= -p $PID 2>/dev/null || echo "알 수 없음")
                echo "  - PID $PID 소유자: $OWNER"
            fi
        fi
    done
else
    pm2 list | grep -E "(qr-backend|qr-frontend)" | while read line; do
        if echo "$line" | grep -q "qr-backend\|qr-frontend"; then
            PID=$(echo "$line" | awk '{print $6}')
            if [ ! -z "$PID" ] && [ "$PID" != "0" ]; then
                OWNER=$(ps -o user= -p $PID 2>/dev/null || echo "알 수 없음")
                echo "  - PID $PID 소유자: $OWNER"
            fi
        fi
    done
fi

# 11. 최종 상태 확인
log_info "11. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 상태 ==="
echo "  - 현재 사용자: $CURRENT_USER"
echo "  - 프로젝트 디렉토리: $PROJECT_DIR"
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

if curl -s https://invenone.it.kr &> /dev/null; then
    log_success "도메인 프론트엔드 연결: 정상"
else
    log_warning "도메인 프론트엔드 연결: 실패"
fi

if curl -s https://invenone.it.kr/api/health &> /dev/null; then
    log_success "도메인 백엔드 연결: 정상"
else
    log_warning "도메인 백엔드 연결: 실패"
fi

echo ""
echo "=========================================="
echo "🔧 완전한 사용자 권한 문제 해결 완료!"
echo "=========================================="
echo ""

log_success "완전한 사용자 권한 문제 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 중요 사항:"
echo "  - 백엔드와 프론트엔드 모두 dmanager 계정으로 실행됩니다."
echo "  - 서버 재시작 시에도 dmanager 계정으로 자동 시작됩니다."
echo "  - root 계정으로 실행하지 마세요!"
echo ""
echo "📝 유용한 명령어:"
echo "  - dmanager로 전환: su - dmanager"
echo "  - PM2 상태: pm2 status"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 프로세스 소유자 확인: ps -o user= -p [PID]"
echo "  - PM2 프로세스 소유자 확인: pm2 list | grep -E '(qr-backend|qr-frontend)'" 