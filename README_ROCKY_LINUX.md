# QR 자산관리 시스템 - Rocky Linux 배포 가이드 (Supabase 기반)

## 📋 개요

이 문서는 Rocky Linux 서버에 QR 자산관리 시스템을 배포하는 방법을 설명합니다.
**Supabase**를 데이터베이스로 사용하는 Node.js 백엔드와 Nuxt.js 프론트엔드로 구성됩니다.

## 🚀 빠른 배포

### 1. 서버 접속
```bash
ssh dmanager@your-server-ip
```

### 2. 프로젝트 준비
```bash
# 프로젝트 루트 디렉토리로 이동 (중요!)
cd /path/to/your/project  # backend, frontend 폴더가 있는 디렉토리
```

### 3. 배포 스크립트 실행
```bash
# 스크립트 실행 권한 부여
chmod +x deploy_rocky_linux.sh

# 배포 실행
./deploy_rocky_linux.sh
```

**중요**: 
- 스크립트는 `backend`와 `frontend` 폴더가 있는 프로젝트 루트 디렉토리에서 실행해야 합니다.
- 만약 이미 `/home/dmanager/assetmanager` 디렉토리에서 실행한다면, 기존 프로젝트를 유지하는 옵션을 선택하세요.

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

### Node.js 의존성 충돌 해결 (2025-08-08 추가)

npm과 nodejs 버전 충돌이 발생하는 경우:

```bash
# Node.js 충돌 해결 스크립트 실행
chmod +x /home/dmanager/fix_nodejs_conflict.sh
./fix_nodejs_conflict.sh
```

**수동 해결 방법:**
```bash
# 1. 기존 Node.js 패키지 제거
sudo dnf remove -y nodejs npm nsolid*

# 2. 저장소 정리
sudo rm -f /etc/yum.repos.d/nodesource-nsolid.repo
sudo dnf clean all

# 3. Node.js 18.x LTS 재설치
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs

# 4. 설치 확인
node --version
npm --version
```

### PM2 권한 문제 해결 (2025-08-08 추가)

PM2 글로벌 설치 시 `EACCES` 권한 오류가 발생하는 경우:

```bash
# PM2 권한 문제 해결 스크립트 실행
chmod +x /home/dmanager/fix_pm2_permissions.sh
./fix_pm2_permissions.sh
```

**수동 해결 방법:**
```bash
# 방법 1: 사용자 홈 디렉토리에 설치 (권장)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
npm install -g pm2

# 방법 2: npm 글로벌 디렉토리 권한 수정
sudo chown -R $(whoami):$(whoami) $(npm config get prefix)
npm install -g pm2

# 방법 3: sudo 사용 (임시 해결책)
sudo npm install -g pm2
```

### 프로젝트 파일 복구 (2025-08-08 추가)

프로젝트 파일 복사 실패 시 `cp: cannot stat` 오류가 발생하는 경우:

```bash
# 프로젝트 파일 복구 스크립트 실행
chmod +x /home/dmanager/fix_project_files.sh
./fix_project_files.sh
```

**수동 해결 방법:**
```bash
# 1. 현재 디렉토리 확인
pwd
ls -la

# 2. 프로젝트 파일 위치 찾기
find /home/dmanager -name "backend" -type d 2>/dev/null
find /home/dmanager -name "frontend" -type d 2>/dev/null

# 3. 수동으로 파일 복사
mkdir -p /home/dmanager/assetmanager
cp -r /path/to/backend /home/dmanager/assetmanager/
cp -r /path/to/frontend /home/dmanager/assetmanager/

# 4. 권한 설정
sudo chown -R dmanager:dmanager /home/dmanager/assetmanager
```

### Supabase 환경변수 설정 (2025-08-08 추가)

Supabase 환경변수 누락 오류가 발생하는 경우:

```bash
# Supabase 환경변수 설정 스크립트 실행
chmod +x /home/dmanager/setup_supabase_env.sh
./setup_supabase_env.sh
```

