<template>
  <div class="devices-container">
    <!-- 2024-12-19: 현대적인 헤더 섹션으로 재설계 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-info">
          <div class="title-section">
            <h1 class="page-title">장비 관리</h1>
            <div class="title-badge">
              <span class="badge-count">{{ devices.length }}</span>
              <span class="badge-text">개 장비</span>
            </div>
          </div>
          <p class="page-subtitle">직원별 장비를 관리하고 QR 코드를 생성하세요</p>
        </div>
        
        <div class="header-actions">
          <!-- 검색 및 필터 -->
          <div class="search-filter-section">
            <div class="search-box">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="search-icon">
                <circle cx="11" cy="11" r="8"/>
                <path d="M21 21l-4.35-4.35"/>
              </svg>
              <input
                v-model="searchQuery"
                type="text"
                placeholder="장비명, 직원명으로 검색..."
                class="search-input"
                @input="handleSearch"
              />
            </div>
            
            <div class="filter-group">
              <select 
                v-model="assignmentFilter" 
                @change="loadDevices"
                class="filter-select"
              >
                <option value="">전체 상태</option>
                <option value="assigned">할당됨</option>
                <option value="unassigned">미할당</option>
              </select>
            </div>
          </div>

          <!-- 뷰 전환 버튼 -->
          <div class="view-toggle">
            <button 
              @click="viewMode = 'card'"
              :class="['view-btn', { active: viewMode === 'card' }]"
              title="카드 뷰"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="3" width="7" height="7"/>
                <rect x="14" y="3" width="7" height="7"/>
                <rect x="3" y="14" width="7" height="7"/>
                <rect x="14" y="14" width="7" height="7"/>
              </svg>
            </button>
            <button 
              @click="viewMode = 'list'"
              :class="['view-btn', { active: viewMode === 'list' }]"
              title="리스트 뷰"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="8" y1="6" x2="21" y2="6"/>
                <line x1="8" y1="12" x2="21" y2="12"/>
                <line x1="8" y1="18" x2="21" y2="18"/>
                <line x1="3" y1="6" x2="3.01" y2="6"/>
                <line x1="3" y1="12" x2="3.01" y2="12"/>
                <line x1="3" y1="18" x2="3.01" y2="18"/>
              </svg>
            </button>
          </div>

          <!-- 액션 버튼들 -->
          <div class="action-buttons">
            <BaseButton
              label="Excel 내보내기"
              variant="secondary"
              size="md"
              :disabled="devices.length === 0"
              icon="M12 10V16M12 10L9 13M12 10L15 13M21 15V19C21 19.5304 20.7893 20.0391 20.4142 20.4142C20.0391 20.7893 19.5304 21 19 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V15"
              @click="exportExcel"
            />

            <BaseButton
              label="템플릿 다운로드"
              variant="secondary"
              size="md"
              icon="M21 15V19C21 19.5304 20.7893 20.0391 20.4142 20.4142C20.0391 20.7893 19.5304 21 19 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V15"
              @click="downloadExcelTemplate"
            />

            <!-- Excel 가져오기 -->
            <div class="file-upload-wrapper">
              <input
                type="file"
                ref="fileInput"
                @change="importExcel"
                accept=".xlsx,.xls,.csv"
                class="hidden"
              />
              <BaseButton
                label="Excel 가져오기"
                variant="secondary"
                size="md"
                icon="M21 15V19C21 19.5304 20.7893 20.0391 20.4142 20.4142C20.0391 20.7893 19.5304 21 19 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V15"
                @click="() => (fileInput as HTMLInputElement)?.click()"
              />
            </div>

            <BaseButton
              label="장비 추가"
              variant="primary"
              size="md"
              icon="M12 5V19M5 12H19"
              @click="showAddModal = true"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- 로딩 상태 -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p class="loading-text">장비 정보를 불러오는 중...</p>
    </div>

    <!-- 에러 상태 -->
    <div v-else-if="error" class="error-state animate-fade-in-up">
      <div class="error-icon">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
          <line x1="15" y1="9" x2="9" y2="15" stroke="currentColor" stroke-width="2"/>
          <line x1="9" y1="9" x2="15" y2="15" stroke="currentColor" stroke-width="2"/>
        </svg>
      </div>
      <h3 class="error-title">데이터를 불러올 수 없습니다</h3>
      <p class="error-message">{{ error }}</p>
      <button @click="loadDevices" class="btn-gradient retry-btn">
        다시 시도
      </button>
    </div>

    <!-- 메인 콘텐츠 -->
    <div v-else class="main-content animate-fade-in-up" style="animation-delay: 0.1s;">
      <!-- 통계 카드 -->
      <div class="stats-section">
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon device-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                <line x1="8" y1="21" x2="16" y2="21" stroke="currentColor" stroke-width="2"/>
                <line x1="12" y1="17" x2="12" y2="21" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <div class="stat-content">
              <h3 class="stat-value">{{ devices.length }}</h3>
              <p class="stat-label">총 장비 수</p>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon manufacturer-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <div class="stat-content">
              <h3 class="stat-value">{{ manufacturerCount }}</h3>
              <p class="stat-label">제조사 수</p>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon assigned-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M9 12L11 14L15 10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2"/>
              </svg>
            </div>
            <div class="stat-content">
              <h3 class="stat-value">{{ assignedDevices }}</h3>
              <p class="stat-label">할당된 장비</p>
            </div>
          </div>

          <div class="stat-card">
            <div class="stat-icon new-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </div>
            <div class="stat-content">
              <h3 class="stat-value">{{ recentDevices }}</h3>
              <p class="stat-label">이번 달 신규</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 검색 및 필터 -->
      <div class="search-section">
        <div class="search-card">
          <div class="search-input-group">
            <div class="search-input-wrapper">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="11" cy="11" r="8" stroke="currentColor" stroke-width="2"/>
                <path d="M21 21L16.65 16.65" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <input
                v-model="searchQuery"
                type="text"
                placeholder="자산번호, 제조사, 모델명으로 검색..."
                class="search-input"
              />
            </div>
            <select v-model="filterEmployee" class="filter-select">
              <option value="">모든 직원</option>
              <option v-for="emp in employees" :key="emp.id" :value="emp.id">
                {{ emp.name }} ({{ emp.department }})
              </option>
            </select>
            <select v-model="filterManufacturer" class="filter-select">
              <option value="">모든 제조사</option>
              <option v-for="mfg in manufacturers" :key="mfg" :value="mfg">
                {{ mfg }}
              </option>
            </select>
            <select v-model="filterStatus" class="filter-select">
              <option value="">모든 상태</option>
              <option value="assigned">할당됨</option>
              <option value="unassigned">미할당</option>
            </select>
          </div>
        </div>
      </div>

      <!-- 카드 뷰 -->
      <div v-if="viewMode === 'card' && filteredDevices.length" class="devices-grid">
        <div 
          v-for="device in filteredDevices" 
          :key="device.id"
          class="device-card"
        >
          <div class="device-header">
            <div class="device-actions">
              <button 
                @click="editDevice(device)"
                class="action-btn edit-btn"
                title="수정"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M11 4H4C3.46957 4 2.96086 4.21071 2.58579 4.58579C2.21071 4.96086 2 5.46957 2 6V20C2 20.5304 2.21071 21.0391 2.58579 21.4142C2.96086 21.7893 3.46957 22 4 22H18C18.5304 22 19.0391 21.7893 19.4142 21.4142C19.7893 21.0391 20 20.5304 20 20V13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M18.5 2.5C18.8978 2.10217 19.4374 1.87868 20 1.87868C20.5626 1.87868 21.1022 2.10217 21.5 2.5C21.8978 2.89782 22.1213 3.43739 22.1213 4C22.1213 4.56261 21.8978 5.10217 21.5 5.5L12 15L8 16L9 12L18.5 2.5Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
              <button 
                @click="deleteDevice(device)"
                class="action-btn delete-btn"
                title="삭제"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3 6H5H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M19 6V20C19 20.5304 18.7893 21.0391 18.4142 21.4142C18.0391 21.7893 17.5304 22 17 22H7C6.46957 22 5.96086 21.7893 5.58579 21.4142C5.21071 21.0391 5 20.5304 5 20V6M8 6V4C8 3.46957 8.21071 2.96086 8.58579 2.58579C8.96086 2.21071 9.46957 2 10 2H14C14.5304 2 15.0391 2.21071 15.4142 2.58579C15.7893 2.96086 16 3.46957 16 4V6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
            </div>
          </div>
          
          <div class="device-info">
            <h3 class="device-asset-number">{{ device.asset_number }}</h3>
            <p class="device-model">{{ device.manufacturer }} {{ device.model_name }}</p>
            
            <!-- 담당자 정보 -->
            <div class="device-details">
              <div class="detail-item">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M17 21V19C17 17.9391 16.5786 16.9217 15.8284 16.1716C15.0783 15.4214 14.0609 15 13 15H5C3.93913 15 2.92172 15.4214 2.17157 16.1716C1.42143 16.9217 1 17.9391 1 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M9 11C11.2091 11 13 9.20914 13 7C13 4.79086 11.2091 3 9 3C6.79086 3 5 4.79086 5 7C5 9.20914 6.79086 11 9 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <span v-if="getDeviceEmployeeInfo(device)" class="assigned-employee">
                  {{ getDeviceEmployeeInfo(device)?.name }} ({{ getDeviceEmployeeInfo(device)?.department }} - {{ getDeviceEmployeeInfo(device)?.position }})
                </span>
                <span v-else class="unassigned-employee">
                  미할당 - 담당자 선택 필요
                </span>
              </div>
              
              <!-- 시리얼 번호 -->
              <div class="detail-item" v-if="device.serial_number">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke="currentColor" stroke-width="2"/>
                </svg>
                {{ device.serial_number }}
              </div>
              
              <!-- 회사명 -->
              <div class="detail-item">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3 9L12 2L21 9V20C21 20.5304 20.7893 21.0391 20.4142 21.4142C20.0391 21.7893 19.5304 22 19 22H5C4.46957 22 3.96086 21.7893 3.58579 21.4142C3.21071 21.0391 3 20.5304 3 20V9Z" stroke="currentColor" stroke-width="2"/>
                  <polyline points="9,22 9,12 15,12 15,22" stroke="currentColor" stroke-width="2"/>
                </svg>
                {{ getDeviceCompanyName(device) }}
              </div>
            </div>
          </div>

          <div class="device-footer">
            <div class="device-status">
              <span class="status-badge" :class="device.employee_id ? 'assigned' : 'unassigned'">
                {{ device.employee_id ? '할당됨' : '미할당' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- 리스트 뷰 -->
      <div v-else-if="viewMode === 'list' && filteredDevices.length" class="devices-list">
        <div class="list-header">
          <div class="list-header-cell">자산번호</div>
          <div class="list-header-cell">조사일자</div>
          <div class="list-header-cell">담당자</div>
          <div class="list-header-cell">용도</div>
          <div class="list-header-cell">제조사/모델</div>
          <div class="list-header-cell">시리얼번호</div>
          <div class="list-header-cell">회사명</div>
          <div class="list-header-cell">상태</div>
          <div class="list-header-cell">작업</div>
        </div>
        
        <div 
          v-for="device in filteredDevices" 
          :key="device.id"
          class="list-row"
        >
          <div class="list-cell asset-number">
            <strong>{{ device.asset_number }}</strong>
          </div>
          <div class="list-cell inspection-date">
            {{ device.inspection_date || '-' }}
          </div>
          <div class="list-cell employee">
            <span v-if="getDeviceEmployeeInfo(device)" class="assigned-employee">
              {{ getDeviceEmployeeInfo(device)?.name }}<br>
              <small>({{ getDeviceEmployeeInfo(device)?.department }} - {{ getDeviceEmployeeInfo(device)?.position }})</small>
            </span>
            <span v-else class="unassigned-employee">
              미할당<br>
              <small>담당자 선택 필요</small>
            </span>
          </div>
          <div class="list-cell purpose">
            {{ device.purpose || '-' }}
          </div>
          <div class="list-cell model">
            {{ device.manufacturer }} {{ device.model_name }}
          </div>
          <div class="list-cell serial">
            {{ device.serial_number || '-' }}
          </div>
          <div class="list-cell company">
            {{ getDeviceCompanyName(device) }}
          </div>
          <div class="list-cell status">
            <span class="status-badge" :class="device.employee_id ? 'assigned' : 'unassigned'">
              {{ device.employee_id ? '할당됨' : '미할당' }}
            </span>
          </div>
          <div class="list-cell actions">
            <div class="action-buttons">
              <button 
                @click="editDevice(device)"
                class="action-btn edit-btn"
                title="수정"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M11 4H4C3.46957 4 2.96086 4.21071 2.58579 4.58579C2.21071 4.96086 2 5.46957 2 6V20C2 20.5304 2.21071 21.0391 2.58579 21.4142C2.96086 21.7893 3.46957 22 4 22H18C18.5304 22 19.0391 21.7893 19.4142 21.4142C19.7893 21.0391 20 20.5304 20 20V13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M18.5 2.5C18.8978 2.10217 19.4374 1.87868 20 1.87868C20.5626 1.87868 21.1022 2.10217 21.5 2.5C21.8978 2.89782 22.1213 3.43739 22.1213 4C22.1213 4.56261 21.8978 5.10217 21.5 5.5L12 15L8 16L9 12L18.5 2.5Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
              <button 
                @click="deleteDevice(device)"
                class="action-btn delete-btn"
                title="삭제"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M3 6H5H21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M19 6V20C19 20.5304 18.7893 21.0391 18.4142 21.4142C18.0391 21.7893 17.5304 22 17 22H7C6.46957 22 5.96086 21.7893 5.58579 21.4142C5.21071 21.0391 5 20.5304 5 20V6M8 6V4C8 3.46957 8.21071 2.96086 8.58579 2.58579C8.96086 2.21071 9.46957 2 10 2H14C14.5304 2 15.0391 2.21071 15.4142 2.58579C15.7893 2.96086 16 3.46957 16 4V6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </button>
            </div>
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
        <h3 class="empty-title">등록된 장비가 없습니다</h3>
        <p class="empty-text">첫 번째 장비를 추가해보세요</p>
        <button @click="showAddModal = true" class="btn-gradient empty-btn">
          장비 추가하기
        </button>
      </div>
    </div>

    <!-- 장비 추가/수정 모달 -->
    <DeviceModal 
      v-if="showAddModal"
      :device="selectedDevice"
      @close="closeModal"
      @saved="onDeviceSaved"
    />
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

// Import BaseButton component
const BaseButton = defineAsyncComponent(() => import('~/components/BaseButton.vue'))

const { devices: devicesApi, employees: employeesApi } = useApi()

// Reactive data
const devices = ref<any[]>([])
const employees = ref<any[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const searchQuery = ref('')
const filterEmployee = ref('')
const filterManufacturer = ref('')
const filterStatus = ref('')
const showAddModal = ref(false)
const selectedDevice = ref<any | null>(null)
const fileInput = ref<HTMLInputElement>()
const viewMode = ref<'card' | 'list'>('card')
const assignmentFilter = ref('') // 할당 상태 필터

// Computed properties
const manufacturers = computed(() => {
  const mfgs = new Set(devices.value.map(device => device.manufacturer))
  return Array.from(mfgs).sort()
})

const manufacturerCount = computed(() => manufacturers.value.length)

const assignedDevices = computed(() => {
  return devices.value.filter(device => device.employee_id).length
})

const recentDevices = computed(() => {
  const now = new Date()
  const thisMonth = now.getMonth()
  const thisYear = now.getFullYear()
  
  return devices.value.filter(device => {
    const created = new Date(device.created_at)
    return created.getMonth() === thisMonth && created.getFullYear() === thisYear
  }).length
})

const filteredDevices = computed(() => {
  let filtered = devices.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(device => 
      device.asset_number.toLowerCase().includes(query) ||
      device.manufacturer.toLowerCase().includes(query) ||
      device.model_name.toLowerCase().includes(query)
    )
  }

  // Employee filter
  if (filterEmployee.value) {
    filtered = filtered.filter(device => device.employee_id === filterEmployee.value)
  }

  // Manufacturer filter
  if (filterManufacturer.value) {
    filtered = filtered.filter(device => device.manufacturer === filterManufacturer.value)
  }

  // Status filter
  if (filterStatus.value) {
    if (filterStatus.value === 'assigned') {
      filtered = filtered.filter(device => device.employee_id)
    } else if (filterStatus.value === 'unassigned') {
      filtered = filtered.filter(device => !device.employee_id)
    }
  }

  // Assignment filter
  if (assignmentFilter.value) {
    if (assignmentFilter.value === 'assigned') {
      filtered = filtered.filter(device => device.employee_id)
    } else if (assignmentFilter.value === 'unassigned') {
      filtered = filtered.filter(device => !device.employee_id)
    }
  }

  return filtered
})

// Methods
// Search handler
const handleSearch = () => {
  // 검색은 computed property에서 자동으로 처리됨
  // 필요시 추가 로직 구현
}

// Load devices
const loadDevices = async () => {
  try {
    loading.value = true
    error.value = null
    
    // Build query parameters
    const params: any = {}
    if (assignmentFilter.value) {
      params.assignment_status = assignmentFilter.value
    }
    
    const [devicesResponse, employeesResponse] = await Promise.all([
      devicesApi.getAll(params),
      employeesApi.getAll()
    ])
    
    devices.value = devicesResponse.devices || []
    employees.value = employeesResponse.employees || []
  } catch (err: any) {
    console.error('Failed to load devices:', err)
    error.value = err.message || '장비 정보를 불러오는데 실패했습니다'
  } finally {
    loading.value = false
  }
}

const editDevice = (device: any) => {
  selectedDevice.value = device
  showAddModal.value = true
}

const deleteDevice = async (device: any) => {
  if (!confirm(`${device.asset_number} 장비를 삭제하시겠습니까?`)) {
    return
  }

  try {
    await devicesApi.delete(device.id)
    await loadDevices()
  } catch (err: any) {
    console.error('Failed to delete device:', err)
    alert('장비 삭제에 실패했습니다')
  }
}

const downloadQR = async (device: any) => {
  try {
    const response = await devicesApi.getById(device.id)
    // QR 코드 다운로드 로직은 백엔드에서 구현 필요
    console.log('QR download for device:', device.asset_number)
    alert('QR 코드 다운로드 기능은 준비 중입니다')
  } catch (err: any) {
    console.error('Failed to download QR code:', err)
    alert('QR 코드 다운로드에 실패했습니다')
  }
}

const exportExcel = async () => {
  try {
    const response = await devicesApi.exportExcel()
    const blob = new Blob([response], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'devices.xlsx'
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
  } catch (err: any) {
    console.error('Failed to export Excel:', err)
    alert('Excel 내보내기에 실패했습니다')
  }
}

const downloadExcelTemplate = async () => {
  try {
    // Excel 템플릿 데이터 생성 - 더 명확한 예시
    const templateData = [
      {
        '자산번호': 'AS-NB-23-002',
        '조사일자': '2025-07-27',
        '사용자': '이영희',
        '용도': '개발용',
        '장비 Type': '노트북',
        '제조사': 'Dell',
        '모델명': 'Dell Latitude 5520',
        'S/N': 'ABC123456',
        '모니터크기': '14인치',
        '지급일자': '2023-03-15',
        'CPU': 'Intel(R) Core(TM) i5-10210U CPU @ 1.60 GHz',
        '메모리': '16GB',
        '하드디스크': '512GB SSD',
        '그래픽카드': 'Intel UHD Graphics',
        'OS': 'Windows 10 Pro'
      }
    ]

    // CSV 형식으로 변환
    const headers = Object.keys(templateData[0] as Record<string, string>)
    const csvContent = [
      headers.join(','),
      ...templateData.map(row => headers.map(header => `"${(row as Record<string, string>)[header]}"`).join(','))
    ].join('\n')

    // CSV 파일 다운로드
    const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'devices_template.csv'
    document.body.appendChild(a)
    a.click()
    window.URL.revokeObjectURL(url)
    document.body.removeChild(a)
    
    alert('CSV 템플릿이 다운로드되었습니다. 이 파일을 참고하여 장비 정보를 입력하세요.')
  } catch (error) {
    console.error('Failed to download template:', error)
    alert('템플릿 다운로드에 실패했습니다.')
  }
}

const importExcel = async (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) {
    console.log('❌ [DEBUG] No file selected')
    return
  }

  console.log('🔍 [DEBUG] File selected:', {
    name: file.name,
    size: file.size,
    type: file.type
  })

  try {
    console.log('🚀 [DEBUG] Starting Excel import...')
    console.log('🚀 [DEBUG] Calling devicesApi.importExcel...')
    
    const response = await devicesApi.importExcel(file)
    
    console.log('✅ [DEBUG] Import response received:', response)
    
    if (response.success_count > 0) {
      // 2025-01-27: UPSERT 동작을 반영한 메시지 개선
      alert(`Excel 가져오기 완료!\n처리된 장비: ${response.success_count}개\n실패: ${response.error_count}개\n\n※ 자산번호가 중복된 경우 기존 데이터가 업데이트됩니다.`)
      if (response.errors && response.errors.length > 0) {
        console.log('❌ [DEBUG] Import errors:', response.errors)
        alert(`일부 오류가 발생했습니다:\n${response.errors.slice(0, 5).join('\n')}`)
      }
      await loadDevices()
    } else {
      if (response.error_count > 0) {
        alert(`가져오기 실패!\n실패: ${response.error_count}개\n\n주요 오류:\n${response.errors?.slice(0, 5).join('\n')}\n\nCSV 파일 형식을 확인해주세요.`)
      } else {
        alert('가져오기된 장비가 없습니다.')
      }
    }
  } catch (err: any) {
    console.error('❌ [DEBUG] Failed to import Excel:', err)
    console.error('❌ [DEBUG] Error details:', {
      message: err.message,
      stack: err.stack,
      name: err.name
    })
    alert(`Excel 가져오기에 실패했습니다: ${err.message || '알 수 없는 오류'}`)
  } finally {
    if (target) target.value = ''
  }
}

const closeModal = () => {
  showAddModal.value = false
  selectedDevice.value = null
}

const onDeviceSaved = async () => {
  closeModal()
  await loadDevices()
}

const getDeviceCompanyName = (device: any) => {
  if (device.employee_id) {
    const employee = employees.value.find(emp => emp.id === device.employee_id)
    return employee ? employee.company_name : '회사명 미설정'
  }
  return '회사명 미설정'
}

const getDeviceEmployeeInfo = (device: any) => {
  if (device.employee_id) {
    const employee = employees.value.find(emp => emp.id === device.employee_id)
    return employee ? {
      name: employee.name,
      department: employee.department,
      position: employee.position
    } : null
  }
  return null
}

// Load data on mount
onMounted(() => {
  loadDevices()
})
</script>

<style scoped>
.devices-container {
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* 2024-12-19: 현대적인 페이지 헤더 스타일 */
.page-header {
  margin-bottom: 32px;
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

.title-section {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 12px;
}

.page-title {
  font-size: 32px;
  font-weight: 800;
  color: #1f2937;
  margin: 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.title-badge {
  display: flex;
  align-items: center;
  gap: 4px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  padding: 8px 12px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.badge-count {
  font-size: 16px;
  font-weight: 700;
}

.badge-text {
  font-size: 12px;
}

.page-subtitle {
  color: #6b7280;
  font-size: 16px;
  font-weight: 500;
  margin: 0;
}

.header-actions {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 300px;
}

/* 검색 및 필터 섹션 */
.search-filter-section {
  display: flex;
  gap: 12px;
  align-items: center;
}

.search-box {
  position: relative;
  flex: 1;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #9ca3af;
  z-index: 1;
}

.search-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.9);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 12px 16px 12px 48px;
  font-size: 14px;
  transition: all 0.3s ease;
  color: #1f2937;
}

.search-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.search-input::placeholder {
  color: #9ca3af;
}

.filter-group {
  position: relative;
}

.filter-select {
  background: rgba(255, 255, 255, 0.9);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 12px 16px;
  font-size: 14px;
  color: #1f2937;
  transition: all 0.3s ease;
  min-width: 140px;
  cursor: pointer;
}

.filter-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

/* 뷰 전환 버튼 */
.view-toggle {
  display: flex;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 4px;
  gap: 4px;
  align-self: flex-start;
}

.view-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: none;
  border: none;
  border-radius: 8px;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.3s ease;
}

.view-btn:hover {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.view-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 액션 버튼들 */
.action-buttons {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: center;
}

.file-upload-wrapper {
  position: relative;
}

/* 기존 필터 스타일 제거 - 새로운 스타일로 대체됨 */

/* 반응형 디자인 */
@media (max-width: 1024px) {
  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 24px;
  }
  
  .header-actions {
    min-width: auto;
  }
  
  .search-filter-section {
    flex-direction: column;
    gap: 16px;
  }
  
  .action-buttons {
    justify-content: center;
  }
}

@media (max-width: 768px) {
  .devices-container {
    padding: 16px;
  }
  
  .page-header {
    margin-bottom: 24px;
  }
  
  .header-content {
    padding: 24px;
  }
  
  .page-title {
    font-size: 24px;
  }
  
  .title-section {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .search-filter-section {
    gap: 12px;
  }
  
  .action-buttons {
    flex-direction: column;
    gap: 8px;
  }
  
  .view-toggle {
    align-self: center;
  }
}

.btn-secondary {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: rgba(255, 255, 255, 0.8);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 16px;
  color: #667eea;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-secondary:hover {
  background: rgba(102, 126, 234, 0.1);
  border-color: #667eea;
  transform: translateY(-2px);
}

.btn-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.btn-gradient {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 16px;
  color: white;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.btn-gradient:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn-gradient:active {
  transform: translateY(0);
}

/* 2025-08-08: 기존 중복 스타일 제거 - 통일된 버튼 스타일 사용 */

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 24px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.loading-text {
  margin-top: 16px;
  color: #6b7280;
  font-size: 16px;
}

.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 24px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.error-icon {
  color: #ef4444;
  margin-bottom: 16px;
}

.error-title {
  font-size: 24px;
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

.stats-section {
  margin-bottom: 24px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 24px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.device-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.manufacturer-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.assigned-icon {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.new-icon {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
}

.search-section {
  margin-bottom: 24px;
}

.search-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.search-input-group {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  gap: 16px;
  align-items: center;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-input-wrapper svg {
  position: absolute;
  left: 16px;
  color: #9ca3af;
}

.search-input {
  width: 100%;
  background: rgba(255, 255, 255, 0.8);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 16px;
  padding: 16px 16px 16px 48px;
  font-size: 16px;
  transition: all 0.3s ease;
  color: #1f2937;
}

.search-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.search-input::placeholder {
  color: #9ca3af;
}

.filter-select {
  background: rgba(255, 255, 255, 0.9);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 12px 16px;
  font-size: 14px;
  color: #1f2937;
  transition: all 0.3s ease;
  min-width: 120px;
}

.filter-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.filter-select option {
  background: white;
  color: #1f2937;
}

.devices-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
}

.device-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
}

.device-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
}

.device-header {
  display: flex;
  justify-content: flex-end;
  align-items: flex-start;
  margin-bottom: 16px;
}

.device-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.edit-btn {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.edit-btn:hover {
  background: rgba(102, 126, 234, 0.2);
  transform: scale(1.05);
}

.delete-btn {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.2);
  transform: scale(1.05);
}

.device-info {
  margin-bottom: 16px;
}

.device-asset-number {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.device-model {
  color: #6b7280;
  font-size: 14px;
  margin-bottom: 12px;
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

.assigned-employee {
  color: #38f9d7;
  font-weight: 600;
}

.unassigned-employee {
  color: #fa709a;
  font-weight: 600;
}

.device-footer {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  padding-top: 16px;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
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

.status-badge.unassigned {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
  color: white;
}

.devices-list {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.list-header {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  gap: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  font-weight: 600;
  color: #6b7280;
}

.list-header-cell {
  text-align: left;
}

.list-row {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr;
  gap: 16px;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.list-row:last-child {
  border-bottom: none;
}

.list-cell {
  text-align: left;
  color: #1f2937;
}

.list-cell strong {
  font-weight: 600;
}

.list-cell .assigned-employee {
  color: #38f9d7;
  font-weight: 600;
}

.list-cell .unassigned-employee {
  color: #fa709a;
  font-weight: 600;
}

.action-buttons {
  display: flex;
  gap: 8px;
  align-items: center;
}

.action-buttons .action-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-buttons .edit-btn {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.action-buttons .edit-btn:hover {
  background: rgba(102, 126, 234, 0.2);
  transform: scale(1.05);
}

.action-buttons .delete-btn {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.action-buttons .delete-btn:hover {
  background: rgba(239, 68, 68, 0.2);
  transform: scale(1.05);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 24px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  text-align: center;
}

.empty-icon {
  color: #9ca3af;
  margin-bottom: 16px;
}

.empty-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 8px;
}

.empty-text {
  color: #6b7280;
  margin-bottom: 24px;
}

.empty-btn {
  padding: 12px 24px;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
  .devices-container {
    padding: 16px;
  }
  
  .header-content {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .page-title {
    font-size: 24px;
  }
  
  .header-actions {
    flex-wrap: wrap;
    justify-content: center;
  }
  
  .assignment-filter {
    order: -1;
    margin-bottom: 12px;
  }

  .view-toggle {
    order: -1;
    margin-bottom: 12px;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .search-input-group {
    grid-template-columns: 1fr;
  }
  
  .devices-grid {
    grid-template-columns: 1fr;
  }
  
  .device-card {
    padding: 20px;
  }
  
  .devices-list {
    padding: 16px;
    overflow-x: auto;
  }
  
  .list-header {
    grid-template-columns: 120px 100px 120px 80px 1fr 100px 120px 80px 80px;
    min-width: 900px;
  }
  
  .list-row {
    grid-template-columns: 120px 100px 120px 80px 1fr 100px 120px 80px 80px;
    min-width: 900px;
  }
  
  .list-header-cell,
  .list-cell {
    font-size: 12px;
    padding: 0 4px;
  }
}

@media (max-width: 480px) {
  .list-header {
    grid-template-columns: 100px 80px 100px 70px 1fr 80px 100px 70px 70px;
    min-width: 700px;
  }
  
  .list-row {
    grid-template-columns: 100px 80px 100px 70px 1fr 80px 100px 70px 70px;
    min-width: 700px;
  }
  
  .list-header-cell,
  .list-cell {
    font-size: 11px;
    padding: 0 2px;
  }
}
</style> 