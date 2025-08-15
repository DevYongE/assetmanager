<template>
  <div class="p-8">
    <h1 class="text-2xl font-bold mb-4">QR 생성 방식 선택 테스트</h1>
    
    <div class="space-y-4">
      <div class="p-4 bg-gray-100 rounded">
        <h2 class="font-semibold">현재 상태:</h2>
        <p>선택된 생성 방식: {{ generationMode }}</p>
        <p>QR 타입: {{ qrType }}</p>
        <p>선택된 장비: {{ selectedDevice ? selectedDevice.asset_number : '없음' }}</p>
      </div>
      
      <div class="p-4 bg-blue-100 rounded">
        <h2 class="font-semibold">테스트 방법:</h2>
        <ol class="list-decimal list-inside space-y-2">
          <li>QR 생성기 페이지로 이동</li>
          <li>생성 방식 선택 (단일/일괄/템플릿/사용자 정의)</li>
          <li>각 방식에 따른 설정 확인</li>
          <li>QR 생성 기능 테스트</li>
        </ol>
      </div>
      
      <div class="p-4 bg-green-100 rounded">
        <h2 class="font-semibold">테스트 링크:</h2>
        <div class="space-y-2">
          <a 
            href="/qr-generator" 
            class="block px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 text-center"
            target="_blank"
          >
            QR 생성기 페이지
          </a>
        </div>
      </div>
      
      <div class="p-4 bg-yellow-100 rounded">
        <h2 class="font-semibold">생성 방식별 기능:</h2>
        <div class="space-y-2">
          <div class="p-2 bg-white rounded">
            <h3 class="font-medium">1. 단일 QR 생성</h3>
            <p class="text-sm text-gray-600">- 개별 장비/직원 QR 코드 생성</p>
            <p class="text-sm text-gray-600">- QR 타입 선택 (장비/직원)</p>
            <p class="text-sm text-gray-600">- 장비 선택 및 QR 설정</p>
          </div>
          <div class="p-2 bg-white rounded">
            <h3 class="font-medium">2. 일괄 QR 생성</h3>
            <p class="text-sm text-gray-600">- 여러 장비/직원 QR 코드 일괄 생성</p>
            <p class="text-sm text-gray-600">- 생성 대상 선택 (전체/선택/필터)</p>
            <p class="text-sm text-gray-600">- 출력 형식 선택 (ZIP/PDF/개별)</p>
          </div>
          <div class="p-2 bg-white rounded">
            <h3 class="font-medium">3. 템플릿 기반 생성</h3>
            <p class="text-sm text-gray-600">- 사용자 정의 템플릿으로 QR 생성</p>
            <p class="text-sm text-gray-600">- 템플릿 선택 및 미리보기</p>
            <p class="text-sm text-gray-600">- 템플릿별 필드 설정</p>
          </div>
          <div class="p-2 bg-white rounded">
            <h3 class="font-medium">4. 사용자 정의 생성</h3>
            <p class="text-sm text-gray-600">- 직접 입력한 데이터로 QR 생성</p>
            <p class="text-sm text-gray-600">- JSON 형식 데이터 입력</p>
            <p class="text-sm text-gray-600">- 데이터 검증 및 생성</p>
          </div>
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
// 2025-01-27: QR 생성 방식 선택 테스트 페이지

const testResults = ref<string[]>([])

const addResult = (message: string) => {
  testResults.value.push(`[${new Date().toLocaleTimeString()}] ${message}`)
}

onMounted(() => {
  addResult('QR 생성 방식 선택 테스트 페이지가 로드되었습니다.')
  addResult('QR 생성기 페이지에서 다양한 생성 방식을 테스트해보세요.')
  addResult('각 생성 방식에 따른 UI와 기능이 올바르게 작동하는지 확인하세요.')
})
</script>
