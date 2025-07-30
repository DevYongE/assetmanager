#!/bin/bash

# PM2 관리 스크립트 (수정된 버전)
# 작성일: 2024-12-19
# 설명: QR Asset Management 백엔드 프로세스를 PM2로 관리합니다.
# - Supabase 환경 변수 확인
# - 올바른 포트 설정 (4000)

set -e

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

# 함수: Supabase 환경 변수 확인
check_supabase_env() {
    log_info "Supabase 환경 변수를 확인합니다..."
    
    if [ ! -f "$BACKEND_DIR/.env" ]; then
        log_error ".env 파일이 없습니다!"
        return 1
    fi
    
    # 환경 변수 확인
    source "$BACKEND_DIR/.env"
    
    if [ -z "$SUPABASE_URL" ] || [ "$SUPABASE_URL" = "your_supabase_url_here" ]; then
        log_error "SUPABASE_URL이 설정되지 않았습니다!"
        return 1
    fi
    
    if [ -z "$SUPABASE_KEY" ] || [ "$SUPABASE_KEY" = "your_supabase_anon_key_here" ]; then
        log_error "SUPABASE_KEY가 설정되지 않았습니다!"
        return 1
    fi
    
    if [ -z "$SUPABASE_SERVICE_ROLE_KEY" ] || [ "$SUPABASE_SERVICE_ROLE_KEY" = "your_supabase_service_role_key_here" ]; then
        log_error "SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았습니다!"
        return 1
    fi
    
    log_success "Supabase 환경 변수가 올바르게 설정되어 있습니다."
    return 0
}

# 함수: PM2 상태 확인
check_pm2_status() {
    log_info "PM2 프로세스 상태를 확인합니다..."
    pm2 status
}

# 함수: 백엔드 시작
start_backend() {
    log_info "백엔드를 시작합니다..."
    cd $BACKEND_DIR
    
    # Supabase 환경 변수 확인
    if ! check_supabase_env; then
        log_error "Supabase 환경 변수를 먼저 설정해주세요!"
        echo ""
        echo "📝 .env 파일 예시:"
        echo "SUPABASE_URL=https://your-project.supabase.co"
        echo "SUPABASE_KEY=your_anon_key"
        echo "SUPABASE_SERVICE_ROLE_KEY=your_service_role_key"
        echo "PORT=4000"
        echo "NODE_ENV=production"
        echo "JWT_SECRET=your_jwt_secret"
        return 1
    fi
    
    # 의존성 설치 확인
    if [ ! -d "node_modules" ]; then
        log_info "의존성을 설치합니다..."
        npm install
    fi
    
    # PM2로 백엔드 시작
    pm2 start index.js --name "qr-backend" --env production
    
    log_success "백엔드가 시작되었습니다!"
    pm2 status
}

# 함수: 백엔드 중지
stop_backend() {
    log_info "백엔드를 중지합니다..."
    pm2 stop qr-backend
    log_success "백엔드가 중지되었습니다!"
}

# 함수: 백엔드 재시작
restart_backend() {
    log_info "백엔드를 재시작합니다..."
    pm2 restart qr-backend
    log_success "백엔드가 재시작되었습니다!"
}

# 함수: 백엔드 삭제
delete_backend() {
    log_info "백엔드 프로세스를 삭제합니다..."
    pm2 delete qr-backend
    log_success "백엔드 프로세스가 삭제되었습니다!"
}

# 함수: 로그 확인
show_logs() {
    log_info "백엔드 로그를 확인합니다..."
    pm2 logs qr-backend --lines 50
}

# 함수: 실시간 로그 모니터링
monitor_logs() {
    log_info "실시간 로그 모니터링을 시작합니다... (Ctrl+C로 종료)"
    pm2 logs qr-backend --lines 0
}

# 함수: PM2 설정 저장
save_pm2() {
    log_info "PM2 설정을 저장합니다..."
    pm2 save
    log_success "PM2 설정이 저장되었습니다!"
}

# 함수: PM2 자동 시작 설정
setup_pm2_startup() {
    log_info "PM2 자동 시작을 설정합니다..."
    pm2 startup
    log_success "PM2 자동 시작이 설정되었습니다!"
}

# 함수: 메모리 및 CPU 사용량 확인
show_resources() {
    log_info "리소스 사용량을 확인합니다..."
    pm2 monit
}

# 함수: 프로세스 정보 확인
show_info() {
    log_info "프로세스 정보를 확인합니다..."
    pm2 show qr-backend
}

# 함수: 전체 PM2 프로세스 정리
cleanup_pm2() {
    log_warning "모든 PM2 프로세스를 정리합니다..."
    pm2 delete all
    log_success "모든 PM2 프로세스가 정리되었습니다!"
}

# 함수: 환경 변수 설정 도움말
show_env_help() {
    echo ""
    echo "🔧 Supabase 환경 변수 설정 가이드"
    echo "작성일: 2024-12-19"
    echo ""
    echo "1. Supabase 프로젝트에서 다음 정보를 가져오세요:"
    echo "   - Project URL"
    echo "   - anon/public key"
    echo "   - service_role key"
    echo ""
    echo "2. 백엔드 .env 파일을 다음과 같이 설정하세요:"
    echo ""
    echo "SUPABASE_URL=https://your-project.supabase.co"
    echo "SUPABASE_KEY=your_anon_key_here"
    echo "SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here"
    echo "PORT=4000"
    echo "NODE_ENV=production"
    echo "JWT_SECRET=your_jwt_secret_key_2024"
    echo "JWT_EXPIRES_IN=24h"
    echo ""
    echo "3. 설정 후 백엔드를 재시작하세요:"
    echo "   ./pm2_management_corrected.sh restart"
    echo ""
}

# 함수: 도움말 표시
show_help() {
    echo ""
    echo "🔧 QR Asset Management PM2 관리 스크립트 (수정된 버전)"
    echo "작성일: 2024-12-19"
    echo ""
    echo "사용법: $0 [명령어]"
    echo ""
    echo "명령어:"
    echo "  status     - PM2 프로세스 상태 확인"
    echo "  start      - 백엔드 시작 (환경 변수 확인 포함)"
    echo "  stop       - 백엔드 중지"
    echo "  restart    - 백엔드 재시작"
    echo "  delete     - 백엔드 프로세스 삭제"
    echo "  logs       - 백엔드 로그 확인"
    echo "  monitor    - 실시간 로그 모니터링"
    echo "  save       - PM2 설정 저장"
    echo "  startup    - PM2 자동 시작 설정"
    echo "  resources  - 리소스 사용량 확인"
    echo "  info       - 프로세스 정보 확인"
    echo "  cleanup    - 모든 PM2 프로세스 정리"
    echo "  env-help   - 환경 변수 설정 도움말"
    echo "  help       - 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 logs"
    echo "  $0 env-help"
    echo ""
}

# 메인 로직
case "${1:-help}" in
    "status")
        check_pm2_status
        ;;
    "start")
        start_backend
        ;;
    "stop")
        stop_backend
        ;;
    "restart")
        restart_backend
        ;;
    "delete")
        delete_backend
        ;;
    "logs")
        show_logs
        ;;
    "monitor")
        monitor_logs
        ;;
    "save")
        save_pm2
        ;;
    "startup")
        setup_pm2_startup
        ;;
    "resources")
        show_resources
        ;;
    "info")
        show_info
        ;;
    "cleanup")
        cleanup_pm2
        ;;
    "env-help")
        show_env_help
        ;;
    "help"|*)
        show_help
        ;;
esac 