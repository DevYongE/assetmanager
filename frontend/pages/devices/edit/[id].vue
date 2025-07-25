<template>
  <div class="container py-8">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <div>
          <h1 class="text-3xl font-bold text-gray-900">장비 정보 수정</h1>
          <p class="text-gray-600 mt-2">QR 코드로 스캔된 장비 정보를 수정하세요</p>
        </div>
        <NuxtLink 
          to="/devices"
          class="btn btn-secondary"
        >
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
          </svg>
          목록으로
        </NuxtLink>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-lg p-6 mb-6">
      <div class="flex items-center">
        <svg class="w-6 h-6 text-red-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
        </svg>
        <div>
          <h3 class="text-lg font-semibold text-red-800">오류 발생</h3>
          <p class="text-red-600 mt-1">{{ error }}</p>
        </div>
      </div>
      <div class="mt-4">
        <button @click="loadDevice" class="btn btn-secondary mr-2">
          다시 시도
        </button>
        <NuxtLink to="/devices" class="btn btn-primary">
          장비 목록으로
        </NuxtLink>
      </div>
    </div>

    <!-- Device Edit Form -->
    <div v-else-if="device" class="bg-white rounded-lg border">
      <div class="p-6 border-b">
        <h2 class="text-xl font-semibold text-gray-900">장비 정보 수정</h2>
        <p class="text-gray-600 mt-1">QR 코드: {{ device.asset_number }}</p>
      </div>

      <form @submit.prevent="updateDevice" class="p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Left Column -->
          <div class="space-y-6">
            <!-- 담당자 -->
            <div class="form-group">
              <label class="form-label">담당자</label>
              <select 
                v-model="deviceForm.employee_id"
                required
                class="form-input"
              >
                <option value="">담당자를 선택하세요</option>
                <option 
                  v-for="employee in employees" 
                  :key="employee.id" 
                  :value="employee.id"
                >
                  {{ employee.name }} ({{ employee.department }})
                </option>
              </select>
            </div>

            <!-- 제조사 -->
            <div class="form-group">
              <label class="form-label">제조사</label>
              <input
                v-model="deviceForm.manufacturer"
                type="text"
                class="form-input"
                placeholder="제조사를 입력하세요"
              />
            </div>

            <!-- 시리얼 번호 -->
            <div class="form-group">
              <label class="form-label">시리얼 번호</label>
              <input
                v-model="deviceForm.serial_number"
                type="text"
                class="form-input"
                placeholder="시리얼 번호를 입력하세요"
              />
            </div>

            <!-- 메모리 -->
            <div class="form-group">
              <label class="form-label">메모리</label>
              <input
                v-model="deviceForm.memory"
                type="text"
                class="form-input"
                placeholder="메모리 정보를 입력하세요"
              />
            </div>

            <!-- GPU -->
            <div class="form-group">
              <label class="form-label">GPU</label>
              <input
                v-model="deviceForm.gpu"
                type="text"
                class="form-input"
                placeholder="GPU 정보를 입력하세요"
              />
            </div>

            <!-- 모니터 -->
            <div class="form-group">
              <label class="form-label">모니터</label>
              <input
                v-model="deviceForm.monitor"
                type="text"
                class="form-input"
                placeholder="모니터 정보를 입력하세요"
              />
            </div>
          </div>

          <!-- Right Column -->
          <div class="space-y-6">
            <!-- 자산번호 -->
            <div class="form-group">
              <label class="form-label">자산번호</label>
              <input
                v-model="deviceForm.asset_number"
                type="text"
                required
                class="form-input"
                placeholder="자산번호를 입력하세요"
              />
            </div>

            <!-- 모델명 -->
            <div class="form-group">
              <label class="form-label">모델명</label>
              <input
                v-model="deviceForm.model_name"
                type="text"
                class="form-input"
                placeholder="모델명을 입력하세요"
              />
            </div>

            <!-- CPU -->
            <div class="form-group">
              <label class="form-label">CPU</label>
              <input
                v-model="deviceForm.cpu"
                type="text"
                class="form-input"
                placeholder="CPU 정보를 입력하세요"
              />
            </div>

            <!-- 저장장치 -->
            <div class="form-group">
              <label class="form-label">저장장치</label>
              <input
                v-model="deviceForm.storage"
                type="text"
                class="form-input"
                placeholder="저장장치 정보를 입력하세요"
              />
            </div>

            <!-- 운영체제 -->
            <div class="form-group">
              <label class="form-label">운영체제</label>
              <input
                v-model="deviceForm.os"
                type="text"
                class="form-input"
                placeholder="운영체제를 입력하세요"
              />
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="flex justify-end space-x-3 mt-8 pt-6 border-t">
          <button 
            type="button"
            @click="cancelEdit"
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

    <!-- Success Modal -->
    <div v-if="showSuccessModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <div class="text-center">
          <svg class="w-12 h-12 mx-auto mb-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
          <h3 class="text-lg font-semibold mb-2">저장 완료</h3>
          <p class="text-gray-600 mb-4">장비 정보가 성공적으로 수정되었습니다.</p>
          <div class="space-x-3">
            <button @click="showSuccessModal = false" class="btn btn-secondary">
              닫기
            </button>
            <NuxtLink to="/devices" class="btn btn-primary">
              목록으로
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Device, CreateDeviceData, Employee } from '~/types'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const route = useRoute()
const router = useRouter()
const api = useApi()

// State
const loading = ref(true)
const error = ref<string | null>(null)
const device = ref<Device | null>(null)
const employees = ref<Employee[]>([])
const isSubmitting = ref(false)
const showSuccessModal = ref(false)

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

// Load device and employees
const loadDevice = async () => {
  try {
    loading.value = true
    error.value = null
    
    const deviceId = route.params.id as string
    
    // Load device and employees in parallel
    const [deviceResponse, employeesResponse] = await Promise.all([
      api.devices.getById(deviceId),
      api.employees.getAll()
    ])
    
    device.value = deviceResponse.device
    employees.value = employeesResponse.employees
    
    // Populate form
    Object.assign(deviceForm, {
      employee_id: device.value.employee_id,
      asset_number: device.value.asset_number,
      manufacturer: device.value.manufacturer || '',
      model_name: device.value.model_name || '',
      serial_number: device.value.serial_number || '',
      cpu: device.value.cpu || '',
      memory: device.value.memory || '',
      storage: device.value.storage || '',
      gpu: device.value.gpu || '',
      os: device.value.os || '',
      monitor: device.value.monitor || ''
    })
    
  } catch (err: any) {
    console.error('Load device error:', err)
    error.value = err.message || '장비 정보를 불러올 수 없습니다'
  } finally {
    loading.value = false
  }
}

// Update device
const updateDevice = async () => {
  if (!device.value) return
  
  try {
    isSubmitting.value = true
    
    await api.devices.update(device.value.id, deviceForm)
    
    showSuccessModal.value = true
    
  } catch (err: any) {
    console.error('Update device error:', err)
    error.value = err.message || '장비 정보 수정에 실패했습니다'
  } finally {
    isSubmitting.value = false
  }
}

// Cancel edit
const cancelEdit = () => {
  if (confirm('수정을 취소하시겠습니까? 변경사항이 저장되지 않습니다.')) {
    router.push('/devices')
  }
}

// Load data on mount
onMounted(() => {
  loadDevice()
})
</script> 