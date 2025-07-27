// 2025-01-27: QR 자산관리 시스템 통합 PM2 설정
// 백엔드와 프론트엔드를 함께 관리하는 설정 파일
module.exports = {
  apps: [
    {
      name: 'assetmanager-backend',
      script: './backend/index.js',
      cwd: './backend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true,
      env: {
        NODE_ENV: 'development',
        PORT: 4000
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 4000
      },
      // 2025-01-27: 자동 재시작 설정 추가
      restart_delay: 4000,
      max_restarts: 10,
      min_uptime: '10s'
    },
    {
      name: 'assetmanager-frontend',
      script: 'node_modules/nuxt/bin/nuxt.js',
      args: 'start',
      cwd: './frontend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true,
      env: {
        NODE_ENV: 'development',
        PORT: 3000,
        API_BASE_URL: 'http://localhost:4000'
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
        API_BASE_URL: 'https://invenone.it.kr'
      },
      // 2025-01-27: 자동 재시작 설정 추가
      restart_delay: 4000,
      max_restarts: 10,
      min_uptime: '10s'
    }
  ]
}; 