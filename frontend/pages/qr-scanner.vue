<template>
  <div class="container py-4 md:py-8 px-4 md:px-0">
    <!-- Header with mobile optimization -->
    <div class="mb-6 md:mb-8 text-center">
      <div class="inline-flex items-center justify-center w-12 h-12 md:w-16 md:h-16 bg-gradient-to-br from-green-500 to-blue-600 rounded-full mb-3 md:mb-4">
        <svg class="w-6 h-6 md:w-8 md:h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
        </svg>
      </div>
      <h1 class="text-2xl md:text-3xl font-bold text-gray-900 mb-2">QR 스캐너</h1>
      <p class="text-sm md:text-base text-gray-600">QR 코드를 스캔하여 장비 정보를 수정하세요</p>
      
      <!-- 2025-01-27: 리다이렉트 상태 표시 -->
      <div v-if="isRedirectedFromLogin" class="mt-2">
        <div class="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-xs font-medium">
          <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"/>
          </svg>
          로그인 후 자동 이동됨
        </div>
      </div>
      
      <!-- 2025-08-13: QR 스캐너 상태 표시 추가 -->
      <div class="mt-4 flex justify-center">
        <div class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium" 
             :class="scannerStatus.class">
          <div class="w-2 h-2 rounded-full mr-2" :class="scannerStatus.dot"></div>
          {{ scannerStatus.text }}
        </div>
      </div>
    </div>

    <!-- Scanner Container with mobile optimization -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-4 md:p-6">
      <div class="text-center mb-4 md:mb-6">
        <h3 class="text-lg md:text-xl font-semibold mb-2">QR 코드 스캔</h3>
        <p class="text-sm md:text-base text-gray-600">카메라를 장비의 QR 코드에 맞춰주세요</p>
      </div>

      <!-- Camera Container with mobile optimization -->
      <div class="relative mx-auto max-w-sm md:max-w-md">
        <div 
          ref="videoContainer"
          class="relative bg-black rounded-lg overflow-hidden"
          style="aspect-ratio: 4/3;"
        >
          <video
            ref="video"
            class="w-full h-full object-cover"
            autoplay
            playsinline
            muted
          ></video>
          
          <!-- Scanning Overlay with mobile optimization -->
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="w-40 h-40 md:w-48 md:h-48 border-2 border-white rounded-lg relative">
              <!-- Corner indicators with mobile optimization -->
              <div class="absolute top-0 left-0 w-4 h-4 md:w-6 md:h-6 border-t-4 border-l-4 border-green-400"></div>
              <div class="absolute top-0 right-0 w-4 h-4 md:w-6 md:h-6 border-t-4 border-r-4 border-green-400"></div>
              <div class="absolute bottom-0 left-0 w-4 h-4 md:w-6 md:h-6 border-b-4 border-l-4 border-green-400"></div>
              <div class="absolute bottom-0 right-0 w-4 h-4 md:w-6 md:h-6 border-b-4 border-r-4 border-green-400"></div>
              
              <!-- 2025-08-13: Enhanced scanning animation for mobile -->
              <div class="absolute inset-0 border-t-2 border-green-400 animate-pulse"></div>
              
              <!-- 2025-08-13: QR 코드 감지 표시 -->
              <div v-if="qrDetected" class="absolute inset-0 bg-green-500 bg-opacity-20 flex items-center justify-center">
                <div class="text-white text-center">
                  <svg class="w-8 h-8 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  <p class="text-sm font-medium">QR 코드 감지됨</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Loading State with mobile optimization -->
          <div v-if="loading" class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
            <div class="text-white text-center px-4">
              <div class="animate-spin rounded-full h-6 w-6 md:h-8 md:w-8 border-b-2 border-white mx-auto mb-2"></div>
              <p class="text-sm md:text-base">카메라를 초기화하는 중...</p>
            </div>
          </div>

          <!-- Error State with mobile optimization -->
          <div v-if="error" class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
            <div class="text-white text-center px-4">
              <svg class="w-8 h-8 md:w-12 md:h-12 mx-auto mb-2 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
              </svg>
              <p class="mb-3 text-sm md:text-base">{{ error }}</p>
              <button @click="startCamera" class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors duration-200 text-sm md:text-base">
                다시 시도
              </button>
            </div>
          </div>
        </div>

        <!-- Controls with mobile optimization -->
        <div class="mt-4 flex justify-center space-x-3 md:space-x-4">
          <button 
            @click="startCamera"
            :disabled="loading"
            class="bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white font-semibold py-2 px-4 md:py-3 md:px-6 rounded-lg transition-colors duration-200 flex items-center justify-center text-sm md:text-base"
          >
            <svg class="w-4 h-4 md:w-5 md:h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"/>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            카메라 시작
          </button>
          
          <button 
            @click="stopCamera"
            :disabled="!isScanning"
            class="bg-gray-600 hover:bg-gray-700 disabled:bg-gray-400 text-white font-semibold py-2 px-4 md:py-3 md:px-6 rounded-lg transition-colors duration-200 flex items-center justify-center text-sm md:text-base"
          >
            <svg class="w-4 h-4 md:w-5 md:h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
            카메라 중지
          </button>
        </div>

        <!-- 2025-08-13: QR 스캔 통계 추가 -->
        <div v-if="scanStats.totalScans > 0" class="mt-4 text-center">
          <div class="text-sm text-gray-600">
            총 스캔: {{ scanStats.totalScans }} | 성공: {{ scanStats.successfulScans }} | 실패: {{ scanStats.failedScans }}
          </div>
        </div>
      </div>

      <!-- Manual Input with mobile optimization -->
      <div class="mt-6 md:mt-8 text-center">
        <div class="border-t pt-4 md:pt-6">
          <h4 class="font-medium mb-3 md:mb-4 text-sm md:text-base">QR 코드를 직접 입력</h4>
          <div class="max-w-sm md:max-w-md mx-auto">
            <textarea
              v-model="manualQRInput"
              placeholder="QR 코드 데이터를 여기에 붙여넣으세요..."
              class="w-full h-20 md:h-24 resize-none px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-colors text-sm md:text-base"
            ></textarea>
            <div class="mt-2 flex justify-center space-x-2">
              <button 
                @click="processManualQR"
                :disabled="!manualQRInput.trim()"
                class="bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white font-semibold py-2 px-4 md:py-3 md:px-6 rounded-lg transition-colors duration-200 text-sm md:text-base"
              >
                QR 코드 처리
              </button>
              <button 
                @click="loadTestQR"
                class="bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 md:py-3 md:px-6 rounded-lg transition-colors duration-200 text-sm md:text-base"
              >
                테스트 QR 로드
              </button>
              <!-- 2025-08-13: QR 코드 검증 버튼 추가 -->
              <button 
                @click="validateQR"
                :disabled="!manualQRInput.trim()"
                class="bg-yellow-600 hover:bg-yellow-700 disabled:bg-gray-400 text-white font-semibold py-2 px-4 md:py-3 md:px-6 rounded-lg transition-colors duration-200 text-sm md:text-base"
              >
                검증
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 2025-08-13: QR 코드 검증 결과 표시 -->
      <div v-if="validationResult" class="mt-4 p-4 rounded-lg" :class="validationResult.is_valid ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'">
        <div class="flex items-center">
          <svg v-if="validationResult.is_valid" class="w-5 h-5 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
          </svg>
          <svg v-else class="w-5 h-5 text-red-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
          <div>
            <p class="font-medium" :class="validationResult.is_valid ? 'text-green-800' : 'text-red-800'">
              {{ validationResult.is_valid ? '유효한 QR 코드입니다' : '유효하지 않은 QR 코드입니다' }}
            </p>
            <p class="text-sm" :class="validationResult.is_valid ? 'text-green-600' : 'text-red-600'">
              형식: {{ validationResult.format }} | 버전: {{ validationResult.version }} | 타입: {{ validationResult.type }}
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Processing Modal with mobile optimization -->
    <div v-if="processing" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl p-6 w-full max-w-sm md:max-w-md mx-auto">
        <div class="text-center">
          <div class="animate-spin rounded-full h-6 w-6 md:h-8 md:w-8 border-b-2 border-green-500 mx-auto mb-3 md:mb-4"></div>
          <h3 class="text-base md:text-lg font-semibold mb-2">QR 코드 처리 중...</h3>
          <p class="text-sm md:text-base text-gray-600">{{ processingMessage }}</p>
        </div>
      </div>
    </div>

    <!-- Error Modal with mobile optimization -->
    <div v-if="showErrorModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl p-6 w-full max-w-sm md:max-w-md mx-auto">
        <div class="text-center">
          <svg class="w-8 h-8 md:w-12 md:h-12 mx-auto mb-3 md:mb-4 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
          </svg>
          <h3 class="text-base md:text-lg font-semibold mb-2">오류 발생</h3>
          <p class="text-sm md:text-base text-gray-600 mb-4">{{ errorMessage }}</p>
          <button @click="showErrorModal = false" class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 md:py-3 md:px-6 rounded-lg transition-colors duration-200 text-sm md:text-base">
            확인
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2025-08-13: QR 스캐너 고도화 - 모바일 최적화 및 고급 기능 추가
// - 향상된 모바일 카메라 지원
// - QR 코드 검증 기능
// - 스캔 통계 및 상태 표시
// - 개선된 에러 핸들링

