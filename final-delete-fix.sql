-- 2025-01-27: 최종 삭제 기능 활성화
-- Supabase SQL Editor에서 실행하세요

-- 기존 제약조건 삭제
ALTER TABLE device_history DROP CONSTRAINT device_history_action_type_check;

-- 새로운 제약조건 추가 ('삭제' 포함)
ALTER TABLE device_history ADD CONSTRAINT device_history_action_type_check 
CHECK (action_type IN ('등록', '할당', '반납', '폐기', '수정', '재할당', '삭제'));

-- 확인 메시지
SELECT '삭제 기능이 활성화되었습니다! 🎉' as result;
