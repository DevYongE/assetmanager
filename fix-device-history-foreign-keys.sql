-- 2025-01-27: Fix device_history table foreign key relationships
-- This script fixes the missing foreign key constraints that are causing the PGRST200 error

-- 1. First, let's check if the device_history table exists and its current structure
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'device_history') THEN
        -- Create device_history table if it doesn't exist
        CREATE TABLE device_history (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            device_id UUID NOT NULL,
            action_type VARCHAR(50) NOT NULL CHECK (action_type IN ('등록', '할당', '반납', '폐기', '수정', '재할당', '생성', '삭제')),
            action_description TEXT,
            previous_status VARCHAR(50),
            new_status VARCHAR(50),
            performed_by UUID,
            performed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            metadata JSONB DEFAULT '{}'::jsonb
        );
        
        RAISE NOTICE 'Created device_history table';
    ELSE
        RAISE NOTICE 'device_history table already exists';
    END IF;
END $$;

-- 2. Add foreign key constraint for device_id if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'device_history_device_id_fkey' 
        AND table_name = 'device_history'
    ) THEN
        ALTER TABLE device_history 
        ADD CONSTRAINT device_history_device_id_fkey 
        FOREIGN KEY (device_id) REFERENCES personal_devices(id) ON DELETE CASCADE;
        
        RAISE NOTICE 'Added foreign key constraint for device_id';
    ELSE
        RAISE NOTICE 'Foreign key constraint for device_id already exists';
    END IF;
END $$;

-- 3. Add foreign key constraint for performed_by if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'device_history_performed_by_fkey' 
        AND table_name = 'device_history'
    ) THEN
        ALTER TABLE device_history 
        ADD CONSTRAINT device_history_performed_by_fkey 
        FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE SET NULL;
        
        RAISE NOTICE 'Added foreign key constraint for performed_by';
    ELSE
        RAISE NOTICE 'Foreign key constraint for performed_by already exists';
    END IF;
END $$;

-- 4. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_device_history_device_id ON device_history(device_id);
CREATE INDEX IF NOT EXISTS idx_device_history_action_type ON device_history(action_type);
CREATE INDEX IF NOT EXISTS idx_device_history_performed_at ON device_history(performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_device_history_performed_by ON device_history(performed_by);

-- 5. Show the final table structure
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name='device_history';

-- 6. Show device_history table columns
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'device_history' 
ORDER BY ordinal_position;
