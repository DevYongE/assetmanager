#!/bin/bash

# 2024-12-19: NCP 서버 배포 스크립트
echo "🚀 Starting deployment to NCP server..."

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
echo "📊 PM2 Status: pm2 status" 