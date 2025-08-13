-- 2025-01-27: employees 테이블 RLS 정책 수정 (서비스 역할 허용)
-- Supabase SQL Editor에서 실행하세요

-- 1. 기존 RLS 정책 삭제
DROP POLICY IF EXISTS "Users can only access their own employees" ON employees;
DROP POLICY IF EXISTS "Users can manage their own employees" ON employees;

-- 2. employees 테이블에 RLS 활성화 확인
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- 3. 새로운 RLS 정책 생성 (서비스 역할도 허용)
CREATE POLICY "Allow service role and authenticated users" ON employees
  FOR ALL USING (
    -- 서비스 역할이거나 (admin_id가 설정된 경우)
    -- 인증된 사용자이고 admin_id가 일치하는 경우
    (auth.role() = 'service_role') OR 
    (auth.uid() IS NOT NULL AND admin_id = auth.uid())
  )
  WITH CHECK (
    -- 서비스 역할이거나 (admin_id가 설정된 경우)
    -- 인증된 사용자이고 admin_id가 일치하는 경우
    (auth.role() = 'service_role') OR 
    (auth.uid() IS NOT NULL AND admin_id = auth.uid())
  );

-- 4. 현재 사용자 확인 (디버깅용)
SELECT 
  auth.uid() as current_user_id,
  auth.role() as current_role;

-- 완료 메시지
SELECT 'employees 테이블 RLS 정책이 성공적으로 수정되었습니다! (서비스 역할 허용)' as message;
