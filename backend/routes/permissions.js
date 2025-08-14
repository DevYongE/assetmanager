const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all permissions (admin only)
router.get('/', authenticateToken, async (req, res) => {
  try {
    // Check if user has admin permission for users
    const { data: hasAdminPermission, error: permError } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: 'users',
        p_resource_id: null,
        p_action: 'admin'
      });
    
    if (permError) {
      console.error('Permission check error:', permError);
      return res.status(500).json({ error: 'Failed to check user permissions' });
    }
    
    if (!hasAdminPermission) {
      return res.status(403).json({ error: 'Access denied. Admin only.' });
    }

    const { data: permissions, error } = await supabase
      .from('permissions')
      .select(`
        *,
        users (
          id,
          email
        )
      `)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Get permissions error:', error);
      return res.status(500).json({ error: 'Failed to fetch permissions' });
    }

    res.json({ permissions });
  } catch (error) {
    console.error('Get permissions error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Grant permission to user
router.post('/grant', authenticateToken, async (req, res) => {
  try {
    const { user_id, resource_type, resource_id, action } = req.body;

    // Check if user has admin permission for users
    const { data: hasAdminPermission, error: permError } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: 'users',
        p_resource_id: null,
        p_action: 'admin'
      });
    
    if (permError) {
      console.error('Permission check error:', permError);
      return res.status(500).json({ error: 'Failed to check user permissions' });
    }
    
    if (!hasAdminPermission) {
      return res.status(403).json({ error: 'Access denied. Admin only.' });
    }

    // Validate input
    if (!user_id || !resource_type || !action) {
      return res.status(400).json({ error: 'user_id, resource_type, and action are required' });
    }

    // Grant permission using the function
    const { error } = await supabase
      .rpc('grant_permission', {
        p_user_id: user_id,
        p_resource_type: resource_type,
        p_resource_id: resource_id || null,
        p_action: action
      });

    if (error) {
      console.error('Grant permission error:', error);
      return res.status(500).json({ error: 'Failed to grant permission' });
    }

    res.json({ message: 'Permission granted successfully' });
  } catch (error) {
    console.error('Grant permission error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Revoke permission from user
router.post('/revoke', authenticateToken, async (req, res) => {
  try {
    const { user_id, resource_type, resource_id, action } = req.body;

    // Check if user has admin permission for users
    const { data: hasAdminPermission, error: permError } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: 'users',
        p_resource_id: null,
        p_action: 'admin'
      });
    
    if (permError) {
      console.error('Permission check error:', permError);
      return res.status(500).json({ error: 'Failed to check user permissions' });
    }
    
    if (!hasAdminPermission) {
      return res.status(403).json({ error: 'Access denied. Admin only.' });
    }

    // Validate input
    if (!user_id || !resource_type || !action) {
      return res.status(400).json({ error: 'user_id, resource_type, and action are required' });
    }

    // Revoke permission using the function
    const { error } = await supabase
      .rpc('revoke_permission', {
        p_user_id: user_id,
        p_resource_type: resource_type,
        p_resource_id: resource_id || null,
        p_action: action
      });

    if (error) {
      console.error('Revoke permission error:', error);
      return res.status(500).json({ error: 'Failed to revoke permission' });
    }

    res.json({ message: 'Permission revoked successfully' });
  } catch (error) {
    console.error('Revoke permission error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's own permissions
router.get('/my-permissions', authenticateToken, async (req, res) => {
  try {
    const { data: permissions, error } = await supabase
      .from('permissions')
      .select('*')
      .eq('user_id', req.user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Get my permissions error:', error);
      return res.status(500).json({ error: 'Failed to fetch permissions' });
    }

    res.json({ permissions });
  } catch (error) {
    console.error('Get my permissions error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Check specific permission
router.post('/check', authenticateToken, async (req, res) => {
  try {
    const { resource_type, resource_id, action } = req.body;

    // Validate input
    if (!resource_type || !action) {
      return res.status(400).json({ error: 'resource_type and action are required' });
    }

    const { data: hasPermission, error } = await supabase
      .rpc('check_user_permission', {
        p_user_id: req.user.id,
        p_resource_type: resource_type,
        p_resource_id: resource_id || null,
        p_action: action
      });

    if (error) {
      console.error('Check permission error:', error);
      return res.status(500).json({ error: 'Failed to check permission' });
    }

    res.json({ hasPermission });
  } catch (error) {
    console.error('Check permission error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
