#!/bin/bash

# =============================================================================
# useAuthStore 오류 최종 해결 스크립트
# =============================================================================
#
# 이 스크립트는 useAuthStore is not defined 오류를 완전히 해결합니다.
# auto-import 설정과 TypeScript 설정을 포함합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 useAuthStore 오류를 최종적으로 해결합니다..."
echo ""

# =============================================================================
# 1. 완전한 초기화
# =============================================================================
echo "🧹 1단계: 완전한 초기화"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "모든 빌드 파일 및 캐시 정리..."
rm -rf .output .nuxt node_modules package-lock.json

echo "npm 캐시 정리..."
npm cache clean --force

cd ..

echo ""

# =============================================================================
# 2. nuxt.config.ts 완전 재작성
# =============================================================================
echo "⚙️ 2단계: nuxt.config.ts 완전 재작성"

echo "nuxt.config.ts 파일 완전 재작성..."
cat > frontend/nuxt.config.ts << 'EOF'
// =============================================================================
// QR 자산관리 시스템 Nuxt.js 설정 파일
// =============================================================================
//
// 이 파일은 Nuxt.js 프레임워크의 설정을 담당합니다.
// 개발 환경과 운영 환경의 설정을 분리하여 관리하며,
// 빌드 최적화, 모듈 설정, 환경변수 등을 포함합니다.
//
// 주요 설정:
// - 개발 서버 포트 설정
// - 빌드 최적화 설정
// - CSS 프레임워크 (Tailwind CSS)
// - 상태 관리 (Pinia)
// - 환경별 API URL 설정
// - 보안 및 성능 최적화
//
// 작성일: 2025-01-27
// =============================================================================

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  // 개발 도구 활성화 (개발 환경에서만 사용)
  devtools: { enabled: true },
  
  // =============================================================================
  // 개발 서버 설정
  // =============================================================================
  // 2024-12-19: NCP 서버 배포를 위해 포트를 3000으로 변경
  devServer: {
    port: 3000  // 프론트엔드 개발 서버 포트
  },
  
  // =============================================================================
  // Nitro 서버 설정 (Nuxt 3의 서버 엔진)
  // =============================================================================
  // 2025-01-27: nginx 없이 MIME 타입 문제 해결을 위한 설정 개선
  nitro: {
    storage: {
      redis: {
        driver: 'memory'  // 메모리 기반 스토리지 사용
      }
    },
    // 정적 파일 서빙 활성화
    static: true
  },
  
  // =============================================================================
  // 실험적 기능 설정
  // =============================================================================
  // 2024-12-19: 캐시 무효화를 위한 설정
  experimental: {
    payloadExtraction: false  // 페이로드 추출 비활성화로 캐시 문제 해결
  },
  
  // =============================================================================
  // CSS 설정
  // =============================================================================
  // 전역 CSS 파일 로드
  css: ['~/assets/css/main.css'],
  
  // =============================================================================
  // 모듈 설정
  // =============================================================================
  modules: [
    '@nuxtjs/tailwindcss',  // Tailwind CSS 프레임워크
    '@pinia/nuxt'           // Pinia 상태 관리
  ],
  
  // =============================================================================
  // 앱 헤더 설정
  // =============================================================================
  app: {
    head: {
      // 외부 리소스 (폰트 등) 사전 로드
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
  
  // =============================================================================
  // PostCSS 설정
  // =============================================================================
  // CSS 후처리 도구 설정
  postcss: {
    plugins: {
      tailwindcss: {},    // Tailwind CSS 처리
      autoprefixer: {},   // 벤더 프리픽스 자동 추가
    },
  },
  
  // =============================================================================
  // Auto-import 설정
  // =============================================================================
  // 2025-01-27: auto-import 설정 추가
  imports: {
    dirs: ['stores']
  },
  
  // =============================================================================
  // TypeScript 설정
  // =============================================================================
  // 2025-01-27: TypeScript 설정 추가
  typescript: {
    strict: true,
    typeCheck: true
  },
  
  // =============================================================================
  // 런타임 설정 (환경변수)
  // =============================================================================
  // 2025-01-27: 상대 경로 API URL 설정
  runtimeConfig: {
    public: {
      // =============================================================================
      // API 기본 URL 설정
      // =============================================================================
      // 개발 환경: localhost 사용
      // 운영 환경: 상대 경로 사용 (2025-01-27: localhost 호출 문제 해결)
      apiBase: process.env.NODE_ENV === 'production' 
        ? (process.env.API_BASE_URL || '/api')  // 상대 경로로 변경하여 localhost 호출 방지
        : (process.env.API_BASE_URL || 'http://localhost:4000/api'),  // 개발환경은 HTTP
      
      // =============================================================================
      // 환경 구분 플래그
      // =============================================================================
      // 환경별 기능 분기를 위한 플래그
      isProduction: process.env.NODE_ENV === 'production',
      isDevelopment: process.env.NODE_ENV === 'development',
      
      // =============================================================================
      // 디버그 모드 설정
      // =============================================================================
      // 환경별 디버그 모드 (운영 환경에서는 비활성화)
      debugMode: process.env.NODE_ENV !== 'production'
    }
  }
})
EOF

