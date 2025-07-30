# QR 자산관리 시스템 배포 가이드

## 📋 프로젝트 개요

QR 자산관리 시스템은 QR 코드를 활용한 자산 관리 솔루션입니다.

### 🏗️ 기술 스택

- **백엔드**: Node.js + Express + Supabase
- **프론트엔드**: Nuxt.js 3 + Vue 3 + TypeScript
- **데이터베이스**: Supabase (PostgreSQL)
- **웹 서버**: Nginx
- **프로세스 관리**: PM2
- **도메인**: invenone.it.kr
- **SSL**: Let's Encrypt

### 📁 프로젝트 구조

```
qr-asset-management/
├── backend/                 # 백엔드 (Node.js + Express)
│   ├── config/             # Supabase 설정
│   ├── middleware/         # 미들웨어
│   ├── routes/            # API 라우트
│   └── index.js           # 메인 서버 파일 (포트 4000)
├── frontend/              # 프론트엔드 (Nuxt.js 3)
│   ├── components/        # Vue 컴포넌트
│   ├── pages/            # 페이지
│   ├── stores/           # 상태 관리
│   └── app.vue           # 메인 앱 컴포넌트
└── scripts/              # 배포 스크립트
    ├── deploy.sh         # 통합 배포 스크립트
    └── diagnose.sh       # 시스템 진단 스크립트
```

## 🚀 배포 방법

### 1. 현재 상황 진단

먼저 현재 시스템 상태를 진단합니다:

```bash
chmod +x diagnose.sh
./diagnose.sh
```

### 2. 통합 배포 실행

진단 결과에 따라 시스템을 배포합니다:

```bash
chmod +x deploy.sh
./deploy.sh
```

### 3. PM2 설정 문제 해결 (필요시)

ES 모듈 오류가 발생하는 경우:

```bash
chmod +x fix_pm2_config.sh
./fix_pm2_config.sh
```

### 4. Nuxt.js 모듈 오류 해결 (필요시)

c12 모듈 오류가 발생하는 경우:

```bash
chmod +x fix_nuxt_modules.sh
./fix_nuxt_modules.sh
```

### 5. 포트 충돌 문제 해결 (필요시)

포트 3000, 4000 충돌이 발생하는 경우:

```bash
chmod +x fix_port_conflict.sh
./fix_port_conflict.sh
```

### 6. 사용자 권한 문제 해결 (필요시)

PM2 프로세스가 root 계정으로 실행되는 경우:

```bash
chmod +x fix_user_permissions.sh
./fix_user_permissions.sh
```

### 7. 고집스러운 프로세스 강제 종료 (필요시)

포트를 사용하는 프로세스가 죽지 않는 경우:

```bash
chmod +x kill_stubborn_process.sh
./kill_stubborn_process.sh
```

### 8. 프론트엔드 503 오류 해결 (필요시)

503 Service Unavailable 오류가 발생하는 경우:

```bash
chmod +x fix_frontend_503.sh
./fix_frontend_503.sh
```

### 9. API Health 체크 (권장)

백엔드 API 상태를 종합적으로 확인:

```bash
chmod +x check_api_health.sh
./check_api_health.sh
```

## 📊 배포 스크립트 설명

### `deploy.sh` - 통합 배포 스크립트

**기능:**
- 시스템 환경 자동 감지 (Rocky Linux / Ubuntu)
- NCP 환경 자동 감지
- 백엔드 설정 및 실행 (포트 4000)
- 프론트엔드 빌드 및 실행 (포트 3000)
- Nginx 설정 및 SSL 지원
- 방화벽 설정
- PM2 프로세스 관리

**실행 단계:**
1. 시스템 환경 확인
2. 시스템 패키지 설치
3. 방화벽 설정
4. 백엔드 설정
5. 프론트엔드 설정
6. Nginx 설정
7. SSL 인증서 확인
8. 최종 상태 확인

### `diagnose.sh` - 시스템 진단 스크립트

**기능:**
- 시스템 정보 확인
- 프로젝트 구조 확인
- 백엔드 상태 확인
- 프론트엔드 상태 확인
- Nginx 상태 확인
- SSL 인증서 확인
- 방화벽 상태 확인
- 도메인 연결 테스트
- 시스템 리소스 확인
- 문제점 요약 및 해결 방안 제시

## 🔧 환경 변수 설정

### 백엔드 (.env)

```env
# Supabase Configuration
SUPABASE_URL=https://miiagipiurokjjotbuol.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNTI1MDUsImV4cCI6MjA2NDkyODUwNX0.9S7zWwA5fw2WSJgMJb8iZ7Nnq-Cml0l7vfULCy-Qz5g
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1paWFnaXBpdXJva2pqb3RidW9sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzM1MjUwNSwiZXhwIjoyMDY0OTI4NTA1fQ.YOM-UqbSIZPi0qWtM0jlUb4oS9mBDi-CMs95FYTPAXg

# Server Configuration
PORT=4000
NODE_ENV=production

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
JWT_EXPIRES_IN=24h

# CORS Configuration
CORS_ORIGIN=https://invenone.it.kr
```

## 🌐 접속 정보

배포 완료 후 다음 URL로 접속할 수 있습니다:

- **프론트엔드**: https://invenone.it.kr
- **백엔드 API**: https://invenone.it.kr/api
- **헬스 체크**: https://invenone.it.kr/api/health

## 📝 유용한 명령어