import type { QRCodeData } from '~/types'
import { BrowserMultiFormatReader, Result } from '@zxing/library'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const api = useApi()
const router = useRouter()

// 2025-01-27: 리다이렉트 상태 감지
const isRedirectedFromLogin = computed(() => {
  if (process.client) {
    return sessionStorage.getItem('redirected_from_login') === 'true'
  }
  return false
})

// Refs
const video = ref<HTMLVideoElement>()
const videoContainer = ref<HTMLDivElement>()

// State
const loading = ref(false)
const error = ref<string | null>(null)
const isScanning = ref(false)
const processing = ref(false)
const processingMessage = ref('')
const showErrorModal = ref(false)
const errorMessage = ref('')
const manualQRInput = ref('')
const qrDetected = ref(false)
const validationResult = ref<any>(null)

// 2025-08-13: 스캔 통계 추가
const scanStats = ref({
  totalScans: 0,
  successfulScans: 0,
  failedScans: 0
})

// 2025-08-13: 스캐너 상태 계산
const scannerStatus = computed(() => {
  if (loading.value) {
    return {
      text: '초기화 중...',
      class: 'bg-yellow-100 text-yellow-800',
      dot: 'bg-yellow-400'
    }
  } else if (error.value) {
    return {
      text: '오류 발생',
      class: 'bg-red-100 text-red-800',
      dot: 'bg-red-400'
    }
  } else if (isScanning.value) {
    return {
      text: '스캔 중...',
      class: 'bg-green-100 text-green-800',
      dot: 'bg-green-400'
    }
  } else {
    return {
      text: '대기 중',
      class: 'bg-gray-100 text-gray-800',
      dot: 'bg-gray-400'
    }
  }
})

