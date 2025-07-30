# QR Asset Management System - Rocky Linux 배포 가이드

QR 코드를 활용한 자산 관리 시스템입니다.

## 📋 프로젝트 개요

- **프론트엔드**: Nuxt.js 3 + Vue 3 + TypeScript
- **백엔드**: Node.js + Express + Supabase
- **배포**: Nginx + PM2 (Rocky Linux)
- **작성일**: 2024-12-19

## 🔍 프로젝트 분석 결과

### ✅ 올바른 기술 스택
- **데이터베이스**: MySQL이 아닌 **Supabase** 사용
- **백엔드 포트**: 4000
- **프론트엔드 포트**: 3000
- **마이그레이션**: Supabase RPC 함수 사용
- **운영체제**: Rocky Linux (RHEL/CentOS 계열)

### ❌ 이전 스크립트의 문제점
- MySQL 설정으로 잘못된 가정
- 잘못된 포트 설정
- Supabase 환경 변수 누락
- Ubuntu/Debian 명령어 사용 (Rocky Linux는 dnf 사용)

## 🚀 Rocky Linux 배포 가이드

### 1. 전체 배포 (권장)

```bash
# 스크립트 실행 권한 부여
chmod +x setup_nginx_pm2_rocky.sh

# 전체 배포 실행
./setup_nginx_pm2_rocky.sh
```

### 2. 단계별 배포

#### 2.1 PM2 관리 (수정된 버전)
```bash
chmod +x pm2_management_corrected.sh

# 백엔드 시작 (환경 변수 확인 포함)
./pm2_management_corrected.sh start

# 상태 확인
./pm2_management_corrected.sh status

# 로그 확인
./pm2_management_corrected.sh logs

# 환경 변수 설정 도움말
./pm2_management_corrected.sh env-help
```

#### 2.2 Let's Encrypt SSL 인증서 설정 (Rocky Linux용)
```bash
chmod +x setup_ssl_rocky.sh
./setup_ssl_rocky.sh
```

#### 2.3 배포 상태 확인 (Rocky Linux용)
```bash
chmod +x check_deployment_rocky.sh
./check_deployment_rocky.sh
```

## 📁 프로젝트 구조

```
qr-asset-management/
├── backend/                 # 백엔드 (Node.js + Express + Supabase)
│   ├── config/             # Supabase 설정
│   ├── middleware/         # 미들웨어
│   ├── routes/            # API 라우트
│   └── index.js           # 메인 서버 파일 (포트 4000)
├── frontend/              # 프론트엔드 (Nuxt.js 3)
│   ├── components/        # Vue 컴포넌트
│   ├── pages/            # 페이지
│   ├── stores/           # 상태 관리
│   └── app.vue           # 메인 앱 컴포넌트
└── scripts/              # 배포 스크립트 (Rocky Linux용)
    ├── setup_nginx_pm2_rocky.sh        # Rocky Linux 배포 스크립트
    ├── setup_ssl_rocky.sh              # Rocky Linux SSL 설정
    ├── check_deployment_rocky.sh       # Rocky Linux 상태 확인
    └── pm2_management_corrected.sh     # PM2 관리 스크립트
```

## 🔧 기술 스택

### 프론트엔드
- **Nuxt.js 3**: Vue 3 기반 풀스택 프레임워크
- **Vue 3**: 반응형 UI 프레임워크
- **TypeScript**: 타입 안전성
- **Tailwind CSS**: 유틸리티 기반 CSS 프레임워크
- **Pinia**: 상태 관리

### 백엔드
- **Node.js**: JavaScript 런타임
- **Express**: 웹 프레임워크
- **Supabase**: PostgreSQL 기반 백엔드 서비스
- **JWT**: 인증 토큰
- **CORS**: 크로스 오리진 리소스 공유

### 배포 (Rocky Linux)
- **Nginx**: 웹 서버 및 리버스 프록시
- **PM2**: Node.js 프로세스 관리자
- **firewalld**: 방화벽 (Rocky Linux용)
- **dnf**: 패키지 관리자 (Rocky Linux용)

## 🌐 접속 정보

배포 완료 후 다음 URL로 접속할 수 있습니다:

- **프론트엔드**: https://invenone.it.kr
- **백엔드 API**: https://invenone.it.kr/api
- **헬스 체크**: https://invenone.it.kr/health

## ⚠️ 중요: Supabase 환경 변수 설정

### 필수 환경 변수
백엔드 `.env` 파일에서 다음 변수들을 설정해야 합니다:

```env
# Supabase Configuration (2024-12-19: MySQL이 아닌 Supabase 사용)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# Server Configuration
PORT=4000
NODE_ENV=production

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_2024
JWT_EXPIRES_IN=24h

# CORS Configuration (invenone.it.kr 도메인 포함)
CORS_ORIGIN=https://invenone.it.kr
```

