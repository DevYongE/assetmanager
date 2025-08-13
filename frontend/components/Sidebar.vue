<template>
  <!-- 모바일 오버레이 -->
  <div 
    v-if="isMobile && isMobileOpen" 
    class="mobile-overlay"
    @click="closeMobileSidebar"
  ></div>
  
  <aside class="sidebar" :class="{ 
    'sidebar-collapsed': isCollapsed && !isMobile,
    'mobile-open': isMobileOpen
  }">
    <!-- 사이드바 헤더 -->
    <div class="sidebar-header">
      <div class="logo-section">
        <div class="logo-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 9h6v12H3z"/>
            <path d="M9 3h12v18H9z"/>
            <path d="M15 9h6"/>
            <path d="M15 15h6"/>
            <path d="M9 9h6"/>
            <path d="M9 15h6"/>
          </svg>
        </div>
        <div v-if="!isCollapsed || isMobile" class="logo-text">
          <h1 class="logo-title">InvenOne</h1>
          <p class="logo-subtitle">인벤토리 관리</p>
        </div>
      </div>
      
      <!-- 토글 버튼 -->
      <button class="toggle-button" @click="toggleSidebar">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <polyline v-if="!isCollapsed" points="18,15 12,9 6,15"/>
          <polyline v-else points="6,9 12,15 18,9"/>
        </svg>
      </button>
    </div>

    <!-- 네비게이션 메뉴 -->
    <nav class="sidebar-nav">
      <ul class="nav-list">
        <li v-for="item in menuItems" :key="item.path" class="nav-item">
          <NuxtLink
            :to="item.path"
            class="nav-link"
            :class="{ 'nav-link-active': isActive(item.path) }"
            @click="handleNavClick"
          >
            <div class="nav-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path :d="item.icon" />
              </svg>
            </div>
            <span v-if="!isCollapsed || isMobile" class="nav-text">{{ item.label }}</span>
            <div v-if="(!isCollapsed || isMobile) && item.badge" class="nav-badge">
              {{ item.badge }}
            </div>
          </NuxtLink>
        </li>
      </ul>
    </nav>

    <!-- 사용자 프로필 -->
    <div class="sidebar-footer">
      <div class="user-profile" @click="navigateTo('/profile')">
        <div class="user-avatar">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
            <circle cx="12" cy="7" r="4"/>
          </svg>
        </div>
              <div v-if="!isCollapsed || isMobile" class="user-info">
        <h4 class="user-name"> {{ user?.company_name }}</h4>
        <p class="user-role">{{ user?.role || '관리자' }}</p>
      </div>
        <button v-if="!isCollapsed || isMobile" class="logout-button" @click="handleLogout">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
            <polyline points="16,17 21,12 16,7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
          </svg>
        </button>
      </div>
    </div>

    <!-- 툴팁 (접힌 상태일 때) -->
    <div v-if="isCollapsed" class="sidebar-tooltip" :style="tooltipStyle">
      <span class="tooltip-text">{{ tooltipText }}</span>
    </div>
  </aside>
</template>

<script setup lang="ts">
// 2024-12-19: 트렌디한 UI 디자인으로 사이드바 컴포넌트 완전 재설계
// 2025-01-27: 반응형 동작 개선 및 모바일 토글 기능 수정

import { ref, computed, onMounted, onUnmounted, watch } from 'vue'

// Props
interface Props {
  collapsed?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  collapsed: false
})

// Emits
const emit = defineEmits<{
  'update:collapsed': [value: boolean]
  'mobile-toggle': [value: boolean]
  'mobile-state': [value: boolean] // 2025-01-27: 모바일 상태 전달 추가
}>()

// 상태 관리
const isCollapsed = ref(props.collapsed)
const isMobile = ref(false)
const isMobileOpen = ref(false)
const tooltipText = ref('')
const tooltipStyle = ref({
  top: '0px',
  left: '0px',
  opacity: '0'
})

// 사용자 정보
const user = ref<any>(null)

