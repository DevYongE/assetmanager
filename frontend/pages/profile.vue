<template>
  <div class="container py-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-2">프로필 설정</h1>
      <p class="text-gray-600">계정 정보를 관리하고 설정을 변경하세요</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Profile Info -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Basic Information -->
        <div class="bg-white rounded-lg border p-6">
          <h2 class="text-xl font-semibold mb-6">기본 정보</h2>
          
          <form @submit.prevent="updateProfile">
            <div class="space-y-4">
              <div class="form-group">
                <label class="form-label">이메일 주소</label>
                <input
                  v-model="profileForm.email"
                  type="email"
                  class="form-input bg-gray-50"
                  readonly
                />
                <p class="text-sm text-gray-500 mt-1">이메일 주소는 변경할 수 없습니다</p>
              </div>
              
              <div class="form-group">
                <label class="form-label">회사명</label>
                <input
                  v-model="profileForm.company_name"
                  type="text"
                  required
                  class="form-input"
                  placeholder="회사명을 입력하세요"
                />
              </div>
            </div>
            
            <div class="flex justify-end mt-6">
              <button 
                type="submit"
                :disabled="profileLoading"
                class="btn btn-primary"
              >
                {{ profileLoading ? '저장 중...' : '저장' }}
              </button>
            </div>
          </form>
        </div>

        <!-- Password Change -->
        <div class="bg-white rounded-lg border p-6">
          <h2 class="text-xl font-semibold mb-6">비밀번호 변경</h2>
          
          <form @submit.prevent="changePassword">
            <div class="space-y-4">
              <div class="form-group">
                <label class="form-label">현재 비밀번호</label>
                <input
                  v-model="passwordForm.current_password"
                  type="password"
                  required
                  class="form-input"
                  placeholder="현재 비밀번호를 입력하세요"
                />
              </div>
              
              <div class="form-group">
                <label class="form-label">새 비밀번호</label>
                <input
                  v-model="passwordForm.new_password"
                  type="password"
                  required
                  class="form-input"
                  placeholder="새 비밀번호를 입력하세요"
                />
                <p class="text-sm text-gray-500 mt-1">최소 6자 이상 입력해주세요</p>
              </div>
              
              <div class="form-group">
                <label class="form-label">새 비밀번호 확인</label>
                <input
                  v-model="passwordForm.confirm_password"
                  type="password"
                  required
                  class="form-input"
                  :class="{ error: passwordForm.new_password !== passwordForm.confirm_password && passwordForm.confirm_password }"
                  placeholder="새 비밀번호를 다시 입력하세요"
                />
                <div v-if="passwordForm.new_password !== passwordForm.confirm_password && passwordForm.confirm_password" class="form-error">
                  비밀번호가 일치하지 않습니다
                </div>
              </div>
            </div>
            
            <div class="flex justify-end mt-6">
              <button 
                type="submit"
                :disabled="passwordLoading || passwordForm.new_password !== passwordForm.confirm_password"
                class="btn btn-primary"
              >
                {{ passwordLoading ? '변경 중...' : '비밀번호 변경' }}
              </button>
            </div>
          </form>
        </div>

        <!-- Success/Error Messages -->
        <div v-if="successMessage" class="bg-green-50 border border-green-200 rounded-lg p-4">
          <p class="text-green-600">{{ successMessage }}</p>
        </div>
        
        <div v-if="errorMessage" class="bg-red-50 border border-red-200 rounded-lg p-4">
          <p class="text-red-600">{{ errorMessage }}</p>
        </div>
      </div>

      <!-- Account Overview -->
      <div class="space-y-6">
        <!-- Account Stats -->
        <div class="bg-white rounded-lg border p-6">
          <h3 class="text-lg font-semibold mb-4">계정 현황</h3>
          
          <div class="space-y-4">
            <div class="flex items-center justify-between py-2 border-b border-gray-100">
              <span class="text-gray-600">가입일</span>
              <span class="font-medium">{{ formatDate(authStore.user?.created_at) }}</span>
            </div>
            
            <div class="flex items-center justify-between py-2 border-b border-gray-100">
              <span class="text-gray-600">총 직원 수</span>
              <span class="font-medium text-primary">{{ stats.total_employees || 0 }}명</span>
            </div>
            
            <div class="flex items-center justify-between py-2 border-b border-gray-100">
              <span class="text-gray-600">총 장비 수</span>
              <span class="font-medium text-green-600">{{ stats.total_devices || 0 }}대</span>
            </div>
            
            <div class="flex items-center justify-between py-2">
              <span class="text-gray-600">회사명</span>
              <span class="font-medium">{{ authStore.userCompany }}</span>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="bg-white rounded-lg border p-6">
          <h3 class="text-lg font-semibold mb-4">빠른 작업</h3>
          
          <div class="space-y-3">
            <NuxtLink to="/employees" class="block">
              <div class="flex items-center p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <svg class="w-5 h-5 text-blue-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"/>
                </svg>
                <span class="font-medium">직원 관리</span>
              </div>
            </NuxtLink>
            
            <NuxtLink to="/devices" class="block">
              <div class="flex items-center p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <svg class="w-5 h-5 text-green-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
                <span class="font-medium">장비 관리</span>
              </div>
            </NuxtLink>
            
            <NuxtLink to="/qr-generator" class="block">
              <div class="flex items-center p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <svg class="w-5 h-5 text-purple-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
                </svg>
                <span class="font-medium">QR 생성</span>
              </div>
            </NuxtLink>
            
            <NuxtLink to="/dashboard" class="block">
              <div class="flex items-center p-3 rounded-lg hover:bg-gray-50 transition-colors">
                <svg class="w-5 h-5 text-orange-600 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
                </svg>
                <span class="font-medium">대시보드</span>
              </div>
            </NuxtLink>
          </div>
        </div>

        <!-- Account Settings -->
        <div class="bg-white rounded-lg border p-6">
          <h3 class="text-lg font-semibold mb-4">계정 설정</h3>
          
          <div class="space-y-3">
            <div class="flex items-center justify-between">
              <span class="text-gray-600">이메일 알림</span>
              <label class="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" class="sr-only peer" v-model="notifications.email">
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary peer-focus:ring-opacity-25 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
              </label>
            </div>
            
            <div class="flex items-center justify-between">
              <span class="text-gray-600">브라우저 알림</span>
              <label class="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" class="sr-only peer" v-model="notifications.browser">
                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary peer-focus:ring-opacity-25 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
              </label>
            </div>
          </div>
        </div>

        <!-- Danger Zone -->
        <div class="bg-white rounded-lg border border-red-200 p-6">
          <h3 class="text-lg font-semibold text-red-600 mb-4">위험 구역</h3>
          
          <div class="space-y-4">
            <div>
              <h4 class="font-medium text-gray-900 mb-2">계정 삭제</h4>
              <p class="text-sm text-gray-600 mb-3">
                계정을 삭제하면 모든 데이터가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.
              </p>
              <button 
                @click="confirmDeleteAccount"
                class="btn btn-danger text-sm"
              >
                계정 삭제
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { DashboardStats } from '~/types'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const authStore = useAuthStore()
const api = useApi()