// QR Scanner
let stream: MediaStream | null = null
let qrReader: BrowserMultiFormatReader | null = null

// Start camera with enhanced mobile optimization
const startCamera = async () => {
  try {
    loading.value = true
    error.value = null
    qrDetected.value = false

    // 2025-08-13: Enhanced camera constraints for better mobile support
    const constraints = {
      video: {
        facingMode: 'environment', // Use back camera on mobile
        width: { 
          ideal: window.innerWidth < 768 ? 640 : 1280,
          min: 320,
          max: 1920
        },
        height: { 
          ideal: window.innerWidth < 768 ? 480 : 720,
          min: 240,
          max: 1080
        },
        aspectRatio: { ideal: 4/3 },
        frameRate: { ideal: 30, min: 15 }
      }
    }

    stream = await navigator.mediaDevices.getUserMedia(constraints)

    if (video.value) {
      video.value.srcObject = stream
      await video.value.play()
      
      isScanning.value = true
      loading.value = false
      
      // Start QR scanning
      startQRScanning()
    }
  } catch (err: any) {
    console.error('Camera error:', err)
    
    // 2025-08-13: Enhanced mobile-specific error messages
    if (err.name === 'NotAllowedError') {
      error.value = '카메라 권한이 거부되었습니다. 브라우저 설정에서 카메라 권한을 허용해주세요.'
    } else if (err.name === 'NotFoundError') {
      error.value = '카메라를 찾을 수 없습니다. 카메라가 연결되어 있는지 확인해주세요.'
    } else if (err.name === 'NotSupportedError') {
      error.value = '이 브라우저는 카메라를 지원하지 않습니다. 다른 브라우저를 사용해주세요.'
    } else if (err.name === 'OverconstrainedError') {
      error.value = '카메라 설정이 지원되지 않습니다. 다른 카메라를 시도해주세요.'
    } else {
      error.value = '카메라에 접근할 수 없습니다. 카메라 권한을 확인해주세요.'
    }
    
    loading.value = false
  }
}

