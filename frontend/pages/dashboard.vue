<template>
  <div class="dashboard-container">
    <!-- 헤더 섹션 -->
    <div class="dashboard-header animate-fade-in-up">
      <div class="header-content">
        <div class="welcome-section">
          <h1 class="welcome-title">안녕하세요! 👋</h1>
          <p class="welcome-subtitle">{{ stats?.company_name || '데이터몬스' }}의 자산 현황을 확인해보세요</p>
        </div>
        <div class="header-actions">
          <button class="btn-gradient action-btn">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 5V19M5 12H19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            새로고침
          </button>
        </div>
      </div>
    </div>

    <!-- 통계 카드 섹션 -->
    <div class="stats-grid animate-fade-in-up" style="animation-delay: 0.1s;">
      <!-- 총 직원 수 -->
      <div class="stat-card">
        <div class="stat-icon employee-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M17 21V19C17 17.9391 16.5786 16.9217 15.8284 16.1716C15.0783 15.4214 14.0609 15 13 15H5C3.93913 15 2.92172 15.4214 2.17157 16.1716C1.42143 16.9217 1 17.9391 1 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M9 11C11.2091 11 13 9.20914 13 7C13 4.79086 11.2091 3 9 3C6.79086 3 5 4.79086 5 7C5 9.20914 6.79086 11 9 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M23 21V19C22.9993 18.1137 22.7044 17.2528 22.1614 16.5523C21.6184 15.8519 20.8581 15.3516 20 15.13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M16 3.13C16.8604 3.35031 17.623 3.85071 18.1676 4.55232C18.7122 5.25392 19.0078 6.11683 19.0078 7.005C19.0078 7.89317 18.7122 8.75608 18.1676 9.45768C17.623 10.1593 16.8604 10.6597 16 10.88" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <div class="stat-content">
          <h3 class="stat-label">총 직원 수</h3>
          <p class="stat-value">{{ stats?.total_employees || 0 }}</p>
          <p class="stat-change positive">+12% 이번 달</p>
        </div>
      </div>

      <!-- 총 장비 수 -->
      <div class="stat-card">
        <div class="stat-icon device-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
            <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
            <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
          </svg>
        </div>
        <div class="stat-content">
          <h3 class="stat-label">총 장비 수</h3>
          <p class="stat-value">{{ stats?.total_devices || 0 }}</p>
          <p class="stat-change positive">+8% 이번 주</p>
        </div>
      </div>

      <!-- 활성 장비 -->
      <div class="stat-card">
        <div class="stat-icon active-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M9 12L11 14L15 10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2"/>
          </svg>
        </div>
        <div class="stat-content">
          <h3 class="stat-label">활성 장비</h3>
          <p class="stat-value">{{ stats?.active_devices || 0 }}</p>
          <p class="stat-change positive">+15% 이번 달</p>
        </div>
      </div>

      <!-- 회사 정보 -->
      <div class="stat-card">
        <div class="stat-icon company-icon">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M3 9L12 2L21 9V20C21 20.5304 20.7893 21.0391 20.4142 21.4142C20.0391 21.7893 19.5304 22 19 22H5C4.46957 22 3.96086 21.7893 3.58579 21.4142C3.21071 21.0391 3 20.5304 3 20V9Z" stroke="currentColor" stroke-width="2"/>
            <polyline points="9,22 9,12 15,12 15,22" stroke="currentColor" stroke-width="2"/>
          </svg>
        </div>
        <div class="stat-content">
          <h3 class="stat-label">회사명</h3>
          <p class="stat-value company-name">{{ stats?.company_name || '데이터몬스' }}</p>
          <p class="stat-change neutral">현재 상태</p>
        </div>
      </div>
    </div>

    <!-- 차트 및 상세 정보 섹션 -->
    <div class="charts-section animate-fade-in-up" style="animation-delay: 0.2s;">
      <div class="charts-grid">
        <!-- 부서별 분포 -->
        <div class="chart-card">
          <div class="chart-header">
            <h3 class="chart-title">부서별 장비 분포</h3>
            <div class="chart-legend">
              <span class="legend-item">
                <span class="legend-color employee-color"></span>
                직원
              </span>
              <span class="legend-item">
                <span class="legend-color device-color"></span>
                장비
              </span>
            </div>
          </div>
          <div class="chart-content">
            <div v-if="dashboard?.department_distribution?.length" class="department-list">
              <div 
                v-for="dept in dashboard.department_distribution" 
                :key="dept.department"
                class="department-item"
              >
                <div class="department-info">
                  <div class="department-name">{{ dept.department }}</div>
                  <div class="department-stats">
                    <span class="stat-badge employee-badge">{{ dept.employee_count }}명</span>
                    <span class="stat-badge device-badge">{{ dept.device_count }}개</span>
                  </div>
                </div>
                <div class="department-bar">
                  <div class="bar-segment employee-segment" :style="{ width: `${(dept.employee_count / maxEmployees) * 100}%` }"></div>
                  <div class="bar-segment device-segment" :style="{ width: `${(dept.device_count / maxDevices) * 100}%` }"></div>
                </div>
              </div>
            </div>
            <div v-else class="empty-state">
              <div class="empty-icon">
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M9 19V13H15V19M9 19H15M9 19V11H15V19M9 19H5M15 19H19M15 19V11M9 11V5H15V11M9 11H5M15 11H19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
              <p class="empty-text">부서별 데이터가 없습니다</p>
            </div>
          </div>
        </div>

        <!-- 최근 활동 -->
        <div class="chart-card">
          <div class="chart-header">
            <h3 class="chart-title">최근 등록 현황</h3>
            <div class="chart-actions">
              <button class="chart-btn">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 5V19M5 12H19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
            </div>
          </div>
          <div class="chart-content">
            <div v-if="dashboard?.recent_employees?.length || dashboard?.recent_devices?.length" class="recent-list">
              <!-- 최근 직원 -->
              <div v-for="employee in dashboard?.recent_employees?.slice(0, 3)" :key="employee.id" class="recent-item">
                <div class="recent-icon employee-icon">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M20 21V19C20 17.9391 19.5786 16.9217 18.8284 16.1716C18.0783 15.4214 17.0609 15 16 15H8C6.93913 15 5.92172 15.4214 5.17157 16.1716C4.42143 16.9217 4 17.9391 4 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M12 11C14.2091 11 16 9.20914 16 7C16 4.79086 14.2091 3 12 3C9.79086 3 8 4.79086 8 7C8 9.20914 9.79086 11 12 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div class="recent-content">
                  <div class="recent-title">{{ employee.name }}</div>
                  <div class="recent-subtitle">{{ employee.department }} • {{ employee.position }}</div>
                </div>
                <div class="recent-time">{{ formatDate(employee.created_at) }}</div>
              </div>

              <!-- 최근 장비 -->
              <div v-for="device in dashboard?.recent_devices?.slice(0, 3)" :key="device.id" class="recent-item">
                <div class="recent-icon device-icon">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                    <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
                    <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
                  </svg>
                </div>
                <div class="recent-content">
                  <div class="recent-title">{{ device.asset_number }}</div>
                  <div class="recent-subtitle">{{ device.manufacturer }} {{ device.model_name }}</div>
                </div>
                <div class="recent-time">{{ formatDate(device.created_at) }}</div>
              </div>
            </div>
            <div v-else class="empty-state">
              <div class="empty-icon">
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 8V12L15 15" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
              <p class="empty-text">최근 활동이 없습니다</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { DashboardStats, DashboardData } from '~/types'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

