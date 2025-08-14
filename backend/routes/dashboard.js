const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// 대시보드 통계 조회
router.get('/stats', authenticateToken, async (req, res) => {
  try {
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
    
    // 장비 통계 조회
    let devicesQuery = supabase
      .from('personal_devices')
      .select('id, employee_id, purpose, created_at');
    
    if (!isAdmin) {
      // Manager can only see their own devices
      devicesQuery = devicesQuery.eq('admin_id', req.user.id);
    }
    
    const { data: devices, error: devicesError } = await devicesQuery;
    
    if (devicesError) {
      console.error('Devices query error:', devicesError);
      return res.status(500).json({ error: 'Failed to fetch devices' });
    }
    
    // 직원 통계 조회
    let employeesQuery = supabase
      .from('employees')
      .select('id, created_at');
    
    if (!isAdmin) {
      // Manager can only see their own employees
      employeesQuery = employeesQuery.eq('admin_id', req.user.id);
    }
    
    const { data: employees, error: employeesError } = await employeesQuery;
    
    if (employeesError) {
      console.error('Employees query error:', employeesError);
      return res.status(500).json({ error: 'Failed to fetch employees' });
    }
    
    // 통계 계산
    const totalDevices = devices?.length || 0;
    const totalEmployees = employees?.length || 0;
    const activeDevices = devices?.filter(d => d.employee_id).length || 0;
    const inactiveDevices = devices?.filter(d => !d.employee_id && d.purpose !== '폐기').length || 0;
    const retiredDevices = devices?.filter(d => d.purpose === '폐기').length || 0;
    const maintenanceDevices = 0; // 현재 정비 상태 필드가 없음
    
    // 최근 7일간 추가된 장비 수
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const recentDevices = devices?.filter(d => 
      new Date(d.created_at) >= sevenDaysAgo
    ).length || 0;
    
    // 최근 7일간 추가된 직원 수
    const recentEmployees = employees?.filter(e => 
      new Date(e.created_at) >= sevenDaysAgo
    ).length || 0;
    
    res.json({
      stats: {
        total_devices: totalDevices,
        total_employees: totalEmployees,
        active_devices: activeDevices,
        inactive_devices: inactiveDevices,
        maintenance_devices: maintenanceDevices,
        retired_devices: retiredDevices,
        recent_devices: recentDevices,
        recent_employees: recentEmployees
      }
    });
    
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 최근 활동 조회 (장비 히스토리 기반)
router.get('/recent-activities', authenticateToken, async (req, res) => {
  try {
    // 2025-01-27: Check user permissions
    const { data: permissions, error: permError } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: 'devices',
        p_resource_id: null,
        p_action: 'read'
      });
    
    if (permError) {
      console.error('Permission check error:', permError);
      return res.status(500).json({ error: 'Failed to check user permissions' });
    }
    
    const hasReadPermission = permissions;
    
    // 장비 히스토리 조회
    let historyQuery = supabase
      .from('device_history')
      .select(`
        id,
        action_type,
        action_description,
        performed_at,
        device_id
      `)
      .order('performed_at', { ascending: false })
      .limit(10);
    
    if (!hasReadPermission) {
      // 권한이 없으면 빈 배열 반환
      return res.json({ activities: [] });
    }
    
    const { data: history, error: historyError } = await historyQuery;
    
    if (historyError) {
      console.error('History query error:', historyError);
      return res.status(500).json({ error: 'Failed to fetch history' });
    }
    
    // 활동 데이터 변환
    const activities = history?.map(item => ({
      id: item.id,
      type: 'device',
      title: item.action_type,
      description: item.action_description,
      createdAt: item.performed_at,
      device: { asset_number: `장비 ID: ${item.device_id?.slice(0, 8)}...` }
    })) || [];
    
    res.json({ activities });
    
  } catch (error) {
    console.error('Recent activities error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