**수동 해결 방법:**
```bash
# 1. .env 파일 편집
nano /home/dmanager/assetmanager/backend/.env

# 2. 다음 값들을 실제 Supabase 값으로 변경:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_actual_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_actual_service_role_key
JWT_SECRET=your_random_secret_key

# 3. 환경변수 테스트
cd /home/dmanager/assetmanager/backend
node -e "require('dotenv').config(); console.log('SUPABASE_URL:', process.env.SUPABASE_URL ? 'SET' : 'MISSING');"
```

**환경변수 로드 문제 해결:**
만약 `dotenv`가 환경변수를 로드했지만 백엔드에서 여전히 `MISSING`으로 표시되는 경우:
```bash
# 백엔드 디렉토리에서 직접 테스트
cd /home/dmanager/assetmanager/backend
node run-migration.js
```

### oxc-parser 네이티브 바인딩 문제 해결 (2025-08-08 추가)

프론트엔드 빌드 시 `Cannot find native binding` 오류가 발생하는 경우:

#### 자동 해결 방법
```bash
# oxc-parser 문제 해결 스크립트 실행
chmod +x /home/dmanager/fix_oxc_parser.sh
./fix_oxc_parser.sh
```

#### 수동 해결 방법 (단계별)

**1단계: 기본 해결**
```bash
# 1. 프론트엔드 디렉토리로 이동
cd /home/dmanager/assetmanager/frontend

# 2. 기존 의존성 제거
rm -rf node_modules package-lock.json

# 3. npm 캐시 정리
npm cache clean --force

# 4. 의존성 재설치
npm install

# 5. oxc-parser 강제 재빌드
npm rebuild oxc-parser

# 6. 빌드 테스트
npm run build:prod
```

**2단계: oxc-parser 완전 제거 (1단계 실패 시)**
```bash
# 1. oxc-parser 완전 제거
npm uninstall oxc-parser

# 2. ESLint 설정으로 우회
# (이미 eslint.config.mjs가 oxc-parser 우회 설정으로 업데이트됨)

# 3. 의존성 재설치
npm install

# 4. 빌드 테스트
npm run build:prod
```

**3단계: 시스템 레벨 해결 (2단계 실패 시)**
```bash
# 1. 개발 도구 설치
sudo dnf groupinstall 'Development Tools'

# 2. 시스템 패키지 업데이트
sudo dnf update

# 3. Node.js 버전 확인 (18.x 권장)
node --version

# 4. 다시 1단계 시도
```

#### 문제 원인
- **npm optional dependencies 버그**: https://github.com/npm/cli/issues/4828
- **oxc-parser 네이티브 바인딩**: Linux 환경에서 네이티브 바인딩 로드 실패
- **ESLint 의존성**: oxc-parser가 ESLint의 의존성으로 자동 설치됨

#### 해결책 적용 사항 (2025-08-08)
1. **package.json 개선**: oxc-parser 해결 스크립트 및 overrides 추가
2. **ESLint 설정 우회**: oxc-parser 대신 기본 파서 사용
3. **배포 스크립트 강화**: 다단계 oxc-parser 문제 해결 로직 추가
4. **독립 해결 스크립트**: oxc-parser 전용 문제 해결 도구 제공

#### 예상 결과
- ✅ oxc-parser 네이티브 바인딩 문제 해결
- ✅ 프론트엔드 빌드 성공
- ✅ ESLint 기능 정상 작동 (oxc-parser 우회)
- ✅ 전체 배포 프로세스 완료

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

### TDD 스타일 배포 검증 테스트 (2025-08-08 추가)

TDD(Test-Driven Development) 원칙에 따라 배포 프로세스의 모든 단계를 검증하는 테스트 시스템을 구축했습니다.

#### 🧪 TDD 테스트 스크립트 실행
```bash
# 배포 검증 테스트 실행
chmod +x /home/dmanager/test-deployment.sh
./test-deployment.sh
```

#### 📋 검증 항목 (9개 카테고리)

**1. 환경 검증 테스트**
- ✅ Node.js 버전 (18.x 이상)
- ✅ npm 설치 및 버전
- ✅ Git 설치 및 버전
- ✅ 프로젝트 디렉토리 구조
- ✅ 필수 파일 존재 여부