// 2025-01-27: 배포 환경에서 useAuthStore 오류 해결을 위해 명시적 import 추가
import { useAuthStore } from '~/stores/auth'

const { dashboard: dashboardApi } = useApi()
const authStore = useAuthStore()

// Reactive data
const stats = ref<DashboardStats | null>(null)
const dashboard = ref<DashboardData | null>(null)
const loading = ref(true)

// Computed properties
const maxEmployees = computed(() => {
  if (!dashboard.value?.department_distribution) return 1
  return Math.max(...dashboard.value.department_distribution.map(d => d.employee_count))
})

const maxDevices = computed(() => {
  if (!dashboard.value?.department_distribution) return 1
  return Math.max(...dashboard.value.department_distribution.map(d => d.device_count))
})

// Methods
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  const now = new Date()
  const diffTime = Math.abs(now.getTime() - date.getTime())
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  
  if (diffDays === 1) return '오늘'
  if (diffDays === 2) return '어제'
  if (diffDays <= 7) return `${diffDays - 1}일 전`
  return date.toLocaleDateString('ko-KR')
}

// Load dashboard data
const loadDashboardData = async () => {
  try {
    loading.value = true
    
    console.log('🔍 [DASHBOARD] Loading dashboard data...')
    
    // Load stats
    const statsResponse = await dashboardApi.getStats()
    stats.value = statsResponse.stats
    
    console.log('🔍 [DASHBOARD] Stats loaded:', stats.value)
    
    // Load dashboard data
    const dashboardResponse = await dashboardApi.getDashboard()
    dashboard.value = dashboardResponse.dashboard
    
    console.log('🔍 [DASHBOARD] Dashboard data loaded:', dashboard.value)
    
  } catch (error) {
    console.error('Failed to load dashboard data:', error)
  } finally {
    loading.value = false
  }
}

