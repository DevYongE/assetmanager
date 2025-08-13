const express = require('express');
const { supabase, supabaseAdmin } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all employees for the authenticated user's company
router.get('/', authenticateToken, async (req, res) => {
  try {
    // 2025-01-27: 장비 개수를 포함한 직원 목록 조회 (2025-08-13: inner join을 left join으로 수정하여 장비가 없는 직원도 표시)
    // 2025-08-13: 먼저 직원 데이터만 가져오고, 장비 개수는 별도로 계산
    console.log('🔍 [BACKEND] Fetching employees for admin_id:', req.user.id);
    
    // 2025-08-13: RLS 정책이 제대로 작동하도록 일반 supabase 클라이언트 사용
    // 2025-08-13: admin_id로 직접 필터링하여 보안 유지
    const { data: employees, error } = await supabase
      .from('employees')
      .select('*')
      .eq('admin_id', req.user.id)
      .order('created_at', { ascending: false });
    
    console.log('📝 [BACKEND] Supabase response:', { data: employees, error });

    if (error) {
      console.error('Get employees error:', error);
      return res.status(500).json({ error: 'Failed to fetch employees' });
    }

    // 2025-01-27: 장비 개수 계산 및 응답 데이터 구성 (2025-08-13: 별도 쿼리로 장비 개수 계산)
    console.log('🔍 [BACKEND] Calculating device counts for', employees.length, 'employees');
    const employeesWithDeviceCount = await Promise.all(
      employees.map(async (employee) => {
        // 2025-08-13: RLS 정책이 제대로 작동하도록 일반 supabase 클라이언트 사용
        const { count, error: countError } = await supabase
          .from('personal_devices')
          .select('*', { count: 'exact', head: true })
          .eq('employee_id', employee.id);
        
        const deviceCount = countError ? 0 : (count || 0);
        console.log(`📝 [BACKEND] Employee ${employee.name} has ${deviceCount} devices`);
        
        return {
          ...employee,
          device_count: deviceCount
        };
      })
    );
    
    console.log('📝 [BACKEND] Final response data:', employeesWithDeviceCount);

    res.json({ employees: employeesWithDeviceCount });
  } catch (error) {
    console.error('Get employees error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single employee by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const { data: employee, error } = await supabase
      .from('employees')
      .select('*')
      .eq('id', id)
      .eq('admin_id', req.user.id)
      .single();

    if (error || !employee) {
      return res.status(404).json({ error: 'Employee not found' });
    }

    res.json({ employee });
  } catch (error) {
    console.error('Get employee error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create new employee
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { department, position, name, company_name, email } = req.body;

    // 2025-01-27: 디버깅 로그 추가
    console.log('🔍 [EMPLOYEES] Creating employee with data:', {
      department,
      position,
      name,
      company_name,
      email,
      admin_id: req.user.id
    });

    // 2025-01-27: 이메일 필드 추가
    if (!department || !position || !name || !company_name) {
      return res.status(400).json({ error: 'Department, position, name, and company_name are required' });
    }

    const employeeData = {
      admin_id: req.user.id,
      department,
      position,
      name,
      company_name,
      email: email || null // 2025-01-27: 이메일 필드 추가 (선택사항)
    };

    console.log('📝 [EMPLOYEES] Inserting employee data:', employeeData);

    const { data: employee, error } = await supabaseAdmin
      .from('employees')
      .insert([employeeData])
      .select('*')
      .single();

    console.log('🔍 [EMPLOYEES] Supabase response:', { data: employee, error });

    if (error) {
      console.error('Create employee error:', error);
      return res.status(500).json({ error: 'Failed to create employee' });
    }

    console.log('✅ [EMPLOYEES] Employee created successfully:', employee);

    res.status(201).json({
      message: 'Employee created successfully',
      employee
    });
  } catch (error) {
    console.error('Create employee error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update employee
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { department, position, name, company_name, email } = req.body;

    // Verify employee belongs to current user
    const { data: existingEmployee, error: checkError } = await supabase
      .from('employees')
      .select('id')
      .eq('id', id)
      .eq('admin_id', req.user.id)
      .single();

    if (checkError || !existingEmployee) {
      return res.status(404).json({ error: 'Employee not found' });
    }

    const updates = {};
    if (department) updates.department = department;
    if (position) updates.position = position;
    if (name) updates.name = name;
    if (company_name) updates.company_name = company_name;
    // 2025-01-27: 이메일 필드 업데이트 추가
    if (email !== undefined) updates.email = email;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No updates provided' });
    }

    const { data: employee, error } = await supabase
      .from('employees')
      .update(updates)
      .eq('id', id)
      .eq('admin_id', req.user.id)
      .select('*')
      .single();

    if (error) {
      console.error('Update employee error:', error);
      return res.status(500).json({ error: 'Failed to update employee' });
    }

    res.json({
      message: 'Employee updated successfully',
      employee
    });
  } catch (error) {
    console.error('Update employee error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete employee
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if employee has associated devices
    const { data: devices, error: deviceError } = await supabase
      .from('personal_devices')
      .select('id')
      .eq('employee_id', id);

    if (deviceError) {
      console.error('Check devices error:', deviceError);
      return res.status(500).json({ error: 'Failed to check associated devices' });
    }

    if (devices && devices.length > 0) {
      return res.status(400).json({ 
        error: 'Cannot delete employee with associated devices. Please reassign or delete devices first.' 
      });
    }

    // Delete employee
    const { error } = await supabase
      .from('employees')
      .delete()
      .eq('id', id)
      .eq('admin_id', req.user.id);

    if (error) {
      console.error('Delete employee error:', error);
      return res.status(500).json({ error: 'Failed to delete employee' });
    }

    res.json({ message: 'Employee deleted successfully' });
  } catch (error) {
    console.error('Delete employee error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router; 