// Stop camera
const stopCamera = () => {
  if (stream) {
    stream.getTracks().forEach(track => track.stop())
    stream = null
  }
  
  if (qrReader) {
    qrReader.reset()
    qrReader = null
  }
  
  isScanning.value = false
  qrDetected.value = false
}

// Start QR scanning with enhanced mobile optimization
const startQRScanning = () => {
  if (!video.value) return

  try {
    qrReader = new BrowserMultiFormatReader()
    
    // 2025-08-13: Enhanced mobile-optimized scanning configuration
    const hints = {
      tryHarder: true,
      pureBarcode: false,
      possibleFormats: ['QR_CODE', 'DATA_MATRIX', 'AZTEC']
    }
    
    qrReader.decodeFromVideoDevice(
      null, // Use default camera
      video.value,
      (result: Result | null, error: any) => {
        if (result) {
          console.log('QR Code detected:', result.getText())
          qrDetected.value = true
          scanStats.value.totalScans++
          
          // Process QR after a short delay to show detection feedback
          setTimeout(() => {
            processQRString(result.getText())
          }, 500)
        }
        
        if (error && error.name !== 'NotFoundException') {
          console.error('QR scanning error:', error)
        }
      }
    )
  } catch (err) {
    console.error('Failed to start QR scanning:', err)
    
    // 2025-08-13: Enhanced fallback to simulated scanning for demo
    setTimeout(() => {
      const mockQRData = {
        t: 'd', // type: device (simplified)
        i: 'mock-device-id',
        a: 'AS-NB-23-01', // asset_number
        m: 'HP', // manufacturer
        n: 'HP ProBook 450 G5', // model_name
        s: 'SCD8518SPP', // serial_number
        e: '김규일', // employee name
        c: 'Test Company', // company
        g: new Date().toISOString().split('T')[0], // generated date
        dt: 'Laptop', // device type
        cpu: 'Intel i7', // CPU
        mem: '16GB', // memory
        str: '512GB SSD', // storage
        os: 'Windows 11', // OS
        ca: new Date().toISOString().split('T')[0], // created date
        v: '2.0' // version
      }
      
      console.log('🔍 [QR SCANNER] Using mock QR data for testing')
      qrDetected.value = true
      scanStats.value.totalScans++
      processQRString(JSON.stringify(mockQRData))
    }, 3000)
  }
}

