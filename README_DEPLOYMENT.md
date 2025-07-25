# NCP 서버 배포 가이드

## 2024-12-19: NCP 서버 배포 설정 완료

### 포트 설정
- **Backend**: 4000 포트
- **Frontend**: 3000 포트

### 배포 전 준비사항

1. **NCP 서버에 Node.js 설치**
```bash
# Node.js 18+ 설치
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# PM2 설치
npm install -g pm2
```

2. **방화벽 설정**
```bash
# 3000, 4000 포트 열기
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
```

3. **헬스체크**
```bash
curl http://your-ncp-server-ip:4000/health
```

### 주의사항

1. **API URL 설정**: `frontend/nuxt.config.ts`에서 `your-ncp-server-ip`를 실제 NCP 서버 IP로 변경
2. **데이터베이스**: PostgreSQL 설치 및 설정 필요
3. **SSL**: 프로덕션에서는 HTTPS 설정 권장

### 문제 해결

- **포트 충돌**: `pm2 delete all` 후 재시작
- **권한 문제**: `sudo` 사용
- **빌드 실패**: Node.js 버전 확인 (18+ 권장) 