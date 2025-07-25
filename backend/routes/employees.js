const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all employees for the authenticated user's company
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { data: employees, error } = await supabase
      .from('employees')
      .select('*')
      .eq('admin_id', req.user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Get employees error:', error);
      return res.status(500).json({ error: 'Failed to fetch employees' });
    }

    res.json({ employees });
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
    const { department, position, name, company_name } = req.body;

    if (!department || !position || !name || !company_name) {
      return res.status(400).json({ error: 'Department, position, name, and company_name are required' });
    }

    const { data: employee, error } = await supabase
      .from('employees')
      .insert([{
        admin_id: req.user.id,
        department,
        position,
        name,
        company_name
      }])
      .select('*')
      .single();

    if (error) {
      console.error('Create employee error:', error);
      return res.status(500).json({ error: 'Failed to create employee' });
    }

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
    const { department, position, name, company_name } = req.body;

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