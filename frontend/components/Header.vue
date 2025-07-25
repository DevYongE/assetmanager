<template>
  <header class="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10" style="display: block !important; visibility: visible !important; opacity: 1 !important;">
    <div class="flex items-center justify-between px-6 py-4">
      <div class="flex items-center">
        <h1 class="text-xl font-bold text-gray-900">
          {{ getPageTitle() }}
        </h1>
      </div>
      
      <div class="flex items-center space-x-4">
        <div class="flex items-center space-x-2 text-sm text-gray-600">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
          </svg>
          <span>{{ new Date().toLocaleDateString('ko-KR') }}</span>
        </div>
        
        <!-- Notifications -->
        <button class="relative p-2 text-gray-400 hover:text-gray-600 transition-colors duration-200">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM4.19 4.19A4 4 0 006.73 3H10v5.27A4 4 0 0014.73 9H20v3.27A4 4 0 0020 16.73V21h-3.27A4 4 0 016.73 20H4v-3.27A4 4 0 014.19 4.19z"/>
          </svg>
          <span class="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
        </button>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
const route = useRoute()

// Get page title based on current route
const getPageTitle = () => {
  const routeTitles: Record<string, string> = {
    '/dashboard': '대시보드',
    '/employees': '직원 관리',
    '/devices': '장비 관리',
    '/qr-generator': 'QR 생성',
    '/profile': '프로필 설정'
  }
  
  return routeTitles[route.path] || 'QR 자산관리'
}
</script>

<style scoped>
/* 강제로 헤더가 보이도록 스타일 추가 */
header {
  display: block !important;
  visibility: visible !important;
  opacity: 1 !important;
  position: sticky !important;
  top: 0 !important;
  z-index: 10 !important;
}
</style> 