# QR 자산관리 시스템 - Rocky Linux 배포 가이드 (Supabase 기반)

## 📋 개요

이 문서는 Rocky Linux 서버에 QR 자산관리 시스템을 배포하는 방법을 설명합니다.
**Supabase**를 데이터베이스로 사용하는 Node.js 백엔드와 Nuxt.js 프론트엔드로 구성됩니다.

## 🚀 빠른 배포

### 1. 서버 접속
```bash
ssh dmanager@your-server-ip
```

### 2. 배포 스크립트 실행
```bash
# 스크립트 실행 권한 부여
chmod +x deploy_rocky_linux.sh

# 배포 실행
./deploy_rocky_linux.sh
```

## 📦 시스템 요구사항

- **OS**: Rocky Linux 8/9
- **CPU**: 2코어 이상
- **RAM**: 4GB 이상
- **Storage**: 20GB 이상
- **Network**: 인터넷 연결
- **Database**: Supabase (클라우드)

## 🔧 수동 설치 (스크립트 사용 불가 시)

### 1. 시스템 업데이트
```bash
sudo dnf update -y
sudo dnf install -y git nodejs npm nginx
```

### 2. PM2 설치
```bash
# PM2 글로벌 설치 (sudo 없이)
npm install -g pm2

# PM2 버전 확인
pm2 --version
```

### 3. 프로젝트 설정
```bash
cd /home/dmanager
git clone https://github.com/DevYongE/assetmanager.git
cd assetmanager
```

### 4. 기존 .env 파일 확인
```bash
# 백업에서 .env 파일 복사 (있다면)
cp /path/to/backup/backend/.env backend/.env

# 또는 새로 생성
cat > backend/.env << EOF
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url_here
# 2025-08-08: 변수명 정규화 - SUPABASE_ANON_KEY 사용
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

# 환경변수 파일 권한 설정
chmod 600 backend/.env
```

### 5. 백엔드 설정
```bash
cd backend
npm install

# Supabase 마이그레이션 실행
node run-migration.js
```

### 6. 프론트엔드 설정
```bash
cd ../frontend
npm install
npm run build:prod
```

### 7. PM2 설정
```bash
# 백엔드 시작
cd ../backend
pm2 start index.js --name "assetmanager-backend"

# 프론트엔드 시작
cd ../frontend
pm2 start "npx serve .output/public -p 3000" --name "assetmanager-frontend"

# PM2 설정 저장
pm2 save

# PM2 startup 설정 (중요!)
pm2 startup
# 위 명령어의 출력을 복사하여 실행하세요!
```

### 8. Nginx 설정
```bash
sudo tee /etc/nginx/conf.d/assetmanager.conf > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

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
    }

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
    }
}
EOF

sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### 9. 방화벽 설정
```bash
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=4000/tcp
sudo firewall-cmd --reload
```

## 🔍 모니터링 및 관리

### 상태 확인
```bash
# 전체 상태 확인
/home/dmanager/monitor.sh

# PM2 상태
pm2 status

# Nginx 상태
sudo systemctl status nginx
```

### 로그 확인
```bash
# 백엔드 로그
pm2 logs assetmanager-backend

# 프론트엔드 로그
pm2 logs assetmanager-frontend

# Nginx 로그
sudo tail -f /var/log/nginx/access.log
```

### 서비스 재시작
```bash
# PM2 재시작
pm2 restart all

# Nginx 재시작
sudo systemctl restart nginx
```

## 🛠️ 문제 해결

### 문제 해결 도구 실행
```bash
chmod +x troubleshoot.sh
./troubleshoot.sh
```

### 일반적인 문제들

#### 1. PM2 설치 문제
```bash
# PM2 재설치
npm uninstall -g pm2
npm install -g pm2

# PM2 경로 확인
which pm2

# PM2 버전 확인
pm2 --version
```

#### 2. 포트 충돌
```bash
# 포트 사용 확인
sudo netstat -tlnp | grep -E ':(80|3000|4000)'

