const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { supabase } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Register new user
router.post('/register', async (req, res) => {
  try {
    const { email, password, company_name } = req.body;

    if (!email || !password || !company_name) {
      return res.status(400).json({ error: 'Email, password, and company name are required' });
    }

    // Check if user already exists
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('email', email)
      .single();

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // Create user
    const { data: user, error } = await supabase
      .from('users')
      .insert([{ email, password_hash }])
      .select('id, email')
      .single();

    if (error) {
      console.error('Registration error:', error);
      return res.status(500).json({ error: 'Failed to create user' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      message: 'User created successfully',
      user: {
        id: user.id,
        email: user.email,
        company_name: company_name
      },
      token
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Login user
router.post('/login', async (req, res) => {
  try {
    console.log('🔍 [BACKEND] Login request received')
    console.log('📧 Request body:', req.body)
    
    const { email, password } = req.body;

    if (!email || !password) {
      console.log('❌ [BACKEND] Missing email or password')
      return res.status(400).json({ error: 'Email and password are required' });
    }

    console.log('🔍 [BACKEND] Looking for user with email:', email)

    // Find user
    const { data: user, error } = await supabase
      .from('users')
      .select('id, email, password_hash')
      .eq('email', email)
      .single();

    console.log('📊 [BACKEND] Supabase query result:')
    console.log('👤 User found:', user ? 'Yes' : 'No')
    console.log('🚨 Supabase error:', error)

    if (error || !user) {
      console.log('❌ [BACKEND] User not found or database error')
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    console.log('✅ [BACKEND] User found, verifying password...')

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    console.log('🔐 [BACKEND] Password valid:', isPasswordValid)
    
    if (!isPasswordValid) {
      console.log('❌ [BACKEND] Invalid password')
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    console.log('✅ [BACKEND] Password verified, generating token...')

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    console.log('🎫 [BACKEND] Token generated successfully')
    console.log('👤 [BACKEND] Sending response for user:', user.email)

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email
      },
      token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get current user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    res.json({
      user: {
        id: req.user.id,
        email: req.user.email,
        company_name: req.user.company_name
      }
    });
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update user profile
router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const { company_name, current_password, new_password } = req.body;
    const updates = {};

    if (company_name) {
      updates.company_name = company_name;
    }

    if (new_password) {
      if (!current_password) {
        return res.status(400).json({ error: 'Current password required to change password' });
      }

      // Verify current password
      const { data: user, error } = await supabase
        .from('users')
        .select('password_hash')
        .eq('id', req.user.id)
        .single();

      if (error) {
        return res.status(500).json({ error: 'Failed to verify current password' });
      }

      const isCurrentPasswordValid = await bcrypt.compare(current_password, user.password_hash);
      if (!isCurrentPasswordValid) {
        return res.status(400).json({ error: 'Current password is incorrect' });
      }

      // Hash new password
      const saltRounds = 10;
      updates.password_hash = await bcrypt.hash(new_password, saltRounds);
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No updates provided' });
    }

    // Update user
    const { data: updatedUser, error: updateError } = await supabase
      .from('users')
      .update(updates)
      .eq('id', req.user.id)
      .select('id, email, company_name')
      .single();

    if (updateError) {
      console.error('Profile update error:', updateError);
      return res.status(500).json({ error: 'Failed to update profile' });
    }

    res.json({
      message: 'Profile updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router; 