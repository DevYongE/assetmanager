// 2025-07-25: 백엔드 PM2 설정 (원래 방식)
module.exports = {
  apps: [
    {
      name: 'assetmanager-backend',
      script: './index.js',  // 원래 백엔드 진입점 사용
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'development',
        PORT: 4000
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 4000
      }
    }
  ]
}

