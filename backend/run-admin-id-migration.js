// 2025-01-27: Run migration to add admin_id column to personal_devices table
require('dotenv').config();

const { supabaseAdmin } = require('./config/database');

async function runAdminIdMigration() {
  try {
    console.log('🚀 [MIGRATION] Starting admin_id column migration...');
    
    // Try to add admin_id column (will fail if it already exists)
    console.log('📝 [MIGRATION] Adding admin_id column...');
    
    const { error: addError } = await supabaseAdmin.rpc('exec_sql', {
      sql: `
        ALTER TABLE personal_devices 
        ADD COLUMN admin_id UUID REFERENCES users(id);
        
        CREATE INDEX IF NOT EXISTS idx_personal_devices_admin_id 
        ON personal_devices(admin_id);
        
        COMMENT ON COLUMN personal_devices.admin_id IS '관리자 ID (장비 소유자)';
      `
    });

    if (addError) {
      if (addError.message.includes('already exists')) {
        console.log('✅ [MIGRATION] admin_id column already exists');
      } else {
        console.error('❌ [MIGRATION] Error adding admin_id column:', addError);
        return;
      }
    } else {
      console.log('✅ [MIGRATION] admin_id column added successfully');
    }

    // Check if there are any existing devices that need admin_id
    const { data: existingDevices, error: countError } = await supabaseAdmin
      .from('personal_devices')
      .select('id')
      .is('admin_id', null);

    if (countError) {
      console.error('❌ [MIGRATION] Error checking existing devices:', countError);
      return;
    }

    if (existingDevices && existingDevices.length > 0) {
      console.log(`📝 [MIGRATION] Found ${existingDevices.length} devices without admin_id`);
      
      // Get the first admin user
      const { data: adminUser, error: adminError } = await supabaseAdmin
        .from('users')
        .select('id')
        .eq('role', 'admin')
        .limit(1)
        .single();

      if (adminError || !adminUser) {
        console.error('❌ [MIGRATION] No admin user found:', adminError);
        return;
      }

      console.log(`📝 [MIGRATION] Using admin user ID: ${adminUser.id}`);

      // Update existing devices with admin_id
      const { error: updateError } = await supabaseAdmin
        .from('personal_devices')
        .update({ admin_id: adminUser.id })
        .is('admin_id', null);

      if (updateError) {
        console.error('❌ [MIGRATION] Error updating existing devices:', updateError);
        return;
      }

      console.log('✅ [MIGRATION] Updated existing devices with admin_id');
    } else {
      console.log('✅ [MIGRATION] No existing devices found');
    }

    // Try to make admin_id NOT NULL
    console.log('📝 [MIGRATION] Making admin_id column NOT NULL...');
    const { error: notNullError } = await supabaseAdmin.rpc('exec_sql', {
      sql: 'ALTER TABLE personal_devices ALTER COLUMN admin_id SET NOT NULL;'
    });

    if (notNullError) {
      if (notNullError.message.includes('already')) {
        console.log('✅ [MIGRATION] admin_id column is already NOT NULL');
      } else {
        console.error('❌ [MIGRATION] Error making admin_id NOT NULL:', notNullError);
        return;
      }
    } else {
      console.log('✅ [MIGRATION] Made admin_id column NOT NULL');
    }

    // Test the table structure by trying to insert a test record
    console.log('📝 [MIGRATION] Testing table structure...');
    
    // Get a test admin user
    const { data: testAdmin, error: testAdminError } = await supabaseAdmin
      .from('users')
      .select('id')
      .limit(1)
      .single();

    if (testAdminError || !testAdmin) {
      console.error('❌ [MIGRATION] No test user found:', testAdminError);
      return;
    }

    // Try to insert a test device
    const { data: testDevice, error: testError } = await supabaseAdmin
      .from('personal_devices')
      .insert([{
        admin_id: testAdmin.id,
        asset_number: 'TEST-MIGRATION-001',
        manufacturer: 'Test Manufacturer',
        model_name: 'Test Model'
      }])
      .select('id, admin_id, asset_number')
      .single();

    if (testError) {
      console.error('❌ [MIGRATION] Error testing table structure:', testError);
      return;
    }

    console.log('✅ [MIGRATION] Test device created successfully:', testDevice);

    // Clean up test device
    const { error: cleanupError } = await supabaseAdmin
      .from('personal_devices')
      .delete()
      .eq('asset_number', 'TEST-MIGRATION-001');

    if (cleanupError) {
      console.error('⚠️ [MIGRATION] Warning: Could not clean up test device:', cleanupError);
    } else {
      console.log('✅ [MIGRATION] Test device cleaned up');
    }

    console.log('🎉 [MIGRATION] Migration completed successfully!');
    console.log('📋 [MIGRATION] Summary:');
    console.log('  - admin_id column added to personal_devices table');
    console.log('  - admin_id column is NOT NULL');
    console.log('  - Index created on admin_id column');
    console.log('  - Table structure tested and working');

  } catch (error) {
    console.error('❌ [MIGRATION] Migration failed:', error);
  }
}

// Run the migration
runAdminIdMigration();
