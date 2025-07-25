<template>
  <div class="p-6">
    <h1 class="text-3xl font-bold text-red-600 mb-4">레이아웃 테스트 페이지</h1>
    <p class="text-lg text-gray-700 mb-4">이 페이지가 보인다면 레이아웃이 정상적으로 작동하고 있습니다.</p>
    
    <div class="bg-blue-100 p-4 rounded-lg">
      <h2 class="text-xl font-semibold text-blue-800 mb-2">확인 사항:</h2>
      <ul class="list-disc list-inside text-blue-700 space-y-1">
        <li>왼쪽에 사이드바가 보이나요?</li>
        <li>상단에 헤더가 보이나요?</li>
        <li>이 콘텐츠가 사이드바 옆에 표시되나요?</li>
        <li>햄버거 메뉴로 사이드바를 접을 수 있나요?</li>
      </ul>
    </div>
    
    <div class="mt-6 bg-green-100 p-4 rounded-lg">
      <h2 class="text-xl font-semibold text-green-800 mb-2">현재 상태:</h2>
      <p class="text-green-700">페이지 제목: {{ getPageTitle() }}</p>
      <p class="text-green-700">현재 경로: {{ $route.path }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const route = useRoute()

const getPageTitle = () => {
  return '레이아웃 테스트'
}
</script> 