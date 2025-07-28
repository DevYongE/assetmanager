// =============================================================================
// QR 자산관리 시스템 백엔드 서버
// =============================================================================
//
// 이 파일은 QR 자산관리 시스템의 백엔드 API 서버입니다.
// Express.js를 사용하여 RESTful API를 제공하며,
// 인증, 직원 관리, 장비 관리, QR 코드 생성 등의 기능을 담당합니다.
//
// 주요 기능:
// - 사용자 인증 (JWT 토큰 기반)
// - 직원 정보 관리 (CRUD)
// - 장비 정보 관리 (CRUD)
// - QR 코드 생성 및 관리
// - Excel 파일 import/export
// - 데이터베이스 연동
//
// 작성일: 2025-01-27
// =============================================================================

// 필수 모듈 import
const express = require('express');        // 웹 프레임워크
const cors = require('cors');              // CORS 설정
const dotenv = require('dotenv');          // 환경변수 관리
const path = require('path');              // 파일 경로 처리

// HTTPS 관련 모듈 (현재는 주석 처리 - HTTP 사용)
// const https = require('https');
// const fs = require('fs');

// 환경변수 로드 (.env 파일에서 설정 읽기)
dotenv.config();

// Express 애플리케이션 인스턴스 생성
const app = express();

// =============================================================================
// 서버 포트 설정
// =============================================================================
// 환경변수에서 포트를 가져오거나 기본값 4000 사용
// 2025-01-27: 임시로 HTTP 서버로 변경 (SSL 인증서 문제 해결)
const PORT = process.env.PORT || 4000;

// =============================================================================
// CORS (Cross-Origin Resource Sharing) 설정
// =============================================================================
// 2025-07-25: CORS 설정 수정 - 모바일 접속을 위해 모든 도메인 허용
const corsOptions = {
  origin: [
    'http://localhost:3000',
    'http://localhost:3002',
    'https://localhost:3000',
    'https://localhost:3002',
    'http://211.188.55.145:3000',
    'http://211.188.55.145:3002',
    'https://211.188.55.145:3000',
    'https://211.188.55.145:3002',
    'https://invenone.it.kr',
    'https://www.invenone.it.kr',
    'http://invenone.it.kr',
    'http://www.invenone.it.kr'
  ],
  credentials: true,  // 쿠키/인증 정보 포함 허용
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],  // 허용할 HTTP 메서드
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Origin', 'Accept']  // 허용할 헤더
};

// =============================================================================
// 미들웨어 설정
// =============================================================================
// CORS 미들웨어 적용
app.use(cors(corsOptions));

// JSON 요청 본문 파싱 (최대 10MB)
app.use(express.json({ limit: '10mb' }));

// URL 인코딩된 요청 본문 파싱
app.use(express.urlencoded({ extended: true }));

// =============================================================================
// 라우터 설정
// =============================================================================
console.log('🔧 [BACKEND] Setting up routes...')

// 각 기능별 라우터를 /api 경로 하위에 마운트
app.use('/api/auth', require('./routes/auth'));      // 인증 관련 (로그인, 회원가입)
app.use('/api/users', require('./routes/users'));    // 사용자 관리
app.use('/api/employees', require('./routes/employees')); // 직원 관리
app.use('/api/devices', require('./routes/devices')); // 장비 관리
app.use('/api/qr', require('./routes/qr'));         // QR 코드 생성

console.log('✅ [BACKEND] Routes configured successfully')

// =============================================================================
// 헬스 체크 엔드포인트
// =============================================================================
// 서비스 상태 확인용 엔드포인트 (모니터링, 로드밸런서용)
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),  // 서버 가동 시간
    environment: process.env.NODE_ENV || 'development'  // 현재 환경
  })
})

// =============================================================================
// 404 에러 핸들러 (주석 처리됨)
// =============================================================================
// path-to-regexp 이슈 해결을 위해 주석 처리
// app.all('*', (req, res) => {
//   res.status(404).json({ error: 'Route not found' });
// });

// =============================================================================
// 전역 에러 핸들러
// =============================================================================
// 모든 라우터에서 발생하는 에러를 처리
app.use((err, req, res, next) => {
  console.error(err.stack);  // 에러 스택 트레이스 출력
  res.status(500).json({ error: 'Something went wrong!' });
});

// =============================================================================
// 서버 시작
// =============================================================================
// 2025-01-27: 임시 HTTP 서버로 변경 (SSL 인증서 문제 해결)
app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 [BACKEND] HTTP Server is running on port', PORT);
  console.log('🌐 [BACKEND] Health check: http://0.0.0.0:' + PORT + '/health');
  console.log('🔐 [BACKEND] Auth endpoint: http://0.0.0.0:' + PORT + '/api/auth/login');
  console.log('⚠️ [BACKEND] Note: Running in HTTP mode (SSL certificate issue)');
});

// 애플리케이션 인스턴스 내보내기 (테스트용)
module.exports = app; 