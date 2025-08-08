#!/bin/bash

# =============================================================================
# QR 자산관리 시스템 Rocky Linux 배포 스크립트 (Supabase 기반)
# =============================================================================
#
# 이 스크립트는 Rocky Linux 서버에 QR 자산관리 시스템을 배포합니다.
# Supabase를 사용하는 Node.js 백엔드와 Nuxt.js 프론트엔드를 포함합니다.
#
# 작성일: 2025-01-27
# =============================================================================

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
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

log_info "🚀 QR 자산관리 시스템 Rocky Linux 배포 시작 (Supabase 기반)"

# =============================================================================
# 1. 시스템 업데이트 및 필수 패키지 설치
# =============================================================================
log_info "📦 시스템 업데이트 및 필수 패키지 설치 중..."

# 2025-08-08: Node.js 의존성 충돌 해결 (npm/nodejs 버전 충돌 방지)
log_info "🔧 Node.js 의존성 충돌 해결 중..."

# 기존 NodeSource 저장소 정리
if [ -f "/etc/yum.repos.d/nodesource-nsolid.repo" ]; then
    log_info "기존 Nsolid 저장소 비활성화..."
    sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/nodesource-nsolid.repo
fi

# 기존 Node.js 관련 패키지 제거
log_info "기존 Node.js 패키지 정리..."
sudo dnf remove -y nodejs npm 2>/dev/null || true

# DNF 캐시 정리
sudo dnf clean all

# 시스템 업데이트
sudo dnf update -y

# Node.js 18.x 설치 (안정적인 LTS 버전)
log_info "Node.js 18.x LTS 설치 중..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# Node.js 버전 확인
log_info "Node.js 설치 확인:"
node --version
npm --version

# Nginx 설치
sudo dnf install -y nginx

# PM2 글로벌 설치 (권한 문제 해결)
log_info "PM2 글로벌 설치 중..."
# 2025-08-08: npm 글로벌 패키지 권한 문제 해결 (sudo 없이 안전한 설치)
# 방법 1: npm 글로벌 디렉토리를 사용자 홈으로 변경
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# PATH에 npm 글로벌 디렉토리 추가
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# PM2 설치 (사용자 홈 디렉토리에 설치)
npm install -g pm2

# 설치 확인
log_info "PM2 설치 확인:"
pm2 --version

# =============================================================================
# 2. 프로젝트 디렉토리 설정
# =============================================================================
log_info "📁 프로젝트 디렉토리 설정 중..."

# 2025-08-08: 백업 타임스탬프를 변수로 고정하여 이후 참조 시 동일 값 사용
BACKUP_TS=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${PROJECT_DIR}_backup_${BACKUP_TS}"

# 기존 프로젝트 백업 (2025-08-08: 고정된 BACKUP_PATH 사용)
if [ -d "$PROJECT_DIR" ]; then
    log_warning "기존 프로젝트를 백업합니다... (백업 경로: $BACKUP_PATH)"
    sudo mv "$PROJECT_DIR" "$BACKUP_PATH"
fi

# 프로젝트 디렉토리 생성
sudo mkdir -p "$PROJECT_DIR"
sudo chown -R dmanager:dmanager "$PROJECT_DIR"

# =============================================================================
# 3. 프로젝트 파일 복사
# =============================================================================
log_info "📋 프로젝트 파일 복사 중..."

# 현재 스크립트가 있는 디렉토리에서 파일 복사
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo cp -r "$SCRIPT_DIR/backend" "$PROJECT_DIR/"
sudo cp -r "$SCRIPT_DIR/frontend" "$PROJECT_DIR/"
sudo chown -R dmanager:dmanager "$PROJECT_DIR"

# =============================================================================
# 4. 기존 .env 파일 확인 및 설정
# =============================================================================
log_info "🗄️ 환경변수 파일 확인 중..."

# 2025-08-08: 동일 타이밍의 백업 디렉토리를 참조하도록 수정 (BACKUP_PATH 재사용)
if [ -f "$BACKUP_PATH/backend/.env" ]; then
    log_info "기존 .env 파일을 복사합니다... (2025-08-08)"
    cp "$BACKUP_PATH/backend/.env" "$BACKEND_DIR/.env"
    log_success "기존 .env 파일 복사 완료"
