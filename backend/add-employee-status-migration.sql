-- Migration: Add employee status and resignation date fields
-- Date: 2025-01-27

-- Step 1: Add status column to employees table (active/resigned)
ALTER TABLE employees ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- Step 2: Add resigned_at column to employees table (퇴사일)
ALTER TABLE employees ADD COLUMN resigned_at TIMESTAMP;

-- Step 3: Add constraint to ensure status is either 'active' or 'resigned'
ALTER TABLE employees ADD CONSTRAINT chk_employee_status 
CHECK (status IN ('active', 'resigned'));

-- Step 4: Add indexes for better performance
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_employees_resigned_at ON employees(resigned_at);

-- Step 5: Add comment for documentation
COMMENT ON COLUMN employees.status IS '직원 근무 상태: active(재직중), resigned(퇴사)';
COMMENT ON COLUMN employees.resigned_at IS '퇴사일 (퇴사한 경우에만 설정)';
