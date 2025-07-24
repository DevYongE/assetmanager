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
    if (file.mimetype === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
        file.mimetype === 'application/vnd.ms-excel') {
      cb(null, true);
    } else {
      cb(new Error('Only Excel files are allowed'), false);
    }
  },
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Get all devices for the authenticated user's employees
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { data: devices, error } = await supabase
      .from('personal_devices')
      .select(`
        *,
        employees (
          id,
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
      monitor
    } = req.body;

    if (!employee_id || !asset_number) {
      return res.status(400).json({ error: 'Employee ID and asset number are required' });
    }

    // Verify employee belongs to current user
    const { data: employee, error: empError } = await supabase
      .from('employees')
      .select('id')
      .eq('id', employee_id)
      .eq('admin_id', req.user.id)
      .single();

    if (empError || !employee) {
      return res.status(400).json({ error: 'Invalid employee ID' });
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
        monitor
      }])
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
      console.error('Create device error:', error);
      return res.status(500).json({ error: 'Failed to create device' });
    }

    res.status(201).json({
      message: 'Device created successfully',
      device
    });
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
      monitor
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

    if (checkError || !existingDevice || existingDevice.employees.admin_id !== req.user.id) {
      return res.status(404).json({ error: 'Device not found' });
    }

    const updates = {};
    if (employee_id) {
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

    if (checkError || !device || device.employees.admin_id !== req.user.id) {
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
    if (!req.file) {
      return res.status(400).json({ error: 'Excel file is required' });
    }

    const workbook = xlsx.read(req.file.buffer, { type: 'buffer' });
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    const data = xlsx.utils.sheet_to_json(worksheet);

    if (data.length === 0) {
      return res.status(400).json({ error: 'Excel file is empty' });
    }

    const errors = [];
    const successDevices = [];

    for (let i = 0; i < data.length; i++) {
      const row = data[i];
      try {
        // Validate required fields
        if (!row.employee_name || !row.asset_number) {
          errors.push(`Row ${i + 2}: Employee name and asset number are required`);
          continue;
        }

        // Find employee by name
        const { data: employee, error: empError } = await supabase
          .from('employees')
          .select('id')
          .eq('name', row.employee_name)
          .eq('admin_id', req.user.id)
          .single();

        if (empError || !employee) {
          errors.push(`Row ${i + 2}: Employee '${row.employee_name}' not found`);
          continue;
        }

        // Check if asset number already exists
        const { data: existingDevice } = await supabase
          .from('personal_devices')
          .select('id')
          .eq('asset_number', row.asset_number)
          .single();

        if (existingDevice) {
          errors.push(`Row ${i + 2}: Asset number '${row.asset_number}' already exists`);
          continue;
        }

        // Create device
        const { data: device, error } = await supabase
          .from('personal_devices')
          .insert([{
            employee_id: employee.id,
            asset_number: row.asset_number,
            manufacturer: row.manufacturer || null,
            model_name: row.model_name || null,
            serial_number: row.serial_number || null,
            cpu: row.cpu || null,
            memory: row.memory || null,
            storage: row.storage || null,
            gpu: row.gpu || null,
            os: row.os || null,
            monitor: row.monitor || null
          }])
          .select('*')
          .single();

        if (error) {
          errors.push(`Row ${i + 2}: Failed to create device - ${error.message}`);
        } else {
          successDevices.push(device);
        }
      } catch (error) {
        errors.push(`Row ${i + 2}: ${error.message}`);
      }
    }

    res.json({
      message: 'Import completed',
      success_count: successDevices.length,
      error_count: errors.length,
      errors: errors.slice(0, 10), // Limit errors for response size
      devices: successDevices
    });
  } catch (error) {
    console.error('Import error:', error);
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