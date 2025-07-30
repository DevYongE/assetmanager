#!/bin/bash

# SSL 인증서 설정 스크립트 - Rocky Linux용
# 작성일: 2024-12-19
# 설명: Rocky Linux에서 invenone.it.kr 도메인을 위한 SSL 인증서를 설정합니다.

set -e

echo "🔒 SSL 인증서 설정을 시작합니다 (Rocky Linux)..."

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

# Rocky Linux 확인
log_info "Rocky Linux 시스템을 확인합니다..."
if ! grep -q "Rocky Linux" /etc/os-release; then
    log_warning "이 스크립트는 Rocky Linux용입니다. 다른 시스템에서는 문제가 발생할 수 있습니다."
fi

# 도메인 설정
DOMAIN="invenone.it.kr"
SSL_DIR="/etc/letsencrypt/live/$DOMAIN"

# EPEL 저장소 활성화 (Rocky Linux용)
log_info "EPEL 저장소를 활성화합니다..."
sudo dnf install -y epel-release

# Certbot 설치 (Rocky Linux용)
log_info "Certbot을 설치합니다..."
sudo dnf install -y certbot python3-certbot-nginx

# Let's Encrypt 디렉토리 확인
log_info "Let's Encrypt 디렉토리를 확인합니다..."
sudo mkdir -p $SSL_DIR

# 기존 Let's Encrypt 인증서 확인
log_info "기존 Let's Encrypt 인증서를 확인합니다..."
if [ -f "$SSL_DIR/fullchain.pem" ] && [ -f "$SSL_DIR/privkey.pem" ]; then
    log_success "기존 Let's Encrypt 인증서가 발견되었습니다."
    echo "  - Certificate: $SSL_DIR/fullchain.pem"
    echo "  - Private Key: $SSL_DIR/privkey.pem"
    
    # 인증서 유효성 확인
    if openssl x509 -checkend 86400 -noout -in "$SSL_DIR/fullchain.pem" > /dev/null 2>&1; then
        log_success "SSL 인증서가 유효합니다."
    else
        log_warning "SSL 인증서가 만료되었거나 곧 만료됩니다."
    fi
else
    log_info "기존 Let's Encrypt 인증서가 없습니다. 새로 생성합니다."
fi

# Let's Encrypt 인증서 생성 (옵션 1)
log_info "Let's Encrypt 인증서를 생성합니다..."
echo ""
echo "🔧 SSL 인증서 생성 옵션:"
echo "1. Let's Encrypt (무료, 자동 갱신)"
echo "2. 기존 인증서 파일 사용"
echo "3. 수동 설정"
echo ""
read -p "선택하세요 (1-3): " ssl_choice

