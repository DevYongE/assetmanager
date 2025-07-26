#!/bin/bash

# 2024-12-19: NCP 서버 배포 스크립트
# 2025-01-27: 환경변수 설정 및 에러 처리 추가
echo "🚀 Starting deployment to NCP server..."

# 환경변수 설정
export NODE_ENV=production
export API_BASE_URL=https://invenone.it.kr/api

# Backend 배포
echo "📦 Deploying Backend..."
cd backend
npm install
npm run build
pm2 start ecosystem.config.js --env production

# Frontend 배포
echo "📦 Deploying Frontend..."
cd ../frontend
npm install
npm run build
pm2 start ecosystem.config.js --env production

echo "✅ Deployment completed!"
echo "🌐 Backend: http://your-ncp-server-ip:4000"
echo "🌐 Frontend: http://your-ncp-server-ip:3000"
echo "🌐 HTTPS: https://invenone.it.kr"
echo "📊 PM2 Status: pm2 status" 