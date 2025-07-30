# HTTPS 설정 가이드

## 2025-01-27: HTTPS + SSL 인증서 설정 완료

### ✅ 현재 설정 상태
- 백엔드: HTTPS 서버 (포트 4000)
- 프론트엔드: HTTPS 서버 (포트 3000)
- nginx: HTTPS 리버스 프록시 (포트 443)
- SSL 인증서: Let's Encrypt 적용

### 🔐 SSL 인증서 정보
```
Certificate: /etc/letsencrypt/live/invenone.it.kr/fullchain.pem
Private Key: /etc/letsencrypt/live/invenone.it.kr/privkey.pem
Domain: invenone.it.kr
```

### 🌐 접속 URL
- **웹사이트**: https://invenone.it.kr
- **API 서버**: https://invenone.it.kr/api
- **헬스체크**: https://invenone.it.kr/api/health

### 🔧 배포 방법

#### 1. 자동 배포 (권장)
```bash
# 배포 스크립트 실행
chmod +x deploy.sh
./deploy.sh
```

#### 2. 수동 배포
```bash
# 백엔드 배포
cd backend
npm install
pm2 delete backend 2>/dev/null || true
pm2 start index.js --name backend --watch

# 프론트엔드 배포
cd ../frontend
npm install
npm run build
pm2 delete frontend 2>/dev/null || true
pm2 start npm --name frontend -- run preview

# nginx 설정 적용
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl restart nginx
```

### 🔍 설정 확인

#### 1. SSL 인증서 확인
```bash
# 인증서 파일 존재 확인
ls -la /etc/letsencrypt/live/invenone.it.kr/

# 인증서 정보 확인
sudo openssl x509 -in /etc/letsencrypt/live/invenone.it.kr/fullchain.pem -text -noout
```

#### 2. 서비스 상태 확인
```bash
# PM2 프로세스 확인
pm2 status

# nginx 상태 확인
sudo systemctl status nginx

# 포트 확인
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'
```

#### 3. 방화벽 설정 확인
```bash
# 방화벽 상태 확인
sudo ufw status

# 필요한 포트 열기
sudo ufw allow 80
sudo ufw allow 443
```

### 🚨 문제 해결

#### 1. SSL 인증서 오류
```bash
# 인증서 갱신
sudo certbot renew

# nginx 재시작
sudo systemctl restart nginx
```

#### 2. nginx 설정 오류
```bash
# 설정 파일 문법 검사
sudo nginx -t

# 오류 로그 확인
sudo tail -f /var/log/nginx/error.log
```

#### 3. CORS 오류
- 브라우저 개발자 도구에서 Network 탭 확인
- API 요청이 HTTPS로 이루어지는지 확인
- nginx CORS 헤더 설정 확인

#### 4. Mixed Content 오류
- 모든 리소스가 HTTPS로 로드되는지 확인
- 프론트엔드 API URL이 HTTPS인지 확인

### 📊 모니터링

#### 1. 로그 확인
```bash
# nginx 접근 로그
sudo tail -f /var/log/nginx/access.log

# nginx 오류 로그
sudo tail -f /var/log/nginx/error.log

# PM2 로그
pm2 logs
```

#### 2. 성능 모니터링
```bash
# 시스템 리소스 확인
htop

# 네트워크 연결 확인
sudo netstat -tlnp
```

### 🔄 유지보수

#### 1. SSL 인증서 갱신
```bash
# 자동 갱신 테스트
sudo certbot renew --dry-run

# 실제 갱신
sudo certbot renew

# nginx 재시작
sudo systemctl reload nginx
```

#### 2. 서비스 재시작
```bash
# PM2 프로세스 재시작
pm2 restart all

# nginx 재시작
sudo systemctl restart nginx
```

#### 3. 설정 변경 후 적용
```bash
# nginx 설정 변경 후
sudo nginx -t
sudo systemctl reload nginx

# PM2 설정 변경 후
pm2 restart all
```

### ⚠️ 주의사항

1. **SSL 인증서 갱신**: Let's Encrypt 인증서는 90일마다 갱신 필요
2. **방화벽 설정**: 포트 80, 443이 열려있어야 함
3. **도메인 설정**: DNS에서 invenone.it.kr이 서버 IP로 설정되어야 함
4. **백업**: 정기적으로 설정 파일과 데이터 백업 필요

### 📞 지원

문제가 발생하면 다음 정보를 확인해주세요:
- nginx 오류 로그
- PM2 로그
- 브라우저 개발자 도구 콘솔
- SSL 인증서 상태
- 방화벽 설정 