-- 2025-01-27: 장비 히스토리 시스템 마이그레이션 (파라미터화된 메시지 템플릿 + 상세 변경 내역)
-- Supabase SQL Editor에서 실행하세요

-- 1. device_history 테이블 생성
CREATE TABLE IF NOT EXISTS device_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  device_id UUID NOT NULL REFERENCES personal_devices(id) ON DELETE CASCADE,
  action_type VARCHAR(50) NOT NULL CHECK (action_type IN ('등록', '할당', '반납', '폐기', '수정', '재할당', '삭제')),
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

-- 3. 메시지 템플릿 설정 테이블 생성
CREATE TABLE IF NOT EXISTS history_message_templates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  action_type VARCHAR(50) NOT NULL UNIQUE,
  template TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. 기본 메시지 템플릿 삽입
INSERT INTO history_message_templates (action_type, template, description) VALUES
  ('등록', '{employee_name}에게 할당된 새로운 장비가 등록되었습니다', '장비 등록 시 메시지'),
  ('등록_미할당', '새로운 장비가 등록되었습니다 (미할당)', '미할당 장비 등록 시 메시지'),
  ('할당', '장비가 {employee_name}에게 할당되었습니다', '장비 할당 시 메시지'),
  ('반납', '{employee_name}이 반납하였습니다', '장비 반납 시 메시지'),
  ('폐기', '{employee_name}이 폐기하였습니다', '장비 폐기 시 메시지'),
  ('재할당', '장비가 {old_employee_name}에서 {new_employee_name}에게 재할당되었습니다', '장비 재할당 시 메시지'),
  ('수정', '장비 정보가 수정되었습니다', '장비 수정 시 메시지'),
  ('수정_상세', '{changed_fields}가 변경되었습니다', '장비 수정 상세 시 메시지'),
  ('삭제', '장비가 삭제되었습니다 ({employee_name}에게 할당된 상태)', '장비 삭제 시 메시지'),
  ('삭제_미할당', '장비가 삭제되었습니다 (미할당 상태)', '미할당 장비 삭제 시 메시지')
ON CONFLICT (action_type) DO UPDATE SET
  template = EXCLUDED.template,
  description = EXCLUDED.description,
  updated_at = NOW();

