const express = require('express');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get current user profile with role
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const { data: user, error } = await supabase
      .from('users')
      .select('id, email, role, created_at')
      .eq('id', req.user.id)
      .single();

    if (error || !user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user profile (only email for now)
router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    const { data: user, error } = await supabase
      .from('users')
      .update({ email })
      .eq('id', req.user.id)
      .select('id, email, role, created_at')
      .single();

    if (error) {
      console.error('Update user profile error:', error);
      return res.status(500).json({ error: 'Failed to update profile' });
    }

    res.json({ user });
  } catch (error) {
    console.error('Update user profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2025-01-27: Admin only - Get all users (for admin management)
router.get('/', authenticateToken, async (req, res) => {
  try {
    // Check if user is admin
    const { data: currentUser, error: userError } = await supabase
      .from('users')
      .select('role')
      .eq('id', req.user.id)
      .single();
    
    if (userError || !currentUser) {
      return res.status(500).json({ error: 'Failed to get user information' });
    }
    
    if (currentUser.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied. Admin only.' });
    }

    const { data: users, error } = await supabase
      .from('users')
      .select('id, email, role, created_at')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Get users error:', error);
      return res.status(500).json({ error: 'Failed to fetch users' });
    }

    res.json({ users });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2025-01-27: Admin only - Update user role
router.put('/:id/role', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;

    // Check if user is admin
    const { data: currentUser, error: userError } = await supabase
      .from('users')
      .select('role')
      .eq('id', req.user.id)
      .single();
    
    if (userError || !currentUser) {
      return res.status(500).json({ error: 'Failed to get user information' });
    }
    
    if (currentUser.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied. Admin only.' });
    }

    // Validate role
    if (!role || !['admin', 'manager'].includes(role)) {
      return res.status(400).json({ error: 'Invalid role. Must be "admin" or "manager".' });
    }

    // Prevent admin from changing their own role to manager (at least one admin must remain)
    if (id === req.user.id && role === 'manager') {
      return res.status(400).json({ error: 'Cannot change your own role to manager. At least one admin must remain.' });
    }

    const { data: user, error } = await supabase
      .from('users')
      .update({ role })
      .eq('id', id)
      .select('id, email, role, created_at')
      .single();

    if (error) {
      console.error('Update user role error:', error);
      return res.status(500).json({ error: 'Failed to update user role' });
    }

    res.json({ user });
  } catch (error) {
    console.error('Update user role error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router; 