# =============================================================================
# Windows PowerShell Server Deployment Script
# =============================================================================

Write-Host "Starting server deployment..." -ForegroundColor Green
Write-Host ""

# =============================================================================
# 1. Check current status
# =============================================================================
Write-Host "Step 1: Check current status" -ForegroundColor Yellow

Write-Host "Checking frontend build files..."
if (Test-Path "frontend\.output\server") {
    Write-Host "Frontend build files exist" -ForegroundColor Green
} else {
    Write-Host "Frontend build files missing" -ForegroundColor Red
}

Write-Host ""

# =============================================================================
# 2. Server deployment commands
# =============================================================================
Write-Host "Step 2: Server deployment commands" -ForegroundColor Yellow

Write-Host "Run these commands on NCP server:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Connect to server:" -ForegroundColor White
Write-Host "   ssh dmanager@211.188.55.145" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Navigate to project directory:" -ForegroundColor White
Write-Host "   cd /home/dmanager/assetmanager" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Pull latest code:" -ForegroundColor White
Write-Host "   git pull origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Run fix_auth_store.sh:" -ForegroundColor White
Write-Host "   chmod +x fix_auth_store.sh" -ForegroundColor Gray
Write-Host "   ./fix_auth_store.sh" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# 3. Manual deployment steps
# =============================================================================
Write-Host "Step 3: Manual deployment steps" -ForegroundColor Yellow

Write-Host "Execute these steps on server in order:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Stop PM2 processes:" -ForegroundColor White
Write-Host "   pm2 stop all" -ForegroundColor Gray
Write-Host "   pm2 delete all" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Rebuild frontend:" -ForegroundColor White
Write-Host "   cd frontend" -ForegroundColor Gray
Write-Host "   rm -rf .output .nuxt" -ForegroundColor Gray
Write-Host "   npm run build" -ForegroundColor Gray
Write-Host "   cd .." -ForegroundColor Gray
Write-Host ""
Write-Host "3. Restart with PM2:" -ForegroundColor White
Write-Host "   pm2 start ecosystem.config.js" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Restart Caddy:" -ForegroundColor White
Write-Host "   sudo systemctl restart caddy" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Check status:" -ForegroundColor White
Write-Host "   pm2 status" -ForegroundColor Gray
Write-Host "   sudo systemctl status caddy" -ForegroundColor Gray
Write-Host ""

# =============================================================================
# 4. Completion
# =============================================================================
Write-Host "Step 4: Completion" -ForegroundColor Yellow

Write-Host "After deployment, check the following:" -ForegroundColor Cyan
Write-Host "   1. Visit https://invenone.it.kr" -ForegroundColor White
Write-Host "   2. Clear browser cache (Ctrl+F5)" -ForegroundColor White
Write-Host "   3. Check Console tab in Developer Tools" -ForegroundColor White
Write-Host ""
Write-Host "Troubleshooting commands:" -ForegroundColor Cyan
Write-Host "   PM2 logs: pm2 logs" -ForegroundColor Gray
Write-Host "   Caddy logs: sudo journalctl -u caddy -f" -ForegroundColor Gray
Write-Host "   Port check: sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'" -ForegroundColor Gray
Write-Host ""
Write-Host "Deployment preparation completed!" -ForegroundColor Green 