else
    log_warning "기존 .env 파일이 없습니다. 새로 생성합니다..."
    
    # 백엔드 환경변수 파일 생성
    cat > "$BACKEND_DIR/.env" << 'EOF'
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url_here
# 2025-08-08: 변수명 정규화 (백엔드 코드와 일치)
SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# Server Configuration
PORT=4000
NODE_ENV=production

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_2025
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=https://your-domain.com
EOF

    log_warning "⚠️  Supabase 환경변수를 설정해주세요!"
    log_warning "   $BACKEND_DIR/.env 파일을 편집하여 다음을 설정하세요:"
    log_warning "   - SUPABASE_URL: Supabase 프로젝트 URL"
    # 2025-08-08: 안내 문구 수정
    log_warning "   - SUPABASE_ANON_KEY: Supabase anon key"
    log_warning "   - SUPABASE_SERVICE_ROLE_KEY: Supabase service role key"
    log_warning "   - JWT_SECRET: JWT 시크릿 키"
    log_warning "   - CORS_ORIGIN: 프론트엔드 도메인"

    # 사용자에게 환경변수 설정 요청
    read -p "Supabase 환경변수를 설정하셨나요? (y/N): " env_configured
    if [[ $env_configured != [yY] ]]; then
        log_error "환경변수 설정이 필요합니다. 스크립트를 중단합니다."
        exit 1
    fi
fi

# =============================================================================
# 5. 백엔드 설정
# =============================================================================
log_info "🔧 백엔드 설정 중..."

cd "$BACKEND_DIR"

# 의존성 설치
npm install

# 환경변수 파일 권한 설정
chmod 600 .env

# Supabase 마이그레이션 실행
log_info "Supabase 마이그레이션 실행 중..."
node run-migration.js

log_success "백엔드 설정 완료"

# =============================================================================
# 6. 프론트엔드 설정
# =============================================================================
log_info "🎨 프론트엔드 설정 중..."

cd "$FRONTEND_DIR"

# 의존성 설치
npm install

# 프로덕션 빌드
log_info "프론트엔드 빌드 중..."
npm run build:prod

log_success "프론트엔드 설정 완료"

# =============================================================================
# 7. PM2 설정 (수정된 버전)
# =============================================================================
log_info "⚡ PM2 설정 중..."

# PM2 경로 확인
PM2_PATH=$(which pm2)
if [ -z "$PM2_PATH" ]; then
    log_error "PM2가 설치되지 않았습니다. 다시 설치합니다..."
    npm install -g pm2
fi

# PM2 버전 확인
log_info "PM2 버전 확인:"
pm2 --version

# 백엔드 PM2 설정 (환경변수 파일 경로 지정)
cd "$BACKEND_DIR"
pm2 start index.js --name "assetmanager-backend" --env production

# 프론트엔드 PM2 설정 (정적 파일 서빙)
cd "$FRONTEND_DIR"
pm2 start "npx serve .output/public -p 3000" --name "assetmanager-frontend"

# PM2 설정 저장 및 자동 시작
pm2 save

# PM2 startup 설정 (사용자별)
log_info "PM2 startup 설정 중..."
pm2 startup
log_warning "위 명령어의 출력을 복사하여 실행하세요!"

log_success "PM2 설정 완료"

# =============================================================================
# 8. Nginx 설정
# =============================================================================
log_info "🌐 Nginx 설정 중..."

