<template>
  <div class="qr-generator-page">
    <!-- 헤더 섹션 -->
    <div class="hero-section">
      <div class="hero-content">
        <div class="hero-icon">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 9h6v12H3z"/>
            <path d="M9 3h12v18H9z"/>
            <path d="M15 9h6"/>
            <path d="M15 15h6"/>
            <path d="M9 9h6"/>
            <path d="M9 15h6"/>
          </svg>
        </div>
        <h1 class="hero-title">
          <span class="gradient-text">QR 코드 생성기</span>
        </h1>
        <p class="hero-subtitle">
          장비와 직원을 위한 고품질 QR 코드를 생성하세요
        </p>
        
        <!-- 전체 장비 액션 버튼 -->
        <div class="hero-actions">
          <BaseButton
            label="전체 장비 다운로드"
            variant="success"
            size="md"
            :loading="downloadingAll"
            :icon="'M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3'"
            @click="downloadAllDevices"
          />
          <BaseButton
            label="전체 장비 프린트"
            variant="primary"
            size="md"
            :loading="printingAll"
            :icon="'M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4zM9 17v2M15 17v2M9 9h6M9 13h6'"
            @click="printAllDevices"
          />
        </div>
      </div>
    </div>

    <!-- 메인 컨텐츠 -->
    <div class="main-content">
      <!-- QR 타입 선택 -->
      <div class="section-card">
        <h2 class="section-title">QR 코드 타입 선택</h2>
        <div class="qr-type-grid">
          <div 
            class="qr-type-card"
            :class="{ active: qrType === 'device' }"
            @click="qrType = 'device'"
          >
            <div class="qr-type-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <h3 class="qr-type-title">장비 QR 코드</h3>
            <p class="qr-type-description">장비 정보가 포함된 QR 코드</p>
          </div>
          
          <div 
            class="qr-type-card"
            :class="{ active: qrType === 'employee' }"
            @click="qrType = 'employee'"
          >
            <div class="qr-type-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <h3 class="qr-type-title">직원 QR 코드</h3>
            <p class="qr-type-description">직원 정보가 포함된 QR 코드</p>
          </div>
        </div>
      </div>

      <!-- 장비 선택 (장비 QR 코드일 때만 표시) -->
      <div v-if="qrType === 'device'" class="section-card">
        <h2 class="section-title">장비 선택</h2>
        
        <!-- 검색 필터 -->
        <div class="search-container">
          <div class="search-input-wrapper">
            <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8"/>
              <path d="m21 21-4.35-4.35"/>
            </svg>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="장비명, 제조사, 모델명으로 검색..."
              class="search-input"
            />
          </div>
        </div>

        <!-- 장비 목록 -->
        <div class="device-grid">
          <div
            v-for="device in filteredDevices"
            :key="device.id"
            class="device-card"
            :class="{ selected: selectedDevice?.id === device.id }"
            @click="selectDevice(device)"
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
              <p class="device-number">자산번호: {{ device.asset_number }}</p>
              <p class="device-status" :class="device.status">
                {{ getStatusText(device.status) }}
              </p>
            </div>
            <div class="device-check">
              <svg v-if="selectedDevice?.id === device.id" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="20,6 9,17 4,12"/>
              </svg>
            </div>
          </div>
        </div>
      </div>

      <!-- QR 생성 섹션 -->
      <div v-if="selectedDevice || qrType === 'employee'" class="section-card">
        <h2 class="section-title">QR 코드 생성</h2>
        
        <!-- 선택된 장비 정보 -->
        <div v-if="selectedDevice" class="selected-device-info">
          <div class="device-preview">
            <div class="device-preview-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <div class="device-preview-info">
              <h3 class="device-preview-name">{{ selectedDevice.manufacturer }} {{ selectedDevice.model_name }}</h3>
              <p class="device-preview-number">{{ selectedDevice.asset_number }}</p>
              <p class="device-preview-employee" v-if="selectedDevice.employees">
                담당자: {{ selectedDevice.employees.name }}
              </p>
            </div>
          </div>
        </div>

        <!-- QR 설정 -->
        <div class="qr-settings">
          <div class="setting-group">
            <label class="setting-label">QR 코드 형식</label>
            <div class="setting-options">
              <label class="radio-option">
                <input type="radio" v-model="qrFormat" value="png" />
                <span class="radio-custom"></span>
                PNG
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrFormat" value="svg" />
                <span class="radio-custom"></span>
                SVG
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrFormat" value="json" />
                <span class="radio-custom"></span>
                JSON
              </label>
            </div>
          </div>

          <div class="setting-group">
            <label class="setting-label">QR 코드 크기</label>
            <div class="size-slider">
              <input
                v-model="qrSize"
                type="range"
                min="128"
                max="512"
                step="32"
                class="size-range"
              />
              <span class="size-value">{{ qrSize }}px</span>
            </div>
          </div>
        </div>

        <!-- 액션 버튼 -->
        <div class="action-buttons">
          <BaseButton
            label="QR 코드 생성"
            variant="accent"
            size="lg"
            :loading="generating"
            :icon="'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z'"
            @click="generateQR"
          />
        </div>
      </div>

      <!-- QR 결과 섹션 -->
      <div v-if="deviceQRUrl" class="section-card result-section">
        <h2 class="section-title">생성된 QR 코드</h2>
        
        <div class="qr-result">
          <div class="qr-display">
            <img :src="deviceQRUrl" :alt="`QR Code for ${selectedDevice?.asset_number}`" class="qr-image" />
          </div>
          
          <div class="qr-actions">
            <BaseButton
              label="다운로드"
              variant="success"
              :icon="'M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3'"
              @click="downloadQR"
            />
            <BaseButton
              label="인쇄"
              variant="primary"
              :icon="'M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4zM9 17v2M15 17v2M9 9h6M9 13h6'"
              @click="printDeviceQR"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2024-12-19: 트렌디한 UI 디자인으로 QR 생성 페이지 완전 재설계
