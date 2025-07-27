-- Check and add missing columns to personal_devices table
-- 2025-07-27: Safe migration script

-- Check current columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'personal_devices' 
ORDER BY column_name;

-- Add missing columns one by one
-- 1. inspection_date
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'inspection_date') THEN
        ALTER TABLE personal_devices ADD COLUMN inspection_date DATE;
        CREATE INDEX idx_personal_devices_inspection_date ON personal_devices(inspection_date);
        RAISE NOTICE 'Added inspection_date column';
    ELSE
        RAISE NOTICE 'inspection_date column already exists';
    END IF;
END $$;

-- 2. purpose
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'purpose') THEN
        ALTER TABLE personal_devices ADD COLUMN purpose VARCHAR(100);
        CREATE INDEX idx_personal_devices_purpose ON personal_devices(purpose);
        RAISE NOTICE 'Added purpose column';
    ELSE
        RAISE NOTICE 'purpose column already exists';
    END IF;
END $$;

-- 3. device_type
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'device_type') THEN
        ALTER TABLE personal_devices ADD COLUMN device_type VARCHAR(100);
        CREATE INDEX idx_personal_devices_device_type ON personal_devices(device_type);
        RAISE NOTICE 'Added device_type column';
    ELSE
        RAISE NOTICE 'device_type column already exists';
    END IF;
END $$;

-- 4. monitor_size
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'monitor_size') THEN
        ALTER TABLE personal_devices ADD COLUMN monitor_size VARCHAR(50);
        CREATE INDEX idx_personal_devices_monitor_size ON personal_devices(monitor_size);
        RAISE NOTICE 'Added monitor_size column';
    ELSE
        RAISE NOTICE 'monitor_size column already exists';
    END IF;
END $$;

-- 5. issue_date
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'issue_date') THEN
        ALTER TABLE personal_devices ADD COLUMN issue_date DATE;
        CREATE INDEX idx_personal_devices_issue_date ON personal_devices(issue_date);
        RAISE NOTICE 'Added issue_date column';
    ELSE
        RAISE NOTICE 'issue_date column already exists';
    END IF;
END $$;

-- 6. Make employee_id nullable for unassigned devices
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'employee_id' AND is_nullable = 'NO') THEN
        ALTER TABLE personal_devices ALTER COLUMN employee_id DROP NOT NULL;
        RAISE NOTICE 'Made employee_id nullable';
    ELSE
        RAISE NOTICE 'employee_id is already nullable';
    END IF;
END $$;

-- Show final table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'personal_devices' 
ORDER BY column_name; 