# 기존 Nginx 설정 백업
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Nginx 설정 파일 생성
sudo tee /etc/nginx/conf.d/assetmanager.conf > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;  # 모든 도메인 허용

    # 보안 헤더
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # 프론트엔드 (정적 파일)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # 정적 파일 캐싱
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # 백엔드 API
    location /api {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # API 요청 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 에러 페이지
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
EOF

# Nginx 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx
sudo systemctl enable nginx

log_success "Nginx 설정 완료"

# =============================================================================
# 9. 방화벽 설정
# =============================================================================
log_info "🔥 방화벽 설정 중..."

# 방화벽 활성화
sudo systemctl enable firewalld
sudo systemctl start firewalld

# 포트 허용
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=4000/tcp

# 방화벽 재시작
sudo firewall-cmd --reload

log_success "방화벽 설정 완료"

# =============================================================================
# 10. 백업 스크립트 생성
# =============================================================================
log_info "💾 백업 스크립트 생성 중..."

cat > /home/dmanager/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/dmanager/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# 애플리케이션 백업
tar -czf $BACKUP_DIR/app_backup_$DATE.tar.gz /home/dmanager/assetmanager

# 환경변수 백업
cp /home/dmanager/assetmanager/backend/.env $BACKUP_DIR/env_backup_$DATE

# 30일 이상 된 백업 삭제
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
find $BACKUP_DIR -name "env_backup_*" -mtime +30 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /home/dmanager/backup.sh

# 자동 백업 설정 (매일 새벽 2시)
echo "0 2 * * * /home/dmanager/backup.sh" | crontab -

log_success "백업 스크립트 생성 완료"

# =============================================================================
# 11. 모니터링 스크립트 생성
# =============================================================================
log_info "📊 모니터링 스크립트 생성 중..."

cat > /home/dmanager/monitor.sh << 'EOF'
#!/bin/bash
echo "=== QR 자산관리 시스템 상태 ==="
echo "시간: $(date)"
echo ""

echo "=== PM2 상태 ==="
pm2 status
echo ""

echo "=== Nginx 상태 ==="
sudo systemctl status nginx --no-pager -l
echo ""

echo "=== 포트 사용 현황 ==="
sudo netstat -tlnp | grep -E ':(80|3000|4000)'
echo ""

echo "=== 디스크 사용량 ==="
df -h
echo ""

echo "=== 메모리 사용량 ==="
free -h
echo ""

echo "=== 최근 로그 (마지막 10줄) ==="
echo "Nginx 에러 로그:"
sudo tail -10 /var/log/nginx/error.log
echo ""
echo "백엔드 로그:"
pm2 logs assetmanager-backend --lines 10
EOF

chmod +x /home/dmanager/monitor.sh

log_success "모니터링 스크립트 생성 완료"

# =============================================================================
# 12. 문제 해결 스크립트 생성
# =============================================================================
log_info "🛠️ 문제 해결 스크립트 생성 중..."

cat > /home/dmanager/troubleshoot.sh << 'EOF'
#!/bin/bash

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
echo "3. 방화벽 설정 확인"
echo "4. 포트 충돌 해결"
echo "5. 권한 문제 해결"
echo "6. Supabase 연결 확인"
echo "7. PM2 재설치"
echo "8. 전체 시스템 재시작"
echo "9. 종료"
echo ""

read -p "선택하세요 (1-9): " choice

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
    4)
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
    5)
        log_info "권한 문제 해결 중..."
        sudo chown -R dmanager:dmanager /home/dmanager/assetmanager
        sudo chmod -R 755 /home/dmanager/assetmanager
        chmod 600 /home/dmanager/assetmanager/backend/.env
        log_success "권한 설정 완료"
        ;;
    6)
        log_info "Supabase 연결 확인 중..."
        echo "환경변수 확인:"
        cat /home/dmanager/assetmanager/backend/.env | grep SUPABASE
        echo ""
        echo "백엔드 연결 테스트:"
        curl -s http://localhost:4000/api/health || echo "백엔드 연결 실패"
        ;;
    7)
        log_info "PM2 재설치 중..."
        npm uninstall -g pm2
        npm install -g pm2
        log_success "PM2 재설치 완료"
        ;;
    8)
        log_warning "전체 시스템 재시작을 진행합니다..."
        read -p "정말 재시작하시겠습니까? (y/N): " confirm
        if [[ $confirm == [yY] ]]; then
            sudo reboot
        else
            log_info "재시작이 취소되었습니다."
        fi
        ;;
    9)
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
EOF

chmod +x /home/dmanager/troubleshoot.sh

log_success "문제 해결 스크립트 생성 완료"

# =============================================================================
# 13. 배포 완료 확인
# =============================================================================
log_info "🔍 배포 완료 확인 중..."

# 서비스 상태 확인
sleep 5

echo ""
echo "=== 배포 완료 확인 ==="
echo ""

# PM2 상태 확인
echo "PM2 상태:"
pm2 status
echo ""

# Nginx 상태 확인
echo "Nginx 상태:"
sudo systemctl status nginx --no-pager -l
echo ""

# 포트 확인
echo "포트 사용 현황:"
sudo netstat -tlnp | grep -E ':(80|3000|4000)'
echo ""

log_success "🎉 QR 자산관리 시스템 배포 완료!"
echo ""
echo "=== 접속 정보 ==="
echo "웹사이트: http://$(hostname -I | awk '{print $1}')"
echo "API 엔드포인트: http://$(hostname -I | awk '{print $1}')/api"
echo ""
echo "=== 관리 명령어 ==="
echo "상태 확인: /home/dmanager/monitor.sh"
echo "백업 실행: /home/dmanager/backup.sh"
echo "문제 해결: /home/dmanager/troubleshoot.sh"
echo "PM2 재시작: pm2 restart all"
echo "Nginx 재시작: sudo systemctl restart nginx"
echo ""
echo "=== 로그 확인 ==="
echo "백엔드 로그: pm2 logs assetmanager-backend"
echo "프론트엔드 로그: pm2 logs assetmanager-frontend"
echo "Nginx 로그: sudo tail -f /var/log/nginx/access.log"
echo ""
echo "=== 중요 사항 ==="
echo "⚠️  Supabase 환경변수가 올바르게 설정되었는지 확인하세요!"
echo "⚠️  프론트엔드에서 API 호출이 정상적으로 작동하는지 확인하세요!"
echo "⚠️  PM2 startup 명령어를 실행하여 자동 시작을 설정하세요!"