echo "✅ nuxt.config.ts 파일 완전 재작성 완료"

echo ""

# =============================================================================
# 3. package.json 수정
# =============================================================================
echo "📦 3단계: package.json 수정"

echo "package.json에 Pinia 패키지 강제 추가..."
cd frontend

# package.json에 Pinia 패키지가 없으면 추가
if ! grep -q "@pinia/nuxt" package.json; then
    npm install @pinia/nuxt
    echo "✅ @pinia/nuxt 패키지 추가 완료"
else
    echo "✅ @pinia/nuxt 패키지 이미 존재"
fi

# pinia 패키지도 추가
if ! grep -q "pinia" package.json; then
    npm install pinia
    echo "✅ pinia 패키지 추가 완료"
else
    echo "✅ pinia 패키지 이미 존재"
fi

cd ..

echo ""

# =============================================================================
# 4. stores 디렉토리 및 파일 완전 재생성
# =============================================================================
echo "📝 4단계: stores 디렉토리 및 파일 완전 재생성"

echo "stores 디렉토리 생성..."
mkdir -p frontend/stores

echo "auth.ts 파일 완전 재생성..."
cat > frontend/stores/auth.ts << 'EOF'
// =============================================================================
// QR 자산관리 시스템 인증 스토어
// =============================================================================
//
// 이 파일은 Pinia를 사용한 인증 상태 관리를 담당합니다.
// 로그인, 로그아웃, 사용자 정보 관리 등의 기능을 제공합니다.
//
// 작성일: 2025-01-27
// =============================================================================

import { defineStore } from 'pinia'

// =============================================================================
// 사용자 타입 정의
// =============================================================================
interface User {
  id: string
  email: string
  name: string
  role: string
  created_at: string
  updated_at: string
}

// =============================================================================
// 인증 상태 타입 정의
// =============================================================================
interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  loading: boolean
}

