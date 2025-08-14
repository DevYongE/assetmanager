<template>
  <div class="device-detail-container">
    <!-- 로딩 상태 -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p class="loading-text">장비 정보를 불러오는 중...</p>
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
      <h3 class="error-title">장비 정보를 불러올 수 없습니다</h3>
      <p class="error-message">{{ error }}</p>
      <button @click="loadDevice" class="btn-gradient retry-btn">
        다시 시도
      </button>
    </div>

    <!-- 메인 콘텐츠 -->
    <div v-else-if="device" class="main-content">
      <!-- 헤더 -->
      <div class="page-header">
        <div class="header-content">
          <div class="header-info">
            <div class="breadcrumb">
              <NuxtLink to="/devices" class="breadcrumb-link">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M19 12H5M12 19L5 12L12 5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                장비 목록
              </NuxtLink>
              <span class="breadcrumb-separator">/</span>
              <span class="breadcrumb-current">{{ device.asset_number }}</span>
            </div>
            <h1 class="page-title">장비 상세 정보</h1>
            <p class="page-subtitle">자산번호: {{ device.asset_number }}</p>
          </div>
          <div class="header-actions">
            <button 
              @click="editDevice" 
              :disabled="device.purpose === '폐기'"
              :class="['btn-gradient edit-btn', { 'disabled': device.purpose === '폐기' }]"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11 4H4C3.46957 4 2.96086 4.21071 2.58579 4.58579C2.21071 4.96086 2 5.46957 2 6V20C2 20.5304 2.21071 21.0391 2.58579 21.4142C2.96086 21.7893 3.46957 22 4 22H18C18.5304 22 19.0391 21.7893 19.4142 21.4142C19.7893 21.0391 20 20.5304 20 20V13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M18.5 2.5C18.8978 2.10217 19.4374 1.87868 20 1.87868C20.5626 1.87868 21.1022 2.10217 21.5 2.5C21.8978 2.89782 22.1213 3.43739 22.1213 4C22.1213 4.56261 21.8978 5.10217 21.5 5.5L12 15L8 16L9 12L18.5 2.5Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              수정
            </button>
            <!-- 2025-01-27: 장비 상태 변경 버튼들 추가 -->
            <div class="status-actions">
                                  <button 
                      v-if="device.employee_id && device.purpose !== '폐기'" 
                      @click="returnDevice" 
                      class="btn-secondary return-btn"
                    >
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M3 12L7 8M3 12L7 16M3 12H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      반납
                    </button>
                    <button 
                      v-if="device.purpose !== '폐기'"
                      @click="openDisposeModal" 
                      class="btn-danger dispose-btn"
                    >
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M3 6H5H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M8 6V4C8 3.46957 8.21071 2.96086 8.58579 2.58579C8.96086 2.21071 9.46957 2 10 2H14C14.5304 2 15.0391 2.21071 15.4142 2.58579C15.7893 2.96086 16 3.46957 16 4V6M19 6V20C19 20.5304 18.7893 21.0391 18.4142 21.4142C18.0391 21.7893 17.5304 22 17 22H7C6.46957 22 5.96086 21.7893 5.58579 21.4142C5.21071 21.0391 5 20.5304 5 20V6H19Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      폐기
                    </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 장비 정보 그리드 -->
      <div class="content-grid">
        <!-- 기본 정보 카드 -->
        <div class="info-card">
          <div class="card-header">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
                <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
              </svg>
              기본 정보
            </h3>
          </div>
          <div class="card-content">
            <div class="info-grid">
              <div class="info-item">
                <label class="info-label">자산번호</label>
                <span class="info-value">{{ device.asset_number }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">제조사</label>
                <span class="info-value">{{ device.manufacturer || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">모델명</label>
                <span class="info-value">{{ device.model_name || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">시리얼 번호</label>
                <span class="info-value">{{ device.serial_number || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">용도</label>
                <span class="info-value">{{ device.purpose || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">장비 타입</label>
                <span class="info-value">{{ device.device_type || '-' }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 담당자 정보 카드 -->
        <div class="info-card">
          <div class="card-header">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M17 21V19C17 17.9391 16.5786 16.9217 15.8284 16.1716C15.0783 15.4214 14.0609 15 13 15H5C3.93913 15 2.92172 15.4214 2.17157 16.1716C1.42143 16.9217 1 17.9391 1 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M9 11C11.2091 11 13 9.20914 13 7C13 4.79086 11.2091 3 9 3C6.79086 3 5 4.79086 5 7C5 9.20914 6.79086 11 9 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              담당자 정보
            </h3>
          </div>
          <div class="card-content">
            <div v-if="device.employees" class="employee-info">
              <div class="employee-avatar">
                <span class="avatar-text">{{ device.employees.name.charAt(0) }}</span>
              </div>
              <div class="employee-details">
                <h4 class="employee-name">{{ device.employees.name }}</h4>
                <p class="employee-position">{{ device.employees.position }}</p>
                <p class="employee-department">{{ device.employees.department }}</p>
              </div>
            </div>
            <div v-else class="no-employee">
              <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M17 21V19C17 17.9391 16.5786 16.9217 15.8284 16.1716C15.0783 15.4214 14.0609 15 13 15H5C3.93913 15 2.92172 15.4214 2.17157 16.1716C1.42143 16.9217 1 17.9391 1 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M9 11C11.2091 11 13 9.20914 13 7C13 4.79086 11.2091 3 9 3C6.79086 3 5 4.79086 5 7C5 9.20914 6.79086 11 9 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <p>담당자가 할당되지 않았습니다</p>
            </div>
          </div>
        </div>

        <!-- 사양 정보 카드 -->
        <div class="info-card">
          <div class="card-header">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9 12L11 14L15 10M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              사양 정보
            </h3>
          </div>
          <div class="card-content">
            <div class="info-grid">
              <div class="info-item">
                <label class="info-label">CPU</label>
                <span class="info-value">{{ device.cpu || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">메모리</label>
                <span class="info-value">{{ device.memory || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">저장장치</label>
                <span class="info-value">{{ device.storage || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">그래픽카드</label>
                <span class="info-value">{{ device.gpu || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">운영체제</label>
                <span class="info-value">{{ device.os || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">모니터</label>
                <span class="info-value">{{ device.monitor || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">모니터 크기</label>
                <span class="info-value">{{ device.monitor_size || '-' }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 날짜 정보 카드 -->
        <div class="info-card">
          <div class="card-header">
            <h3 class="card-title">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                <line x1="16" y1="2" x2="16" y2="6" stroke="currentColor" stroke-width="2"/>
                <line x1="8" y1="2" x2="8" y2="6" stroke="currentColor" stroke-width="2"/>
                <line x1="3" y1="10" x2="21" y2="10" stroke="currentColor" stroke-width="2"/>
              </svg>
              날짜 정보
            </h3>
          </div>
          <div class="card-content">
            <div class="info-grid">
              <div class="info-item">
                <label class="info-label">조사일자</label>
                <span class="info-value">{{ device.inspection_date || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">지급일자</label>
                <span class="info-value">{{ device.issue_date || '-' }}</span>
              </div>
              <div class="info-item">
                <label class="info-label">등록일</label>
                <span class="info-value">{{ formatDate(device.created_at) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 히스토리 섹션 -->
      <div class="history-section">
        <div class="section-header">
          <h2 class="section-title">변경 히스토리</h2>
          <p class="section-subtitle">장비 정보 변경 내역을 확인할 수 있습니다</p>
        </div>
        <div v-if="historyLoading" class="history-loading">
          <div class="loading-spinner-small"></div>
          <p>히스토리를 불러오는 중...</p>
        </div>
        <div v-else-if="history.length" class="history-timeline">
          <div 
            v-for="item in history" 
            :key="item.id"
            class="timeline-item"
          >
            <div class="timeline-marker"></div>
            <div class="timeline-content">
              <div class="timeline-header">
                <h4 class="timeline-title">{{ item.action_type }}</h4>
                <span class="timeline-date">{{ formatDate(item.performed_at) }}</span>
              </div>
              <p class="timeline-description">{{ item.action_description }}</p>
              <!-- 2025-01-27: 처리자 정보 표시 개선 -->
              <div class="timeline-user">
                <span class="user-label">처리자:</span>
                <span class="user-name">{{ getProcessorName(item) }}</span>
              </div>
              
              <!-- 2025-01-27: 수정 시 변경된 항목만 간단히 표시 (action_description 활용) -->
              <div v-if="item.action_type === '수정' && item.action_description" class="timeline-changes">
                <div class="changes-summary">
                  <span class="changes-label">변경된 항목:</span>
                  <span class="changes-content">{{ item.action_description }}</span>
                </div>
              </div>
              
              <div v-if="item.previous_status || item.new_status" class="timeline-status">
                <span v-if="item.previous_status" class="status-change">
                  <span class="status-label">이전:</span>
                  <span class="status-value previous">{{ item.previous_status }}</span>
                </span>
                <span v-if="item.new_status" class="status-change">
                  <span class="status-label">변경:</span>
                  <span class="status-value current">{{ item.new_status }}</span>
                </span>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="empty-history">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
            <line x1="16" y1="2" x2="16" y2="6" stroke="currentColor" stroke-width="2"/>
            <line x1="8" y1="2" x2="8" y2="6" stroke="currentColor" stroke-width="2"/>
            <line x1="3" y1="10" x2="21" y2="10" stroke="currentColor" stroke-width="2"/>
          </svg>
          <p>아직 변경 히스토리가 없습니다</p>
        </div>
      </div>
    </div>

    <!-- 2025-01-27: 장비 수정 모달 추가 -->
    <DeviceModal 
      v-if="showEditModal" 
      :device="device" 
      @close="showEditModal = false"
      @device-updated="handleDeviceUpdated"
    />

    <!-- 2025-01-27: 폐기 사유 입력 모달 -->
    <div v-if="showDisposeModal" class="modal-overlay" @click="showDisposeModal = false">
      <div class="modal-container" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">장비 폐기</h3>
          <button @click="showDisposeModal = false" class="modal-close">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <line x1="18" y1="6" x2="6" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <line x1="6" y1="6" x2="18" y2="18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <p class="modal-description">
            장비를 폐기하시겠습니까? 폐기 후에는 수정이 불가능합니다.
          </p>
          <div class="form-group">
            <label for="disposeReason" class="form-label">폐기 사유 <span class="required">*</span></label>
            <textarea
              id="disposeReason"
              v-model="disposeReason"
              class="form-input"
              rows="4"
              placeholder="폐기 사유를 입력해주세요..."
              required
            ></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button @click="showDisposeModal = false" class="btn-secondary">
            취소
          </button>
          <button @click="disposeDevice" class="btn-danger" :disabled="!disposeReason.trim()">
            폐기 확인
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

const route = useRoute()
const { devices: devicesApi } = useApi()

// 2025-01-27: DeviceModal 컴포넌트 import
import DeviceModal from '~/components/DeviceModal.vue'

// Reactive data
const device = ref<any>(null)
const loading = ref(true)
const error = ref<string | null>(null)
// 2025-01-27: 히스토리 관련 변수 추가
const history = ref<any[]>([])
const historyLoading = ref(false)

// 2025-01-27: 수정 모달 관련 변수 추가
const showEditModal = ref(false)

// Load device data
const loadDevice = async () => {
  try {
    loading.value = true
    error.value = null
    
    // 2025-01-27: 자산번호로 장비 정보 로드
    const response = await devicesApi.getById(route.params.id as string)
    device.value = response.device
    
    // 2025-01-27: 장비 정보 로드 후 히스토리도 함께 로드
    await loadHistory()
  } catch (err: any) {
    console.error('Failed to load device:', err)
    error.value = err.message || '장비 정보를 불러올 수 없습니다'
  } finally {
    loading.value = false
  }
}

// 2025-01-27: 히스토리 로드 함수 추가
const loadHistory = async () => {
  try {
    historyLoading.value = true
    // 2025-01-27: 자산번호로 히스토리 로드
    const response = await devicesApi.getHistory(route.params.id as string)
    history.value = response.history || []
  } catch (err: any) {
    console.error('Failed to load history:', err)
    // 히스토리 로드 실패는 에러로 처리하지 않음
  } finally {
    historyLoading.value = false
  }
}



// Edit device
const editDevice = () => {
  // 2025-01-27: 폐기된 장비는 수정 불가
  if (device.value.purpose === '폐기') {
    alert('폐기된 장비는 수정할 수 없습니다.')
    return
  }
  
  // 2025-01-27: 장비 수정 모달 열기
  showEditModal.value = true
}

// Handle device updated from modal
const handleDeviceUpdated = async (updatedDevice: any) => {
  // 2025-01-27: 장비 정보 업데이트 및 히스토리 새로고침
  device.value = updatedDevice
  await loadHistory()
  showEditModal.value = false
}

// 2025-01-27: 반납 처리 함수 (사용자 요청에 따른 단순화)
const returnDevice = async () => {
  if (!confirm('반납하시겠습니까?')) {
    return
  }

  try {
    loading.value = true
    error.value = null

    const response = await devicesApi.returnDevice(device.value.asset_number)
    device.value = response.device
    
    await loadHistory()
  } catch (err: any) {
    console.error('Failed to return device:', err)
    error.value = err.message || '장비 반납에 실패했습니다'
  } finally {
    loading.value = false
  }
}

// 2025-01-27: 폐기 처리 함수 (사용자 요청에 따른 모달창 구현)
const showDisposeModal = ref(false)
const disposeReason = ref('')

const openDisposeModal = () => {
  disposeReason.value = ''
  showDisposeModal.value = true
}

const disposeDevice = async () => {
  if (!disposeReason.value.trim()) {
    alert('폐기 사유를 입력해주세요.')
    return
  }

  try {
    loading.value = true
    error.value = null
    showDisposeModal.value = false

    const response = await devicesApi.disposeDevice(device.value.asset_number, disposeReason.value)
    device.value = response.device
    
    await loadHistory()
  } catch (err: any) {
    console.error('Failed to dispose device:', err)
    error.value = err.message || '장비 폐기에 실패했습니다'
  } finally {
    loading.value = false
  }
}

// 기존 함수 유지 (하위 호환성)
const changeStatus = async (newStatus: string) => {
  if (newStatus === 'returned') {
    await returnDevice()
  } else if (newStatus === 'disposed') {
    openDisposeModal()
  }
}

// 2025-01-27: 상태 텍스트 변환 함수 추가
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'returned': '반납',
    'disposed': '폐기',
    '할당됨': '할당됨',
    '미할당': '미할당',
    '반납됨': '반납됨',
    '폐기됨': '폐기됨',
    '없음': '없음'
  }
  return statusMap[status] || status
}

// 2025-01-27: 처리자 이름 표시 함수 (사용자 정보 조인 활용)
const getProcessorName = (item: any) => {
  // 2025-01-27: 사용자 정보가 조인된 경우 email 또는 company_name 표시
  if (item.users && item.users.email) {
    return `관리자 (${item.users.email})`
  } else if (item.users && item.users.company_name) {
    return `관리자 (${item.users.company_name})`
  } else if (item.performed_by) {
    // 2025-01-27: 사용자 정보가 없는 경우 기본값
    return '관리자'
  }
  return '시스템'
}

// 2025-01-27: 필드명 변환 함수
const getFieldName = (field: string) => {
  const fieldNames: Record<string, string> = {
    'asset_number': '자산번호',
    'employee_id': '담당자',
    'manufacturer': '제조사',
    'model_name': '모델명',
    'serial_number': '시리얼번호',
    'cpu': 'CPU',
    'memory': '메모리',
    'storage': '저장장치',
    'gpu': '그래픽카드',
    'os': '운영체제',
    'monitor': '모니터',
    'monitor_size': '모니터크기',
    'inspection_date': '조사일자',
    'purpose': '용도',
    'device_type': '장비타입',
    'issue_date': '지급일자'
  }
  return fieldNames[field] || field
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
  loadDevice()
})
</script>

<style scoped>
.device-detail-container {
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

.edit-btn.disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.status-actions {
  display: flex;
  gap: 12px;
}

.return-btn,
.dispose-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
}

/* 2025-01-27: 상태 변경 버튼 스타일 추가 */
.btn-secondary {
  background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  transition: all 0.3s ease;
  cursor: pointer;
}

.btn-secondary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 114, 128, 0.3);
}

.btn-danger {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  transition: all 0.3s ease;
  cursor: pointer;
}

.btn-danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(239, 68, 68, 0.3);
}

.content-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
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

.employee-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.employee-avatar {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 18px;
}

.employee-details {
  flex: 1;
}

.employee-name {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 4px 0;
}

.employee-position {
  color: #6b7280;
  font-size: 14px;
  margin: 0 0 2px 0;
}

.employee-department {
  color: #9ca3af;
  font-size: 13px;
  margin: 0;
}

.no-employee {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #9ca3af;
  text-align: center;
}

.no-employee svg {
  margin-bottom: 16px;
}

.history-section {
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

.history-timeline {
  position: relative;
}

.timeline-item {
  display: flex;
  gap: 20px;
  margin-bottom: 24px;
  position: relative;
}

.timeline-marker {
  width: 12px;
  height: 12px;
  background: #667eea;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 6px;
}

.timeline-content {
  flex: 1;
  background: #f9fafb;
  border-radius: 12px;
  padding: 16px;
  border-left: 3px solid #667eea;
}

.timeline-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.timeline-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.timeline-date {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.timeline-description {
  color: #6b7280;
  font-size: 14px;
  margin: 0;
}

.timeline-user {
  margin-top: 12px;
  font-size: 14px;
  color: #6b7280;
}

.user-label {
  font-weight: 600;
  color: #1f2937;
}

.user-name {
  color: #667eea;
  font-weight: 500;
}

.timeline-status {
  margin-top: 12px;
  font-size: 14px;
  color: #6b7280;
}

.status-change {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-label {
  font-weight: 600;
  color: #1f2937;
}

.status-value {
  font-weight: 500;
}

.status-value.previous {
  color: #6b7280;
}

.status-value.current {
  color: #1f2937;
}

.timeline-employees {
  margin-top: 12px;
  font-size: 14px;
  color: #6b7280;
}

.employee-change {
  display: flex;
  align-items: center;
  gap: 8px;
}

.change-label {
  font-weight: 600;
  color: #1f2937;
}

.employee-name {
  font-weight: 500;
}

.employee-name.previous {
  color: #6b7280;
}

 .employee-name.current {
   color: #1f2937;
 }
 
 /* 2025-01-27: 변경된 항목 간단 표시 스타일 */
 .timeline-changes {
   margin-top: 12px;
   padding: 12px;
   background: #f8fafc;
   border-radius: 8px;
   border-left: 3px solid #667eea;
 }
 
 .changes-summary {
   display: flex;
   align-items: flex-start;
   gap: 8px;
 }
 
 .changes-label {
   font-weight: 600;
   color: #1f2937;
   font-size: 13px;
   white-space: nowrap;
 }
 
 .changes-content {
   color: #374151;
   font-size: 13px;
   line-height: 1.4;
   flex: 1;
 }
  
  /* 2025-01-27: 폐기 모달창 스타일 */
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    backdrop-filter: blur(4px);
  }
  
  .modal-container {
    background: white;
    border-radius: 16px;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow: hidden;
  }
  
  .modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 24px;
    border-bottom: 1px solid #e5e7eb;
  }
  
  .modal-title {
    font-size: 20px;
    font-weight: 700;
    color: #1f2937;
    margin: 0;
  }
  
  .modal-close {
    background: none;
    border: none;
    color: #6b7280;
    cursor: pointer;
    padding: 4px;
    border-radius: 6px;
    transition: all 0.2s;
  }
  
  .modal-close:hover {
    background: #f3f4f6;
    color: #374151;
  }
  
  .modal-body {
    padding: 24px;
  }
  
  .modal-description {
    color: #6b7280;
    margin-bottom: 20px;
    line-height: 1.6;
  }
  
  .form-group {
    margin-bottom: 0;
  }
  
  .form-label {
    display: block;
    font-weight: 600;
    color: #374151;
    margin-bottom: 8px;
    font-size: 14px;
  }
  
  .required {
    color: #ef4444;
  }
  
  .form-input {
    width: 100%;
    padding: 12px;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    font-size: 14px;
    transition: border-color 0.2s;
    resize: vertical;
    min-height: 100px;
  }
  
  .form-input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }
  
  .modal-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    padding: 24px;
    border-top: 1px solid #e5e7eb;
    background: #f9fafb;
  }
  
  .btn-secondary {
    padding: 10px 20px;
    background: #f3f4f6;
    color: #374151;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .btn-secondary:hover {
    background: #e5e7eb;
  }
  
  .btn-danger {
    padding: 10px 20px;
    background: #ef4444;
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .btn-danger:hover:not(:disabled) {
    background: #dc2626;
  }
  
  .btn-danger:disabled {
    background: #d1d5db;
    cursor: not-allowed;
  }
  
  .empty-history {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #9ca3af;
  text-align: center;
}

.empty-history svg {
  margin-bottom: 16px;
}

.history-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 20px;
  color: #9ca3af;
  text-align: center;
}

.loading-spinner-small {
  width: 32px;
  height: 32px;
  border: 3px solid #e5e7eb;
  border-top: 3px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@media (max-width: 768px) {
  .device-detail-container {
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
  
  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
}
</style>
