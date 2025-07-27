# QR 자산관리 시스템

## 📋 프로젝트 개요

QR 자산관리 시스템은 직원과 장비의 정보를 관리하고, QR 코드를 생성하여 자산 추적을 효율적으로 수행할 수 있는 웹 애플리케이션입니다.

### 🎯 주요 기능

- **직원 관리**: 직원 정보 등록, 수정, 삭제
- **장비 관리**: 장비 정보 등록, 수정, 삭제, 담당자 할당
- **QR 코드 생성**: 직원별/장비별 QR 코드 생성 및 다운로드
- **Excel Import/Export**: 대량 데이터 처리
- **대시보드**: 통계 및 현황 조회
- **사용자 인증**: JWT 토큰 기반 로그인/회원가입

### 🏗️ 기술 스택

#### Frontend
- **Nuxt.js 4**: Vue.js 기반 프레임워크
- **TypeScript**: 타입 안전성
- **Tailwind CSS**: 스타일링
- **Pinia**: 상태 관리
- **@zxing/library**: QR 코드 스캔

#### Backend
- **Express.js**: Node.js 웹 프레임워크
- **JWT**: 인증 토큰
- **bcryptjs**: 비밀번호 암호화
- **qrcode**: QR 코드 생성
- **xlsx**: Excel 파일 처리
- **Supabase**: 데이터베이스

#### Infrastructure
- **Nginx**: 리버스 프록시 및 SSL
- **PM2**: 프로세스 관리
- **Docker**: 컨테이너화 (선택사항)

## 🚀 빠른 시작

### 1. 저장소 클론

```bash
git clone <repository-url>
cd qr-asset-management
```

### 2. 의존성 설치

```bash
# 백엔드 의존성 설치
cd backend
npm install

# 프론트엔드 의존성 설치
cd ../frontend
npm install
```

### 3. 환경 설정

#### 백엔드 환경변수 설정

```bash
# backend/.env 파일 생성
cp backend/.env.example backend/.env
```

```env
# 데이터베이스 설정
DATABASE_URL=your_database_url

# JWT 시크릿
JWT_SECRET=your_jwt_secret

# 서버 포트
PORT=4000

# 환경 설정
NODE_ENV=development
```

#### 프론트엔드 환경변수 설정

```bash
# frontend/.env 파일 생성
cp frontend/.env.example frontend/.env
```

```env
# API 기본 URL
API_BASE_URL=http://localhost:4000

# 환경 설정
NODE_ENV=development
```

### 4. 개발 서버 실행

```bash
# 백엔드 서버 실행 (포트 4000)
cd backend
npm run dev

# 프론트엔드 서버 실행 (포트 3000)
cd ../frontend
npm run dev
```

### 5. 브라우저에서 접속

- **프론트엔드**: http://localhost:3000
- **백엔드 API**: http://localhost:4000

## 🛠️ 운영 환경 배포

### 1. PM2를 사용한 배포

```bash
# 전체 서비스 시작
./start-services.sh

# 또는 수동으로 시작
pm2 start ecosystem.config.js --env production
```

### 2. Nginx 설정

```bash
# Nginx 설정 파일 복사
sudo cp /etc/nginx/conf.d/assetmanager.conf /etc/nginx/sites-available/

# 설정 활성화
sudo ln -s /etc/nginx/sites-available/assetmanager.conf /etc/nginx/sites-enabled/

# Nginx 재시작
sudo systemctl reload nginx
```

### 3. SSL 인증서 설정

```bash
# 자체 서명 인증서 생성 (개발용)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt
```

## 📁 프로젝트 구조

```
qr-asset-management/
├── backend/                 # 백엔드 서버 (Express.js)
│   ├── config/             # 데이터베이스 설정
│   ├── middleware/         # 미들웨어 (인증 등)
│   ├── routes/            # API 라우터
│   ├── index.js           # 메인 서버 파일
│   └── package.json
├── frontend/               # 프론트엔드 (Nuxt.js)
│   ├── components/        # Vue 컴포넌트
│   ├── pages/            # 페이지 컴포넌트
│   ├── composables/      # 재사용 가능한 로직
│   ├── stores/           # Pinia 상태 관리
│   ├── types/            # TypeScript 타입 정의
│   └── nuxt.config.ts    # Nuxt 설정
├── ecosystem.config.js    # PM2 설정
├── start-services.sh     # 서비스 시작 스크립트
├── deploy.sh            # 배포 스크립트
└── README.md
```

