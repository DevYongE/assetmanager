// 2025-01-27: 직원 테이블에 이메일 필드 추가를 위한 마이그레이션
require('dotenv').config();

const { supabaseAdmin } = require('./config/database');

async function addEmailFieldMigration() {
  try {
    console.log('🚀 [MIGRATION] Adding email field to employees table...');
    
    // Migration steps
    const migrations = [
      {
        name: 'Add email column to employees table',
        sql: `
          ALTER TABLE employees 
          ADD COLUMN IF NOT EXISTS email VARCHAR(255);
        `
      },
      {
        name: 'Create index for email field',
        sql: `
          CREATE INDEX IF NOT EXISTS idx_employees_email 
          ON employees(email);
        `
      }
    ];
    
    for (const migration of migrations) {
      console.log(`📝 [MIGRATION] Executing: ${migration.name}`);
      
      const { error } = await supabaseAdmin.rpc('exec_sql', {
        sql: migration.sql
      });
      
      if (error) {
        console.error(`❌ [MIGRATION] Failed: ${migration.name}`, error);
        throw error;
      }
      
      console.log(`✅ [MIGRATION] Success: ${migration.name}`);
    }
    
    console.log('🎉 [MIGRATION] Email field migration completed successfully!');
    
  } catch (error) {
    console.error('❌ [MIGRATION] Migration failed:', error);
    process.exit(1);
  }
}

// Run migration
addEmailFieldMigration();
