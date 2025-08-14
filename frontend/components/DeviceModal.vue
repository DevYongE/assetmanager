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

        <!-- 자산 번호 -->
        <div>
          <label class="form-label">자산 번호 *</label>
          <input 
            v-model="form.asset_number" 
            type="text" 
            required
            placeholder="예: AS-NB-23-01"
            class="form-input"
          />
        </div>

        <!-- 조사일자 -->
        <div>
          <label class="form-label">조사일자</label>
          <input 
            v-model="form.inspection_date" 
            type="date" 
            class="form-input"
          />
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

        <!-- 장비 Type -->
        <div>
          <label class="form-label">장비 Type</label>
          <select v-model="form.device_type" class="form-input">
            <option value="">장비 타입을 선택하세요</option>
            <option value="노트북">노트북</option>
            <option value="데스크톱">데스크톱</option>
            <option value="모니터">모니터</option>
            <option value="프린터">프린터</option>
            <option value="기타">기타</option>
          </select>
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
          <label class="form-label">모니터 크기</label>
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
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="form-label">CPU</label>
            <input 
              v-model="form.cpu" 
              type="text" 
              placeholder="예: Intel(R) Core(TM) i7-8565U CPU @ 1.80 GHz"
              class="form-input"
            />
          </div>
          <div>
            <label class="form-label">메모리</label>
            <input 
              v-model="form.memory" 
              type="text" 
              placeholder="예: 32GB"
              class="form-input"
            />
          </div>
          <div>
            <label class="form-label">하드디스크</label>
            <input 
              v-model="form.storage" 
              type="text" 
              placeholder="예: 500G SSD, 1800GB HDD"
              class="form-input"
            />
          </div>
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
  if (props.device) {
    Object.assign(form, {
      employee_id: props.device.employee_id,
      asset_number: props.device.asset_number,
      inspection_date: props.device.inspection_date || '',
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
  } else {
    Object.assign(form, {
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
  }
}

// Handle submit
const handleSubmit = async () => {
  try {
    isSubmitting.value = true
    
    if (props.device) {
      // 2025-01-27: 실제로 변경된 필드만 백엔드로 전송
      const changedFields = {};
      
      // 각 필드를 비교하여 변경된 것만 추가
      const fieldsToCheck = [
        'employee_id', 'asset_number', 'manufacturer', 'model_name', 
        'serial_number', 'cpu', 'memory', 'storage', 'gpu', 'os', 
        'monitor', 'inspection_date', 'purpose', 'device_type', 
        'monitor_size', 'issue_date'
      ];
      
      fieldsToCheck.forEach(field => {
        const currentValue = form[field];
        const originalValue = props.device[field];
        
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
      await api.devices.create(form)
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