#!/bin/bash

# 2025-01-27: QR 자산관리 시스템 PM2 서비스 시작 스크립트
# 서버 재부팅 시 자동으로 실행되도록 설정

echo "🚀 Starting QR Asset Management System..."

# 로그 디렉토리 생성
mkdir -p logs

# PM2가 설치되어 있는지 확인
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 is not installed. Installing PM2..."
    npm install -g pm2
fi

# 기존 PM2 프로세스 중지 및 삭제
echo "🔄 Stopping existing PM2 processes..."
pm2 delete all 2>/dev/null || true

# 환경변수 설정
export NODE_ENV=production
export API_BASE_URL=https://invenone.it.kr

# 의존성 설치
echo "📦 Installing dependencies..."

# Backend 의존성 설치
echo "📦 Installing Backend dependencies..."
cd backend
npm install --production
cd ..

# Frontend 의존성 설치 및 빌드
echo "📦 Installing Frontend dependencies..."
cd frontend
npm install --production
echo "🔨 Building Frontend..."
NODE_ENV=production npm run build
cd ..

# PM2로 서비스 시작
echo "🚀 Starting services with PM2..."
pm2 start ecosystem.config.js --env production

# PM2 설정 저장 (서버 재부팅 시 자동 시작)
echo "💾 Saving PM2 configuration..."
pm2 save

# PM2 startup 스크립트 생성 (서버 재부팅 시 자동 시작)
echo "🔧 Setting up PM2 startup script..."
pm2 startup

# 상태 확인
echo "📊 Checking service status..."
pm2 status

echo "✅ Services started successfully!"
echo "🌐 Backend: http://localhost:4000"
echo "🌐 Frontend: http://localhost:3000"
echo "🌐 HTTPS: https://invenone.it.kr"
echo "📊 PM2 Status: pm2 status"
echo "📋 PM2 Logs: pm2 logs"
echo "🔄 Restart: pm2 restart all"
echo "⏹️ Stop: pm2 stop all" 