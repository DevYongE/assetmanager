<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-4">QR 링크 리다이렉트 테스트</h1>
    
    <div class="space-y-4">
      <div class="p-4 bg-gray-100 rounded">
        <h2 class="font-semibold">현재 상태:</h2>
        <p>인증됨: {{ authStore.isAuthenticated ? '예' : '아니오' }}</p>
        <p>저장된 리다이렉트 URL: {{ savedRedirectUrl || '없음' }}</p>
        <p>리다이렉트 플래그: {{ redirectedFlag ? '설정됨' : '없음' }}</p>
      </div>
      
      <div class="p-4 bg-blue-100 rounded">
        <h2 class="font-semibold">테스트 방법:</h2>
        <ol class="list-decimal list-inside space-y-2">
          <li>로그아웃 상태에서 QR 링크 접속</li>
          <li>로그인 페이지로 리다이렉트됨</li>
          <li>로그인 성공 후 원래 QR 링크로 자동 이동</li>
          <li>QR 페이지에서 "로그인 후 자동 이동됨" 표시 확인</li>
        </ol>
      </div>
      
      <div class="p-4 bg-green-100 rounded">
        <h2 class="font-semibold">테스트 링크:</h2>
        <div class="space-y-2">
          <a 
            href="/qr-scanner" 
            class="block px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 text-center"
            target="_blank"
          >
            QR 스캐너 페이지
          </a>
          <a 
            href="/qr-generator" 
            class="block px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 text-center"
            target="_blank"
          >
            QR 생성기 페이지
          </a>
          <a 
            href="/devices" 
            class="block px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600 text-center"
            target="_blank"
          >
            장비 관리 페이지
          </a>
        </div>
      </div>
      
      <div class="p-4 bg-yellow-100 rounded">
        <h2 class="font-semibold">수동 테스트:</h2>
        <div class="space-y-2">
          <button 
            @click="simulateQRRedirect" 
            class="px-4 py-2 bg-orange-500 text-white rounded hover:bg-orange-600"
          >
            QR 리다이렉트 시뮬레이션
          </button>
          <button 
            @click="clearRedirectData" 
            class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
          >
            리다이렉트 데이터 초기화
          </button>
          <button 
            @click="logout" 
            class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600"
          >
            로그아웃
          </button>
        </div>
      </div>
      
      <div class="p-4 bg-purple-100 rounded">
        <h2 class="font-semibold">테스트 결과:</h2>
        <pre class="text-sm bg-white p-2 rounded border">{{ testResults }}</pre>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2025-01-27: QR 링크 리다이렉트 테스트 페이지

const authStore = useAuthStore()
const testResults = ref<string[]>([])

const savedRedirectUrl = computed(() => {
  if (process.client) {
    return sessionStorage.getItem('redirect_after_login')
  }
  return null
})

const redirectedFlag = computed(() => {
  if (process.client) {
    return sessionStorage.getItem('redirected_from_login') === 'true'
  }
  return false
})

const addResult = (message: string) => {
  testResults.value.push(`[${new Date().toLocaleTimeString()}] ${message}`)
}

const simulateQRRedirect = () => {
  addResult('QR 리다이렉트 시뮬레이션 시작...')
  
  if (process.client) {
    // QR 스캐너 URL 저장
    sessionStorage.setItem('redirect_after_login', '/qr-scanner')
    addResult('리다이렉트 URL 저장: /qr-scanner')
    
    // 로그아웃 상태로 시뮬레이션
    addResult('로그아웃 상태로 시뮬레이션...')
    addResult('이제 로그인 페이지로 이동하면 됩니다.')
  }
}

const clearRedirectData = () => {
  addResult('리다이렉트 데이터 초기화...')
  
  if (process.client) {
    sessionStorage.removeItem('redirect_after_login')
    sessionStorage.removeItem('redirected_from_login')
    addResult('모든 리다이렉트 데이터가 삭제되었습니다.')
  }
}

const logout = () => {
  addResult('로그아웃 실행...')
  authStore.logout()
  addResult('로그아웃 완료')
}

onMounted(() => {
  addResult('QR 리다이렉트 테스트 페이지가 로드되었습니다.')
  addResult(`현재 인증 상태: ${authStore.isAuthenticated ? '인증됨' : '인증 안됨'}`)
  addResult(`저장된 리다이렉트 URL: ${savedRedirectUrl.value || '없음'}`)
  addResult(`리다이렉트 플래그: ${redirectedFlag.value ? '설정됨' : '없음'}`)
})
</script>
