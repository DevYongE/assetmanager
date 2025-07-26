// 2024-12-19: NCP 서버 배포를 위한 PM2 설정 파일
module.exports = {
  apps: [
    {
      name: 'assetmanager-backend',
      script: 'index.js',
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
}; 