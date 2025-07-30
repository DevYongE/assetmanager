<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<script setup lang="ts">
// 2025-01-27: 배포 환경에서 useAuthStore 오류 해결을 위해 명시적 import 추가
import { useAuthStore } from '~/stores/auth'

// Initialize auth store
onMounted(() => {
  console.log('🔐 [APP] Initializing auth store...')
  const authStore = useAuthStore()
  authStore.initializeAuth()
  console.log('✅ [APP] Auth store initialized')
  console.log('👤 [APP] User authenticated:', authStore.isAuthenticated)
})
</script> 