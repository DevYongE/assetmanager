-- 🚨 외래키 제약조건 수정으로 삭제 기능 활성화
-- Supabase SQL Editor에서 즉시 실행하세요!

-- 1. 기존 외래키 제약조건 삭제
ALTER TABLE device_history DROP CONSTRAINT device_history_device_id_fkey;

-- 2. 새로운 외래키 제약조건 추가 (CASCADE DELETE)
ALTER TABLE device_history ADD CONSTRAINT device_history_device_id_fkey 
FOREIGN KEY (device_id) REFERENCES personal_devices(id) ON DELETE CASCADE;

-- 3. action_type 제약조건도 함께 수정
ALTER TABLE device_history DROP CONSTRAINT IF EXISTS device_history_action_type_check;
ALTER TABLE device_history ADD CONSTRAINT device_history_action_type_check 
CHECK (action_type IN ('등록', '할당', '반납', '폐기', '수정', '재할당', '삭제'));

-- 4. 확인 메시지
SELECT '외래키 제약조건이 수정되어 삭제 기능이 활성화되었습니다! 🎉' as result;

-- 5. 현재 제약조건 확인
SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as definition 
FROM pg_constraint 
WHERE conrelid = 'device_history'::regclass 
AND conname IN ('device_history_device_id_fkey', 'device_history_action_type_check');
