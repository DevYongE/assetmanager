<template>
  <div style="min-height: 100vh; display: flex; align-items: center; justify-content: center; background-color: #f9fafb; font-family: Arial, sans-serif;">
    <div style="max-width: 28rem; width: 100%; padding: 2rem;">
      <div style="text-align: center; margin-bottom: 2rem;">
        <h2 style="font-size: 2rem; font-weight: bold; color: #111827; margin-bottom: 0.5rem;">
          로그인
        </h2>
        <p style="color: #6b7280; font-size: 1rem;">
          계정에 로그인하여 자산 관리를 시작하세요
        </p>
      </div>
      
      <form @submit.prevent="handleLogin" style="space-y: 1.5rem;">
        <div>
          <label for="email" style="display: block; margin-bottom: 0.5rem; font-weight: 500; color: #374151;">
            이메일 주소
          </label>
          <input
            id="email"
            v-model="formData.email"
            type="email"
            required
            :disabled="loading"
            style="width: 100%; padding: 0.75rem; border: 1px solid #d1d5db; border-radius: 6px; font-size: 1rem;"
            placeholder="이메일을 입력하세요"
          />
        </div>

        <div>
          <label for="password" style="display: block; margin-bottom: 0.5rem; font-weight: 500; color: #374151;">
            비밀번호
          </label>
          <input
            id="password"
            v-model="formData.password"
            type="password"
            required
            :disabled="loading"
            style="width: 100%; padding: 0.75rem; border: 1px solid #d1d5db; border-radius: 6px; font-size: 1rem;"
            placeholder="비밀번호를 입력하세요"
          />
        </div>

        <div v-if="error" style="padding: 1rem; background-color: #fef2f2; border: 1px solid #fecaca; border-radius: 6px; margin-bottom: 1rem;">
          <p style="color: #dc2626; font-size: 0.9rem;">
            {{ error }}
          </p>
        </div>

        <button
          type="submit"
          :disabled="loading"
          style="width: 100%; padding: 0.75rem 1.5rem; background-color: #2563eb; color: white; border: none; border-radius: 6px; font-weight: 500; font-size: 1rem; cursor: pointer; position: relative;"
          :style="{ opacity: loading ? 0.7 : 1, cursor: loading ? 'not-allowed' : 'pointer' }"
        >
          <span v-if="!loading">로그인</span>
          <span v-else style="display: flex; align-items: center; justify-content: center; gap: 0.5rem;">
            <div style="width: 16px; height: 16px; border: 2px solid transparent; border-top: 2px solid white; border-radius: 50%; animation: spin 1s linear infinite;"></div>
            로그인 중...
          </span>
        </button>

        <div style="text-align: center; margin-top: 1.5rem;">
          <p style="color: #6b7280; font-size: 0.9rem;">
            아직 계정이 없으신가요?
            <a href="/register" style="color: #2563eb; text-decoration: underline; font-weight: 500;">
              회원가입
            </a>
          </p>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
// Use auth store for login
const authStore = useAuthStore()
const loading = ref(false)
const error = ref('')

const formData = reactive({
  email: '',
  password: ''
})

const handleLogin = async () => {
  loading.value = true
  error.value = ''
  
  try {
    console.log('🔍 [FRONTEND] Login attempt started')
    console.log('📧 Email:', formData.email)
    console.log('🔑 Password length:', formData.password.length)
    
    // Set timeout for login request (10 seconds)
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => reject(new Error('로그인 요청이 시간 초과되었습니다. 다시 시도해주세요.')), 10000)
    })
    
    // Login with timeout
    const loginResponse = await Promise.race([authStore.login(formData), timeoutPromise])
    
    console.log('✅ [FRONTEND] Login successful!')
    console.log('📦 [FRONTEND] Login response:', loginResponse)
    console.log('👤 [FRONTEND] User from store:', authStore.user)
    console.log('🎫 [FRONTEND] Token from store:', authStore.token)
    console.log('🔐 [FRONTEND] Is authenticated:', authStore.isAuthenticated)
    
    // Wait a bit to ensure store is updated
    await new Promise(resolve => setTimeout(resolve, 100))
    
    console.log('👤 [FRONTEND] User after delay:', authStore.user)
    console.log('🎫 [FRONTEND] Token after delay:', authStore.token)
    
    console.log('🔄 [FRONTEND] Redirecting to dashboard...')
    await navigateTo('/dashboard')
    
  } catch (err: any) {
    console.error('❌ [FRONTEND] Login failed!')
    console.error('🚨 Error details:', err)
    
    if (err.message.includes('시간 초과')) {
      error.value = err.message
    } else if (err.data?.error) {
      error.value = err.data.error
    } else if (err.message) {
      error.value = err.message
    } else {
      error.value = '로그인에 실패했습니다. 다시 시도해주세요.'
    }
  } finally {
    loading.value = false
    console.log('🏁 [FRONTEND] Login process finished')
  }
}
</script>

<style scoped>
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style> 