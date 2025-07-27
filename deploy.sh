#!/bin/bash

# 2024-12-19: NCP 서버 배포 스크립트
# 2025-07-27: 환경별 배포 설정 추가
echo "🚀 Starting deployment to NCP server..."

# 환경변수 설정 (운영 환경)
export NODE_ENV=production
export API_BASE_URL=https://invenone.it.kr/api

# Backend 배포
echo "📦 Deploying Backend..."
cd backend
npm install
npm run build
pm2 start ecosystem.config.js --env production

# Frontend 배포 (운영 환경용)
echo "📦 Deploying Frontend (Production Mode)..."
cd ../frontend
npm install
NODE_ENV=production npm run build
pm2 start ecosystem.config.js --env production

echo "✅ Deployment completed!"
echo "🌐 Backend: http://your-ncp-server-ip:4000"
echo "🌐 Frontend: http://your-ncp-server-ip:3000"
echo "🌐 HTTPS: https://invenone.it.kr"
echo "📊 PM2 Status: pm2 status"
echo "🔧 Environment: PRODUCTION" 