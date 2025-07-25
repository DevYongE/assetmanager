// User and Authentication types
export interface User {
  id: string
  email: string
  created_at?: string
}

export interface LoginCredentials {
  email: string
  password: string
}

export interface RegisterData {
  email: string
  password: string
  company_name: string
}

export interface AuthResponse {
  message: string
  user: User
  token: string
}

// Employee types
export interface Employee {
  id: string
  admin_id: string
  department: string
  position: string
  name: string
  company_name: string
  created_at: string
}

export interface CreateEmployeeData {
  department: string
  position: string
  name: string
  company_name: string
}

// Device types
export interface Device {
  id: string
  employee_id: string
  asset_number: string
  manufacturer?: string
  model_name?: string
  serial_number?: string
  cpu?: string
  memory?: string
  storage?: string
  gpu?: string
  os?: string
  monitor?: string
  created_at: string
  employees?: Employee
}

export interface CreateDeviceData {
  employee_id: string
  asset_number: string
  manufacturer?: string
  model_name?: string
  serial_number?: string
  cpu?: string
  memory?: string
  storage?: string
  gpu?: string
  os?: string
  monitor?: string
}

// Dashboard types
export interface DashboardStats {
  total_employees: number
  total_devices: number
  active_devices: number
  company_name: string
}

export interface DashboardData {
  recent_employees: DashboardEmployee[]
  recent_devices: DashboardDevice[]
  department_distribution: DepartmentStats[]
  summary: {
    total_employees: number
    total_devices: number
  }
}

export interface DashboardEmployee {
  id: string
  name: string
  department: string
  position: string
  created_at: string
}

export interface DashboardDevice {
  id: string
  asset_number: string
  manufacturer: string
  model_name: string
  employees: { name: string }
  created_at: string
}

export interface DepartmentStats {
  department: string
  device_count: number
  employee_count: number
}

// QR Code types
export interface QRCodeData {
  type: 'device' | 'employee'
  id: string
  asset_number?: string
  name?: string
  manufacturer?: string
  model_name?: string
  serial_number?: string
  employee?: {
    name: string
    department: string
    position: string
  }
  devices?: Device[]
  company: string
  generated_at: string
}

export interface QRCodeResponse {
  qr_data: QRCodeData
  qr_string: string
}

// API Response types
export interface ApiResponse<T = any> {
  message?: string
  error?: string
  data?: T
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  limit: number
}

// Form validation types
export interface ValidationErrors {
  [key: string]: string[]
}

// File upload types
export interface ExcelImportResponse {
  message: string
  success_count: number
  error_count: number
  errors: string[]
  devices: Device[]
}

// UI State types
export interface LoadingState {
  [key: string]: boolean
}

export interface Toast {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message?: string
  duration?: number
} 