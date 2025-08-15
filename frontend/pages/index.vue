<template>
  <div>
    <!-- 리다이렉트 중... -->
  </div>
</template>

<script setup lang="ts">
// 2025-01-27: 인증 상태 확인 후 조건부 리다이렉트
const router = useRouter()
const authStore = useAuthStore()

onMounted(() => {
  // 인증된 사용자는 대시보드로, 그렇지 않으면 로그인 페이지로
  if (authStore.isAuthenticated) {
    router.push('/dashboard')
  } else {
    router.push('/login')
  }
})
</script> 