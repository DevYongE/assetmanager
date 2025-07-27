<template>
  <div class="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
    <!-- Desktop Header -->
    <div class="hidden md:block bg-white/80 backdrop-blur-sm border-b border-white/20 px-6 py-8">
      <div class="max-w-7xl mx-auto">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center shadow-lg">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
              </svg>
            </div>
            <div>
              <h1 class="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">장비 정보 수정</h1>
              <p class="text-gray-600 mt-2">QR 코드로 스캔된 장비 정보를 수정하세요</p>
            </div>
          </div>
          <NuxtLink 
            to="/devices"
            class="bg-gradient-to-r from-gray-600 to-gray-700 hover:from-gray-700 hover:to-gray-800 text-white font-semibold py-3 px-6 rounded-xl transition-all duration-200 flex items-center shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
          >
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
            </svg>
            목록으로
          </NuxtLink>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 py-6 md:py-8">
      <!-- Loading State -->
      <div v-if="loading" class="flex justify-center items-center py-16">
        <div class="text-center">
          <div class="relative">
            <div class="w-16 h-16 border-4 border-blue-200 rounded-full animate-spin"></div>
            <div class="absolute top-0 left-0 w-16 h-16 border-4 border-transparent border-t-blue-600 rounded-full animate-spin"></div>
          </div>
          <p class="text-gray-600 mt-4 text-lg">장비 정보를 불러오는 중...</p>
        </div>
      </div>

      <!-- Error State -->
      <div v-else-if="error" class="bg-white/80 backdrop-blur-sm border border-red-200 rounded-2xl p-8 mb-6 shadow-xl">
        <div class="flex items-start">
          <div class="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mr-4">
            <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
            </svg>
          </div>
          <div class="flex-1">
            <h3 class="text-xl font-semibold text-red-800 mb-2">오류 발생</h3>
            <p class="text-red-600">{{ error }}</p>
          </div>
        </div>
        <div class="mt-6 flex flex-col sm:flex-row space-y-3 sm:space-y-0 sm:space-x-4">
          <button @click="loadDevice" class="bg-gradient-to-r from-gray-600 to-gray-700 hover:from-gray-700 hover:to-gray-800 text-white font-semibold py-3 px-6 rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl">
            다시 시도
          </button>
          <NuxtLink to="/devices" class="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-semibold py-3 px-6 rounded-xl transition-all duration-200 text-center shadow-lg hover:shadow-xl">
            장비 목록으로
          </NuxtLink>
        </div>
      </div>

      <!-- Device Edit Form -->
      <div v-else-if="device" class="bg-white/80 backdrop-blur-sm rounded-2xl border border-white/20 shadow-2xl overflow-hidden">
        <!-- Form Header -->
        <div class="bg-gradient-to-r from-blue-600 to-purple-600 p-8 text-white">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
              </div>
              <div>
                <h2 class="text-2xl font-bold">장비 정보</h2>
                <p class="text-blue-100 mt-1">QR 코드: {{ device.asset_number }}</p>
              </div>
            </div>
            <div class="hidden md:flex items-center space-x-2">
              <span class="inline-flex items-center px-4 py-2 rounded-full text-sm font-medium bg-white/20 text-white">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
                장비 정보
              </span>
            </div>
          </div>
        </div>

        <!-- Form Content -->
        <form @submit.prevent="updateDevice" class="p-8">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <!-- Left Column -->
            <div class="space-y-6">
              <!-- 담당자 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                  </svg>
                  담당자
                </label>
                <select 
                  v-model="deviceForm.employee_id"
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
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
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                  </svg>
                  제조사
                </label>
                <input
                  v-model="deviceForm.manufacturer"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="제조사를 입력하세요"
                />
              </div>

              <!-- 시리얼 번호 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                  </svg>
                  시리얼 번호
                </label>
                <input
                  v-model="deviceForm.serial_number"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="시리얼 번호를 입력하세요"
                />
              </div>

              <!-- 메모리 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/>
                  </svg>
                  메모리
                </label>
                <input
                  v-model="deviceForm.memory"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="메모리 정보를 입력하세요"
                />
              </div>

              <!-- GPU -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                  GPU
                </label>
                <input
                  v-model="deviceForm.gpu"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="GPU 정보를 입력하세요"
                />
              </div>

              <!-- 모니터 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                  모니터
                </label>
                <input
                  v-model="deviceForm.monitor"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="모니터 정보를 입력하세요"
                />
              </div>
            </div>

            <!-- Right Column -->
            <div class="space-y-6">
              <!-- 자산번호 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/>
                  </svg>
                  자산번호
                </label>
                <input
                  v-model="deviceForm.asset_number"
                  type="text"
                  required
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="자산번호를 입력하세요"
                />
              </div>

              <!-- 모델명 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                  모델명
                </label>
                <input
                  v-model="deviceForm.model_name"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="모델명을 입력하세요"
                />
              </div>

              <!-- CPU -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"/>
                  </svg>
                  CPU
                </label>
                <input
                  v-model="deviceForm.cpu"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="CPU 정보를 입력하세요"
                />
              </div>

              <!-- 저장장치 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"/>
                  </svg>
                  저장장치
                </label>
                <input
                  v-model="deviceForm.storage"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="저장장치 정보를 입력하세요"
                />
              </div>

              <!-- 운영체제 -->
              <div class="form-group">
                <label class="block text-sm font-semibold text-gray-700 mb-3 flex items-center">
                  <svg class="w-4 h-4 mr-2 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                  운영체제
                </label>
                <input
                  v-model="deviceForm.os"
                  type="text"
                  class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-200 bg-white/50 backdrop-blur-sm"
                  placeholder="운영체제를 입력하세요"
                />
              </div>
            </div>
          </div>

          <!-- Desktop Action Buttons -->
          <div class="hidden md:flex justify-end space-x-4 mt-10 pt-8 border-t border-gray-200">
            <button 
              type="button"
              @click="cancelEdit"
              class="bg-gradient-to-r from-gray-600 to-gray-700 hover:from-gray-700 hover:to-gray-800 text-white font-semibold py-3 px-8 rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
            >
              취소
            </button>
            <button 
              type="submit"
              :disabled="isSubmitting"
              class="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 disabled:from-gray-400 disabled:to-gray-500 text-white font-semibold py-3 px-8 rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
            >
              {{ isSubmitting ? '저장 중...' : '저장' }}
            </button>
          </div>

          <!-- Mobile Action Buttons -->
          <div class="md:hidden flex space-x-4 mt-8 pt-6 border-t border-gray-200">
            <button 
              type="button"
              @click="cancelEdit"
              class="flex-1 bg-gradient-to-r from-gray-600 to-gray-700 hover:from-gray-700 hover:to-gray-800 text-white font-semibold py-4 px-6 rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl"
            >
              취소
            </button>
            <button 
              type="submit"
              :disabled="isSubmitting"
              class="flex-1 bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 disabled:from-gray-400 disabled:to-gray-500 text-white font-semibold py-4 px-6 rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl"
            >
              {{ isSubmitting ? '저장 중...' : '저장' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Success Modal -->
    <div v-if="showSuccessModal" class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-2xl p-8 w-full max-w-sm md:max-w-md mx-auto shadow-2xl transform transition-all duration-300 scale-100">
        <div class="text-center">
          <div class="w-16 h-16 bg-gradient-to-br from-green-400 to-green-600 rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg">
            <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
          </div>
          <h3 class="text-2xl font-bold text-gray-900 mb-3">저장 완료!</h3>
          <p class="text-gray-600 mb-8 text-lg">장비 정보가 성공적으로 수정되었습니다.</p>
          <div class="flex flex-col sm:flex-row space-y-3 sm:space-y-0 sm:space-x-4">
            <button @click="showSuccessModal = false" class="bg-gradient-to-r from-gray-600 to-gray-700 hover:from-gray-700 hover:to-gray-800 text-white font-semibold py-3 px-6 rounded-xl transition-all duration-200 shadow-lg hover:shadow-xl">
              닫기
            </button>
            <NuxtLink to="/devices" class="bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white font-semibold py-3 px-6 rounded-xl transition-all duration-200 text-center shadow-lg hover:shadow-xl">
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
  layout: 'simple',
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