const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config();

const app = express();
// 2024-12-19: NCP 서버 배포를 위해 포트를 4000으로 변경
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
console.log('🔧 [BACKEND] Setting up routes...')
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/employees', require('./routes/employees'));
app.use('/api/devices', require('./routes/devices'));
app.use('/api/qr', require('./routes/qr'));
console.log('✅ [BACKEND] Routes configured successfully')

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  })
})

// 404 handler (commented out to fix path-to-regexp issue)
// app.all('*', (req, res) => {
//   res.status(404).json({ error: 'Route not found' });
// });

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(PORT, () => {
  console.log('🚀 [BACKEND] Server is running on port', PORT);
  console.log('🌐 [BACKEND] Health check: http://localhost:' + PORT + '/health');
  console.log('🔐 [BACKEND] Auth endpoint: http://localhost:' + PORT + '/api/auth/login');
});

module.exports = app; 