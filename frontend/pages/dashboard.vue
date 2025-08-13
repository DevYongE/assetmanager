<template>
  <div class="dashboard-page">
    <!-- 히어로 섹션 -->
    <div class="hero-section">
      <div class="hero-content">
        <div class="welcome-message">
          <h1 class="hero-title">
            안녕하세요, <span class="gradient-text">{{ user?.company_name || '사용자' }}</span>님! 👋
          </h1>
                <p class="hero-subtitle">
        <span class="company-name" v-if="user?.company_name">{{ user.company_name }}</span><span v-else>귀하의</span> 효율적인 인벤토리 관리를 시작해보세요
      </p>
        </div>
        <div class="hero-stats">
          <div class="stat-card">
            <div class="stat-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <div class="stat-info">
              <span class="stat-number">{{ stats.totalDevices }}</span>
              <span class="stat-label">총 장비</span>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <div class="stat-info">
              <span class="stat-number">{{ stats.totalEmployees }}</span>
              <span class="stat-label">총 직원</span>
            </div>
          </div>
          <div class="stat-card">
            <div class="stat-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 12l2 2 4-4"/>
                <path d="M21 12c-1 0-2-1-2-2s1-2 2-2 2 1 2 2-1 2-2 2z"/>
                <path d="M3 12c1 0 2-1 2-2s-1-2-2-2-2 1-2 2 1 2 2 2z"/>
                <path d="M12 3c0 1-1 2-2 2s-2-1-2-2 1-2 2-2 2 1 2 2z"/>
                <path d="M12 21c0-1 1-2 2-2s2 1 2 2-1 2-2 2-2-1-2-2z"/>
              </svg>
            </div>
            <div class="stat-info">
              <span class="stat-number">{{ stats.activeDevices }}</span>
              <span class="stat-label">사용 중</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 메인 컨텐츠 -->
    <div class="main-content">
      <!-- 빠른 액션 -->
      <div class="section-card">
        <h2 class="section-title">빠른 액션</h2>
        <div class="quick-actions">
          <div class="action-card" @click="navigateTo('/qr-generator')">
            <div class="action-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 9h6v12H3z"/>
                <path d="M9 3h12v18H9z"/>
                <path d="M15 9h6"/>
                <path d="M15 15h6"/>
                <path d="M9 9h6"/>
                <path d="M9 15h6"/>
              </svg>
            </div>
            <h3 class="action-title">QR 코드 생성</h3>
            <p class="action-description">장비와 직원용 QR 코드를 생성하세요</p>
          </div>
          
          <div class="action-card" @click="navigateTo('/qr-scanner')">
            <div class="action-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 9h6v12H3z"/>
                <path d="M9 3h12v18H9z"/>
                <path d="M15 9h6"/>
                <path d="M15 15h6"/>
                <path d="M9 9h6"/>
                <path d="M9 15h6"/>
              </svg>
            </div>
            <h3 class="action-title">QR 코드 스캔</h3>
            <p class="action-description">QR 코드를 스캔하여 정보를 확인하세요</p>
          </div>
          
          <div class="action-card" @click="navigateTo('/devices')">
            <div class="action-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <h3 class="action-title">장비 관리</h3>
            <p class="action-description">장비 정보를 추가하고 관리하세요</p>
          </div>
          
          <div class="action-card" @click="navigateTo('/employees')">
            <div class="action-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <h3 class="action-title">직원 관리</h3>
            <p class="action-description">직원 정보를 추가하고 관리하세요</p>
          </div>
        </div>
      </div>

      <!-- 최근 활동 -->
      <div class="section-card">
        <h2 class="section-title">최근 활동</h2>
        <div class="recent-activities">
          <div v-if="recentActivities.length === 0" class="empty-state">
            <div class="empty-icon">
              <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12,6 12,12 16,14"/>
              </svg>
            </div>
            <h3 class="empty-title">아직 활동이 없습니다</h3>
            <p class="empty-description">새로운 장비를 추가하거나 QR 코드를 생성해보세요</p>
          </div>
          
          <div v-else class="activity-list">
            <div 
              v-for="activity in recentActivities" 
              :key="activity.id"
              class="activity-item"
            >
              <div class="activity-icon" :class="activity.type">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path v-if="activity.type === 'device'" d="M3 9h6v12H3z"/>
                  <path v-if="activity.type === 'device'" d="M9 3h12v18H9z"/>
                  <path v-if="activity.type === 'employee'" d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                  <circle v-if="activity.type === 'employee'" cx="12" cy="7" r="4"/>
                  <path v-if="activity.type === 'qr'" d="M3 9h6v12H3z"/>
                  <path v-if="activity.type === 'qr'" d="M9 3h12v18H9z"/>
                </svg>
              </div>
              <div class="activity-content">
                <h4 class="activity-title">{{ activity.title }}</h4>
                <p class="activity-description">{{ activity.description }}</p>
                <span class="activity-time">{{ formatTime(activity.createdAt) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 장비 상태 요약 -->
      <div class="section-card">
        <h2 class="section-title">장비 상태 요약</h2>
        <div class="device-status-grid">
          <div class="status-card active">
            <div class="status-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M9 12l2 2 4-4"/>
                <path d="M21 12c-1 0-2-1-2-2s1-2 2-2 2 1 2 2-1 2-2 2z"/>
                <path d="M3 12c1 0 2-1 2-2s-1-2-2-2-2 1-2 2 1 2 2 2z"/>
                <path d="M12 3c0 1-1 2-2 2s-2-1-2-2 1-2 2-2 2 1 2 2z"/>
                <path d="M12 21c0-1 1-2 2-2s2 1 2 2-1 2-2 2-2-1-2-2z"/>
              </svg>
            </div>
            <div class="status-info">
              <span class="status-number">{{ stats.activeDevices }}</span>
              <span class="status-label">사용 중</span>
            </div>
          </div>
          
          <div class="status-card inactive">
            <div class="status-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <line x1="15" y1="9" x2="9" y2="15"/>
                <line x1="9" y1="9" x2="15" y2="15"/>
              </svg>
            </div>
            <div class="status-info">
              <span class="status-number">{{ stats.inactiveDevices }}</span>
              <span class="status-label">미사용</span>
            </div>
          </div>
          
          <div class="status-card maintenance">
            <div class="status-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>
              </svg>
            </div>
            <div class="status-info">
              <span class="status-number">{{ stats.maintenanceDevices }}</span>
              <span class="status-label">정비 중</span>
            </div>
          </div>
          
          <div class="status-card retired">
            <div class="status-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 6h18"/>
                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/>
                <path d="M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
              </svg>
            </div>
            <div class="status-info">
              <span class="status-number">{{ stats.retiredDevices }}</span>
              <span class="status-label">폐기</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 최근 추가된 장비 -->
      <div class="section-card">
        <h2 class="section-title">최근 추가된 장비</h2>
        <div class="recent-devices">
          <div v-if="recentDevices.length === 0" class="empty-state">
            <div class="empty-icon">
              <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <h3 class="empty-title">아직 장비가 없습니다</h3>
            <p class="empty-description">첫 번째 장비를 추가해보세요</p>
            <BaseButton
              label="장비 추가"
              variant="accent"
              :icon="'M12 5v14M5 12h14'"
              @click="navigateTo('/devices')"
            />
          </div>
          
          <div v-else class="device-list">
            <div 
              v-for="device in recentDevices" 
              :key="device.id"
              class="device-item"
              @click="navigateTo(`/devices/edit/${device.id}`)"
            >
              <div class="device-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                  <line x1="8" y1="21" x2="16" y2="21"/>
                  <line x1="12" y1="17" x2="12" y2="21"/>
                </svg>
              </div>
              <div class="device-info">
                <h4 class="device-name">{{ device.manufacturer }} {{ device.model_name }}</h4>
                <p class="device-number">{{ device.asset_number }}</p>
                <span class="device-status" :class="device.status">
                  {{ getStatusText(device.status) }}
                </span>
              </div>
              <div class="device-arrow">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="9,18 15,12 9,6"/>
                </svg>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2024-12-19: 트렌디한 UI 디자인으로 대시보드 페이지 완전 재설계

import { ref, computed, onMounted } from 'vue'
import { defineAsyncComponent } from 'vue'

const BaseButton = defineAsyncComponent(() => import('~/components/BaseButton.vue'))

// 2024-12-19: useApi composable 사용 준비
// useApi는 composable이므로 직접 호출하여 사용

// 상태 관리
const user = ref<any>(null)
const stats = ref({
  totalDevices: 0,
  totalEmployees: 0,
  activeDevices: 0,
  inactiveDevices: 0,
  maintenanceDevices: 0,
  retiredDevices: 0
})

const recentActivities = ref<any[]>([])
const recentDevices = ref<any[]>([])

// 상태 텍스트 변환
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    active: '사용 중',
    inactive: '미사용',
    maintenance: '정비 중',
    retired: '폐기'
  }
  return statusMap[status] || status
}

