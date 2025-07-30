#!/bin/bash

# 배포 상태 확인 스크립트 (수정된 버전)
# 작성일: 2024-12-19
# 설명: QR Asset Management의 전체 배포 상태를 확인합니다.
# - Supabase 연결 확인
# - 올바른 포트 설정 (백엔드: 4000, 프론트엔드: 3000)

set -e

echo "🔍 QR Asset Management 배포 상태를 확인합니다..."

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

# 함수: 시스템 정보 확인
check_system_info() {
    log_info "시스템 정보를 확인합니다..."
    echo "  - OS: $(lsb_release -d | cut -f2)"
    echo "  - Kernel: $(uname -r)"
    echo "  - CPU: $(nproc) cores"
    echo "  - Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "  - Disk: $(df -h / | tail -1 | awk '{print $4}') available"
}

# 함수: Nginx 상태 확인
check_nginx() {
    log_info "Nginx 상태를 확인합니다..."
    
    if systemctl is-active --quiet nginx; then
        log_success "Nginx가 실행 중입니다."
        echo "  - Status: $(systemctl is-active nginx)"
        echo "  - Enabled: $(systemctl is-enabled nginx)"
        
        # Nginx 설정 테스트
        if sudo nginx -t &> /dev/null; then
            log_success "Nginx 설정이 유효합니다."
        else
            log_error "Nginx 설정에 오류가 있습니다!"
        fi
        
        # 포트 확인
        if netstat -tlnp | grep -q ":80 "; then
            log_success "Nginx가 포트 80에서 실행 중입니다."
        else
            log_error "Nginx가 포트 80에서 실행되지 않습니다!"
        fi
    else
        log_error "Nginx가 실행되지 않습니다!"
    fi
}

# 함수: Supabase 연결 확인
check_supabase() {
    log_info "Supabase 연결을 확인합니다..."
    
    if [ ! -f "$BACKEND_DIR/.env" ]; then
        log_error ".env 파일이 없습니다!"
        return
    fi
    
    # 환경 변수 로드
    source "$BACKEND_DIR/.env"
    
    # Supabase 환경 변수 확인
    if [ -z "$SUPABASE_URL" ] || [ "$SUPABASE_URL" = "your_supabase_url_here" ]; then
        log_error "SUPABASE_URL이 설정되지 않았습니다!"
        return
    fi
    
    if [ -z "$SUPABASE_KEY" ] || [ "$SUPABASE_KEY" = "your_supabase_anon_key_here" ]; then
        log_error "SUPABASE_KEY가 설정되지 않았습니다!"
        return
    fi
    
    if [ -z "$SUPABASE_SERVICE_ROLE_KEY" ] || [ "$SUPABASE_SERVICE_ROLE_KEY" = "your_supabase_service_role_key_here" ]; then
        log_error "SUPABASE_SERVICE_ROLE_KEY가 설정되지 않았습니다!"
        return
    fi
    
    log_success "Supabase 환경 변수가 설정되어 있습니다."
    echo "  - SUPABASE_URL: ${SUPABASE_URL:0:30}..."
    echo "  - SUPABASE_KEY: ${SUPABASE_KEY:0:20}..."
    echo "  - SUPABASE_SERVICE_ROLE_KEY: ${SUPABASE_SERVICE_ROLE_KEY:0:20}..."
}

# 함수: PM2 상태 확인
check_pm2() {
    log_info "PM2 상태를 확인합니다..."
    
    if command -v pm2 &> /dev/null; then
        log_success "PM2가 설치되어 있습니다."
        
        # PM2 프로세스 확인
        if pm2 list | grep -q "qr-backend"; then
            log_success "백엔드 프로세스가 실행 중입니다."
            pm2 status
        else
            log_warning "백엔드 프로세스가 실행되지 않습니다."
        fi
    else
        log_error "PM2가 설치되지 않았습니다!"
    fi
}

# 함수: 백엔드 상태 확인 (포트 4000)
check_backend() {
    log_info "백엔드 상태를 확인합니다 (포트 4000)..."
    
    if [ -d "$BACKEND_DIR" ]; then
        log_success "백엔드 디렉토리가 존재합니다."
        
        # 의존성 확인
        if [ -d "$BACKEND_DIR/node_modules" ]; then
            log_success "백엔드 의존성이 설치되어 있습니다."
        else
            log_warning "백엔드 의존성이 설치되지 않았습니다."
        fi
        
        # 환경 변수 파일 확인
        if [ -f "$BACKEND_DIR/.env" ]; then
            log_success "환경 변수 파일이 존재합니다."
        else
            log_error "환경 변수 파일이 없습니다!"
        fi
        
        # API 연결 테스트 (포트 4000)
        if curl -s http://localhost:4000/api/health &> /dev/null; then
            log_success "백엔드 API가 응답합니다 (포트 4000)."
        else
            log_warning "백엔드 API가 응답하지 않습니다 (포트 4000)."
        fi
    else
        log_error "백엔드 디렉토리가 존재하지 않습니다!"
    fi
}

