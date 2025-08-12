<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<script setup lang="ts">
// 2025-01-27: 배포 환경에서 useAuthStore 오류 해결을 위해 명시적 import 추가
import { useAuthStore } from '~/stores/auth'

// Initialize auth store immediately
const authStore = useAuthStore()

// 2025-08-08: 새로고침 시 로그인 화면 문제 해결을 위해 즉시 초기화
if (process.client) {
  console.log('🔐 [APP] Initializing auth store immediately...')
  authStore.initializeAuth()
  console.log('✅ [APP] Auth store initialized')
  console.log('👤 [APP] User authenticated:', authStore.isAuthenticated)
}

// Initialize auth store on mount as backup
onMounted(() => {
  if (!authStore.isAuthenticated) {
    console.log('🔐 [APP] Re-initializing auth store on mount...')
    authStore.initializeAuth()
    console.log('✅ [APP] Auth store re-initialized')
    console.log('👤 [APP] User authenticated:', authStore.isAuthenticated)
  }
})
</script> 