<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Sidebar -->
    <div class="fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg border-r border-gray-200" style="position: fixed !important; z-index: 9999 !important; display: block !important; visibility: visible !important; opacity: 1 !important;">
      <!-- Logo -->
      <div class="flex items-center px-6 py-4 border-b border-gray-200">
        <div class="flex items-center">
          <div class="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center mr-3">
            <span class="text-white font-bold text-lg">Q</span>
          </div>
          <span class="text-xl font-bold text-gray-900">QR 자산관리</span>
        </div>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 px-4 py-6 space-y-2">
        <NuxtLink 
          to="/dashboard" 
          class="flex items-center px-4 py-3 text-gray-700 rounded-lg transition-colors duration-200"
          :class="{ 'bg-blue-50 text-blue-700': $route.path === '/dashboard' }"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
          </svg>
          <span class="font-medium">대시보드</span>
        </NuxtLink>

        <NuxtLink 
          to="/employees" 
          class="flex items-center px-4 py-3 text-gray-700 rounded-lg transition-colors duration-200"
          :class="{ 'bg-blue-50 text-blue-700': $route.path.startsWith('/employees') }"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
          </svg>
          <span class="font-medium">직원 관리</span>
        </NuxtLink>

        <NuxtLink 
          to="/devices" 
          class="flex items-center px-4 py-3 text-gray-700 rounded-lg transition-colors duration-200"
          :class="{ 'bg-blue-50 text-blue-700': $route.path.startsWith('/devices') }"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
          </svg>
          <span class="font-medium">장비 관리</span>
        </NuxtLink>

        <NuxtLink 
          to="/qr-generator" 
          class="flex items-center px-4 py-3 text-gray-700 rounded-lg transition-colors duration-200"
          :class="{ 'bg-blue-50 text-blue-700': $route.path.startsWith('/qr-generator') }"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V6a1 1 0 00-1-1H5a1 1 0 00-1 1v1a1 1 0 001 1zm12 0h2a1 1 0 001-1V6a1 1 0 00-1-1h-2a1 1 0 00-1 1v1a1 1 0 001 1zM5 20h2a1 1 0 001-1v-1a1 1 0 00-1-1H5a1 1 0 00-1 1v1a1 1 0 001 1z"/>
          </svg>
          <span class="font-medium">QR 생성</span>
        </NuxtLink>
      </nav>

      <!-- Settings -->
      <div class="px-4 py-4 border-t border-gray-200">
        <NuxtLink 
          to="/profile" 
          class="flex items-center px-4 py-3 text-gray-700 rounded-lg transition-colors duration-200"
          :class="{ 'bg-blue-50 text-blue-700': $route.path.startsWith('/profile') }"
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
          </svg>
          <span class="font-medium">설정</span>
        </NuxtLink>
      </div>
    </div>
    
    <!-- Main Content -->
    <div class="ml-64">
      <!-- Header -->
      <header class="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-10" style="display: block !important; visibility: visible !important; opacity: 1 !important;">
        <div class="flex items-center justify-between px-6 py-4">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-gray-900">
              {{ getPageTitle() }}
            </h1>
          </div>
          
          <div class="flex items-center space-x-4">
            <!-- Filters -->
            <div class="flex items-center space-x-3">
              <select class="px-3 py-2 bg-gray-100 border border-gray-200 rounded-lg text-sm text-gray-700">
                <option>전체 기간</option>
                <option>이번 달</option>
                <option>이번 주</option>
              </select>
              <select class="px-3 py-2 bg-gray-100 border border-gray-200 rounded-lg text-sm text-gray-700">
                <option>전체 부서</option>
                <option>개발팀</option>
                <option>디자인팀</option>
              </select>
            </div>
            
            <!-- User Menu -->
            <div class="flex items-center space-x-3">
              <button class="relative p-2 text-gray-400 hover:text-gray-600 transition-colors duration-200">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM4.19 4.19A4 4 0 006.73 3H10v5.27A4 4 0 0014.73 9H20v3.27A4 4 0 0020 16.73V21h-3.27A4 4 0 016.73 20H4v-3.27A4 4 0 014.19 4.19z"/>
                </svg>
                <span class="absolute top-0 right-0 w-2 h-2 bg-red-500 rounded-full"></span>
              </button>
              
              <div class="flex items-center space-x-2">
                <div class="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center">
                  <span class="text-white font-medium text-sm">{{ useAuthStore().user?.email?.charAt(0)?.toUpperCase() || 'U' }}</span>
                </div>
                <button 
                  @click="handleLogout"
                  class="text-gray-400 hover:text-red-500 transition-colors duration-200"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </header>
      
      <!-- Page Content -->
      <main class="p-6">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
const router = useRouter()
const route = useRoute()

// Handle logout
const handleLogout = () => {
  const authStore = useAuthStore()
  authStore.logout()
  router.push('/login')
}

// Get page title based on current route
const getPageTitle = () => {
  const routeTitles: Record<string, string> = {
    '/dashboard': '대시보드',
    '/employees': '직원 관리',
    '/devices': '장비 관리',
    '/qr-generator': 'QR 생성',
    '/profile': '설정',
    '/test-layout': '레이아웃 테스트'
  }
  
  return routeTitles[route.path] || 'QR 자산관리'
}

// Redirect if not authenticated
// onMounted(() => {
//   if (!authStore.isAuthenticated) {
//     router.push('/login')
//   }
// })
</script>

<style scoped>
/* 강제로 사이드바와 헤더가 보이도록 스타일 추가 */
.sidebar {
  position: fixed !important;
  z-index: 9999 !important;
  display: block !important;
  visibility: visible !important;
  opacity: 1 !important;
}

.header {
  display: block !important;
  visibility: visible !important;
  opacity: 1 !important;
  position: sticky !important;
  top: 0 !important;
  z-index: 10 !important;
}
</style> 