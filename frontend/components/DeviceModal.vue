<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-2xl p-8 w-full max-w-2xl mx-4 max-h-[90vh] overflow-y-auto">
      <!-- 헤더 -->
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-gray-900">
          {{ device ? '장비 수정' : '장비 추가' }}
        </h2>
        <button 
          @click="$emit('close')"
          class="text-gray-400 hover:text-gray-600 transition-colors"
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
      </div>

      <!-- 폼 -->
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- 직원 선택 -->
        <div>
          <label class="form-label">담당 직원</label>
          <select 
            v-model="form.employee_id" 
            class="form-input"
          >
            <option value="">미할당</option>
            <option 
              v-for="employee in employees" 
              :key="employee.id" 
              :value="employee.id"
            >
              {{ employee.name }} ({{ employee.department }} - {{ employee.position }})
            </option>
          </select>
        </div>

        <!-- 장비 Type -->
        <div>
          <label class="form-label">장비 Type *</label>
          <select v-model="form.device_type" @change="updateAssetNumberPrefix" class="form-input" required>
            <option value="">장비 타입을 선택하세요</option>
            <option value="노트북">노트북</option>
            <option value="데스크탑">데스크탑</option>
            <option value="모니터">모니터</option>
            <option value="프린터">프린터</option>
            <option value="기타">기타</option>
          </select>
        </div>

        <!-- 자산 번호 -->
        <div>
          <label class="form-label">자산 번호 *</label>
                    <div class="flex items-center bg-white border border-gray-300 rounded-lg hover:border-gray-400 focus-within:ring-2 focus-within:ring-blue-500 focus-within:border-blue-500 shadow-sm hover:shadow-md transition-all duration-200">
            <span 
              class="inline-flex items-center px-4 py-3 text-sm font-semibold rounded-l-lg border-r transition-colors duration-200"
              :class="assetNumberPrefix === 'AS-' ? 
                'text-gray-500 bg-gray-100 border-gray-200' : 
                'text-blue-700 bg-gradient-to-r from-blue-50 to-blue-100 border-blue-200'"
            >
              <svg class="w-4 h-4 mr-2 transition-colors duration-200" 
                   :class="assetNumberPrefix === 'AS-' ? 'text-gray-400' : 'text-blue-600'" 
                   fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M17.707 9.293a1 1 0 010 1.414l-7 7a1 1 0 01-1.414 0l-7-7A.997.997 0 012 10V5a3 3 0 013-3h5c.256 0 .512.098.707.293l7 7zM5 6a1 1 0 100 2 1 1 0 000-2z" clip-rule="evenodd" />
              </svg>
              {{ assetNumberPrefix }}
            </span>
            <input 
              v-model="assetNumberSuffix" 
              type="text" 
              placeholder="001"
              class="flex-1 px-4 py-3 text-base border-0 bg-transparent focus:outline-none focus:ring-0 rounded-r-lg placeholder-gray-400"
              required
              @input="updateFullAssetNumber"
            />
          </div>
          <p class="mt-1 text-xs text-gray-500">
            <span class="inline-flex items-center">
              <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
              </svg>
              장비 타입을 선택하면 자동으로 PREFIX가 설정됩니다
            </span>
          </p>
        </div>



        <!-- 용도 -->
        <div>
          <label class="form-label">용도</label>
          <!-- 2025-01-27: 용도 필드를 select에서 input으로 변경하여 자유 입력 가능하도록 수정 -->
          <input 
            v-model="form.purpose" 
            type="text" 
            placeholder="예: 업무용, 개발용, 디자인용 등"
            class="form-input"
          />
        </div>



        <!-- 제조사 -->
        <div>
          <label class="form-label">제조사</label>
          <input 
            v-model="form.manufacturer" 
            type="text" 
            placeholder="예: HP, Lenovo, 삼성"
            class="form-input"
          />
        </div>

        <!-- 모델명 -->
        <div>
          <label class="form-label">모델명</label>
          <input 
            v-model="form.model_name" 
            type="text" 
            placeholder="예: HP ProBook 450 G6"
            class="form-input"
          />
        </div>

        <!-- 시리얼 번호 -->
        <div>
          <label class="form-label">시리얼 번호</label>
          <input 
            v-model="form.serial_number" 
            type="text" 
            placeholder="예: SCD85185FP"
            class="form-input"
          />
        </div>

        <!-- 모니터 크기 -->
        <div>
          <label class="form-label">노트북 모니터 크기</label>
          <select v-model="form.monitor_size" class="form-input">
            <option value="">모니터 크기를 선택하세요</option>
            <option value="13인치">13인치</option>
            <option value="14인치">14인치</option>
            <option value="15인치">15인치</option>
            <option value="16인치">16인치</option>
            <option value="17인치">17인치</option>
            <option value="기타">기타</option>
          </select>
        </div>

        <!-- 지급일자 -->
        <div>
          <label class="form-label">지급일자</label>
          <input 
            v-model="form.issue_date" 
            type="date" 
            class="form-input"
          />
        </div>

        <!-- 사양 정보 -->
         <div class="space-y-4">
           <!-- CPU -->
          <div>
            <label class="form-label">CPU</label>
            <input 
              v-model="form.cpu" 
              type="text" 
              placeholder="예: Intel(R) Core(TM) i7-8565U CPU @ 1.80 GHz"
              class="form-input"
            />
          </div>
           
                     <!-- 메모리 -->
          <div>
            <label class="form-label">메모리</label>
            <div class="space-y-3">
              <div v-for="(memory, index) in memoryDevices" :key="index" class="flex gap-2 items-center">
                <div class="relative flex-[3]">
            <input 
                    v-model="memory.capacity" 
                    type="number" 
                    min="1"
                    max="9999"
                    step="1"
                    placeholder="용량 입력"
                    class="form-input pr-16 h-12 text-base w-full"
                  />
                  <div class="absolute right-2 top-1/2 transform -translate-y-1/2 flex flex-col">
                    <button 
                      type="button"
                      @click="adjustMemoryCapacity(index, 1)"
                      class="w-6 h-4 text-gray-500 hover:text-blue-600 text-sm leading-none flex items-center justify-center hover:bg-gray-100 rounded transition-all"
                    >
                      ▲
                    </button>
                    <button 
                      type="button"
                      @click="adjustMemoryCapacity(index, -1)"
                      class="w-6 h-4 text-gray-500 hover:text-blue-600 text-sm leading-none flex items-center justify-center hover:bg-gray-100 rounded transition-all"
                    >
                      ▼
                    </button>
                  </div>
                </div>
                <select v-model="memory.unit" class="form-input flex-[1] h-12 text-base min-w-[80px]">
                  <option value="MB">MB</option>
                  <option value="GB">GB</option>
                  <option value="TB">TB</option>
                </select>
                <button 
                  type="button"
                  @click="removeMemoryDevice(index)"
                  class="px-4 h-12 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm font-medium"
                  v-if="memoryDevices.length > 1"
                >
                  삭제
                </button>
              </div>
              <button 
                type="button"
                @click="addMemoryDevice"
                class="w-full py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm font-medium flex items-center justify-center gap-2"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 5V19M5 12H19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                메모리 추가
              </button>
            </div>
          </div>
           
                       <!-- 하드디스크 -->
          <div>
            <label class="form-label">하드디스크</label>
              <div class="space-y-3">
                                 <div v-for="(storage, index) in storageDevices" :key="index" class="flex gap-2 items-center">
                  <select v-model="storage.type" class="form-input flex-[1] h-12 text-base min-w-[80px]">
                    <option value="HDD">HDD</option>
                    <option value="SSD">SSD</option>
                  </select>
                  <div class="relative flex-[3]">
            <input 
                      v-model="storage.capacity" 
                      type="number" 
                      min="1"
                      max="9999"
                      step="1"
                      placeholder="용량 입력"
                      class="form-input pr-16 h-12 text-base w-full"
                    />
                    <div class="absolute right-2 top-1/2 transform -translate-y-1/2 flex flex-col">
                      <button 
                        type="button"
                        @click="adjustStorageCapacity(index, 1)"
                        class="w-6 h-4 text-gray-500 hover:text-blue-600 text-sm leading-none flex items-center justify-center hover:bg-gray-100 rounded transition-all"
                      >
                        ▲
                      </button>
                      <button 
                        type="button"
                        @click="adjustStorageCapacity(index, -1)"
                        class="w-6 h-4 text-gray-500 hover:text-blue-600 text-sm leading-none flex items-center justify-center hover:bg-gray-100 rounded transition-all"
                      >
                        ▼
                      </button>
                    </div>
                  </div>
                  <select v-model="storage.unit" class="form-input flex-[1] h-12 text-base min-w-[80px]">
                    <option value="MB">MB</option>
                    <option value="GB">GB</option>
                    <option value="TB">TB</option>
                  </select>
                  <button 
                    type="button"
                    @click="removeStorageDevice(index)"
                    class="px-4 h-12 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm font-medium"
                    v-if="storageDevices.length > 1"
                  >
                    삭제
                  </button>
                 </div>
                               <button 
                  type="button"
                  @click="addStorageDevice"
                  class="w-full py-3 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors text-sm font-medium flex items-center justify-center gap-2"
                >
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 5V19M5 12H19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  저장장치 추가
                </button>
             </div>
          </div>
           
           <!-- 그래픽카드 -->
          <div>
            <label class="form-label">그래픽카드</label>
            <input 
              v-model="form.gpu" 
              type="text" 
              placeholder="예: NVIDIA GeForce MX130"
              class="form-input"
            />
          </div>
        </div>

        <!-- 운영체제 -->
        <div>
          <label class="form-label">운영체제</label>
          <select v-model="form.os" class="form-input">
            <option value="">운영체제를 선택하세요</option>
            <option value="Windows 10 Home">Windows 10 Home</option>
            <option value="Windows 10 Pro">Windows 10 Pro</option>
            <option value="Windows 11 Home">Windows 11 Home</option>
            <option value="Windows 11 Pro">Windows 11 Pro</option>
            <option value="macOS">macOS</option>
            <option value="Linux">Linux</option>
            <option value="기타">기타</option>
          </select>
        </div>

        <!-- 버튼 -->
        <div class="flex gap-4 pt-6">
          <button 
            type="button"
            @click="$emit('close')"
            class="btn-secondary flex-1"
          >
            취소
          </button>
          <button 
            type="submit"
            :disabled="isSubmitting"
            class="btn-gradient flex-1"
          >
            <svg v-if="isSubmitting" class="animate-spin w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
            </svg>
            {{ isSubmitting ? '저장 중...' : (device ? '수정' : '추가') }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Device, CreateDeviceData, Employee } from '~/types'