# =============================================================================
# 14. Node.js 충돌 해결 스크립트 생성 (2025-08-08 추가)
# =============================================================================
log_info "🛠️ Node.js 충돌 해결 스크립트 생성 중..."

cat > /home/dmanager/fix_nodejs_conflict.sh << 'EOF'
#!/bin/bash

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

echo "🔧 Node.js 의존성 충돌 해결 도구"
echo "=================================="
echo ""

# 1. 현재 Node.js 상태 확인
log_info "1. 현재 Node.js 상태 확인 중..."

echo "=== 현재 Node.js 버전 ==="
node --version 2>/dev/null || echo "Node.js가 설치되지 않음"
npm --version 2>/dev/null || echo "npm이 설치되지 않음"
echo ""

echo "=== 설치된 Node.js 관련 패키지 ==="
rpm -qa | grep -i node
echo ""

echo "=== 활성화된 저장소 ==="
sudo dnf repolist | grep -i node
echo ""

# 2. 충돌 해결 옵션
echo "🔧 충돌 해결 옵션:"
echo "1. 완전한 Node.js 재설치 (권장)"
echo "2. Nsolid 저장소만 비활성화"
echo "3. 특정 버전 강제 설치"
echo "4. 저장소 정리만 수행"
echo "5. 종료"
echo ""

read -p "선택하세요 (1-5): " choice

case $choice in
    1)
        log_info "완전한 Node.js 재설치를 진행합니다..."
        
        # 기존 Node.js 관련 패키지 완전 제거
        log_info "기존 패키지 제거 중..."
        sudo dnf remove -y nodejs npm 2>/dev/null || true
        sudo dnf remove -y nsolid* 2>/dev/null || true
        
        # 저장소 정리
        log_info "저장소 정리 중..."
        sudo rm -f /etc/yum.repos.d/nodesource-nsolid.repo
        sudo rm -f /etc/yum.repos.d/nodesource.repo
        
        # DNF 캐시 정리
        sudo dnf clean all
        
        # Node.js 18.x LTS 설치
        log_info "Node.js 18.x LTS 설치 중..."
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo dnf install -y nodejs
        
        # 설치 확인
        log_info "설치 확인:"
        node --version
        npm --version
        
        log_success "Node.js 재설치 완료!"
        ;;
    2)
        log_info "Nsolid 저장소 비활성화 중..."
        
        if [ -f "/etc/yum.repos.d/nodesource-nsolid.repo" ]; then
            sudo sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/nodesource-nsolid.repo
            log_success "Nsolid 저장소 비활성화 완료"
        else
            log_warning "Nsolid 저장소 파일이 없습니다"
        fi
        
        # npm 재설치
        sudo dnf install -y npm
        log_success "npm 재설치 완료"
        ;;
    3)
        log_info "특정 버전 강제 설치 중..."
        
        # Node.js 16.x 설치 (npm 8.19.4와 호환)
        curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
        sudo dnf install -y nodejs-16.x
        
        log_success "Node.js 16.x 설치 완료"
        ;;
    4)
        log_info "저장소 정리만 수행 중..."
        
        # 불필요한 저장소 제거
        sudo rm -f /etc/yum.repos.d/nodesource-nsolid.repo
        
        # DNF 캐시 정리
        sudo dnf clean all
        
        log_success "저장소 정리 완료"
        ;;
    5)
        log_info "종료합니다."
        exit 0
        ;;
    *)
        log_error "잘못된 선택입니다."
        exit 1
        ;;
esac

echo ""
log_success "Node.js 충돌 해결 완료!"
echo "재배포를 위해 다음 명령어를 실행하세요:"
echo "cd /home/dmanager && ./deploy_rocky_linux.sh"
EOF

chmod +x /home/dmanager/fix_nodejs_conflict.sh

log_success "Node.js 충돌 해결 스크립트 생성 완료"

# =============================================================================
# 15. PM2 권한 문제 해결 스크립트 생성 (2025-08-08 추가)
# =============================================================================
log_info "🛠️ PM2 권한 문제 해결 스크립트 생성 중..."

