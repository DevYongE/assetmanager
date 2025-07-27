import type { 
  User, 
  LoginCredentials, 
  RegisterData, 
  AuthResponse,
  Employee,
  CreateEmployeeData,
  Device,
  CreateDeviceData,
  DashboardStats,
  DashboardData,
  QRCodeResponse,
  ExcelImportResponse,
  ApiResponse
} from '~/types'

export const useApi = () => {
  const config = useRuntimeConfig()
  const apiBase = config.public.apiBase
  const isProduction = config.public.isProduction
  const debugMode = config.public.debugMode

  // Get auth token from localStorage
  const getAuthToken = () => {
    if (import.meta.client) {
      return localStorage.getItem('auth_token')
    }
    return null
  }

  // Create headers with auth token
  const createHeaders = () => {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    }
    
    const token = getAuthToken()
    if (token) {
      headers.Authorization = `Bearer ${token}`
    }
    
    return headers
  }

  // 2025-07-27: 환경별 API 호출 함수
  // 개발/테스트 환경: 단순 호출
  // 운영 환경: HTTPS 실패 시 HTTP 자동 전환
  const apiCallWithFallback = async <T>(
    endpoint: string, 
    options: RequestInit = {}
  ): Promise<T> => {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiBase
    const isProduction = config.public.isProduction
    const debugMode = config.public.debugMode
    
    if (debugMode) {
      console.log('🔧 [API DEBUG] Environment:', isProduction ? 'PRODUCTION' : 'DEVELOPMENT')
      console.log('🔧 [API DEBUG] Base URL:', baseUrl)
    }
    
    // 개발/테스트 환경: 단순 호출
    if (!isProduction) {
      console.log('🔍 [API DEBUG] Development mode - direct call:', `${baseUrl}${endpoint}`)
      
      const response = await fetch(`${baseUrl}${endpoint}`, {
        headers: createHeaders(),
        ...options
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Network error' }))
        throw new Error(error.error || `HTTP ${response.status}`)
      }

      return response.json()
    }
    
    // 운영 환경: HTTPS 실패 시 HTTP 자동 전환
    const httpsUrl = baseUrl.replace('http://', 'https://')
    const httpUrl = baseUrl.replace('https://', 'http://')
    
    console.log('🔍 [API DEBUG] Production mode - trying HTTPS first:', `${httpsUrl}${endpoint}`)
    
    try {
      // 먼저 HTTPS로 시도
      const response = await fetch(`${httpsUrl}${endpoint}`, {
        headers: createHeaders(),
        ...options
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Network error' }))
        throw new Error(error.error || `HTTP ${response.status}`)
      }

      return response.json()
    } catch (error) {
      console.log('⚠️ [API DEBUG] HTTPS failed, trying HTTP:', `${httpUrl}${endpoint}`)
      
      try {
        // HTTPS 실패 시 HTTP로 재시도
        const response = await fetch(`${httpUrl}${endpoint}`, {
          headers: createHeaders(),
          ...options
        })

        if (!response.ok) {
          const error = await response.json().catch(() => ({ error: 'Network error' }))
          throw new Error(error.error || `HTTP ${response.status}`)
        }

        return response.json()
      } catch (httpError) {
        console.error('❌ [API DEBUG] Both HTTPS and HTTP failed:', httpError)
        throw httpError
      }
    }
  }

  // FormData를 사용하는 API용 환경별 함수
  const apiCallWithFormData = async <T>(
    endpoint: string,
    formData: FormData,
    options: RequestInit = {}
  ): Promise<T> => {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiBase
    const isProduction = config.public.isProduction
    const debugMode = config.public.debugMode
    
    const token = getAuthToken()
    const headers: Record<string, string> = {}
    if (token) {
      headers.Authorization = `Bearer ${token}`
    }
    
    if (debugMode) {
      console.log('🔧 [API DEBUG] FormData Environment:', isProduction ? 'PRODUCTION' : 'DEVELOPMENT')
    }
    
    // 개발/테스트 환경: 단순 호출
    if (!isProduction) {
      console.log('🔍 [API DEBUG] Development mode - FormData call:', `${baseUrl}${endpoint}`)
      
      const response = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers,
        body: formData,
        ...options
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Network error' }))
        throw new Error(error.error || `HTTP ${response.status}`)
      }

      return response.json()
    }
    
    // 운영 환경: HTTPS 실패 시 HTTP 자동 전환
    const httpsUrl = baseUrl.replace('http://', 'https://')
    const httpUrl = baseUrl.replace('https://', 'http://')
    
    console.log('🔍 [API DEBUG] Production mode - FormData HTTPS first:', `${httpsUrl}${endpoint}`)
    
    try {
      // 먼저 HTTPS로 시도
      const response = await fetch(`${httpsUrl}${endpoint}`, {
        method: 'POST',
        headers,
        body: formData,
        ...options
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Network error' }))
        throw new Error(error.error || `HTTP ${response.status}`)
      }

      return response.json()
    } catch (error) {
      console.log('⚠️ [API DEBUG] FormData HTTPS failed, trying HTTP:', `${httpUrl}${endpoint}`)
      
      try {
        // HTTPS 실패 시 HTTP로 재시도
        const response = await fetch(`${httpUrl}${endpoint}`, {
          method: 'POST',
          headers,
          body: formData,
          ...options
        })

        if (!response.ok) {
          const error = await response.json().catch(() => ({ error: 'Network error' }))
          throw new Error(error.error || `HTTP ${response.status}`)
        }

        return response.json()
      } catch (httpError) {
        console.error('❌ [API DEBUG] FormData both HTTPS and HTTP failed:', httpError)
        throw httpError
      }
    }
  }

  // Blob 다운로드용 환경별 함수
  const apiCallForBlob = async (
    endpoint: string,
    options: RequestInit = {}
  ): Promise<Blob> => {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiBase
    const isProduction = config.public.isProduction
    const debugMode = config.public.debugMode
    
    const token = getAuthToken()
    const headers: Record<string, string> = {}
    if (token) {
      headers.Authorization = `Bearer ${token}`
    }
    
    if (debugMode) {
      console.log('🔧 [API DEBUG] Blob Environment:', isProduction ? 'PRODUCTION' : 'DEVELOPMENT')
    }
    
    // 개발/테스트 환경: 단순 호출
    if (!isProduction) {
      console.log('🔍 [API DEBUG] Development mode - Blob call:', `${baseUrl}${endpoint}`)
      
      const response = await fetch(`${baseUrl}${endpoint}`, {
        headers,
        ...options
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      return response.blob()
    }
    
    // 운영 환경: HTTPS 실패 시 HTTP 자동 전환
    const httpsUrl = baseUrl.replace('http://', 'https://')
    const httpUrl = baseUrl.replace('https://', 'http://')
    
    console.log('🔍 [API DEBUG] Production mode - Blob HTTPS first:', `${httpsUrl}${endpoint}`)
    
    try {
      // 먼저 HTTPS로 시도
      const response = await fetch(`${httpsUrl}${endpoint}`, {
        headers,
        ...options
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      return response.blob()
    } catch (error) {
      console.log('⚠️ [API DEBUG] Blob HTTPS failed, trying HTTP:', `${httpUrl}${endpoint}`)
      
      try {
        // HTTPS 실패 시 HTTP로 재시도
        const response = await fetch(`${httpUrl}${endpoint}`, {
          headers,
          ...options
        })

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`)
        }

        return response.blob()
      } catch (httpError) {
        console.error('❌ [API DEBUG] Blob both HTTPS and HTTP failed:', httpError)
        throw httpError
      }
    }
  }

  // Generic API call function (기존 호환성을 위해 유지)
  const apiCall = async <T>(
    endpoint: string, 
    options: RequestInit = {}
  ): Promise<T> => {
    return apiCallWithFallback<T>(endpoint, options)
  }

  // Authentication API
  const auth = {
    async login(credentials: LoginCredentials): Promise<AuthResponse> {
      return apiCall<AuthResponse>('/api/auth/login', {
        method: 'POST',
        body: JSON.stringify(credentials)
      })
    },

    async register(data: RegisterData): Promise<AuthResponse> {
      return apiCall<AuthResponse>('/api/auth/register', {
        method: 'POST',
        body: JSON.stringify(data)
      })
    },

    async getProfile(): Promise<{ user: User }> {
      return apiCall<{ user: User }>('/api/auth/profile')
    },

    async updateProfile(data: Partial<User & { current_password?: string; new_password?: string }>): Promise<{ user: User }> {
      return apiCall<{ user: User }>('/api/auth/profile', {
        method: 'PUT',
        body: JSON.stringify(data)
      })
    }
  }

  // Users API
  const users = {
    async getStats(): Promise<{ stats: DashboardStats }> {
      return apiCall<{ stats: DashboardStats }>('/api/users/stats')
    },

    async getDashboard(): Promise<{ dashboard: DashboardData }> {
      return apiCall<{ dashboard: DashboardData }>('/api/users/dashboard')
    }
  }

  // Employees API
  const employees = {
    async getAll(): Promise<{ employees: Employee[] }> {
      return apiCall<{ employees: Employee[] }>('/api/employees')
    },

    async getById(id: string): Promise<{ employee: Employee }> {
      return apiCall<{ employee: Employee }>(`/api/employees/${id}`)
    },

    async create(data: CreateEmployeeData): Promise<{ employee: Employee }> {
      return apiCall<{ employee: Employee }>('/api/employees', {
        method: 'POST',
        body: JSON.stringify(data)
      })
    },

    async update(id: string, data: Partial<CreateEmployeeData>): Promise<{ employee: Employee }> {
      return apiCall<{ employee: Employee }>(`/api/employees/${id}`, {
        method: 'PUT',
        body: JSON.stringify(data)
      })
    },

    async delete(id: string): Promise<{ message: string }> {
      return apiCall<{ message: string }>(`/api/employees/${id}`, {
        method: 'DELETE'
      })
    }
  }

  // Devices API
  const devices = {
    async getAll(): Promise<{ devices: Device[] }> {
      return apiCall<{ devices: Device[] }>('/api/devices')
    },

    async getById(id: string): Promise<{ device: Device }> {
      return apiCall<{ device: Device }>(`/api/devices/${id}`)
    },

    async create(data: CreateDeviceData): Promise<{ device: Device }> {
      return apiCall<{ device: Device }>('/api/devices', {
        method: 'POST',
        body: JSON.stringify(data)
      })
    },

    async update(id: string, data: Partial<CreateDeviceData>): Promise<{ device: Device }> {
      return apiCall<{ device: Device }>(`/api/devices/${id}`, {
        method: 'PUT',
        body: JSON.stringify(data)
      })
    },

    async delete(id: string): Promise<{ message: string }> {
      return apiCall<{ message: string }>(`/api/devices/${id}`, {
        method: 'DELETE'
      })
    },

    // 2025-07-27: FormData를 사용하는 API도 HTTPS/HTTP 자동 전환 적용
    async importExcel(file: File): Promise<ExcelImportResponse> {
      const formData = new FormData()
      formData.append('file', file)

      return apiCallWithFormData<ExcelImportResponse>('/api/devices/import', formData)
    },

    async exportExcel(): Promise<Blob> {
      return apiCallForBlob('/api/devices/export/excel')
    }
  }

  // QR Codes API
  const qr = {
    async getDeviceQR(id: string, format: 'png' | 'svg' | 'json' = 'json'): Promise<QRCodeResponse | Blob> {
      if (format === 'json') {
        return apiCall<QRCodeResponse>(`/api/qr/device/${id}?format=json`)
      } else {
        return apiCallForBlob(`/api/qr/device/${id}?format=${format}`)
      }
    },

    async getEmployeeQR(id: string, format: 'png' | 'svg' | 'json' = 'json'): Promise<QRCodeResponse | Blob> {
      if (format === 'json') {
        return apiCall<QRCodeResponse>(`/api/qr/employee/${id}?format=json`)
      } else {
        return apiCallForBlob(`/api/qr/employee/${id}?format=${format}`)
      }
    },

    async bulkDeviceQR(deviceIds: string[], format: 'png' | 'json' = 'json'): Promise<any> {
      return apiCall<any>('/api/qr/bulk/devices', {
        method: 'POST',
        body: JSON.stringify({ device_ids: deviceIds, format })
      })
    },

    async decode(qrString: string): Promise<{ data: any; is_valid: boolean }> {
      return apiCall<{ data: any; is_valid: boolean }>('/api/qr/decode', {
        method: 'POST',
        body: JSON.stringify({ qr_string: qrString })
      })
    }
  }

  return {
    auth,
    users,
    employees,
    devices,
    qr
  }
} 