<template>
  <div>
    <!-- Sidebar - 로그인 페이지에서는 숨김 -->
    <div 
      v-if="!isLoginPage"
      :style="{
        position: 'fixed',
        left: 0,
        top: 0,
        width: '260px',
        height: '100vh',
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        zIndex: 9999,
        transform: sidebarOpen ? 'translateX(0)' : 'translateX(-100%)',
        transition: 'transform 0.3s ease-in-out',
        boxShadow: '4px 0 20px rgba(0,0,0,0.1)',
        borderRight: '1px solid rgba(255,255,255,0.1)'
      }"
    >
      <!-- Logo -->
      <div style="padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.1);">
        <div style="display: flex; align-items: center;">
          <div style="width: 36px; height: 36px; background: rgba(255,255,255,0.2); border-radius: 10px; display: flex; align-items: center; justify-content: center; margin-right: 14px; backdrop-filter: blur(10px);">
            <span style="color: white; font-weight: 700; font-size: 18px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;">Q</span>
          </div>
          <span style="font-size: 20px; font-weight: 700; color: white; letter-spacing: -0.3px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;">QR 자산관리</span>
        </div>
      </div>

      <!-- Navigation -->
      <nav style="padding: 24px 12px; flex: 1;">
        <div style="margin-bottom: 6px;">
          <NuxtLink 
            to="/dashboard" 
            style="display: flex; align-items: center; padding: 14px 16px; color: rgba(255,255,255,0.8); text-decoration: none; border-radius: 10px; transition: all 0.3s ease; margin-bottom: 3px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;"
            :style="{ 
              backgroundColor: $route.path === '/dashboard' ? 'rgba(255,255,255,0.15)' : 'transparent', 
              color: $route.path === '/dashboard' ? 'white' : 'rgba(255,255,255,0.8)',
              boxShadow: $route.path === '/dashboard' ? '0 3px 10px rgba(0,0,0,0.15)' : 'none'
            }"
          >
            <svg style="width: 20px; height: 20px; margin-right: 14px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
            </svg>
            <span style="font-weight: 600; font-size: 14px;">대시보드</span>
          </NuxtLink>
        </div>

        <div style="margin-bottom: 6px;">
          <NuxtLink 
            to="/employees" 
            style="display: flex; align-items: center; padding: 14px 16px; color: rgba(255,255,255,0.8); text-decoration: none; border-radius: 10px; transition: all 0.3s ease; margin-bottom: 3px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;"
            :style="{ 
              backgroundColor: $route.path.startsWith('/employees') ? 'rgba(255,255,255,0.15)' : 'transparent', 
              color: $route.path.startsWith('/employees') ? 'white' : 'rgba(255,255,255,0.8)',
              boxShadow: $route.path.startsWith('/employees') ? '0 3px 10px rgba(0,0,0,0.15)' : 'none'
            }"
          >
            <svg style="width: 20px; height: 20px; margin-right: 14px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
            <span style="font-weight: 600; font-size: 14px;">직원 관리</span>
          </NuxtLink>
        </div>

        <div style="margin-bottom: 6px;">
          <NuxtLink 
            to="/devices" 
            style="display: flex; align-items: center; padding: 14px 16px; color: rgba(255,255,255,0.8); text-decoration: none; border-radius: 10px; transition: all 0.3s ease; margin-bottom: 3px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;"
            :style="{ 
              backgroundColor: $route.path.startsWith('/devices') ? 'rgba(255,255,255,0.15)' : 'transparent', 
              color: $route.path.startsWith('/devices') ? 'white' : 'rgba(255,255,255,0.8)',
              boxShadow: $route.path.startsWith('/devices') ? '0 3px 10px rgba(0,0,0,0.15)' : 'none'
            }"
          >
            <svg style="width: 20px; height: 20px; margin-right: 14px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
            </svg>
            <span style="font-weight: 600; font-size: 14px;">장비 관리</span>
          </NuxtLink>
        </div>

        <div style="margin-bottom: 6px;">
          <NuxtLink 
            to="/qr-generator" 
            style="display: flex; align-items: center; padding: 14px 16px; color: rgba(255,255,255,0.8); text-decoration: none; border-radius: 10px; transition: all 0.3s ease; margin-bottom: 3px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;"
            :style="{ 
              backgroundColor: $route.path.startsWith('/qr-generator') ? 'rgba(255,255,255,0.15)' : 'transparent', 
              color: $route.path.startsWith('/qr-generator') ? 'white' : 'rgba(255,255,255,0.8)',
              boxShadow: $route.path.startsWith('/qr-generator') ? '0 3px 10px rgba(0,0,0,0.15)' : 'none'
            }"
          >
            <svg style="width: 20px; height: 20px; margin-right: 14px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V6a1 1 0 00-1-1H5a1 1 0 00-1 1v1a1 1 0 001 1zm12 0h2a1 1 0 001-1V6a1 1 0 00-1-1h-2a1 1 0 00-1 1v1a1 1 0 001 1zM5 20h2a1 1 0 001-1v-1a1 1 0 00-1-1H5a1 1 0 00-1 1v1a1 1 0 001 1z"/>
            </svg>
            <span style="font-weight: 600; font-size: 14px;">QR 생성</span>
          </NuxtLink>
        </div>

        <div style="margin-bottom: 6px;">
          <NuxtLink 
            to="/qr-scanner" 
            style="display: flex; align-items: center; padding: 14px 16px; color: rgba(255,255,255,0.8); text-decoration: none; border-radius: 10px; transition: all 0.3s ease; margin-bottom: 3px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;"
            :style="{ 
              backgroundColor: $route.path.startsWith('/qr-scanner') ? 'rgba(255,255,255,0.15)' : 'transparent', 
              color: $route.path.startsWith('/qr-scanner') ? 'white' : 'rgba(255,255,255,0.8)',
              boxShadow: $route.path.startsWith('/qr-scanner') ? '0 3px 10px rgba(0,0,0,0.15)' : 'none'
            }"
          >
            <svg style="width: 20px; height: 20px; margin-right: 14px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"/>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            <span style="font-weight: 600; font-size: 14px;">QR 스캐너</span>
          </NuxtLink>
        </div>
      </nav>

      <!-- Settings -->
      <div style="padding: 20px 12px; border-top: 1px solid rgba(255,255,255,0.1);">
        <NuxtLink 
          to="/profile" 
          style="display: flex; align-items: center; padding: 14px 16px; color: rgba(255,255,255,0.8); text-decoration: none; border-radius: 10px; transition: all 0.3s ease; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;"
          :style="{ 
            backgroundColor: $route.path.startsWith('/profile') ? 'rgba(255,255,255,0.15)' : 'transparent', 
            color: $route.path.startsWith('/profile') ? 'white' : 'rgba(255,255,255,0.8)',
            boxShadow: $route.path.startsWith('/profile') ? '0 3px 10px rgba(0,0,0,0.15)' : 'none'
          }"
        >
          <svg style="width: 20px; height: 20px; margin-right: 14px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
          </svg>
          <span style="font-weight: 600; font-size: 14px;">설정</span>
        </NuxtLink>
      </div>
    </div>
    
    <!-- Header - 로그인 페이지에서는 숨김 -->
    <div 
      v-if="!isLoginPage"
      :style="{
        position: 'fixed',
        top: 0,
        left: sidebarOpen ? '260px' : '0',
        right: 0,
        height: '70px',
        background: 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)',
        zIndex: 9999,
        transition: 'left 0.3s ease-in-out',
        boxShadow: '0 2px 20px rgba(0,0,0,0.1)',
        borderBottom: '1px solid rgba(0,0,0,0.05)'
      }"
    >
      <div style="display: flex; align-items: center; justify-content: space-between; padding: 0 28px; height: 100%;">
        <div style="display: flex; align-items: center; gap: 20px;">
          <!-- Hamburger Menu -->
          <button 
            @click="toggleSidebar"
            style="padding: 10px; background: rgba(255,255,255,0.8); border: none; border-radius: 10px; cursor: pointer; transition: all 0.3s ease; backdrop-filter: blur(10px);"
          >
            <svg style="width: 20px; height: 20px; color: #374151;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
          </button>
          
          <h1 style="font-size: 24px; font-weight: 700; color: #1f2937; margin: 0; letter-spacing: -0.5px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;">
            {{ pageTitle }}
          </h1>
        </div>
        
        <div style="display: flex; align-items: center; gap: 16px;">
          <!-- Filters -->
          <div style="display: flex; align-items: center; gap: 12px;">
            <select style="padding: 10px 14px; background: rgba(255,255,255,0.8); border: 1px solid rgba(0,0,0,0.1); border-radius: 10px; font-size: 13px; color: #374151; backdrop-filter: blur(10px); min-width: 120px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;">
              <option>전체 기간</option>
              <option>이번 달</option>
              <option>이번 주</option>
            </select>
            <select style="padding: 10px 14px; background: rgba(255,255,255,0.8); border: 1px solid rgba(0,0,0,0.1); border-radius: 10px; font-size: 13px; color: #374151; backdrop-filter: blur(10px); min-width: 120px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;">
              <option>전체 부서</option>
              <option>개발팀</option>
              <option>디자인팀</option>
            </select>
          </div>
          
          <!-- User Menu -->
          <div style="display: flex; align-items: center; gap: 12px;">
            <button style="position: relative; padding: 10px; color: #6b7280; background: rgba(255,255,255,0.8); border: none; border-radius: 10px; cursor: pointer; transition: all 0.3s ease; backdrop-filter: blur(10px);">
              <svg style="width: 18px; height: 18px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-5 5v-5zM4.19 4.19A4 4 0 006.73 3H10v5.27A4 4 0 0014.73 9H20v3.27A4 4 0 0020 16.73V21h-3.27A4 4 0 016.73 20H4v-3.27A4 4 0 014.19 4.19z"/>
              </svg>
              <span style="position: absolute; top: 3px; right: 3px; width: 8px; height: 8px; background: #ef4444; border-radius: 50%; border: 2px solid white;"></span>
            </button>
            
            <div style="display: flex; align-items: center; gap: 10px;">
              <div style="width: 36px; height: 36px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);">
                <span style="color: white; font-weight: 600; font-size: 14px; font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;">A</span>
              </div>
              <button 
                @click="handleLogout"
                style="padding: 10px; color: #6b7280; background: rgba(255,255,255,0.8); border: none; border-radius: 10px; cursor: pointer; transition: all 0.3s ease; backdrop-filter: blur(10px);"
              >
                <svg style="width: 18px; height: 18px;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Main Content -->
    <div 
      :style="{
        marginLeft: isLoginPage ? '0' : (sidebarOpen ? '260px' : '0'),
        marginTop: isLoginPage ? '0' : '70px',
        padding: isLoginPage ? '0' : '28px',
        minHeight: isLoginPage ? '100vh' : 'calc(100vh - 70px)',
        background: isLoginPage ? 'transparent' : 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)',
        transition: 'margin-left 0.3s ease-in-out'
      }"
    >
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute()
const router = useRouter()

// Sidebar toggle state
const sidebarOpen = ref(true)

// Check if current page is login page
const isLoginPage = computed(() => {
  return route.path === '/login' || route.path === '/register'
})

// Toggle sidebar
const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

// Get page title based on current route
const pageTitle = computed(() => {
  const routeTitles: Record<string, string> = {
    '/dashboard': '대시보드',
    '/employees': '직원 관리',
    '/devices': '장비 관리',
    '/qr-generator': 'QR 생성',
    '/qr-scanner': 'QR 스캐너',
    '/profile': '프로필 설정',
    '/test-layout': '레이아웃 테스트'
  }
  
  return routeTitles[route.path] || 'QR 자산관리'
})

// 2025-01-27: 배포 환경에서 useAuthStore 오류 해결을 위해 명시적 import 추가
import { useAuthStore } from '~/stores/auth'

// Handle logout
const handleLogout = () => {
  const authStore = useAuthStore()
  authStore.logout()
  router.push('/login')
}
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