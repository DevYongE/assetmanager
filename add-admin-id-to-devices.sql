-- 2025-01-27: Add admin_id column to personal_devices table
-- This migration adds the missing admin_id column that is required for RLS policies

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

-- Make admin_id NOT NULL after adding it
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'admin_id' AND is_nullable = 'YES') THEN
        -- First, update any existing NULL admin_id values to a default admin user
        -- You may need to adjust this based on your actual admin user ID
        UPDATE personal_devices 
        SET admin_id = (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
        WHERE admin_id IS NULL;
        
        -- Then make the column NOT NULL
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
ORDER BY column_name;