// 2024-12-19: TypeScript 오류 수정 - useApi composable 사용으로 변경

import { ref, computed, onMounted } from 'vue'
import { defineAsyncComponent } from 'vue'

const BaseButton = defineAsyncComponent(() => import('~/components/BaseButton.vue'))

// API composable 사용
const { devices: devicesApi, qr: qrApi } = useApi()

// 상태 관리
const qrType = ref<'device' | 'employee'>('device')
const searchQuery = ref('')
const selectedDevice = ref<any>(null)
const qrFormat = ref<'png' | 'svg' | 'json'>('png') // 2024-12-19: 'json' 타입 추가
const qrSize = ref(256)
const generating = ref(false)
const deviceQRUrl = ref('')
const downloadingAll = ref(false)
const printingAll = ref(false)

// 장비 데이터
const devices = ref<any[]>([])

// 필터된 장비 목록
const filteredDevices = computed(() => {
  if (!searchQuery.value) return devices.value
  
  const query = searchQuery.value.toLowerCase()
  return devices.value.filter(device => 
    device.manufacturer?.toLowerCase().includes(query) ||
    device.model_name?.toLowerCase().includes(query) ||
    device.asset_number?.toLowerCase().includes(query)
  )
})

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

// 장비 선택
const selectDevice = (device: any) => {
  selectedDevice.value = device
  deviceQRUrl.value = ''
}

// QR 코드 생성
const generateQR = async () => {
  if (!selectedDevice.value) return
  
  generating.value = true
  try {
    // 2024-12-19: useApi composable 사용으로 변경하여 TypeScript 오류 해결
    const response = await qrApi.getDeviceQR(selectedDevice.value.id, qrFormat.value)
    
    if (qrFormat.value === 'json') {
      // JSON 응답인 경우
      const qrResponse = response as any
      deviceQRUrl.value = qrResponse.qrUrl || qrResponse.data?.qrUrl
    } else {
      // Blob 응답인 경우 (PNG/SVG)
      const blob = response as Blob
      deviceQRUrl.value = URL.createObjectURL(blob)
    }
  } catch (error) {
    console.error('QR 생성 실패:', error)
  } finally {
    generating.value = false
  }
}

