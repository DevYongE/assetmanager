// 2025-08-08: 환경변수 로드 추가 (dotenv 설정이 먼저 실행되도록)
require('dotenv').config();

const { supabaseAdmin } = require('./config/database');

async function runMigration() {
  try {
    console.log('🚀 [MIGRATION] Starting migration...');
    
    // Migration steps
    const migrations = [
      {
        name: 'Add inspection_date column',
        sql: 'ALTER TABLE personal_devices ADD COLUMN inspection_date DATE;'
      },
      {
        name: 'Add purpose column',
        sql: 'ALTER TABLE personal_devices ADD COLUMN purpose VARCHAR;'
      },
      {
        name: 'Add device_type column',
        sql: 'ALTER TABLE personal_devices ADD COLUMN device_type VARCHAR;'
      },
      {
        name: 'Add monitor_size column',
        sql: 'ALTER TABLE personal_devices ADD COLUMN monitor_size VARCHAR;'
      },
      {
        name: 'Add issue_date column',
        sql: 'ALTER TABLE personal_devices ADD COLUMN issue_date DATE;'
      },
      {
        name: 'Create index for inspection_date',
        sql: 'CREATE INDEX idx_personal_devices_inspection_date ON personal_devices(inspection_date);'
      },
      {
        name: 'Create index for purpose',
        sql: 'CREATE INDEX idx_personal_devices_purpose ON personal_devices(purpose);'
      },
      {
        name: 'Create index for device_type',
        sql: 'CREATE INDEX idx_personal_devices_device_type ON personal_devices(device_type);'
      },
      {
        name: 'Create index for issue_date',
        sql: 'CREATE INDEX idx_personal_devices_issue_date ON personal_devices(issue_date);'
      }
    ];
    
    for (const migration of migrations) {
      console.log(`🔧 [MIGRATION] Running: ${migration.name}`);
      
      try {
        const { data, error } = await supabaseAdmin.rpc('exec_sql', {
          sql: migration.sql
        });
        
        if (error) {
          console.log(`⚠️ [MIGRATION] ${migration.name} failed (might already exist):`, error.message);
        } else {
          console.log(`✅ [MIGRATION] ${migration.name} completed`);
        }
      } catch (err) {
        console.log(`⚠️ [MIGRATION] ${migration.name} failed (might already exist):`, err.message);
      }
    }
    
    console.log('✅ [MIGRATION] Migration process completed!');
    
  } catch (error) {
    console.error('❌ [MIGRATION] Migration error:', error);
  }
}

// Run migration
runMigration(); 