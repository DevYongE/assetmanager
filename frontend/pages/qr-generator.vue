<template>
  <div class="container py-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">QR 코드 생성기</h1>
      <p class="text-gray-600">직원 및 장비별 QR 코드를 생성하고 관리하세요</p>
    </div>

    <!-- QR Type Selection -->
    <div class="bg-white rounded-lg border p-6 mb-8">
      <h2 class="text-xl font-semibold mb-4">QR 코드 유형 선택</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <button 
          @click="selectedType = 'device'"
          :class="[
            'p-4 border-2 rounded-lg text-left transition-colors',
            selectedType === 'device' 
              ? 'border-primary bg-primary bg-opacity-10' 
              : 'border-gray-200 hover:border-gray-300'
          ]"
        >
          <div class="flex items-start space-x-3">
            <svg class="w-6 h-6 text-primary mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
            </svg>
            <div>
              <h3 class="font-semibold text-gray-900">장비 QR 코드</h3>
              <p class="text-sm text-gray-600 mt-1">개별 장비의 상세 정보가 포함된 QR 코드</p>
              <ul class="text-xs text-gray-500 mt-2 space-y-1">
                <li>• 자산 번호, 모델명, 시리얼 번호</li>
                <li>• 담당자 정보</li>
                <li>• 장비 사양</li>
              </ul>
            </div>
          </div>
        </button>

        <button 
          @click="selectedType = 'employee'"
          :class="[
            'p-4 border-2 rounded-lg text-left transition-colors',
            selectedType === 'employee' 
              ? 'border-primary bg-primary bg-opacity-10' 
              : 'border-gray-200 hover:border-gray-300'
          ]"
        >
          <div class="flex items-start space-x-3">
            <svg class="w-6 h-6 text-primary mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
            </svg>
            <div>
              <h3 class="font-semibold text-gray-900">직원 QR 코드</h3>
              <p class="text-sm text-gray-600 mt-1">직원 정보와 할당된 장비 목록이 포함된 QR 코드</p>
              <ul class="text-xs text-gray-500 mt-2 space-y-1">
                <li>• 직원명, 부서, 직급</li>
                <li>• 할당된 모든 장비 목록</li>
                <li>• 연락처 정보</li>
              </ul>
            </div>
          </div>
        </button>
      </div>
    </div>

    <!-- Device QR Generation -->
    <div v-if="selectedType === 'device'" class="space-y-6">
      <!-- Device Selection -->
      <div class="bg-white rounded-lg border p-6">
        <h3 class="text-lg font-semibold mb-4">장비 선택</h3>
        
        <!-- Search -->
        <div class="mb-4">
          <input
            v-model="deviceSearchQuery"
            type="text"
            placeholder="자산번호, 제조사, 모델명으로 검색..."
            class="form-input"
          />
        </div>

        <!-- Device List -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-h-96 overflow-y-auto">
          <div 
            v-for="device in filteredDevices" 
            :key="device.id"
            @click="selectedDevice = device"
            :class="[
              'p-4 border rounded-lg cursor-pointer transition-colors',
              selectedDevice?.id === device.id 
                ? 'border-primary bg-primary bg-opacity-10' 
                : 'border-gray-200 hover:border-gray-300'
            ]"
          >
            <div class="flex items-center justify-between mb-2">
              <h4 class="font-medium text-gray-900">{{ device.asset_number }}</h4>
              <span v-if="selectedDevice?.id === device.id" class="text-primary">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
              </span>
            </div>
            <p class="text-sm text-gray-600">{{ device.manufacturer }} {{ device.model_name }}</p>
            <p class="text-xs text-gray-500">담당자: {{ device.employees?.name }}</p>
          </div>
        </div>

        <div v-if="filteredDevices.length === 0" class="text-center py-8 text-gray-500">
          검색 결과가 없습니다
        </div>
      </div>

      <!-- Generate Device QR -->
      <div v-if="selectedDevice" class="bg-white rounded-lg border p-6">
        <h3 class="text-lg font-semibold mb-4">QR 코드 생성</h3>
        <div class="flex flex-col md:flex-row gap-6">
          <!-- QR Options -->
          <div class="flex-1">
            <div class="space-y-4">
              <div>
                <label class="form-label">QR 코드 형식</label>
                <select v-model="deviceQRFormat" class="form-input">
                  <option value="png">PNG 이미지</option>
                  <option value="svg">SVG 벡터</option>
                </select>
              </div>
              
              <div>
                <label class="form-label">크기</label>
                <select v-model="deviceQRSize" class="form-input">
                  <option value="200">작음 (200px)</option>
                  <option value="300">중간 (300px)</option>
                  <option value="400">큼 (400px)</option>
                </select>
              </div>

              <button 
                @click="generateDeviceQR"
                :disabled="deviceQRLoading"
                class="btn btn-primary w-full"
              >
                <svg v-if="deviceQRLoading" class="animate-spin w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                </svg>
                {{ deviceQRLoading ? '생성 중...' : 'QR 코드 생성' }}
              </button>
            </div>
          </div>

          <!-- QR Preview -->
          <div class="flex-1">
            <div v-if="deviceQRUrl" class="text-center">
              <h4 class="font-medium mb-4">QR 코드 미리보기</h4>
              <div class="inline-block p-4 bg-gray-50 rounded-lg">
                <img :src="deviceQRUrl" alt="Device QR Code" class="max-w-full" />
              </div>
              <div class="mt-4 space-x-3">
                <button @click="downloadDeviceQR" class="btn btn-primary">
                  다운로드
                </button>
                <button @click="printDeviceQR" class="btn btn-secondary">
                  인쇄
                </button>
              </div>
            </div>
            <div v-else class="text-center py-12 bg-gray-50 rounded-lg">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
              </svg>
              <p class="text-gray-500 mt-2">QR 코드가 여기에 표시됩니다</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Employee QR Generation -->
    <div v-if="selectedType === 'employee'" class="space-y-6">
      <!-- Employee Selection -->
      <div class="bg-white rounded-lg border p-6">
        <h3 class="text-lg font-semibold mb-4">직원 선택</h3>
        
        <!-- Search -->
        <div class="mb-4">
          <input
            v-model="employeeSearchQuery"
            type="text"
            placeholder="직원명, 부서, 직급으로 검색..."
            class="form-input"
          />
        </div>

        <!-- Employee List -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 max-h-96 overflow-y-auto">
          <div 
            v-for="employee in filteredEmployees" 
            :key="employee.id"
            @click="selectedEmployee = employee"
            :class="[
              'p-4 border rounded-lg cursor-pointer transition-colors',
              selectedEmployee?.id === employee.id 
                ? 'border-primary bg-primary bg-opacity-10' 
                : 'border-gray-200 hover:border-gray-300'
            ]"
          >
            <div class="flex items-center justify-between mb-2">
              <div class="w-10 h-10 bg-primary rounded-full flex items-center justify-center text-white font-medium">
                {{ employee.name.charAt(0) }}
              </div>
              <span v-if="selectedEmployee?.id === employee.id" class="text-primary">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
              </span>
            </div>
            <h4 class="font-medium text-gray-900">{{ employee.name }}</h4>
            <p class="text-sm text-gray-600">{{ employee.department }}</p>
            <p class="text-xs text-gray-500">{{ employee.position }}</p>
          </div>
        </div>

        <div v-if="filteredEmployees.length === 0" class="text-center py-8 text-gray-500">
          검색 결과가 없습니다
        </div>
      </div>

      <!-- Generate Employee QR -->
      <div v-if="selectedEmployee" class="bg-white rounded-lg border p-6">
        <h3 class="text-lg font-semibold mb-4">QR 코드 생성</h3>
        <div class="flex flex-col md:flex-row gap-6">
          <!-- QR Options -->
          <div class="flex-1">
            <div class="space-y-4">
              <div>
                <label class="form-label">QR 코드 형식</label>
                <select v-model="employeeQRFormat" class="form-input">
                  <option value="png">PNG 이미지</option>
                  <option value="svg">SVG 벡터</option>
                </select>
              </div>
              
              <div>
                <label class="form-label">크기</label>
                <select v-model="employeeQRSize" class="form-input">
                  <option value="200">작음 (200px)</option>
                  <option value="300">중간 (300px)</option>
                  <option value="400">큼 (400px)</option>
                </select>
              </div>

              <button 
                @click="generateEmployeeQR"
                :disabled="employeeQRLoading"
                class="btn btn-primary w-full"
              >
                <svg v-if="employeeQRLoading" class="animate-spin w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                </svg>
                {{ employeeQRLoading ? '생성 중...' : 'QR 코드 생성' }}
              </button>
            </div>
          </div>

          <!-- QR Preview -->
          <div class="flex-1">
            <div v-if="employeeQRUrl" class="text-center">
              <h4 class="font-medium mb-4">QR 코드 미리보기</h4>
              <div class="inline-block p-4 bg-gray-50 rounded-lg">
                <img :src="employeeQRUrl" alt="Employee QR Code" class="max-w-full" />
              </div>
              <div class="mt-4 space-x-3">
                <button @click="downloadEmployeeQR" class="btn btn-primary">
                  다운로드
                </button>
                <button @click="printEmployeeQR" class="btn btn-secondary">
                  인쇄
                </button>
              </div>
            </div>
            <div v-else class="text-center py-12 bg-gray-50 rounded-lg">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
              </svg>
              <p class="text-gray-500 mt-2">QR 코드가 여기에 표시됩니다</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Bulk QR Generation -->
    <div class="bg-white rounded-lg border p-6">
      <h3 class="text-lg font-semibold mb-4">일괄 QR 코드 생성</h3>
      <p class="text-gray-600 mb-4">여러 장비의 QR 코드를 한 번에 생성할 수 있습니다.</p>
      
      <div class="flex flex-col md:flex-row gap-4">
        <div class="flex-1">
          <label class="form-label">생성할 장비 수</label>
          <select v-model="bulkDeviceCount" class="form-input">
            <option value="5">최근 5개</option>
            <option value="10">최근 10개</option>
            <option value="20">최근 20개</option>
            <option value="all">모든 장비</option>
          </select>
        </div>
        <div class="flex-1">
          <label class="form-label">형식</label>
          <select v-model="bulkQRFormat" class="form-input">
            <option value="png">PNG 이미지</option>
            <option value="json">JSON 데이터</option>
          </select>
        </div>
        <div class="flex-1 flex items-end">
          <button 
            @click="generateBulkQR"
            :disabled="bulkQRLoading"
            class="btn btn-primary w-full"
          >
            {{ bulkQRLoading ? '생성 중...' : '일괄 생성' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Device, Employee } from '~/types'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const api = useApi()

// State
const selectedType = ref<'device' | 'employee'>('device')
const devices = ref<Device[]>([])
const employees = ref<Employee[]>([])
const loading = ref(true)

// Device QR state
const selectedDevice = ref<Device | null>(null)
const deviceSearchQuery = ref('')
const deviceQRFormat = ref<'png' | 'svg'>('png')
const deviceQRSize = ref('300')
const deviceQRUrl = ref<string | null>(null)
const deviceQRLoading = ref(false)

// Employee QR state
const selectedEmployee = ref<Employee | null>(null)
const employeeSearchQuery = ref('')
const employeeQRFormat = ref<'png' | 'svg'>('png')
const employeeQRSize = ref('300')
const employeeQRUrl = ref<string | null>(null)
const employeeQRLoading = ref(false)

// Bulk QR state
const bulkDeviceCount = ref('10')
const bulkQRFormat = ref<'png' | 'json'>('png')
const bulkQRLoading = ref(false)

// Computed
const filteredDevices = computed(() => {
  if (!deviceSearchQuery.value) return devices.value
  
  const query = deviceSearchQuery.value.toLowerCase()
  return devices.value.filter(device =>
    device.asset_number.toLowerCase().includes(query) ||
    device.manufacturer?.toLowerCase().includes(query) ||
    device.model_name?.toLowerCase().includes(query)
  )
})

const filteredEmployees = computed(() => {
  if (!employeeSearchQuery.value) return employees.value
  
  const query = employeeSearchQuery.value.toLowerCase()
  return employees.value.filter(employee =>
    employee.name.toLowerCase().includes(query) ||
    employee.department.toLowerCase().includes(query) ||
    employee.position.toLowerCase().includes(query)
  )
})

// Methods
const loadData = async () => {
  try {
    loading.value = true
    const [devicesResponse, employeesResponse] = await Promise.all([
      api.devices.getAll(),
      api.employees.getAll()
    ])
    devices.value = devicesResponse.devices
    employees.value = employeesResponse.employees
  } catch (error) {
    console.error('Failed to load data:', error)
  } finally {
    loading.value = false
  }
}

const generateDeviceQR = async () => {
  if (!selectedDevice.value) return
  
  try {
    deviceQRLoading.value = true
    const blob = await api.qr.getDeviceQR(
      selectedDevice.value.id, 
      deviceQRFormat.value
    ) as Blob
    
    deviceQRUrl.value = URL.createObjectURL(blob)
  } catch (error) {
    console.error('Failed to generate device QR:', error)
  } finally {
    deviceQRLoading.value = false
  }
}

const generateEmployeeQR = async () => {
  if (!selectedEmployee.value) return
  
  try {
    employeeQRLoading.value = true
    const blob = await api.qr.getEmployeeQR(
      selectedEmployee.value.id, 
      employeeQRFormat.value
    ) as Blob
    
    employeeQRUrl.value = URL.createObjectURL(blob)
  } catch (error) {
    console.error('Failed to generate employee QR:', error)
  } finally {
    employeeQRLoading.value = false
  }
}

const downloadDeviceQR = () => {
  if (deviceQRUrl.value && selectedDevice.value) {
    const a = document.createElement('a')
    a.href = deviceQRUrl.value
    a.download = `qr_device_${selectedDevice.value.asset_number}.${deviceQRFormat.value}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  }
}

const downloadEmployeeQR = () => {
  if (employeeQRUrl.value && selectedEmployee.value) {
    const a = document.createElement('a')
    a.href = employeeQRUrl.value
    a.download = `qr_employee_${selectedEmployee.value.name}.${employeeQRFormat.value}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  }
}

const printDeviceQR = () => {
  if (deviceQRUrl.value) {
    const printWindow = window.open('', '', 'width=400,height=400')
    if (printWindow) {
      printWindow.document.write(`
        <html>
          <head><title>QR Code - ${selectedDevice.value?.asset_number}</title></head>
          <body style="text-align: center; padding: 20px;">
            <h3>${selectedDevice.value?.asset_number}</h3>
            <img src="${deviceQRUrl.value}" style="max-width: 100%;" />
            <p>담당자: ${selectedDevice.value?.employees?.name}</p>
          </body>
        </html>
      `)
      printWindow.document.close()
      printWindow.print()
    }
  }
}

const printEmployeeQR = () => {
  if (employeeQRUrl.value) {
    const printWindow = window.open('', '', 'width=400,height=400')
    if (printWindow) {
      printWindow.document.write(`
        <html>
          <head><title>QR Code - ${selectedEmployee.value?.name}</title></head>
          <body style="text-align: center; padding: 20px;">
            <h3>${selectedEmployee.value?.name}</h3>
            <img src="${employeeQRUrl.value}" style="max-width: 100%;" />
            <p>${selectedEmployee.value?.department} - ${selectedEmployee.value?.position}</p>
          </body>
        </html>
      `)
      printWindow.document.close()
      printWindow.print()
    }
  }
}

const generateBulkQR = async () => {
  try {
    bulkQRLoading.value = true
    
    let deviceIds: string[]
    if (bulkDeviceCount.value === 'all') {
      deviceIds = devices.value.map(d => d.id)
    } else {
      const count = parseInt(bulkDeviceCount.value)
      deviceIds = devices.value.slice(0, count).map(d => d.id)
    }
    
    const result = await api.qr.bulkDeviceQR(deviceIds, bulkQRFormat.value)
    
    // Download as JSON file
    const blob = new Blob([JSON.stringify(result, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `bulk_qr_codes_${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    
  } catch (error) {
    console.error('Failed to generate bulk QR:', error)
  } finally {
    bulkQRLoading.value = false
  }
}

// Load data on mount
onMounted(() => {
  loadData()
})

// Reset selection when type changes
watch(selectedType, () => {
  selectedDevice.value = null
  selectedEmployee.value = null
  deviceQRUrl.value = null
  employeeQRUrl.value = null
})
</script> 