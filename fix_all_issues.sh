#!/bin/bash

# 모든 문제 종합 해결 스크립트 (2024-12-19)
# 설명: 포트 충돌, 프론트엔드 오류, Nginx 설정 문제를 모두 해결합니다.

set -e

echo "🔧 모든 문제를 종합적으로 해결합니다..."

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
echo "🔧 모든 문제 종합 해결"
echo "작성일: 2024-12-19"
echo "=========================================="
echo ""

# 프로젝트 디렉토리 설정
CURRENT_DIR=$(pwd)
FRONTEND_DIR="$CURRENT_DIR/frontend"
BACKEND_DIR="$CURRENT_DIR/backend"

log_info "프로젝트 디렉토리: $CURRENT_DIR"

# 1. 현재 상태 진단
log_info "1. 현재 상태를 진단합니다..."

echo "=== 포트 사용 상태 ==="
echo "  - 포트 3000: $(lsof -i :3000 >/dev/null 2>&1 && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 4000: $(lsof -i :4000 >/dev/null 2>&1 && echo '사용 중' || echo '사용 안 함')"

echo ""
echo "=== PM2 상태 ==="
pm2 status 2>/dev/null || echo "PM2가 실행되지 않습니다."

echo ""
echo "=== Nginx 상태 ==="
if systemctl is-active --quiet nginx; then
    log_success "Nginx가 실행 중입니다."
else
    log_warning "Nginx가 실행되지 않습니다."
fi

# 2. 모든 프로세스 강제 종료
log_info "2. 모든 프로세스를 강제 종료합니다..."

# 포트 3000, 4000 프로세스 종료
for port in 3000 4000; do
    PIDS=$(lsof -i :$port -t 2>/dev/null || true)
    if [ ! -z "$PIDS" ]; then
        log_info "포트 $port 프로세스를 종료합니다..."
        for pid in $PIDS; do
            log_info "  - PID $pid 종료 중..."
            kill -KILL $pid 2>/dev/null || true
        done
    fi
done

# PM2 프로세스 정리
log_info "PM2 프로세스를 정리합니다..."
pm2 delete all 2>/dev/null || true
pm2 kill 2>/dev/null || true

# 모든 Node.js 프로세스 종료
log_info "모든 Node.js 프로세스를 종료합니다..."
pkill -f "node" 2>/dev/null || true

sleep 5

# 3. 포트 해제 확인
log_info "3. 포트 해제를 확인합니다..."
echo "  - 포트 3000: $(lsof -i :3000 >/dev/null 2>&1 && echo '여전히 사용 중' || echo '해제됨')"
echo "  - 포트 4000: $(lsof -i :4000 >/dev/null 2>&1 && echo '여전히 사용 중' || echo '해제됨')"

# 4. 백엔드 재시작
log_info "4. 백엔드를 재시작합니다..."
cd "$BACKEND_DIR"

if [ -f "index.js" ]; then
    log_info "백엔드를 PM2로 시작합니다..."
    pm2 start index.js --name "qr-backend" --env production
    
    sleep 5
    
    # 백엔드 상태 확인
    if curl -s http://localhost:4000/api/health &> /dev/null; then
        log_success "백엔드가 정상적으로 실행됩니다!"
    else
        log_error "백엔드가 응답하지 않습니다!"
        pm2 logs qr-backend --lines 5
    fi
else
    log_error "백엔드 index.js 파일이 없습니다!"
fi

# 5. 프론트엔드 의존성 재설치
log_info "5. 프론트엔드 의존성을 재설치합니다..."
cd "$FRONTEND_DIR"

# 기존 파일 정리
log_info "기존 파일을 정리합니다..."
rm -rf node_modules package-lock.json .output .nuxt

# npm cache 정리
log_info "npm cache를 정리합니다..."
npm cache clean --force

# 의존성 재설치
log_info "의존성을 재설치합니다..."
npm install

# 6. 프론트엔드 빌드
log_info "6. 프론트엔드를 빌드합니다..."

# 빌드 실행
log_info "프론트엔드를 빌드합니다..."
npm run build

# 빌드 결과 확인
log_info "빌드 결과를 확인합니다..."
if [ -d ".output/server" ]; then
    log_success "빌드가 성공했습니다!"
    ls -la .output/server/
else
    log_error "빌드가 실패했습니다!"
    exit 1
fi

# 7. PM2 설정 파일 생성
log_info "7. PM2 설정 파일을 생성합니다..."

