<template>
  <header class="header">
    <!-- 헤더 컨테이너 -->
    <div class="header-container">
      <!-- 왼쪽 섹션 -->
      <div class="header-left">
        <!-- 모바일 메뉴 버튼 -->
        <button class="mobile-menu-button" @click="toggleMobileMenu">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="3" y1="6" x2="21" y2="6"/>
            <line x1="3" y1="12" x2="21" y2="12"/>
            <line x1="3" y1="18" x2="21" y2="18"/>
          </svg>
        </button>

        <!-- 브레드크럼 -->
        <nav class="breadcrumb" v-if="breadcrumbs.length > 0">
          <ol class="breadcrumb-list">
            <li v-for="(crumb, index) in breadcrumbs" :key="index" class="breadcrumb-item">
              <NuxtLink
                v-if="crumb.path && index < breadcrumbs.length - 1"
                :to="crumb.path"
                class="breadcrumb-link"
              >
                {{ crumb.label }}
              </NuxtLink>
              <span v-else class="breadcrumb-current">{{ crumb.label }}</span>
              <svg
                v-if="index < breadcrumbs.length - 1"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                class="breadcrumb-separator"
              >
                <polyline points="9,18 15,12 9,6"/>
              </svg>
            </li>
          </ol>
        </nav>
      </div>

      <!-- 중앙 섹션 -->
      <div class="header-center">
        <!-- 페이지 제목 -->
        <h1 v-if="pageTitle" class="page-title">{{ pageTitle }}</h1>
      </div>

      <!-- 오른쪽 섹션 -->
      <div class="header-right">
        <!-- 검색 버튼 -->
        <button class="header-button search-button" @click="toggleSearch">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"/>
            <path d="M21 21l-4.35-4.35"/>
          </svg>
        </button>

        <!-- 알림 버튼 -->
        <button class="header-button notification-button" @click="toggleNotifications">
          <div class="notification-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/>
              <path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>
            </svg>
            <span v-if="notificationCount > 0" class="notification-badge">
              {{ notificationCount > 99 ? '99+' : notificationCount }}
            </span>
          </div>
        </button>

        <!-- 사용자 메뉴 -->
        <div class="user-menu" ref="userMenuRef">
          <button class="user-menu-button" @click="toggleUserMenu">
            <div class="user-avatar">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
                  <div class="user-info">
        <span class="user-name"> {{ user?.company_name }}</span>
        <span class="user-email">{{ user?.email || 'user@example.com' }}</span>
      </div>
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              class="user-menu-arrow"
              :class="{ 'user-menu-arrow-rotated': isUserMenuOpen }"
            >
              <polyline points="6,9 12,15 18,9"/>
            </svg>
          </button>

          <!-- 사용자 드롭다운 메뉴 -->
          <div v-if="isUserMenuOpen" class="user-dropdown">
            <div class="dropdown-header">
              <div class="dropdown-user-info">
                <div class="dropdown-avatar">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                  </svg>
                </div>
                <div class="dropdown-user-details">
                  <h4 class="dropdown-user-name">{{ user?.name || '사용자' }}</h4>
                  <p class="dropdown-user-email">{{ user?.email || 'user@example.com' }}</p>
                </div>
              </div>
            </div>

            <div class="dropdown-menu">
              <NuxtLink to="/profile" class="dropdown-item">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle cx="12" cy="7" r="4"/>
                </svg>
                <span>프로필 설정</span>
              </NuxtLink>

              <button class="dropdown-item" @click="handleLogout">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                  <polyline points="16,17 21,12 16,7"/>
                  <line x1="21" y1="12" x2="9" y2="12"/>
                </svg>
                <span>로그아웃</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 2025-01-27: 통합 검색 오버레이 -->
    <div v-if="isSearchOpen" class="search-overlay" @click="closeSearch">
      <div class="search-modal" @click.stop>
        <div class="search-input-wrapper">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="search-icon">
            <circle cx="11" cy="11" r="8"/>
            <path d="M21 21l-4.35-4.35"/>
          </svg>
          <input
            ref="searchInput"
            v-model="searchQuery"
            type="text"
            class="search-input"
            placeholder="직원명, 장비 자산번호, 장비 타입, 제조사로 검색..."
            @input="handleSearch"
            @keydown.esc="closeSearch"
            @keydown.enter="handleSearchEnter"
          />
          <button class="search-close" @click="closeSearch">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>
        
        <!-- 검색 결과 드롭다운 -->
        <div v-if="searchResults.length > 0" class="search-results">
          <div class="search-results-header">
            <span class="search-results-title">검색 결과 ({{ searchResults.length }})</span>
          </div>
          <div class="search-results-list">
            <div 
              v-for="result in searchResults" 
              :key="result.id"
              class="search-result-item"
              @click="handleResultClick(result)"
            >
              <div class="result-icon" :class="result.type">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path v-if="result.type === 'device'" d="M3 9h6v12H3z"/>
                  <path v-if="result.type === 'device'" d="M9 3h12v18H9z"/>
                  <path v-if="result.type === 'employee'" d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle v-if="result.type === 'employee'" cx="12" cy="7" r="4"/>
                </svg>
              </div>
              <div class="result-content">
                <div class="result-title">{{ result.title }}</div>
                <div class="result-subtitle">{{ result.subtitle }}</div>
                <div class="result-type">{{ result.typeLabel }}</div>
              </div>
              <div class="result-arrow">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="9,18 15,12 9,6"/>
                </svg>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 검색 결과가 없을 때 -->
        <div v-else-if="searchQuery && !isSearching" class="search-no-results">
          <div class="no-results-icon">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8"/>
              <path d="M21 21l-4.35-4.35"/>
            </svg>
          </div>
          <h3 class="no-results-title">검색 결과가 없습니다</h3>
          <p class="no-results-description">다른 검색어를 시도해보세요</p>
        </div>
        
        <!-- 검색 중일 때 -->
        <div v-else-if="isSearching" class="search-loading">
          <div class="loading-spinner"></div>
          <span class="loading-text">검색 중...</span>
        </div>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