## 🔧 주요 설정 파일

### Nginx 설정 (`/etc/nginx/conf.d/assetmanager.conf`)
- HTTP에서 HTTPS 자동 리다이렉트
- 프론트엔드/백엔드 프록시 설정
- SSL 보안 설정
- CORS 설정
- 정적 파일 캐싱

### PM2 설정 (`ecosystem.config.js`)
- 백엔드/프론트엔드 서비스 관리
- 자동 재시작 설정
- 로그 파일 관리
- 메모리 사용량 제한

### Nuxt 설정 (`frontend/nuxt.config.ts`)
- 개발 서버 포트 설정
- 환경별 API URL 설정
- 모듈 설정 (Tailwind CSS, Pinia)
- 빌드 최적화 설정

## 📊 API 엔드포인트

### 인증
- `POST /api/auth/login` - 로그인
- `POST /api/auth/register` - 회원가입

### 직원 관리
- `GET /api/employees` - 직원 목록 조회
- `POST /api/employees` - 직원 생성
- `PUT /api/employees/:id` - 직원 정보 수정
- `DELETE /api/employees/:id` - 직원 삭제

### 장비 관리
- `GET /api/devices` - 장비 목록 조회
- `POST /api/devices` - 장비 생성
- `PUT /api/devices/:id` - 장비 정보 수정
- `DELETE /api/devices/:id` - 장비 삭제
- `POST /api/devices/import` - Excel 파일 import
- `GET /api/devices/export` - Excel 파일 export

### QR 코드
- `GET /api/qr/device/:id` - 장비 QR 코드 생성
- `GET /api/qr/employee/:id` - 직원 QR 코드 생성
- `POST /api/qr/bulk-device` - 일괄 장비 QR 코드 생성
- `POST /api/qr/decode` - QR 코드 디코딩

## 🔍 모니터링 및 로그

### PM2 명령어

```bash
# 서비스 상태 확인
pm2 status

# 로그 확인
pm2 logs

# 실시간 모니터링
pm2 monit

# 서비스 재시작
pm2 restart all
```

### 로그 파일 위치

- **백엔드 로그**: `./logs/backend-*.log`
- **프론트엔드 로그**: `./logs/frontend-*.log`
- **Nginx 로그**: `/var/log/nginx/assetmanager_*.log`

## 🛡️ 보안 설정

### SSL/TLS
- TLS 1.2, 1.3 지원
- 강력한 암호화 스위트 사용
- HSTS 헤더 설정

### 인증
- JWT 토큰 기반 인증
- bcryptjs를 사용한 비밀번호 암호화
- 토큰 만료 시간 설정

### CORS
- 운영 환경에서 필요한 도메인만 허용
- 안전한 헤더 설정

## 🚨 문제 해결

### 일반적인 문제

1. **포트 충돌**
   ```bash
   # 사용 중인 포트 확인
   netstat -tlnp | grep :3000
   netstat -tlnp | grep :4000
   ```

2. **PM2 서비스가 시작되지 않는 경우**
   ```bash
   # PM2 재설치
   npm install -g pm2
   
   # 로그 확인
   pm2 logs
   ```

3. **Nginx 설정 오류**
   ```bash
   # 설정 문법 검사
   sudo nginx -t
   
   # Nginx 재시작
   sudo systemctl reload nginx
   ```

### 디버깅

1. **API 호출 문제**
   - 브라우저 개발자 도구의 Network 탭 확인
   - 백엔드 로그 확인: `pm2 logs assetmanager-backend`

2. **프론트엔드 문제**
   - 브라우저 콘솔 확인
   - 프론트엔드 로그 확인: `pm2 logs assetmanager-frontend`

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 지원

문제가 발생하거나 질문이 있으시면 다음을 확인해주세요:

1. **PM2 상태**: `pm2 status`
2. **로그 확인**: `pm2 logs`
3. **Nginx 상태**: `sudo systemctl status nginx`
4. **포트 확인**: `netstat -tlnp`

---

**작성일**: 2025-01-27  
**버전**: 1.0.0  
**작성자**: QR 자산관리 시스템 개발팀 