// State
const profileLoading = ref(false)
const passwordLoading = ref(false)
const successMessage = ref('')
const errorMessage = ref('')
const stats = ref<DashboardStats>({
  total_employees: 0,
  total_devices: 0,
  company_name: ''
})

// Form data
const profileForm = reactive({
  email: authStore.user?.email || '',
  company_name: authStore.user?.company_name || ''
})

const passwordForm = reactive({
  current_password: '',
  new_password: '',
  confirm_password: ''
})

const notifications = reactive({
  email: true,
  browser: false
})

// Methods
const formatDate = (dateString?: string) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const clearMessages = () => {
  successMessage.value = ''
  errorMessage.value = ''
}

const updateProfile = async () => {
  try {
    profileLoading.value = true
    clearMessages()
    
    await authStore.updateProfile({
      company_name: profileForm.company_name
    })
    
    successMessage.value = '프로필이 성공적으로 업데이트되었습니다.'
  } catch (error: any) {
    errorMessage.value = error.message || '프로필 업데이트에 실패했습니다.'
  } finally {
    profileLoading.value = false
  }
}

const changePassword = async () => {
  if (passwordForm.new_password !== passwordForm.confirm_password) {
    errorMessage.value = '새 비밀번호가 일치하지 않습니다.'
    return
  }
  
  if (passwordForm.new_password.length < 6) {
    errorMessage.value = '비밀번호는 최소 6자 이상이어야 합니다.'
    return
  }
  
  try {
    passwordLoading.value = true
    clearMessages()
    
    await authStore.updateProfile({
      current_password: passwordForm.current_password,
      new_password: passwordForm.new_password
    })
    
    // Clear form
    Object.assign(passwordForm, {
      current_password: '',
      new_password: '',
      confirm_password: ''
    })
    
    successMessage.value = '비밀번호가 성공적으로 변경되었습니다.'
  } catch (error: any) {
    errorMessage.value = error.message || '비밀번호 변경에 실패했습니다.'
  } finally {
    passwordLoading.value = false
  }
}

const confirmDeleteAccount = () => {
  if (confirm('정말로 계정을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
    if (confirm('모든 데이터가 영구적으로 삭제됩니다. 계속하시겠습니까?')) {
      // TODO: Implement account deletion
      alert('계정 삭제 기능은 아직 구현되지 않았습니다.')
    }
  }
}

const loadStats = async () => {
  try {
    const response = await api.users.getStats()
    stats.value = response.stats
  } catch (error) {
    console.error('Failed to load stats:', error)
  }
}

// Load data on mount
onMounted(() => {
  loadStats()
  
  // Update form with current user data
  if (authStore.user) {
    profileForm.email = authStore.user.email
    profileForm.company_name = authStore.user.company_name
  }
})

// Clear messages after 5 seconds
watch([successMessage, errorMessage], () => {
  if (successMessage.value || errorMessage.value) {
    setTimeout(() => {
      clearMessages()
    }, 5000)
  }
})
</script> 