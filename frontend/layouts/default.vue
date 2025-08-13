<template>
  <div class="layout-container">
    <!-- Sidebar Component -->
    <Sidebar 
      v-if="!isLoginPage" 
      v-model:collapsed="sidebarCollapsed"
      @update:collapsed="updateSidebarState"
      @mobile-toggle="handleMobileToggle"
      @mobile-state="handleMobileState"
      ref="sidebarRef"
    />
    
    <!-- Main Content Area -->
    <div class="main-area" :class="{ 'mobile-sidebar-open': isMobileSidebarOpen }">
      <!-- Header Component -->
      <Header 
        v-if="!isLoginPage" 
        :style="headerStyle"
        @toggle-mobile-menu="toggleMobileSidebar"
      />
      
      <!-- Main Content -->
      <main 
        :class="[
          'main-content',
          { 'with-sidebar': !isLoginPage }
        ]"
        :style="mainContentStyle"
      >
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2025-01-27: 사이드바 반응형 동작 개선 및 모바일 토글 기능 추가

const route = useRoute()

// Check if current page is login page
const isLoginPage = computed(() => {
  return route.path === '/login' || route.path === '/register'
})

// 2025-01-27: 사이드바 상태 관리 개선
const sidebarCollapsed = ref(false)
const isMobileSidebarOpen = ref(false)
const isMobile = ref(false) // 2025-01-27: 모바일 상태 추가
const sidebarRef = ref()

// 사이드바 상태 업데이트 함수
const updateSidebarState = (collapsed: boolean) => {
  sidebarCollapsed.value = collapsed
}

// 모바일 사이드바 토글 처리
const handleMobileToggle = (isOpen: boolean) => {
  isMobileSidebarOpen.value = isOpen
}

// 2025-01-27: 모바일 상태 감지 처리 추가
const handleMobileState = (isMobileState: boolean) => {
  isMobile.value = isMobileState
}

// 헤더에서 모바일 메뉴 토글 호출 시 처리
const toggleMobileSidebar = () => {
  if (sidebarRef.value) {
    sidebarRef.value.toggleMobileSidebar()
  }
}

// 2025-01-27: 사이드바 상태에 따른 메인 콘텐츠 스타일 계산 개선
const mainContentStyle = computed(() => {
  if (isLoginPage.value) {
    return {
      marginLeft: '0',
      paddingTop: '0'
    }
  }

  // 2025-01-27: 모바일에서 메인 콘텐츠 여백 조정 개선
  // 모바일에서는 사이드바가 열려있을 때만 여백 적용
  if (isMobile.value && isMobileSidebarOpen.value) {
    return {
      marginLeft: '0',
      paddingTop: '70px'
    }
  }

  // 모바일에서는 기본적으로 여백 없음
  if (isMobile.value) {
    return {
      marginLeft: '0',
      paddingTop: '70px'
    }
  }

  // 데스크톱에서 사이드바 상태에 따른 여백 조정
  const sidebarWidth = sidebarCollapsed.value ? 20 : 240
  return {
    marginLeft: `${sidebarWidth}px`,
    paddingTop: '70px'
  }
})

// 사이드바 상태에 따른 헤더 위치 조정
const headerStyle = computed(() => {
  if (isLoginPage.value) {
    return {
      left: '0px'
    }
  }

  // 2025-01-27: 모바일에서 헤더 위치 조정 개선
  // 모바일에서는 사이드바가 열려있을 때만 여백 적용
  if (isMobile.value && isMobileSidebarOpen.value) {
    return {
      left: '0px'
    }
  }

  // 모바일에서는 기본적으로 왼쪽 끝에서 시작
  if (isMobile.value) {
    return {
      left: '0px'
    }
  }

  // 데스크톱에서 사이드바 상태에 따른 헤더 위치
  const sidebarWidth = sidebarCollapsed.value ? 20 : 240
  return {
    left: `${sidebarWidth}px`
  }
})
</script>

<style scoped>
/* 2025-01-27: 레이아웃 구조 완전 재설계 - 사이드바와 메인 콘텐츠 분리 및 반응형 개선 */
.layout-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  display: flex;
  position: relative;
}

/* 메인 영역 (헤더 + 콘텐츠) */
.main-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  /* 2025-01-27: margin-left 제거 - JavaScript에서 동적으로 계산 */
  transition: margin-left 0.3s ease-in-out;
}

/* 메인 콘텐츠 */
.main-content {
  flex: 1;
  padding: 1.5rem 2rem;
  background: transparent;
  min-height: calc(100vh - 70px); /* 헤더 높이만큼 제외 */
}

.main-content.with-sidebar {
  padding-top: 0; /* 헤더가 있으므로 상단 패딩 제거 */
}

/* 반응형 디자인 */
@media (max-width: 1024px) {
  /* 2025-01-27: margin-left 제거 - JavaScript에서 동적으로 계산 */
}

@media (max-width: 768px) {
  /* 2025-01-27: margin-left 제거 - JavaScript에서 동적으로 계산 */
  
  /* 모바일에서 사이드바가 열려있을 때 오버레이 효과 */
  .main-area.mobile-sidebar-open {
    position: relative;
  }
  
  .main-area.mobile-sidebar-open::before {
    content: '';
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 999;
    pointer-events: auto;
  }
  
  .main-content {
    padding: 1rem;
  }
}

/* 로그인/회원가입 페이지용 스타일 */
.layout-container:has(.main-area:only-child) {
  display: block;
}

.layout-container:has(.main-area:only-child) .main-area {
  margin-left: 0;
}
</style> 