// Process QR string with enhanced validation
const processQRString = async (qrString: string) => {
  try {
    processing.value = true
    processingMessage.value = 'QR 코드를 분석하는 중...'

    // 2025-08-13: Enhanced QR string validation
    if (!qrString || qrString.trim() === '') {
      throw new Error('QR 코드 데이터가 비어있습니다.')
    }

    console.log('🔍 [QR SCANNER] Processing QR string:', qrString.substring(0, 100) + '...')

    // Try to decode QR string
    const decodedResult = await api.qr.decode(qrString)
    
    console.log('🔍 [QR SCANNER] Decoded result:', decodedResult)
    
    if (!decodedResult.is_valid) {
      scanStats.value.failedScans++
      throw new Error('유효하지 않은 QR 코드입니다.')
    }

    await processQRData(decodedResult.data)
    scanStats.value.successfulScans++
    
  } catch (err: any) {
    console.error('QR string processing error:', err)
    scanStats.value.failedScans++
    errorMessage.value = err.message || 'QR 코드 처리 중 오류가 발생했습니다.'
    showErrorModal.value = true
  } finally {
    processing.value = false
    stopCamera()
  }
}

// Process QR data with enhanced validation and direct link support
const processQRData = async (qrData: any) => {
  try {
    processing.value = true
    processingMessage.value = 'QR 코드를 분석하는 중...'

    // 2025-08-13: Enhanced QR data validation with direct link support
    let deviceId: string
    let deviceType: string
    let directLink: string | null = null

    if (qrData.t) {
      // Simplified format
      deviceType = qrData.t === 'd' ? 'device' : 'employee'
      deviceId = qrData.i
      directLink = qrData.l || null // 2025-08-13: Extract direct link
    } else {
      // Full format (backward compatibility)
      deviceType = qrData.type
      deviceId = qrData.id
      directLink = qrData.link || null
    }

    // Validate QR data
    if (!deviceType || !deviceId) {
      throw new Error('유효하지 않은 QR 코드입니다.')
    }

    if (deviceType !== 'device') {
      throw new Error('장비 QR 코드만 지원됩니다.')
    }

    // 2025-08-13: Handle direct link if available
    if (directLink) {
      processingMessage.value = '장비 페이지로 이동하는 중...'
      
      // Check if it's a relative link (starts with /)
      if (directLink.startsWith('/')) {
        // Navigate to relative path
        await router.push(directLink)
        return
      } else if (directLink.startsWith('http')) {
        // External link - open in new tab or navigate if same domain
        const currentDomain = window.location.origin
        if (directLink.startsWith(currentDomain)) {
          // Same domain - navigate to the path
          const path = directLink.replace(currentDomain, '')
          await router.push(path)
          return
        } else {
          // Different domain - ask user if they want to open
          if (confirm('외부 링크를 새 탭에서 열까요?')) {
            window.open(directLink, '_blank')
          }
          return
        }
      }
    }

    // Fallback: Verify device exists and navigate using device ID
    processingMessage.value = '장비 정보를 확인하는 중...'
    
    try {
      const device = await api.devices.getById(deviceId)
      
      // Navigate to device edit page
      await router.push(`/devices/edit/${deviceId}`)
      
    } catch (err: any) {
      if (err.message.includes('not found')) {
        throw new Error('해당 장비를 찾을 수 없습니다.')
      } else {
        throw new Error('장비 정보를 불러올 수 없습니다.')
      }
    }

  } catch (err: any) {
    console.error('QR processing error:', err)
    errorMessage.value = err.message || 'QR 코드 처리 중 오류가 발생했습니다.'
    showErrorModal.value = true
  } finally {
    processing.value = false
    stopCamera()
  }
}

