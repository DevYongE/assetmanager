-- 2025-01-27: Fix users table - add role column if it doesn't exist
-- Run this in Supabase SQL Editor to fix the role column issue

-- 1. Check if role column exists in users table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'users' 
        AND column_name = 'role'
    ) THEN
        -- Add role column if it doesn't exist
        ALTER TABLE users ADD COLUMN role VARCHAR(50) DEFAULT 'manager';
        
        -- Update existing users to have admin role (you can modify this logic)
        UPDATE users SET role = 'admin' WHERE email LIKE '%admin%' OR email LIKE '%관리자%';
        
        -- Add comment to the column
        COMMENT ON COLUMN users.role IS 'User role: admin, manager, user';
        
        RAISE NOTICE 'Role column added to users table';
    ELSE
        RAISE NOTICE 'Role column already exists in users table';
    END IF;
END $$;

-- 2. Show current users and their roles
SELECT 
    'Current Users and Roles' as info,
    id,
    email,
    role,
    created_at
FROM users
ORDER BY created_at;

-- 3. Now run the grant delete permissions
-- Grant delete permission for all devices to admin users
INSERT INTO permissions (user_id, resource_type, resource_id, action)
SELECT 
    u.id,
    'devices',
    NULL, -- NULL means all devices
    'delete'
FROM users u
WHERE u.role = 'admin'
ON CONFLICT (user_id, resource_type, resource_id, action) DO NOTHING;

-- Grant delete permission for all employees to admin users
INSERT INTO permissions (user_id, resource_type, resource_id, action)
SELECT 
    u.id,
    'employees',
    NULL, -- NULL means all employees
    'delete'
FROM users u
WHERE u.role = 'admin'
ON CONFLICT (user_id, resource_type, resource_id, action) DO NOTHING;

-- Grant delete permission for own devices to manager users
INSERT INTO permissions (user_id, resource_type, resource_id, action)
SELECT DISTINCT
    u.id,
    'devices',
    pd.id, -- Specific device ID
    'delete'
FROM users u
JOIN personal_devices pd ON pd.admin_id = u.id
WHERE u.role = 'manager'
ON CONFLICT (user_id, resource_type, resource_id, action) DO NOTHING;

-- Grant delete permission for own employees to manager users
INSERT INTO permissions (user_id, resource_type, resource_id, action)
SELECT DISTINCT
    u.id,
    'employees',
    e.id, -- Specific employee ID
    'delete'
FROM users u
JOIN employees e ON e.admin_id = u.id
WHERE u.role = 'manager'
ON CONFLICT (user_id, resource_type, resource_id, action) DO NOTHING;

-- 4. Show final permissions summary
SELECT 
    'Final Permission Summary' as info,
    u.role,
    COUNT(*) as total_permissions,
    COUNT(CASE WHEN p.action = 'delete' THEN 1 END) as delete_permissions
FROM users u
LEFT JOIN permissions p ON u.id = p.user_id
GROUP BY u.role
ORDER BY u.role;

-- 5. Show current delete permissions
SELECT 
    'Current Delete Permissions' as info,
    p.id,
    u.email as user_email,
    u.role as user_role,
    p.resource_type,
    CASE 
        WHEN p.resource_id IS NULL THEN 'ALL'
        ELSE p.resource_id::text
    END as resource_id,
    p.action,
    p.created_at
FROM permissions p
JOIN users u ON p.user_id = u.id
WHERE p.action = 'delete'
ORDER BY u.email, p.resource_type;
