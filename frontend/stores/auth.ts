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
    refreshInterval: null as NodeJS.Timeout | null
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
    updateActivity() {
      this.lastActivity = Date.now()
      if (process.client) {
        localStorage.setItem('last_activity', this.lastActivity.toString())
      }
    },

    // 2025-08-08: 세션 모니터링 시작
    startSessionMonitoring() {
      if (process.client && this.isAuthenticated) {
        // 5분마다 세션 상태 확인
        this.refreshInterval = setInterval(() => {
          this.checkSessionValidity()
        }, 5 * 60 * 1000)
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
    initializeAuth() {
      if (process.client) {
        const savedToken = localStorage.getItem('auth_token')
        const savedUser = localStorage.getItem('auth_user')
        const savedLastActivity = localStorage.getItem('last_activity')
        
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
          }
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
        
        // Persist to localStorage
        if (process.client) {
          localStorage.setItem('auth_token', response.token)
          localStorage.setItem('auth_user', JSON.stringify(response.user))
          localStorage.setItem('last_activity', this.lastActivity!.toString())
          console.log('💾 [AUTH STORE] Data saved to localStorage')
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
        
        // Persist to localStorage
        if (process.client) {
          localStorage.setItem('auth_token', response.token)
          localStorage.setItem('auth_user', JSON.stringify(response.user))
          localStorage.setItem('last_activity', this.lastActivity!.toString())
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
      
      // Clear localStorage
      if (process.client) {
        localStorage.removeItem('auth_token')
        localStorage.removeItem('auth_user')
        localStorage.removeItem('last_activity')
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
    }
  }
}) 