### PM2 관리
```bash
# PM2 상태 확인
pm2 status

# 백엔드 로그 확인
pm2 logs qr-backend

# 프론트엔드 로그 확인
pm2 logs qr-frontend

# 모든 서비스 재시작
pm2 restart all

# 특정 서비스 재시작
pm2 restart qr-backend
pm2 restart qr-frontend
```

### Nginx 관리
```bash
# Nginx 상태 확인
sudo systemctl status nginx

# Nginx 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx

# Nginx 로그 확인
sudo tail -f /var/log/nginx/error.log
```

### 시스템 모니터링
```bash
# 포트 사용 상태 확인
ss -tlnp

# 시스템 리소스 확인
htop

# 디스크 사용량 확인
df -h

# 메모리 사용량 확인
free -h
```

## ⚠️ 문제 해결

### 1. 백엔드가 응답하지 않는 경우
```bash
# 백엔드 로그 확인
pm2 logs qr-backend

# 백엔드 재시작
pm2 restart qr-backend

# 환경 변수 확인
cat backend/.env
```

### 2. 프론트엔드가 응답하지 않는 경우
```bash
# 프론트엔드 로그 확인
pm2 logs qr-frontend

# 프론트엔드 재시작
pm2 restart qr-frontend

# 빌드 파일 확인
ls -la frontend/.output/
```

### 3. Nginx가 실행되지 않는 경우
```bash
# Nginx 상태 확인
sudo systemctl status nginx

# Nginx 설정 테스트
sudo nginx -t

# 포트 충돌 확인
ss -tlnp | grep :80
ss -tlnp | grep :443
```

### 4. PM2 설정 파일 문제
```bash
# PM2 설정 파일 확인
cat frontend/ecosystem.config.cjs

# PM2 재시작
pm2 restart qr-frontend

# PM2 로그 확인
pm2 logs qr-frontend
```

### 5. Nuxt.js 모듈 문제
```bash
# 의존성 확인
npm list c12

# node_modules 재설치
rm -rf node_modules package-lock.json
npm install

# 빌드 재실행
npm run build
```

### 6. 포트 충돌 문제
```bash
# 포트 사용 상태 확인
ss -tlnp | grep ':3000\|:4000'

# PM2 프로세스 정리
pm2 delete all
pm2 kill

# 포트 사용 프로세스 종료
kill -9 $(ss -tlnp | grep ':3000 ' | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2)
kill -9 $(ss -tlnp | grep ':4000 ' | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2)
```

### 7. 사용자 권한 문제
```bash
# 현재 사용자 확인
whoami

# dmanager 계정으로 전환
su - dmanager

# PM2 프로세스 소유자 확인
pm2 list | grep -E "(qr-backend|qr-frontend)" | while read line; do
    PID=$(echo "$line" | awk '{print $6}')
    if [ ! -z "$PID" ] && [ "$PID" != "0" ]; then
        OWNER=$(ps -o user= -p $PID 2>/dev/null || echo "알 수 없음")
        echo "PID $PID 소유자: $OWNER"
    fi
done

# dmanager 계정으로 PM2 재시작
pm2 delete all
pm2 kill
cd /home/dmanager/assetmanager/backend && pm2 start index.js --name 'qr-backend'
cd /home/dmanager/assetmanager/frontend && pm2 start ecosystem.config.cjs
```

### 8. 고집스러운 프로세스 문제
```bash
# 포트 사용 프로세스 확인
lsof -i :3000
lsof -i :4000

# 프로세스 강제 종료
kill -9 $(lsof -i :3000 -t)
kill -9 $(lsof -i :4000 -t)

# 모든 Node.js 프로세스 종료
pkill -f "node"

# PM2 완전 정리
pm2 delete all
pm2 kill
```

### 9. 프론트엔드 503 오류 문제
```bash
# 프론트엔드 상태 확인
pm2 status
lsof -i :3000

# 프론트엔드 재빌드
cd frontend
rm -rf node_modules package-lock.json .output .nuxt
npm cache clean --force
npm install
npm run build

# PM2 재시작
pm2 delete qr-frontend
pm2 start ecosystem.config.cjs

# Nginx 재시작
sudo systemctl restart nginx
```

### 10. API Health 문제
```bash
# API Health 체크
curl -s http://localhost:4000/api/health

# 백엔드 상태 확인
pm2 status
lsof -i :4000

# 백엔드 재시작
pm2 restart qr-backend

# 백엔드 로그 확인
pm2 logs qr-backend --lines 10

# Supabase 연결 테스트
curl -s "$SUPABASE_URL/rest/v1/"
```

### 11. SSL 인증서 문제
```bash
# SSL 인증서 확인
ls -la /etc/letsencrypt/live/invenone.it.kr/

# 인증서 만료일 확인
openssl x509 -in /etc/letsencrypt/live/invenone.it.kr/fullchain.pem -noout -enddate
```

## 🔄 재배포

시스템에 문제가 있을 때 전체 재배포:

```bash
# 1. 현재 상태 진단
./diagnose.sh

# 2. 전체 재배포
./deploy.sh

# 3. 재배포 후 상태 확인
./diagnose.sh
```

## 📞 지원

문제가 발생하면 다음 순서로 확인하세요:

1. `./diagnose.sh` 실행하여 문제점 파악
2. 로그 확인 (PM2, Nginx)
3. 환경 변수 확인
4. 포트 충돌 확인
5. `./deploy.sh` 실행하여 재배포

---

**작성일**: 2024-12-19  
**버전**: 1.0.0  
**도메인**: invenone.it.kr 