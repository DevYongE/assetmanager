-- Migration: Move company_name from users to employees table
-- Date: 2024-12-19

-- Step 1: Add company_name column to employees table
ALTER TABLE employees ADD COLUMN company_name VARCHAR;

-- Step 2: Copy company_name from users to employees
UPDATE employees 
SET company_name = (
  SELECT company_name 
  FROM users 
  WHERE users.id = employees.admin_id
);

-- Step 3: Make company_name NOT NULL in employees table
ALTER TABLE employees ALTER COLUMN company_name SET NOT NULL;

-- Step 4: Remove company_name from users table
ALTER TABLE users DROP COLUMN company_name;

-- Step 5: Add index for better performance
CREATE INDEX idx_employees_company_name ON employees(company_name); 