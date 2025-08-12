// 2025-01-27: 회원가입 시 기업명 저장을 위한 마이그레이션
require('dotenv').config();

const { supabaseAdmin } = require('./config/database');

async function addCompanyNameMigration() {
  try {
    console.log('🚀 [MIGRATION] Adding company_name to users table...');
    
    // Migration steps
    const migrations = [
      {
        name: 'Add company_name column to users table',
        sql: `
          ALTER TABLE users 
          ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);
        `
      },
      {
        name: 'Update existing users with company_name from employees table',
        sql: `
          UPDATE users 
          SET company_name = (
            SELECT e.company_name 
            FROM employees e 
            WHERE e.admin_id = users.id 
            LIMIT 1
          )
          WHERE company_name IS NULL;
        `
      },
      {
        name: 'Set default company_name for users without employees record',
        sql: `
          UPDATE users 
          SET company_name = '기본 회사명'
          WHERE company_name IS NULL;
        `
      },
      {
        name: 'Add NOT NULL constraint to company_name',
        sql: `
          ALTER TABLE users 
          ALTER COLUMN company_name SET NOT NULL;
        `
      },
      {
        name: 'Create index for company_name',
        sql: `
          CREATE INDEX IF NOT EXISTS idx_users_company_name 
          ON users(company_name);
        `
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
    
    console.log('✅ [MIGRATION] Company name migration completed!');
    
    // Verify the migration
    console.log('🔍 [MIGRATION] Verifying migration...');
    const { data: columns, error: columnError } = await supabaseAdmin
      .from('information_schema.columns')
      .select('column_name, data_type, is_nullable')
      .eq('table_name', 'users')
      .eq('table_schema', 'public')
      .eq('column_name', 'company_name');
    
    if (columnError) {
      console.error('❌ [MIGRATION] Verification failed:', columnError);
    } else if (columns && columns.length > 0) {
      console.log('✅ [MIGRATION] Verification successful: company_name column exists');
      console.log('📊 [MIGRATION] Column details:', columns[0]);
    } else {
      console.log('⚠️ [MIGRATION] company_name column not found');
    }
    
  } catch (error) {
    console.error('❌ [MIGRATION] Migration error:', error);
  }
}

// Run migration
addCompanyNameMigration();
