<template>
  <div class="container py-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-bold text-gray-900">QR 스캐너</h1>
      <p class="text-gray-600 mt-2">QR 코드를 스캔하여 장비 정보를 수정하세요</p>
    </div>

    <!-- Scanner Container -->
    <div class="bg-white rounded-lg border p-6">
      <div class="text-center mb-6">
        <h3 class="text-lg font-semibold mb-2">QR 코드 스캔</h3>
        <p class="text-gray-600">카메라를 장비의 QR 코드에 맞춰주세요</p>
      </div>

      <!-- Camera Container -->
      <div class="relative mx-auto max-w-md">
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
          
          <!-- Scanning Overlay -->
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="w-48 h-48 border-2 border-white rounded-lg relative">
              <!-- Corner indicators -->
              <div class="absolute top-0 left-0 w-6 h-6 border-t-4 border-l-4 border-primary"></div>
              <div class="absolute top-0 right-0 w-6 h-6 border-t-4 border-r-4 border-primary"></div>
              <div class="absolute bottom-0 left-0 w-6 h-6 border-b-4 border-l-4 border-primary"></div>
              <div class="absolute bottom-0 right-0 w-6 h-6 border-b-4 border-r-4 border-primary"></div>
            </div>
          </div>

          <!-- Loading State -->
          <div v-if="loading" class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
            <div class="text-white text-center">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-white mx-auto mb-2"></div>
              <p>카메라를 초기화하는 중...</p>
            </div>
          </div>

          <!-- Error State -->
          <div v-if="error" class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
            <div class="text-white text-center">
              <svg class="w-12 h-12 mx-auto mb-2 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
              </svg>
              <p class="mb-2">{{ error }}</p>
              <button @click="startCamera" class="btn btn-primary">
                다시 시도
              </button>
            </div>
          </div>
        </div>

        <!-- Controls -->
        <div class="mt-4 flex justify-center space-x-4">
          <button 
            @click="startCamera"
            :disabled="loading"
            class="btn btn-primary"
          >
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"/>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"/>
            </svg>
            카메라 시작
          </button>
          
          <button 
            @click="stopCamera"
            :disabled="!isScanning"
            class="btn btn-secondary"
          >
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
            카메라 중지
          </button>
        </div>
      </div>

      <!-- Manual Input -->
      <div class="mt-8 text-center">
        <div class="border-t pt-6">
          <h4 class="font-medium mb-4">QR 코드를 직접 입력</h4>
          <div class="max-w-md mx-auto">
            <textarea
              v-model="manualQRInput"
              placeholder="QR 코드 데이터를 여기에 붙여넣으세요..."
              class="form-input w-full h-24 resize-none"
            ></textarea>
            <button 
              @click="processManualQR"
              :disabled="!manualQRInput.trim()"
              class="btn btn-primary mt-2"
            >
              QR 코드 처리
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Processing Modal -->
    <div v-if="processing" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <div class="text-center">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <h3 class="text-lg font-semibold mb-2">QR 코드 처리 중...</h3>
          <p class="text-gray-600">{{ processingMessage }}</p>
        </div>
      </div>
    </div>

    <!-- Error Modal -->
    <div v-if="showErrorModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md mx-4">
        <div class="text-center">
          <svg class="w-12 h-12 mx-auto mb-4 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
          </svg>
          <h3 class="text-lg font-semibold mb-2">오류 발생</h3>
          <p class="text-gray-600 mb-4">{{ errorMessage }}</p>
          <button @click="showErrorModal = false" class="btn btn-primary">
            확인
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { QRCodeData } from '~/types'
import { BrowserMultiFormatReader, Result } from '@zxing/library'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const api = useApi()
const router = useRouter()

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

// QR Scanner
let stream: MediaStream | null = null
let qrReader: BrowserMultiFormatReader | null = null

// Start camera
const startCamera = async () => {
  try {
    loading.value = true
    error.value = null

    // Request camera access
    stream = await navigator.mediaDevices.getUserMedia({
      video: {
        facingMode: 'environment', // Use back camera if available
        width: { ideal: 1280 },
        height: { ideal: 720 }
      }
    })

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
    error.value = '카메라에 접근할 수 없습니다. 카메라 권한을 확인해주세요.'
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
}

// Start QR scanning
const startQRScanning = () => {
  if (!video.value) return

  try {
    qrReader = new BrowserMultiFormatReader()
    
    qrReader.decodeFromVideoDevice(
      null, // Use default camera
      video.value,
      (result: Result | null, error: any) => {
        if (result) {
          console.log('QR Code detected:', result.getText())
          processQRString(result.getText())
        }
        
        if (error && error.name !== 'NotFoundException') {
          console.error('QR scanning error:', error)
        }
      }
    )
  } catch (err) {
    console.error('Failed to start QR scanning:', err)
         // Fallback to simulated scanning for demo
     setTimeout(() => {
       const mockQRData: QRCodeData = {
         type: 'device',
         id: 'mock-device-id',
         asset_number: 'AS-NB-23-01',
         manufacturer: 'HP',
         model_name: 'HP ProBook 450 G5',
         serial_number: 'SCD8518SPP',
         employee: {
           name: '김규일',
           department: '개발팀',
           position: '개발자'
         },
         company: 'Test Company',
         generated_at: new Date().toISOString()
       }
       
       processQRData(mockQRData)
     }, 3000)
  }
}

// Process QR string
const processQRString = async (qrString: string) => {
  try {
    processing.value = true
    processingMessage.value = 'QR 코드를 분석하는 중...'

    // Try to decode QR string
    const decodedResult = await api.qr.decode(qrString)
    
    if (!decodedResult.is_valid) {
      throw new Error('유효하지 않은 QR 코드입니다.')
    }

    await processQRData(decodedResult.data)
    
  } catch (err: any) {
    console.error('QR string processing error:', err)
    errorMessage.value = err.message || 'QR 코드 처리 중 오류가 발생했습니다.'
    showErrorModal.value = true
  } finally {
    processing.value = false
    stopCamera()
  }
}

// Process QR data
const processQRData = async (qrData: QRCodeData) => {
  try {
    processing.value = true
    processingMessage.value = 'QR 코드를 분석하는 중...'

    // Validate QR data
    if (!qrData.type || !qrData.id) {
      throw new Error('유효하지 않은 QR 코드입니다.')
    }

    if (qrData.type !== 'device') {
      throw new Error('장비 QR 코드만 지원됩니다.')
    }

    // Verify device exists
    processingMessage.value = '장비 정보를 확인하는 중...'
    
    try {
      const device = await api.devices.getById(qrData.id)
      
      // Navigate to device edit page
      await router.push(`/devices/edit/${qrData.id}`)
      
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

// Process manual QR input
const processManualQR = async () => {
  if (!manualQRInput.value.trim()) return

  try {
    processing.value = true
    processingMessage.value = 'QR 코드를 분석하는 중...'

    // Try to parse as JSON
    let qrData: QRCodeData
    try {
      qrData = JSON.parse(manualQRInput.value.trim())
    } catch {
      throw new Error('유효하지 않은 QR 코드 형식입니다.')
    }

    await processQRData(qrData)
    
  } catch (err: any) {
    console.error('Manual QR processing error:', err)
    errorMessage.value = err.message || 'QR 코드 처리 중 오류가 발생했습니다.'
    showErrorModal.value = true
  } finally {
    processing.value = false
    manualQRInput.value = ''
  }
}

// Cleanup on unmount
onUnmounted(() => {
  stopCamera()
})

// Start camera on mount
onMounted(() => {
  startCamera()
})
</script> 