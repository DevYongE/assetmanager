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
    
    // Get employee IDs for current user
    const { data: employees } = await supabase
      .from('employees')
      .select('id')
      .eq('admin_id', req.user.id);
    
    const employeeIds = employees?.map(emp => emp.id) || [];
    
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
    
    // Apply assignment status filter
    if (assignment_status === 'assigned') {
      // Only assigned devices (employee_id is not null and in employeeIds)
      query = query.not('employee_id', 'is', null).in('employee_id', employeeIds);
    } else if (assignment_status === 'unassigned') {
      // Only unassigned devices (employee_id is null)
      query = query.is('employee_id', null);
    } else {
      // Show all devices: assigned to current user's employees OR unassigned
      if (employeeIds.length > 0) {
        query = query.or(`employee_id.in.(${employeeIds.join(',')}),employee_id.is.null`);
      } else {
        // If no employees, show only unassigned devices
        query = query.is('employee_id', null);
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

// Get single device by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const { data: device, error } = await supabase
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
      `)
      .eq('id', id)
      .single();

    if (error || !device) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // Check if device belongs to user's employee
    if (device.employees.admin_id !== req.user.id) {
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

    const { data: device, error } = await supabase
      .from('personal_devices')
      .insert([{
        employee_id: verifiedEmployeeId,
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
      }])
      .select('*')
      .single();

    if (error) {
      console.error('Create device error:', error);
      return res.status(500).json({ error: 'Failed to create device' });
    }

    res.json({ device });
  } catch (error) {
    console.error('Create device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update device
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
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

    // Verify device belongs to user's employee
    const { data: existingDevice, error: checkError } = await supabase
      .from('personal_devices')
      .select(`
        id,
        asset_number,
        employees (
          admin_id
        )
      `)
      .eq('id', id)
      .single();

    if (checkError || !existingDevice) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // Verify device belongs to current user (handle both assigned and unassigned devices)
    let deviceBelongsToUser = false;
    
    if (existingDevice.employee_id) {
      // For assigned devices, check through employee
      const { data: employee } = await supabase
        .from('employees')
        .select('admin_id')
        .eq('id', existingDevice.employee_id)
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
        .neq('id', id)
        .single();

      if (duplicateDevice) {
        return res.status(400).json({ error: 'Asset number already exists' });
      }
      updates.asset_number = asset_number;
    }

    if (manufacturer !== undefined) updates.manufacturer = manufacturer;
    if (model_name !== undefined) updates.model_name = model_name;
    if (serial_number !== undefined) updates.serial_number = serial_number;
    if (cpu !== undefined) updates.cpu = cpu;
    if (memory !== undefined) updates.memory = memory;
    if (storage !== undefined) updates.storage = storage;
    if (gpu !== undefined) updates.gpu = gpu;
    if (os !== undefined) updates.os = os;
    if (monitor !== undefined) updates.monitor = monitor;
    if (inspection_date !== undefined) updates.inspection_date = inspection_date;
    if (purpose !== undefined) updates.purpose = purpose;
    if (device_type !== undefined) updates.device_type = device_type;
    if (monitor_size !== undefined) updates.monitor_size = monitor_size;
    if (issue_date !== undefined) updates.issue_date = issue_date;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No updates provided' });
    }

    const { data: device, error } = await supabase
      .from('personal_devices')
      .update(updates)
      .eq('id', id)
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

    if (error) {
      console.error('Update device error:', error);
      return res.status(500).json({ error: 'Failed to update device' });
    }

    res.json({
      message: 'Device updated successfully',
      device
    });
  } catch (error) {
    console.error('Update device error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete device
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Verify device belongs to user's employee
    const { data: device, error: checkError } = await supabase
      .from('personal_devices')
      .select(`
        id,
        employees (
          admin_id
        )
      `)
      .eq('id', id)
      .single();

    if (checkError || !device) {
      return res.status(404).json({ error: 'Device not found' });
    }

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

    const { error } = await supabase
      .from('personal_devices')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('Delete device error:', error);
      return res.status(500).json({ error: 'Failed to delete device' });
    }

    res.json({ message: 'Device deleted successfully' });
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

        // Check if asset number already exists
        console.log(`🔍 [DEBUG] Checking if asset number exists: "${row.자산번호}"`)
        const { data: existingDevice } = await supabase
          .from('personal_devices')
          .select('id')
          .eq('asset_number', row.자산번호.toString().trim())
          .single();

        if (existingDevice) {
          const error = `Row ${i + 2}: Asset number '${row.자산번호}' already exists`;
          console.log('❌ [DEBUG]', error);
          errors.push(error);
          continue;
        }

        // Create device with all new fields
        const deviceData = {
          employee_id: employeeId,
          asset_number: row.자산번호.toString().trim(),
          inspection_date: row.조사일자 ? row.조사일자.toString().trim() : null,
          purpose: row.용도 ? row.용도.toString().trim() : null,
          device_type: row['장비 Type'] ? row['장비 Type'].toString().trim() : null,
          manufacturer: row.제조사 ? row.제조사.toString().trim() : null,
          model_name: row.모델명 ? row.모델명.toString().trim() : null,
          serial_number: row['S/N'] ? row['S/N'].toString().trim() : null,
          monitor_size: row.모니터크기 ? row.모니터크기.toString().trim() : null,
          issue_date: row.지급일자 ? row.지급일자.toString().trim() : null,
          cpu: row.CPU ? row.CPU.toString().trim() : null,
          memory: row.메모리 ? row.메모리.toString().trim() : null,
          storage: row.하드디스크 ? row.하드디스크.toString().trim() : null,
          gpu: row.그래픽카드 ? row.그래픽카드.toString().trim() : null,
          os: row.OS ? row.OS.toString().trim() : null
        };
        
        console.log(`🚀 [DEBUG] Creating device with data:`, deviceData);
        
        const { data: device, error } = await supabase
          .from('personal_devices')
          .insert([deviceData])
          .select('*')
          .single();

        if (error) {
          const errorMsg = `Row ${i + 2}: Failed to create device - ${error.message}`;
          console.log('❌ [DEBUG]', errorMsg);
          errors.push(errorMsg);
        } else {
          console.log(`✅ [DEBUG] Device created successfully: ${device.id}`)
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

// Export devices to Excel
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

module.exports = router; 