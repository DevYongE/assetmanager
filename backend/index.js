const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config();

const app = express();
// 2024-12-19: NCP 서버 배포를 위해 포트를 4000으로 변경
const PORT = process.env.PORT || 4000;

// 2025-07-25: CORS 설정 수정 - 모바일 접속을 위해 모든 도메인 허용
const corsOptions = {
  origin: true, // 모든 도메인 허용
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Origin', 'Accept']
};

// Middleware
app.use(cors(corsOptions));
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

app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 [BACKEND] Server is running on port', PORT);
  console.log('🌐 [BACKEND] Health check: http://0.0.0.0:' + PORT + '/health');
  console.log('🔐 [BACKEND] Auth endpoint: http://0.0.0.0:' + PORT + '/api/auth/login');
});

module.exports = app; 