# 함수: 프론트엔드 상태 확인 (포트 3000)
check_frontend() {
    log_info "프론트엔드 상태를 확인합니다 (포트 3000)..."
    
    if [ -d "$FRONTEND_DIR" ]; then
        log_success "프론트엔드 디렉토리가 존재합니다."
        
        # 빌드 파일 확인
        if [ -d "$FRONTEND_DIR/.output" ]; then
            log_success "프론트엔드가 빌드되어 있습니다."
        else
            log_warning "프론트엔드가 빌드되지 않았습니다."
        fi
        
        # 의존성 확인
        if [ -d "$FRONTEND_DIR/node_modules" ]; then
            log_success "프론트엔드 의존성이 설치되어 있습니다."
        else
            log_warning "프론트엔드 의존성이 설치되지 않았습니다."
        fi
        
        # 웹 접속 테스트 (포트 3000)
        if curl -s http://localhost:3000 &> /dev/null; then
            log_success "프론트엔드가 접속 가능합니다 (포트 3000)."
        else
            log_warning "프론트엔드에 접속할 수 없습니다 (포트 3000)."
        fi
    else
        log_error "프론트엔드 디렉토리가 존재하지 않습니다!"
    fi
}

# 함수: 방화벽 상태 확인
check_firewall() {
    log_info "방화벽 상태를 확인합니다..."
    
    if ufw status | grep -q "Status: active"; then
        log_success "방화벽이 활성화되어 있습니다."
        echo "  - UFW Status: $(ufw status | grep Status)"
        
        # Nginx 포트 확인
        if ufw status | grep -q "Nginx Full"; then
            log_success "Nginx 방화벽 규칙이 설정되어 있습니다."
        else
            log_warning "Nginx 방화벽 규칙이 설정되지 않았습니다."
        fi
    else
        log_warning "방화벽이 비활성화되어 있습니다."
    fi
}

# 함수: 로그 확인
check_logs() {
    log_info "로그 파일 상태를 확인합니다..."
    
    # Nginx 로그
    if [ -f "/var/log/nginx/qr-asset-error.log" ]; then
        log_success "Nginx 에러 로그가 존재합니다."
        echo "  - Nginx Error Log: $(wc -l < /var/log/nginx/qr-asset-error.log) lines"
    else
        log_warning "Nginx 에러 로그가 없습니다."
    fi
    
    # PM2 로그
    if pm2 logs qr-backend --lines 1 &> /dev/null; then
        log_success "PM2 로그가 존재합니다."
    else
        log_warning "PM2 로그가 없습니다."
    fi
}

# 함수: 성능 확인
check_performance() {
    log_info "시스템 성능을 확인합니다..."
    
    # CPU 사용률
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "  - CPU Usage: ${CPU_USAGE}%"
    
    # 메모리 사용률
    MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
    echo "  - Memory Usage: ${MEMORY_USAGE}%"
    
    # 디스크 사용률
    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    echo "  - Disk Usage: ${DISK_USAGE}%"
    
    # 로드 평균
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | cut -d',' -f1)
    echo "  - Load Average: ${LOAD_AVG}"
}

# 함수: 포트 사용 확인
check_ports() {
    log_info "포트 사용 상태를 확인합니다..."
    
    # 포트 80 (Nginx)
    if netstat -tlnp | grep -q ":80 "; then
        log_success "포트 80이 사용 중입니다 (Nginx)."
    else
        log_warning "포트 80이 사용되지 않습니다."
    fi
    
    # 포트 3000 (프론트엔드)
    if netstat -tlnp | grep -q ":3000 "; then
        log_success "포트 3000이 사용 중입니다 (프론트엔드)."
    else
        log_warning "포트 3000이 사용되지 않습니다."
    fi
    
    # 포트 4000 (백엔드)
    if netstat -tlnp | grep -q ":4000 "; then
        log_success "포트 4000이 사용 중입니다 (백엔드)."
    else
        log_warning "포트 4000이 사용되지 않습니다."
    fi
}

# 메인 실행
echo ""
echo "=========================================="
echo "🔍 QR Asset Management 배포 상태 확인 (수정된 버전)"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

check_system_info
echo ""

check_nginx
echo ""

check_supabase
echo ""

check_pm2
echo ""

check_backend
echo ""

check_frontend
echo ""

check_firewall
echo ""

check_ports
echo ""

check_logs
echo ""

check_performance
echo ""

echo "=========================================="
echo "📊 요약"
echo "=========================================="
echo ""

# 전체 상태 요약
echo "✅ 정상 동작 중인 서비스:"
systemctl is-active nginx &> /dev/null && echo "  - Nginx"
pm2 list | grep -q "qr-backend" && echo "  - Backend (PM2)"

echo ""
echo "🌐 접속 정보:"
echo "  - Frontend: http://localhost"
echo "  - Backend API: http://localhost/api"
echo "  - Health Check: http://localhost/health"

echo ""
echo "⚠️  중요 사항:"
echo "  - Supabase 환경 변수가 설정되어 있는지 확인하세요"
echo "  - 백엔드 포트: 4000"
echo "  - 프론트엔드 포트: 3000"

echo ""
echo "📝 유용한 명령어:"
echo "  - 전체 상태 확인: $0"
echo "  - PM2 관리: ./pm2_management_corrected.sh [명령어]"
echo "  - 환경 변수 도움말: ./pm2_management_corrected.sh env-help"
echo "  - 배포: ./setup_nginx_pm2_corrected.sh"

echo ""
log_success "배포 상태 확인이 완료되었습니다! 🎉" 