# ecosystem.config.cjs 생성
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

log_success "ecosystem.config.cjs가 생성되었습니다."

# 8. 프론트엔드 시작
log_info "8. 프론트엔드를 시작합니다..."

# PM2로 프론트엔드 시작
log_info "PM2로 프론트엔드를 시작합니다..."
pm2 start ecosystem.config.cjs

sleep 5

# 9. 프론트엔드 상태 확인
log_info "9. 프론트엔드 상태를 확인합니다..."

echo "=== PM2 상태 ==="
pm2 status

echo ""
echo "=== 포트 상태 ==="
echo "  - 포트 3000: $(lsof -i :3000 >/dev/null 2>&1 && echo '사용 중' || echo '사용 안 함')"
echo "  - 포트 4000: $(lsof -i :4000 >/dev/null 2>&1 && echo '사용 중' || echo '사용 안 함')"

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "로컬 프론트엔드 연결: 정상"
else
    log_error "로컬 프론트엔드 연결: 실패"
    pm2 logs qr-frontend --lines 10
fi

if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "로컬 백엔드 연결: 정상"
else
    log_error "로컬 백엔드 연결: 실패"
    pm2 logs qr-backend --lines 10
fi

# 10. Nginx 설정 수정
log_info "10. Nginx 설정을 수정합니다..."

# Nginx 설정 파일 생성
sudo tee /etc/nginx/conf.d/invenone.it.kr.conf > /dev/null << 'EOF'
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

server {
    listen 80;
    server_name invenone.it.kr www.invenone.it.kr;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name invenone.it.kr www.invenone.it.kr;
    
    ssl_certificate /etc/letsencrypt/live/invenone.it.kr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/invenone.it.kr/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    # 프론트엔드 프록시
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
        proxy_read_timeout 86400;
    }
    
    # 백엔드 API 프록시
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }
    
    # 정적 파일 캐싱
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://localhost:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

log_success "Nginx 설정이 업데이트되었습니다."

# Nginx 설정 테스트
log_info "Nginx 설정을 테스트합니다..."
if nginx -t; then
    log_success "Nginx 설정이 정상입니다."
else
    log_error "Nginx 설정에 문제가 있습니다!"
fi

# Nginx 재시작
log_info "Nginx를 재시작합니다..."
sudo systemctl restart nginx

sleep 3

# 11. 최종 상태 확인
log_info "11. 최종 상태를 확인합니다..."

echo ""
echo "=== 최종 상태 ==="
echo "  - 백엔드 프로세스: $(lsof -i :4000 >/dev/null 2>&1 && echo '실행 중' || echo '중지됨')"
echo "  - 프론트엔드 프로세스: $(lsof -i :3000 >/dev/null 2>&1 && echo '실행 중' || echo '중지됨')"
echo "  - Nginx 상태: $(systemctl is-active --quiet nginx && echo '실행 중' || echo '중지됨')"

echo ""
echo "=== PM2 상태 ==="
pm2 status

echo ""
echo "=== 연결 테스트 ==="
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "로컬 프론트엔드: 정상"
else
    log_error "로컬 프론트엔드: 실패"
fi

if curl -s http://localhost:4000/api/health &> /dev/null; then
    log_success "로컬 백엔드: 정상"
else
    log_error "로컬 백엔드: 실패"
fi

if curl -s https://invenone.it.kr &> /dev/null; then
    log_success "도메인 프론트엔드: 정상"
else
    log_warning "도메인 프론트엔드: 실패"
fi

if curl -s https://invenone.it.kr/api/health &> /dev/null; then
    log_success "도메인 백엔드: 정상"
else
    log_warning "도메인 백엔드: 실패"
fi

echo ""
echo "=========================================="
echo "🔧 모든 문제 종합 해결 완료!"
echo "=========================================="
echo ""

log_success "모든 문제 해결이 완료되었습니다! 🎉"
echo ""
echo "📝 다음 단계:"
echo "  1. 브라우저에서 https://invenone.it.kr 접속 테스트"
echo "  2. 여전히 문제가 있으면 개별 스크립트 실행"
echo "  3. 로그 확인: pm2 logs [프로세스명]"
echo ""
echo "📝 유용한 명령어:"
echo "  - PM2 상태: pm2 status"
echo "  - 백엔드 로그: pm2 logs qr-backend"
echo "  - 프론트엔드 로그: pm2 logs qr-frontend"
echo "  - Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo "  - 포트 확인: lsof -i :3000 && lsof -i :4000" 