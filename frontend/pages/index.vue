<template>
  <div>
    <!-- 리다이렉트 중... -->
  </div>
</template>

<script setup lang="ts">
// 메인 페이지에서 대시보드로 리다이렉트
const router = useRouter()

onMounted(() => {
  router.push('/dashboard')
})
</script> 