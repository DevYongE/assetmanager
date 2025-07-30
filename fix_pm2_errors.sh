#!/bin/bash

# PM2 프로세스 오류 해결 스크립트 (NCP Rocky Linux용)
# 작성일: 2024-12-19
# 설명: 모든 PM2 프로세스의 오류를 진단하고 수정합니다.

set -e

echo "🔧 PM2 프로세스 오류를 해결합니다..."

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

# 프로젝트 디렉토리 설정
PROJECT_DIR="/var/www/qr-asset-management"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

echo "=========================================="
echo "🔧 PM2 프로세스 오류 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 1. 현재 PM2 상태 확인
log_info "1. 현재 PM2 상태를 확인합니다..."
pm2 status

# 2. 각 프로세스의 상세 로그 확인
log_info "2. 각 프로세스의 상세 로그를 확인합니다..."

echo "=== backend 프로세스 로그 ==="
pm2 logs backend --err --lines 10 2>/dev/null || echo "backend 로그가 없습니다."

echo ""
echo "=== frontend 프로세스 로그 ==="
pm2 logs frontend --err --lines 10 2>/dev/null || echo "frontend 로그가 없습니다."

echo ""
echo "=== qr-backend 프로세스 로그 ==="
pm2 logs qr-backend --err --lines 10 2>/dev/null || echo "qr-backend 로그가 없습니다."

# 3. 프로젝트 파일 확인
log_info "3. 프로젝트 파일을 확인합니다..."

# 백엔드 파일 확인
if [ -d "$BACKEND_DIR" ]; then
    echo "=== 백엔드 파일 확인 ==="
    echo "  - 디렉토리: $BACKEND_DIR"
    echo "  - package.json: $([ -f "$BACKEND_DIR/package.json" ] && echo '존재' || echo '없음')"
    echo "  - index.js: $([ -f "$BACKEND_DIR/index.js" ] && echo '존재' || echo '없음')"
    echo "  - .env: $([ -f "$BACKEND_DIR/.env" ] && echo '존재' || echo '없음')"
    
    if [ -f "$BACKEND_DIR/package.json" ]; then
        echo "  - package.json 내용:"
        cat "$BACKEND_DIR/package.json" | head -10
    fi
else
    log_error "백엔드 디렉토리가 존재하지 않습니다!"
fi

# 프론트엔드 파일 확인
if [ -d "$FRONTEND_DIR" ]; then
    echo ""
    echo "=== 프론트엔드 파일 확인 ==="
    echo "  - 디렉토리: $FRONTEND_DIR"
    echo "  - package.json: $([ -f "$FRONTEND_DIR/package.json" ] && echo '존재' || echo '없음')"
    echo "  - nuxt.config.ts: $([ -f "$FRONTEND_DIR/nuxt.config.ts" ] && echo '존재' || echo '없음')"
    
    if [ -f "$FRONTEND_DIR/package.json" ]; then
        echo "  - package.json 내용:"
        cat "$FRONTEND_DIR/package.json" | head -10
    fi
else
    log_error "프론트엔드 디렉토리가 존재하지 않습니다!"
fi

# 4. Node.js 버전 확인
log_info "4. Node.js 버전을 확인합니다..."
node --version
npm --version

# 5. 의존성 확인 및 설치
log_info "5. 의존성을 확인하고 설치합니다..."

# 백엔드 의존성
if [ -d "$BACKEND_DIR" ]; then
    echo "=== 백엔드 의존성 확인 ==="
    if [ -d "$BACKEND_DIR/node_modules" ]; then
        log_success "백엔드 node_modules가 존재합니다."
    else
        log_warning "백엔드 node_modules가 없습니다. 설치합니다..."
        cd "$BACKEND_DIR"
        npm install
    fi
fi

# 프론트엔드 의존성
if [ -d "$FRONTEND_DIR" ]; then
    echo ""
    echo "=== 프론트엔드 의존성 확인 ==="
    if [ -d "$FRONTEND_DIR/node_modules" ]; then
        log_success "프론트엔드 node_modules가 존재합니다."
    else
        log_warning "프론트엔드 node_modules가 없습니다. 설치합니다..."
        cd "$FRONTEND_DIR"
        npm install
    fi
fi

# 6. 기존 PM2 프로세스 정리
log_info "6. 기존 PM2 프로세스를 정리합니다..."
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

# 7. 백엔드 직접 실행 테스트
log_info "7. 백엔드를 직접 실행해봅니다..."
if [ -d "$BACKEND_DIR" ]; then
    cd "$BACKEND_DIR"
    
    # 환경 변수 확인
    if [ -f ".env" ]; then
        log_success ".env 파일이 존재합니다."
        echo "  - 환경 변수 내용:"
        grep -E "^(PORT|NODE_ENV|SUPABASE|JWT)" .env || echo "  - 주요 환경 변수가 없습니다."
    else
        log_error ".env 파일이 없습니다!"
    fi
    
    # 백엔드 직접 실행 테스트
    log_info "백엔드를 직접 실행해봅니다..."
    timeout 15s node index.js || {
        log_error "백엔드 직접 실행에 실패했습니다!"
        echo "  - 오류 로그:"
        node index.js 2>&1 | head -10
    }
