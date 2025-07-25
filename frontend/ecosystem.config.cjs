// 2025-07-25: PM2 Nuxt.js 설정 (원래 방식)
module.exports = {
  apps: [
    {
      name: 'assetmanager-frontend',
      script: '.output/server/index.mjs',  // Nuxt.js 빌드 결과물 사용
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
} 