// 시간 포맷팅
const formatTime = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffInHours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60))
  
  if (diffInHours < 1) return '방금 전'
  if (diffInHours < 24) return `${diffInHours}시간 전`
  
  const diffInDays = Math.floor(diffInHours / 24)
  if (diffInDays < 7) return `${diffInDays}일 전`
  
  return date.toLocaleDateString('ko-KR')
}

// 데이터 로드
const loadDashboardData = async () => {
  try {
    const api = useApi()
    
    // 통계 데이터 로드
    const statsResponse = await api.dashboard.getStats()
    // 2024-12-19: DashboardStats 타입을 로컬 stats 객체 구조에 맞게 매핑
    stats.value = {
      totalDevices: statsResponse.stats.total_devices,
      totalEmployees: statsResponse.stats.total_employees,
      activeDevices: statsResponse.stats.active_devices,
      inactiveDevices: 0, // 백엔드에서 제공하지 않는 필드
      maintenanceDevices: 0, // 백엔드에서 제공하지 않는 필드
      retiredDevices: 0 // 백엔드에서 제공하지 않는 필드
    }
    
    // 최근 활동 로드 (임시로 빈 배열 사용 - 백엔드에 해당 엔드포인트가 없음)
    recentActivities.value = []
    
    // 최근 장비 로드
    const devicesResponse = await api.devices.getAll()
    recentDevices.value = devicesResponse.devices.slice(0, 5) // 최근 5개만 표시
    
  } catch (error) {
    console.error('대시보드 데이터 로드 실패:', error)
    
    // 테스트 데이터 (개발용)
    stats.value = {
      totalDevices: 24,
      totalEmployees: 12,
      activeDevices: 18,
      inactiveDevices: 4,
      maintenanceDevices: 1,
      retiredDevices: 1
    }
    
    recentActivities.value = [
      {
        id: 1,
        type: 'device',
        title: '새 장비 추가',
        description: 'MacBook Pro 16인치가 추가되었습니다',
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString()
      },
      {
        id: 2,
        type: 'qr',
        title: 'QR 코드 생성',
        description: '장비 QR 코드가 생성되었습니다',
        createdAt: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString()
      }
    ]
    
    recentDevices.value = [
      {
        id: 1,
        manufacturer: 'Apple',
        model_name: 'MacBook Pro 16"',
        asset_number: 'MBP-001',
        status: 'active'
      },
      {
        id: 2,
        manufacturer: 'Dell',
        model_name: 'XPS 15',
        asset_number: 'DLL-002',
        status: 'active'
      }
    ]
  }
}

