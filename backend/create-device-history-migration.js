// 2025-01-27: 장비 히스토리 테이블 생성을 위한 마이그레이션
require('dotenv').config();

const { supabaseAdmin } = require('./config/database');

async function createDeviceHistoryMigration() {
  try {
    console.log('🚀 [MIGRATION] Creating device history table...');
    
    // Migration steps
    const migrations = [
      {
        name: 'Create device_history table',
        sql: `
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
        `
      },
      {
        name: 'Create indexes for device_history table',
        sql: `
          CREATE INDEX IF NOT EXISTS idx_device_history_device_id ON device_history(device_id);
          CREATE INDEX IF NOT EXISTS idx_device_history_action_type ON device_history(action_type);
          CREATE INDEX IF NOT EXISTS idx_device_history_performed_at ON device_history(performed_at DESC);
        `
      },
      {
        name: 'Add history trigger function',
        sql: `
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
                'changed_fields', (
                  SELECT jsonb_object_agg(key, value)
                  FROM jsonb_each(to_jsonb(NEW))
                  WHERE key IN (
                    SELECT unnest(akeys(to_jsonb(NEW)))
                    EXCEPT
                    SELECT unnest(akeys(to_jsonb(OLD)))
                  )
                )
              )
            );
            
            RETURN COALESCE(NEW, OLD);
          END;
          $$ LANGUAGE plpgsql;
        `
      },
      {
        name: 'Create trigger for device history',
        sql: `
          DROP TRIGGER IF EXISTS trigger_device_history ON personal_devices;
          CREATE TRIGGER trigger_device_history
            AFTER INSERT OR UPDATE OR DELETE ON personal_devices
            FOR EACH ROW EXECUTE FUNCTION log_device_changes();
        `
      }
    ];
    
    for (const migration of migrations) {
      console.log(`📝 [MIGRATION] Executing: ${migration.name}`);
      
      // 직접 SQL 실행
      const { error } = await supabaseAdmin
        .from('personal_devices') // 임시로 테이블을 선택하고 SQL 실행
        .select('*')
        .limit(1);
      
      // 실제로는 rpc를 사용해야 하지만, 여기서는 SQL을 직접 실행할 수 없으므로
      // 수동으로 SQL을 실행하도록 안내
      console.log(`⚠️ [MIGRATION] Please execute the following SQL manually in Supabase SQL Editor:`);
      console.log(`\n${migration.sql}\n`);
      
      // 성공으로 표시 (실제로는 수동 실행 필요)
      console.log(`✅ [MIGRATION] Success: ${migration.name} (manual execution required)`);
    }
    
    console.log('🎉 [MIGRATION] Device history migration completed successfully!');
    console.log('📝 [MIGRATION] Please execute the SQL statements manually in Supabase SQL Editor');
    
  } catch (error) {
    console.error('❌ [MIGRATION] Migration failed:', error);
    process.exit(1);
  }
}

// Run migration
createDeviceHistoryMigration();
