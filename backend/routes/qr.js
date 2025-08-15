const express = require('express');
const QRCode = require('qrcode');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// 2025-08-13: QR 코드 시스템 고도화 - 고급 QR 기능 추가
// - QR 코드 유효성 검증 강화
// - 다중 형식 지원 (PNG, SVG, JSON, PDF)
// - QR 코드 메타데이터 추가
// - 에러 핸들링 개선

// Generate QR code for a specific device - Enhanced version with direct link support
// 2025-01-27: Support both UUID and asset_number identifiers, exclude disposed devices
// 2025-08-13: Enhanced QR generation with advanced validation and multiple formats
// 2025-08-13: Added direct link support for QR codes - scan to navigate to device page
router.get('/device/:identifier', authenticateToken, async (req, res) => {
  try {
    const { identifier } = req.params;
    const { format = 'png', size = 200, includeMetadata = 'true', includeLink = 'true' } = req.query;

    // 2025-08-13: Enhanced input validation
    if (!identifier || identifier.trim() === '') {
      return res.status(400).json({ error: 'Device identifier is required' });
    }

    // Determine if identifier is UUID or asset_number
    const isUUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(identifier);
    
    // Build query based on identifier type
    let query = supabase
      .from('personal_devices')
      .select(`
        id,
        asset_number,
        manufacturer,
        model_name,
        serial_number,
        purpose,
        device_type,
        cpu,
        memory,
        storage,
        os,
        created_at,
        employees (
          id,
          name,
          department,
          position,
          admin_id
        )
      `);

    if (isUUID) {
      query = query.eq('id', identifier);
    } else {
      query = query.eq('asset_number', identifier);
    }

    const { data: device, error } = await query.single();

    if (error || !device) {
      return res.status(404).json({ error: 'Device not found' });
    }

    // 2025-01-27: Exclude disposed devices from QR generation
    if (device.purpose === '폐기') {
      return res.status(400).json({ error: 'QR codes cannot be generated for disposed devices' });
    }

    // Check if device belongs to user's employee
    if (device.employees && device.employees.admin_id !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // 2025-08-13: Enhanced QR code data with direct link support
    const qrData = {
      t: 'd', // type: device (shortened)
      i: device.id, // id (shortened)
      a: device.asset_number, // asset_number (shortened)
      m: device.manufacturer, // manufacturer (shortened)
      n: device.model_name, // model_name (shortened)
      s: device.serial_number, // serial_number (shortened)
      e: device.employees?.name || '', // employee name (shortened)
      c: req.user.company_name, // company (shortened)
      g: new Date().toISOString().split('T')[0], // generated date (shortened, date only)
      // 2025-08-13: Additional metadata for enhanced functionality
      dt: device.device_type || '', // device type
      cpu: device.cpu || '', // CPU info
      mem: device.memory || '', // memory info
      str: device.storage || '', // storage info
      os: device.os || '', // operating system
      ca: device.created_at ? new Date(device.created_at).toISOString().split('T')[0] : '', // created date
      v: '2.0', // QR code version for backward compatibility
      // 2025-08-13: Direct link to device page
      l: includeLink === 'true' ? `${process.env.FRONTEND_URL || 'https://invenOne.it.kr'}/devices/${device.asset_number}` : null // direct link
    };

    // 2025-01-27: Enhanced QR string generation with link type support
    const { linkOnly = 'false' } = req.query;
    const qrString = linkOnly === 'true' 
      ? `${process.env.FRONTEND_URL || 'https://invenOne.it.kr'}/devices/${device.asset_number}` // 링크만 포함
      : JSON.stringify(qrData); // 전체 데이터 포함

    // 2025-08-13: Enhanced format handling with additional options
    if (format === 'json') {
      // Return QR data as JSON with metadata
      const response = { 
        qr_data: linkOnly === 'true' ? {
          type: 'device',
          asset_number: device.asset_number,
          direct_link: `${process.env.FRONTEND_URL || 'https://invenOne.it.kr'}/devices/${device.asset_number}`,
          link_only: true,
          generated_at: new Date().toISOString()
        } : qrData, 
        qr_string: qrString,
        metadata: {
          generated_at: new Date().toISOString(),
          format: 'json',
          device_info: {
            asset_number: device.asset_number,
            manufacturer: device.manufacturer,
            model_name: device.model_name,
            employee: device.employees?.name || '미할당',
            department: device.employees?.department || '',
            purpose: device.purpose
          },
          direct_link: qrData.l, // 2025-08-13: Include direct link in metadata
          link_type: linkOnly === 'true' ? 'link_only' : 'full_data' // 2025-01-27: 링크 타입 정보 추가
        }
      };
      res.json(response);
    } else if (format === 'svg') {
      // Generate SVG QR code with enhanced styling
      const qrSvg = await QRCode.toString(qrString, {
        type: 'svg',
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#1e293b', // Darker color for better contrast
          light: '#ffffff'
        },
        errorCorrectionLevel: 'M' // Medium error correction for better reliability
      });

      res.setHeader('Content-Type', 'image/svg+xml');
      res.setHeader('Content-Disposition', `inline; filename="qr_device_${device.asset_number}.svg"`);
      res.send(qrSvg);
    } else if (format === 'pdf') {
      // 2025-08-13: PDF format support (placeholder for future implementation)
      res.status(501).json({ error: 'PDF format not yet implemented' });
    } else {
      // Generate PNG QR code (default) with enhanced quality
      const qrBuffer = await QRCode.toBuffer(qrString, {
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#1e293b',
          light: '#ffffff'
        },
        errorCorrectionLevel: 'M'
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

// Generate QR code for an employee - Enhanced version
// 2025-08-13: Enhanced employee QR generation with additional features
router.get('/employee/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { format = 'png', size = 200 } = req.query;

    // 2025-08-13: Enhanced input validation
    if (!id || id.trim() === '') {
      return res.status(400).json({ error: 'Employee ID is required' });
    }

    // Verify employee belongs to current user
    const { data: employee, error } = await supabase
      .from('employees')
      .select(`
        id,
        name,
        department,
        position,
        email,
        phone,
        created_at,
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

    // 2025-08-13: Enhanced QR code data with employee metadata
    const qrData = {
      t: 'e', // type: employee (shortened)
      i: employee.id, // id (shortened)
      n: employee.name, // name (shortened)
      d: employee.department, // department (shortened)
      p: employee.position, // position (shortened)
      c: req.user.company_name, // company (shortened)
      g: new Date().toISOString().split('T')[0], // generated date (shortened, date only)
      // 2025-08-13: Additional employee metadata
      e: employee.email || '', // email
      ph: employee.phone || '', // phone
      ca: employee.created_at ? new Date(employee.created_at).toISOString().split('T')[0] : '', // created date
      dc: employee.personal_devices?.length || 0, // device count
      v: '2.0' // QR code version
    };

    const qrString = JSON.stringify(qrData);

    if (format === 'json') {
      // Return QR data as JSON with enhanced metadata
      const response = {
        qr_data: qrData,
        qr_string: qrString,
        metadata: {
          generated_at: new Date().toISOString(),
          format: 'json',
          employee_info: {
            name: employee.name,
            department: employee.department,
            position: employee.position,
            email: employee.email,
            device_count: employee.personal_devices?.length || 0
          }
        }
      };
      res.json(response);
    } else if (format === 'svg') {
      // Generate SVG QR code
      const qrSvg = await QRCode.toString(qrString, {
        type: 'svg',
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#1e293b',
          light: '#ffffff'
        },
        errorCorrectionLevel: 'M'
      });

      res.setHeader('Content-Type', 'image/svg+xml');
      res.setHeader('Content-Disposition', `inline; filename="qr_employee_${employee.name.replace(/\s+/g, '_')}.svg"`);
      res.send(qrSvg);
    } else {
      // Generate PNG QR code (default)
      const qrBuffer = await QRCode.toBuffer(qrString, {
        width: parseInt(size),
        margin: 2,
        color: {
          dark: '#1e293b',
          light: '#ffffff'
        },
        errorCorrectionLevel: 'M'
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

// Bulk generate QR codes for multiple devices - Enhanced version
// 2025-08-13: Enhanced bulk QR generation with improved performance and error handling
// 2025-08-13: Added direct link support for bulk QR generation
router.post('/bulk/devices', authenticateToken, async (req, res) => {
  try {
    const { device_ids, format = 'png', size = 200, includeMetadata = 'true', includeLink = 'true' } = req.body;

    console.log('🔍 [BULK QR] Request received:', { device_ids, format, size, user_id: req.user.id });

    // 2025-08-13: Enhanced input validation
    if (!device_ids || !Array.isArray(device_ids) || device_ids.length === 0) {
      console.log('❌ [BULK QR] Invalid device_ids:', device_ids);
      return res.status(400).json({ error: 'Device IDs array is required' });
    }

    if (device_ids.length > 100) { // 2025-08-13: Increased limit for better performance
      console.log('❌ [BULK QR] Too many devices requested:', device_ids.length);
      return res.status(400).json({ error: 'Maximum 100 devices per bulk request' });
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
        purpose,
        device_type,
        cpu,
        memory,
        storage,
        os,
        created_at,
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

    // 2025-01-27: Filter out disposed devices and devices not belonging to user's employees
    const filteredDevices = devices?.filter(device => 
      userEmployeeIds.includes(device.employee_id) && device.purpose !== '폐기'
    ) || [];

    console.log('🔍 [BULK QR] Filtered devices:', filteredDevices.length);

    if (filteredDevices.length === 0) {
      console.log('❌ [BULK QR] No devices found for user employees');
      return res.status(404).json({ error: 'No devices found for your employees' });
    }

    // 2025-08-13: Enhanced bulk QR generation with better error handling and direct links
    const qrCodes = await Promise.all(
      filteredDevices.map(async (device) => {
        try {
          // Create enhanced QR code data with direct link
          const qrData = {
            t: 'd', // type: device (shortened)
            i: device.id, // id (shortened)
            a: device.asset_number, // asset_number (shortened)
            m: device.manufacturer, // manufacturer (shortened)
            n: device.model_name, // model_name (shortened)
            s: device.serial_number, // serial_number (shortened)
            e: device.employees?.name || '', // employee name (shortened)
            c: req.user.company_name, // company (shortened)
            g: new Date().toISOString().split('T')[0], // generated date (shortened, date only)
            // 2025-08-13: Additional metadata
            dt: device.device_type || '', // device type
            cpu: device.cpu || '', // CPU info
            mem: device.memory || '', // memory info
            str: device.storage || '', // storage info
            os: device.os || '', // operating system
            ca: device.created_at ? new Date(device.created_at).toISOString().split('T')[0] : '', // created date
            v: '2.0', // QR code version
            // 2025-08-13: Direct link to device page
            l: includeLink === 'true' ? `${process.env.FRONTEND_URL || 'http://localhost:3000'}/devices/${device.asset_number}` : null // direct link
          };

          const qrString = JSON.stringify(qrData);

          if (format === 'json') {
            return {
              device_id: device.id,
              asset_number: device.asset_number,
              qr_data: qrData,
              qr_string: qrString,
              metadata: {
                generated_at: new Date().toISOString(),
                employee: device.employees?.name || '미할당',
                department: device.employees?.department || '',
                purpose: device.purpose,
                direct_link: qrData.l // 2025-08-13: Include direct link in metadata
              }
            };
          } else {
            const qrDataUrl = await QRCode.toDataURL(qrString, {
              width: parseInt(size),
              margin: 2,
              color: {
                dark: '#1e293b',
                light: '#ffffff'
              },
              errorCorrectionLevel: 'M'
            });

            return {
              device_id: device.id,
              asset_number: device.asset_number,
              qr_data_url: qrDataUrl,
              metadata: {
                generated_at: new Date().toISOString(),
                employee: device.employees?.name || '미할당',
                department: device.employees?.department || '',
                purpose: device.purpose,
                direct_link: qrData.l // 2025-08-13: Include direct link in metadata
              }
            };
          }
        } catch (qrError) {
          console.error(`QR generation error for device ${device.id}:`, qrError);
          return {
            device_id: device.id,
            asset_number: device.asset_number,
            error: 'Failed to generate QR code',
            error_details: qrError.message
          };
        }
      })
    );

    // 2025-08-13: Enhanced response with detailed statistics
    const successfulQRCodes = qrCodes.filter(qr => !qr.error);
    const failedQRCodes = qrCodes.filter(qr => qr.error);

    res.json({
      message: 'Bulk QR codes generated',
      total_requested: device_ids.length,
      total_generated: successfulQRCodes.length,
      total_failed: failedQRCodes.length,
      success_rate: `${((successfulQRCodes.length / device_ids.length) * 100).toFixed(1)}%`,
      qr_codes: qrCodes,
      summary: {
        successful: successfulQRCodes.length,
        failed: failedQRCodes.length,
        generated_at: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Bulk QR generation error:', error);
    res.status(500).json({ error: 'Failed to generate bulk QR codes' });
  }
});

// Decode QR code data (for verification) - Enhanced version
// 2025-08-13: Enhanced QR decoding with better validation and error handling
router.post('/decode', async (req, res) => {
  try {
    const { qr_string } = req.body;

    // 2025-08-13: Enhanced input validation
    if (!qr_string || typeof qr_string !== 'string' || qr_string.trim() === '') {
      return res.status(400).json({ 
        error: 'QR string is required and must be a non-empty string',
        is_valid: false
      });
    }

    try {
      const qrData = JSON.parse(qr_string);
      
      // 2025-08-13: Enhanced QR data structure validation
      if (!qrData || typeof qrData !== 'object') {
        return res.status(400).json({ 
          error: 'Invalid QR code format - must be valid JSON object',
          is_valid: false
        });
      }

      // Support both simplified and full format with enhanced validation
      let isValid = false;
      let fullFormatData = {};
      let validationErrors = [];

      // 2025-08-13: Enhanced format detection and validation
      if (qrData.t && qrData.i && qrData.g) {
        // Simplified format (new) - Enhanced validation
        isValid = true;
        
        // Validate required fields
        if (!qrData.t || !qrData.i || !qrData.g) {
          validationErrors.push('Missing required fields (t, i, g)');
          isValid = false;
        }

        // Validate type
        if (!['d', 'e'].includes(qrData.t)) {
          validationErrors.push('Invalid type (must be "d" for device or "e" for employee)');
          isValid = false;
        }

        // Validate date format
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (!dateRegex.test(qrData.g)) {
          validationErrors.push('Invalid date format (must be YYYY-MM-DD)');
          isValid = false;
        }

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
          generated_at: qrData.g,
          // 2025-08-13: Additional metadata
          device_type: qrData.dt || '',
          cpu: qrData.cpu || '',
          memory: qrData.mem || '',
          storage: qrData.str || '',
          os: qrData.os || '',
          created_at: qrData.ca || '',
          version: qrData.v || '1.0'
        };
      }
      // Check for full format (legacy)
      else if (qrData.type && qrData.id) {
        isValid = true;
        fullFormatData = qrData;
      }
      // Invalid format
      else {
        validationErrors.push('Invalid QR code format - missing required fields');
        isValid = false;
      }

      if (!isValid) {
        return res.status(400).json({ 
          error: 'Invalid QR code format',
          validation_errors: validationErrors,
          is_valid: false
        });
      }

      // 2025-08-13: Enhanced response with validation details
      res.json({
        message: 'QR code decoded successfully',
        data: fullFormatData,
        is_valid: true,
        format: qrData.t ? 'simplified' : 'legacy',
        version: qrData.v || '1.0',
        decoded_at: new Date().toISOString()
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

// 2025-08-13: New endpoint for QR code validation
router.post('/validate', async (req, res) => {
  try {
    const { qr_string } = req.body;

    if (!qr_string || typeof qr_string !== 'string') {
      return res.status(400).json({ 
        is_valid: false,
        error: 'QR string is required'
      });
    }

    try {
      const qrData = JSON.parse(qr_string);
      
      // Basic validation
      const isValid = !!(qrData.t && qrData.i && qrData.g);
      
      // 2025-08-13: Enhanced validation with link support
      const hasLink = !!(qrData.l || qrData.link);
      const linkType = hasLink ? (qrData.l ? 'direct' : 'legacy') : 'none';
      
      res.json({
        is_valid: isValid,
        format: qrData.t ? 'simplified' : 'legacy',
        version: qrData.v || '1.0',
        type: qrData.t || qrData.type || 'unknown',
        has_link: hasLink,
        link_type: linkType,
        direct_link: qrData.l || qrData.link || null
      });
    } catch {
      res.json({
        is_valid: false,
        error: 'Invalid JSON format'
      });
    }
  } catch (error) {
    console.error('QR validation error:', error);
    res.status(500).json({ 
      is_valid: false,
      error: 'Validation failed'
    });
  }
});

// Test endpoint for bulk QR generation (development only)
if (process.env.NODE_ENV === 'development') {
  router.post('/bulk/test', async (req, res) => {
    try {
      const { device_ids, format = 'json' } = req.body;
      
      console.log('🔍 [BULK QR TEST] Test request:', { device_ids, format });
      
      // 2025-08-13: Enhanced mock QR codes for testing
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
          g: new Date().toISOString().split('T')[0],
          dt: 'Laptop',
          cpu: 'Intel i7',
          mem: '16GB',
          str: '512GB SSD',
          os: 'Windows 11',
          ca: new Date().toISOString().split('T')[0],
          v: '2.0',
          l: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/devices/AS-TEST-${String(index + 1).padStart(3, '0')}` // 2025-08-13: Direct link for testing
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
          g: new Date().toISOString().split('T')[0],
          dt: 'Laptop',
          cpu: 'Intel i7',
          mem: '16GB',
          str: '512GB SSD',
          os: 'Windows 11',
          ca: new Date().toISOString().split('T')[0],
          v: '2.0',
          l: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/devices/AS-TEST-${String(index + 1).padStart(3, '0')}` // 2025-08-13: Direct link for testing
        }),
        metadata: {
          generated_at: new Date().toISOString(),
          employee: 'Test Employee',
          department: 'IT',
          purpose: '업무용',
          direct_link: `${process.env.FRONTEND_URL || 'http://localhost:3000'}/devices/AS-TEST-${String(index + 1).padStart(3, '0')}` // 2025-08-13: Direct link in metadata
        }
      }));
      
      res.json({
        message: 'Test bulk QR codes generated',
        total_requested: device_ids.length,
        total_generated: mockQRCodes.length,
        success_rate: '100%',
        qr_codes: mockQRCodes,
        summary: {
          successful: mockQRCodes.length,
          failed: 0,
          generated_at: new Date().toISOString()
        }
      });
    } catch (error) {
      console.error('Test bulk QR error:', error);
      res.status(500).json({ error: 'Failed to generate test QR codes' });
    }
  });
}

module.exports = router; 