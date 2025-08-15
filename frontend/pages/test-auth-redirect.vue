<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-4">인증 리다이렉트 테스트</h1>
    
    <div class="space-y-4">
      <div class="p-4 bg-gray-100 rounded">
        <h2 class="font-semibold">현재 인증 상태:</h2>
        <p>인증됨: {{ authStore.isAuthenticated ? '예' : '아니오' }}</p>
        <p>토큰: {{ authStore.token ? '존재' : '없음' }}</p>
        <p>사용자: {{ authStore.user ? authStore.user.email : '없음' }}</p>
      </div>
      
             <div class="p-4 bg-blue-100 rounded">
         <h2 class="font-semibold">테스트 액션:</h2>
         <div class="space-y-2">
           <button 
             @click="testIndexRedirect" 
             class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
           >
             메인 페이지 리다이렉트 테스트
           </button>
           <button 
             @click="testDashboardAccess" 
             class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
           >
             대시보드 접근 테스트
           </button>
           <button 
             @click="clearAuth" 
             class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
           >
             인증 정보 초기화
           </button>
           <button 
             @click="testBrowserClose" 
             class="px-4 py-2 bg-purple-500 text-white rounded hover:bg-purple-600"
           >
             브라우저 종료 감지 테스트
           </button>
         </div>
       </div>
      
      <div class="p-4 bg-yellow-100 rounded">
        <h2 class="font-semibold">테스트 결과:</h2>
        <pre class="text-sm">{{ testResults }}</pre>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2025-01-27: 인증 리다이렉트 테스트 페이지

const authStore = useAuthStore()
const router = useRouter()
const testResults = ref<string[]>([])

const addResult = (message: string) => {
  testResults.value.push(`[${new Date().toLocaleTimeString()}] ${message}`)
}

const testIndexRedirect = () => {
  addResult('메인 페이지 리다이렉트 테스트 시작...')
  
  // 현재 인증 상태 확인
  addResult(`현재 인증 상태: ${authStore.isAuthenticated ? '인증됨' : '인증 안됨'}`)
  
  // 리다이렉트 로직 시뮬레이션
  if (authStore.isAuthenticated) {
    addResult('인증된 사용자: /dashboard로 리다이렉트 예정')
    router.push('/dashboard')
  } else {
    addResult('인증되지 않은 사용자: /login으로 리다이렉트 예정')
    router.push('/login')
  }
}

const testDashboardAccess = () => {
  addResult('대시보드 접근 테스트 시작...')
  
  if (authStore.isAuthenticated) {
    addResult('인증된 사용자: 대시보드 접근 가능')
    router.push('/dashboard')
  } else {
    addResult('인증되지 않은 사용자: 로그인 페이지로 리다이렉트 예정')
    router.push('/login')
  }
}

const clearAuth = () => {
  addResult('인증 정보 초기화...')
  authStore.logout()
  addResult('인증 정보가 초기화되었습니다.')
}

const testBrowserClose = () => {
  addResult('브라우저 종료 감지 테스트 시작...')
  addResult('현재 세션 스토리지 상태:')
  addResult(`- auth_token: ${sessionStorage.getItem('auth_token') ? '존재' : '없음'}`)
  addResult(`- auth_user: ${sessionStorage.getItem('auth_user') ? '존재' : '없음'}`)
  addResult('localStorage 상태:')
  addResult(`- auth_token: ${localStorage.getItem('auth_token') ? '존재' : '없음'}`)
  addResult(`- auth_user: ${localStorage.getItem('auth_user') ? '존재' : '없음'}`)
  addResult('브라우저를 닫고 다시 열면 세션 스토리지가 비워집니다.')
}

onMounted(() => {
  addResult('테스트 페이지가 로드되었습니다.')
  addResult(`초기 인증 상태: ${authStore.isAuthenticated ? '인증됨' : '인증 안됨'}`)
})
</script>
