#!/bin/bash

# PM2 관리 스크립트
# 작성일: 2024-12-19
# 설명: QR Asset Management 백엔드 프로세스를 PM2로 관리합니다.

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

# 함수: PM2 상태 확인
check_pm2_status() {
    log_info "PM2 프로세스 상태를 확인합니다..."
    pm2 status
}

# 함수: 백엔드 시작
start_backend() {
    log_info "백엔드를 시작합니다..."
    cd $BACKEND_DIR
    
    # 환경 변수 파일 확인
    if [ ! -f ".env" ]; then
        log_error ".env 파일이 없습니다. 환경 변수를 설정해주세요."
        exit 1
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

# 함수: 도움말 표시
show_help() {
    echo ""
    echo "🔧 QR Asset Management PM2 관리 스크립트"
    echo "작성일: 2024-12-19"
    echo ""
    echo "사용법: $0 [명령어]"
    echo ""
    echo "명령어:"
    echo "  status     - PM2 프로세스 상태 확인"
    echo "  start      - 백엔드 시작"
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
    echo "  help       - 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 logs"
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
    "help"|*)
        show_help
        ;;
esac 