// 메뉴 아이템
const menuItems = [
  {
    path: '/dashboard',
    label: '대시보드',
    icon: 'M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
    badge: null
  },
  {
    path: '/qr-generator',
    label: 'QR 생성',
    icon: 'M3 9h6v12H3z M9 3h12v18H9z M15 9h6 M15 15h6 M9 9h6 M9 15h6',
    badge: null
  },
  {
    path: '/qr-scanner',
    label: 'QR 스캔',
    icon: 'M3 9h6v12H3z M9 3h12v18H9z M15 9h6 M15 15h6 M9 9h6 M9 15h6',
    badge: null
  },
  {
    path: '/devices',
    label: '장비 관리',
    icon: 'M3 9h6v12H3z M9 3h12v18H9z M15 9h6 M15 15h6 M9 9h6 M9 15h6',
    badge: null
  },
  {
    path: '/employees',
    label: '직원 관리',
    icon: 'M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2 M12 3a4 4 0 1 0 0 8 4 4 0 0 0 0-8z',
    badge: null
  }
]

// 사이드바 토글
const toggleSidebar = () => {
  if (isMobile.value) {
    // 모바일에서는 모바일 사이드바 토글
    isMobileOpen.value = !isMobileOpen.value
    emit('mobile-toggle', isMobileOpen.value)
  } else {
    // 데스크톱에서는 접기/펼치기 토글
    isCollapsed.value = !isCollapsed.value
    emit('update:collapsed', isCollapsed.value)
  }
}

// 활성 메뉴 확인
const isActive = (path: string) => {
  const route = useRoute()
  return route.path === path || route.path.startsWith(path + '/')
}

// 모바일 감지
const checkMobile = () => {
  const wasMobile = isMobile.value
  // 2025-01-27: 모바일 감지 기준을 1024px로 상향 조정하여 태블릿 환경 개선
  isMobile.value = window.innerWidth < 1024
  
  // 2025-01-27: 모바일 상태를 레이아웃에 전달
  emit('mobile-state', isMobile.value)
  
  // 모바일 상태가 변경되었을 때 처리
  if (wasMobile !== isMobile.value) {
    if (isMobile.value) {
      // 데스크톱에서 모바일로 변경
      isMobileOpen.value = false
      emit('mobile-toggle', false)
    } else {
      // 모바일에서 데스크톱으로 변경
      isMobileOpen.value = false
      emit('mobile-toggle', false)
    }
  }
}

// 모바일 사이드바 토글 (외부에서 호출)
const toggleMobileSidebar = () => {
  if (isMobile.value) {
    isMobileOpen.value = !isMobileOpen.value
    emit('mobile-toggle', isMobileOpen.value)
  }
}

// 모바일 사이드바 닫기
const closeMobileSidebar = () => {
  if (isMobile.value) {
    isMobileOpen.value = false
    emit('mobile-toggle', false)
  }
}

// 네비게이션 클릭 처리
const handleNavClick = () => {
  // 모바일에서 메뉴 클릭 시 사이드바 닫기
  if (isMobile.value) {
    isMobileOpen.value = false
    emit('mobile-toggle', false)
  }
}

// 로그아웃 처리
const handleLogout = async () => {
  try {
    const authStore = useAuthStore()
    await authStore.logout()
  } catch (error) {
    console.error('로그아웃 실패:', error)
  }
}

// 툴팁 표시
const showTooltip = (event: MouseEvent, text: string) => {
  if (!isCollapsed.value || isMobile.value) return
  
  const target = event.currentTarget as HTMLElement
  const rect = target.getBoundingClientRect()
  
  tooltipText.value = text
  tooltipStyle.value = {
    top: `${rect.top + rect.height / 2 - 20}px`,
    left: `${rect.right + 10}px`,
    opacity: '1'
  }
}

// 툴팁 숨기기
const hideTooltip = () => {
  tooltipStyle.value.opacity = '0'
}

// 사용자 정보 로드
const loadUserInfo = () => {
  const authStore = useAuthStore()
  user.value = authStore.user
}

// 사용자 표시 이름 생성
const getUserDisplayName = () => {
  if (!user.value?.email) return '사용자'
  
  // 이메일에서 @ 앞부분을 이름으로 사용
  const emailName = user.value.email.split('@')[0]
  return emailName.charAt(0).toUpperCase() + emailName.slice(1)
}

// 마우스 이벤트 리스너
const handleMouseEnter = (event: MouseEvent, text: string) => {
  showTooltip(event, text)
}

const handleMouseLeave = () => {
  hideTooltip()
}

