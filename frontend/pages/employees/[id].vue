<template>
  <div class="employee-detail-container">
    <!-- 로딩 상태 -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p class="loading-text">직원 정보를 불러오는 중...</p>
    </div>

    <!-- 에러 상태 -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
          <line x1="15" y1="9" x2="9" y2="15" stroke="currentColor" stroke-width="2"/>
          <line x1="9" y1="9" x2="15" y2="15" stroke="currentColor" stroke-width="2"/>
        </svg>
      </div>
      <h3 class="error-title">직원 정보를 불러올 수 없습니다</h3>
      <p class="error-message">{{ error }}</p>
      <button @click="loadEmployee" class="btn-gradient retry-btn">
        다시 시도
      </button>
    </div>

    <!-- 메인 콘텐츠 -->
    <div v-else-if="employee" class="main-content">
      <!-- 헤더 -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-info">
            <div class="breadcrumb">
              <NuxtLink to="/employees" class="breadcrumb-link">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M19 12H5M12 19L5 12L12 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                직원 관리
              </NuxtLink>
              <span class="breadcrumb-separator">/</span>
              <span class="breadcrumb-current">{{ employee?.name || '로딩 중...' }}</span>
            </div>
            <h1 class="page-title">{{ employee?.name ? `${employee.name}님 정보` : '직원 정보' }}</h1>
            <p class="page-subtitle">{{ employee?.department && employee?.position ? `${employee.department} - ${employee.position}` : '정보 로딩 중...' }}</p>
          </div>
          <div class="header-actions">
            <!-- 2025-01-27: 퇴사 상태 표시 -->
            <div v-if="employee?.status === 'resigned'" class="resigned-badge">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9 12L11 14L15 10M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              퇴사
            </div>
            
            <button @click="editEmployee" class="btn-gradient edit-btn">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11 4H4C3.46957 4 2.96086 4.21071 2.58579 4.58579C2.21071 4.96086 2 5.46957 2 6V20C2 20.5304 2.21071 21.0391 2.58579 21.4142C2.96086 21.7893 3.46957 22 4 22H18C18.5304 22 19.0391 21.7893 19.4142 21.4142C19.7893 21.0391 20 20.5304 20 20V13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M18.5 2.5C18.8978 2.10217 19.4374 1.87868 20 1.87868C20.5626 1.87868 21.1022 2.10217 21.5 2.5C21.8978 2.89782 22.1213 3.43739 22.1213 4C22.1213 4.56261 21.8978 5.10217 21.5 5.5L12 15L8 16L9 12L18.5 2.5Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              수정
            </button>
            
            <!-- 2025-01-27: 퇴사 버튼 (재직 중인 직원만 표시) -->
            <button 
              v-if="employee?.status !== 'resigned'" 
              @click="showResignModal = true" 
              class="btn-danger resign-btn"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              퇴사 처리
            </button>
          </div>
        </div>
      </div>

      <!-- 직원 정보 그리드 -->
      <div class="content-grid">
        <!-- 기본 정보 카드 -->
        <div class="info-card">
          <div class="card-header">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M17 21V19C17 17.9391 16.5786 16.9217 15.8284 16.1716C15.0783 15.4214 14.0609 15 13 15H5C3.93913 15 2.92172 15.4214 2.17157 16.1716C1.42143 16.9217 1 17.9391 1 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M9 11C11.2091 11 13 9.20914 13 7C13 4.79086 11.2091 3 9 3C6.79086 3 5 4.79086 5 7C5 9.20914 6.79086 11 9 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              기본 정보
            </h3>
          </div>
          <div class="card-content">
            <div class="employee-profile">
              <div class="employee-avatar-large">
                <span class="avatar-text">{{ employee.name.charAt(0) }}</span>
              </div>
              <div class="employee-details">
                <h2 class="employee-name-large">{{ employee.name }}</h2>
                <p class="employee-position-large">{{ employee.position }}</p>
                <p class="employee-department-large">{{ employee.department }}</p>
              </div>
            </div>
            <div class="info-grid">
              <div class="info-item">
                <label class="info-label">이름</label>
                <span class="info-value">{{ employee.name }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">부서</label>
                <span class="info-value">{{ employee.department }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">직급</label>
                <span class="info-value">{{ employee.position }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">회사명</label>
                <span class="info-value">{{ employee.company_name }}</span>
              </div>
              <div class="info-item" v-if="employee.email">
                <label class="info-label">이메일</label>
                <span class="info-value">{{ employee.email }}</span>
              </div>
                             <div class="info-item">
                 <label class="info-label">등록일</label>
                 <span class="info-value">{{ formatDate(employee.created_at) }}</span>
               </div>
               <!-- 2025-01-27: 퇴사일 표시 (퇴사한 직원만) -->
               <div v-if="employee.status === 'resigned' && employee.resigned_at" class="info-item">
                 <label class="info-label">퇴사일</label>
                 <span class="info-value">{{ formatDate(employee.resigned_at) }}</span>
               </div>
            </div>
          </div>
        </div>

        <!-- 통계 카드 -->
        <div class="info-card">
          <div class="card-header">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9 19C9 19.5304 9.21071 20.0391 9.58579 20.4142C9.96086 20.7893 10.4696 21 11 21H13C13.5304 21 14.0391 20.7893 14.4142 20.4142C14.7893 20.0391 15 19.5304 15 19V17H9V19Z" stroke="currentColor" stroke-width="2"/>
                <path d="M5 7H19V17H5V7Z" stroke="currentColor" stroke-width="2"/>
                <path d="M7 7V5C7 4.46957 7.21071 3.96086 7.58579 3.58579C7.96086 3.21071 8.46957 3 9 3H15C15.5304 3 16.0391 3.21071 16.4142 3.58579C16.7893 3.96086 17 4.46957 17 5V7" stroke="currentColor" stroke-width="2"/>
              </svg>
              장비 통계
            </h3>
          </div>
          <div class="card-content">
            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-icon">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                    <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
                    <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
                  </svg>
                </div>
                <div class="stat-content">
                  <h4 class="stat-value">{{ devices.length }}</h4>
                  <p class="stat-label">총 장비 수</p>
                </div>
              </div>
              <div class="stat-item">
                <div class="stat-icon">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M9 12L11 14L15 10M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                </div>
                <div class="stat-content">
                  <h4 class="stat-value">{{ deviceTypes.length }}</h4>
                  <p class="stat-label">장비 종류</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 보유 장비 목록 -->
      <div class="devices-section">
        <div class="section-header">
          <h2 class="section-title">보유 장비 목록</h2>
          <p class="section-subtitle">{{ employee.name }}님이 현재 사용 중인 장비입니다</p>
        </div>
        
        <!-- 장비 목록 -->
        <div v-if="devices.length" class="devices-grid">
          <div 
            v-for="device in devices" 
            :key="device.id"
            class="device-card"
            @click="viewDevice(device.asset_number)"
          >
            <div class="device-header">
              <div class="device-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                  <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
                  <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
              <div class="device-status">
                <span class="status-badge assigned">할당됨</span>
              </div>
            </div>
            
            <div class="device-info">
              <h3 class="device-name">{{ device.asset_number }}</h3>
              <p class="device-model">{{ device.manufacturer }} {{ device.model_name }}</p>
              <div class="device-details">
                <span class="detail-item">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M9 12L11 14L15 10M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  {{ device.device_type || '일반 장비' }}
                </span>
                <span class="detail-item" v-if="device.purpose">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M9 12L11 14L15 10M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  {{ device.purpose }}
                </span>
              </div>
            </div>
            
            <div class="device-footer">
              <span class="device-date">등록: {{ formatDate(device.created_at) }}</span>
            </div>
          </div>
        </div>

        <!-- 빈 상태 -->
        <div v-else class="empty-state">
          <div class="empty-icon">
            <svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
              <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
              <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
            </svg>
          </div>
          <h3 class="empty-title">할당된 장비가 없습니다</h3>
          <p class="empty-text">{{ employee.name }}님에게 아직 장비가 할당되지 않았습니다</p>
        </div>
      </div>
    </div>

    <!-- 2025-01-27: 직원 수정 모달 -->
    <EmployeeModal 
      v-if="showEditModal"
      :employee="employee"
      @close="closeEditModal"
      @saved="onEmployeeUpdated"
    />
    
    <!-- 2025-01-27: 퇴사 처리 모달 -->
    <div v-if="showResignModal" class="modal-overlay" @click="closeResignModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">퇴사 처리</h3>
          <button @click="closeResignModal" class="modal-close">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <line x1="18" y1="6" x2="6" y2="18" stroke="currentColor" stroke-width="2"/>
              <line x1="6" y1="6" x2="18" y2="18" stroke="currentColor" stroke-width="2"/>
            </svg>
          </button>
        </div>
        
        <div class="modal-body">
          <div class="warning-message">
            <div class="warning-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" stroke="currentColor" stroke-width="2"/>
                <line x1="12" y1="9" x2="12" y2="13" stroke="currentColor" stroke-width="2"/>
                <line x1="12" y1="17" x2="12.01" y2="17" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <h4 class="warning-title">{{ employee?.name }}님의 퇴사를 처리하시겠습니까?</h4>
            <p class="warning-description">
              퇴사 처리 시 다음 작업이 수행됩니다:
            </p>
            <ul class="warning-list">
              <li>직원 상태가 '퇴사'로 변경됩니다</li>
              <li>연결된 모든 장비가 자동으로 반납 처리됩니다</li>
              <li>이 작업은 되돌릴 수 없습니다</li>
            </ul>
          </div>
          
          <div v-if="devices.length > 0" class="device-return-section">
            <h5 class="device-return-title">반납될 장비 목록</h5>
            <div class="device-return-list">
              <div 
                v-for="device in devices" 
                :key="device.id"
                class="device-return-item"
              >
                <div class="device-return-icon">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                    <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
                    <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
                  </svg>
                </div>
                <div class="device-return-info">
                  <span class="device-return-name">{{ device.asset_number }}</span>
                  <span class="device-return-model">{{ device.manufacturer }} {{ device.model_name }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="modal-footer">
          <button @click="closeResignModal" class="btn-secondary cancel-btn">
            취소
          </button>
          <button @click="processResignation" class="btn-danger confirm-btn" :disabled="processingResignation">
            <div v-if="processingResignation" class="loading-spinner-small"></div>
            {{ processingResignation ? '처리 중...' : '퇴사 처리' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

// 2025-01-27: EmployeeModal 컴포넌트 import
import EmployeeModal from '~/components/EmployeeModal.vue'

const route = useRoute()
const router = useRouter()
const { employees: employeesApi, devices: devicesApi } = useApi()

// Reactive data
const employee = ref<any>(null)
const devices = ref<any[]>([])
const loading = ref(true)
const error = ref<string | null>(null)

// Computed properties
const deviceTypes = computed(() => {
  const types = new Set(devices.value.map(device => device.device_type).filter(Boolean))
  return Array.from(types)
})

// Load employee data
const loadEmployee = async () => {
  try {
    loading.value = true
    error.value = null
    
    // Load employee info
    const employeeResponse = await employeesApi.getById(route.params.id as string)
    employee.value = employeeResponse.employee
    
    // Load employee's devices
    const devicesResponse = await devicesApi.getAll({ assignment_status: 'assigned' })
    devices.value = devicesResponse.devices.filter((device: any) => 
      device.employee_id === employee.value.id
    )
  } catch (err: any) {
    console.error('Failed to load employee:', err)
    error.value = err.message || '직원 정보를 불러올 수 없습니다'
  } finally {
    loading.value = false
  }
}

// 2025-01-27: 직원 수정 모달 상태 추가
const showEditModal = ref(false)

// 2025-01-27: 퇴사 처리 관련 상태 추가
const showResignModal = ref(false)
const processingResignation = ref(false)

// Edit employee
const editEmployee = () => {
  console.log('Edit employee:', employee.value?.id)
  showEditModal.value = true
}

// 2025-01-27: 모달 닫기 함수
const closeEditModal = () => {
  showEditModal.value = false
}

// 2025-01-27: 직원 수정 완료 후 처리
const onEmployeeUpdated = async () => {
  console.log('✅ Employee updated, reloading data')
  closeEditModal()
  await loadEmployee() // 데이터 다시 로드
}

// 2025-01-27: 퇴사 처리 관련 함수들
const closeResignModal = () => {
  showResignModal.value = false
}

const processResignation = async () => {
  if (!employee.value) return
  
  try {
    processingResignation.value = true
    
    // 2025-01-27: 백엔드 퇴사 처리 API 사용
    const result = await employeesApi.resign(employee.value.id)
    
    console.log('✅ Employee resignation processed successfully:', result)
    
    // 모달 닫기 및 데이터 새로고침
    closeResignModal()
    await loadEmployee()
    
  } catch (error) {
    console.error('❌ Failed to process resignation:', error)
    // 에러 처리 (실제로는 토스트 메시지 등으로 표시)
  } finally {
    processingResignation.value = false
  }
}

// View device detail
const viewDevice = (deviceId: string) => {
  router.push(`/devices/${deviceId}`)
}

// Format date
const formatDate = (dateString: string) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Load data on mount
onMounted(() => {
  loadEmployee()
})
</script>

<style scoped>
.employee-detail-container {
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.loading-state,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text,
.error-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 8px;
}

.error-message {
  color: #6b7280;
  margin-bottom: 24px;
}

.retry-btn {
  padding: 12px 24px;
}

.main-content {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.page-header {
  margin-bottom: 24px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 32px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 32px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.header-info {
  flex: 1;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  font-size: 14px;
  color: #6b7280;
}

.breadcrumb-link {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #667eea;
  text-decoration: none;
  transition: color 0.3s ease;
}

.breadcrumb-link:hover {
  color: #5a67d8;
}

.breadcrumb-separator {
  color: #d1d5db;
}

.breadcrumb-current {
  color: #1f2937;
  font-weight: 600;
}

.page-title {
  font-size: 32px;
  font-weight: 800;
  color: #1f2937;
  margin: 0 0 8px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  color: #6b7280;
  font-size: 16px;
  margin: 0;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.edit-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
}

/* 2025-01-27: 퇴사 처리 관련 스타일 */
.resigned-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
}

.resign-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.resign-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(239, 68, 68, 0.3);
}

/* 퇴사 처리 모달 스타일 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 20px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  max-width: 500px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 24px 16px 24px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-title {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.modal-close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: #f3f4f6;
  border: none;
  border-radius: 8px;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.3s ease;
}

.modal-close:hover {
  background: #e5e7eb;
  color: #374151;
}

.modal-body {
  padding: 24px;
}

.warning-message {
  margin-bottom: 24px;
}

.warning-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  background: #fef3c7;
  border-radius: 12px;
  color: #f59e0b;
  margin-bottom: 16px;
}

.warning-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 12px 0;
}

.warning-description {
  color: #6b7280;
  margin: 0 0 16px 0;
}

.warning-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.warning-list li {
  position: relative;
  padding-left: 20px;
  margin-bottom: 8px;
  color: #6b7280;
}

.warning-list li::before {
  content: '•';
  position: absolute;
  left: 0;
  color: #ef4444;
  font-weight: bold;
}

.device-return-section {
  border-top: 1px solid #e5e7eb;
  padding-top: 24px;
}

.device-return-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 16px 0;
}

.device-return-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.device-return-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f9fafb;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
}

.device-return-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: #e5e7eb;
  border-radius: 6px;
  color: #6b7280;
}

.device-return-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.device-return-name {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.device-return-model {
  font-size: 12px;
  color: #6b7280;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 24px 24px 24px;
  border-top: 1px solid #e5e7eb;
}

.btn-secondary {
  padding: 12px 20px;
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  color: #374151;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

.btn-danger {
  padding: 12px 20px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  border: none;
  border-radius: 8px;
  color: white;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-danger:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.btn-danger:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading-spinner-small {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.content-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 24px;
}

.info-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  overflow: hidden;
  transition: all 0.3s ease;
}

.info-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
}

.card-header {
  padding: 24px 24px 16px 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.card-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.card-content {
  padding: 24px;
}

.employee-profile {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 24px;
  padding-bottom: 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.employee-avatar-large {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 32px;
}

.employee-details {
  flex: 1;
}

.employee-name-large {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.employee-position-large {
  font-size: 18px;
  color: #6b7280;
  margin: 0 0 4px 0;
}

.employee-department-large {
  font-size: 16px;
  color: #9ca3af;
  margin: 0;
}

.info-grid {
  display: grid;
  gap: 16px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.info-item:last-child {
  border-bottom: none;
}

.info-label {
  font-weight: 600;
  color: #6b7280;
  font-size: 14px;
}

.info-value {
  color: #1f2937;
  font-weight: 500;
}

.stats-grid {
  display: grid;
  gap: 20px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: #f9fafb;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.stat-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 4px 0;
}

.stat-label {
  color: #6b7280;
  font-size: 14px;
  margin: 0;
}

.devices-section {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 32px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.section-header {
  margin-bottom: 32px;
}

.section-title {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.section-subtitle {
  color: #6b7280;
  margin: 0;
}

.devices-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 24px;
}

.device-card {
  background: #f9fafb;
  border-radius: 16px;
  padding: 24px;
  border: 2px solid transparent;
  transition: all 0.3s ease;
  cursor: pointer;
}

.device-card:hover {
  border-color: #667eea;
  transform: translateY(-4px);
  box-shadow: 0 12px 40px rgba(102, 126, 234, 0.15);
}

.device-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.device-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.device-status {
  display: flex;
  gap: 8px;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
}

.status-badge.assigned {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.device-info {
  margin-bottom: 16px;
}

.device-name {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.device-model {
  color: #6b7280;
  font-size: 14px;
  margin: 0 0 12px 0;
}

.device-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #6b7280;
  font-size: 13px;
}

.detail-item svg {
  color: #9ca3af;
}

.device-footer {
  padding-top: 16px;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

.device-date {
  color: #9ca3af;
  font-size: 12px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 24px;
  text-align: center;
}

.empty-icon {
  color: #9ca3af;
  margin-bottom: 16px;
}

.empty-title {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.empty-text {
  color: #6b7280;
  margin: 0;
}

@media (max-width: 768px) {
  .employee-detail-container {
    padding: 16px;
  }
  
  .header-content {
    flex-direction: column;
    gap: 16px;
    padding: 24px;
  }
  
  .content-grid {
    grid-template-columns: 1fr;
  }
  
  .devices-grid {
    grid-template-columns: 1fr;
  }
  
  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
}
</style>