// =============================================================================
// 인증 스토어 정의
// =============================================================================
export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    token: null,
    isAuthenticated: false,
    loading: false
  }),

  getters: {
    // 현재 사용자 정보
    currentUser: (state) => state.user,
    
    // 인증 상태
    isLoggedIn: (state) => state.isAuthenticated && !!state.token,
    
    // 로딩 상태
    isLoading: (state) => state.loading
  },

  actions: {
    // =============================================================================
    // 로그인
    // =============================================================================
    async login(credentials: { email: string; password: string }) {
      this.loading = true
      
      try {
        const { $api } = useNuxtApp()
        const response = await $api.auth.login(credentials)
        
        this.token = response.token
        this.user = response.user
        this.isAuthenticated = true
        
        // 토큰을 localStorage에 저장
        if (process.client) {
          localStorage.setItem('auth_token', response.token)
        }
        
        return response
      } catch (error) {
        console.error('Login error:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    // =============================================================================
    // 로그아웃
    // =============================================================================
    async logout() {
      this.loading = true
      
      try {
        const { $api } = useNuxtApp()
        await $api.auth.logout()
      } catch (error) {
        console.error('Logout error:', error)
      } finally {
        // 상태 초기화
        this.user = null
        this.token = null
        this.isAuthenticated = false
        
        // localStorage에서 토큰 제거
        if (process.client) {
          localStorage.removeItem('auth_token')
        }
        
        this.loading = false
      }
    },

    // =============================================================================
    // 사용자 정보 가져오기
    // =============================================================================
    async fetchUser() {
      this.loading = true
      
      try {
        const { $api } = useNuxtApp()
        const response = await $api.auth.getProfile()
        
        this.user = response.user
        this.isAuthenticated = true
        
        return response
      } catch (error) {
        console.error('Fetch user error:', error)
        this.logout()
        throw error
      } finally {
        this.loading = false
      }
    },

    // =============================================================================
    // 토큰으로 인증 상태 복원
    // =============================================================================
    async restoreAuth() {
      if (process.client) {
        const token = localStorage.getItem('auth_token')
        if (token) {
          this.token = token
          this.isAuthenticated = true
          
          try {
            await this.fetchUser()
          } catch (error) {
            console.error('Restore auth error:', error)
            this.logout()
          }
        }
      }
    },

    // =============================================================================
    // 사용자 정보 업데이트
    // =============================================================================
    async updateProfile(data: Partial<User>) {
      this.loading = true
      
      try {
        const { $api } = useNuxtApp()
        const response = await $api.auth.updateProfile(data)
        
        this.user = response.user
        
        return response
      } catch (error) {
        console.error('Update profile error:', error)
        throw error
      } finally {
        this.loading = false
      }
    }
  }
})
EOF

echo "✅ auth.ts 파일 완전 재생성 완료"

echo ""

# =============================================================================
# 5. 의존성 완전 재설치
# =============================================================================
echo "📦 5단계: 의존성 완전 재설치"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "의존성 완전 재설치..."
npm install

echo "Pinia 패키지 확인:"
npm list @pinia/nuxt
npm list pinia

cd ..

echo ""

# =============================================================================
# 6. 프론트엔드 완전 재빌드
# =============================================================================
echo "🔨 6단계: 프론트엔드 완전 재빌드"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "프론트엔드 완전 재빌드..."
NODE_ENV=production npm run build

if [ $? -eq 0 ]; then
    echo "✅ 프론트엔드 빌드 성공"
    
    echo ""
    echo "빌드 파일 확인:"
    ls -la .output/
    
    echo ""
    echo "서버 파일 확인:"
    ls -la .output/server/
    
else
    echo "❌ 프론트엔드 빌드 실패"
    echo "빌드 로그 확인 중..."
    npm run build 2>&1 | tail -20
    exit 1
fi

cd ..

echo ""

# =============================================================================
# 7. PM2 완전 재시작
# =============================================================================
echo "⚙️ 7단계: PM2 완전 재시작"

echo "기존 PM2 프로세스 중지..."
pm2 stop all 2>/dev/null
pm2 delete all 2>/dev/null
pm2 kill 2>/dev/null

echo "5초 대기..."
sleep 5

echo "PM2 프로세스 재시작..."
pm2 start ecosystem.config.js

echo "10초 대기..."
sleep 10

echo "PM2 상태 확인..."
pm2 status

echo ""
echo "PM2 로그 확인:"
pm2 logs --lines 10

echo ""

# =============================================================================
# 8. 포트 테스트
# =============================================================================
echo "🧪 8단계: 포트 테스트"

echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(3000|4000)'

echo ""
echo "백엔드 직접 테스트:"
curl -I http://localhost:4000/api/health 2>/dev/null && echo "✅ 백엔드 정상" || echo "❌ 백엔드 실패"

echo ""
echo "프론트엔드 직접 테스트:"
curl -I http://localhost:3000 2>/dev/null && echo "✅ 프론트엔드 정상" || echo "❌ 프론트엔드 실패"

echo ""

# =============================================================================
# 9. Nginx 재시작
# =============================================================================
echo "🌐 9단계: Nginx 재시작"

echo "Nginx 설정 테스트..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx 설정 테스트 성공"
    echo "Nginx 재시작..."
    sudo systemctl restart nginx
    echo "Nginx 상태 확인..."
    sudo systemctl status nginx --no-pager
else
    echo "❌ Nginx 설정 테스트 실패"
    exit 1
fi

echo ""

# =============================================================================
# 10. 최종 테스트
# =============================================================================
echo "🎯 10단계: 최종 테스트"

echo "20초 대기..."
sleep 20

echo "웹사이트 테스트:"
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""
echo "API 테스트:"
curl -I https://invenone.it.kr/api/health 2>/dev/null && echo "✅ API 정상" || echo "❌ API 실패"

echo ""

# =============================================================================
# 11. 완료
# =============================================================================
echo "🎉 useAuthStore 오류 최종 해결 완료!"
echo ""
echo "📋 확인 사항:"
echo "   1. 브라우저에서 https://invenone.it.kr 접속"
echo "   2. 브라우저 캐시 삭제 후 재접속 (Ctrl+F5)"
echo "   3. 개발자 도구에서 Console 탭 확인"
echo "   4. useAuthStore 오류가 사라졌는지 확인"
echo ""
echo "🔧 관리 명령어:"
echo "   PM2 상태: pm2 status"
echo "   PM2 로그: pm2 logs"
echo "   백엔드 로그: pm2 logs qr-backend"
echo "   프론트엔드 로그: pm2 logs qr-frontend"
echo "   Nginx 상태: sudo systemctl status nginx"
echo "   Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 