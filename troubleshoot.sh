#!/bin/bash

# =============================================================================
# QR 자산관리 시스템 문제 해결 스크립트
# =============================================================================
#
# 이 스크립트는 배포 후 발생할 수 있는 문제들을 해결합니다.
#
# 작성일: 2025-01-27
# =============================================================================

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

# 변수 설정
PROJECT_DIR="/home/dmanager/assetmanager"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/frontend"

echo "🔧 QR 자산관리 시스템 문제 해결 도구"
echo "=================================="
echo ""

# 1. 시스템 상태 확인
log_info "1. 시스템 상태 확인 중..."

echo "=== PM2 상태 ==="
pm2 status
echo ""

echo "=== Nginx 상태 ==="
sudo systemctl status nginx --no-pager -l
echo ""

echo "=== MySQL 상태 ==="
sudo systemctl status mysqld --no-pager -l
echo ""

echo "=== 포트 사용 현황 ==="
sudo netstat -tlnp | grep -E ':(80|3000|4000)'
echo ""

# 2. 로그 확인
log_info "2. 로그 확인 중..."

echo "=== Nginx 에러 로그 (마지막 20줄) ==="
sudo tail -20 /var/log/nginx/error.log
echo ""

echo "=== 백엔드 로그 (마지막 20줄) ==="
pm2 logs assetmanager-backend --lines 20
echo ""

echo "=== 프론트엔드 로그 (마지막 20줄) ==="
pm2 logs assetmanager-frontend --lines 20
echo ""

# 3. 문제 해결 옵션
echo "🔧 문제 해결 옵션:"
echo "1. PM2 프로세스 재시작"
echo "2. Nginx 재시작"
echo "3. MySQL 재시작"
echo "4. 방화벽 설정 확인"
echo "5. 포트 충돌 해결"
echo "6. 권한 문제 해결"
echo "7. 전체 시스템 재시작"
echo "8. 종료"
echo ""

read -p "선택하세요 (1-8): " choice

case $choice in
    1)
        log_info "PM2 프로세스 재시작 중..."
        pm2 restart all
        pm2 save
        log_success "PM2 재시작 완료"
        ;;
    2)
        log_info "Nginx 재시작 중..."
        sudo systemctl restart nginx
        sudo systemctl status nginx
        log_success "Nginx 재시작 완료"
        ;;
    3)
        log_info "MySQL 재시작 중..."
        sudo systemctl restart mysqld
        sudo systemctl status mysqld
        log_success "MySQL 재시작 완료"
        ;;
    4)
        log_info "방화벽 설정 확인 중..."
        sudo firewall-cmd --list-all
        echo ""
        echo "방화벽 포트 추가:"
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --permanent --add-port=3000/tcp
        sudo firewall-cmd --permanent --add-port=4000/tcp
        sudo firewall-cmd --reload
        log_success "방화벽 설정 완료"
        ;;
    5)
        log_info "포트 충돌 해결 중..."
        echo "포트 3000 사용 프로세스:"
        sudo lsof -i :3000
        echo ""
        echo "포트 4000 사용 프로세스:"
        sudo lsof -i :4000
        echo ""
        echo "포트 80 사용 프로세스:"
        sudo lsof -i :80
        echo ""
        log_warning "충돌하는 프로세스를 수동으로 종료하세요"
        ;;
    6)
        log_info "권한 문제 해결 중..."
        sudo chown -R dmanager:dmanager "$PROJECT_DIR"
        sudo chmod -R 755 "$PROJECT_DIR"
        sudo chown -R dmanager:dmanager /home/dmanager
        log_success "권한 설정 완료"
        ;;
    7)
        log_warning "전체 시스템 재시작을 진행합니다..."
        read -p "정말 재시작하시겠습니까? (y/N): " confirm
        if [[ $confirm == [yY] ]]; then
            sudo reboot
        else
            log_info "재시작이 취소되었습니다."
        fi
        ;;
    8)
        log_info "종료합니다."
        exit 0
        ;;
    *)
        log_error "잘못된 선택입니다."
        exit 1
        ;;
esac

echo ""
log_success "문제 해결 완료!"
echo "상태를 다시 확인하려면: /home/dmanager/monitor.sh" 