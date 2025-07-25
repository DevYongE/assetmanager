import { defineStore } from 'pinia'

interface User {
  id: string
  email: string
  company_name: string
  created_at?: string
}

interface LoginCredentials {
  email: string
  password: string
}

interface RegisterData {
  email: string
  password: string
  company_name: string
}

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
        
        // Simple API call without useApi composable with timeout
        const response = await $fetch<{token: string, user: User}>('http://localhost:3000/api/auth/login', {
          method: 'POST',
          body: credentials,
          // Add timeout
          timeout: 8000
        })
        
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

    async register(data: RegisterData) {
      this.loading = true
      this.error = null
      
      try {
        // Simple API call without useApi composable
        const response = await $fetch<{token: string, user: User}>('http://localhost:3000/api/auth/register', {
          method: 'POST',
          body: data
        })
        
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

    logout() {
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
        const response = await $fetch<{user: User}>('http://localhost:3000/api/auth/profile', {
          headers: {
            'Authorization': `Bearer ${this.token}`
          }
        })
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
        const response = await $fetch<{user: User}>('/api/auth/profile', {
          method: 'PUT',
          headers: {
            'Authorization': `Bearer ${this.token}`
          },
          body: data
        })
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