// QR 다운로드
const downloadQR = () => {
  if (!deviceQRUrl.value) return
  
  const link = document.createElement('a')
  link.href = deviceQRUrl.value
  link.download = `qr-${selectedDevice.value?.asset_number}.${qrFormat.value}`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// QR 인쇄
const printDeviceQR = () => {
  if (deviceQRUrl.value) {
    const printWindow = window.open('', '', 'width=400,height=500')
    if (printWindow) {
      printWindow.document.write(`
        <html>
          <head>
            <title>QR Code - ${selectedDevice.value?.asset_number}</title>
            <style>
              body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                text-align: center;
                padding: 20px;
                margin: 0;
                background: white;
              }
              .qr-container {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 400px;
              }
              .qr-code {
                margin-bottom: 20px;
              }
              .product-number {
                border: 2px solid #333;
                padding: 10px 20px;
                border-radius: 8px;
                font-size: 18px;
                font-weight: bold;
                background: #f8f9fa;
                color: #333;
              }
              .device-info {
                margin-top: 15px;
                font-size: 14px;
                color: #666;
              }
            </style>
          </head>
          <body>
            <div class="qr-container">
              <div class="qr-code">
                <img src="${deviceQRUrl.value}" style="max-width: 300px; height: auto;" />
              </div>
              <div class="product-number">
                ${selectedDevice.value?.asset_number}
              </div>
              <div class="device-info">
                <p>${selectedDevice.value?.manufacturer} ${selectedDevice.value?.model_name}</p>
                <p>담당자: ${selectedDevice.value?.employees?.name}</p>
              </div>
            </div>
          </body>
        </html>
      `)
      printWindow.document.close()
      printWindow.print()
    }
  }
}

// 전체 장비 다운로드
const downloadAllDevices = async () => {
  if (devices.value.length === 0) {
    alert('다운로드할 장비가 없습니다.')
    return
  }
  
  downloadingAll.value = true
  try {
    // 각 장비의 QR 코드를 개별적으로 다운로드
    for (const device of devices.value) {
      try {
        const qrResponse = await qrApi.getDeviceQR(device.id, 'png')
        if (qrResponse instanceof Blob) {
          const url = URL.createObjectURL(qrResponse)
          const link = document.createElement('a')
          link.href = url
          link.download = `qr-${device.asset_number}.png`
          document.body.appendChild(link)
          link.click()
          document.body.removeChild(link)
          URL.revokeObjectURL(url)
          
          // 다운로드 간격을 두어 브라우저가 처리할 시간을 줍니다
          await new Promise(resolve => setTimeout(resolve, 100))
        }
      } catch (error) {
        console.error(`장비 ${device.asset_number} QR 다운로드 실패:`, error)
      }
    }
    
    alert('전체 장비 QR 코드가 성공적으로 다운로드되었습니다.')
  } catch (error) {
    console.error('전체 장비 다운로드 실패:', error)
    alert('전체 장비 다운로드에 실패했습니다.')
  } finally {
    downloadingAll.value = false
  }
}

// 전체 장비 프린트
const printAllDevices = async () => {
  if (devices.value.length === 0) {
    alert('프린트할 장비가 없습니다.')
    return
  }
  
  printingAll.value = true
  try {
    // 모든 장비의 QR 코드를 생성하고 프린트 페이지 열기
    const printWindow = window.open('', '', 'width=800,height=600')
    if (printWindow) {
      let printContent = `
        <html>
          <head>
            <title>전체 장비 QR 코드</title>
            <style>
              body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0;
                padding: 20px;
                background: white;
              }
              .qr-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                max-width: 100%;
              }
              .qr-item {
                text-align: center;
                padding: 15px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                page-break-inside: avoid;
              }
              .qr-code {
                margin-bottom: 10px;
              }
              .qr-code img {
                max-width: 150px;
                height: auto;
              }
              .device-number {
                font-weight: bold;
                font-size: 14px;
                margin-bottom: 5px;
                color: #333;
              }
              .device-info {
                font-size: 12px;
                color: #666;
                margin-bottom: 5px;
              }
              .employee-info {
                font-size: 11px;
                color: #888;
              }
              @media print {
                .qr-item {
                  border: 1px solid #ccc;
                }
              }
            </style>
          </head>
          <body>
            <h1 style="text-align: center; margin-bottom: 30px;">전체 장비 QR 코드</h1>
            <div class="qr-grid">
      `
      
      // 각 장비의 QR 코드를 생성하여 HTML에 추가
      for (const device of devices.value) {
        try {
          const qrResponse = await qrApi.getDeviceQR(device.id, 'png')
          let qrUrl = ''
          
          if (typeof qrResponse === 'object' && 'qrUrl' in qrResponse) {
            qrUrl = (qrResponse as any).qrUrl
          } else {
            const blob = qrResponse as Blob
            qrUrl = URL.createObjectURL(blob)
          }
          
          printContent += `
            <div class="qr-item">
              <div class="qr-code">
                <img src="${qrUrl}" alt="QR Code for ${device.asset_number}" />
              </div>
              <div class="device-number">${device.asset_number}</div>
              <div class="device-info">${device.manufacturer} ${device.model_name}</div>
              <div class="employee-info">담당자: ${device.employees?.name || '미배정'}</div>
            </div>
          `
        } catch (error) {
          console.error(`장비 ${device.asset_number} QR 생성 실패:`, error)
          printContent += `
            <div class="qr-item">
              <div class="device-number">${device.asset_number}</div>
              <div class="device-info">QR 생성 실패</div>
            </div>
          `
        }
      }
      
      printContent += `
            </div>
          </body>
        </html>
      `
      
      printWindow.document.write(printContent)
      printWindow.document.close()
      
      // 프린트 다이얼로그 열기
      setTimeout(() => {
        printWindow.print()
      }, 1000)
    }
  } catch (error) {
    console.error('전체 장비 프린트 실패:', error)
    alert('전체 장비 프린트에 실패했습니다.')
  } finally {
    printingAll.value = false
  }
}

// 장비 데이터 로드
const loadDevices = async () => {
  try {
    // 2024-12-19: useApi composable 사용으로 변경하여 TypeScript 오류 해결
    const response = await devicesApi.getAll()
    devices.value = response.devices
  } catch (error) {
    console.error('장비 데이터 로드 실패:', error)
  }
}

onMounted(() => {
  loadDevices()
})
</script>

<style scoped>
/* 트렌디한 QR 생성 페이지 스타일 */
.qr-generator-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  padding: 2rem 0;
}

