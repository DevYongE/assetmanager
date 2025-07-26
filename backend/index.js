const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const https = require('https');
const fs = require('fs');

// Load environment variables
dotenv.config();

const app = express();
// 2025-01-27: HTTPS 서버로 변경하여 443 포트 직접 처리
const PORT = process.env.PORT || 443;

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

// 2025-01-27: HTTPS 서버 설정
const options = {
  key: fs.readFileSync('/home/dmanager/assetmanager/localhost.key'),
  cert: fs.readFileSync('/home/dmanager/assetmanager/localhost.crt')
};

// HTTPS 서버 생성 및 실행
https.createServer(options, app).listen(PORT, '0.0.0.0', () => {
  console.log('🚀 [BACKEND] HTTPS Server is running on port', PORT);
  console.log('🌐 [BACKEND] Health check: https://0.0.0.0:' + PORT + '/health');
  console.log('🔐 [BACKEND] Auth endpoint: https://0.0.0.0:' + PORT + '/api/auth/login');
  console.log('🔒 [BACKEND] SSL Certificate loaded successfully');
});

module.exports = app; 