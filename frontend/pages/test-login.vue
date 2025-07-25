<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center">
    <div class="max-w-md w-full bg-white rounded-lg shadow-md p-6">
      <h1 class="text-2xl font-bold text-center mb-6">로그인 테스트</h1>
      
      <!-- Test Results -->
      <div class="mb-6 space-y-3">
        <div class="p-3 rounded border" :class="testResults.backend ? 'border-green-200 bg-green-50' : 'border-red-200 bg-red-50'">
          <div class="flex items-center">
            <div class="w-4 h-4 rounded-full mr-2" :class="testResults.backend ? 'bg-green-500' : 'bg-red-500'"></div>
            <span class="text-sm font-medium">백엔드 연결: {{ testResults.backend ? '성공' : '실패' }}</span>
          </div>
        </div>
        
        <div class="p-3 rounded border" :class="testResults.login ? 'border-green-200 bg-green-50' : 'border-red-200 bg-red-50'">
          <div class="flex items-center">
            <div class="w-4 h-4 rounded-full mr-2" :class="testResults.login ? 'bg-green-500' : 'bg-red-500'"></div>
            <span class="text-sm font-medium">로그인 API: {{ testResults.login ? '성공' : '실패' }}</span>
          </div>
        </div>
        
        <div class="p-3 rounded border" :class="testResults.timeout ? 'border-green-200 bg-green-50' : 'border-red-200 bg-red-50'">
          <div class="flex items-center">
            <div class="w-4 h-4 rounded-full mr-2" :class="testResults.timeout ? 'bg-green-500' : 'bg-red-500'"></div>
            <span class="text-sm font-medium">타임아웃: {{ testResults.timeout ? '정상' : '발생' }}</span>
          </div>
        </div>
      </div>

      <!-- Test Buttons -->
      <div class="space-y-3">
        <button 
          @click="testBackendConnection" 
          class="w-full px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
        >
          백엔드 연결 테스트
        </button>
        
        <button 
          @click="testLoginAPI" 
          class="w-full px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition-colors"
        >
          로그인 API 테스트
        </button>
        
        <button 
          @click="runAllTests" 
          class="w-full px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600 transition-colors"
        >
          전체 테스트 실행
        </button>
      </div>

      <!-- Logs -->
      <div class="mt-6">
        <h3 class="text-sm font-medium mb-2">테스트 로그:</h3>
        <div class="bg-gray-100 p-3 rounded text-xs font-mono max-h-40 overflow-y-auto">
          <div v-for="log in logs" :key="log.id" class="mb-1">
            <span class="text-gray-500">{{ log.timestamp }}</span>
            <span :class="log.type === 'error' ? 'text-red-600' : 'text-green-600'">{{ log.message }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const testResults = ref({
  backend: false,
  login: false,
  timeout: true
})

const logs = ref<Array<{id: number, timestamp: string, message: string, type: 'success' | 'error'}>>([])
let logId = 0

const addLog = (message: string, type: 'success' | 'error' = 'success') => {
  logs.value.push({
    id: logId++,
    timestamp: new Date().toLocaleTimeString(),
    message,
    type
  })
}

const testBackendConnection = async () => {
  addLog('🔍 백엔드 연결 테스트 시작...')
  
  try {
    const startTime = Date.now()
    const response = await $fetch('/health', { timeout: 5000 })
    const endTime = Date.now()
    
    addLog(`✅ 백엔드 연결 성공 (${endTime - startTime}ms)`)
    testResults.value.backend = true
  } catch (error: any) {
    addLog(`❌ 백엔드 연결 실패: ${error.message}`, 'error')
    testResults.value.backend = false
  }
}

const testLoginAPI = async () => {
  addLog('🔍 로그인 API 테스트 시작...')
  
  try {
    const startTime = Date.now()
    const response = await $fetch('/api/auth/login', {
      method: 'POST',
      body: {
        email: 'devXcdy@gmail.com',
        password: 'dragon12'
      },
      timeout: 10000
    })
    const endTime = Date.now()
    
    addLog(`✅ 로그인 API 성공 (${endTime - startTime}ms)`)
    addLog(`📧 응답: ${JSON.stringify(response, null, 2)}`)
    testResults.value.login = true
    testResults.value.timeout = true
  } catch (error: any) {
    addLog(`❌ 로그인 API 실패: ${error.message}`, 'error')
    testResults.value.login = false
    
    if (error.message.includes('timeout') || error.message.includes('Timeout')) {
      testResults.value.timeout = false
      addLog('⏰ 타임아웃 발생!', 'error')
    }
  }
}

const runAllTests = async () => {
  addLog('🚀 전체 테스트 시작...')
  logs.value = []
  
  await testBackendConnection()
  await new Promise(resolve => setTimeout(resolve, 1000))
  await testLoginAPI()
  
  addLog('🏁 전체 테스트 완료!')
}
</script> 