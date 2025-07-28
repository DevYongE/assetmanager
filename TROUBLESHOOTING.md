# 로그인 실패 문제 해결 가이드

## 2025-01-27: 정적 파일 서빙 문제 및 MIME 타입 오류 해결

### 문제 상황
1. **CSS MIME 타입 오류**: CSS 파일이 `application/json` MIME 타입으로 서빙됨
2. **500 Internal Server Error**: JavaScript 파일들이 서버에서 제대로 서빙되지 않음
3. **Mixed Content 오류**: HTTPS 페이지에서 HTTP 리소스 요청
4. **DOM 경고**: Password input에 `autocomplete` 속성 누락

### 해결 방법

#### 1. Nuxt 설정 개선 (완료)
- `nuxt.config.ts`에서 Nitro 설정에 `static: true` 추가
- 정적 파일 서빙 활성화

#### 2. Password Input 수정 (완료)
- `login.vue`에서 password input에 `autocomplete="current-password"` 추가

#### 3. 브라우저 캐시 완전 삭제
```bash
# Chrome/Edge에서:
# 1. F12 (개발자 도구 열기)
# 2. Network 탭 클릭
# 3. "Disable cache" 체크박스 활성화
# 4. Ctrl+Shift+R (강제 새로고침)
# 5. 또는 Ctrl+Shift+Delete로 캐시 삭제
```

#### 4. 서버 재시작
```bash
# 백엔드 서버 재시작 (4000 포트)
cd backend
npm start

# 프론트엔드 서버 재시작 (3000 포트)
cd frontend
npm run dev
```

#### 5. 포트 확인
```bash
# 백엔드가 4000 포트에서 실행 중인지 확인
netstat -an | findstr :4000

# 프론트엔드가 3000 포트에서 실행 중인지 확인
netstat -an | findstr :3000
```

#### 6. API URL 확인
브라우저 개발자 도구 콘솔에서 다음 로그 확인:
```
🔍 [API DEBUG] Environment: PRODUCTION
🔍 [API DEBUG] Base URL: https://invenone.it.kr/api
🔍 [API DEBUG] Endpoint: /auth/login
🔍 [API DEBUG] Production mode - trying HTTPS first: https://invenone.it.kr/api/auth/login
```

#### 7. 환경 변수 확인
```bash
# 프론트엔드에서 환경 변수 확인
echo $NODE_ENV
```

#### 8. 수동 API 테스트
```bash
# 백엔드 헬스체크
curl https://invenone.it.kr/api/health

# 로그인 API 테스트
curl -X POST https://invenone.it.kr/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### 추가 디버깅

#### 1. 브라우저 개발자 도구에서 확인할 사항
- Network 탭에서 실제 요청 URL 확인
- Console 탭에서 API DEBUG 로그 확인
- Application 탭에서 localStorage 확인

#### 2. 서버 로그 확인
```bash
# 백엔드 서버 로그
cd backend
npm start

# 프론트엔드 서버 로그
cd frontend
npm run dev
```

### 예상 결과
성공적으로 수정되면:
- CSS 파일이 올바른 MIME 타입으로 서빙됨
- JavaScript 파일들이 정상적으로 로드됨
- Password input에 autocomplete 속성 추가됨
- Mixed Content 오류 해결
- CORS 오류 해결
- 로그인 성공

### 문제가 지속되는 경우
1. 모든 브라우저 탭 닫기
2. 브라우저 완전 종료 후 재시작
3. 서버 재시작
4. 다른 브라우저로 테스트

### 정적 파일 서빙 문제 해결 확인사항
- Nuxt 설정에서 `static: true` 설정 확인
- 빌드된 파일들이 `.output/public` 디렉토리에 있는지 확인
- 서버에서 정적 파일 경로가 올바르게 설정되었는지 확인
- MIME 타입이 올바르게 설정되었는지 확인

### MIME 타입 오류 해결 확인사항
- CSS 파일이 `text/css` MIME 타입으로 서빙되는지 확인
- JavaScript 파일이 `application/javascript` MIME 타입으로 서빙되는지 확인
- 브라우저 개발자 도구에서 파일 요청 헤더 확인 