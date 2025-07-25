// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  // 2024-12-19: NCP 서버 배포를 위해 포트를 3000으로 변경
  devServer: {
    port: 3000
  },
  // 2024-12-19: 브라우저 캐시 문제 해결을 위한 설정 추가
  nitro: {
    storage: {
      redis: {
        driver: 'memory'
      }
    }
  },
  // 2024-12-19: 캐시 무효화를 위한 설정
  experimental: {
    payloadExtraction: false
  },
  css: ['~/assets/css/main.css'],
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt'
  ],
  app: {
    head: {
      link: [
        {
          rel: 'preconnect',
          href: 'https://fonts.googleapis.com'
        },
        {
          rel: 'preconnect',
          href: 'https://fonts.gstatic.com',
          crossorigin: ''
        },
        {
          rel: 'stylesheet',
          href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap'
        }
      ]
    }
  },
  postcss: {
    plugins: {
      tailwindcss: {},
      autoprefixer: {},
    },
  },
  // 2025-01-27: 환경변수로 API URL 설정 (배포 시 유연성 확보)
  runtimeConfig: {
    public: {
      apiBase: process.env.API_BASE_URL || 'http://localhost:4000'
    }
  }
})