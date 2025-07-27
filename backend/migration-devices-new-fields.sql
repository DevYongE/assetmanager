-- Add new columns to personal_devices table
-- 2025-07-27: Add new fields for device management
-- Note: Run each ALTER TABLE statement individually to avoid conflicts

-- Add inspection_date column (if not exists)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'inspection_date') THEN
        ALTER TABLE personal_devices ADD COLUMN inspection_date DATE;
        CREATE INDEX idx_personal_devices_inspection_date ON personal_devices(inspection_date);
        COMMENT ON COLUMN personal_devices.inspection_date IS '조사일자';
    END IF;
END $$;

-- Add purpose column (if not exists)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'purpose') THEN
        ALTER TABLE personal_devices ADD COLUMN purpose VARCHAR(100);
        CREATE INDEX idx_personal_devices_purpose ON personal_devices(purpose);
        COMMENT ON COLUMN personal_devices.purpose IS '용도';
    END IF;
END $$;

-- Add device_type column (if not exists)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'device_type') THEN
        ALTER TABLE personal_devices ADD COLUMN device_type VARCHAR(100);
        CREATE INDEX idx_personal_devices_device_type ON personal_devices(device_type);
        COMMENT ON COLUMN personal_devices.device_type IS '장비 타입';
    END IF;
END $$;

-- Add monitor_size column (if not exists)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'monitor_size') THEN
        ALTER TABLE personal_devices ADD COLUMN monitor_size VARCHAR(50);
        CREATE INDEX idx_personal_devices_monitor_size ON personal_devices(monitor_size);
        COMMENT ON COLUMN personal_devices.monitor_size IS '모니터 크기';
    END IF;
END $$;

-- Add issue_date column (if not exists)
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'issue_date') THEN
        ALTER TABLE personal_devices ADD COLUMN issue_date DATE;
        CREATE INDEX idx_personal_devices_issue_date ON personal_devices(issue_date);
        COMMENT ON COLUMN personal_devices.issue_date IS '지급일자';
    END IF;
END $$;

-- Modify employee_id to allow NULL values (if not already nullable)
DO $$ 
BEGIN 
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'personal_devices' AND column_name = 'employee_id' AND is_nullable = 'NO') THEN
        ALTER TABLE personal_devices ALTER COLUMN employee_id DROP NOT NULL;
        COMMENT ON COLUMN personal_devices.employee_id IS '담당 직원 ID (NULL = 미할당)';
    END IF;
END $$;

-- Example: Insert unassigned device (only if you want to add test data)
-- 2025-07-27: Example INSERT for unassigned device
INSERT INTO personal_devices (
    id,
    employee_id,
    asset_number,
    manufacturer,
    model_name,
    serial_number,
    cpu,
    memory,
    storage,
    gpu,
    os,
    monitor,
    inspection_date,
    purpose,
    device_type,
    monitor_size,
    issue_date,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(), -- 새로운 UUID 생성
    NULL,              -- 미할당: employee_id를 NULL로 설정
    'AS-NB-25-001',   -- 자산번호 (필수)
    'Samsung',         -- 제조사
    'Galaxy Book Pro', -- 모델명
    'SN-001-XYZ',      -- 시리얼 번호
    'Intel Core i7-1165G7', -- CPU
    '16GB',            -- 메모리
    '512GB SSD',       -- 저장장치 (하드디스크)
    'Intel Iris Xe Graphics', -- GPU (그래픽카드)
    'Windows 11 Pro',  -- 운영체제
    '15.6 inch',       -- 모니터
    '2025-07-27',      -- 조사일자
    '업무용',           -- 용도
    '노트북',           -- 장비 타입
    '15.6',            -- 모니터 사이즈
    '2025-01-15',      -- 발행일자
    NOW(),             -- 현재 시간으로 생성일자 설정
    NOW()              -- 현재 시간으로 업데이트일자 설정
);

-- Additional test data for unassigned devices
INSERT INTO personal_devices (
    id,
    employee_id,
    asset_number,
    manufacturer,
    model_name,
    serial_number,
    cpu,
    memory,
    storage,
    gpu,
    os,
    monitor,
    inspection_date,
    purpose,
    device_type,
    monitor_size,
    issue_date,
    created_at,
    updated_at
) VALUES 
(
    gen_random_uuid(),
    NULL,
    'AS-DT-25-001',
    'HP',
    'EliteDesk 800',
    'SN-HP-001',
    'Intel Core i5-10400',
    '8GB',
    '256GB SSD',
    'Intel UHD Graphics',
    'Windows 10 Pro',
    '22 inch',
    '2025-07-27',
    '일반업무',
    '데스크톱',
    '22',
    '2024-06-01',
    NOW(),
    NOW()
),
(
    gen_random_uuid(),
    NULL,
    'AS-MN-25-001',
    'LG',
    'UltraWide 34',
    'SN-LG-001',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    '34 inch',
    '2025-07-27',
    '모니터링',
    '모니터',
    '34',
    '2024-08-15',
    NOW(),
    NOW()
); 