cat > /home/dmanager/fix_pm2_permissions.sh << 'EOF'
#!/bin/bash

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

echo "🔧 PM2 권한 문제 해결 도구"
echo "============================"
echo ""

# 1. 현재 PM2 상태 확인
log_info "1. 현재 PM2 상태 확인 중..."

echo "=== PM2 설치 상태 ==="
which pm2 2>/dev/null && echo "PM2 경로: $(which pm2)" || echo "PM2가 설치되지 않음"
pm2 --version 2>/dev/null || echo "PM2 버전 확인 실패"
echo ""

echo "=== npm 글로벌 디렉토리 ==="
npm config get prefix
echo ""

echo "=== 현재 사용자 ==="
whoami
echo ""

echo "=== npm 글로벌 디렉토리 권한 ==="
ls -la $(npm config get prefix) 2>/dev/null || echo "npm 글로벌 디렉토리 확인 실패"
echo ""

# 2. 권한 문제 해결 옵션
echo "🔧 권한 문제 해결 옵션:"
echo "1. 사용자 홈 디렉토리에 PM2 설치 (권장)"
echo "2. npm 글로벌 디렉토리 권한 수정"
echo "3. sudo로 PM2 설치 (임시 해결책)"
echo "4. PM2 완전 제거 후 재설치"
echo "5. 종료"
echo ""

read -p "선택하세요 (1-5): " choice

case $choice in
    1)
        log_info "사용자 홈 디렉토리에 PM2 설치를 진행합니다..."
        
        # npm 글로벌 디렉토리를 사용자 홈으로 변경
        log_info "npm 글로벌 디렉토리 설정 중..."
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'
        
        # PATH에 npm 글로벌 디렉토리 추가
        log_info "PATH 설정 중..."
        echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
        source ~/.bashrc
        
        # 기존 PM2 제거 (있다면)
        log_info "기존 PM2 제거 중..."
        npm uninstall -g pm2 2>/dev/null || true
        
        # PM2 설치
        log_info "PM2 설치 중..."
        npm install -g pm2
        
        # 설치 확인
        log_info "설치 확인:"
        pm2 --version
        
        log_success "PM2 설치 완료!"
        ;;
    2)
        log_info "npm 글로벌 디렉토리 권한 수정 중..."
        
        # npm 글로벌 디렉토리 소유권 변경
        NPM_PREFIX=$(npm config get prefix)
        log_info "npm 글로벌 디렉토리: $NPM_PREFIX"
        
        if [ -d "$NPM_PREFIX" ]; then
            sudo chown -R $(whoami):$(whoami) "$NPM_PREFIX"
            log_success "권한 수정 완료"
            
            # PM2 재설치
            npm install -g pm2
            log_success "PM2 재설치 완료"
        else
            log_error "npm 글로벌 디렉토리를 찾을 수 없습니다"
        fi
        ;;
    3)
        log_warning "sudo로 PM2 설치 (임시 해결책)..."
        
        # sudo로 PM2 설치
        sudo npm install -g pm2
        
        log_success "PM2 설치 완료 (sudo 사용)"
        log_warning "⚠️  보안상 권장하지 않습니다. 나중에 권한 문제를 해결하세요."
        ;;
    4)
        log_info "PM2 완전 제거 후 재설치 중..."
        
        # PM2 완전 제거
        log_info "기존 PM2 제거 중..."
        sudo npm uninstall -g pm2 2>/dev/null || true
        npm uninstall -g pm2 2>/dev/null || true
        
        # PM2 관련 파일 정리
        rm -rf ~/.pm2 2>/dev/null || true
        sudo rm -rf /root/.pm2 2>/dev/null || true
        
        # npm 글로벌 디렉토리 정리
        log_info "npm 글로벌 디렉토리 정리 중..."
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'
        
        # PATH 설정
        echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
        source ~/.bashrc
        
        # PM2 재설치
        log_info "PM2 재설치 중..."
        npm install -g pm2
        
        # 설치 확인
        pm2 --version
        
        log_success "PM2 완전 재설치 완료!"
        ;;
    5)
        log_info "종료합니다."
        exit 0
        ;;
    *)
        log_error "잘못된 선택입니다."
        exit 1
        ;;
esac

echo ""
log_success "PM2 권한 문제 해결 완료!"
echo "재배포를 위해 다음 명령어를 실행하세요:"
echo "cd /home/dmanager && ./deploy_rocky_linux.sh"
EOF

chmod +x /home/dmanager/fix_pm2_permissions.sh

log_success "PM2 권한 문제 해결 스크립트 생성 완료" 