# 충돌하는 프로세스 종료
sudo kill -9 [PID]
```

#### 3. 권한 문제
```bash
sudo chown -R dmanager:dmanager /home/dmanager/assetmanager
sudo chmod -R 755 /home/dmanager/assetmanager
chmod 600 /home/dmanager/assetmanager/backend/.env
```

#### 4. 방화벽 문제
```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

#### 5. Supabase 연결 문제
```bash
# 환경변수 확인
cat /home/dmanager/assetmanager/backend/.env | grep SUPABASE

# 백엔드 연결 테스트
curl -s http://localhost:4000/api/health
```

## 💾 백업 및 복원

### 자동 백업
```bash
# 백업 실행
/home/dmanager/backup.sh

# 백업 목록 확인
ls -la /home/dmanager/backups/
```

### 수동 백업
```bash
# 애플리케이션 백업
tar -czf app_backup_$(date +%Y%m%d).tar.gz /home/dmanager/assetmanager

# 환경변수 백업
cp /home/dmanager/assetmanager/backend/.env env_backup_$(date +%Y%m%d)
```

### 복원
```bash
# 애플리케이션 복원
tar -xzf app_backup_20250127.tar.gz -C /

# 환경변수 복원
cp env_backup_20250127 /home/dmanager/assetmanager/backend/.env
```

## 🔒 보안 설정

### SSL 인증서 설정 (선택사항)
```bash
# Certbot 설치
sudo dnf install -y certbot python3-certbot-nginx

# SSL 인증서 발급
sudo certbot --nginx -d your-domain.com

# 자동 갱신 설정
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

### 방화벽 강화
```bash
# SSH 포트 변경 (선택사항)
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# 불필요한 서비스 비활성화
sudo systemctl disable telnet
sudo systemctl disable rsh
```

## 📊 성능 모니터링

### 시스템 리소스 확인
```bash
# CPU 및 메모리 사용량
htop

# 디스크 사용량
df -h

# 네트워크 사용량
iftop
```

### 로그 분석
```bash
# Nginx 접속 로그 분석
sudo tail -f /var/log/nginx/access.log | grep -v "health"

# 에러 로그 모니터링
sudo tail -f /var/log/nginx/error.log
```

## 🔄 업데이트

### 애플리케이션 업데이트
```bash
cd /home/dmanager/assetmanager

# 백업 생성
/home/dmanager/backup.sh

# 코드 업데이트
git pull origin master

# 백엔드 재시작
cd backend
npm install
pm2 restart assetmanager-backend

# 프론트엔드 재빌드
cd ../frontend
npm install
npm run build:prod
pm2 restart assetmanager-frontend
```

### 시스템 업데이트
```bash
sudo dnf update -y
sudo systemctl restart nginx
```

## ⚠️ 중요 사항

### Supabase 설정
1. [Supabase](https://supabase.com)에서 프로젝트 생성
2. Project Settings > API에서 다음 정보 확인:
   - Project URL
   - anon/public key
   - service_role key
3. 백엔드 `.env` 파일에 설정

### 환경변수 필수 항목
```env
# 2025-08-08: 변수명 정규화 - SUPABASE_ANON_KEY 사용
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here
JWT_SECRET=your_jwt_secret_key_2025
```

### PM2 자동 시작 설정
```bash
# PM2 startup 명령어 실행 후 출력된 명령어를 복사하여 실행
pm2 startup
# 예: sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u dmanager --hp /home/dmanager
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:

1. **로그 확인**: `/home/dmanager/monitor.sh`
2. **문제 해결 도구**: `./troubleshoot.sh`
3. **백업 확인**: `/home/dmanager/backup.sh`
4. **Supabase 연결**: 환경변수 설정 확인
5. **PM2 문제**: `npm install -g pm2` 재설치

## 📝 변경 이력

- **2025-01-27**: Supabase 기반 배포 가이드 작성
- **2025-01-27**: 자동화 스크립트 추가
- **2025-01-27**: 문제 해결 도구 추가
- **2025-01-27**: PM2 설치 문제 해결 및 .env 파일 확인 추가 