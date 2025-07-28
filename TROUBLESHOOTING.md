# 로그인 실패 문제 해결 가이드

## 2025-01-27: Mixed Content 오류 및 URL 중복 문제 해결

### 문제 상황
1. **Mixed Content 오류**: HTTPS 페이지에서 HTTP 리소스 요청
   - `https://invenone.it.kr/login` → `http://invenone.it.kr/api/api/auth/login`
2. **URL 중복 문제**: `api/api/auth/login` (api가 두 번 들어감)
3. **404 Not Found**: API 엔드포인트를 찾을 수 없음
4. **CORS 오류**: 도메인 간 요청 차단

### 해결 방법

#### 1. API URL 설정 수정 (완료)
- Frontend: `nuxt.config.ts`에서 API Base URL에 `/api` 경로 추가
- Backend: CORS 설정에 HTTPS 도메인 추가

#### 2. 브라우저 캐시 완전 삭제
```bash
# Chrome/Edge에서:
# 1. F12 (개발자 도구 열기)
# 2. Network 탭 클릭
# 3. "Disable cache" 체크박스 활성화
# 4. Ctrl+Shift+R (강제 새로고침)
# 5. 또는 Ctrl+Shift+Delete로 캐시 삭제
```

#### 3. 서버 재시작
```bash
# 백엔드 서버 재시작 (4000 포트)
cd backend
npm start

# 프론트엔드 서버 재시작 (3000 포트)
cd frontend
npm run dev
```

#### 4. 포트 확인
```bash
# 백엔드가 4000 포트에서 실행 중인지 확인
netstat -an | findstr :4000

# 프론트엔드가 3000 포트에서 실행 중인지 확인
netstat -an | findstr :3000
```

#### 5. API URL 확인
브라우저 개발자 도구 콘솔에서 다음 로그 확인:
```
🔍 [API DEBUG] Environment: PRODUCTION
🔍 [API DEBUG] Base URL: https://invenone.it.kr/api
🔍 [API DEBUG] Endpoint: /auth/login
🔍 [API DEBUG] Production mode - trying HTTPS first: https://invenone.it.kr/api/auth/login
```

#### 6. 환경 변수 확인
```bash
# 프론트엔드에서 환경 변수 확인
echo $NODE_ENV
```

#### 7. 수동 API 테스트
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
- 브라우저 콘솔에 `🔍 [API DEBUG] Production mode - trying HTTPS first: https://invenone.it.kr/api/auth/login` 로그 표시
- 로그인 요청이 올바른 HTTPS URL로 전송됨
- Mixed Content 오류 해결
- CORS 오류 해결
- 로그인 성공

### 문제가 지속되는 경우
1. 모든 브라우저 탭 닫기
2. 브라우저 완전 종료 후 재시작
3. 서버 재시작
4. 다른 브라우저로 테스트

### Mixed Content 오류 해결 확인사항
- Backend 서버가 HTTPS를 지원하는지 확인
- CORS 설정에 HTTPS 도메인이 포함되어 있는지 확인
- API 요청이 올바른 HTTPS URL로 전송되는지 확인
- 브라우저에서 Mixed Content 차단 설정 확인

### URL 중복 문제 해결 확인사항
- `nuxt.config.ts`에서 API Base URL이 올바르게 설정되었는지 확인
- API 호출 시 `/api` 경로가 중복되지 않는지 확인
- 브라우저 개발자 도구에서 실제 요청 URL 확인 