// 2024-12-19: 트렌디한 UI 디자인으로 헤더 컴포넌트 완전 재설계
// 2025-01-27: 모바일 메뉴 토글 기능 개선 및 사이드바 연동 수정

import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'

// Props
interface Props {
  pageTitle?: string
}

const props = withDefaults(defineProps<Props>(), {
  pageTitle: ''
})

// Emits
const emit = defineEmits<{
  'toggle-mobile-menu': []
}>()

// 상태 관리
const isUserMenuOpen = ref(false)
const isSearchOpen = ref(false)
const searchQuery = ref('')
const notificationCount = ref(0)
const user = ref<any>(null)

// 2025-01-27: 통합 검색 관련 상태 추가
const searchResults = ref<any[]>([])
const isSearching = ref(false)
const searchTimeout = ref<NodeJS.Timeout | null>(null)

// Refs
const userMenuRef = ref<HTMLElement>()
const searchInput = ref<HTMLInputElement>()

// 브레드크럼 계산
const breadcrumbs = computed(() => {
  const route = useRoute()
  const paths = route.path.split('/').filter(Boolean)
  
  if (paths.length === 0) return []
  
  // 2025-01-27: 브랜드명을 InvenOne으로 변경
  const crumbs = [{ label: 'InvenOne', path: '/' }]
  
  let currentPath = ''
  paths.forEach((path, index) => {
    currentPath += `/${path}`
    
    // 경로에 따른 라벨 매핑
    const labelMap: Record<string, string> = {
      dashboard: '대시보드',
      devices: '장비 관리',
      employees: '직원 관리',
      'qr-generator': 'QR 생성',
      'qr-scanner': 'QR 스캔',
      profile: '프로필',
      edit: '편집',
      register: '회원가입',
      login: '로그인'
    }
    
    const label = labelMap[path] || path
    crumbs.push({
      label,
      path: index === paths.length - 1 ? '' : currentPath
    })
  })
  
  return crumbs
})

