# NCP 서버 배포 가이드

## 2024-12-19: NCP 서버 배포 설정 완료
## 2025-01-27: invenone.it.kr 도메인 HTTPS 설정 추가

### 포트 설정
- **Backend**: 4000 포트
- **Frontend**: 3000 포트
- **Nginx**: 80, 443 포트 (HTTPS)

### 도메인 설정 (invenone.it.kr)

#### 1. DNS 설정
도메인 관리자 페이지에서 A 레코드를 서버 IP로 설정:
```
invenone.it.kr  A  [서버IP주소]
```

#### 2. HTTPS 설정 (자동)
```bash
# SSL 인증서 자동 설정 스크립트 실행
./setup-ssl-invenone.sh
```

#### 3. 수동 HTTPS 설정
```bash
# 1. certbot 설치
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# 2. SSL 인증서 발급
sudo certbot --nginx -d invenone.it.kr --email admin@invenone.it.kr --agree-tos --non-interactive

# 3. nginx 설정 적용
sudo cp nginx-invenone-ssl.conf /etc/nginx/sites-available/invenone-ssl
sudo ln -sf /etc/nginx/sites-available/invenone-ssl /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

### 배포 전 준비사항

1. **NCP 서버에 Node.js 설치**
```bash
# Node.js 18+ 설치
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# PM2 설치
npm install -g pm2
```

2. **Nginx 설치**
```bash
# Nginx 설치
sudo apt update
sudo apt install -y nginx

# 방화벽 설정
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3000
sudo ufw allow 4000
```

3. **환경 변수 설정**
```bash
# Backend .env 파일 생성
cd backend
cp .env.example .env
# .env 파일에서 실제 값으로 수정
```

### 배포 방법

1. **자동 배포 (권장)**
```bash
chmod +x deploy.sh
./deploy.sh
```

2. **수동 배포**
```bash
# Backend 배포
cd backend
npm install
pm2 start ecosystem.config.js --env production

# Frontend 배포
cd ../frontend
npm install
npm run build
pm2 start ecosystem.config.js --env production
```

### 확인 방법

1. **서비스 상태 확인**
```bash
pm2 status
pm2 logs
```

2. **포트 확인**
```bash
netstat -tlnp | grep :3000
netstat -tlnp | grep :4000
netstat -tlnp | grep :443
```

3. **헬스체크**
```bash
curl http://your-ncp-server-ip:4000/health
curl https://invenone.it.kr/api/health
```

4. **SSL 인증서 확인**
```bash
sudo certbot certificates
openssl s_client -connect invenone.it.kr:443 -servername invenone.it.kr
```

### 주의사항

1. **API URL 설정**: `frontend/nuxt.config.ts`에서 `your-ncp-server-ip`를 실제 NCP 서버 IP로 변경
2. **데이터베이스**: PostgreSQL 설치 및 설정 필요
3. **SSL**: Let's Encrypt 인증서는 90일마다 자동 갱신됩니다
4. **도메인**: invenone.it.kr 도메인이 서버 IP로 올바르게 설정되어야 합니다

### 문제 해결

- **포트 충돌**: `pm2 delete all` 후 재시작
- **권한 문제**: `sudo` 사용
- **빌드 실패**: Node.js 버전 확인 (18+ 권장)
- **SSL 인증서 실패**: DNS 설정 확인, 80번 포트 열림 확인
- **nginx 설정 오류**: `sudo nginx -t`로 설정 파일 문법 확인

### 유용한 명령어

```bash
# nginx 상태 확인
sudo systemctl status nginx

# nginx 설정 테스트
sudo nginx -t

# nginx 재시작
sudo systemctl reload nginx

# SSL 인증서 수동 갱신
sudo certbot renew

# PM2 로그 확인
pm2 logs --lines 100

# 서버 리소스 확인
htop
df -h
free -h
``` 