// props 변경 감지
watch(() => props.collapsed, (newValue) => {
  if (!isMobile.value) {
    isCollapsed.value = newValue
  }
})

// 외부에서 모바일 토글 호출 가능하도록 expose
defineExpose({
  toggleMobileSidebar,
  closeMobileSidebar
})

onMounted(() => {
  loadUserInfo()
  checkMobile()
  
  // 2025-01-27: 모바일 반응형 개선 - 리사이즈 이벤트 리스너 추가
  window.addEventListener('resize', checkMobile)
  
  // 메뉴 아이템에 마우스 이벤트 추가
  const navLinks = document.querySelectorAll('.nav-link')
  navLinks.forEach((link, index) => {
    // 2025-01-27: TypeScript 안전성 개선 - 배열 인덱스 범위 체크 추가
    const menuItem = menuItems[index]
    if (menuItem) {
      link.addEventListener('mouseenter', (e) => handleMouseEnter(e as MouseEvent, menuItem.label))
      link.addEventListener('mouseleave', handleMouseLeave)
    }
  })
})

onUnmounted(() => {
  // 2025-01-27: 모바일 반응형 개선 - 리사이즈 이벤트 리스너 제거
  window.removeEventListener('resize', checkMobile)
  
  // 이벤트 리스너 제거
  const navLinks = document.querySelectorAll('.nav-link')
  navLinks.forEach((link) => {
    link.removeEventListener('mouseenter', handleMouseEnter as any)
    link.removeEventListener('mouseleave', handleMouseLeave)
  })
})
</script>

<style scoped>
/* 트렌디한 사이드바 스타일 */
.sidebar {
  width: 240px; /* 2024-12-19: UX 개선을 위해 너비 축소 */
  height: 100vh;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  border-right: 1px solid rgba(255, 255, 255, 0.2);
  display: flex;
  flex-direction: column;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: fixed;
  top: 0;
  left: 0;
  z-index: 50;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
}

.sidebar-collapsed {
  width: 70px; /* 2024-12-19: UX 개선을 위해 접힌 상태 너비도 축소 */
}

/* 사이드바 헤더 */
.sidebar-header {
  padding: 1.25rem; /* 2024-12-19: UX 개선을 위해 패딩 축소 */
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px; /* 2024-12-19: UX 개선을 위해 크기 축소 */
  height: 36px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 10px;
  color: white;
  flex-shrink: 0;
  box-shadow: 0 4px 6px -1px rgba(139, 92, 246, 0.3);
}

.logo-text {
  display: flex;
  flex-direction: column;
}

.logo-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1e293b;
  line-height: 1;
  margin: 0;
}

.logo-subtitle {
  font-size: 0.75rem;
  color: #64748b;
  margin: 0;
}

.toggle-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s ease;
}

.toggle-button:hover {
  background: rgba(139, 92, 246, 0.1);
  color: #a855f7;
  transform: scale(1.05);
}

/* 네비게이션 */
.sidebar-nav {
  flex: 1;
  padding: 1rem 0;
  overflow-y: auto;
}

.nav-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.nav-item {
  margin: 0;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.875rem; /* 2024-12-19: UX 개선을 위해 간격 축소 */
  padding: 0.75rem 1.25rem; /* 2024-12-19: UX 개선을 위해 패딩 축소 */
  color: #64748b;
  text-decoration: none;
  border-radius: 12px;
  margin: 0 0.5rem; /* 2024-12-19: UX 개선을 위해 마진 축소 */
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.nav-link::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.nav-link:hover::before {
  opacity: 1;
}

.nav-link:hover {
  color: #a855f7;
  transform: translateX(4px);
}

.nav-link-active {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  color: #a855f7;
  font-weight: 600;
}

.nav-link-active::before {
  opacity: 1;
}

.nav-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.nav-text {
  font-size: 0.875rem;
  font-weight: 500;
  white-space: nowrap;
}

.nav-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 20px;
  height: 20px;
  padding: 0 6px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border-radius: 10px;
  font-size: 0.75rem;
  font-weight: 600;
  margin-left: auto;
}

/* 사이드바 푸터 */
.sidebar-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.user-profile {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.user-profile:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.user-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
  border-radius: 10px;
  color: white;
  flex-shrink: 0;
}

.user-info {
  flex: 1;
  min-width: 0;
}

