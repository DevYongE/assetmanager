-- 2025-01-27: 장비 히스토리 시스템 마이그레이션
-- Supabase SQL Editor에서 실행하세요

-- 1. device_history 테이블 생성
CREATE TABLE IF NOT EXISTS device_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  device_id UUID NOT NULL REFERENCES personal_devices(id) ON DELETE CASCADE,
  action_type VARCHAR(50) NOT NULL CHECK (action_type IN ('등록', '할당', '반납', '폐기', '수정', '재할당')),
  action_description TEXT,
  previous_status VARCHAR(50),
  new_status VARCHAR(50),
  performed_by UUID REFERENCES users(id),
  performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB DEFAULT '{}'::jsonb
);

-- 2. 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_device_history_device_id ON device_history(device_id);
CREATE INDEX IF NOT EXISTS idx_device_history_action_type ON device_history(action_type);
CREATE INDEX IF NOT EXISTS idx_device_history_performed_at ON device_history(performed_at DESC);

-- 3. 히스토리 트리거 함수 생성
CREATE OR REPLACE FUNCTION log_device_changes()
RETURNS TRIGGER AS $$
DECLARE
  action_type_val VARCHAR(50);
  action_desc TEXT;
  old_status VARCHAR(50);
  new_status_val VARCHAR(50);
BEGIN
  -- Determine action type and description based on employee_id changes
  IF TG_OP = 'INSERT' THEN
    action_type_val := '등록';
    action_desc := '새로운 장비가 등록되었습니다';
    new_status_val := CASE 
      WHEN NEW.employee_id IS NOT NULL THEN '할당됨'
      ELSE '미할당'
    END;
  ELSIF TG_OP = 'UPDATE' THEN
    -- Employee assignment change detection
    IF OLD.employee_id IS DISTINCT FROM NEW.employee_id THEN
      IF NEW.employee_id IS NOT NULL AND OLD.employee_id IS NULL THEN
        action_type_val := '할당';
        action_desc := '장비가 직원에게 할당되었습니다';
        old_status := '미할당';
        new_status_val := '할당됨';
      ELSIF NEW.employee_id IS NULL AND OLD.employee_id IS NOT NULL THEN
        action_type_val := '반납';
        action_desc := '장비가 반납되었습니다';
        old_status := '할당됨';
        new_status_val := '미할당';
      ELSE
        action_type_val := '재할당';
        action_desc := '장비가 다른 직원에게 재할당되었습니다';
        old_status := '할당됨';
        new_status_val := '할당됨';
      END IF;
    ELSE
      action_type_val := '수정';
      action_desc := '장비 정보가 수정되었습니다';
      new_status_val := CASE 
        WHEN NEW.employee_id IS NOT NULL THEN '할당됨'
        ELSE '미할당'
      END;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    action_type_val := '삭제';
    action_desc := '장비가 삭제되었습니다';
    old_status := CASE 
      WHEN OLD.employee_id IS NOT NULL THEN '할당됨'
      ELSE '미할당'
    END;
  END IF;
  
  -- Insert history record
  INSERT INTO device_history (
    device_id,
    action_type,
    action_description,
    previous_status,
    new_status,
    performed_by,
    metadata
  ) VALUES (
    COALESCE(NEW.id, OLD.id),
    action_type_val,
    action_desc,
    old_status,
    new_status_val,
    current_setting('request.jwt.claims', true)::json->>'sub',
    jsonb_build_object(
      'old_data', to_jsonb(OLD),
      'new_data', to_jsonb(NEW),
      'changed_fields', '{}'::jsonb
    )
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 4. 트리거 생성
DROP TRIGGER IF EXISTS trigger_device_history ON personal_devices;
CREATE TRIGGER trigger_device_history
  AFTER INSERT OR UPDATE OR DELETE ON personal_devices
  FOR EACH ROW EXECUTE FUNCTION log_device_changes();

-- 완료 메시지
SELECT '장비 히스토리 시스템이 성공적으로 설정되었습니다!' as message;
