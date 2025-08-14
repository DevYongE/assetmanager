const express = require('express');
const multer = require('multer');
const xlsx = require('xlsx');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({ 
  storage,
  fileFilter: (req, file, cb) => {
    // Check file extension first
    const isCSV = file.originalname.toLowerCase().endsWith('.csv');
    const isExcel = file.originalname.toLowerCase().endsWith('.xlsx') || 
                   file.originalname.toLowerCase().endsWith('.xls');
    
    // Check MIME type
    const validMimeTypes = [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-excel',
      'text/csv',
      'application/csv',
      'application/vnd.ms-excel.sheet.macroEnabled.12',
      'application/vnd.ms-excel.template.macroEnabled.12',
      'application/vnd.ms-excel.addin.macroEnabled.12',
      'application/vnd.ms-excel.sheet.binary.macroEnabled.12'
    ];
    
    if (isCSV || isExcel || validMimeTypes.includes(file.mimetype)) {
      console.log('📄 [DEBUG] File accepted:', {
        originalname: file.originalname,
        mimetype: file.mimetype,
        isCSV,
        isExcel
      });
      cb(null, true);
    } else {
      console.log('❌ [DEBUG] File rejected:', {
        originalname: file.originalname,
        mimetype: file.mimetype
      });
      cb(new Error('Only Excel and CSV files are allowed'), false);
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Get all devices for current user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { assignment_status } = req.query; // 'assigned', 'unassigned', or undefined for all
    
    // 2025-01-27: Check user permissions using permissions table
    const { data: permissions, error: permError } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: 'devices',
        p_resource_id: null,
        p_action: 'admin'
      });
    
    if (permError) {
      console.error('Permission check error:', permError);
      return res.status(500).json({ error: 'Failed to check user permissions' });
    }
    
    const isAdmin = permissions;
    
    let query = supabase
      .from('personal_devices')
      .select(`
        *,
        employees (
          id,
          name,
          department,
          position
        )
      `);
    
    // 2025-01-27: Role-based access control
    if (isAdmin) {
      // Admin can see all devices
      if (assignment_status === 'assigned') {
        query = query.not('employee_id', 'is', null);
      } else if (assignment_status === 'unassigned') {
        query = query.is('employee_id', null);
      }
      // If no assignment_status filter, show all devices
    } else {
      // Manager can only see their own devices
      if (assignment_status === 'assigned') {
        // Get employee IDs for current user
        const { data: employees } = await supabase
          .from('employees')
          .select('id')
          .eq('admin_id', req.user.id);
        
        const employeeIds = employees?.map(emp => emp.id) || [];
        
        if (employeeIds.length > 0) {
          query = query.not('employee_id', 'is', null)
                       .in('employee_id', employeeIds)
                       .eq('admin_id', req.user.id);
        } else {
          // No employees, return empty result
          query = query.eq('id', '00000000-0000-0000-0000-000000000000'); // Impossible ID
        }
      } else if (assignment_status === 'unassigned') {
        query = query.is('employee_id', null)
                     .eq('admin_id', req.user.id);
      } else {
        // Show all devices owned by current user
        query = query.eq('admin_id', req.user.id);
      }
    }
    
    const { data: devices, error } = await query
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Get devices error:', error);
      return res.status(500).json({ error: 'Failed to fetch devices' });
    }

    res.json({ devices });
  } catch (error) {
    console.error('Get devices error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single device by ID or Asset Number
router.get('/:identifier', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;

    // 2025-01-27: 자산번호로 장비 조회 지원 추가
    // Check if identifier is a UUID (device ID) or asset number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
    
    let query = supabase
      .from('personal_devices')
      .select(`
        *,
        employees (
          id,
          name,
          department,
          position,
          admin_id
        )
      `);

    if (isUUID) {
      // If it's a UUID, search by ID
      query = query.eq('id', identifier);
    } else {
      // If it's not a UUID, search by asset_number
      query = query.eq('asset_number', identifier);
    }

    const { data: device, error } = await query.single();

    if (error || !device) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // 2025-01-27: Check user permissions for single device
    const { data: hasReadPermission, error: permError } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: 'devices',
        p_resource_id: device.id,
        p_action: 'read'
      });
    
    if (permError) {
      console.error('Permission check error:', permError);
      return res.status(500).json({ error: 'Failed to check user permissions' });
    }
    
    let hasAccess = hasReadPermission;
    
    // If no specific permission, check if user owns the device
    if (!hasAccess) {
      if (device.employees && device.employees.admin_id === req.user.id) {
        // Device is assigned to current user's employee
        hasAccess = true;
      } else if (device.admin_id === req.user.id) {
        // Device is owned by current user (including unassigned devices)
        hasAccess = true;
      }
    }
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ device });
  } catch (error) {
    console.error('Get device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new device
router.post('/', authenticateToken, async (req, res) => {
  try {
    const {
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
      issue_date
    } = req.body;

    if (!asset_number) {
      return res.status(400).json({ error: 'Asset number is required' });
    }

    // Verify employee belongs to current user (only if employee_id is provided)
    let verifiedEmployeeId = null;
    if (employee_id && employee_id.trim() !== '') {
      const { data: employee, error: empError } = await supabase
        .from('employees')
        .select('id')
        .eq('id', employee_id)
        .eq('admin_id', req.user.id)
        .single();

      if (empError || !employee) {
        return res.status(400).json({ error: 'Invalid employee ID' });
      }
      verifiedEmployeeId = employee.id;
    }

    // Check if asset number already exists
    const { data: existingDevice } = await supabase
      .from('personal_devices')
      .select('id')
      .eq('asset_number', asset_number)
      .single();

    if (existingDevice) {
      return res.status(400).json({ error: 'Asset number already exists' });
    }

    // 2025-01-27: Add admin_id to device creation to fix not-null constraint violation
    // 2025-01-27: Fix date field validation to prevent empty string errors
    const deviceData = {
      admin_id: req.user.id, // 2025-01-27: Add admin_id from authenticated user
      employee_id: verifiedEmployeeId,
      asset_number,
      manufacturer: manufacturer || null,
      model_name: model_name || null,
      serial_number: serial_number || null,
      cpu: cpu || null,
      memory: memory || null,
      storage: storage || null,
      gpu: gpu || null,
      os: os || null,
      monitor: monitor || null,
      inspection_date: inspection_date || null,
      purpose: purpose || null,
      device_type: device_type || null,
      monitor_size: monitor_size || null,
      issue_date: issue_date || null
    };
    
    const { data: device, error } = await supabase
      .from('personal_devices')
      .insert([deviceData])
      .select('*')
      .single();

    if (error) {
      console.error('Create device error:', error);
      return res.status(500).json({ error: 'Failed to create device' });
    }

    // 2025-01-27: 장비 생성 시 히스토리 기록
    if (device) {
      await supabase
        .from('device_history')
        .insert([{
          device_id: device.id,
          action_type: '생성',
          action_description: `새 장비 등록: ${device.asset_number}`,
          previous_status: '없음',
          new_status: device.employee_id ? '할당됨' : '미할당',
          performed_by: req.user.id,
          metadata: { 
            created_device: device,
            manual_action: true 
          }
        }]);
    }

    res.json({ device });
  } catch (error) {
    console.error('Create device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update device by ID or Asset Number
router.put('/:identifier', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;
    
    // 2025-01-27: 자산번호로 장비 수정 지원 추가
    // Check if identifier is a UUID (device ID) or asset number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
    const {
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
      issue_date
    } = req.body;

    // 2025-01-27: Verify device belongs to current user with admin_id check
    let query = supabase
      .from('personal_devices')
      .select(`
        id,
        asset_number,
        admin_id,
        employee_id,
        employees (
          admin_id
        )
      `);

    if (isUUID) {
      // If it's a UUID, search by ID
      query = query.eq('id', identifier);
    } else {
      // If it's not a UUID, search by asset_number
      query = query.eq('asset_number', identifier);
    }

    const { data: existingDevice, error: checkError } = await query.single();

    if (checkError || !existingDevice) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // 2025-01-27: Check user permissions for device update
    const { data: hasWritePermission, error: permError } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: 'devices',
        p_resource_id: existingDevice.id,
        p_action: 'write'
      });
    
    if (permError) {
      console.error('Permission check error:', permError);
      return res.status(500).json({ error: 'Failed to check user permissions' });
    }
    
    let deviceBelongsToUser = hasWritePermission;
    
    // If no specific permission, check if user owns the device
    if (!deviceBelongsToUser) {
      if (existingDevice.employees && existingDevice.employees.admin_id === req.user.id) {
        // Device is assigned to current user's employee
        deviceBelongsToUser = true;
      } else if (existingDevice.admin_id === req.user.id) {
        // Device is owned by current user (including unassigned devices)
        deviceBelongsToUser = true;
      }
    }

    if (!deviceBelongsToUser) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const updates = {};
    
    // Handle employee_id (can be null for unassigned)
    if (employee_id !== undefined) {
      if (employee_id && employee_id.trim() !== '') {
        // Verify new employee belongs to current user
        const { data: employee, error: empError } = await supabase
          .from('employees')
          .select('id')
          .eq('id', employee_id)
          .eq('admin_id', req.user.id)
          .single();

        if (empError || !employee) {
          return res.status(400).json({ error: 'Invalid employee ID' });
        }
        updates.employee_id = employee_id;
      } else {
        // Set to null for unassigned
        updates.employee_id = null;
      }
    }

    if (asset_number && asset_number !== existingDevice.asset_number) {
      // Check if new asset number already exists
      const { data: duplicateDevice } = await supabase
        .from('personal_devices')
        .select('id')
        .eq('asset_number', asset_number)
        .neq('id', existingDevice.id)
        .single();

      if (duplicateDevice) {
        return res.status(400).json({ error: 'Asset number already exists' });
      }
      updates.asset_number = asset_number;
    }

    // 2025-01-27: Fix date field validation to prevent empty string errors
    if (manufacturer !== undefined) updates.manufacturer = manufacturer || null;
    if (model_name !== undefined) updates.model_name = model_name || null;
    if (serial_number !== undefined) updates.serial_number = serial_number || null;
    if (cpu !== undefined) updates.cpu = cpu || null;
    if (memory !== undefined) updates.memory = memory || null;
    if (storage !== undefined) updates.storage = storage || null;
    if (gpu !== undefined) updates.gpu = gpu || null;
    if (os !== undefined) updates.os = os || null;
    if (monitor !== undefined) updates.monitor = monitor || null;
    if (inspection_date !== undefined) updates.inspection_date = inspection_date || null;
    if (purpose !== undefined) updates.purpose = purpose || null;
    if (device_type !== undefined) updates.device_type = device_type || null;
    if (monitor_size !== undefined) updates.monitor_size = monitor_size || null;
    if (issue_date !== undefined) updates.issue_date = issue_date || null;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No updates provided' });
    }

    // 2025-01-27: 장비 정보 변경 전/후 기록을 위한 히스토리 추가
    const { data: updatedDevice, error } = await supabase
      .from('personal_devices')
      .update(updates)
      .eq('id', existingDevice.id)
      .select(`
        *,
        employees (
          id,
          name,
          department,
          position
        )
      `)
      .single();

    if (!error && updatedDevice) {
      // 변경된 필드들을 찾아서 히스토리에 기록
      const changedFields = [];
      Object.keys(updates).forEach(field => {
        if (field !== 'updated_at' && existingDevice[field] !== updates[field]) {
          changedFields.push({
            field,
            before: existingDevice[field],
            after: updates[field]
          });
        }
      });

             if (changedFields.length > 0) {
         // 2025-01-27: 구체적인 변경 내역을 명확하게 표시
         const changeDescriptions = changedFields.map(field => {
           const fieldNames = {
             'asset_number': '자산번호',
             'employee_id': '담당자',
             'manufacturer': '제조사',
             'model_name': '모델명',
             'serial_number': '시리얼번호',
             'cpu': 'CPU',
             'memory': '메모리',
             'storage': '저장장치',
             'gpu': '그래픽카드',
             'os': '운영체제',
             'monitor': '모니터',
             'monitor_size': '모니터크기',
             'inspection_date': '조사일자',
             'purpose': '용도',
             'device_type': '장비타입',
             'issue_date': '지급일자'
           };
           
           const fieldName = fieldNames[field.field] || field.field;
           const beforeValue = field.before || '없음';
           const afterValue = field.after || '없음';
           
           return `${fieldName}: ${beforeValue} → ${afterValue}`;
         });
         
         // 히스토리에 변경 내역 기록
         await supabase
           .from('device_history')
           .insert([{
             device_id: existingDevice.id,
             action_type: '수정',
             action_description: `장비 정보 수정 - ${changeDescriptions.join(', ')}`,
             previous_status: existingDevice.employee_id ? '할당됨' : '미할당',
             new_status: updatedDevice.employee_id ? '할당됨' : '미할당',
             performed_by: req.user.id,
             metadata: { 
               changed_fields: changedFields,
               manual_action: true 
             }
           }]);
       }
    }

    if (error) {
      console.error('Update device error:', error);
      return res.status(500).json({ error: 'Failed to update device' });
    }

    res.json({
      message: 'Device updated successfully',
      device: updatedDevice
    });
  } catch (error) {
    console.error('Update device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete device by ID or Asset Number
router.delete('/:identifier', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;
    
    // 2025-01-27: 자산번호로 장비 삭제 지원 추가
    // Check if identifier is a UUID (device ID) or asset number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);

    // 2025-01-27: 폐기된 장비만 삭제 가능하도록 수정
    // Verify device exists and get its purpose
    let query = supabase
      .from('personal_devices')
      .select(`
        id,
        purpose,
        employee_id,
        employees (
          admin_id
        )
      `);

    if (isUUID) {
      // If it's a UUID, search by ID
      query = query.eq('id', identifier);
    } else {
      // If it's not a UUID, search by asset_number
      query = query.eq('asset_number', identifier);
    }

    const { data: device, error: checkError } = await query.single();

    if (checkError || !device) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // 2025-01-27: 삭제 기능 비활성화 - 폐기된 장비는 별도 관리
    return res.status(400).json({ error: '장비 삭제 기능은 비활성화되었습니다. 폐기된 장비는 별도로 관리됩니다.' });

    // Verify device belongs to current user (handle both assigned and unassigned devices)
    let deviceBelongsToUser = false;
    
    if (device.employee_id) {
      // For assigned devices, check through employee
      const { data: employee } = await supabase
        .from('employees')
        .select('admin_id')
        .eq('id', device.employee_id)
        .single();
      
      deviceBelongsToUser = employee && employee.admin_id === req.user.id;
    } else {
      // For unassigned devices, check if user has any employees (to ensure they can manage unassigned devices)
      const { data: userEmployees } = await supabase
        .from('employees')
        .select('id')
        .eq('admin_id', req.user.id);
      
      deviceBelongsToUser = userEmployees && userEmployees.length > 0;
    }

    if (!deviceBelongsToUser) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // 2025-01-27: 삭제 기능 비활성화
    res.status(400).json({ error: '장비 삭제 기능은 비활성화되었습니다.' });
  } catch (error) {
    console.error('Delete device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Import devices from Excel
router.post('/import', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    console.log('🔍 [DEBUG] Import request received')
    console.log('🔍 [DEBUG] Request URL:', req.url)
    console.log('🔍 [DEBUG] Request method:', req.method)
    console.log('🔍 [DEBUG] Request headers:', req.headers)
    console.log('🔍 [DEBUG] File info:', req.file ? {
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size
    } : 'No file')
    
    if (!req.file) {
      console.log('❌ [DEBUG] No file provided')
      return res.status(400).json({ error: 'Excel or CSV file is required' });
    }

    let data;
    
    // Check if it's a CSV file based on extension
    const isCSV = req.file.originalname.toLowerCase().endsWith('.csv');
    
    if (isCSV) {
      console.log('📄 [DEBUG] Processing CSV file based on extension')
      // Parse CSV
      const csvContent = req.file.buffer.toString('utf-8');
      console.log('📄 [DEBUG] Full CSV content:')
      console.log(csvContent)
      
      const lines = csvContent.split('\n');
      console.log('📄 [DEBUG] Total lines:', lines.length)
      console.log('📄 [DEBUG] First line (headers):', lines[0])
      
      const headers = lines[0].split(',').map(h => h.trim().replace(/"/g, ''));
      console.log('📄 [DEBUG] Parsed headers:', headers)
      
      data = lines.slice(1)
        .filter(line => line.trim()) // Remove empty lines
        .map((line, index) => {
          console.log(`📄 [DEBUG] Processing line ${index + 2}: "${line}"`)
          const values = line.split(',').map(v => v.trim().replace(/"/g, ''));
          console.log(`📄 [DEBUG] Split values:`, values)
          
          const row = {};
          headers.forEach((header, headerIndex) => {
            const value = values[headerIndex] || '';
            row[header] = value;
            console.log(`📄 [DEBUG] Header "${header}" = "${value}"`)
          });
          console.log(`📄 [DEBUG] Final row ${index + 2}:`, row);
          return row;
        })
        .filter(row => {
          // Filter out rows where all values are empty
          const hasData = Object.values(row).some(value => value && value.trim());
          if (!hasData) {
            console.log('📄 [DEBUG] Skipping empty row');
          }
          return hasData;
        });
    } else {
      console.log('📊 [DEBUG] Processing Excel file')
      
      try {
        // Parse Excel with explicit options
        const workbook = xlsx.read(req.file.buffer, { 
          type: 'buffer',
          cellDates: true,
          cellNF: false,
          cellText: false
        });
        
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        
        console.log('📊 [DEBUG] Excel sheet info:', {
          sheetName,
          range: worksheet['!ref'],
          sheetNames: workbook.SheetNames
        });
        
        // Convert to JSON with explicit header handling
        data = xlsx.utils.sheet_to_json(worksheet, { 
          header: 1, // Use first row as headers
          defval: '',
          blankrows: false
        });
        
        console.log('📊 [DEBUG] Raw Excel data (first 3 rows):', data.slice(0, 3));
        
        if (data.length < 2) {
          console.log('❌ [DEBUG] Excel file has insufficient data');
          return res.status(400).json({ error: 'Excel file has insufficient data' });
        }
        
        // Extract headers from first row
        const headers = data[0];
        console.log('📊 [DEBUG] Headers:', headers);
        
        // Check if 자산번호 exists in headers
        const assetNumberIndex = headers.findIndex(header => 
          header && header.toString().toLowerCase().includes('자산번호')
        );
        
        if (assetNumberIndex === -1) {
          console.log('❌ [DEBUG] 자산번호 not found in headers');
          console.log('📊 [DEBUG] Available headers:', headers);
          return res.status(400).json({ error: '자산번호 column not found in Excel file' });
        }
        
        console.log(`✅ [DEBUG] 자산번호 found at index ${assetNumberIndex}`);
        
        // Convert data rows to objects
        data = data.slice(1).map((row, index) => {
          const obj = {};
          headers.forEach((header, headerIndex) => {
            if (header) {
              obj[header] = row[headerIndex] || '';
            }
          });
          console.log(`📊 [DEBUG] Row ${index + 2}:`, obj);
          return obj;
        });
        
      } catch (error) {
        console.error('❌ [DEBUG] Excel parsing error:', error);
        return res.status(400).json({ error: 'Failed to parse Excel file: ' + error.message });
      }
    }

    console.log('📊 [DEBUG] Parsed data rows:', data.length)
    console.log('📊 [DEBUG] First row sample:', data[0])

    if (data.length === 0) {
      console.log('❌ [DEBUG] No data found in file')
      return res.status(400).json({ error: 'File is empty' });
    }

    const errors = [];
    const successDevices = [];

    for (let i = 0; i < data.length; i++) {
      const row = data[i];
      console.log(`🔍 [DEBUG] Processing row ${i + 1}:`, row)
      
      try {
        // Validate required fields
        console.log(`🔍 [DEBUG] Validating row ${i + 1}:`, row);
        console.log(`🔍 [DEBUG] 자산번호 value: "${row.자산번호}"`);
        
        if (!row.자산번호 || row.자산번호.toString().trim() === '') {
          const error = `Row ${i + 2}: 자산번호 is required (empty or missing)`;
          console.log('❌ [DEBUG]', error);
          errors.push(error);
          continue;
        }

        // Find employee by name (if provided)
        let employeeId = null;
        if (row.사용자 && row.사용자.toString().trim() !== '') {
          console.log(`🔍 [DEBUG] Looking for employee: "${row.사용자}"`)
          const { data: employee, error: empError } = await supabase
            .from('employees')
            .select('id')
            .eq('name', row.사용자.toString().trim())
            .eq('admin_id', req.user.id)
            .single();

          if (empError || !employee) {
            const error = `Row ${i + 2}: Employee '${row.사용자}' not found`;
            console.log('❌ [DEBUG]', error);
            errors.push(error);
            continue;
          }
          employeeId = employee.id;
          console.log(`✅ [DEBUG] Found employee ID: ${employeeId}`)
        }

        // 2025-01-27: UPSERT 로직 구현 - 자산번호 중복 시 UPDATE 처리
        // Check if asset number already exists
        console.log(`🔍 [DEBUG] Checking if asset number exists: "${row.자산번호}"`)
        const { data: existingDevice } = await supabase
          .from('personal_devices')
          .select('id')
          .eq('asset_number', row.자산번호.toString().trim())
          .single();

        // 2025-01-27: Create device with all new fields including admin_id
        // 2025-01-27: Fix date field validation to prevent empty string errors
        const deviceData = {
          admin_id: req.user.id, // 2025-01-27: Add admin_id from authenticated user
          employee_id: employeeId,
          asset_number: row.자산번호.toString().trim(),
          inspection_date: row.조사일자 && row.조사일자.toString().trim() !== '' ? row.조사일자.toString().trim() : null,
          purpose: row.용도 && row.용도.toString().trim() !== '' ? row.용도.toString().trim() : null,
          device_type: row['장비 Type'] && row['장비 Type'].toString().trim() !== '' ? row['장비 Type'].toString().trim() : null,
          manufacturer: row.제조사 && row.제조사.toString().trim() !== '' ? row.제조사.toString().trim() : null,
          model_name: row.모델명 && row.모델명.toString().trim() !== '' ? row.모델명.toString().trim() : null,
          serial_number: row['S/N'] && row['S/N'].toString().trim() !== '' ? row['S/N'].toString().trim() : null,
          monitor_size: row.모니터크기 && row.모니터크기.toString().trim() !== '' ? row.모니터크기.toString().trim() : null,
          issue_date: row.지급일자 && row.지급일자.toString().trim() !== '' ? row.지급일자.toString().trim() : null,
          cpu: row.CPU && row.CPU.toString().trim() !== '' ? row.CPU.toString().trim() : null,
          memory: row.메모리 && row.메모리.toString().trim() !== '' ? row.메모리.toString().trim() : null,
          storage: row.하드디스크 && row.하드디스크.toString().trim() !== '' ? row.하드디스크.toString().trim() : null,
          gpu: row.그래픽카드 && row.그래픽카드.toString().trim() !== '' ? row.그래픽카드.toString().trim() : null,
          os: row.OS && row.OS.toString().trim() !== '' ? row.OS.toString().trim() : null
        };
        
        let device;
        let error;

        if (existingDevice) {
          // 2025-01-27: 기존 장비가 있으면 UPDATE
          console.log(`🔄 [DEBUG] Updating existing device ID: ${existingDevice.id}`);
          const { data: updatedDevice, error: updateError } = await supabase
            .from('personal_devices')
            .update(deviceData)
            .eq('id', existingDevice.id)
            .select('*')
            .single();
          
          device = updatedDevice;
          error = updateError;
          
          if (!error) {
            console.log(`✅ [DEBUG] Device updated successfully: ${device.id}`);
          }
        } else {
          // 2025-01-27: 새 장비이면 INSERT
          console.log(`🚀 [DEBUG] Creating new device with data:`, deviceData);
          const { data: newDevice, error: insertError } = await supabase
            .from('personal_devices')
            .insert([deviceData])
            .select('*')
            .single();
          
          device = newDevice;
          error = insertError;
          
          if (!error) {
            console.log(`✅ [DEBUG] Device created successfully: ${device.id}`);
          }
        }

                 if (error) {
           const errorMsg = `Row ${i + 2}: Failed to ${existingDevice ? 'update' : 'create'} device - ${error.message}`;
           console.log('❌ [DEBUG]', errorMsg);
           errors.push(errorMsg);
         } else {
           console.log(`✅ [DEBUG] Device ${existingDevice ? 'updated' : 'created'} successfully: ${device.id}`)
           
           // 2025-01-27: Excel 임포트 시 히스토리 기록
           if (existingDevice) {
             // 업데이트된 경우 변경 내역 기록
             const changedFields = [];
             Object.keys(deviceData).forEach(field => {
               if (field !== 'admin_id' && existingDevice[field] !== deviceData[field]) {
                 changedFields.push({
                   field,
                   before: existingDevice[field],
                   after: deviceData[field]
                 });
               }
             });
             
             if (changedFields.length > 0) {
               // 2025-01-27: Excel 임포트 시에도 구체적인 변경 내역을 명확하게 표시
               const changeDescriptions = changedFields.map(field => {
                 const fieldNames = {
                   'asset_number': '자산번호',
                   'employee_id': '담당자',
                   'manufacturer': '제조사',
                   'model_name': '모델명',
                   'serial_number': '시리얼번호',
                   'cpu': 'CPU',
                   'memory': '메모리',
                   'storage': '저장장치',
                   'gpu': '그래픽카드',
                   'os': '운영체제',
                   'monitor': '모니터',
                   'monitor_size': '모니터크기',
                   'inspection_date': '조사일자',
                   'purpose': '용도',
                   'device_type': '장비타입',
                   'issue_date': '지급일자'
                 };
                 
                 const fieldName = fieldNames[field.field] || field.field;
                 const beforeValue = field.before || '없음';
                 const afterValue = field.after || '없음';
                 
                 return `${fieldName}: ${beforeValue} → ${afterValue}`;
               });
               
               await supabase
                 .from('device_history')
                 .insert([{
                   device_id: device.id,
                   action_type: 'Excel수정',
                   action_description: `Excel 임포트로 수정 - ${changeDescriptions.join(', ')}`,
                   previous_status: existingDevice.employee_id ? '할당됨' : '미할당',
                   new_status: device.employee_id ? '할당됨' : '미할당',
                   performed_by: req.user.id,
                   metadata: { 
                     changed_fields: changedFields,
                     import_source: 'excel',
                     manual_action: false 
                   }
                 }]);
             }
           } else {
             // 새로 생성된 경우
             await supabase
               .from('device_history')
               .insert([{
                 device_id: device.id,
                 action_type: 'Excel생성',
                 action_description: `Excel 임포트로 생성: ${device.asset_number}`,
                 previous_status: '없음',
                 new_status: device.employee_id ? '할당됨' : '미할당',
                 performed_by: req.user.id,
                 metadata: { 
                   created_device: device,
                   import_source: 'excel',
                   manual_action: false 
                 }
               }]);
           }
           
           successDevices.push(device);
         }
      } catch (error) {
        const errorMsg = `Row ${i + 2}: ${error.message}`;
        console.log('❌ [DEBUG]', errorMsg);
        errors.push(errorMsg);
      }
    }

    console.log('📊 [DEBUG] Import completed:', {
      success_count: successDevices.length,
      error_count: errors.length,
      errors: errors.slice(0, 5)
    })

    res.json({
      message: 'Import completed',
      success_count: successDevices.length,
      error_count: errors.length,
      errors: errors.slice(0, 10), // Limit errors for response size
      devices: successDevices
    });
  } catch (error) {
    console.error('❌ [DEBUG] Import error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2025-01-27: Export devices to Excel
router.get('/export/excel', authenticateToken, async (req, res) => {
  try {
    const { data: devices, error } = await supabase
      .from('personal_devices')
      .select(`
        *,
        employees (
          name,
          department,
          position
        )
      `)
      .in('employee_id', 
        await supabase
          .from('employees')
          .select('id')
          .eq('admin_id', req.user.id)
          .then(({ data }) => data?.map(emp => emp.id) || [])
      )
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Export error:', error);
      return res.status(500).json({ error: 'Failed to fetch devices' });
    }

    // Transform data for Excel
    const excelData = devices.map(device => ({
      'Asset Number': device.asset_number,
      'Employee Name': device.employees?.name || '',
      'Department': device.employees?.department || '',
      'Position': device.employees?.position || '',
      'Manufacturer': device.manufacturer || '',
      'Model Name': device.model_name || '',
      'Serial Number': device.serial_number || '',
      'CPU': device.cpu || '',
      'Memory': device.memory || '',
      'Storage': device.storage || '',
      'GPU': device.gpu || '',
      'OS': device.os || '',
      'Monitor': device.monitor || '',
      'Created At': new Date(device.created_at).toLocaleDateString()
    }));

    // Create workbook and worksheet
    const workbook = xlsx.utils.book_new();
    const worksheet = xlsx.utils.json_to_sheet(excelData);

    // Add worksheet to workbook
    xlsx.utils.book_append_sheet(workbook, worksheet, 'Devices');

    // Generate buffer
    const buffer = xlsx.write(workbook, { type: 'buffer', bookType: 'xlsx' });

    // Set headers for file download
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="devices_${new Date().toISOString().split('T')[0]}.xlsx"`);

    res.send(buffer);
  } catch (error) {
    console.error('Export error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2025-01-27: 장비 히스토리 조회 API 추가 (자산번호 지원)
router.get('/:identifier/history', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;
    
    // 2025-01-27: 자산번호로 장비 히스토리 조회 지원 추가
    // Check if identifier is a UUID (device ID) or asset number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
    
    let query = supabase
      .from('personal_devices')
      .select('id, asset_number');

    if (isUUID) {
      // If it's a UUID, search by ID
      query = query.eq('id', identifier);
    } else {
      // If it's not a UUID, search by asset_number
      query = query.eq('asset_number', identifier);
    }
    
    const { data: device, error: deviceError } = await query.single();
    
    if (deviceError || !device) {
      return res.status(404).json({ error: '장비를 찾을 수 없습니다' });
    }
    
         // 장비 히스토리 조회 (users 테이블 조인 제거)
     const { data: history, error } = await supabase
       .from('device_history')
       .select('*')
       .eq('device_id', device.id)
       .order('performed_at', { ascending: false });
    
    if (error) {
      console.error('History fetch error:', error);
      return res.status(500).json({ error: '히스토리를 불러올 수 없습니다' });
    }
    
    res.json({ 
      device: { id: device.id, asset_number: device.asset_number },
      history: history || [] 
    });
    
  } catch (error) {
    console.error('Device history error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2025-01-27: 장비 상태 변경 API 추가 (반납, 폐기 등) - 자산번호 지원
// 2025-01-27: 반납 처리 API (사용자 요청에 따른 단순화)
router.patch('/:identifier/return', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;
    
    // Check if identifier is a UUID (device ID) or asset number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
    
    // 장비 존재 확인
    let query = supabase
      .from('personal_devices')
      .select('id, asset_number, employee_id');

    if (isUUID) {
      query = query.eq('id', identifier);
    } else {
      query = query.eq('asset_number', identifier);
    }
    
    const { data: device, error: deviceError } = await query.single();
    
    if (deviceError || !device) {
      return res.status(404).json({ error: '장비를 찾을 수 없습니다' });
    }
    
    // 할당된 장비만 반납 가능
    if (!device.employee_id) {
      return res.status(400).json({ error: '이미 미할당 상태인 장비입니다' });
    }
    
    // 반납 처리: 담당직원을 미할당으로 변경
    const { data: updatedDevice, error: updateError } = await supabase
      .from('personal_devices')
      .update({ employee_id: null })
      .eq('id', device.id)
      .select('*')
      .single();
    
    if (updateError) {
      console.error('Return device error:', updateError);
      return res.status(500).json({ error: '반납 처리에 실패했습니다' });
    }
    
    res.json({ 
      message: '장비가 성공적으로 반납되었습니다',
      device: updatedDevice 
    });
    
  } catch (error) {
    console.error('Return device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2025-01-27: 폐기 처리 API (사용자 요청에 따른 폐기 사유 포함)
router.patch('/:identifier/dispose', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;
    const { reason } = req.body;
    
    // 폐기 사유 필수 확인
    if (!reason || reason.trim() === '') {
      return res.status(400).json({ error: '폐기 사유를 입력해주세요' });
    }
    
    // Check if identifier is a UUID (device ID) or asset number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
    
    // 장비 존재 확인
    let query = supabase
      .from('personal_devices')
      .select('id, asset_number, employee_id, purpose');

    if (isUUID) {
      query = query.eq('id', identifier);
    } else {
      query = query.eq('asset_number', identifier);
    }
    
    const { data: device, error: deviceError } = await query.single();
    
    if (deviceError || !device) {
      return res.status(404).json({ error: '장비를 찾을 수 없습니다' });
    }
    
    // 이미 폐기된 장비 확인
    if (device.purpose === '폐기') {
      return res.status(400).json({ error: '이미 폐기된 장비입니다' });
    }
    
    // 폐기 처리: 담당직원 미할당 + 용도를 '폐기'로 설정
    const { data: updatedDevice, error: updateError } = await supabase
      .from('personal_devices')
      .update({ 
        employee_id: null,
        purpose: '폐기'
      })
      .eq('id', device.id)
      .select('*')
      .single();
    
    if (updateError) {
      console.error('Dispose device error:', updateError);
      return res.status(500).json({ error: '폐기 처리에 실패했습니다' });
    }
    
    // 폐기 사유를 히스토리에 추가 기록
    await supabase
      .from('device_history')
      .insert([{
        device_id: device.id,
        action_type: '폐기',
        action_description: `폐기 사유: ${reason}`,
        previous_status: device.employee_id ? '할당됨' : '미할당',
        new_status: '미할당',
        performed_by: req.user.id,
        metadata: { dispose_reason: reason, manual_action: true }
      }]);
    
    res.json({ 
      message: '장비가 성공적으로 폐기되었습니다',
      device: updatedDevice 
    });
    
  } catch (error) {
    console.error('Dispose device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 기존 status API는 유지 (하위 호환성)
router.patch('/:identifier/status', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;
    
    // 2025-01-27: 자산번호로 장비 상태 변경 지원 추가
    // Check if identifier is a UUID (device ID) or asset number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
    const { status, reason } = req.body;
    
    // 유효한 상태값 확인
    const validStatuses = ['returned', 'disposed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: '유효하지 않은 상태값입니다. 반납(returned) 또는 폐기(disposed)만 가능합니다.' });
    }
    
    // 장비 존재 확인
    let query = supabase
      .from('personal_devices')
      .select('id, asset_number, employee_id');

    if (isUUID) {
      // If it's a UUID, search by ID
      query = query.eq('id', identifier);
    } else {
      // If it's not a UUID, search by asset_number
      query = query.eq('asset_number', identifier);
    }
    
    const { data: device, error: deviceError } = await query.single();
    
    if (deviceError || !device) {
      return res.status(404).json({ error: '장비를 찾을 수 없습니다' });
    }
    
    // 2025-01-27: 상태 변경 업데이트 - employee_id를 null로 설정하고, 폐기 시 purpose를 '폐기'로 설정
    const updateData = { employee_id: null };
    
    // 폐기 처리 시 purpose를 '폐기'로 설정
    if (status === 'disposed') {
      updateData.purpose = '폐기';
    }
    
    const { data: updatedDevice, error: updateError } = await supabase
      .from('personal_devices')
      .update(updateData)
      .eq('id', device.id)
      .select('*')
      .single();
    
    if (updateError) {
      console.error('Status update error:', updateError);
      return res.status(500).json({ error: '상태 변경에 실패했습니다' });
    }
    
    res.json({ 
      message: '상태가 성공적으로 변경되었습니다',
      device: updatedDevice 
    });
    
  } catch (error) {
    console.error('Status change error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;