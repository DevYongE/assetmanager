const express = require('express');
const QRCode = require('qrcode');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Generate QR code for a specific device
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

    // Create QR code data with device information
    const qrData = {
      type: 'device',
      id: device.id,
      asset_number: device.asset_number,
      manufacturer: device.manufacturer,
      model_name: device.model_name,
      serial_number: device.serial_number,
      employee: {
        name: device.employees.name,
        department: device.employees.department,
        position: device.employees.position
      },
      company: req.user.company_name,
      generated_at: new Date().toISOString()
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

// Generate QR code for an employee (all their devices)
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

    // Create QR code data with employee and devices information
    const qrData = {
      type: 'employee',
      id: employee.id,
      name: employee.name,
      department: employee.department,
      position: employee.position,
      devices: employee.personal_devices || [],
      company: req.user.company_name,
      generated_at: new Date().toISOString()
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

// Bulk generate QR codes for multiple devices
router.post('/bulk/devices', authenticateToken, async (req, res) => {
  try {
    const { device_ids, format = 'png', size = 200 } = req.body;

    if (!device_ids || !Array.isArray(device_ids) || device_ids.length === 0) {
      return res.status(400).json({ error: 'Device IDs array is required' });
    }

    if (device_ids.length > 50) {
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
        employees (
          id,
          name,
          department,
          position,
          admin_id
        )
      `)
      .in('id', device_ids)
      .in('employee_id', 
        await supabase
          .from('employees')
          .select('id')
          .eq('admin_id', req.user.id)
          .then(({ data }) => data?.map(emp => emp.id) || [])
      );

    if (error) {
      console.error('Bulk QR fetch error:', error);
      return res.status(500).json({ error: 'Failed to fetch devices' });
    }

    const qrCodes = await Promise.all(
      devices.map(async (device) => {
        try {
          const qrData = {
            type: 'device',
            id: device.id,
            asset_number: device.asset_number,
            manufacturer: device.manufacturer,
            model_name: device.model_name,
            serial_number: device.serial_number,
            employee: {
              name: device.employees.name,
              department: device.employees.department,
              position: device.employees.position
            },
            company: req.user.company_name,
            generated_at: new Date().toISOString()
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

// Decode QR code data (for verification)
router.post('/decode', async (req, res) => {
  try {
    const { qr_string } = req.body;

    if (!qr_string) {
      return res.status(400).json({ error: 'QR string is required' });
    }

    try {
      const qrData = JSON.parse(qr_string);
      
      // Basic validation
      if (!qrData.type || !qrData.id || !qrData.generated_at) {
        return res.status(400).json({ error: 'Invalid QR code format' });
      }

      res.json({
        message: 'QR code decoded successfully',
        data: qrData,
        is_valid: true
      });
    } catch (parseError) {
      res.status(400).json({ 
        error: 'Invalid QR code format',
        is_valid: false
      });
    }
  } catch (error) {
    console.error('QR decode error:', error);
    res.status(500).json({ error: 'Failed to decode QR code' });
  }
});

module.exports = router; 