### Supabase 설정 방법
1. [Supabase](https://supabase.com)에서 프로젝트 생성
2. Project Settings > API에서 다음 정보 확인:
   - Project URL
   - anon/public key
   - service_role key
3. 백엔드 `.env` 파일에 설정

## 📝 주요 기능

### 사용자 관리
- 회원가입/로그인
- JWT 기반 인증
- 사용자 프로필 관리

### QR 코드 관리
- QR 코드 생성
- QR 코드 스캔
- 자산 정보 연동

### 자산 관리
- 디바이스 등록/수정/삭제
- 직원 정보 관리
- 자산 이력 추적

## 🔍 배포 상태 확인

```bash
# 전체 시스템 상태 확인 (Rocky Linux용)
./check_deployment_rocky.sh

# 확인 항목:
# - Nginx 상태
# - Let's Encrypt SSL 인증서 상태
# - Supabase 연결 상태
# - PM2 프로세스 상태
# - 백엔드 API 응답 (포트 4000)
# - 프론트엔드 접속 (포트 3000)
# - firewalld 방화벽 상태
# - 시스템 리소스 사용량
```

## 🛠️ 유용한 명령어 (Rocky Linux용)

### PM2 관리
```bash
# 프로세스 상태 확인
pm2 status

# 로그 확인
pm2 logs qr-backend

# 재시작
pm2 restart qr-backend

# 중지
pm2 stop qr-backend

# 삭제
pm2 delete qr-backend

# 환경 변수 설정 도움말
./pm2_management_corrected.sh env-help
```

### Nginx 관리 (Rocky Linux용)
```bash
# 상태 확인
sudo systemctl status nginx

# 재시작
sudo systemctl restart nginx

# 설정 테스트
sudo nginx -t

# 로그 확인
sudo tail -f /var/log/nginx/invenone.it.kr-error.log
```

### 방화벽 관리 (Rocky Linux용 - firewalld)
```bash
# 방화벽 상태 확인
sudo firewall-cmd --list-all

# HTTP/HTTPS 서비스 허용
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# SSH 서비스 허용
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

### 패키지 관리 (Rocky Linux용 - dnf)
```bash
# 시스템 업데이트
sudo dnf update -y

# 패키지 설치
sudo dnf install -y [패키지명]

# 저장소 확인
sudo dnf repolist

# EPEL 저장소 활성화
sudo dnf install -y epel-release
```

## 🔒 보안 설정 (Rocky Linux용)

### 방화벽 설정
```bash
# firewalld 활성화
sudo systemctl enable firewalld
sudo systemctl start firewalld

# HTTP/HTTPS 포트 허용
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# SSH 포트 허용
sudo firewall-cmd --permanent --add-service=ssh

# 방화벽 규칙 적용
sudo firewall-cmd --reload
```

### SELinux 설정 (필요시)
```bash
# SELinux 상태 확인
sestatus

# Nginx 포트 허용
sudo semanage port -a -t http_port_t -p tcp 80
sudo semanage port -a -t http_port_t -p tcp 443

# Nginx 컨텍스트 설정
sudo setsebool -P httpd_can_network_connect 1
```

## 🚨 문제 해결 (Rocky Linux용)

### 502 Bad Gateway 오류
```bash
# 백엔드 프로세스 확인
pm2 status

# 백엔드 재시작
pm2 restart qr-backend

# Nginx 재시작
sudo systemctl restart nginx

# 방화벽 확인
sudo firewall-cmd --list-all
```

### Supabase 연결 오류
```bash
# 환경 변수 확인
./pm2_management_corrected.sh env-help

# 백엔드 로그 확인
pm2 logs qr-backend
```

### 포트 충돌
```bash
# 포트 사용 확인 (Rocky Linux용 - ss 명령어)
sudo ss -tlnp | grep :80
sudo ss -tlnp | grep :443
sudo ss -tlnp | grep :3000
sudo ss -tlnp | grep :4000

# 프로세스 종료
sudo kill -9 [PID]
```

### Let's Encrypt SSL 인증서 문제
```bash
# Let's Encrypt SSL 인증서 확인
sudo certbot certificates

# Let's Encrypt SSL 인증서 갱신
sudo certbot renew

# Nginx 설정 테스트
sudo nginx -t

# SSL 연결 테스트
curl -I https://invenone.it.kr
```

## 📞 지원

문제가 발생하면 다음 순서로 확인해보세요:

1. `./check_deployment_rocky.sh` 실행하여 전체 상태 확인
2. PM2 로그 확인: `pm2 logs qr-backend`
3. Nginx 로그 확인: `sudo tail -f /var/log/nginx/invenone.it.kr-error.log`
4. 환경 변수 확인: `./pm2_management_corrected.sh env-help`
5. 방화벽 상태 확인: `sudo firewall-cmd --list-all`

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

---

**마지막 업데이트**: 2024-12-19
**배포 방식**: Nginx + PM2 (Rocky Linux)
**데이터베이스**: Supabase
**포트 설정**: 백엔드 4000, 프론트엔드 3000
**운영체제**: Rocky Linux (RHEL/CentOS 계열) 