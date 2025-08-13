-- 2025-01-27: employees 테이블 RLS 정책 수정
-- Supabase SQL Editor에서 실행하세요

-- 1. 기존 RLS 정책 삭제
DROP POLICY IF EXISTS "Users can only access their own employees" ON employees;

-- 2. employees 테이블에 RLS 활성화 확인
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- 3. 새로운 RLS 정책 생성 (INSERT, SELECT, UPDATE, DELETE 모두 허용)
CREATE POLICY "Users can manage their own employees" ON employees
  FOR ALL USING (admin_id = auth.uid())
  WITH CHECK (admin_id = auth.uid());

-- 4. 또는 더 구체적인 정책들로 분리할 수도 있습니다:
-- CREATE POLICY "Users can view their own employees" ON employees
--   FOR SELECT USING (admin_id = auth.uid());

-- CREATE POLICY "Users can insert their own employees" ON employees
--   FOR INSERT WITH CHECK (admin_id = auth.uid());

-- CREATE POLICY "Users can update their own employees" ON employees
--   FOR UPDATE USING (admin_id = auth.uid())
--   WITH CHECK (admin_id = auth.uid());

-- CREATE POLICY "Users can delete their own employees" ON employees
--   FOR DELETE USING (admin_id = auth.uid());

-- 5. 현재 사용자 확인 (디버깅용)
SELECT auth.uid() as current_user_id;

-- 완료 메시지
SELECT 'employees 테이블 RLS 정책이 성공적으로 수정되었습니다!' as message;
