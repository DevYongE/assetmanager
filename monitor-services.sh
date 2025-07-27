#!/bin/bash

# 2025-01-27: QR 자산관리 시스템 PM2 모니터링 스크립트
# 서비스 상태를 확인하고 필요시 재시작

echo "🔍 Monitoring QR Asset Management System..."

# PM2 상태 확인
pm2 status

# 각 서비스의 상태 확인
backend_status=$(pm2 jlist | jq -r '.[] | select(.name=="assetmanager-backend") | .pm2_env.status')
frontend_status=$(pm2 jlist | jq -r '.[] | select(.name=="assetmanager-frontend") | .pm2_env.status')

echo "📊 Service Status:"
echo "   Backend: $backend_status"
echo "   Frontend: $frontend_status"

# 백엔드 상태 확인 및 재시작
if [ "$backend_status" != "online" ]; then
    echo "⚠️ Backend is not online. Restarting..."
    pm2 restart assetmanager-backend
    sleep 5
    backend_status=$(pm2 jlist | jq -r '.[] | select(.name=="assetmanager-backend") | .pm2_env.status')
    echo "   Backend status after restart: $backend_status"
fi

# 프론트엔드 상태 확인 및 재시작
if [ "$frontend_status" != "online" ]; then
    echo "⚠️ Frontend is not online. Restarting..."
    pm2 restart assetmanager-frontend
    sleep 5
    frontend_status=$(pm2 jlist | jq -r '.[] | select(.name=="assetmanager-frontend") | .pm2_env.status')
    echo "   Frontend status after restart: $frontend_status"
fi

# 메모리 사용량 확인
echo "💾 Memory Usage:"
pm2 monit --no-daemon &

# 로그 확인 (최근 10줄)
echo "📋 Recent Logs:"
echo "=== Backend Logs ==="
pm2 logs assetmanager-backend --lines 5 --nostream
echo "=== Frontend Logs ==="
pm2 logs assetmanager-frontend --lines 5 --nostream

echo "✅ Monitoring completed!" 