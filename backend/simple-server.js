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
    password_hash: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // 'dragon12'
    company_name: 'Test Company'
  }
];

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    message: 'Simple server is running!'
  });
});

// Login endpoint
app.post('/api/auth/login', async (req, res) => {
  try {
    console.log('🔍 [SIMPLE SERVER] Login request received');
    console.log('📧 Request body:', req.body);
    
    const { email, password } = req.body;

    if (!email || !password) {
      console.log('❌ [SIMPLE SERVER] Missing email or password');
      return res.status(400).json({ error: 'Email and password are required' });
    }

    console.log('🔍 [SIMPLE SERVER] Looking for user with email:', email);

    // Find user (case-insensitive email comparison)
    const user = users.find(u => u.email.toLowerCase() === email.toLowerCase());

    if (!user) {
      console.log('❌ [SIMPLE SERVER] User not found');
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    console.log('✅ [SIMPLE SERVER] User found, verifying password...');

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    console.log('🔐 [SIMPLE SERVER] Password valid:', isPasswordValid);
    
    if (!isPasswordValid) {
      console.log('❌ [SIMPLE SERVER] Invalid password');
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    console.log('✅ [SIMPLE SERVER] Password verified, generating token...');

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      'your-secret-key',
      { expiresIn: '24h' }
    );

    console.log('🎫 [SIMPLE SERVER] Token generated successfully');
    console.log('👤 [SIMPLE SERVER] Sending response for user:', user.email);

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
    console.error('❌ [SIMPLE SERVER] Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Register endpoint
app.post('/api/auth/register', async (req, res) => {
  try {
    console.log('🔍 [SIMPLE SERVER] Register request received');
    console.log('📧 Request body:', req.body);
    
    const { email, password, company_name } = req.body;

    if (!email || !password || !company_name) {
      console.log('❌ [SIMPLE SERVER] Missing required fields');
      return res.status(400).json({ error: 'Email, password, and company_name are required' });
    }

    // Check if user already exists
    const existingUser = users.find(u => u.email.toLowerCase() === email.toLowerCase());
    if (existingUser) {
      console.log('❌ [SIMPLE SERVER] User already exists');
      return res.status(400).json({ error: 'User already exists' });
    }

    console.log('✅ [SIMPLE SERVER] Creating new user...');

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Create new user
    const newUser = {
      id: (users.length + 1).toString(),
      email,
      password_hash,
      company_name
    };

    users.push(newUser);

    // Generate JWT token
    const token = jwt.sign(
      { userId: newUser.id, email: newUser.email },
      'your-secret-key',
      { expiresIn: '24h' }
    );

    console.log('✅ [SIMPLE SERVER] User created successfully');

    res.status(201).json({
      message: 'User created successfully',
      user: {
        id: newUser.id,
        email: newUser.email,
        company_name: newUser.company_name
      },
      token
    });
  } catch (error) {
    console.error('❌ [SIMPLE SERVER] Registration error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log('🚀 [SIMPLE SERVER] Server is running on port', PORT);
  console.log('🌐 [SIMPLE SERVER] Health check: http://localhost:' + PORT + '/health');
  console.log('🔐 [SIMPLE SERVER] Auth endpoint: http://localhost:' + PORT + '/api/auth/login');
  console.log('👤 [SIMPLE SERVER] Test user: devXcdy@gmail.com / dragon12');
}); 