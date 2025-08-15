import { defineStore } from 'pinia'
import type { User, LoginCredentials, RegisterData } from '~/types'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    token: null as string | null,
    loading: false,
    error: null as string | null,
    // 2025-08-08: 세션 관리 개선
    lastActivity: null as number | null,
    sessionTimeout: 24 * 60 * 60 * 1000, // 24시간 (밀리초)
    refreshInterval: null as NodeJS.Timeout | null,
    // 2025-01-27: 브라우저 종료 감지
    browserCloseListener: null as (() => void) | null
  }),

  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
    userCompany: (state) => state.user?.company_name || '',
    // 2025-08-08: 세션 상태 확인
    isSessionValid: (state) => {
      if (!state.lastActivity || !state.token) return false
      const now = Date.now()
      const timeSinceLastActivity = now - state.lastActivity
      return timeSinceLastActivity < state.sessionTimeout
    }
  },

  actions: {
    // 2025-08-08: 세션 활동 업데이트
    // 2025-01-27: 세션 스토리지도 함께 업데이트
    updateActivity() {
      this.lastActivity = Date.now()
      if (process.client) {
        localStorage.setItem('last_activity', this.lastActivity.toString())
        
        // 2025-01-27: 세션 스토리지도 업데이트
        if (this.token && this.user) {
          sessionStorage.setItem('auth_token', this.token)
          sessionStorage.setItem('auth_user', JSON.stringify(this.user))
        }
      }
    },

    // 2025-08-08: 세션 모니터링 시작
    startSessionMonitoring() {
      if (process.client && this.isAuthenticated) {
        // 5분마다 세션 상태 확인
        this.refreshInterval = setInterval(() => {
          this.checkSessionValidity()
        }, 5 * 60 * 1000)
        
        // 2025-01-27: 브라우저 종료 감지 시작
        this.startBrowserCloseDetection()
      }
    },

    // 2025-08-08: 세션 유효성 확인
    checkSessionValidity() {
      if (!this.isSessionValid) {
        console.log('🔐 [AUTH STORE] Session expired, logging out...')
        this.logout()
        return
      }
      
      // 활동 시간 업데이트
      this.updateActivity()
    },

    // 2025-08-08: initializeAuth 메서드 개선
    // 2025-01-27: 세션 스토리지 우선 확인으로 브라우저 종료 감지
    initializeAuth() {
      if (process.client) {
        // 2025-01-27: 세션 스토리지 우선 확인 (브라우저 종료 시 자동 삭제됨)
        let savedToken = sessionStorage.getItem('auth_token')
        let savedUser = sessionStorage.getItem('auth_user')
        let savedLastActivity = localStorage.getItem('last_activity')
        
        // 세션 스토리지에 없으면 localStorage에서 확인
        if (!savedToken || !savedUser) {
          savedToken = localStorage.getItem('auth_token')
          savedUser = localStorage.getItem('auth_user')
          console.log('🔐 [AUTH STORE] Session storage empty, checking localStorage...')
        } else {
          console.log('🔐 [AUTH STORE] Session found in sessionStorage')
        }
        
        if (savedToken && savedUser) {
          try {
            this.token = savedToken
            this.user = JSON.parse(savedUser)
            this.lastActivity = savedLastActivity ? parseInt(savedLastActivity) : Date.now()
            
            // 세션 유효성 확인
            if (this.isSessionValid) {
              this.updateActivity()
              this.startSessionMonitoring()
              console.log('✅ [AUTH STORE] Session restored successfully')
            } else {
              console.log('⚠️ [AUTH STORE] Session expired, clearing data')
              this.logout()
            }
          } catch (e) {
            console.error('❌ [AUTH STORE] Failed to restore session:', e)
            localStorage.removeItem('auth_token')
            localStorage.removeItem('auth_user')
            localStorage.removeItem('last_activity')
            sessionStorage.removeItem('auth_token')
            sessionStorage.removeItem('auth_user')
          }
        } else {
          console.log('🔐 [AUTH STORE] No saved session found')
        }
      }
    },

    async login(credentials: LoginCredentials) {
      this.loading = true
      this.error = null
      
      try {
        console.log('🚀 [AUTH STORE] Starting login process...')
        console.log('📧 [AUTH STORE] Credentials:', { email: credentials.email, passwordLength: credentials.password.length })
        
        // 2025-01-27: useApi composable 사용으로 변경 (환경별 자동 처리)
        const { auth } = useApi()
        const response = await auth.login(credentials)
        
        console.log('✅ [AUTH STORE] Login API response received')
        console.log('📦 [AUTH STORE] Response data:', response)
        
        // Store auth data
        this.token = response.token
        this.user = response.user
        this.updateActivity() // 2025-08-08: 활동 시간 초기화
        
        console.log('💾 [AUTH STORE] Storing auth data to localStorage')
        console.log('🎫 [AUTH STORE] Token:', this.token ? 'EXISTS' : 'MISSING')
        console.log('👤 [AUTH STORE] User:', this.user)
        
        // Persist to localStorage and sessionStorage
        if (process.client) {
          localStorage.setItem('auth_token', response.token)
          localStorage.setItem('auth_user', JSON.stringify(response.user))
          localStorage.setItem('last_activity', this.lastActivity!.toString())
          
          // 2025-01-27: 세션 스토리지에도 저장 (브라우저 종료 시 자동 삭제)
          sessionStorage.setItem('auth_token', response.token)
          sessionStorage.setItem('auth_user', JSON.stringify(response.user))
          
          console.log('💾 [AUTH STORE] Data saved to localStorage and sessionStorage')
        }
        
        // 2025-08-08: 세션 모니터링 시작
        this.startSessionMonitoring()
        
        console.log('✅ [AUTH STORE] Login completed successfully')
        return response
      } catch (err: any) {
        console.error('❌ [AUTH STORE] Login failed:', err)
        this.error = err.message || '로그인에 실패했습니다.'
        throw err
      } finally {
        this.loading = false
      }
    },

    // 2025-01-27: register 메서드 추가
    async register(data: RegisterData) {
      this.loading = true
      this.error = null
      
      try {
        // 2025-01-27: useApi composable 사용으로 변경 (환경별 자동 처리)
        const { auth } = useApi()
        const response = await auth.register(data)
        
        // Store auth data
        this.token = response.token
        this.user = response.user
        this.updateActivity() // 2025-08-08: 활동 시간 초기화
        
        // Persist to localStorage and sessionStorage
        if (process.client) {
          localStorage.setItem('auth_token', response.token)
          localStorage.setItem('auth_user', JSON.stringify(response.user))
          localStorage.setItem('last_activity', this.lastActivity!.toString())
          
          // 2025-01-27: 세션 스토리지에도 저장 (브라우저 종료 시 자동 삭제)
          sessionStorage.setItem('auth_token', response.token)
          sessionStorage.setItem('auth_user', JSON.stringify(response.user))
        }
        
        // 2025-08-08: 세션 모니터링 시작
        this.startSessionMonitoring()
        
        return response
      } catch (err: any) {
        this.error = err.message || '회원가입에 실패했습니다.'
        throw err
      } finally {
        this.loading = false
      }
    },

    async logout() {
      // Clear state
      this.user = null
      this.token = null
      this.error = null
      this.lastActivity = null
      
      // Clear interval
      if (this.refreshInterval) {
        clearInterval(this.refreshInterval)
        this.refreshInterval = null
      }
      
      // 2025-01-27: 브라우저 종료 감지 정리
      this.stopBrowserCloseDetection()
      
      // Clear localStorage
      if (process.client) {
        localStorage.removeItem('auth_token')
        localStorage.removeItem('auth_user')
        localStorage.removeItem('last_activity')
        sessionStorage.removeItem('auth_token')
        sessionStorage.removeItem('auth_user')
      }
      
      // Redirect to login
      navigateTo('/login')
    },

    async refreshProfile() {
      if (!this.isAuthenticated) return
      
      this.loading = true
      try {
        // 2025-01-27: useApi composable 사용으로 변경 (환경별 자동 처리)
        const { auth } = useApi()
        const response = await auth.getProfile()
        this.user = response.user
        this.updateActivity() // 2025-08-08: 활동 시간 업데이트
        
        // Update localStorage
        if (process.client) {
          localStorage.setItem('auth_user', JSON.stringify(response.user))
          localStorage.setItem('last_activity', this.lastActivity!.toString())
        }
      } catch (err: any) {
        this.error = err.message || '프로필 정보를 가져올 수 없습니다.'
        // If token is invalid, logout
        if (err.message.includes('401') || err.message.includes('403')) {
          this.logout()
        }
      } finally {
        this.loading = false
      }
    },

    async updateProfile(data: Partial<User & { current_password?: string; new_password?: string }>) {
      this.loading = true
      this.error = null
      
      try {
        // 2025-01-27: useApi composable 사용으로 변경 (환경별 자동 처리)
        const { auth } = useApi()
        const response = await auth.updateProfile(data)
        this.user = response.user
        this.updateActivity() // 2025-08-08: 활동 시간 업데이트
        
        // Update localStorage
        if (process.client) {
          localStorage.setItem('auth_user', JSON.stringify(response.user))
          localStorage.setItem('last_activity', this.lastActivity!.toString())
        }
        
        return response
      } catch (err: any) {
        this.error = err.message || '프로필 업데이트에 실패했습니다.'
        throw err
      } finally {
        this.loading = false
      }
    },

    clearError() {
      this.error = null
    },

    // 2025-01-27: 브라우저 종료 감지 시작
    startBrowserCloseDetection() {
      if (process.client && !this.browserCloseListener) {
        const handleBrowserClose = () => {
          console.log('🔐 [AUTH STORE] Browser closing detected, logging out...')
          // 브라우저 종료 시 즉시 로그아웃
          this.user = null
          this.token = null
          this.error = null
          this.lastActivity = null
          
          // 세션 스토리지만 정리 (localStorage는 유지)
          sessionStorage.removeItem('auth_token')
          sessionStorage.removeItem('auth_user')
        }

        // beforeunload: 브라우저 탭/창 닫기
        window.addEventListener('beforeunload', handleBrowserClose)
        
        // pagehide: 페이지 숨김 (모바일 브라우저 대응)
        window.addEventListener('pagehide', handleBrowserClose)
        
        // visibilitychange: 탭 전환 시
        document.addEventListener('visibilitychange', () => {
          if (document.visibilityState === 'hidden') {
            console.log('🔐 [AUTH STORE] Page hidden, preparing for logout...')
          }
        })

        this.browserCloseListener = handleBrowserClose
        console.log('✅ [AUTH STORE] Browser close detection started')
      }
    },

    // 2025-01-27: 브라우저 종료 감지 정리
    stopBrowserCloseDetection() {
      if (process.client && this.browserCloseListener) {
        window.removeEventListener('beforeunload', this.browserCloseListener)
        window.removeEventListener('pagehide', this.browserCloseListener)
        this.browserCloseListener = null
        console.log('✅ [AUTH STORE] Browser close detection stopped')
      }
    }
  }
}) 