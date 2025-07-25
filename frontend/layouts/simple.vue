<template>
  <div>
    <!-- 강제 사이드바 -->
    <div style="position: fixed; left: 0; top: 0; width: 250px; height: 100vh; background: red; color: white; z-index: 9999; padding: 20px;">
      <h2>사이드바 (Simple Layout)</h2>
      <p>이것이 보인다면 레이아웃이 작동합니다.</p>
    </div>
    
    <!-- 강제 헤더 -->
    <div style="position: fixed; top: 0; left: 250px; right: 0; height: 60px; background: orange; color: white; z-index: 9999; padding: 20px;">
      <h2>헤더 (Simple Layout)</h2>
    </div>
    
    <!-- 메인 콘텐츠 -->
    <div style="margin-left: 250px; margin-top: 60px; padding: 20px;">
      <slot />
    </div>
  </div>
</template> 