.user-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-role {
  font-size: 0.75rem;
  color: #64748b;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.logout-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 8px;
  color: #dc2626;
  cursor: pointer;
  transition: all 0.3s ease;
}

.logout-button:hover {
  background: rgba(239, 68, 68, 0.2);
  transform: scale(1.05);
}

/* 툴팁 */
.sidebar-tooltip {
  position: fixed;
  background: rgba(30, 41, 59, 0.9);
  backdrop-filter: blur(10px);
  color: white;
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
  z-index: 1000;
  pointer-events: none;
  transition: opacity 0.3s ease;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.tooltip-text {
  display: block;
}

/* 접힌 상태 스타일 */
.sidebar-collapsed .logo-text,
.sidebar-collapsed .nav-text,
.sidebar-collapsed .user-info,
.sidebar-collapsed .logout-button {
  display: none;
}

.sidebar-collapsed .sidebar-header {
  justify-content: center;
  padding: 1rem;
}

.sidebar-collapsed .toggle-button {
  position: absolute;
  right: -16px;
  top: 50%;
  transform: translateY(-50%);
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  color: white;
  border: 2px solid white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  z-index: 60; /* 2025-01-27: z-index 추가로 다른 요소 위에 표시 */
}

.sidebar-collapsed .toggle-button:hover {
  background: linear-gradient(135deg, #9333ea 0%, #6d28d9 100%);
  transform: translateY(-50%) scale(1.05);
  box-shadow: 0 6px 8px -1px rgba(0, 0, 0, 0.15);
}

.sidebar-collapsed .nav-link {
  justify-content: center;
  padding: 0.75rem;
  margin: 0 0.5rem;
}

.sidebar-collapsed .user-profile {
  justify-content: center;
  padding: 0.5rem;
}

/* 스크롤바 스타일 */
.sidebar-nav::-webkit-scrollbar {
  width: 4px;
}

.sidebar-nav::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
}

.sidebar-nav::-webkit-scrollbar-thumb {
  background: rgba(139, 92, 246, 0.3);
  border-radius: 2px;
}

.sidebar-nav::-webkit-scrollbar-thumb:hover {
  background: rgba(139, 92, 246, 0.5);
}

/* 반응형 */
@media (max-width: 1024px) {
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    width: 280px; /* 모바일에서는 전체 너비로 */
    transform: translateX(-100%);
    z-index: 1000;
    transition: transform 0.3s ease-in-out;
  }
  
  .sidebar.mobile-open {
    transform: translateX(0);
  }
  
  /* 2025-01-27: 모바일에서 접힌 상태 스타일 무시 및 텍스트 표시 개선 */
  .sidebar-collapsed {
    width: 280px;
  }
  
  /* 모바일에서는 항상 텍스트 표시 */
  .sidebar-collapsed .logo-text,
  .sidebar-collapsed .nav-text,
  .sidebar-collapsed .user-info,
  .sidebar-collapsed .logout-button {
    display: block !important;
  }
  
  .sidebar-collapsed .sidebar-header {
    justify-content: space-between;
    padding: 1.25rem;
  }
  
  .sidebar-collapsed .toggle-button {
    position: static;
    transform: none;
  }
  
  .sidebar-collapsed .nav-link {
    justify-content: flex-start;
    padding: 0.75rem 1.25rem;
    margin: 0 0.5rem;
  }
  
  .sidebar-collapsed .user-profile {
    justify-content: flex-start;
    padding: 0.75rem;
  }
  
  /* 2025-01-27: 모바일 오버레이 스타일 개선 */
  .mobile-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    z-index: 999;
    cursor: pointer;
    /* 2025-01-27: 터치 이벤트 개선 */
    touch-action: none;
  }
}

@media (max-width: 480px) {
  .sidebar {
    width: 100%;
    max-width: 320px;
  }
  
  /* 2025-01-27: 작은 화면에서도 일관된 동작 보장 */
  .sidebar-collapsed {
    width: 100%;
    max-width: 320px;
  }
  
  /* 작은 화면에서도 텍스트 표시 */
  .sidebar-collapsed .logo-text,
  .sidebar-collapsed .nav-text,
  .sidebar-collapsed .user-info,
  .sidebar-collapsed .logout-button {
    display: block !important;
  }
}
</style> 