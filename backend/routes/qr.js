const express = require('express');
const QRCode = require('qrcode');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Generate QR code for a specific device - Simplified version
router.get('/device/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { format = 'png', size = 200 } = req.query;

    // Verify device belongs to user's employee
    const { data: device, error } = await supabase
      .from('personal_devices')
      .select(`
        id,
        asset_number,
        manufacturer,
        model_name,
        serial_number,
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

    // Create simplified QR code data with only essential information
    const qrData = {
      t: 'd', // type: device (shortened)
      i: device.id, // id (shortened)
      a: device.asset_number, // asset_number (shortened)
      m: device.manufacturer, // manufacturer (shortened)
      n: device.model_name, // model_name (shortened)
      s: device.serial_number, // serial_number (shortened)
      e: device.employees.name, // employee name (shortened)
      c: req.user.company_name, // company (shortened)
      g: new Date().toISOString().split('T')[0] // generated date (shortened, date only)
    };

    const qrString = JSON.stringify(qrData);

    if (format === 'json') {
      // Return QR data as JSON
      res.json({ qr_data: qrData, qr_string: qrString });
    } else if (format === 'svg') {
      // Generate SVG QR code
      const qrSvg = await QRCode.toString(qrString, {
        type: 'svg',
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      res.setHeader('Content-Type', 'image/svg+xml');
      res.send(qrSvg);
    } else {
      // Generate PNG QR code (default)
      const qrBuffer = await QRCode.toBuffer(qrString, {
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      res.setHeader('Content-Type', 'image/png');
      res.setHeader('Content-Disposition', `inline; filename="qr_device_${device.asset_number}.png"`);
      res.send(qrBuffer);
    }
  } catch (error) {
    console.error('QR generation error:', error);
    res.status(500).json({ error: 'Failed to generate QR code' });
  }
});

// Generate QR code for an employee - Simplified version
router.get('/employee/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { format = 'png', size = 200 } = req.query;

    // Verify employee belongs to current user
    const { data: employee, error } = await supabase
      .from('employees')
      .select(`
        id,
        name,
        department,
        position,
        personal_devices (
          id,
          asset_number,
          manufacturer,
          model_name,
          serial_number
        )
      `)
      .eq('id', id)
      .eq('admin_id', req.user.id)
      .single();

    if (error || !employee) {
      return res.status(404).json({ error: 'Employee not found' });
    }

    // Create simplified QR code data with only essential information
    const qrData = {
      t: 'e', // type: employee (shortened)
      i: employee.id, // id (shortened)
      n: employee.name, // name (shortened)
      d: employee.department, // department (shortened)
      p: employee.position, // position (shortened)
      c: req.user.company_name, // company (shortened)
      g: new Date().toISOString().split('T')[0] // generated date (shortened, date only)
    };

    const qrString = JSON.stringify(qrData);

    if (format === 'json') {
      // Return QR data as JSON
      res.json({ qr_data: qrData, qr_string: qrString });
    } else if (format === 'svg') {
      // Generate SVG QR code
      const qrSvg = await QRCode.toString(qrString, {
        type: 'svg',
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      res.setHeader('Content-Type', 'image/svg+xml');
      res.send(qrSvg);
    } else {
      // Generate PNG QR code (default)
      const qrBuffer = await QRCode.toBuffer(qrString, {
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });

      res.setHeader('Content-Type', 'image/png');
      res.setHeader('Content-Disposition', `inline; filename="qr_employee_${employee.name.replace(/\s+/g, '_')}.png"`);
      res.send(qrBuffer);
    }
  } catch (error) {
    console.error('QR generation error:', error);
    res.status(500).json({ error: 'Failed to generate QR code' });
  }
});

// Bulk generate QR codes for multiple devices - Simplified version
router.post('/bulk/devices', authenticateToken, async (req, res) => {
  try {
    const { device_ids, format = 'png', size = 200 } = req.body;

    console.log('🔍 [BULK QR] Request received:', { device_ids, format, size, user_id: req.user.id });

    if (!device_ids || !Array.isArray(device_ids) || device_ids.length === 0) {
      console.log('❌ [BULK QR] Invalid device_ids:', device_ids);
      return res.status(400).json({ error: 'Device IDs array is required' });
    }

    if (device_ids.length > 50) {
      console.log('❌ [BULK QR] Too many devices requested:', device_ids.length);
      return res.status(400).json({ error: 'Maximum 50 devices per bulk request' });
    }

    // Get all devices that belong to user's employees
    const { data: devices, error } = await supabase
      .from('personal_devices')
      .select(`
        id,
        asset_number,
        manufacturer,
        model_name,
        serial_number,
        employee_id,
        employees (
          id,
          name,
          department,
          position,
          admin_id
        )
      `)
      .in('id', device_ids);

    if (error) {
      console.error('Bulk QR fetch error:', error);
      return res.status(500).json({ error: 'Failed to fetch devices' });
    }

    console.log('🔍 [BULK QR] Found devices:', devices?.length || 0);

    // Filter devices that belong to user's employees
    const userEmployeeIds = await supabase
      .from('employees')
      .select('id')
      .eq('admin_id', req.user.id)
      .then(({ data }) => data?.map(emp => emp.id) || []);

    console.log('🔍 [BULK QR] User employee IDs:', userEmployeeIds);

    const filteredDevices = devices?.filter(device => 
      userEmployeeIds.includes(device.employee_id)
    ) || [];

    console.log('🔍 [BULK QR] Filtered devices:', filteredDevices.length);

    if (filteredDevices.length === 0) {
      console.log('❌ [BULK QR] No devices found for user employees');
      return res.status(404).json({ error: 'No devices found for your employees' });
    }

    const qrCodes = await Promise.all(
      filteredDevices.map(async (device) => {
        try {
          // Create simplified QR code data
          const qrData = {
            t: 'd', // type: device (shortened)
            i: device.id, // id (shortened)
            a: device.asset_number, // asset_number (shortened)
            m: device.manufacturer, // manufacturer (shortened)
            n: device.model_name, // model_name (shortened)
            s: device.serial_number, // serial_number (shortened)
            e: device.employees.name, // employee name (shortened)
            c: req.user.company_name, // company (shortened)
            g: new Date().toISOString().split('T')[0] // generated date (shortened, date only)
          };

          const qrString = JSON.stringify(qrData);

          if (format === 'json') {
            return {
              device_id: device.id,
              asset_number: device.asset_number,
              qr_data: qrData,
              qr_string: qrString
            };
          } else {
            const qrDataUrl = await QRCode.toDataURL(qrString, {
              width: parseInt(size),
              margin: 2,
              color: {
                dark: '#000000',
                light: '#FFFFFF'
              }
            });

            return {
              device_id: device.id,
              asset_number: device.asset_number,
              qr_data_url: qrDataUrl
            };
          }
        } catch (qrError) {
          console.error(`QR generation error for device ${device.id}:`, qrError);
          return {
            device_id: device.id,
            asset_number: device.asset_number,
            error: 'Failed to generate QR code'
          };
        }
      })
    );

    res.json({
      message: 'Bulk QR codes generated',
      total_requested: device_ids.length,
      total_generated: qrCodes.filter(qr => !qr.error).length,
      qr_codes: qrCodes
    });
  } catch (error) {
    console.error('Bulk QR generation error:', error);
    res.status(500).json({ error: 'Failed to generate bulk QR codes' });
  }
});

// Decode QR code data (for verification) - Updated for simplified format
router.post('/decode', async (req, res) => {
  try {
    const { qr_string } = req.body;

    // Validate input
    if (!qr_string || typeof qr_string !== 'string' || qr_string.trim() === '') {
      return res.status(400).json({ 
        error: 'QR string is required and must be a non-empty string',
        is_valid: false
      });
    }

    try {
      const qrData = JSON.parse(qr_string);
      
      // Validate QR data structure
      if (!qrData || typeof qrData !== 'object') {
        return res.status(400).json({ 
          error: 'Invalid QR code format - must be valid JSON object',
          is_valid: false
        });
      }

      // Support both simplified and full format
      let isValid = false;
      let fullFormatData = {};

      // Check for simplified format (new)
      if (qrData.t && qrData.i && qrData.g) {
        isValid = true;
        fullFormatData = {
          type: qrData.t === 'd' ? 'device' : 'employee',
          id: qrData.i,
          asset_number: qrData.a || '',
          manufacturer: qrData.m || '',
          model_name: qrData.n || '',
          serial_number: qrData.s || '',
          employee: qrData.e ? { name: qrData.e } : undefined,
          name: qrData.n || '',
          department: qrData.d || '',
          position: qrData.p || '',
          company: qrData.c || '',
          generated_at: qrData.g
        };
      }
      // Check for full format (legacy)
      else if (qrData.type && qrData.id) {
        isValid = true;
        fullFormatData = qrData;
      }
      // Invalid format
      else {
        return res.status(400).json({ 
          error: 'Invalid QR code format - missing required fields',
          is_valid: false
        });
      }

      if (!isValid) {
        return res.status(400).json({ 
          error: 'Invalid QR code format',
          is_valid: false
        });
      }

      res.json({
        message: 'QR code decoded successfully',
        data: fullFormatData,
        is_valid: true
      });
    } catch (parseError) {
      console.error('QR parse error:', parseError);
      res.status(400).json({ 
        error: 'Invalid QR code format - must be valid JSON',
        is_valid: false
      });
    }
  } catch (error) {
    console.error('QR decode error:', error);
    res.status(500).json({ 
      error: 'Failed to decode QR code',
      is_valid: false
    });
  }
});

// Test endpoint for bulk QR generation (development only)
if (process.env.NODE_ENV === 'development') {
  router.post('/bulk/test', async (req, res) => {
    try {
      const { device_ids, format = 'json' } = req.body;
      
      console.log('🔍 [BULK QR TEST] Test request:', { device_ids, format });
      
      // Generate mock QR codes for testing
      const mockQRCodes = device_ids.map((deviceId, index) => ({
        device_id: deviceId,
        asset_number: `AS-TEST-${String(index + 1).padStart(3, '0')}`,
        qr_data: {
          t: 'd',
          i: deviceId,
          a: `AS-TEST-${String(index + 1).padStart(3, '0')}`,
          m: 'Test Manufacturer',
          n: 'Test Model',
          s: `TEST-${String(index + 1).padStart(6, '0')}`,
          e: 'Test Employee',
          c: 'Test Company',
          g: new Date().toISOString().split('T')[0]
        },
        qr_string: JSON.stringify({
          t: 'd',
          i: deviceId,
          a: `AS-TEST-${String(index + 1).padStart(3, '0')}`,
          m: 'Test Manufacturer',
          n: 'Test Model',
          s: `TEST-${String(index + 1).padStart(6, '0')}`,
          e: 'Test Employee',
          c: 'Test Company',
          g: new Date().toISOString().split('T')[0]
        })
      }));
      
      res.json({
        message: 'Test bulk QR codes generated',
        total_requested: device_ids.length,
        total_generated: mockQRCodes.length,
        qr_codes: mockQRCodes
      });
    } catch (error) {
      console.error('Test bulk QR error:', error);
      res.status(500).json({ error: 'Failed to generate test QR codes' });
    }
  });
}

module.exports = router; 