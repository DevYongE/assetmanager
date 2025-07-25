<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-bold text-gray-900">
          회원가입
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          새 계정을 생성하여 자산 관리를 시작하세요
        </p>
      </div>
      
      <form class="mt-8 space-y-6" @submit.prevent="handleRegister">
        <div class="space-y-4">
          <div class="form-group">
            <label for="email" class="form-label">
              이메일 주소
            </label>
            <input
              id="email"
              v-model="formData.email"
              type="email"
              autocomplete="email"
              required
              class="form-input"
              :class="{ error: formErrors.email }"
              placeholder="이메일을 입력하세요"
            />
            <div v-if="formErrors.email" class="form-error">
              {{ formErrors.email }}
            </div>
          </div>

          <div class="form-group">
            <label for="company_name" class="form-label">
              회사명
            </label>
            <input
              id="company_name"
              v-model="formData.company_name"
              type="text"
              required
              class="form-input"
              :class="{ error: formErrors.company_name }"
              placeholder="회사명을 입력하세요"
            />
            <div v-if="formErrors.company_name" class="form-error">
              {{ formErrors.company_name }}
            </div>
          </div>

          <div class="form-group">
            <label for="password" class="form-label">
              비밀번호
            </label>
            <input
              id="password"
              v-model="formData.password"
              type="password"
              autocomplete="new-password"
              required
              class="form-input"
              :class="{ error: formErrors.password }"
              placeholder="비밀번호를 입력하세요"
            />
            <div v-if="formErrors.password" class="form-error">
              {{ formErrors.password }}
            </div>
          </div>

          <div class="form-group">
            <label for="password_confirm" class="form-label">
              비밀번호 확인
            </label>
            <input
              id="password_confirm"
              v-model="formData.password_confirm"
              type="password"
              required
              class="form-input"
              :class="{ error: formErrors.password_confirm }"
              placeholder="비밀번호를 다시 입력하세요"
            />
            <div v-if="formErrors.password_confirm" class="form-error">
              {{ formErrors.password_confirm }}
            </div>
          </div>
        </div>

        <div v-if="authStore.error" class="p-4 bg-red-50 border border-red-200 rounded-lg">
          <p class="text-sm text-red-600">
            {{ authStore.error }}
          </p>
        </div>

        <div>
          <button
            type="submit"
            :disabled="authStore.loading || !isFormValid"
            class="btn btn-primary w-full"
          >
            <svg v-if="authStore.loading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            {{ authStore.loading ? '가입 중...' : '회원가입' }}
          </button>
        </div>

        <div class="text-center">
          <p class="text-sm text-gray-600">
            이미 계정이 있으신가요?
            <NuxtLink to="/login" class="font-medium text-primary hover:text-primary-700">
              로그인
            </NuxtLink>
          </p>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { RegisterData } from '~/types'

definePageMeta({
  layout: 'simple'
})

const authStore = useAuthStore()
const router = useRouter()

// Form data
const formData = reactive<RegisterData & { password_confirm: string }>({
  email: '',
  company_name: '',
  password: '',
  password_confirm: ''
})

// Form validation
const formErrors = reactive({
  email: '',
  company_name: '',
  password: '',
  password_confirm: ''
})

const isFormValid = computed(() => {
  return (
    formData.email &&
    formData.company_name &&
    formData.password &&
    formData.password_confirm &&
    !formErrors.email &&
    !formErrors.company_name &&
    !formErrors.password &&
    !formErrors.password_confirm
  )
})

// Validate email
watch(() => formData.email, (email) => {
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    formErrors.email = '올바른 이메일 형식을 입력해주세요'
  } else {
    formErrors.email = ''
  }
})

// Validate company name
watch(() => formData.company_name, (company_name) => {
  if (company_name && company_name.length < 2) {
    formErrors.company_name = '회사명은 최소 2자 이상이어야 합니다'
  } else {
    formErrors.company_name = ''
  }
})

// Validate password
watch(() => formData.password, (password) => {
  if (password && password.length < 6) {
    formErrors.password = '비밀번호는 최소 6자 이상이어야 합니다'
  } else {
    formErrors.password = ''
  }
  
  // Re-validate password confirmation
  if (formData.password_confirm && formData.password !== formData.password_confirm) {
    formErrors.password_confirm = '비밀번호가 일치하지 않습니다'
  } else if (formData.password_confirm) {
    formErrors.password_confirm = ''
  }
})

// Validate password confirmation
watch(() => formData.password_confirm, (password_confirm) => {
  if (password_confirm && formData.password !== password_confirm) {
    formErrors.password_confirm = '비밀번호가 일치하지 않습니다'
  } else {
    formErrors.password_confirm = ''
  }
})

// Handle registration
const handleRegister = async () => {
  authStore.clearError()
  
  try {
    const registerData: RegisterData = {
      email: formData.email,
      company_name: formData.company_name,
      password: formData.password
    }
    
    await authStore.register(registerData)
    await router.push('/dashboard')
  } catch (error) {
    // Error is handled by the store
    console.error('Registration failed:', error)
  }
}

// Redirect if already authenticated
onMounted(() => {
  if (authStore.isAuthenticated) {
    router.push('/dashboard')
  }
})
</script> 