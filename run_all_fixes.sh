#!/bin/bash

# 모든 수정 스크립트 통합 실행 (NCP Rocky Linux용)
# 작성일: 2024-12-19
# 설명: 모든 문제 해결 스크립트를 순서대로 실행합니다.

set -e

echo "🚀 모든 수정 스크립트를 순서대로 실행합니다..."

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
echo "🚀 통합 문제 해결 스크립트"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 스크립트 실행 함수
run_script() {
    local script_name=$1
    local description=$2
    
    echo ""
    log_info "실행 중: $script_name"
    log_info "설명: $description"
    echo "=========================================="
    
    if [ -f "$script_name" ]; then
        chmod +x "$script_name"
        if ./"$script_name"; then
            log_success "$script_name 실행 완료"
        else
            log_error "$script_name 실행 실패"
            echo "계속 진행하시겠습니까? (y/n)"
            read -p "선택: " continue_choice
            if [ "$continue_choice" != "y" ]; then
                exit 1
            fi
        fi
    else
        log_error "$script_name 파일이 없습니다!"
        echo "계속 진행하시겠습니까? (y/n)"
        read -p "선택: " continue_choice
        if [ "$continue_choice" != "y" ]; then
            exit 1
        fi
    fi
    
    echo ""
    echo "다음 스크립트로 진행하시겠습니까? (y/n)"
    read -p "선택: " next_choice
    if [ "$next_choice" != "y" ]; then
        log_info "사용자가 중단했습니다."
        exit 0
    fi
}

# 1단계: 문제 진단
run_script "diagnose_502_ncp.sh" "502 오류 진단 및 문제점 파악"

# 2단계: 포트 충돌 해결
run_script "fix_port_conflict.sh" "포트 80, 443 충돌 문제 해결"

# 3단계: Nginx 오류 해결
run_script "fix_nginx_error.sh" "Nginx 서비스 시작 실패 해결"

# 4단계: 백엔드 크래시 해결
run_script "fix_backend_crash.sh" "백엔드 크래시 문제 해결"

# 5단계: PM2 프로세스 오류 해결
run_script "fix_pm2_errors.sh" "PM2 프로세스 오류 해결"

# 6단계: 프론트엔드 빌드 해결
run_script "fix_frontend_build_local.sh" "프론트엔드 빌드 문제 해결"

# 7단계: Nuxt 빌드 문제 해결 (필요시)
run_script "fix_nuxt_build_issue.sh" "Nuxt 빌드 문제 진단 및 해결"

# 8단계: 최종 상태 확인
run_script "check_deployment_ncp_rocky.sh" "전체 배포 상태 확인"

echo ""
echo "=========================================="
echo "🎉 모든 수정 스크립트 실행 완료!"
echo "=========================================="
echo ""

log_success "모든 문제 해결 스크립트가 완료되었습니다!"
echo ""
echo "📊 최종 상태:"
echo "  - Nginx: $(systemctl is-active nginx 2>/dev/null || echo '알 수 없음')"
echo "  - PM2 Backend: $(pm2 list | grep qr-backend | awk '{print $10}' 2>/dev/null || echo '알 수 없음')"
echo "  - 포트 80: $(ss -tlnp | grep ':80 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 443: $(ss -tlnp | grep ':443 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 4000: $(ss -tlnp | grep ':4000 ' >/dev/null && echo '사용 중' || echo '사용 안 함')"

echo ""
echo "🌐 접속 정보:"
echo "  - Frontend: http://invenone.it.kr"
echo "  - Backend API: http://invenone.it.kr/api"
echo "  - Health Check: http://invenone.it.kr/health"

echo ""
echo "📝 추가 작업:"
echo "  - SSL 인증서 설정: ./setup_ssl_rocky.sh"
echo "  - 전체 재배포: ./setup_nginx_pm2_ncp_rocky.sh"
echo "  - PM2 관리: ./pm2_management_corrected.sh"

echo ""
log_success "통합 문제 해결이 완료되었습니다! 🎉" 