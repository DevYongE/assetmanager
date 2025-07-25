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
  // 2024-12-19: NCP 서버 배포를 위해 프로덕션 API URL 설정
  runtimeConfig: {
    public: {
      apiBase: process.env.NODE_ENV === 'production' 
        ? 'http://211.188.55.145:4000'  // 현재 서버 IP로 설정
        : 'http://211.188.55.145:4000'  // 개발 환경에서도 현재 서버 IP 사용
    }
  }
})