#!/bin/bash

# 2025-07-27: 개발/테스트 환경 배포 스크립트
echo "🚀 Starting development deployment..."

# 환경변수 설정 (개발 환경)
export NODE_ENV=development
export API_BASE_URL=http://localhost:4000

# Backend 배포
echo "📦 Deploying Backend (Development Mode)..."
cd backend
npm install
npm run build
pm2 start ecosystem.config.js --env development

# Frontend 배포 (개발 환경용)
echo "📦 Deploying Frontend (Development Mode)..."
cd ../frontend
npm install
NODE_ENV=development npm run build
pm2 start ecosystem.config.js --env development

echo "✅ Development deployment completed!"
echo "🌐 Backend: http://localhost:4000"
echo "🌐 Frontend: http://localhost:3000"
echo "📊 PM2 Status: pm2 status"
echo "🔧 Environment: DEVELOPMENT" 