-- 2025-01-27: employees 테이블에 email 컬럼 추가
-- Supabase SQL Editor에서 실행하세요

-- employees 테이블에 email 컬럼 추가
ALTER TABLE employees 
ADD COLUMN IF NOT EXISTS email VARCHAR(255);

-- email 컬럼에 대한 인덱스 생성 (선택사항)
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);

-- 완료 메시지
SELECT 'employees 테이블에 email 컬럼이 성공적으로 추가되었습니다!' as message;