interface Props {
  device?: Device | null
}

interface Emits {
  (e: 'close'): void
  (e: 'saved'): void
  (e: 'device-updated', device: any): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const api = useApi()

// State
const isSubmitting = ref(false)
const employees = ref<Employee[]>([])

// Form data
const form = reactive<CreateDeviceData>({
  employee_id: '',
  asset_number: '',
  inspection_date: '',
  purpose: '',
  device_type: '',
  manufacturer: '',
  model_name: '',
  serial_number: '',
  monitor_size: '',
  issue_date: '',
  cpu: '',
  memory: '',
  storage: '',
  gpu: '',
  os: '',
  monitor: ''
})

// 2025-01-27: 메모리 관리를 위한 반응형 배열 추가
const memoryDevices = ref([
  { capacity: '', unit: 'GB' }
])

// 2025-01-27: 저장장치 관리를 위한 반응형 배열 추가
const storageDevices = ref([
  { type: 'SSD', capacity: '', unit: 'GB' }
])

// 2025-01-27: 자산번호 PREFIX 관리
const assetNumberPrefix = ref('AS-')
const assetNumberSuffix = ref('')

// 2025-01-27: 저장장치 추가 함수
const addStorageDevice = () => {
  storageDevices.value.push({ type: 'SSD', capacity: '', unit: 'GB' })
}

// 2025-01-27: 메모리 추가 함수
const addMemoryDevice = () => {
  memoryDevices.value.push({ capacity: '', unit: 'GB' })
}

// 2025-01-27: 메모리 삭제 함수
const removeMemoryDevice = (index: number) => {
  if (memoryDevices.value.length > 1) {
    memoryDevices.value.splice(index, 1)
  }
}

// 2025-01-27: 저장장치 삭제 함수
const removeStorageDevice = (index: number) => {
  if (storageDevices.value.length > 1) {
    storageDevices.value.splice(index, 1)
  }
}

// 2025-01-27: 메모리 데이터를 문자열로 변환하는 함수
const formatMemoryString = () => {
  return memoryDevices.value
    .filter(device => {
      if (!device.capacity) return false
      const capacityStr = String(device.capacity).trim()
      return capacityStr !== '' && capacityStr !== '0'
    })
    .map(device => `${device.capacity}${device.unit}`)
    .join(' / ')
}

// 2025-01-27: 저장장치 데이터를 문자열로 변환하는 함수
const formatStorageString = () => {
  return storageDevices.value
    .filter(device => {
      if (!device.capacity) return false
      const capacityStr = String(device.capacity).trim()
      return capacityStr !== '' && capacityStr !== '0'
    })
    .map(device => `${device.type} ${device.capacity}${device.unit}`)
    .join(' / ')
}

// 2025-01-27: 기존 메모리 문자열을 파싱하는 함수
const parseMemoryString = (memoryString: string) => {
  if (!memoryString) {
    memoryDevices.value = [{ capacity: '', unit: 'GB' }]
    return
  }
  
  // "/" 또는 "," 구분자로 분리 (기존 데이터 호환성 유지)
  const devices = memoryString.split(/[\/,]/).map(device => device.trim())
  memoryDevices.value = devices.map(device => {
    const match = device.match(/^(\d+(?:\.\d+)?)\s*(MB|GB|TB)$/i)
    if (match && match[1] && match[2]) {
      return {
        capacity: match[1],
        unit: match[2].toUpperCase()
      }
    }
    return { capacity: '', unit: 'GB' }
  })
  
  if (memoryDevices.value.length === 0) {
    memoryDevices.value = [{ capacity: '', unit: 'GB' }]
  }
}

// 2025-01-27: 기존 저장장치 문자열을 파싱하는 함수
const parseStorageString = (storageString: string) => {
  if (!storageString) {
    storageDevices.value = [{ type: 'SSD', capacity: '', unit: 'GB' }]
    return
  }
  
  // "/" 또는 "," 구분자로 분리 (기존 데이터 호환성 유지)
  const devices = storageString.split(/[\/,]/).map(device => device.trim())
  storageDevices.value = devices.map(device => {
    const match = device.match(/^(HDD|SSD)\s*(\d+(?:\.\d+)?)\s*(MB|GB|TB)$/i)
    if (match && match[1] && match[2] && match[3]) {
      return {
        type: match[1].toUpperCase(),
        capacity: match[2],
        unit: match[3].toUpperCase()
      }
    }
    return { type: 'SSD', capacity: '', unit: 'GB' }
  })
  
  if (storageDevices.value.length === 0) {
    storageDevices.value = [{ type: 'SSD', capacity: '', unit: 'GB' }]
  }
}

// 2025-01-27: 메모리 용량 조정 함수
const adjustMemoryCapacity = (index: number, delta: number) => {
  const memory = memoryDevices.value[index]
  if (memory) {
    const currentValue = Number(memory.capacity) || 0
    const newValue = Math.max(1, Math.min(9999, currentValue + delta))
    memory.capacity = newValue.toString()
  }
}

// 2025-01-27: 저장장치 용량 조정 함수
const adjustStorageCapacity = (index: number, delta: number) => {
  const storage = storageDevices.value[index]
  if (storage) {
    const currentValue = Number(storage.capacity) || 0
    const newValue = Math.max(1, Math.min(9999, currentValue + delta))
    storage.capacity = newValue.toString()
  }
}

// 2025-01-27: 장비 타입에 따른 자산번호 PREFIX 업데이트
const updateAssetNumberPrefix = () => {
  const deviceType = form.device_type
  switch (deviceType) {
    case '노트북':
      assetNumberPrefix.value = 'AS-NB-'
      break
    case '데스크탑':
      assetNumberPrefix.value = 'AS-PC-'
      break
    case '모니터':
      assetNumberPrefix.value = 'AS-MT-'
      break
    case '프린터':
    case '기타':
      assetNumberPrefix.value = 'AS-ETC-'
      break
    default:
      assetNumberPrefix.value = 'AS-'
  }
  updateFullAssetNumber()
}

// 2025-01-27: 전체 자산번호 업데이트
const updateFullAssetNumber = () => {
  form.asset_number = assetNumberPrefix.value + assetNumberSuffix.value
}

// 2025-01-27: 기존 자산번호를 PREFIX와 SUFFIX로 분리
const parseAssetNumber = (assetNumber: string) => {
  if (!assetNumber) {
    assetNumberPrefix.value = 'AS-'
    assetNumberSuffix.value = ''
    return
  }
  
  // PREFIX 패턴 매칭
  const prefixPatterns = [
    { pattern: /^AS-NB-(.*)$/, prefix: 'AS-NB-' },
    { pattern: /^AS-PC-(.*)$/, prefix: 'AS-PC-' },
    { pattern: /^AS-MT-(.*)$/, prefix: 'AS-MT-' },
    { pattern: /^AS-ETC-(.*)$/, prefix: 'AS-ETC-' },
    { pattern: /^AS-(.*)$/, prefix: 'AS-' }
  ]
  
  for (const { pattern, prefix } of prefixPatterns) {
    const match = assetNumber.match(pattern)
    if (match && match[1] !== undefined) {
      assetNumberPrefix.value = prefix
      assetNumberSuffix.value = match[1]
      return
    }
  }
  
  // 매칭되지 않으면 전체를 SUFFIX로 처리
  assetNumberPrefix.value = 'AS-'
  assetNumberSuffix.value = assetNumber
}

// Load employees
const loadEmployees = async () => {
  try {
    const response = await api.employees.getAll()
    employees.value = response.employees
  } catch (error) {
    console.error('Failed to load employees:', error)
  }
}

// Initialize form
const initializeForm = () => {
  // 2025-01-27: 현재 날짜를 YYYY-MM-DD 형식으로 가져오기 (조사일자 자동 설정용)
  const today = new Date().toISOString().split('T')[0]
  
  if (props.device) {
    Object.assign(form, {
      employee_id: props.device.employee_id,
      asset_number: props.device.asset_number,
      inspection_date: today, // 2025-01-27: 수정 시에도 현재 날짜로 자동 설정 (UI에서 제거됨)
      purpose: props.device.purpose || '',
      device_type: props.device.device_type || '',
      manufacturer: props.device.manufacturer || '',
      model_name: props.device.model_name || '',
      serial_number: props.device.serial_number || '',
      monitor_size: props.device.monitor_size || '',
      issue_date: props.device.issue_date || '',
      cpu: props.device.cpu || '',
      memory: props.device.memory || '',
      storage: props.device.storage || '',
      gpu: props.device.gpu || '',
      os: props.device.os || '',
      monitor: props.device.monitor || ''
    })
    
    // 2025-01-27: 기존 메모리 데이터 파싱
    parseMemoryString(props.device.memory || '')
    // 2025-01-27: 기존 저장장치 데이터 파싱
    parseStorageString(props.device.storage || '')
    
    // 2025-01-27: 기존 자산번호에서 PREFIX와 SUFFIX 분리
    parseAssetNumber(props.device.asset_number || '')
  } else {
    Object.assign(form, {
      employee_id: '',
      asset_number: '',
      inspection_date: today, // 2025-01-27: 새 장비 추가 시 현재 날짜로 자동 설정 (UI에서 제거됨)
      purpose: '',
      device_type: '',
      manufacturer: '',
      model_name: '',
      serial_number: '',
      monitor_size: '',
      issue_date: '',
      cpu: '',
      memory: '',
      memory_unit: 'GB', // 2025-01-27: 기본값 설정
      storage: '',
      gpu: '',
      os: '',
      monitor: ''
    })
    
    // 2025-01-27: 새 장비 추가 시 기본 저장장치 설정
    storageDevices.value = [{ type: 'SSD', capacity: '', unit: 'GB' }]
  }
}

// Handle submit
const handleSubmit = async () => {
  try {
    isSubmitting.value = true
    
    // 2025-01-27: 메모리와 저장장치 데이터 포맷팅
    const submitData = {
      ...form,
      memory: formatMemoryString(),
      storage: formatStorageString()
    }
    
    if (props.device) {
      // 2025-01-27: 실제로 변경된 필드만 백엔드로 전송
      const changedFields: Record<string, any> = {};
      
      // 각 필드를 비교하여 변경된 것만 추가
      const fieldsToCheck = [
        'employee_id', 'asset_number', 'manufacturer', 'model_name', 
        'serial_number', 'cpu', 'memory', 'storage', 'gpu', 'os', 
        'monitor', 'inspection_date', 'purpose', 'device_type', 
        'monitor_size', 'issue_date'
      ];
      
      fieldsToCheck.forEach(field => {
        const currentValue = (submitData as any)[field];
        const originalValue = props.device ? (props.device as any)[field] : undefined;
        
        // null과 undefined를 빈 문자열로 통일하여 비교
        const normalizedCurrent = currentValue === null || currentValue === undefined ? '' : currentValue;
        const normalizedOriginal = originalValue === null || originalValue === undefined ? '' : originalValue;
        
        if (normalizedCurrent !== normalizedOriginal) {
          changedFields[field] = currentValue;
        }
      });
      
      console.log('🔍 [DEBUG] Changed fields:', changedFields);
      
      // 변경된 필드가 있으면 업데이트
      if (Object.keys(changedFields).length > 0) {
        const response = await api.devices.update(props.device.asset_number, changedFields)
        emit('device-updated', response.device)
      } else {
        // 변경된 필드가 없으면 그냥 닫기
        emit('close')
      }
    } else {
      await api.devices.create(submitData)
      emit('saved')
    }
  } catch (error: any) {
    console.error('Failed to save device:', error)
    alert(error.message || '장비 저장에 실패했습니다')
  } finally {
    isSubmitting.value = false
  }
}

// Initialize on mount
onMounted(() => {
  loadEmployees()
  initializeForm()
})

// Watch for device changes
watch(() => props.device, () => {
  initializeForm()
})
</script>

<style scoped>
.form-label {
  display: block;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
  font-size: 14px;
}

.form-input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  font-size: 14px;
  transition: all 0.3s ease;
  background: #f9fafb;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  background: white;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* 2025-01-27: 숫자 입력 필드 스타일 개선 */
.form-input[type="number"] {
  -moz-appearance: textfield !important;
  appearance: textfield !important;
  /* 모든 브라우저에서 스피너 완전 제거 */
}

/* Webkit 브라우저 (Chrome, Safari, Edge) 스피너 제거 */
.form-input[type="number"]::-webkit-outer-spin-button,
.form-input[type="number"]::-webkit-inner-spin-button {
  -webkit-appearance: none !important;
  appearance: none !important;
  margin: 0 !important;
  display: none !important;
  opacity: 0 !important;
  pointer-events: none !important;
}

/* Firefox에서 스피너 완전 제거 */
.form-input[type="number"]::-moz-number-spin-box {
  display: none !important;
}

/* IE/Edge에서 스피너 제거 */
.form-input[type="number"]::-ms-clear,
.form-input[type="number"]::-ms-expand {
  display: none !important;
}

/* 커스텀 스피너 버튼 스타일 */
.form-input[type="number"] + div button {
  transition: all 0.2s ease;
}

.form-input[type="number"] + div button:hover {
  color: #667eea;
  transform: scale(1.1);
}

.btn-secondary {
  padding: 12px 24px;
  background: #f3f4f6;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  color: #374151;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background: #e5e7eb;
  border-color: #d1d5db;
}

.btn-gradient {
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-gradient:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.btn-gradient:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}
</style> 