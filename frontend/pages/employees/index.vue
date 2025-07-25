<template>
  <div class="container py-8">
    <!-- Header -->
    <div class="flex justify-between items-center mb-8">
      <div>
        <h1 class="text-3xl font-bold text-gray-900">직원 관리</h1>
        <p class="text-gray-600 mt-2">직원 정보를 관리하고 장비를 할당하세요</p>
      </div>
      <button 
        @click="showAddModal = true"
        class="btn btn-primary"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
        </svg>
        직원 추가
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
      <p class="text-red-600">{{ error }}</p>
      <button @click="loadEmployees" class="btn btn-secondary mt-2">
        다시 시도
      </button>
    </div>

    <!-- Employees List -->
    <div v-else class="space-y-6">
      <!-- Stats -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div class="bg-white rounded-lg border p-4">
          <div class="text-2xl font-bold text-primary">{{ employees.length }}</div>
          <div class="text-sm text-gray-600">총 직원 수</div>
        </div>
        <div class="bg-white rounded-lg border p-4">
          <div class="text-2xl font-bold text-green-600">{{ departmentCount }}</div>
          <div class="text-sm text-gray-600">부서 수</div>
        </div>
        <div class="bg-white rounded-lg border p-4">
          <div class="text-2xl font-bold text-blue-600">{{ recentEmployees }}</div>
          <div class="text-sm text-gray-600">이번 달 신규</div>
        </div>
      </div>

      <!-- Search and Filter -->
      <div class="bg-white rounded-lg border p-4 mb-6">
        <div class="flex flex-col md:flex-row gap-4">
          <div class="flex-1">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="직원 이름, 부서, 직급으로 검색..."
              class="form-input"
            />
          </div>
          <div class="flex gap-2">
            <select v-model="filterDepartment" class="form-input">
              <option value="">모든 부서</option>
              <option v-for="dept in departments" :key="dept" :value="dept">
                {{ dept }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <!-- Employees Grid -->
      <div v-if="filteredEmployees.length" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div 
          v-for="employee in filteredEmployees" 
          :key="employee.id"
          class="bg-white rounded-lg border hover:shadow-lg transition-shadow duration-200"
        >
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <div class="w-12 h-12 bg-primary rounded-full flex items-center justify-center text-white font-bold">
                {{ employee.name.charAt(0) }}
              </div>
              <div class="flex space-x-2">
                <button 
                  @click="editEmployee(employee)"
                  class="text-gray-400 hover:text-primary"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                  </svg>
                </button>
                <button 
                  @click="deleteEmployee(employee)"
                  class="text-gray-400 hover:text-red-500"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                  </svg>
                </button>
              </div>
            </div>
            
            <div>
              <h3 class="text-lg font-semibold text-gray-900 mb-2">{{ employee.name }}</h3>
              <p class="text-gray-600 mb-1">{{ employee.department }}</p>
              <p class="text-gray-500 text-sm">{{ employee.position }}</p>
              <p class="text-gray-400 text-xs mt-2">
                등록일: {{ formatDate(employee.created_at) }}
              </p>
            </div>
            
            <div class="mt-4 pt-4 border-t border-gray-200">
              <NuxtLink 
                :to="`/devices?employee=${employee.id}`"
                class="text-primary hover:text-primary-700 text-sm font-medium"
              >
                장비 보기 →
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="text-center py-12">
        <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"/>
        </svg>
        <h3 class="mt-2 text-sm font-medium text-gray-900">직원이 없습니다</h3>
        <p class="mt-1 text-sm text-gray-500">첫 번째 직원을 추가해보세요.</p>
        <div class="mt-6">
          <button 
            @click="showAddModal = true"
            class="btn btn-primary"
          >
            직원 추가
          </button>
        </div>
      </div>
    </div>

    <!-- Add/Edit Employee Modal -->
    <div v-if="showAddModal || showEditModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <h3 class="text-lg font-semibold mb-4">
          {{ showEditModal ? '직원 정보 수정' : '새 직원 추가' }}
        </h3>
        
        <form @submit.prevent="showEditModal ? updateEmployee() : createEmployee()">
          <div class="space-y-4">
            <div class="form-group">
              <label class="form-label">이름</label>
              <input
                v-model="employeeForm.name"
                type="text"
                required
                class="form-input"
                placeholder="직원 이름을 입력하세요"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">부서</label>
              <input
                v-model="employeeForm.department"
                type="text"
                required
                class="form-input"
                placeholder="부서명을 입력하세요"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">직급</label>
              <input
                v-model="employeeForm.position"
                type="text"
                required
                class="form-input"
                placeholder="직급을 입력하세요"
              />
            </div>
            
            <div class="form-group">
              <label class="form-label">기업명</label>
              <input
                v-model="employeeForm.company_name"
                type="text"
                required
                class="form-input"
                placeholder="기업명을 입력하세요"
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
  </div>
</template>

<script setup lang="ts">
import type { Employee, CreateEmployeeData } from '~/types'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const api = useApi()

// State
const loading = ref(true)
const error = ref<string | null>(null)
const employees = ref<Employee[]>([])
const isSubmitting = ref(false)

// Modal state
const showAddModal = ref(false)
const showEditModal = ref(false)
const editingEmployee = ref<Employee | null>(null)

// Form state
const employeeForm = reactive<CreateEmployeeData>({
  name: '',
  department: '',
  position: '',
  company_name: ''
})

// Search and filter
const searchQuery = ref('')
const filterDepartment = ref('')

// Computed properties
const departments = computed(() => {
  const deps = new Set(employees.value.map(emp => emp.department))
  return Array.from(deps).sort()
})

const departmentCount = computed(() => departments.value.length)

const recentEmployees = computed(() => {
  const now = new Date()
  const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1)
  return employees.value.filter(emp => new Date(emp.created_at) >= thisMonth).length
})

