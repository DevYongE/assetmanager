-- 즉시 삭제 기능 활성화
-- Supabase SQL Editor에서 실행하세요

ALTER TABLE device_history DROP CONSTRAINT device_history_action_type_check;
ALTER TABLE device_history ADD CONSTRAINT device_history_action_type_check 
CHECK (action_type IN ('등록', '할당', '반납', '폐기', '수정', '재할당', '삭제'));

SELECT '삭제 기능 활성화 완료!' as result;