// 모바일 메뉴 토글
const toggleMobileMenu = () => {
  // 2025-01-27: 모바일 사이드바 토글 기능 개선 - 부모 컴포넌트에 이벤트 전달
  emit('toggle-mobile-menu')
}

// 검색 토글
const toggleSearch = () => {
  isSearchOpen.value = !isSearchOpen.value
  if (isSearchOpen.value) {
    nextTick(() => {
      searchInput.value?.focus()
    })
  }
}

// 2025-01-27: 통합 검색 함수들
const handleSearch = () => {
  // 이전 타이머가 있으면 취소
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
  }
  
  // 검색어가 없으면 결과 초기화
  if (!searchQuery.value.trim()) {
    searchResults.value = []
    return
  }
  
  // 300ms 후에 검색 실행 (디바운싱)
  searchTimeout.value = setTimeout(() => {
    performSearch()
  }, 300)
}

const performSearch = async () => {
  if (!searchQuery.value.trim()) return
  
  isSearching.value = true
  searchResults.value = []
  
  try {
    const api = useApi()
    const query = searchQuery.value.trim()
    
    // 장비 검색
    const devicesResponse = await api.devices.getAll()
    const devices = devicesResponse.devices || []
    
    // 직원 검색
    const employeesResponse = await api.employees.getAll()
    const employees = employeesResponse.employees || []
    
    const results: any[] = []
    
    // 장비 검색 결과 추가
    devices.forEach(device => {
      const searchableText = [
        device.asset_number,
        device.manufacturer,
        device.model_name,
        device.device_type,
        device.purpose
      ].join(' ').toLowerCase()
      
      if (searchableText.includes(query.toLowerCase())) {
        results.push({
          id: device.id,
          type: 'device',
          typeLabel: '장비',
          title: `${device.manufacturer || '제조사 미지정'} ${device.model_name || '모델명 미지정'}`,
          subtitle: `자산번호: ${device.asset_number}`,
          path: `/devices/${device.asset_number}`
        })
      }
    })
    
    // 직원 검색 결과 추가
    employees.forEach(employee => {
      const searchableText = [
        employee.name,
        employee.email,
        employee.department,
        employee.position
      ].join(' ').toLowerCase()
      
      if (searchableText.includes(query.toLowerCase())) {
        results.push({
          id: employee.id,
          type: 'employee',
          typeLabel: '직원',
          title: employee.name,
          subtitle: `${employee.department || '부서 미지정'} • ${employee.position || '직책 미지정'}`,
          path: `/employees/${employee.id}`
        })
      }
    })
    
    // 최대 10개 결과로 제한
    searchResults.value = results.slice(0, 10)
    
  } catch (error) {
    console.error('검색 실패:', error)
    searchResults.value = []
  } finally {
    isSearching.value = false
  }
}

const handleSearchEnter = () => {
  if (searchResults.value.length > 0) {
    handleResultClick(searchResults.value[0])
  }
}

const handleResultClick = (result: any) => {
  closeSearch()
  navigateTo(result.path)
}

// 검색 닫기
const closeSearch = () => {
  isSearchOpen.value = false
  searchQuery.value = ''
  searchResults.value = []
  isSearching.value = false
  
  // 타이머 정리
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
    searchTimeout.value = null
  }
}

// 알림 토글
const toggleNotifications = () => {
  // 알림 기능 구현
  console.log('알림 토글')
}

// 사용자 메뉴 토글
const toggleUserMenu = () => {
  isUserMenuOpen.value = !isUserMenuOpen.value
}

// 로그아웃 처리
const handleLogout = async () => {
  try {
    const authStore = useAuthStore()
    await authStore.logout()
    isUserMenuOpen.value = false
  } catch (error) {
    console.error('로그아웃 실패:', error)
  }
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

// 외부 클릭 감지
const handleClickOutside = (event: Event) => {
  if (userMenuRef.value && !userMenuRef.value.contains(event.target as Node)) {
    isUserMenuOpen.value = false
  }
}

// 키보드 이벤트 처리
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    isUserMenuOpen.value = false
    closeSearch()
  }
}

