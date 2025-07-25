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

  // Generic API call function
  const apiCall = async <T>(
    endpoint: string, 
    options: RequestInit = {}
  ): Promise<T> => {
    // 2025-07-25: HTTPS 모바일 접속을 위해 서버 URL 수정 (Nginx 프록시)
    const serverUrl = 'https://211.188.55.145:9443'
    const fullUrl = `${serverUrl}${endpoint}`
    console.log('🔍 [API DEBUG] Making request to:', fullUrl)
    console.log('🔍 [API DEBUG] Server URL:', serverUrl)
    
    const response = await fetch(fullUrl, {
      headers: createHeaders(),
      ...options
    })

    if (!response.ok) {
      const error = await response.json().catch(() => ({ error: 'Network error' }))
      throw new Error(error.error || `HTTP ${response.status}`)
    }

    return response.json()
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

    async importExcel(file: File): Promise<ExcelImportResponse> {
      const formData = new FormData()
      formData.append('file', file)

      const token = getAuthToken()
      const headers: Record<string, string> = {}
      if (token) {
        headers.Authorization = `Bearer ${token}`
      }

      const response = await fetch(`${apiBase}/api/devices/import`, {
        method: 'POST',
        headers,
        body: formData
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Network error' }))
        throw new Error(error.error || `HTTP ${response.status}`)
      }

      return response.json()
    },

    async exportExcel(): Promise<Blob> {
      const token = getAuthToken()
      const headers: Record<string, string> = {}
      if (token) {
        headers.Authorization = `Bearer ${token}`
      }

      const response = await fetch(`${apiBase}/api/devices/export/excel`, {
        headers
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      return response.blob()
    }
  }

  // QR Codes API
  const qr = {
    async getDeviceQR(id: string, format: 'png' | 'svg' | 'json' = 'json'): Promise<QRCodeResponse | Blob> {
      if (format === 'json') {
        return apiCall<QRCodeResponse>(`/api/qr/device/${id}?format=json`)
      } else {
        const token = getAuthToken()
        const headers: Record<string, string> = {}
        if (token) {
          headers.Authorization = `Bearer ${token}`
        }

        const response = await fetch(`${apiBase}/api/qr/device/${id}?format=${format}`, {
          headers
        })

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`)
        }

        return response.blob()
      }
    },

    async getEmployeeQR(id: string, format: 'png' | 'svg' | 'json' = 'json'): Promise<QRCodeResponse | Blob> {
      if (format === 'json') {
        return apiCall<QRCodeResponse>(`/api/qr/employee/${id}?format=json`)
      } else {
        const token = getAuthToken()
        const headers: Record<string, string> = {}
        if (token) {
          headers.Authorization = `Bearer ${token}`
        }

        const response = await fetch(`${apiBase}/api/qr/employee/${id}?format=${format}`, {
          headers
        })

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`)
        }

        return response.blob()
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