// 사용자 정보 로드
const loadUserInfo = () => {
  const authStore = useAuthStore()
  user.value = authStore.user
}

onMounted(() => {
  loadUserInfo()
  loadDashboardData()
})
</script>

<style scoped>
/* 트렌디한 대시보드 페이지 스타일 */
.dashboard-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  padding: 2rem 0;
}

/* 히어로 섹션 */
.hero-section {
  margin-bottom: 3rem;
  padding: 0 2rem;
}

.hero-content {
  max-width: 1200px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 3rem;
  align-items: center;
}

.welcome-message {
  text-align: left;
}

.hero-title {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 1rem;
  line-height: 1.2;
  color: #1e293b;
}

.hero-subtitle {
  font-size: 1.25rem;
  color: #64748b;
  line-height: 1.6;
}

.company-name {
  color: #8b5cf6;
  font-weight: 600;
}

.hero-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 12px;
  color: white;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
  line-height: 1;
}

.stat-label {
  font-size: 0.875rem;
  color: #64748b;
  margin-top: 0.25rem;
}

/* 메인 컨텐츠 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 2rem;
}

/* 섹션 카드 */
.section-card {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 24px;
  padding: 2rem;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  transition: all 0.3s ease;
}

.section-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  color: #1e293b;
}

/* 빠른 액션 */
.quick-actions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.action-card {
  background: rgba(255, 255, 255, 0.6);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1.5rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.action-card::before {
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

.action-card:hover {
  transform: translateY(-8px);
  border-color: rgba(139, 92, 246, 0.5);
  box-shadow: 0 20px 25px -5px rgba(139, 92, 246, 0.2);
}

.action-card:hover::before {
  opacity: 1;
}

.action-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 16px;
  margin-bottom: 1rem;
  color: white;
}

.action-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #1e293b;
}

