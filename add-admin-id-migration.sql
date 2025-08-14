-- 2025-01-27: Add admin_id column to personal_devices table
-- Run this in Supabase SQL Editor to fix the device creation issue

-- Add admin_id column to personal_devices table
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'admin_id') THEN
        ALTER TABLE personal_devices ADD COLUMN admin_id UUID REFERENCES users(id);
        CREATE INDEX idx_personal_devices_admin_id ON personal_devices(admin_id);
        COMMENT ON COLUMN personal_devices.admin_id IS '관리자 ID (장비 소유자)';
        RAISE NOTICE 'Added admin_id column to personal_devices table';
    ELSE
        RAISE NOTICE 'admin_id column already exists in personal_devices table';
    END IF;
END $$;

-- Update any existing devices with NULL admin_id to use the first admin user
DO $$
DECLARE
    admin_user_id UUID;
BEGIN
    -- Get the first admin user
    SELECT id INTO admin_user_id FROM users WHERE role = 'admin' LIMIT 1;
    
    IF admin_user_id IS NOT NULL THEN
        UPDATE personal_devices 
        SET admin_id = admin_user_id
        WHERE admin_id IS NULL;
        
        RAISE NOTICE 'Updated existing devices with admin_id: %', admin_user_id;
    ELSE
        RAISE NOTICE 'No admin user found, skipping existing device updates';
    END IF;
END $$;

-- Make admin_id NOT NULL after updating existing data
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'admin_id' AND is_nullable = 'YES') THEN
        ALTER TABLE personal_devices ALTER COLUMN admin_id SET NOT NULL;
        RAISE NOTICE 'Made admin_id column NOT NULL';
    ELSE
        RAISE NOTICE 'admin_id column is already NOT NULL';
    END IF;
END $$;

-- Show the updated table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'personal_devices' 
ORDER BY ordinal_position;
