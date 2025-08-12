<template>
  <div class="layout-container">
    <!-- Sidebar Component -->
    <Sidebar 
      v-if="!isLoginPage" 
      v-model:collapsed="sidebarCollapsed"
      @update:collapsed="updateSidebarState"
    />
    
    <!-- Main Content Area -->
    <div class="main-area">
      <!-- Header Component -->
      <Header v-if="!isLoginPage" :style="headerStyle" />
      
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
const route = useRoute()

// Check if current page is login page
const isLoginPage = computed(() => {
  return route.path === '/login' || route.path === '/register'
})

// 2024-12-19: 사이드바 상태 관리 개선
const sidebarCollapsed = ref(false)

// 사이드바 상태 업데이트 함수
const updateSidebarState = (collapsed: boolean) => {
  sidebarCollapsed.value = collapsed
}

// 2024-12-19: 사이드바 상태에 따른 메인 콘텐츠 스타일 계산
const sidebarState = useState('sidebar', () => ({
  isCollapsed: false,
  isMobile: false,
  isOpen: false
}))

const mainContentStyle = computed(() => {
  if (isLoginPage.value) {
    return {
      marginLeft: '0',
      paddingTop: '0'
    }
  }

  // 2024-12-19: 사이드바 상태에 따른 메인 콘텐츠 위치 조정
  return {
    marginLeft: '0',
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

  return {
    left: sidebarCollapsed.value ? '80px' : '240px'
  }
})
</script>

<style scoped>
/* 2024-12-19: 레이아웃 구조 완전 재설계 - 사이드바와 메인 콘텐츠 분리 */
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
  margin-left: 240px; /* 사이드바 너비만큼 여백 - 2024-12-19: UX 개선을 위해 축소 */
  transition: margin-left 0.3s ease-in-out;
}

/* 메인 콘텐츠 */
.main-content {
  flex: 1;
  padding: 1.5rem 2rem; /* 2024-12-19: UX 개선을 위해 상하 패딩 축소 */
  background: transparent;
  min-height: calc(100vh - 70px); /* 헤더 높이만큼 제외 */
}

.main-content.with-sidebar {
  padding-top: 0; /* 헤더가 있으므로 상단 패딩 제거 */
}

/* 반응형 디자인 */
@media (max-width: 1024px) {
  .main-area {
    margin-left: 70px; /* 접힌 사이드바 너비 - 2024-12-19: UX 개선 */
  }
  
  .header {
    left: 70px !important; /* 접힌 사이드바에 맞춰 헤더 위치 조정 */
  }
}

@media (max-width: 768px) {
  .main-area {
    margin-left: 0; /* 모바일에서는 사이드바 숨김 */
  }
  
  .header {
    left: 0 !important; /* 모바일에서는 헤더를 왼쪽 끝으로 */
  }
  
  .main-content {
    padding: 1rem;
  }
  
  /* 2024-12-19: 모바일에서 사이드바 숨김 */
  .sidebar {
    transform: translateX(-100%);
  }
  
  /* 모바일에서 사이드바가 열려있을 때만 표시 */
  .sidebar.mobile-open {
    transform: translateX(0);
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