.action-description {
  color: #64748b;
  font-size: 0.875rem;
  line-height: 1.5;
}

/* 최근 활동 */
.recent-activities {
  min-height: 200px;
}

.activity-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  transition: all 0.3s ease;
}

.activity-item:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateX(4px);
}

.activity-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 10px;
  color: white;
}

.activity-icon.device {
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
}

.activity-icon.employee {
  background: linear-gradient(135deg, #10b981 0%, #047857 100%);
}

.activity-icon.qr {
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
}

.activity-content {
  flex: 1;
}

.activity-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 0.25rem;
}

.activity-description {
  font-size: 0.75rem;
  color: #64748b;
  margin-bottom: 0.25rem;
}

.activity-time {
  font-size: 0.75rem;
  color: #94a3b8;
}

/* 장비 상태 요약 */
.device-status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
}

.status-card {
  background: rgba(255, 255, 255, 0.6);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1.5rem;
  text-align: center;
  transition: all 0.3s ease;
}

.status-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.status-card.active {
  border-color: rgba(16, 185, 129, 0.3);
}

.status-card.inactive {
  border-color: rgba(100, 116, 139, 0.3);
}

.status-card.maintenance {
  border-color: rgba(245, 158, 11, 0.3);
}

.status-card.retired {
  border-color: rgba(239, 68, 68, 0.3);
}

.status-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 12px;
  margin-bottom: 1rem;
  color: white;
}

.status-card.active .status-icon {
  background: linear-gradient(135deg, #10b981 0%, #047857 100%);
}

.status-card.inactive .status-icon {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
}

.status-card.maintenance .status-icon {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.status-card.retired .status-icon {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
}

.status-number {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1e293b;
  display: block;
  line-height: 1;
}

.status-label {
  font-size: 0.875rem;
  color: #64748b;
  margin-top: 0.25rem;
}

/* 최근 장비 */
.recent-devices {
  min-height: 200px;
}

.device-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.device-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.device-item:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateX(4px);
}

.device-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
  border-radius: 10px;
  color: white;
}

.device-info {
  flex: 1;
}

.device-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 0.25rem;
}

.device-number {
  font-size: 0.75rem;
  color: #64748b;
  margin-bottom: 0.25rem;
}

.device-status {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  display: inline-block;
}

.device-status.active {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.device-status.inactive {
  background: rgba(100, 116, 139, 0.1);
  color: #475569;
}

.device-status.maintenance {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.device-status.retired {
  background: rgba(239, 68, 68, 0.1);
  color: #dc2626;
}

.device-arrow {
  color: #94a3b8;
  transition: all 0.3s ease;
}

.device-item:hover .device-arrow {
  color: #64748b;
  transform: translateX(4px);
}

/* 빈 상태 */
.empty-state {
  text-align: center;
  padding: 3rem 1rem;
}

.empty-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  background: rgba(139, 92, 246, 0.1);
  border-radius: 20px;
  margin-bottom: 1.5rem;
  color: #a855f7;
}

.empty-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 0.5rem;
}

.empty-description {
  color: #64748b;
  margin-bottom: 1.5rem;
}

/* 반응형 */
@media (max-width: 1024px) {
  .hero-content {
    grid-template-columns: 1fr;
    gap: 2rem;
    text-align: center;
  }
  
  .welcome-message {
    text-align: center;
  }
  
  .hero-stats {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }
  
  .hero-stats {
    grid-template-columns: 1fr;
  }
  
  .main-content {
    grid-template-columns: 1fr;
    padding: 0 1rem;
  }
  
  .section-card {
    padding: 1.5rem;
  }
  
  .quick-actions {
    grid-template-columns: 1fr;
  }
  
  .device-status-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .hero-section {
    padding: 0 1rem;
  }
}

@media (max-width: 480px) {
  .device-status-grid {
    grid-template-columns: 1fr;
  }
}
</style>