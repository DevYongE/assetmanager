-- 2025-01-27: Create permissions system with separate permissions table
-- Run this in Supabase SQL Editor to implement flexible permission system

-- 1. Create permissions table
CREATE TABLE IF NOT EXISTS permissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    resource_type VARCHAR(50) NOT NULL CHECK (resource_type IN ('devices', 'employees', 'users')),
    resource_id UUID, -- NULL means all resources of that type
    action VARCHAR(50) NOT NULL CHECK (action IN ('read', 'write', 'delete', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, resource_type, resource_id, action)
);

-- 2. Create index for better performance
CREATE INDEX IF NOT EXISTS idx_permissions_user_id ON permissions(user_id);
CREATE INDEX IF NOT EXISTS idx_permissions_resource ON permissions(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_permissions_action ON permissions(action);

-- 3. Add admin_id column to personal_devices table (if not exists)
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

-- 4. Set default permissions for first user (super admin)
DO $$
DECLARE
    first_user_id UUID;
BEGIN
    -- Get the first user
    SELECT id INTO first_user_id FROM users ORDER BY created_at LIMIT 1;
    
    IF first_user_id IS NOT NULL THEN
        -- Insert super admin permissions for all resources
        INSERT INTO permissions (user_id, resource_type, resource_id, action) VALUES
            (first_user_id, 'devices', NULL, 'admin'),
            (first_user_id, 'employees', NULL, 'admin'),
            (first_user_id, 'users', NULL, 'admin')
        ON CONFLICT (user_id, resource_type, resource_id, action) DO NOTHING;
        
        RAISE NOTICE 'Set super admin permissions for user: %', first_user_id;
    ELSE
        RAISE NOTICE 'No users found to set permissions';
    END IF;
END $$;

-- 5. Update existing devices with admin_id (set to first user)
DO $$
DECLARE
    first_user_id UUID;
BEGIN
    -- Get the first user
    SELECT id INTO first_user_id FROM users ORDER BY created_at LIMIT 1;
    
    IF first_user_id IS NOT NULL THEN
        UPDATE personal_devices 
        SET admin_id = first_user_id
        WHERE admin_id IS NULL;
        
        RAISE NOTICE 'Updated existing devices with admin_id: %', first_user_id;
    ELSE
        RAISE NOTICE 'No users found, skipping existing device updates';
    END IF;
END $$;

-- 6. Make admin_id NOT NULL after updating existing data
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'admin_id' AND is_nullable = 'YES') THEN
        ALTER TABLE personal_devices ALTER COLUMN admin_id SET NOT NULL;
        RAISE NOTICE 'Made admin_id column NOT NULL';
    ELSE
        RAISE NOTICE 'admin_id column is already NOT NULL';
    END IF;
END $$;

-- 7. Create function to check user permissions
CREATE OR REPLACE FUNCTION check_user_permission(
    p_user_id UUID,
    p_resource_type VARCHAR(50),
    p_resource_id UUID DEFAULT NULL,
    p_action VARCHAR(50) DEFAULT 'read'
) RETURNS BOOLEAN AS $$
BEGIN
    -- Check if user has admin permission for this resource type
    IF EXISTS (
        SELECT 1 FROM permissions 
        WHERE user_id = p_user_id 
        AND resource_type = p_resource_type 
        AND resource_id IS NULL 
        AND action = 'admin'
    ) THEN
        RETURN TRUE;
    END IF;
    
    -- Check if user has specific permission for this resource
    IF EXISTS (
        SELECT 1 FROM permissions 
        WHERE user_id = p_user_id 
        AND resource_type = p_resource_type 
        AND (resource_id = p_resource_id OR resource_id IS NULL)
        AND (action = p_action OR action = 'admin')
    ) THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Create function to grant permissions
CREATE OR REPLACE FUNCTION grant_permission(
    p_user_id UUID,
    p_resource_type VARCHAR(50),
    p_resource_id UUID DEFAULT NULL,
    p_action VARCHAR(50) DEFAULT 'read'
) RETURNS VOID AS $$
BEGIN
    INSERT INTO permissions (user_id, resource_type, resource_id, action)
    VALUES (p_user_id, p_resource_type, p_resource_id, p_action)
    ON CONFLICT (user_id, resource_type, resource_id, action) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Create function to revoke permissions
CREATE OR REPLACE FUNCTION revoke_permission(
    p_user_id UUID,
    p_resource_type VARCHAR(50),
    p_resource_id UUID DEFAULT NULL,
    p_action VARCHAR(50) DEFAULT 'read'
) RETURNS VOID AS $$
BEGIN
    DELETE FROM permissions 
    WHERE user_id = p_user_id 
    AND resource_type = p_resource_type 
    AND (resource_id = p_resource_id OR (p_resource_id IS NULL AND resource_id IS NULL))
    AND action = p_action;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Update RLS policies to use permissions table
-- Drop existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON employees;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON employees;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON employees;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON employees;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON personal_devices;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON personal_devices;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON personal_devices;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON personal_devices;

-- 11. Create new permission-based policies for users table
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- 12. Create new permission-based policies for employees table
-- Read policy
CREATE POLICY "Permission-based employee read access" ON employees
    FOR SELECT USING (
        check_user_permission(auth.uid(), 'employees', id, 'read')
    );

-- Insert policy
CREATE POLICY "Permission-based employee insert access" ON employees
    FOR INSERT WITH CHECK (
        check_user_permission(auth.uid(), 'employees', id, 'write')
    );

-- Update policy
CREATE POLICY "Permission-based employee update access" ON employees
    FOR UPDATE USING (
        check_user_permission(auth.uid(), 'employees', id, 'write')
    );

-- Delete policy
CREATE POLICY "Permission-based employee delete access" ON employees
    FOR DELETE USING (
        check_user_permission(auth.uid(), 'employees', id, 'delete')
    );

-- 13. Create new permission-based policies for personal_devices table
-- Read policy
CREATE POLICY "Permission-based device read access" ON personal_devices
    FOR SELECT USING (
        check_user_permission(auth.uid(), 'devices', id, 'read')
    );

-- Insert policy
CREATE POLICY "Permission-based device insert access" ON personal_devices
    FOR INSERT WITH CHECK (
        check_user_permission(auth.uid(), 'devices', id, 'write')
    );

-- Update policy
CREATE POLICY "Permission-based device update access" ON personal_devices
    FOR UPDATE USING (
        check_user_permission(auth.uid(), 'devices', id, 'write')
    );

-- Delete policy
CREATE POLICY "Permission-based device delete access" ON personal_devices
    FOR DELETE USING (
        check_user_permission(auth.uid(), 'devices', id, 'delete')
    );

-- 14. Enable RLS on permissions table
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;

-- 15. Create policies for permissions table (only super admins can manage permissions)
CREATE POLICY "Super admins can manage permissions" ON permissions
    FOR ALL USING (
        check_user_permission(auth.uid(), 'users', NULL, 'admin')
    );

-- 16. Show the created table structure
SELECT 'permissions' as table_name, column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'permissions' 
ORDER BY ordinal_position;

-- 17. Show current permissions
SELECT 
    p.id,
    u.email as user_email,
    p.resource_type,
    p.resource_id,
    p.action,
    p.created_at
FROM permissions p
JOIN users u ON p.user_id = u.id
ORDER BY u.email, p.resource_type, p.action;
