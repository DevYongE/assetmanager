const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory user storage for testing
const users = [
  {
    id: '1',
    email: 'devXcdy@gmail.com',
    password_hash: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // 'password'
    company_name: 'Test Company'
  }
];

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
  try {
    console.log('🔍 [TEST SERVER] Login request received');
    console.log('📧 Request body:', req.body);
    
    const { email, password } = req.body;

    if (!email || !password) {
      console.log('❌ [TEST SERVER] Missing email or password');
      return res.status(400).json({ error: 'Email and password are required' });
    }

    console.log('🔍 [TEST SERVER] Looking for user with email:', email);

    // Find user (case-insensitive email comparison)
    const user = users.find(u => u.email.toLowerCase() === email.toLowerCase());

    if (!user) {
      console.log('❌ [TEST SERVER] User not found');
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    console.log('✅ [TEST SERVER] User found, verifying password...');

    // Verify password (using 'dragon12' for testing)
    const isPasswordValid = password === 'dragon12';
    console.log('🔐 [TEST SERVER] Password valid:', isPasswordValid);
    
    if (!isPasswordValid) {
      console.log('❌ [TEST SERVER] Invalid password');
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    console.log('✅ [TEST SERVER] Password verified, generating token...');

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      'test-secret-key',
      { expiresIn: '24h' }
    );

    console.log('🎫 [TEST SERVER] Token generated successfully');
    console.log('👤 [TEST SERVER] Sending response for user:', user.email);

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        company_name: user.company_name
      },
      token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(PORT, () => {
  console.log('🚀 [TEST SERVER] Server is running on port', PORT);
  console.log('🌐 [TEST SERVER] Health check: http://localhost:' + PORT + '/health');
  console.log('🔐 [TEST SERVER] Auth endpoint: http://localhost:' + PORT + '/api/auth/login');
  console.log('👤 [TEST SERVER] Test user: devXcdy@gmail.com / dragon12');
}); 