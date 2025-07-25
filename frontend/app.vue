<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>

<script setup lang="ts">
// Initialize auth store
onMounted(() => {
  console.log('🔐 [APP] Initializing auth store...')
  const authStore = useAuthStore()
  authStore.initializeAuth()
  console.log('✅ [APP] Auth store initialized')
  console.log('👤 [APP] User authenticated:', authStore.isAuthenticated)
})
</script> 