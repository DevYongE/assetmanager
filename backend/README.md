# QR Asset Management Backend

QR 코드를 이용한 자산 관리 시스템의 백엔드 API 서버입니다.

## 📋 주요 기능

- **사용자 관리**: 회원가입, 로그인, 프로필 관리
- **직원 관리**: 직원 등록, 수정, 삭제
- **장비 관리**: 개인 장비 등록, 수정, 삭제
- **QR 코드**: 장비별 QR 코드 생성 및 관리
- **Excel 연동**: 장비 정보 가져오기/내보내기
- **대시보드**: 통계 및 요약 정보 제공

## 🛠 기술 스택

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL)
- **Authentication**: JWT (JSON Web Token)
- **Password Hashing**: bcryptjs
- **QR Code**: qrcode
- **File Upload**: multer
- **Excel Processing**: xlsx

## 🗄 데이터베이스 스키마

### users 테이블
```sql
- id (uuid, primary key)
- email (varchar, unique)
- password_hash (varchar)
- created_at (timestamp)
```

### employees 테이블
```sql
- id (uuid, primary key)
- admin_id (uuid, foreign key -> users.id)
- department (varchar)
- position (varchar)
- name (varchar)
- company_name (varchar)
- created_at (timestamp)
```

### personal_devices 테이블
```sql
- id (uuid, primary key)
- employee_id (uuid, foreign key -> employees.id)
- asset_number (varchar, unique)
- manufacturer (varchar)
- model_name (varchar)
- serial_number (varchar)
- cpu (varchar)
- memory (varchar)
- storage (varchar)
- gpu (varchar)
- os (varchar)
- monitor (varchar)
- created_at (timestamp)
```

## ⚙️ 설정

### 1. 환경 변수 설정

`.env` 파일을 생성하고 다음 정보를 설정하세요:

```bash
PORT=3000
NODE_ENV=development

# Supabase 설정
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# JWT 시크릿 키
JWT_SECRET=your_jwt_secret_here_change_this_to_something_secure
```

### 2. 데이터베이스 마이그레이션

데이터베이스 스키마를 업데이트하려면 `migration.sql` 파일의 SQL을 실행하세요:

```sql
-- Supabase SQL Editor에서 실행하거나
-- psql을 통해 직접 실행하세요

-- Step 1: Add company_name column to employees table
ALTER TABLE employees ADD COLUMN company_name VARCHAR;

-- Step 2: Copy company_name from users to employees
UPDATE employees 
SET company_name = (
  SELECT company_name 
  FROM users 
  WHERE users.id = employees.admin_id
);

-- Step 3: Make company_name NOT NULL in employees table
ALTER TABLE employees ALTER COLUMN company_name SET NOT NULL;

-- Step 4: Remove company_name from users table
ALTER TABLE users DROP COLUMN company_name;

-- Step 5: Add index for better performance
CREATE INDEX idx_employees_company_name ON employees(company_name);
```

### 3. 의존성 설치

```bash
npm install
```

### 4. 서버 실행

#### 개발 모드 (nodemon 사용)
```bash
npm run dev
```

#### 프로덕션 모드
```bash
npm start
```

## 🚀 API 엔드포인트

### 인증 (Authentication)
- `POST /api/auth/register` - 회원가입
- `POST /api/auth/login` - 로그인
- `GET /api/auth/profile` - 프로필 조회
- `PUT /api/auth/profile` - 프로필 수정

### 사용자 (Users)
- `GET /api/users/stats` - 사용자 통계 조회
- `GET /api/users/dashboard` - 대시보드 데이터 조회

### 직원 (Employees)
- `GET /api/employees` - 직원 목록 조회
- `GET /api/employees/:id` - 특정 직원 조회
- `POST /api/employees` - 직원 추가
- `PUT /api/employees/:id` - 직원 수정
- `DELETE /api/employees/:id` - 직원 삭제

### 장비 (Devices)
- `GET /api/devices` - 장비 목록 조회
- `GET /api/devices/:id` - 특정 장비 조회
- `POST /api/devices` - 장비 추가
- `PUT /api/devices/:id` - 장비 수정
- `DELETE /api/devices/:id` - 장비 삭제
- `POST /api/devices/import` - Excel 파일로 장비 가져오기
- `GET /api/devices/export/excel` - Excel 파일로 장비 내보내기

### QR 코드 (QR Codes)
- `GET /api/qr/device/:id` - 장비 QR 코드 생성
- `GET /api/qr/employee/:id` - 직원 QR 코드 생성
- `POST /api/qr/bulk/devices` - 여러 장비 QR 코드 일괄 생성
- `POST /api/qr/decode` - QR 코드 디코딩

## 📝 사용 예시

### 1. 회원가입
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password123",
    "company_name": "My Company"
  }'
```

### 2. 로그인
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password123"
  }'
```

### 3. 직원 추가 (토큰 필요)
```bash
curl -X POST http://localhost:3000/api/employees \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "홍길동",
    "department": "개발팀",
    "position": "개발자"
  }'
```

### 4. 장비 추가 (토큰 필요)
```bash
curl -X POST http://localhost:3000/api/devices \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "employee_id": "EMPLOYEE_UUID",
    "asset_number": "AS001",
    "manufacturer": "Samsung",
    "model_name": "Galaxy Book",
    "serial_number": "SN123456",
    "cpu": "Intel i7",
    "memory": "16GB",
    "storage": "512GB SSD"
  }'
```

### 5. QR 코드 생성
```bash
# PNG 형태로 QR 코드 생성
curl http://localhost:3000/api/qr/device/DEVICE_UUID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  --output qrcode.png

# JSON 형태로 QR 데이터 조회
curl http://localhost:3000/api/qr/device/DEVICE_UUID?format=json \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 📊 Excel 가져오기 형식

Excel 파일을 이용해 장비를 일괄 등록할 때 다음 컬럼이 필요합니다:

| 컬럼명 | 필수 | 설명 |
|--------|------|------|
| employee_name | ✅ | 직원 이름 (기존에 등록된 직원) |
| asset_number | ✅ | 자산 번호 (고유값) |
| manufacturer | ❌ | 제조사 |
| model_name | ❌ | 모델명 |
| serial_number | ❌ | 시리얼 번호 |
| cpu | ❌ | CPU 정보 |
| memory | ❌ | 메모리 정보 |
| storage | ❌ | 저장장치 정보 |
| gpu | ❌ | GPU 정보 |
| os | ❌ | 운영체제 |
| monitor | ❌ | 모니터 정보 |

## 🔒 보안

- 모든 비밀번호는 bcryptjs를 사용해 해시화
- JWT 토큰을 사용한 인증
- Supabase RLS (Row Level Security) 활용
- CORS 설정으로 크로스 오리진 요청 제어

## 🎯 향후 개선사항

- [ ] 역할 기반 접근 제어 (RBAC)
- [ ] 장비 사용 이력 추적
- [ ] 알림 시스템
- [ ] API 속도 제한 (Rate Limiting)
- [ ] 파일 업로드 최적화
- [ ] 로그 시스템 개선

## 🐛 문제 해결

### 1. Supabase 연결 오류
- `.env` 파일의 Supabase 설정을 확인하세요
- Supabase 프로젝트가 활성화되어 있는지 확인하세요

### 2. JWT 토큰 오류
- JWT_SECRET이 올바르게 설정되어 있는지 확인하세요
- 토큰이 만료되지 않았는지 확인하세요

### 3. 파일 업로드 오류
- 파일 크기가 10MB를 초과하지 않는지 확인하세요
- Excel 파일 형식이 올바른지 확인하세요

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 등록해 주세요. 