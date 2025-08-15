<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-4">브라우저 종료 감지 테스트</h1>
    
    <div class="space-y-4">
      <div class="p-4 bg-gray-100 rounded">
        <h2 class="font-semibold">현재 상태:</h2>
        <p>인증됨: {{ authStore.isAuthenticated ? '예' : '아니오' }}</p>
        <p>세션 스토리지 토큰: {{ sessionStorage.getItem('auth_token') ? '존재' : '없음' }}</p>
        <p>로컬 스토리지 토큰: {{ localStorage.getItem('auth_token') ? '존재' : '없음' }}</p>
      </div>
      
      <div class="p-4 bg-blue-100 rounded">
        <h2 class="font-semibold">테스트 방법:</h2>
        <ol class="list-decimal list-inside space-y-2">
          <li>로그인 후 이 페이지로 이동</li>
          <li>브라우저 탭을 닫거나 브라우저를 완전히 종료</li>
          <li>브라우저를 다시 열고 이 페이지로 이동</li>
          <li>세션 스토리지가 비워져서 자동 로그아웃되는지 확인</li>
        </ol>
      </div>
      
      <div class="p-4 bg-green-100 rounded">
        <h2 class="font-semibold">이벤트 로그:</h2>
        <div class="bg-white p-2 rounded border max-h-40 overflow-y-auto">
          <div v-for="(log, index) in eventLogs" :key="index" class="text-sm">
            {{ log }}
          </div>
        </div>
      </div>
      
      <div class="p-4 bg-yellow-100 rounded">
        <h2 class="font-semibold">수동 테스트:</h2>
        <div class="space-y-2">
          <button 
            @click="simulateLogin" 
            class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
          >
            로그인 시뮬레이션
          </button>
          <button 
            @click="simulateLogout" 
            class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
          >
            로그아웃 시뮬레이션
          </button>
          <button 
            @click="clearSessionStorage" 
            class="px-4 py-2 bg-orange-500 text-white rounded hover:bg-orange-600"
          >
            세션 스토리지만 삭제
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2025-01-27: 브라우저 종료 감지 테스트 페이지

const authStore = useAuthStore()
const eventLogs = ref<string[]>([])

const addLog = (message: string) => {
  const timestamp = new Date().toLocaleTimeString()
  eventLogs.value.push(`[${timestamp}] ${message}`)
}

const simulateLogin = () => {
  addLog('로그인 시뮬레이션 시작...')
  
  // 가짜 인증 데이터 생성
  const fakeToken = 'fake_token_' + Date.now()
  const fakeUser = {
    id: 1,
    email: 'test@example.com',
    company_name: '테스트 회사'
  }
  
  // 세션 스토리지와 로컬 스토리지에 저장
  sessionStorage.setItem('auth_token', fakeToken)
  sessionStorage.setItem('auth_user', JSON.stringify(fakeUser))
  localStorage.setItem('auth_token', fakeToken)
  localStorage.setItem('auth_user', JSON.stringify(fakeUser))
  
  addLog('가짜 인증 데이터가 저장되었습니다.')
  addLog('이제 브라우저를 닫고 다시 열어보세요.')
}

const simulateLogout = () => {
  addLog('로그아웃 시뮬레이션 시작...')
  
  // 모든 스토리지 정리
  sessionStorage.removeItem('auth_token')
  sessionStorage.removeItem('auth_user')
  localStorage.removeItem('auth_token')
  localStorage.removeItem('auth_user')
  localStorage.removeItem('last_activity')
  
  addLog('모든 인증 데이터가 삭제되었습니다.')
}

const clearSessionStorage = () => {
  addLog('세션 스토리지만 삭제...')
  
  sessionStorage.removeItem('auth_token')
  sessionStorage.removeItem('auth_user')
  
  addLog('세션 스토리지가 삭제되었습니다.')
  addLog('localStorage는 그대로 유지됩니다.')
}

// 페이지 로드 시 이벤트 리스너 추가
onMounted(() => {
  addLog('테스트 페이지가 로드되었습니다.')
  addLog(`현재 인증 상태: ${authStore.isAuthenticated ? '인증됨' : '인증 안됨'}`)
  
  // 브라우저 종료 이벤트 감지
  const handleBeforeUnload = () => {
    addLog('beforeunload 이벤트 발생 (브라우저 종료 감지)')
  }
  
  const handlePageHide = () => {
    addLog('pagehide 이벤트 발생 (페이지 숨김)')
  }
  
  const handleVisibilityChange = () => {
    if (document.visibilityState === 'hidden') {
      addLog('visibilitychange 이벤트 발생 (페이지 숨김)')
    } else {
      addLog('visibilitychange 이벤트 발생 (페이지 표시)')
    }
  }
  
  window.addEventListener('beforeunload', handleBeforeUnload)
  window.addEventListener('pagehide', handlePageHide)
  document.addEventListener('visibilitychange', handleVisibilityChange)
  
  addLog('브라우저 종료 감지 이벤트 리스너가 등록되었습니다.')
  
  // 컴포넌트 언마운트 시 이벤트 리스너 정리
  onUnmounted(() => {
    window.removeEventListener('beforeunload', handleBeforeUnload)
    window.removeEventListener('pagehide', handlePageHide)
    document.removeEventListener('visibilitychange', handleVisibilityChange)
  })
})
</script>