case $ssl_choice in
    1)
        log_info "Let's Encrypt 인증서를 생성합니다..."
        
        # Nginx 설정이 있는지 확인 (Rocky Linux용 경로)
        if [ ! -f "/etc/nginx/conf.d/$DOMAIN.conf" ]; then
            log_error "Nginx 설정 파일이 없습니다. 먼저 배포 스크립트를 실행하세요."
            exit 1
        fi
        
        # Certbot으로 인증서 생성
        sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
        
        if [ $? -eq 0 ]; then
            log_success "Let's Encrypt 인증서가 성공적으로 생성되었습니다!"
            
            # 자동 갱신 설정 (Rocky Linux용)
            log_info "자동 갱신을 설정합니다..."
            sudo crontab -l 2>/dev/null | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet"; } | sudo crontab -
            
            log_success "SSL 인증서 설정이 완료되었습니다!"
        else
            log_error "Let's Encrypt 인증서 생성에 실패했습니다."
            exit 1
        fi
        ;;
    2)
        log_info "기존 Let's Encrypt 인증서 파일을 사용합니다..."
        echo ""
        echo "📁 Let's Encrypt 인증서 파일을 다음 위치에 배치하세요:"
        echo "  - Certificate: $SSL_DIR/fullchain.pem"
        echo "  - Private Key: $SSL_DIR/privkey.pem"
        echo ""
        read -p "인증서 파일을 배치한 후 Enter를 누르세요..."
        
        if [ -f "$SSL_DIR/fullchain.pem" ] && [ -f "$SSL_DIR/privkey.pem" ]; then
            log_success "Let's Encrypt 인증서 파일이 확인되었습니다."
            
            # 파일 권한 설정
            sudo chmod 644 $SSL_DIR/fullchain.pem
            sudo chmod 600 $SSL_DIR/privkey.pem
            
            log_success "기존 Let's Encrypt SSL 인증서 설정이 완료되었습니다!"
        else
            log_error "Let's Encrypt 인증서 파일을 찾을 수 없습니다."
            exit 1
        fi
        ;;
    3)
        log_info "수동 설정을 선택했습니다..."
        echo ""
        echo "🔧 수동 Let's Encrypt SSL 설정 가이드 (Rocky Linux):"
        echo "1. Let's Encrypt 인증서 파일을 준비하세요:"
        echo "   - fullchain.pem (공개키)"
        echo "   - privkey.pem (개인키)"
        echo ""
        echo "2. 파일을 다음 위치에 복사하세요:"
        echo "   sudo cp fullchain.pem $SSL_DIR/"
        echo "   sudo cp privkey.pem $SSL_DIR/"
        echo ""
        echo "3. 파일 권한을 설정하세요:"
        echo "   sudo chmod 644 $SSL_DIR/fullchain.pem"
        echo "   sudo chmod 600 $SSL_DIR/privkey.pem"
        echo ""
        echo "4. Nginx 설정을 테스트하세요:"
        echo "   sudo nginx -t"
        echo ""
        echo "5. Nginx를 재시작하세요:"
        echo "   sudo systemctl restart nginx"
        echo ""
        log_warning "수동 설정을 완료한 후 스크립트를 다시 실행하세요."
        exit 0
        ;;
    *)
        log_error "잘못된 선택입니다."
        exit 1
        ;;
esac

# SSL 설정 확인
log_info "SSL 설정을 확인합니다..."

# 인증서 정보 확인
if [ -f "$SSL_DIR/fullchain.pem" ]; then
    log_info "Let's Encrypt SSL 인증서 정보:"
    openssl x509 -in "$SSL_DIR/fullchain.pem" -text -noout | grep -E "(Subject:|Not Before|Not After|DNS:)"
fi

# Nginx 설정 테스트
log_info "Nginx 설정을 테스트합니다..."
if sudo nginx -t; then
    log_success "Nginx 설정이 유효합니다."
else
    log_error "Nginx 설정에 오류가 있습니다."
    exit 1
fi

# Nginx 재시작
log_info "Nginx를 재시작합니다..."
sudo systemctl restart nginx

# SSL 연결 테스트
log_info "SSL 연결을 테스트합니다..."
if curl -s -I https://$DOMAIN > /dev/null 2>&1; then
    log_success "HTTPS 연결이 정상입니다."
else
    log_warning "HTTPS 연결에 문제가 있을 수 있습니다."
fi

# 상태 확인
echo ""
log_success "SSL 인증서 설정이 완료되었습니다!"
echo ""
echo "📊 Let's Encrypt SSL 상태:"
echo "  - Domain: $DOMAIN"
echo "  - Certificate: $SSL_DIR/fullchain.pem"
echo "  - Private Key: $SSL_DIR/privkey.pem"
echo "  - Nginx Status: $(sudo systemctl is-active nginx)"
echo ""
echo "🌐 접속 정보:"
echo "  - HTTPS: https://$DOMAIN"
echo "  - API: https://$DOMAIN/api"
echo "  - Health: https://$DOMAIN/health"
echo ""
echo "📝 유용한 명령어 (Rocky Linux용):"
echo "  - SSL 상태 확인: sudo certbot certificates"
echo "  - SSL 갱신: sudo certbot renew"
echo "  - Nginx 상태: sudo systemctl status nginx"
echo "  - SSL 연결 테스트: curl -I https://$DOMAIN"
echo "  - 방화벽 상태: sudo firewall-cmd --list-all"
echo ""
log_success "SSL 인증서 설정이 완료되었습니다! 🔒" 