/* 히어로 섹션 */
.hero-section {
  text-align: center;
  margin-bottom: 3rem;
  padding: 0 2rem;
}

.hero-content {
  max-width: 600px;
  margin: 0 auto;
}

.hero-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 24px;
  margin-bottom: 1.5rem;
  color: white;
  box-shadow: 0 20px 25px -5px rgba(139, 92, 246, 0.3);
  animation: float 3s ease-in-out infinite;
}

.hero-title {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 1rem;
  line-height: 1.2;
}

.hero-subtitle {
  font-size: 1.125rem;
  color: #64748b;
  line-height: 1.6;
  margin-bottom: 2rem;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

/* 메인 컨텐츠 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

/* 섹션 카드 */
.section-card {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 24px;
  padding: 2rem;
  margin-bottom: 2rem;
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

/* QR 타입 그리드 */
.qr-type-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.qr-type-card {
  background: rgba(255, 255, 255, 0.6);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 20px;
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.qr-type-card::before {
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

.qr-type-card:hover {
  transform: translateY(-8px);
  border-color: rgba(139, 92, 246, 0.5);
  box-shadow: 0 20px 25px -5px rgba(139, 92, 246, 0.2);
}

.qr-type-card.active {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  border-color: #a855f7;
  box-shadow: 0 20px 25px -5px rgba(139, 92, 246, 0.3);
}

.qr-type-card.active::before {
  opacity: 1;
}

.qr-type-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 16px;
  margin-bottom: 1rem;
  color: white;
}

.qr-type-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #1e293b;
}

.qr-type-description {
  color: #64748b;
  font-size: 0.875rem;
}

/* 검색 컨테이너 */
.search-container {
  margin-bottom: 2rem;
}

.search-input-wrapper {
  position: relative;
  max-width: 500px;
}

.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  z-index: 10;
}

.search-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  font-size: 1rem;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #a855f7;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

/* 장비 그리드 */
.device-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1rem;
}

