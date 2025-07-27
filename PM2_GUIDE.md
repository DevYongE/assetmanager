# PM2 서비스 관리 가이드

## 2025-01-27: QR 자산관리 시스템 PM2 설정

### 🚀 서비스 시작

```bash
# 전체 서비스 시작
./start-services.sh

# 또는 수동으로 시작
pm2 start ecosystem.config.js --env production
```

### 📊 서비스 상태 확인

```bash
# PM2 상태 확인
pm2 status

# 상세 정보 확인
pm2 show assetmanager-backend
pm2 show assetmanager-frontend

# 로그 확인
pm2 logs
pm2 logs assetmanager-backend
pm2 logs assetmanager-frontend
```

### 🔄 서비스 재시작

```bash
# 전체 서비스 재시작
pm2 restart all

# 개별 서비스 재시작
pm2 restart assetmanager-backend
pm2 restart assetmanager-frontend
```

### ⏹️ 서비스 중지

```bash
# 전체 서비스 중지
pm2 stop all

# 개별 서비스 중지
pm2 stop assetmanager-backend
pm2 stop assetmanager-frontend
```

### 🗑️ 서비스 삭제

```bash
# 전체 서비스 삭제
pm2 delete all

# 개별 서비스 삭제
pm2 delete assetmanager-backend
pm2 delete assetmanager-frontend
```

### 🔧 모니터링

```bash
# 실시간 모니터링
pm2 monit

# 모니터링 스크립트 실행
./monitor-services.sh
```

### 💾 설정 저장 및 자동 시작

```bash
# 현재 설정 저장
pm2 save

# 서버 재부팅 시 자동 시작 설정
pm2 startup

# systemd 서비스 설정 (선택사항)
sudo cp assetmanager.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable assetmanager
sudo systemctl start assetmanager
```

### 📋 로그 확인

```bash
# 실시간 로그
pm2 logs --follow

# 특정 서비스 로그
pm2 logs assetmanager-backend --follow
pm2 logs assetmanager-frontend --follow

# 로그 파일 위치
# ./logs/backend-error.log
# ./logs/backend-out.log
# ./logs/frontend-error.log
# ./logs/frontend-out.log
```

### 🔍 문제 해결

#### 서비스가 시작되지 않는 경우:
```bash
# PM2 재설치
npm install -g pm2

# 포트 확인
netstat -tlnp | grep :3000
netstat -tlnp | grep :4000

# 로그 확인
pm2 logs
```

#### 메모리 부족 문제:
```bash
# 메모리 사용량 확인
pm2 monit

# 메모리 제한 설정 확인
pm2 show assetmanager-backend
```

#### 자동 재시작이 안 되는 경우:
```bash
# PM2 설정 확인
pm2 startup

# systemd 서비스 확인
sudo systemctl status assetmanager
```

### 📊 성능 모니터링

```bash
# CPU/메모리 사용량
pm2 monit

# 상세 통계
pm2 show assetmanager-backend
pm2 show assetmanager-frontend
```

### 🔄 배포

```bash
# 전체 배포
./deploy.sh

# 또는 수동 배포
cd backend && npm install --production && cd ..
cd frontend && npm install --production && NODE_ENV=production npm run build && cd ..
pm2 restart all
```

### ⚠️ 주의사항

1. **포트 충돌**: 3000, 4000 포트가 사용 중인지 확인
2. **메모리**: 각 서비스는 최대 1GB 메모리 사용
3. **로그**: 로그 파일이 너무 커지지 않도록 주기적 정리
4. **백업**: PM2 설정 파일 백업 권장

### 📞 지원

문제가 발생하면 다음을 확인하세요:
1. `pm2 status` - 서비스 상태
2. `pm2 logs` - 에러 로그
3. `pm2 monit` - 실시간 모니터링
4. 시스템 리소스 사용량 