// Process manual QR input with enhanced validation
const processManualQR = async () => {
  if (!manualQRInput.value.trim()) return

  try {
    processing.value = true
    processingMessage.value = 'QR 코드를 분석하는 중...'

    // Try to parse as JSON (both simplified and full format)
    let qrData: any
    try {
      qrData = JSON.parse(manualQRInput.value.trim())
    } catch {
      throw new Error('유효하지 않은 QR 코드 형식입니다.')
    }

    // Validate the parsed data
    if (!qrData.t && !qrData.type) {
      throw new Error('QR 코드에 타입 정보가 없습니다.')
    }

    // Convert to QR string format for API
    const qrString = JSON.stringify(qrData)
    
    // Use the same decode API for consistency
    const decodedResult = await api.qr.decode(qrString)
    
    if (!decodedResult.is_valid) {
      throw new Error('유효하지 않은 QR 코드입니다.')
    }

    await processQRData(decodedResult.data)
    
  } catch (err: any) {
    console.error('Manual QR processing error:', err)
    errorMessage.value = err.message || 'QR 코드 처리 중 오류가 발생했습니다.'
    showErrorModal.value = true
  } finally {
    processing.value = false
    manualQRInput.value = ''
  }
}

// 2025-08-13: QR 코드 검증 기능 추가
const validateQR = async () => {
  if (!manualQRInput.value.trim()) return

  try {
    const qrString = manualQRInput.value.trim()
    
    // Try to parse as JSON first
    let qrData: any
    try {
      qrData = JSON.parse(qrString)
    } catch {
      validationResult.value = {
        is_valid: false,
        format: 'unknown',
        version: 'unknown',
        type: 'unknown',
        error: 'Invalid JSON format'
      }
      return
    }

    // Use validation API
    const result = await api.qr.validate(qrString)
    validationResult.value = result
    
  } catch (err: any) {
    console.error('QR validation error:', err)
    validationResult.value = {
      is_valid: false,
      format: 'unknown',
      version: 'unknown',
      type: 'unknown',
      error: 'Validation failed'
    }
  }
}

// Load test QR data for debugging
const loadTestQR = () => {
  const testQRData = {
    t: 'd', // type: device (simplified)
    i: 'test-device-123',
    a: 'AS-TEST-001', // asset_number
    m: 'Samsung', // manufacturer
    n: 'Galaxy Tab S9', // model_name
    s: 'TEST123456', // serial_number
    e: '테스트 사용자', // employee name
    c: 'Test Company', // company
    g: new Date().toISOString().split('T')[0], // generated date
    dt: 'Tablet', // device type
    cpu: 'Snapdragon 8 Gen 2', // CPU
    mem: '8GB', // memory
    str: '256GB', // storage
    os: 'Android 13', // OS
    ca: new Date().toISOString().split('T')[0], // created date
    v: '2.0', // version
    l: `${window.location.origin}/devices/AS-TEST-001` // 2025-08-13: Direct link for testing
  }
  
  manualQRInput.value = JSON.stringify(testQRData, null, 2)
  console.log('🔍 [QR SCANNER] Loaded test QR data with direct link')
}

// Enhanced mobile-specific optimizations
const handleOrientationChange = () => {
  // Reinitialize camera on orientation change for mobile
  if (isScanning.value) {
    stopCamera()
    setTimeout(() => {
      startCamera()
    }, 500)
  }
}

// Enhanced cleanup on unmount
onUnmounted(() => {
  stopCamera()
  window.removeEventListener('orientationchange', handleOrientationChange)
  window.removeEventListener('resize', handleOrientationChange)
})

// Start camera on mount with enhanced mobile optimization
onMounted(() => {
  // Add orientation change listener for mobile
  window.addEventListener('orientationchange', handleOrientationChange)
  window.addEventListener('resize', handleOrientationChange)
  
  // 2025-01-27: 리다이렉트 플래그 정리 (페이지 로드 후)
  if (process.client && isRedirectedFromLogin.value) {
    setTimeout(() => {
      sessionStorage.removeItem('redirected_from_login')
    }, 3000) // 3초 후 플래그 제거
  }
  
  // Start camera with slight delay for mobile devices
  setTimeout(() => {
    startCamera()
  }, 100)
})
</script> 