// Load data on mount
onMounted(() => {
  loadDashboardData()
})
</script>

<style scoped>
.dashboard-container {
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.dashboard-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 32px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.welcome-title {
  font-size: 32px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.welcome-subtitle {
  color: #6b7280;
  font-size: 16px;
  font-weight: 500;
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.employee-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.device-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.active-icon {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.company-icon {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  font-weight: 600;
  color: #6b7280;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 4px;
}

.company-name {
  font-size: 20px;
}

.stat-change {
  font-size: 12px;
  font-weight: 600;
}

.stat-change.positive {
  color: #10b981;
}

.stat-change.negative {
  color: #ef4444;
}

.stat-change.neutral {
  color: #6b7280;
}

.charts-section {
  margin-bottom: 32px;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 24px;
}

.chart-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.chart-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.chart-legend {
  display: flex;
  gap: 16px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #6b7280;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.employee-color {
  background: #667eea;
}

.device-color {
  background: #4facfe;
}

.chart-actions {
  display: flex;
  gap: 8px;
}

.chart-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  background: rgba(102, 126, 234, 0.1);
  border: none;
  color: #667eea;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-btn:hover {
  background: rgba(102, 126, 234, 0.2);
  transform: scale(1.05);
}

.department-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.department-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.department-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.department-name {
  font-weight: 600;
  color: #1f2937;
}

.department-stats {
  display: flex;
  gap: 8px;
}

.stat-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
}

.employee-badge {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.device-badge {
  background: rgba(79, 172, 254, 0.1);
  color: #4facfe;
}

.department-bar {
  height: 8px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 4px;
  overflow: hidden;
  display: flex;
}

.bar-segment {
  height: 100%;
  transition: width 0.3s ease;
}

.employee-segment {
  background: #667eea;
}

.device-segment {
  background: #4facfe;
}

.recent-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.recent-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 12px;
  background: rgba(0, 0, 0, 0.02);
  transition: all 0.3s ease;
}

.recent-item:hover {
  background: rgba(102, 126, 234, 0.05);
  transform: translateX(4px);
}

.recent-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.recent-content {
  flex: 1;
}

.recent-title {
  font-weight: 600;
  color: #1f2937;
  font-size: 14px;
}

.recent-subtitle {
  color: #6b7280;
  font-size: 12px;
}

.recent-time {
  font-size: 11px;
  color: #9ca3af;
  font-weight: 500;
}

.empty-state {
  text-align: center;
  padding: 48px 24px;
}

.empty-icon {
  width: 64px;
  height: 64px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  color: #9ca3af;
}

.empty-text {
  color: #6b7280;
  font-size: 14px;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
  .dashboard-container {
    padding: 16px;
  }
  
  .header-content {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .welcome-title {
    font-size: 24px;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .charts-grid {
    grid-template-columns: 1fr;
  }
  
  .stat-card {
    padding: 20px;
  }
  
  .stat-value {
    font-size: 24px;
  }
}
</style> 