.device-card {
  background: rgba(255, 255, 255, 0.6);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.device-card:hover {
  transform: translateY(-4px);
  border-color: rgba(139, 92, 246, 0.3);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.device-card.selected {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  border-color: #a855f7;
  box-shadow: 0 10px 15px -3px rgba(139, 92, 246, 0.2);
}

.device-icon {
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

.device-info {
  flex: 1;
}

.device-name {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.25rem;
  color: #1e293b;
}

.device-number {
  font-size: 0.875rem;
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

.device-check {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #10b981 0%, #047857 100%);
  border-radius: 8px;
  color: white;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.device-card.selected .device-check {
  opacity: 1;
}

/* 선택된 장비 정보 */
.selected-device-info {
  margin-bottom: 2rem;
}

.device-preview {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: rgba(139, 92, 246, 0.05);
  border: 1px solid rgba(139, 92, 246, 0.2);
  border-radius: 16px;
  padding: 1.5rem;
}

.device-preview-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 16px;
  color: white;
}

.device-preview-name {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.25rem;
  color: #1e293b;
}

.device-preview-number {
  font-size: 0.875rem;
  color: #64748b;
  margin-bottom: 0.25rem;
}

.device-preview-employee {
  font-size: 0.875rem;
  color: #10b981;
  font-weight: 500;
}

/* QR 설정 */
.qr-settings {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.setting-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.setting-label {
  font-weight: 600;
  color: #1e293b;
  font-size: 0.875rem;
}

.setting-options {
  display: flex;
  gap: 1rem;
}

.radio-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-size: 0.875rem;
  color: #64748b;
}

.radio-option input[type="radio"] {
  display: none;
}

.radio-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #e2e8f0;
  border-radius: 50%;
  position: relative;
  transition: all 0.3s ease;
}

.radio-option input[type="radio"]:checked + .radio-custom {
  border-color: #a855f7;
  background: #a855f7;
}

.radio-option input[type="radio"]:checked + .radio-custom::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background: white;
  border-radius: 50%;
}

.size-slider {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.size-range {
  flex: 1;
  height: 6px;
  border-radius: 3px;
  background: #e2e8f0;
  outline: none;
  -webkit-appearance: none;
  appearance: none;
}

.size-range::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #a855f7;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.size-value {
  font-weight: 600;
  color: #1e293b;
  min-width: 60px;
  text-align: right;
}

/* 액션 버튼 */
.action-buttons {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

/* QR 결과 섹션 */
.result-section {
  text-align: center;
}

.qr-result {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2rem;
}

.qr-display {
  background: white;
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.qr-image {
  max-width: 300px;
  height: auto;
  border-radius: 12px;
}

.qr-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  justify-content: center;
}

/* 애니메이션 */
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

/* 반응형 */
@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }
  
  .hero-icon {
    width: 60px;
    height: 60px;
  }
  
  .hero-actions {
    flex-direction: column;
    width: 100%;
    max-width: 300px;
    margin: 0 auto;
  }
  
  .section-card {
    padding: 1.5rem;
    margin-bottom: 1.5rem;
  }
  
  .qr-type-grid {
    grid-template-columns: 1fr;
  }
  
  .device-grid {
    grid-template-columns: 1fr;
  }
  
  .qr-settings {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .qr-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .main-content {
    padding: 0 1rem;
  }
  
  .hero-section {
    padding: 0 1rem;
  }
}
</style> 