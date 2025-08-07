#!/bin/bash

# =============================================================================
# useAuthStore 오류 완전 해결 스크립트
# =============================================================================
#
# 이 스크립트는 useAuthStore is not defined 오류를 완전히 해결합니다.
# 모든 관련 설정을 점검하고 수정합니다.
#
# 작성일: 2025-01-27
# =============================================================================

echo "🔧 useAuthStore 오류를 완전히 해결합니다..."
echo ""

# =============================================================================
# 1. 현재 상태 확인
# =============================================================================
echo "📋 1단계: 현재 상태 확인"

echo "현재 디렉토리:"
pwd

echo ""
echo "프론트엔드 구조 확인:"
ls -la frontend/

echo ""

# =============================================================================
# 2. 기존 파일 정리
# =============================================================================
echo "🧹 2단계: 기존 파일 정리"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "기존 빌드 파일 및 캐시 정리..."
rm -rf .output .nuxt node_modules package-lock.json

echo "npm 캐시 정리..."
npm cache clean --force

cd ..

echo ""

# =============================================================================
# 3. package.json 확인 및 수정
# =============================================================================
echo "📦 3단계: package.json 확인 및 수정"

echo "현재 package.json 확인:"
if [ -f "frontend/package.json" ]; then
    echo "Pinia 관련 패키지 확인:"
    grep -E "(pinia|@pinia)" frontend/package.json || echo "❌ Pinia 패키지 없음"
    
    echo ""
    echo "package.json에 Pinia 패키지 추가..."
    # package.json에 Pinia 패키지가 없으면 추가
    if ! grep -q "@pinia/nuxt" frontend/package.json; then
        cd frontend
        npm install @pinia/nuxt
        cd ..
        echo "✅ @pinia/nuxt 패키지 추가 완료"
    else
        echo "✅ @pinia/nuxt 패키지 이미 존재"
    fi
else
    echo "❌ package.json 파일 없음"
    exit 1
fi

echo ""

# =============================================================================
# 4. nuxt.config.ts 수정
# =============================================================================
echo "⚙️ 4단계: nuxt.config.ts 수정"

echo "현재 nuxt.config.ts 확인:"
if [ -f "frontend/nuxt.config.ts" ]; then
    echo "Pinia 모듈 설정 확인:"
    if grep -q "@pinia/nuxt" frontend/nuxt.config.ts; then
        echo "✅ Pinia 모듈 설정 존재"
    else
        echo "❌ Pinia 모듈 설정 없음 - 추가합니다"
        
        # nuxt.config.ts에 Pinia 모듈 추가
        sed -i '/modules: \[/a\    "@pinia/nuxt",' frontend/nuxt.config.ts
        echo "✅ Pinia 모듈 추가 완료"
    fi
else
    echo "❌ nuxt.config.ts 파일 없음"
    exit 1
fi

echo ""

# =============================================================================
# 5. stores 디렉토리 및 파일 생성
# =============================================================================
echo "📝 5단계: stores 디렉토리 및 파일 생성"

echo "stores 디렉토리 생성..."
mkdir -p frontend/stores

echo "auth.ts 파일 생성..."
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

echo "✅ auth.ts 파일 생성 완료"

echo ""

# =============================================================================
# 6. 의존성 설치
# =============================================================================
echo "📦 6단계: 의존성 설치"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "의존성 설치..."
npm install

echo "Pinia 패키지 확인:"
npm list @pinia/nuxt

cd ..

echo ""

# =============================================================================
# 7. 프론트엔드 재빌드
# =============================================================================
echo "🔨 7단계: 프론트엔드 재빌드"

echo "프론트엔드 디렉토리로 이동..."
cd frontend

echo "프론트엔드 재빌드..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ 프론트엔드 빌드 성공"
else
    echo "❌ 프론트엔드 빌드 실패"
    echo "빌드 로그 확인 중..."
    npm run build 2>&1 | tail -20
    exit 1
fi

cd ..

echo ""

# =============================================================================
# 8. PM2 재시작
# =============================================================================
echo "⚙️ 8단계: PM2 재시작"

echo "기존 PM2 프로세스 중지..."
pm2 stop all
pm2 delete all

echo "PM2 프로세스 재시작..."
pm2 start ecosystem.config.js

echo "PM2 상태 확인..."
pm2 status

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

echo "15초 대기..."
sleep 15

echo "포트 상태 확인:"
sudo netstat -tlnp | grep -E ':(80|443|3000|4000)'

echo ""
echo "웹사이트 테스트..."
curl -I https://invenone.it.kr 2>/dev/null && echo "✅ 웹사이트 정상" || echo "❌ 웹사이트 실패"

echo ""
echo "정적 파일 테스트..."
curl -I https://invenone.it.kr/_nuxt/ 2>/dev/null && echo "✅ 정적 파일 경로 정상" || echo "❌ 정적 파일 경로 실패"

echo ""

# =============================================================================
# 11. 완료
# =============================================================================
echo "🎉 useAuthStore 오류 완전 해결 완료!"
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
echo "   Nginx 상태: sudo systemctl status nginx"
echo "   Nginx 로그: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "✅ 모든 설정이 완료되었습니다!" 