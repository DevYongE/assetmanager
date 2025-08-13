<template>
  <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-2xl p-8 w-full max-w-lg mx-4">
      <!-- 헤더 -->
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-2xl font-bold text-gray-900">
          {{ employee ? '직원 수정' : '직원 추가' }}
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
        <!-- 이름 -->
        <div>
          <label class="form-label">이름 *</label>
          <input 
            v-model="form.name" 
            type="text" 
            required
            placeholder="직원 이름을 입력하세요"
            class="form-input"
          />
        </div>

        <!-- 부서 -->
        <div>
          <label class="form-label">부서 *</label>
          <input 
            v-model="form.department" 
            type="text" 
            required
            placeholder="예: 개발팀, 인사팀, 영업팀"
            class="form-input"
          />
        </div>

        <!-- 직급 -->
        <div>
          <label class="form-label">직급 *</label>
          <input 
            v-model="form.position" 
            type="text" 
            required
            placeholder="예: 사원, 대리, 과장, 차장"
            class="form-input"
          />
        </div>

        <!-- 2025-01-27: 이메일 필드 추가 -->
        <div>
          <label class="form-label">이메일</label>
          <input 
            v-model="form.email" 
            type="email" 
            placeholder="예: employee@company.com"
            class="form-input"
          />
        </div>

        <!-- 회사명 -->
        <div>
          <label class="form-label">회사명 *</label>
          <input 
            v-model="form.company_name" 
            type="text" 
            required
            placeholder="회사명을 입력하세요"
            class="form-input"
          />
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
            {{ isSubmitting ? '저장 중...' : (employee ? '수정' : '추가') }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Employee, CreateEmployeeData } from '~/types'

interface Props {
  employee?: Employee | null
}

interface Emits {
  (e: 'close'): void
  (e: 'saved'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const api = useApi()

// State
const isSubmitting = ref(false)

// Form data
const form = reactive<CreateEmployeeData>({
  name: '',
  department: '',
  position: '',
  company_name: '',
  email: ''
})

// Initialize form
const initializeForm = () => {
  if (props.employee) {
    Object.assign(form, {
      name: props.employee.name,
      department: props.employee.department,
      position: props.employee.position,
      company_name: props.employee.company_name,
      email: props.employee.email || '' // 2025-01-27: 이메일 필드 추가
    })
  } else {
    Object.assign(form, {
      name: '',
      department: '',
      position: '',
      company_name: '',
      email: '' // 2025-01-27: 이메일 필드 추가
    })
  }
}

// Handle submit
const handleSubmit = async () => {
  console.log('🔍 [EMPLOYEE MODAL] handleSubmit called')
  console.log('📝 [EMPLOYEE MODAL] Form data:', form)
  console.log('👤 [EMPLOYEE MODAL] Is edit mode:', !!props.employee)
  
  try {
    isSubmitting.value = true
    
    if (props.employee) {
      console.log('📝 [EMPLOYEE MODAL] Updating employee:', props.employee.id)
      await api.employees.update(props.employee.id, form)
    } else {
      console.log('➕ [EMPLOYEE MODAL] Creating new employee')
      const result = await api.employees.create(form)
      console.log('📝 [EMPLOYEE MODAL] API response:', result)
    }
    
    console.log('✅ [EMPLOYEE MODAL] Employee saved successfully')
    emit('saved')
  } catch (error: any) {
    console.error('❌ [EMPLOYEE MODAL] Failed to save employee:', error)
    alert(error.message || '직원 저장에 실패했습니다')
  } finally {
    isSubmitting.value = false
  }
}

// Initialize on mount
onMounted(() => {
  initializeForm()
})

// Watch for employee changes
watch(() => props.employee, () => {
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