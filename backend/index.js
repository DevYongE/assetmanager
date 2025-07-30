// =============================================================================
// QR 자산관리 시스템 백엔드 서버
// =============================================================================
//
// 이 파일은 Express.js 기반의 백엔드 API 서버입니다.
// 사용자 인증, QR 코드 생성/스캔, 자산 관리 등의 API를 제공합니다.
//
// 주요 기능:
// - 사용자 인증 (로그인/로그아웃)
// - QR 코드 생성 및 스캔
// - 자산 정보 관리
// - CORS 설정
// - HTTPS 지원
//
// 작성일: 2024-12-19
// =============================================================================

// =============================================================================
// 환경 변수 설정
// =============================================================================
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const https = require('https');
const fs = require('fs');
const path = require('path');

// 라우터 모듈들
const authRoutes = require('./routes/auth');
const usersRoutes = require('./routes/users');
const employeesRoutes = require('./routes/employees');
const devicesRoutes = require('./routes/devices');
const qrRoutes = require('./routes/qr');

const app = express();

// =============================================================================
// 미들웨어 설정
// =============================================================================

// JSON 파싱 미들웨어
app.use(express.json());

// URL 인코딩 파싱 미들웨어
app.use(express.urlencoded({ extended: true }));

// =============================================================================
// CORS 설정
// =============================================================================
// 2024-12-19: CORS 설정 수정 - 모든 도메인 허용 및 특정 도메인 추가
const corsOptions = {
  origin: [
    'http://localhost:3000',
    'http://localhost:3002',
    'http://211.188.55.145:3000',
    'http://211.188.55.145:3002',
    'http://your-ncp-server-ip:3000',  // NCP 서버 IP로 변경 필요
    'http://your-ncp-server-ip:3002',   // NCP 서버 IP로 변경 필요
    'https://invenone.it.kr',
    'https://www.invenone.it.kr',
    'http://invenone.it.kr',
    'http://www.invenone.it.kr'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Origin', 'Accept']
};

// CORS 미들웨어 적용
app.use(cors(corsOptions));

// =============================================================================
// 라우터 설정
// =============================================================================

// API 라우터들
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/employees', employeesRoutes);
app.use('/api/devices', devicesRoutes);
app.use('/api/qr', qrRoutes);

// =============================================================================
// 기본 라우트
// =============================================================================

// 루트 경로
app.get('/', (req, res) => {
  res.json({ 
    message: 'QR 자산관리 시스템 API 서버',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// 헬스체크 엔드포인트
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// =============================================================================
// 에러 핸들링 미들웨어
// =============================================================================

// 404 에러 처리
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'API 엔드포인트를 찾을 수 없습니다',
    path: req.originalUrl,
    method: req.method
  });
});

// 전역 에러 핸들러
app.use((err, req, res, next) => {
  console.error('서버 에러:', err);
  res.status(500).json({ 
    error: '서버 내부 오류가 발생했습니다',
    message: err.message
  });
});

// =============================================================================
// 서버 시작
// =============================================================================

// 환경 변수 로딩 확인
console.log('🔧 환경 변수 로딩 상태:');
console.log('   NODE_ENV:', process.env.NODE_ENV || 'not set');
console.log('   PORT:', process.env.PORT || 'not set (using default: 4000)');
console.log('   SUPABASE_URL:', process.env.SUPABASE_URL ? 'SET' : 'NOT SET');
console.log('   SUPABASE_ANON_KEY:', process.env.SUPABASE_ANON_KEY ? 'SET' : 'NOT SET');
console.log('   SUPABASE_SERVICE_ROLE_KEY:', process.env.SUPABASE_SERVICE_ROLE_KEY ? 'SET' : 'NOT SET');
console.log('');

// 2024-12-19: NCP 서버 배포를 위해 포트를 4000으로 변경
const PORT = process.env.PORT || 4000;

// 2025-01-27: HTTPS 서버 설정 추가
const createHttpsServer = () => {
  try {
    // SSL 인증서 파일 경로
    const certPath = '/etc/letsencrypt/live/invenone.it.kr/fullchain.pem';
    const keyPath = '/etc/letsencrypt/live/invenone.it.kr/privkey.pem';
    
    // 인증서 파일 존재 확인
    if (!fs.existsSync(certPath) || !fs.existsSync(keyPath)) {
      console.log('⚠️ SSL 인증서 파일을 찾을 수 없습니다. HTTP 서버로 시작합니다.');
      return null;
    }
    
    // SSL 옵션 설정
    const httpsOptions = {
      cert: fs.readFileSync(certPath),
      key: fs.readFileSync(keyPath)
    };
    
    // HTTPS 서버 생성
    const httpsServer = https.createServer(httpsOptions, app);
    
    console.log('🔒 HTTPS 서버가 성공적으로 설정되었습니다.');
    return httpsServer;
    
  } catch (error) {
    console.log('⚠️ HTTPS 서버 설정 중 오류 발생:', error.message);
    console.log('HTTP 서버로 시작합니다.');
    return null;
  }
};

// 서버 시작 함수
const startServer = () => {
  const httpsServer = createHttpsServer();
  
  if (httpsServer) {
    // HTTPS 서버 시작
    httpsServer.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 HTTPS 서버가 포트 ${PORT}에서 실행 중입니다.`);
      console.log(`🔗 https://invenone.it.kr:${PORT}`);
      console.log(`📊 헬스체크: https://invenone.it.kr:${PORT}/api/health`);
    });
  } else {
    // HTTP 서버 시작 (fallback)
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 HTTP 서버가 포트 ${PORT}에서 실행 중입니다.`);
      console.log(`🔗 http://invenone.it.kr:${PORT}`);
      console.log(`📊 헬스체크: http://invenone.it.kr:${PORT}/api/health`);
    });
  }
};

// 서버 시작
startServer(); 