onMounted(() => {
  loadUserInfo()
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleKeydown)
  
  // 테스트용 알림 카운트
  notificationCount.value = 3
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleKeydown)
  
  // 2025-01-27: 검색 타이머 정리
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
  }
})
</script>

<style scoped>
/* 트렌디한 헤더 스타일 */
.header {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
  position: fixed;
  top: 0;
  left: 240px; /* 사이드바 너비만큼 오프셋 - 2024-12-19: UX 개선을 위해 조정 */
  right: 0;
  z-index: 40;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  transition: left 0.3s ease-in-out;
}

.header-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.5rem; /* 2024-12-19: UX 개선을 위해 좌우 패딩 축소 */
  max-width: 1400px;
  margin: 0 auto;
}

/* 왼쪽 섹션 */
.header-left {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.mobile-menu-button {
  display: none;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s ease;
}

.mobile-menu-button:hover {
  background: rgba(139, 92, 246, 0.1);
  color: #a855f7;
  transform: scale(1.05);
}

/* 브레드크럼 */
.breadcrumb {
  display: flex;
  align-items: center;
}

.breadcrumb-list {
  display: flex;
  align-items: center;
  list-style: none;
  margin: 0;
  padding: 0;
  gap: 0.5rem;
}

.breadcrumb-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.breadcrumb-link {
  color: #64748b;
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.3s ease;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
}

.breadcrumb-link:hover {
  color: #a855f7;
  background: rgba(139, 92, 246, 0.1);
}

.breadcrumb-current {
  color: #1e293b;
  font-size: 0.875rem;
  font-weight: 600;
}

.breadcrumb-separator {
  color: #94a3b8;
  flex-shrink: 0;
}

/* 중앙 섹션 */
.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
}

.page-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
  margin: 0;
  background: linear-gradient(135deg, #1e293b 0%, #475569 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* 오른쪽 섹션 */
.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

/* 헤더 버튼 */
.header-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  color: #64748b;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.header-button:hover {
  background: rgba(139, 92, 246, 0.1);
  color: #a855f7;
  transform: scale(1.05);
}

/* 알림 버튼 */
.notification-icon {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.notification-badge {
  position: absolute;
  top: -6px;
  right: -6px;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 18px;
  height: 18px;
  padding: 0 4px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border-radius: 9px;
  font-size: 0.75rem;
  font-weight: 600;
  border: 2px solid white;
}

/* 사용자 메뉴 */
.user-menu {
  position: relative;
}

.user-menu-button {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 1rem;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  color: #1e293b;
  cursor: pointer;
  transition: all 0.3s ease;
}

.user-menu-button:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.user-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
  border-radius: 8px;
  color: white;
  flex-shrink: 0;
}

.user-info {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  min-width: 0;
}

.user-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 150px;
}



.user-email {
  font-size: 0.75rem;
  color: #64748b;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 120px;
}

.user-menu-arrow {
  color: #64748b;
  transition: transform 0.3s ease;
  flex-shrink: 0;
}

.user-menu-arrow-rotated {
  transform: rotate(180deg);
}

/* 사용자 드롭다운 */
.user-dropdown {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 0.5rem;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 16px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
  min-width: 280px;
  z-index: 50;
  animation: dropdown-fade-in 0.3s ease;
}

