<template>
  <div class="container py-8">
    <!-- Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">장비 관리</h1>
        <p class="text-gray-600 mt-2">직원별 장비를 관리하고 QR 코드를 생성하세요</p>
      </div>
      <div class="flex space-x-3">
        <button 
          @click="exportExcel"
          :disabled="devices.length === 0"
          class="btn btn-secondary"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
          </svg>
          Excel 내보내기
        </button>
        <label class="btn btn-secondary cursor-pointer">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"/>
          </svg>
          Excel 가져오기
          <input 
            ref="fileInput"
            type="file" 
            accept=".xlsx,.xls" 
            @change="importExcel" 
            class="hidden"
          />
        </label>
        <button 
          @click="showAddModal = true"
          class="btn btn-primary"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
          </svg>
          장비 추가
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
      <p class="text-red-600">{{ error }}</p>
      <button @click="loadDevices" class="btn btn-secondary mt-2">
        다시 시도
      </button>
    </div>

    <!-- Devices Management -->
    <div v-else class="space-y-6">
      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="bg-white rounded-lg border p-4">
          <div class="text-2xl font-bold text-primary">{{ devices.length }}</div>
          <div class="text-sm text-gray-600">총 장비 수</div>
        </div>
        <div class="bg-white rounded-lg border p-4">
          <div class="text-2xl font-bold text-green-600">{{ manufacturerCount }}</div>
          <div class="text-sm text-gray-600">제조사 수</div>
        </div>
        <div class="bg-white rounded-lg border p-4">
          <div class="text-2xl font-bold text-blue-600">{{ assignedDevices }}</div>
          <div class="text-sm text-gray-600">할당된 장비</div>
        </div>
        <div class="bg-white rounded-lg border p-4">
          <div class="text-2xl font-bold text-purple-600">{{ recentDevices }}</div>
          <div class="text-sm text-gray-600">이번 달 신규</div>
        </div>
      </div>

      <!-- Search and Filter -->
      <div class="bg-white rounded-lg border p-4 mb-6">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="자산번호, 제조사, 모델명..."
              class="form-input"
            />
          </div>
          <div>
            <select v-model="filterEmployee" class="form-input">
              <option value="">모든 직원</option>
              <option v-for="emp in employees" :key="emp.id" :value="emp.id">
                {{ emp.name }} ({{ emp.department }})
              </option>
            </select>
          </div>
          <div>
            <select v-model="filterManufacturer" class="form-input">
              <option value="">모든 제조사</option>
              <option v-for="mfr in manufacturers" :key="mfr" :value="mfr">
                {{ mfr }}
              </option>
            </select>
          </div>
          <div>
            <button 
              @click="clearFilters"
              class="btn btn-secondary w-full"
            >
              필터 초기화
            </button>
          </div>
        </div>
      </div>

      <!-- Devices Table -->
      <div v-if="filteredDevices.length" class="bg-white rounded-lg border overflow-hidden">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  자산번호
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  담당자
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  장비 정보
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  사양
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  등록일
                </th>
                <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                  작업
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr 
                v-for="device in filteredDevices" 
                :key="device.id"
                class="hover:bg-gray-50"
              >
                <td class="px-6 py-4 whitespace-nowrap">
                  <div class="text-sm font-medium text-gray-900">{{ device.asset_number }}</div>
                  <div class="text-sm text-gray-500">{{ device.serial_number }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                                  <div class="text-sm text-gray-900">{{ device.employees?.name }}</div>
                <div class="text-sm text-gray-500">{{ device.employees?.department }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="text-sm text-gray-900">{{ device.manufacturer }} {{ device.model_name }}</div>
                  <div class="text-sm text-gray-500">{{ device.os }}</div>
                </td>
                <td class="px-6 py-4">
                  <div class="text-sm text-gray-900">{{ device.cpu }}</div>
                  <div class="text-sm text-gray-500">{{ device.memory }} | {{ device.storage }}</div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {{ formatDate(device.created_at) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div class="flex justify-end space-x-2">
                    <button 
                      @click="generateQR(device)"
                      class="text-green-600 hover:text-green-900"
                      title="QR 코드 생성"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
                      </svg>
                    </button>
                    <button 
                      @click="editDevice(device)"
                      class="text-primary hover:text-primary-700"
                      title="수정"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                      </svg>
                    </button>
                    <button 
                      @click="deleteDevice(device)"
                      class="text-red-600 hover:text-red-900"
                      title="삭제"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-12">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
        </svg>
        <h3 class="mt-2 text-sm font-medium text-gray-900">장비가 없습니다</h3>
        <p class="mt-1 text-sm text-gray-500">첫 번째 장비를 추가해보세요.</p>
        <div class="mt-6">
          <button 
            @click="showAddModal = true"
            class="btn btn-primary"
          >
            장비 추가
          </button>
        </div>
      </div>
    </div>

    <!-- Add/Edit Device Modal -->
    <div v-if="showAddModal || showEditModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-2xl mx-4 max-h-screen overflow-y-auto">
        <h3 class="text-lg font-semibold mb-4">
          {{ showEditModal ? '장비 정보 수정' : '새 장비 추가' }}
        </h3>
        
        <form @submit.prevent="showEditModal ? updateDevice() : createDevice()">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-group">
              <label class="form-label">담당자</label>
              <select v-model="deviceForm.employee_id" required class="form-input">
                <option value="">담당자를 선택하세요</option>
                <option v-for="emp in employees" :key="emp.id" :value="emp.id">
                  {{ emp.name }} ({{ emp.department }})
                </option>
              </select>
            </div>
            
            <div class="form-group">
              <label class="form-label">자산번호</label>
              <input
                v-model="deviceForm.asset_number"
                type="text"
                required
                class="form-input"
                placeholder="예: AS001"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">제조사</label>
              <input
                v-model="deviceForm.manufacturer"
                type="text"
                class="form-input"
                placeholder="예: Samsung, LG, Apple"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">모델명</label>
              <input
                v-model="deviceForm.model_name"
                type="text"
                class="form-input"
                placeholder="예: Galaxy Book Pro"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">시리얼 번호</label>
              <input
                v-model="deviceForm.serial_number"
                type="text"
                class="form-input"
                placeholder="시리얼 번호"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">CPU</label>
              <input
                v-model="deviceForm.cpu"
                type="text"
                class="form-input"
                placeholder="예: Intel i7-12700H"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">메모리</label>
              <input
                v-model="deviceForm.memory"
                type="text"
                class="form-input"
                placeholder="예: 16GB DDR4"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">저장장치</label>
              <input
                v-model="deviceForm.storage"
                type="text"
                class="form-input"
                placeholder="예: 512GB SSD"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">GPU</label>
              <input
                v-model="deviceForm.gpu"
                type="text"
                class="form-input"
                placeholder="예: RTX 4060"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">운영체제</label>
              <input
                v-model="deviceForm.os"
                type="text"
                class="form-input"
                placeholder="예: Windows 11 Pro"
              />
            </div>
            
            <div class="form-group md:col-span-2">
              <label class="form-label">모니터</label>
              <input
                v-model="deviceForm.monitor"
                type="text"
                class="form-input"
                placeholder="예: 27인치 4K 모니터"
              />
            </div>
          </div>
          
          <div class="flex justify-end space-x-3 mt-6">
            <button 
              type="button"
              @click="closeModal"
              class="btn btn-secondary"
            >
              취소
            </button>
            <button 
              type="submit"
              :disabled="isSubmitting"
              class="btn btn-primary"
            >
              {{ isSubmitting ? '저장 중...' : '저장' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- QR Modal -->
    <div v-if="showQRModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <h3 class="text-lg font-semibold mb-4">QR 코드</h3>
        <div class="text-center">
          <div v-if="qrImageUrl" class="mb-4">
            <img :src="qrImageUrl" alt="QR Code" class="mx-auto border" />
          </div>
          <div class="space-x-3">
            <button 
              @click="downloadQR"
              class="btn btn-primary"
            >
              다운로드
            </button>
            <button 
              @click="showQRModal = false"
              class="btn btn-secondary"
            >
              닫기
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Import Progress Modal -->
    <div v-if="showImportModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <h3 class="text-lg font-semibold mb-4">Excel 가져오기</h3>
        <div v-if="importResult">
          <div class="mb-4">
            <p class="text-green-600 mb-2">성공: {{ importResult.success_count }}개</p>
            <p class="text-red-600 mb-2">실패: {{ importResult.error_count }}개</p>
          </div>
          <div v-if="importResult.errors.length" class="mb-4 max-h-40 overflow-y-auto">
            <h4 class="font-medium mb-2">오류 목록:</h4>
            <ul class="text-sm text-red-600 space-y-1">
              <li v-for="(error, index) in importResult.errors" :key="index">
                {{ error }}
              </li>
            </ul>
          </div>
        </div>
        <div class="flex justify-end">
          <button 
            @click="closeImportModal"
            class="btn btn-primary"
          >
            확인
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Import types from the correct location
import type { Device, CreateDeviceData, Employee, ExcelImportResponse } from '~/types'

// Page meta
definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

// API composable
const api = useApi()

// State
const loading = ref(true)
const error = ref<string | null>(null)
const devices = ref<Device[]>([])
const employees = ref<Employee[]>([])
const isSubmitting = ref(false)

// Modal state
const showAddModal = ref(false)
const showEditModal = ref(false)
const showQRModal = ref(false)
const showImportModal = ref(false)
const editingDevice = ref<Device | null>(null)
const qrImageUrl = ref<string | null>(null)
const importResult = ref<ExcelImportResponse | null>(null)

// Form state
const deviceForm = reactive<CreateDeviceData>({
  employee_id: '',
  asset_number: '',
  manufacturer: '',
  model_name: '',
  serial_number: '',
  cpu: '',
  memory: '',
  storage: '',
  gpu: '',
  os: '',
  monitor: ''
})

// Search and filter
const searchQuery = ref('')
const filterEmployee = ref('')
const filterManufacturer = ref('')

// File input ref
const fileInput = ref<HTMLInputElement>()

// Computed properties
const manufacturers = computed(() => {
  const mfrs = new Set(devices.value.map(dev => dev.manufacturer).filter(Boolean))
  return Array.from(mfrs).sort()
})

const manufacturerCount = computed(() => manufacturers.value.length)

const assignedDevices = computed(() => devices.value.filter(dev => dev.employee_id).length)

const recentDevices = computed(() => {
  const now = new Date()
  const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1)
  return devices.value.filter(dev => new Date(dev.created_at) >= thisMonth).length
})

const filteredDevices = computed(() => {
  let filtered = devices.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(dev => 
      dev.asset_number.toLowerCase().includes(query) ||
      dev.manufacturer?.toLowerCase().includes(query) ||
      dev.model_name?.toLowerCase().includes(query) ||
      dev.serial_number?.toLowerCase().includes(query)
    )
  }

  if (filterEmployee.value) {
    filtered = filtered.filter(dev => dev.employee_id === filterEmployee.value)
  }

  if (filterManufacturer.value) {
    filtered = filtered.filter(dev => dev.manufacturer === filterManufacturer.value)
  }

  return filtered
})

// Methods
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('ko-KR')
}

const clearFilters = () => {
  searchQuery.value = ''
  filterEmployee.value = ''
  filterManufacturer.value = ''
}

const loadDevices = async () => {
  try {
    loading.value = true
    error.value = null
    const [devicesResponse, employeesResponse] = await Promise.all([
      api.devices.getAll(),
      api.employees.getAll()
    ])
    devices.value = devicesResponse.devices
    employees.value = employeesResponse.employees
  } catch (err: any) {
    error.value = err.message || '데이터를 불러올 수 없습니다'
  } finally {
    loading.value = false
  }
}

const createDevice = async () => {
  try {
    isSubmitting.value = true
    const response = await api.devices.create(deviceForm)
    devices.value.unshift(response.device)
    closeModal()
  } catch (err: any) {
    error.value = err.message || '장비 추가에 실패했습니다'
  } finally {
    isSubmitting.value = false
  }
}

const editDevice = (device: Device) => {
  editingDevice.value = device
  Object.assign(deviceForm, {
    employee_id: device.employee_id,
    asset_number: device.asset_number,
    manufacturer: device.manufacturer || '',
    model_name: device.model_name || '',
    serial_number: device.serial_number || '',
    cpu: device.cpu || '',
    memory: device.memory || '',
    storage: device.storage || '',
    gpu: device.gpu || '',
    os: device.os || '',
    monitor: device.monitor || ''
  })
  showEditModal.value = true
}

const updateDevice = async () => {
  if (!editingDevice.value) return
  
  try {
    isSubmitting.value = true
    const response = await api.devices.update(editingDevice.value.id, deviceForm)
    const index = devices.value.findIndex(dev => dev.id === editingDevice.value!.id)
    if (index !== -1) {
      devices.value[index] = response.device
    }
    closeModal()
  } catch (err: any) {
    error.value = err.message || '장비 정보 수정에 실패했습니다'
  } finally {
    isSubmitting.value = false
  }
}

const deleteDevice = async (device: Device) => {
  if (!confirm(`정말로 ${device.asset_number} 장비를 삭제하시겠습니까?`)) {
    return
  }
  
  try {
    await api.devices.delete(device.id)
    devices.value = devices.value.filter(dev => dev.id !== device.id)
  } catch (err: any) {
    error.value = err.message || '장비 삭제에 실패했습니다'
  }
}

const generateQR = async (device: Device) => {
  try {
    const blob = await api.qr.getDeviceQR(device.id, 'png') as Blob
    qrImageUrl.value = URL.createObjectURL(blob)
    showQRModal.value = true
  } catch (err: any) {
    error.value = err.message || 'QR 코드 생성에 실패했습니다'
  }
}

const downloadQR = () => {
  if (qrImageUrl.value) {
    const a = document.createElement('a')
    a.href = qrImageUrl.value
    a.download = 'qr-code.png'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  }
}

const exportExcel = async () => {
  try {
    const blob = await api.devices.exportExcel()
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `devices_${new Date().toISOString().split('T')[0]}.xlsx`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } catch (err: any) {
    error.value = err.message || 'Excel 내보내기에 실패했습니다'
  }
}

const importExcel = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return
  
  try {
    importResult.value = await api.devices.importExcel(file)
    showImportModal.value = true
    
    // Reload devices to show imported ones
    await loadDevices()
  } catch (err: any) {
    error.value = err.message || 'Excel 가져오기에 실패했습니다'
  } finally {
    if (fileInput.value) {
      fileInput.value.value = ''
    }
  }
}

const closeModal = () => {
  showAddModal.value = false
  showEditModal.value = false
  editingDevice.value = null
  Object.assign(deviceForm, {
    employee_id: '',
    asset_number: '',
    manufacturer: '',
    model_name: '',
    serial_number: '',
    cpu: '',
    memory: '',
    storage: '',
    gpu: '',
    os: '',
    monitor: ''
  })
}

const closeImportModal = () => {
  showImportModal.value = false
  importResult.value = null
}

// Load data on mount
onMounted(() => {
  loadDevices()
})
</script> 