import { defineStore } from 'pinia'
import type { User, LoginCredentials, RegisterData } from '~/types'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    token: null as string | null,
    loading: false,
    error: null as string | null
  }),

  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
    userCompany: (state) => state.user?.company_name || ''
  },

  actions: {
    // 2025-01-27: initializeAuth 메서드 추가
    initializeAuth() {
      if (process.client) {
        const savedToken = localStorage.getItem('auth_token')
        const savedUser = localStorage.getItem('auth_user')
        
        if (savedToken && savedUser) {
          try {
            this.token = savedToken
            this.user = JSON.parse(savedUser)
          } catch (e) {
            // Clear invalid data
            localStorage.removeItem('auth_token')
            localStorage.removeItem('auth_user')
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
        
        console.log('💾 [AUTH STORE] Storing auth data to localStorage')
        console.log('🎫 [AUTH STORE] Token:', this.token ? 'EXISTS' : 'MISSING')
        console.log('👤 [AUTH STORE] User:', this.user)
        
        // Persist to localStorage
        if (process.client) {
          localStorage.setItem('auth_token', response.token)
          localStorage.setItem('auth_user', JSON.stringify(response.user))
          console.log('💾 [AUTH STORE] Data saved to localStorage')
        }
        
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
        
        // Persist to localStorage
        if (process.client) {
          localStorage.setItem('auth_token', response.token)
          localStorage.setItem('auth_user', JSON.stringify(response.user))
        }
        
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
      
      // Clear localStorage
      if (process.client) {
        localStorage.removeItem('auth_token')
        localStorage.removeItem('auth_user')
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
        
        // Update localStorage
        if (process.client) {
          localStorage.setItem('auth_user', JSON.stringify(response.user))
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
        
        // Update localStorage
        if (process.client) {
          localStorage.setItem('auth_user', JSON.stringify(response.user))
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