const filteredEmployees = computed(() => {
  let filtered = employees.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(emp => 
      emp.name.toLowerCase().includes(query) ||
      emp.department.toLowerCase().includes(query) ||
      emp.position.toLowerCase().includes(query)
    )
  }

  if (filterDepartment.value) {
    filtered = filtered.filter(emp => emp.department === filterDepartment.value)
  }

  return filtered
})

// Methods
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('ko-KR')
}

const loadEmployees = async () => {
  try {
    loading.value = true
    error.value = null
    const response = await api.employees.getAll()
    employees.value = response.employees
  } catch (err: any) {
    error.value = err.message || '직원 목록을 불러올 수 없습니다'
  } finally {
    loading.value = false
  }
}

const createEmployee = async () => {
  try {
    isSubmitting.value = true
    const response = await api.employees.create(employeeForm)
    employees.value.unshift(response.employee)
    closeModal()
  } catch (err: any) {
    error.value = err.message || '직원 추가에 실패했습니다'
  } finally {
    isSubmitting.value = false
  }
}

const editEmployee = (employee: Employee) => {
  editingEmployee.value = employee
  Object.assign(employeeForm, {
    name: employee.name,
    department: employee.department,
    position: employee.position
  })
  showEditModal.value = true
}

const updateEmployee = async () => {
  if (!editingEmployee.value) return
  
  try {
    isSubmitting.value = true
    const response = await api.employees.update(editingEmployee.value.id, employeeForm)
    const index = employees.value.findIndex(emp => emp.id === editingEmployee.value!.id)
    if (index !== -1) {
      employees.value[index] = response.employee
    }
    closeModal()
  } catch (err: any) {
    error.value = err.message || '직원 정보 수정에 실패했습니다'
  } finally {
    isSubmitting.value = false
  }
}

const deleteEmployee = async (employee: Employee) => {
  if (!confirm(`정말로 ${employee.name} 직원을 삭제하시겠습니까?`)) {
    return
  }
  
  try {
    await api.employees.delete(employee.id)
    employees.value = employees.value.filter(emp => emp.id !== employee.id)
  } catch (err: any) {
    error.value = err.message || '직원 삭제에 실패했습니다'
  }
}

const closeModal = () => {
  showAddModal.value = false
  showEditModal.value = false
  editingEmployee.value = null
  Object.assign(employeeForm, {
    name: '',
    department: '',
    position: '',
    company_name: ''
  })
}

// Load employees on mount
onMounted(() => {
  loadEmployees()
})
</script> 