-- 5. 메시지 템플릿 처리 함수 생성 (함수 오버로딩 문제 해결)
DROP FUNCTION IF EXISTS get_history_message(VARCHAR, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS get_history_message(VARCHAR, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION get_history_message(
  p_action_type VARCHAR(50),
  p_employee_name TEXT DEFAULT NULL,
  p_old_employee_name TEXT DEFAULT NULL,
  p_new_employee_name TEXT DEFAULT NULL,
  p_changed_fields TEXT DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
  template_text TEXT;
  result_message TEXT;
BEGIN
  -- 템플릿 가져오기
  SELECT template INTO template_text
  FROM history_message_templates
  WHERE history_message_templates.action_type = p_action_type;
  
  -- 템플릿이 없으면 기본 메시지 반환
  IF template_text IS NULL THEN
    RETURN p_action_type || ' 처리되었습니다';
  END IF;
  
  -- 템플릿 변수 치환
  result_message := template_text;
  
  -- {employee_name} 치환
  IF p_employee_name IS NOT NULL THEN
    result_message := REPLACE(result_message, '{employee_name}', p_employee_name);
  ELSE
    result_message := REPLACE(result_message, '{employee_name}', '담당직원');
  END IF;
  
  -- {old_employee_name} 치환
  IF p_old_employee_name IS NOT NULL THEN
    result_message := REPLACE(result_message, '{old_employee_name}', p_old_employee_name);
  ELSE
    result_message := REPLACE(result_message, '{old_employee_name}', '알 수 없는 직원');
  END IF;
  
  -- {new_employee_name} 치환
  IF p_new_employee_name IS NOT NULL THEN
    result_message := REPLACE(result_message, '{new_employee_name}', p_new_employee_name);
  ELSE
    result_message := REPLACE(result_message, '{new_employee_name}', '알 수 없는 직원');
  END IF;
  
  -- {changed_fields} 치환
  IF p_changed_fields IS NOT NULL THEN
    result_message := REPLACE(result_message, '{changed_fields}', p_changed_fields);
  ELSE
    result_message := REPLACE(result_message, '{changed_fields}', '정보');
  END IF;
  
  RETURN result_message;
END;
$$ LANGUAGE plpgsql;

-- 6. 변경된 필드 감지 및 상세 메시지 생성 함수
CREATE OR REPLACE FUNCTION get_changed_fields_detail(
  old_record RECORD,
  new_record RECORD
) RETURNS JSONB AS $$
DECLARE
  changed_fields JSONB := '{}'::jsonb;
  field_names TEXT[] := ARRAY[
    'asset_number', 'manufacturer', 'model_name', 'serial_number', 
    'purpose', 'device_type', 'cpu', 'memory', 'storage', 'gpu', 
    'os', 'monitor', 'monitor_size', 'inspection_date', 'issue_date'
  ];
  field_name TEXT;
  old_value TEXT;
  new_value TEXT;
  field_labels JSONB := '{
    "asset_number": "자산번호",
    "manufacturer": "제조사", 
    "model_name": "모델명",
    "serial_number": "시리얼 번호",
    "purpose": "용도",
    "device_type": "장비 타입",
    "cpu": "CPU",
    "memory": "메모리",
    "storage": "저장장치",
    "gpu": "그래픽카드",
    "os": "운영체제",
    "monitor": "모니터",
    "monitor_size": "모니터 크기",
    "inspection_date": "조사일자",
    "issue_date": "지급일자"
  }'::jsonb;
BEGIN
  -- 각 필드를 순회하며 변경사항 확인
  FOREACH field_name IN ARRAY field_names
  LOOP
    -- OLD와 NEW의 값 비교
    EXECUTE format('SELECT ($1).%I::text, ($2).%I::text', field_name, field_name)
    INTO old_value, new_value
    USING old_record, new_record;
    
    -- 값이 다르면 변경사항으로 기록
    IF old_value IS DISTINCT FROM new_value THEN
      changed_fields := changed_fields || jsonb_build_object(
        field_name,
        jsonb_build_object(
          'label', COALESCE(field_labels->>field_name, field_name),
          'old_value', COALESCE(old_value, ''),
          'new_value', COALESCE(new_value, '')
        )
      );
    END IF;
  END LOOP;
  
  RETURN changed_fields;
END;
$$ LANGUAGE plpgsql;

-- 7. 변경된 필드 목록을 텍스트로 변환하는 함수
CREATE OR REPLACE FUNCTION get_changed_fields_text(
  changed_fields JSONB
) RETURNS TEXT AS $$
DECLARE
  field_name TEXT;
  field_data JSONB;
  field_labels TEXT[] := ARRAY[]::TEXT[];
BEGIN
  -- 변경된 필드들의 라벨을 배열로 수집
  FOR field_name, field_data IN SELECT * FROM jsonb_each(changed_fields)
  LOOP
    field_labels := array_append(field_labels, field_data->>'label');
  END LOOP;
  
  -- 배열을 쉼표로 구분된 텍스트로 변환
  RETURN array_to_string(field_labels, ', ');
END;
$$ LANGUAGE plpgsql;

-- 8. 히스토리 트리거 함수 생성 (상세 변경 내역 포함)
CREATE OR REPLACE FUNCTION log_device_changes()
RETURNS TRIGGER AS $$
DECLARE
  action_type_val VARCHAR(50);
  action_desc TEXT;
  old_status VARCHAR(50);
  new_status_val VARCHAR(50);
  old_employee_name TEXT;
  new_employee_name TEXT;
  old_employee_id UUID;
  new_employee_id UUID;
  changed_fields JSONB;
  changed_fields_text TEXT;
BEGIN
  -- Get employee information for better descriptions
  IF TG_OP = 'UPDATE' AND OLD.employee_id IS NOT NULL THEN
    SELECT name INTO old_employee_name FROM employees WHERE id = OLD.employee_id;
    old_employee_id := OLD.employee_id;
  END IF;
  
  IF TG_OP IN ('INSERT', 'UPDATE') AND NEW.employee_id IS NOT NULL THEN
    SELECT name INTO new_employee_name FROM employees WHERE id = NEW.employee_id;
    new_employee_id := NEW.employee_id;
  END IF;

  -- Determine action type and description based on employee_id changes
  IF TG_OP = 'INSERT' THEN
    action_type_val := '등록';
    IF NEW.employee_id IS NOT NULL THEN
      action_desc := get_history_message('등록', new_employee_name);
    ELSE
      action_desc := get_history_message('등록_미할당');
    END IF;
    new_status_val := CASE 
      WHEN NEW.employee_id IS NOT NULL THEN '할당됨'
      ELSE '미할당'
    END;
  ELSIF TG_OP = 'UPDATE' THEN
    -- Employee assignment change detection
    IF OLD.employee_id IS DISTINCT FROM NEW.employee_id THEN
      IF NEW.employee_id IS NOT NULL AND OLD.employee_id IS NULL THEN
        action_type_val := '할당';
        action_desc := get_history_message('할당', new_employee_name);
        old_status := '미할당';
        new_status_val := '할당됨';
      ELSIF NEW.employee_id IS NULL AND OLD.employee_id IS NOT NULL THEN
        -- 2025-01-27: 반납과 폐기를 구분하여 처리
        IF NEW.purpose = '폐기' THEN
          action_type_val := '폐기';
          action_desc := get_history_message('폐기', old_employee_name);
        ELSE
          action_type_val := '반납';
          action_desc := get_history_message('반납', old_employee_name);
        END IF;
        old_status := '할당됨';
        new_status_val := '미할당';
      ELSE
        action_type_val := '재할당';
        action_desc := get_history_message('재할당', NULL, old_employee_name, new_employee_name);
        old_status := '할당됨';
        new_status_val := '할당됨';
      END IF;
    ELSE
      -- 2025-01-27: 일반 수정 처리 - 변경된 필드 상세 분석
      action_type_val := '수정';
      
      -- 변경된 필드 감지
      changed_fields := get_changed_fields_detail(OLD, NEW);
      changed_fields_text := get_changed_fields_text(changed_fields);
      
      -- 변경된 필드가 있으면 상세 메시지, 없으면 일반 메시지
      IF jsonb_typeof(changed_fields) = 'object' AND changed_fields != '{}'::jsonb THEN
        action_desc := get_history_message('수정_상세', NULL, NULL, NULL, changed_fields_text);
      ELSE
        action_desc := get_history_message('수정');
      END IF;
      
      new_status_val := CASE 
        WHEN NEW.employee_id IS NOT NULL THEN '할당됨'
        ELSE '미할당'
      END;
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    action_type_val := '삭제';
    IF OLD.employee_id IS NOT NULL THEN
      action_desc := get_history_message('삭제', old_employee_name);
    ELSE
      action_desc := get_history_message('삭제_미할당');
    END IF;
    old_status := CASE 
      WHEN OLD.employee_id IS NOT NULL THEN '할당됨'
      ELSE '미할당'
    END;
  END IF;
  
  -- Insert history record with enhanced metadata
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
    (current_setting('request.jwt.claims', true)::json->>'sub')::uuid,
    jsonb_build_object(
      'old_data', to_jsonb(OLD),
      'new_data', to_jsonb(NEW),
      'changed_fields', COALESCE(changed_fields, '{}'::jsonb),
      'old_employee_id', old_employee_id,
      'old_employee_name', old_employee_name,
      'new_employee_id', new_employee_id,
      'new_employee_name', new_employee_name
    )
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 9. 트리거 생성
DROP TRIGGER IF EXISTS trigger_device_history ON personal_devices;
CREATE TRIGGER trigger_device_history
  AFTER INSERT OR UPDATE OR DELETE ON personal_devices
  FOR EACH ROW EXECUTE FUNCTION log_device_changes();

-- 10. 메시지 템플릿 업데이트 함수 생성 (관리자가 메시지를 변경할 수 있도록)
CREATE OR REPLACE FUNCTION update_history_message_template(
  p_action_type VARCHAR(50),
  p_template TEXT,
  p_description TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
  INSERT INTO history_message_templates (action_type, template, description)
  VALUES (p_action_type, p_template, p_description)
  ON CONFLICT (action_type) DO UPDATE SET
    template = EXCLUDED.template,
    description = COALESCE(EXCLUDED.description, history_message_templates.description),
    updated_at = NOW();
  
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- 완료 메시지
SELECT '장비 히스토리 시스템이 성공적으로 설정되었습니다! (파라미터화된 메시지 템플릿 + 상세 변경 내역 포함)' as message;
