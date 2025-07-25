// 2024-12-19: NCP 서버 배포를 위한 Frontend PM2 설정 파일
module.exports = {
  apps: [
    {
      name: 'assetmanager-frontend',
      script: 'node_modules/nuxt/bin/nuxt.js',
      args: 'start',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000
      }
    }
  ]
}; 