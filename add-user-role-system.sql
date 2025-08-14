-- 2025-01-27: Add user role system for admin and manager access control
-- Run this in Supabase SQL Editor to implement role-based access control

-- 1. Add role column to users table
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'role') THEN
        ALTER TABLE users ADD COLUMN role VARCHAR(20) DEFAULT 'manager' CHECK (role IN ('admin', 'manager'));
        CREATE INDEX idx_users_role ON users(role);
        COMMENT ON COLUMN users.role IS '사용자 역할: admin(관리자), manager(담당자)';
        RAISE NOTICE 'Added role column to users table';
    ELSE
        RAISE NOTICE 'role column already exists in users table';
    END IF;
END $$;

-- 2. Set default admin user (first user becomes admin)
DO $$
DECLARE
    first_user_id UUID;
BEGIN
    -- Get the first user and set as admin
    SELECT id INTO first_user_id FROM users ORDER BY created_at LIMIT 1;
    
    IF first_user_id IS NOT NULL THEN
        UPDATE users SET role = 'admin' WHERE id = first_user_id;
        RAISE NOTICE 'Set first user as admin: %', first_user_id;
    ELSE
        RAISE NOTICE 'No users found to set as admin';
    END IF;
END $$;

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

-- 4. Update existing devices with admin_id (set to first admin user)
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

-- 5. Make admin_id NOT NULL after updating existing data
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'admin_id' AND is_nullable = 'YES') THEN
        ALTER TABLE personal_devices ALTER COLUMN admin_id SET NOT NULL;
        RAISE NOTICE 'Made admin_id column NOT NULL';
    ELSE
        RAISE NOTICE 'admin_id column is already NOT NULL';
    END IF;
END $$;

-- 6. Update RLS policies for role-based access control
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

-- 7. Create new role-based policies for users table
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- 8. Create new role-based policies for employees table
-- Admin can see all employees, managers can only see their own employees
CREATE POLICY "Admin can view all employees" ON employees
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

CREATE POLICY "Managers can view own employees" ON employees
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'manager'
            AND users.id = employees.admin_id
        )
    );

-- Admin can insert/update/delete all employees, managers can only manage their own
CREATE POLICY "Admin can manage all employees" ON employees
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

CREATE POLICY "Managers can manage own employees" ON employees
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'manager'
            AND users.id = employees.admin_id
        )
    );

-- 9. Create new role-based policies for personal_devices table
-- Admin can see all devices, managers can only see their own devices
CREATE POLICY "Admin can view all devices" ON personal_devices
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

CREATE POLICY "Managers can view own devices" ON personal_devices
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'manager'
            AND users.id = admin_id
        )
    );

-- Admin can insert/update/delete all devices, managers can only manage their own
CREATE POLICY "Admin can manage all devices" ON personal_devices
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

CREATE POLICY "Managers can manage own devices" ON personal_devices
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'manager'
            AND users.id = admin_id
        )
    );

-- 10. Show the updated table structure
SELECT 'users' as table_name, column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- 11. Show personal_devices table structure
SELECT 'personal_devices' as table_name, column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'personal_devices' 
ORDER BY ordinal_position;

-- 12. Show current user roles
SELECT id, email, role, created_at 
FROM users 
ORDER BY created_at;