**2. 의존성 검증 테스트**
- ✅ 백엔드 핵심 패키지 (express, supabase, bcryptjs 등)
- ✅ 프론트엔드 핵심 패키지 (nuxt, vue, pinia 등)
- ✅ oxc-parser 네이티브 바인딩 상태
- ✅ node_modules 설치 상태

**3. 환경변수 검증 테스트**
- ✅ 백엔드 .env 파일 존재
- ✅ 필수 환경변수 설정 (SUPABASE_URL, JWT_SECRET 등)
- ✅ Supabase 클라이언트 생성 가능

**4. 빌드 검증 테스트**
- ✅ 백엔드 빌드 성공
- ✅ 프론트엔드 빌드 성공 (oxc-parser 우회 포함)

**5. 서비스 검증 테스트**
- ✅ PM2 설치 및 프로세스 실행
- ✅ Nginx 설치 및 설정 유효성
- ✅ 포트 사용 상태 (80, 443, 4000)

**6. API 검증 테스트**
- ✅ 백엔드 API 헬스체크 응답
- ✅ 프론트엔드 접근 가능
- ✅ HTTPS 리다이렉트 작동

**7. 보안 검증 테스트**
- ✅ SSL 인증서 유효성
- ✅ 방화벽 설정 (HTTP/HTTPS 허용)

**8. 성능 검증 테스트**
- ✅ API 응답 시간 (1초 미만)
- ✅ 메모리 사용량 (500MB 미만)

**9. 테스트 결과 요약**
- 📊 총 테스트 수, 성공/실패 통계
- 🎯 성공률 계산 및 최종 판정

#### 🔧 TDD 테스트 결과 해석

**모든 테스트 통과 시:**
```
🎉 모든 테스트 통과! 배포가 성공적으로 완료되었습니다.

✅ 배포 검증 완료 사항:
   - 환경 요구사항 충족
   - 의존성 설치 완료
   - 환경변수 설정 완료
   - 빌드 성공
   - 서비스 실행 중
   - API 정상 작동
   - 보안 설정 완료
   - 성능 기준 충족

🌐 접속 URL: https://invenone.it.kr
🔧 관리 도구: /home/dmanager/fix_oxc_parser.sh
📋 로그 확인: pm2 logs assetmanager
```

**일부 테스트 실패 시:**
```
❌ X개 테스트 실패. 배포에 문제가 있습니다.

🔧 해결 방법:
   1. oxc-parser 문제 해결: ./fix_oxc_parser.sh
   2. 환경변수 설정: ./setup_supabase_env.sh
   3. 전체 재배포: ./deploy_rocky_linux.sh
   4. 시스템 진단: ./troubleshoot.sh

📋 실패한 테스트:
   - [실패한 테스트 목록]
```

#### 🚀 자동화된 TDD 검증

배포 스크립트에 TDD 검증이 자동으로 포함되어 있습니다:

```bash
# 배포 실행 (TDD 검증 포함)
./deploy_rocky_linux.sh

# 또는 수동 검증
./test-deployment.sh
```

#### 📈 TDD 검증의 장점

1. **자동화된 검증**: 수동 확인 대신 자동화된 테스트
2. **포괄적 검사**: 9개 카테고리, 30+ 개별 테스트
3. **실시간 피드백**: 즉시 문제점 식별 및 해결 방법 제시
4. **성능 모니터링**: 응답 시간, 메모리 사용량 등 성능 지표
5. **보안 검증**: SSL, 방화벽 등 보안 설정 확인
6. **재사용 가능**: 언제든지 재실행 가능한 검증 도구

#### 🎯 TDD 원칙 적용

- **테스트 우선**: 배포 전 검증 로직 먼저 작성
- **지속적 검증**: 배포 과정의 모든 단계 검증
- **자동화**: 수동 개입 최소화
- **피드백 루프**: 실패 시 즉시 해결 방법 제시
- **품질 보장**: 모든 배포가 동일한 품질 기준 통과

이제 배포 프로세스가 TDD 원칙에 따라 완전히 검증되며, 문제 발생 시 즉시 식별하고 해결할 수 있습니다. 