@keyframes dropdown-fade-in {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.dropdown-header {
  padding: 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.dropdown-user-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.dropdown-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
  border-radius: 12px;
  color: white;
  flex-shrink: 0;
}

.dropdown-user-details {
  flex: 1;
  min-width: 0;
}

.dropdown-user-name {
  font-size: 1rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 0.25rem 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dropdown-user-email {
  font-size: 0.875rem;
  color: #64748b;
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.dropdown-menu {
  padding: 0.5rem;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.75rem 1rem;
  background: none;
  border: none;
  border-radius: 8px;
  color: #64748b;
  text-decoration: none;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.dropdown-item:hover {
  background: rgba(139, 92, 246, 0.1);
  color: #a855f7;
}

/* 검색 오버레이 */
.search-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding-top: 20vh;
  z-index: 1000;
  animation: overlay-fade-in 0.3s ease;
}

@keyframes overlay-fade-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.search-modal {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  width: 90%;
  max-width: 600px;
  animation: modal-slide-in 0.3s ease;
}

@keyframes modal-slide-in {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.search-input-wrapper {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: rgba(255, 255, 255, 0.8);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1rem 1.5rem;
  transition: all 0.3s ease;
}

.search-input-wrapper:focus-within {
  border-color: #a855f7;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

.search-icon {
  color: #64748b;
  flex-shrink: 0;
}

.search-input {
  flex: 1;
  background: none;
  border: none;
  outline: none;
  font-size: 1.125rem;
  color: #1e293b;
  font-weight: 500;
}

.search-input::placeholder {
  color: #94a3b8;
}

.search-close {
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
  flex-shrink: 0;
}

.search-close:hover {
  background: rgba(239, 68, 68, 0.2);
  transform: scale(1.05);
}

/* 2025-01-27: 검색 결과 스타일 */
.search-results {
  margin-top: 1rem;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 12px;
  overflow: hidden;
}

.search-results-header {
  padding: 0.75rem 1rem;
  background: rgba(139, 92, 246, 0.1);
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.search-results-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #a855f7;
}

.search-results-list {
  max-height: 400px;
  overflow-y: auto;
}

.search-result-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.search-result-item:last-child {
  border-bottom: none;
}

.search-result-item:hover {
  background: rgba(139, 92, 246, 0.1);
}

.result-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 8px;
  color: white;
  flex-shrink: 0;
}

.result-icon.device {
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
}

.result-icon.employee {
  background: linear-gradient(135deg, #10b981 0%, #047857 100%);
}

.result-content {
  flex: 1;
  min-width: 0;
}

.result-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 0.25rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.result-subtitle {
  font-size: 0.75rem;
  color: #64748b;
  margin-bottom: 0.25rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.result-type {
  font-size: 0.75rem;
  color: #a855f7;
  font-weight: 500;
}

.result-arrow {
  color: #94a3b8;
  flex-shrink: 0;
  transition: all 0.3s ease;
}

.search-result-item:hover .result-arrow {
  color: #a855f7;
  transform: translateX(4px);
}

/* 검색 결과 없음 */
.search-no-results {
  text-align: center;
  padding: 3rem 1rem;
}

.no-results-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  background: rgba(139, 92, 246, 0.1);
  border-radius: 16px;
  margin-bottom: 1rem;
  color: #a855f7;
}

.no-results-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 0.5rem;
}

.no-results-description {
  color: #64748b;
  font-size: 0.875rem;
}

/* 검색 로딩 */
.search-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 3rem 1rem;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid rgba(139, 92, 246, 0.2);
  border-top: 3px solid #a855f7;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  color: #64748b;
  font-size: 0.875rem;
}

/* 반응형 */
@media (max-width: 1024px) {
  .header-container {
    padding: 1rem;
  }
  
  .page-title {
    font-size: 1.25rem;
  }
  
  .user-info {
    display: none;
  }
  
  .user-menu-button {
    padding: 0.5rem;
  }
}

@media (max-width: 768px) {
  .mobile-menu-button {
    display: flex;
  }
  
  .breadcrumb {
    display: none;
  }
  
  .header-center {
    justify-content: flex-start;
  }
  
  .page-title {
    font-size: 1.125rem;
  }
  
  .header-right {
    gap: 0.5rem;
  }
  
  .header-button {
    width: 36px;
    height: 36px;
  }
  
  .user-menu-button {
    padding: 0.375rem;
  }
  
  .user-avatar {
    width: 28px;
    height: 28px;
  }
}

@media (max-width: 480px) {
  .header-container {
    padding: 0.75rem;
  }
  
  .page-title {
    font-size: 1rem;
  }
  
  .header-button {
    width: 32px;
    height: 32px;
  }
  
  .user-dropdown {
    min-width: 240px;
    right: -1rem;
  }
}
</style> 