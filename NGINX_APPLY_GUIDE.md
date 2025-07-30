# nginx 설정 적용 가이드

## 2025-01-27: nginx 설정 적용 및 MIME 타입 문제 해결

### ✅ 현재 상태
- nginx 설정 파일 문법 오류 해결됨
- 기본 설정이 정상적으로 작동함

### 🔧 다음 단계

#### 1. 실제 경로 확인 및 설정

Linux 서버에서 다음 명령어로 실제 경로를 확인:

```bash
# 현재 작업 디렉토리 확인
pwd

# 프론트엔드 빌드 파일 경로 확인
ls -la /home/dmanager/assetmanager/frontend/.output/public/_nuxt/

# 또는 다른 가능한 경로들
ls -la /var/www/html/frontend/.output/public/_nuxt/
ls -la /opt/assetmanager/frontend/.output/public/_nuxt/
```

#### 2. nginx 설정 파일 경로 수정

확인된 실제 경로로 `nginx-simple.conf` 파일을 수정:

```bash
# nginx 설정 파일 편집
sudo nano /etc/nginx/nginx.conf
```

다음 부분을 실제 경로로 수정:
```nginx
location /_nuxt/ {
    alias /실제/경로/frontend/.output/public/_nuxt/;
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

#### 3. 파일 권한 설정

```bash
# nginx 사용자가 파일에 접근할 수 있도록 권한 설정
sudo chown -R nginx:nginx /실제/경로/frontend/.output/public/
sudo chmod -R 755 /실제/경로/frontend/.output/public/
```

#### 4. nginx 설정 테스트 및 재시작

```bash
# 설정 파일 문법 검사
sudo nginx -t

# nginx 재시작
sudo systemctl restart nginx

# nginx 상태 확인
sudo systemctl status nginx
```

#### 5. 정적 파일 접근 테스트

```bash
# CSS 파일 접근 테스트
curl -I http://invenone.it.kr/_nuxt/entry.DBSXZB9p.css

# JavaScript 파일 접근 테스트
curl -I http://invenone.it.kr/_nuxt/CJ0ngp13.js
```

### 🚨 문제 해결

#### 1. 404 에러가 발생하는 경우
```bash
# 파일 경로 확인
ls -la /실제/경로/frontend/.output/public/_nuxt/

# nginx 설정에서 alias 경로 확인
grep -n "alias" /etc/nginx/nginx.conf
```

#### 2. MIME 타입이 여전히 잘못된 경우
```bash
# nginx 로그 확인
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# 브라우저 개발자 도구에서 Network 탭 확인
# Response Headers에서 Content-Type 확인
```

#### 3. 권한 문제가 발생하는 경우
```bash
# nginx 사용자 확인
ps aux | grep nginx

# 파일 권한 재설정
sudo chown -R nginx:nginx /실제/경로/frontend/.output/public/
sudo chmod -R 755 /실제/경로/frontend/.output/public/
```

### 📋 예상 결과

성공적으로 설정되면:
- CSS 파일이 `text/css` MIME 타입으로 서빙됨
- JavaScript 파일이 `application/javascript` MIME 타입으로 서빙됨
- 정적 파일들이 200 상태 코드로 로드됨
- 브라우저에서 스타일이 정상적으로 적용됨

### 🔍 확인 방법

1. **브라우저 개발자 도구**:
   - Network 탭에서 파일 요청 확인
   - Response Headers에서 Content-Type 확인
   - 200 상태 코드 확인

2. **curl 명령어**:
   ```bash
   curl -I http://invenone.it.kr/_nuxt/entry.DBSXZB9p.css
   ```

3. **nginx 로그**:
   ```bash
   sudo tail -f /var/log/nginx/access.log
   ``` 