else
    log_error "백엔드 디렉토리가 존재하지 않습니다!"
fi

# 8. PM2 설정 파일 생성
log_info "8. PM2 설정 파일을 생성합니다..."

# 백엔드 PM2 설정
cd "$BACKEND_DIR"
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'qr-backend',
    script: 'index.js',
    cwd: '/var/www/qr-asset-management/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      NODE_ENV: 'production',
      PORT: 4000
    },
    error_file: '/var/log/pm2/qr-backend-error.log',
    out_file: '/var/log/pm2/qr-backend-out.log',
    log_file: '/var/log/pm2/qr-backend-combined.log',
    time: true,
    min_uptime: '10s',
    max_restarts: 10
  }]
}
EOF

# 9. 로그 디렉토리 생성
log_info "9. 로그 디렉토리를 생성합니다..."
sudo mkdir -p /var/log/pm2
sudo chown -R $USER:$USER /var/log/pm2

# 10. 백엔드 시작
log_info "10. 백엔드를 PM2로 시작합니다..."
cd "$BACKEND_DIR"
pm2 start ecosystem.config.js

# 11. 백엔드 상태 확인
log_info "11. 백엔드 상태를 확인합니다..."
sleep 5
pm2 status

# 백엔드 연결 테스트
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "백엔드 API가 정상적으로 응답합니다!"
else
    log_error "백엔드 API가 응답하지 않습니다!"
    echo "  - 백엔드 로그:"
    pm2 logs qr-backend --lines 5
fi

# 12. 프론트엔드 설정 (선택적)
log_info "12. 프론트엔드 설정을 확인합니다..."
if [ -d "$FRONTEND_DIR" ]; then
    cd "$FRONTEND_DIR"
    
    # 프론트엔드 빌드 확인
    if [ -d ".output" ]; then
        log_success "프론트엔드가 빌드되어 있습니다."
    else
        log_warning "프론트엔드가 빌드되지 않았습니다."
        echo "  - 프론트엔드 빌드를 시작합니다..."
        npm run build
    fi
    
    # 프론트엔드 PM2 설정 (선택적)
    echo ""
    echo "프론트엔드를 PM2로 시작하시겠습니까? (y/n)"
    read -p "선택: " start_frontend
    
    if [ "$start_frontend" = "y" ]; then
        log_info "프론트엔드를 PM2로 시작합니다..."
        
        # 프론트엔드 PM2 설정
        cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'qr-frontend',
    script: 'node',
    args: '.output/server/index.mjs',
    cwd: '/var/www/qr-asset-management/frontend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '512M',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/log/pm2/qr-frontend-error.log',
    out_file: '/var/log/pm2/qr-frontend-out.log',
    log_file: '/var/log/pm2/qr-frontend-combined.log',
    time: true
  }]
}
EOF
        
        pm2 start ecosystem.config.js
        sleep 3
        pm2 status
    fi
fi

# 13. 최종 상태 확인
log_info "13. 최종 상태를 확인합니다..."
echo ""
echo "=== 최종 PM2 상태 ==="
pm2 status

echo ""
echo "=== 포트 사용 상태 ==="
echo "  - 포트 3000 (프론트엔드): $(ss -tlnp | grep ':3000 ' || echo '사용되지 않음')"
echo "  - 포트 4000 (백엔드): $(ss -tlnp | grep ':4000 ' || echo '사용되지 않음')"

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "백엔드 연결: 정상"
else
    log_error "백엔드 연결: 실패"
fi

if curl -s http://localhost:3000 &> /dev/null; then
    log_success "프론트엔드 연결: 정상"
else
    log_warning "프론트엔드 연결: 실패"
fi

echo ""
echo "=========================================="
echo "🔧 PM2 프로세스 오류 해결 완료!"
echo "=========================================="
echo ""

# 성공한 프로세스 확인
SUCCESS_COUNT=0
if pm2 list | grep -q "qr-backend.*online"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi
if pm2 list | grep -q "qr-frontend.*online"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi

if [ $SUCCESS_COUNT -gt 0 ]; then
    log_success "일부 프로세스가 정상적으로 실행 중입니다!"
    echo "  - 성공한 프로세스: $SUCCESS_COUNT개"
    echo "  - Frontend: http://invenone.it.kr"
    echo "  - Backend API: http://invenone.it.kr/api"
else
    log_warning "모든 프로세스에 문제가 있을 수 있습니다."
    echo "  - 추가 진단이 필요합니다."
fi

echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - 백엔드 재시작: pm2 restart qr-backend"
echo "  - 전체 재시작: pm2 restart all"

echo ""
log_success "PM2 프로세스 오류 해결이 완료되었습니다! 🎉" 