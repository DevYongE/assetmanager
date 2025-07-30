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

### 4. SSL 인증서 문제
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