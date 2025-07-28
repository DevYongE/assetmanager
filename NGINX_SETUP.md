# nginx 설정 가이드

## 2025-01-27: MIME 타입 오류 해결을 위한 nginx 설정

### 문제 상황
- CSS 파일이 `application/json` MIME 타입으로 서빙됨
- JavaScript 파일들이 500 에러 발생
- 정적 파일 경로가 올바르게 설정되지 않음

### 해결 방법

#### 1. nginx 설정 파일 적용

```bash
# nginx 설정 파일 백업
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# 새로운 설정 파일 적용
sudo cp nginx.conf /etc/nginx/nginx.conf

# 설정 파일 문법 검사
sudo nginx -t

# nginx 재시작
sudo systemctl restart nginx
```

#### 2. 경로 설정 수정

nginx.conf 파일에서 다음 경로를 실제 경로로 수정:

```nginx
# 정적 파일 경로 수정
location /_nuxt/ {
    alias /path/to/your/frontend/.output/public/_nuxt/;
    # 실제 경로로 변경:
    # alias /home/user/qrasset/assetmanager/frontend/.output/public/_nuxt/;
}
```

#### 3. 파일 권한 확인

```bash
# nginx 사용자가 파일에 접근할 수 있도록 권한 설정
sudo chown -R www-data:www-data /path/to/your/frontend/.output/public/
sudo chmod -R 755 /path/to/your/frontend/.output/public/
```

#### 4. nginx 로그 확인

```bash
# nginx 에러 로그 확인
sudo tail -f /var/log/nginx/error.log

# nginx 액세스 로그 확인
sudo tail -f /var/log/nginx/access.log
```

### 설정 확인 사항

#### 1. MIME 타입 설정
- CSS 파일: `text/css`
- JavaScript 파일: `application/javascript`
- JSON 파일: `application/json`

#### 2. 정적 파일 경로
- `/_nuxt/` 경로가 올바르게 설정되었는지 확인
- 파일이 실제로 해당 경로에 존재하는지 확인

#### 3. 파일 권한
- nginx 사용자가 파일에 읽기 권한을 가지고 있는지 확인
- 디렉토리 구조가 올바른지 확인

### 문제 해결

#### 1. 404 에러가 발생하는 경우
```bash
# 파일 경로 확인
ls -la /path/to/your/frontend/.output/public/_nuxt/

# nginx 설정에서 alias 경로 확인
grep -n "alias" /etc/nginx/nginx.conf
```

#### 2. 500 에러가 발생하는 경우
```bash
# nginx 에러 로그 확인
sudo tail -f /var/log/nginx/error.log

# nginx 프로세스 상태 확인
sudo systemctl status nginx
```

#### 3. MIME 타입이 여전히 잘못된 경우
```bash
# nginx 설정 파일에서 types 블록 확인
grep -A 10 "types" /etc/nginx/nginx.conf

# nginx 재시작
sudo systemctl restart nginx
```

### 테스트 방법

#### 1. 정적 파일 접근 테스트
```bash
# CSS 파일 접근 테스트
curl -I https://invenone.it.kr/_nuxt/entry.DBSXZB9p.css

# JavaScript 파일 접근 테스트
curl -I https://invenone.it.kr/_nuxt/CJ0ngp13.js
```

#### 2. 브라우저에서 확인
- 개발자 도구 Network 탭에서 파일 요청 확인
- Response Headers에서 Content-Type 확인
- 200 상태 코드 확인

### 예상 결과
성공적으로 설정되면:
- CSS 파일이 `text/css` MIME 타입으로 서빙됨
- JavaScript 파일이 `application/javascript` MIME 타입으로 서빙됨
- 정적 파일들이 200 상태 코드로 로드됨
- 브라우저에서 스타일이 정상적으로 적용됨 