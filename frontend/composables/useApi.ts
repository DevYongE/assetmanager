// =============================================================================
// QR 자산관리 시스템 API 호출 로직
// =============================================================================
//
// 이 파일은 프론트엔드에서 백엔드 API와 통신하는 모든 로직을 담당합니다.
// 환경별 API URL 설정, 인증 토큰 관리, 에러 처리, CORS 설정 등을 포함합니다.
//
// 주요 기능:
// - 환경별 API URL 자동 설정
// - JWT 토큰 기반 인증
// - HTTPS/HTTP 자동 전환 (운영 환경)
// - 에러 처리 및 재시도 로직
// - CORS 설정
// - 파일 업로드/다운로드
// - QR 코드 생성 및 관리
//
// 작성일: 2025-01-27
// =============================================================================

// 타입 정의 import
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

// =============================================================================
// API 호출 유틸리티 함수
// =============================================================================
export const useApi = () => {
  // Nuxt 런타임 설정에서 환경변수 가져오기
  const config = useRuntimeConfig()
  const apiBase = config.public.apiBase
  const isProduction = config.public.isProduction
  const debugMode = config.public.debugMode

  // =============================================================================
  // 인증 토큰 관리 함수
  // =============================================================================
  // localStorage에서 인증 토큰을 가져오는 함수
  const getAuthToken = () => {
    if (import.meta.client) {
      return localStorage.getItem('auth_token')
    }
    return null
  }

  // =============================================================================
  // HTTP 헤더 생성 함수
  // =============================================================================
  // API 요청에 필요한 헤더를 생성하는 함수
  const createHeaders = () => {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'  // JSON 데이터 전송
    }
    
    // 인증 토큰이 있으면 Authorization 헤더에 추가
    const token = getAuthToken()
    if (token) {
      headers.Authorization = `Bearer ${token}`
    }
    
    return headers
  }

  // =============================================================================
  // 개선된 API 호출 함수 (환경별 처리)
  // =============================================================================
  // 2025-01-27: CSP 문제 해결 및 안정적인 API 호출
  const apiCallWithFallback = async <T>(
    endpoint: string, 
    options: RequestInit = {}
  ): Promise<T> => {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiBase
    const isProduction = config.public.isProduction
    const debugMode = config.public.debugMode
    
    // 디버그 모드에서 환경 정보 출력
    if (debugMode) {
      console.log('🔧 [API DEBUG] Environment:', isProduction ? 'PRODUCTION' : 'DEVELOPMENT')
      console.log('🔧 [API DEBUG] Base URL:', baseUrl)
      console.log('🔧 [API DEBUG] Endpoint:', endpoint)
    }
    
    // =============================================================================
    // 개발/테스트 환경 처리
    // =============================================================================
    // 개발 환경에서는 단순한 API 호출만 수행
    if (!isProduction) {
      const fullUrl = `${baseUrl}${endpoint}`
      console.log('🔍 [API DEBUG] Development mode - direct call:', fullUrl)
      
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
    
    // =============================================================================
    // 운영 환경 처리 (HTTPS 우선, 실패 시 HTTP 자동 전환)
    // =============================================================================
    // HTTPS와 HTTP URL 준비
    const httpsUrl = baseUrl.replace('http://', 'https://')
    const httpUrl = baseUrl.replace('https://', 'http://')
    
    console.log('🔍 [API DEBUG] Production mode - trying HTTPS first:', `${httpsUrl}${endpoint}`)
    
    try {
      // 먼저 HTTPS로 시도
      const response = await fetch(`${httpsUrl}${endpoint}`, {
        headers: createHeaders(),
        ...options,
        mode: 'cors', // CORS 모드 명시적 설정
        credentials: 'include' // 쿠키 포함
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Network error' }))
        throw new Error(error.error || `HTTP ${response.status}`)
      }

      return response.json()
    } catch (httpsError) {
      console.log('⚠️ [API DEBUG] HTTPS failed, trying HTTP:', `${httpUrl}${endpoint}`)
      
      try {
        // HTTPS 실패 시 HTTP로 시도
        const response = await fetch(`${httpUrl}${endpoint}`, {
          headers: createHeaders(),
          ...options,
          mode: 'cors',
          credentials: 'include'
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

  // =============================================================================
  // FormData를 사용하는 API 호출 함수
  // =============================================================================
  // 파일 업로드 등 FormData를 사용하는 API 호출용
  const apiCallWithFormData = async <T>(
    endpoint: string,
    formData: FormData,
    options: RequestInit = {}
  ): Promise<T> => {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiBase
    const isProduction = config.public.isProduction
    const debugMode = config.public.debugMode
    
    // 인증 토큰 준비
    const token = getAuthToken()
    const headers: Record<string, string> = {}
    if (token) {
      headers.Authorization = `Bearer ${token}`
    }
    
    if (debugMode) {
      console.log('🔧 [API DEBUG] FormData Environment:', isProduction ? 'PRODUCTION' : 'DEVELOPMENT')
      console.log('🔧 [API DEBUG] FormData Base URL:', baseUrl)
    }
    
    // 개발 환경 처리
    if (!isProduction) {
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
    
    // 운영 환경 처리 (HTTPS 우선)
    const httpsUrl = baseUrl.replace('http://', 'https://')
    const httpUrl = baseUrl.replace('https://', 'http://')
    
    try {
      const response = await fetch(`${httpsUrl}${endpoint}`, {
        method: 'POST',
        headers,
        body: formData,
        mode: 'cors',
        credentials: 'include',
        ...options
      })

      if (!response.ok) {
        const error = await response.json().catch(() => ({ error: 'Network error' }))
        throw new Error(error.error || `HTTP ${response.status}`)
      }

      return response.json()
    } catch (error) {
      console.log('⚠️ [API DEBUG] HTTPS failed, trying HTTP for FormData')
      
      try {
        const response = await fetch(`${httpUrl}${endpoint}`, {
          method: 'POST',
          headers,
          body: formData,
          mode: 'cors',
          credentials: 'include',
          ...options
        })

        if (!response.ok) {
          const error = await response.json().catch(() => ({ error: 'Network error' }))
          throw new Error(error.error || `HTTP ${response.status}`)
        }

        return response.json()
      } catch (httpError) {
        console.error('❌ [API DEBUG] Both HTTPS and HTTP failed for FormData:', httpError)
        throw httpError
      }
    }
  }

  // =============================================================================
  // Blob 데이터를 위한 API 호출 함수
  // =============================================================================
  // QR 코드 이미지나 파일 다운로드 등 Blob 데이터를 받는 API 호출용
  const apiCallForBlob = async (
    endpoint: string,
    options: RequestInit = {}
  ): Promise<Blob> => {
    const config = useRuntimeConfig()
    const baseUrl = config.public.apiBase
    const isProduction = config.public.isProduction
    const debugMode = config.public.debugMode
    
    if (debugMode) {
      console.log('🔧 [API DEBUG] Blob Environment:', isProduction ? 'PRODUCTION' : 'DEVELOPMENT')
    }
    
    // 개발 환경 처리
    if (!isProduction) {
      const response = await fetch(`${baseUrl}${endpoint}`, {
        headers: createHeaders(),
        ...options
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      return response.blob()
    }
    
    // 운영 환경 처리 (HTTPS 우선)
    const httpsUrl = baseUrl.replace('http://', 'https://')
    const httpUrl = baseUrl.replace('https://', 'http://')
    
    try {
      const response = await fetch(`${httpsUrl}${endpoint}`, {
        headers: createHeaders(),
        mode: 'cors',
        credentials: 'include',
        ...options
      })

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }

      return response.blob()
    } catch (error) {
      console.log('⚠️ [API DEBUG] HTTPS failed, trying HTTP for Blob')
      
      try {
        const response = await fetch(`${httpUrl}${endpoint}`, {
          headers: createHeaders(),
          mode: 'cors',
          credentials: 'include',
          ...options
        })

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`)
        }

        return response.blob()
      } catch (httpError) {
        console.error('❌ [API DEBUG] Both HTTPS and HTTP failed for Blob:', httpError)
        throw httpError
      }
    }
  }

  // =============================================================================
  // 기본 API 호출 함수
  // =============================================================================
  // 일반적인 API 호출을 위한 래퍼 함수
  const apiCall = async <T>(
    endpoint: string, 
    options: RequestInit = {}
  ): Promise<T> => {
    return apiCallWithFallback<T>(endpoint, options)
  }

  // =============================================================================
  // 인증 관련 API 함수들
  // =============================================================================
  const auth = {
    // 로그인 API
    async login(credentials: LoginCredentials): Promise<AuthResponse> {
      return apiCall<AuthResponse>('/auth/login', {
        method: 'POST',
        body: JSON.stringify(credentials)
      })
    },

    // 회원가입 API
    async register(data: RegisterData): Promise<AuthResponse> {
      return apiCall<AuthResponse>('/auth/register', {
        method: 'POST',
        body: JSON.stringify(data)
      })
    },

    // 프로필 조회 API
    async getProfile(): Promise<{ user: User }> {
      return apiCall<{ user: User }>('/users/profile')
    },

    // 프로필 업데이트 API
    async updateProfile(data: Partial<User & { current_password?: string; new_password?: string }>): Promise<{ user: User }> {
      return apiCall<{ user: User }>('/users/profile', {
        method: 'PUT',
        body: JSON.stringify(data)
      })
    }
  }

  // =============================================================================
  // 대시보드 관련 API 함수들
  // =============================================================================
  const dashboard = {
    // 통계 데이터 조회
    async getStats(): Promise<{ stats: DashboardStats }> {
      return apiCall<{ stats: DashboardStats }>('/users/stats')
    },

    // 대시보드 데이터 조회
    async getDashboard(): Promise<{ dashboard: DashboardData }> {
      return apiCall<{ dashboard: DashboardData }>('/users/dashboard')
    }
  }

  // =============================================================================
  // 직원 관리 API 함수들
  // =============================================================================
  const employees = {
    // 전체 직원 목록 조회
    async getAll(): Promise<{ employees: Employee[] }> {
      return apiCall<{ employees: Employee[] }>('/employees')
    },

    // 특정 직원 조회
    async getById(id: string): Promise<{ employee: Employee }> {
      return apiCall<{ employee: Employee }>(`/employees/${id}`)
    },

    // 직원 생성
    async create(data: CreateEmployeeData): Promise<{ employee: Employee }> {
      return apiCall<{ employee: Employee }>('/employees', {
        method: 'POST',
        body: JSON.stringify(data)
      })
    },

    // 직원 정보 업데이트
    async update(id: string, data: Partial<CreateEmployeeData>): Promise<{ employee: Employee }> {
      return apiCall<{ employee: Employee }>(`/employees/${id}`, {
        method: 'PUT',
        body: JSON.stringify(data)
      })
    },

    // 직원 삭제
    async delete(id: string): Promise<{ message: string }> {
      return apiCall<{ message: string }>(`/employees/${id}`, {
        method: 'DELETE'
      })
    }
  }

  // =============================================================================
  // 장비 관리 API 함수들
  // =============================================================================
  const devices = {
    // 전체 장비 목록 조회 (필터링 옵션 포함)
    async getAll(params?: Record<string, string>): Promise<{ devices: Device[] }> {
      const queryString = params ? `?${new URLSearchParams(params).toString()}` : ''
      return apiCall<{ devices: Device[] }>(`/devices${queryString}`)
    },

    // 특정 장비 조회
    async getById(id: string): Promise<{ device: Device }> {
      return apiCall<{ device: Device }>(`/devices/${id}`)
    },

    // 장비 생성
    async create(data: CreateDeviceData): Promise<{ device: Device }> {
      return apiCall<{ device: Device }>('/devices', {
        method: 'POST',
        body: JSON.stringify(data)
      })
    },

    // 장비 정보 업데이트
    async update(id: string, data: Partial<CreateDeviceData>): Promise<{ device: Device }> {
      return apiCall<{ device: Device }>(`/devices/${id}`, {
        method: 'PUT',
        body: JSON.stringify(data)
      })
    },

    // 장비 삭제
    async delete(id: string): Promise<{ message: string }> {
      return apiCall<{ message: string }>(`/devices/${id}`, {
        method: 'DELETE'
      })
    },

    // Excel 파일 import
    async importExcel(file: File): Promise<ExcelImportResponse> {
      const formData = new FormData()
      formData.append('file', file)
      return apiCallWithFormData<ExcelImportResponse>('/devices/import', formData)
    },

    // Excel 파일 export
    async exportExcel(): Promise<Blob> {
      return apiCallForBlob('/devices/export')
    }
  }

  // =============================================================================
  // QR 코드 관련 API 함수들
  // =============================================================================
  const qr = {
    // 장비 QR 코드 생성
    async getDeviceQR(id: string, format: 'png' | 'svg' | 'json' = 'json'): Promise<QRCodeResponse | Blob> {
      if (format === 'json') {
        return apiCall<QRCodeResponse>(`/qr/device/${id}`)
      } else {
        return apiCallForBlob(`/qr/device/${id}?format=${format}`)
      }
    },

    // 직원 QR 코드 생성
    async getEmployeeQR(id: string, format: 'png' | 'svg' | 'json' = 'json'): Promise<QRCodeResponse | Blob> {
      if (format === 'json') {
        return apiCall<QRCodeResponse>(`/qr/employee/${id}`)
      } else {
        return apiCallForBlob(`/qr/employee/${id}?format=${format}`)
      }
    },

    // 일괄 장비 QR 코드 생성
    async bulkDeviceQR(deviceIds: string[], format: 'png' | 'json' = 'json', useTest: boolean = false): Promise<any> {
      const endpoint = useTest ? '/qr/bulk/test' : '/qr/bulk/devices'
      return apiCall(endpoint, {
        method: 'POST',
        body: JSON.stringify({ device_ids: deviceIds, format })
      })
    },

    // QR 코드 디코딩
    async decode(qrString: string): Promise<{ data: any; is_valid: boolean }> {
      return apiCall<{ data: any; is_valid: boolean }>('/qr/decode', {
        method: 'POST',
        body: JSON.stringify({ qr_string: qrString })
      })
    }
  }

  // =============================================================================
  // API 함수들 반환
  // =============================================================================
  return {
    auth,
    dashboard,
    employees,
    devices,
    qr
  }
} 