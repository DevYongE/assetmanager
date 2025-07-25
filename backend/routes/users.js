const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get current user's statistics
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    // Get employee count and company name
    const { data: employees, error: empError } = await supabase
      .from('employees')
      .select('id, company_name')
      .eq('admin_id', req.user.id);

    if (empError) {
      console.error('Get employees error:', empError);
      return res.status(500).json({ error: 'Failed to fetch employee stats' });
    }

    const employeeIds = employees?.map(emp => emp.id) || [];
    const companyName = employees?.[0]?.company_name || 'Unknown Company';

    // Get device count
    const { data: devices, error: devError } = await supabase
      .from('personal_devices')
      .select('id')
      .in('employee_id', employeeIds);

    if (devError) {
      console.error('Get devices error:', devError);
      return res.status(500).json({ error: 'Failed to fetch device stats' });
    }

    res.json({
      stats: {
        total_employees: employees?.length || 0,
        total_devices: devices?.length || 0,
        company_name: companyName
      }
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get dashboard data
router.get('/dashboard', authenticateToken, async (req, res) => {
  try {
    // Get recent employees (last 5)
    const { data: recentEmployees, error: empError } = await supabase
      .from('employees')
      .select('id, name, department, position, created_at')
      .eq('admin_id', req.user.id)
      .order('created_at', { ascending: false })
      .limit(5);

    if (empError) {
      console.error('Get recent employees error:', empError);
      return res.status(500).json({ error: 'Failed to fetch recent employees' });
    }

    const employeeIds = await supabase
      .from('employees')
      .select('id')
      .eq('admin_id', req.user.id)
      .then(({ data }) => data?.map(emp => emp.id) || []);

    // Get recent devices (last 5)
    const { data: recentDevices, error: devError } = await supabase
      .from('personal_devices')
      .select(`
        id,
        asset_number,
        manufacturer,
        model_name,
        created_at,
        employees (
          name,
          department
        )
      `)
      .in('employee_id', employeeIds)
      .order('created_at', { ascending: false })
      .limit(5);

    if (devError) {
      console.error('Get recent devices error:', devError);
      return res.status(500).json({ error: 'Failed to fetch recent devices' });
    }

    // Get device distribution by department
    const { data: departmentStats, error: deptError } = await supabase
      .from('employees')
      .select(`
        department,
        personal_devices (
          id
        )
      `)
      .eq('admin_id', req.user.id);

    if (deptError) {
      console.error('Get department stats error:', deptError);
      return res.status(500).json({ error: 'Failed to fetch department stats' });
    }

    // Process department statistics
    const departmentDistribution = departmentStats?.reduce((acc, emp) => {
      const dept = emp.department || 'Unassigned';
      if (!acc[dept]) {
        acc[dept] = { department: dept, device_count: 0, employee_count: 0 };
      }
      acc[dept].employee_count += 1;
      acc[dept].device_count += emp.personal_devices?.length || 0;
      return acc;
    }, {});

    res.json({
      dashboard: {
        recent_employees: recentEmployees || [],
        recent_devices: recentDevices || [],
        department_distribution: Object.values(departmentDistribution || {}),
        summary: {
          total_employees: employeeIds.length,
          total_devices: recentDevices?.length || 0
        }
      }
    });
  } catch (error) {
    console.error('Get dashboard error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router; 