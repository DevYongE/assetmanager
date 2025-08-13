-- 🚨 긴급: 삭제 기능 활성화
-- Supabase SQL Editor에서 즉시 실행하세요!

-- 1. 기존 제약조건 삭제
ALTER TABLE device_history DROP CONSTRAINT device_history_action_type_check;

-- 2. 새로운 제약조건 추가 ('삭제' 포함)
ALTER TABLE device_history ADD CONSTRAINT device_history_action_type_check 
CHECK (action_type IN ('등록', '할당', '반납', '폐기', '수정', '재할당', '삭제'));

-- 3. 확인 메시지
SELECT '삭제 기능이 활성화되었습니다! 🎉' as result;

-- 4. 현재 제약조건 확인
SELECT conname, pg_get_constraintdef(oid) as definition 
FROM pg_constraint 
WHERE conrelid = 'device_history'::regclass 
AND conname = 'device_history_action_type_check';
