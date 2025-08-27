<template>
  <div class="login-page">
    <!-- 배경 애니메이션 -->
    <div class="background-animation">
      <div class="floating-shapes">
        <div class="shape shape-1"></div>
        <div class="shape shape-2"></div>
        <div class="shape shape-3"></div>
        <div class="shape shape-4"></div>
        <div class="shape shape-5"></div>
      </div>
    </div>

    <!-- 메인 컨테이너 -->
    <div class="login-container">
      <!-- 로고 섹션 -->
      <div class="logo-section">
        <!-- 2025-01-27: InvenOne 로고로 변경 -->
        <div class="logo-icon">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 9h6v12H3z"/>
            <path d="M9 3h12v18H9z"/>
            <path d="M15 9h6"/>
            <path d="M15 15h6"/>
            <path d="M9 9h6"/>
            <path d="M9 15h6"/>
          </svg>
        </div>
        <h1 class="logo-title">
          <span class="gradient-text">InvenOne</span>
        </h1>
        <p class="logo-subtitle">스마트한 자산 관리 솔루션</p>
      </div>

      <!-- 로그인 폼 -->
      <div class="login-form-container">
        <div class="form-header">
          <h2 class="form-title">로그인</h2>
          <p class="form-subtitle">계정에 로그인하여 시작하세요</p>
        </div>

        <form @submit.prevent="handleLogin" class="login-form">
          <!-- 이메일 입력 -->
          <div class="input-group">
            <label class="input-label">이메일</label>
            <div class="input-wrapper">
              <div class="input-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                  <polyline points="22,6 12,13 2,6"/>
                </svg>
              </div>
              <input
                v-model="form.email"
                type="email"
                class="form-input"
                placeholder="이메일을 입력하세요"
                required
                :disabled="loading"
              />
            </div>
          </div>

          <!-- 비밀번호 입력 -->
          <div class="input-group">
            <label class="input-label">비밀번호</label>
            <div class="input-wrapper">
              <div class="input-icon">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                  <circle cx="12" cy="16" r="1"/>
                  <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
              </div>
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                class="form-input"
                placeholder="비밀번호를 입력하세요"
                required
                :disabled="loading"
              />
              <button
                type="button"
                class="password-toggle"
                @click="showPassword = !showPassword"
                :disabled="loading"
              >
                <svg v-if="showPassword" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                  <circle cx="12" cy="12" r="3"/>
                </svg>
                <svg v-else width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
                  <line x1="1" y1="1" x2="23" y2="23"/>
                </svg>
              </button>
            </div>
          </div>

          <!-- 에러 메시지 -->
          <div v-if="error" class="error-message">
            <div class="error-icon">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/>
                <line x1="15" y1="9" x2="9" y2="15"/>
                <line x1="9" y1="9" x2="15" y2="15"/>
              </svg>
            </div>
            <span>{{ error }}</span>
          </div>

          <!-- 로그인 버튼 -->
          <button
            type="submit"
            class="login-button"
            :disabled="loading || !form.email || !form.password"
          >
            <div v-if="loading" class="loading-spinner">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-dasharray="31.416" stroke-dashoffset="31.416">
                  <animate attributeName="stroke-dasharray" dur="2s" values="0 31.416;15.708 15.708;0 31.416" repeatCount="indefinite"/>
                  <animate attributeName="stroke-dashoffset" dur="2s" values="0;-15.708;-31.416" repeatCount="indefinite"/>
                </circle>
              </svg>
            </div>
            <span v-else>로그인</span>
          </button>
        </form>

        <!-- 구분선 -->
        <div class="divider">
          <span class="divider-text">또는</span>
        </div>

        <!-- 회원가입 링크 -->
        <div class="signup-section">
          <p class="signup-text">
            계정이 없으신가요?
            <NuxtLink to="/register" class="signup-link">회원가입</NuxtLink>
          </p>
        </div>
      </div>

      
    </div>
  </div>
</template>

<script setup lang="ts">
// 2024-12-19: 트렌디한 UI 디자인으로 로그인 페이지 완전 재설계

import { ref, reactive } from 'vue'

// 페이지 메타
definePageMeta({
  layout: 'simple'
})

// 상태 관리
const loading = ref(false)
const error = ref('')
const showPassword = ref(false)

const form = reactive({
  email: '',
  password: ''
})

// 2025-01-27: QR 링크 리다이렉트를 위한 저장된 URL 확인
const getRedirectUrl = () => {
  if (process.client) {
    const savedUrl = sessionStorage.getItem('redirect_after_login')
    if (savedUrl) {
      sessionStorage.removeItem('redirect_after_login')
      return savedUrl
    }
  }
  return '/dashboard'
}

// 로그인 처리
const handleLogin = async () => {
  if (!form.email || !form.password) return

  loading.value = true
  error.value = ''

  try {
    const authStore = useAuthStore()
    // 2024-12-19: LoginCredentials 객체 형태로 수정 - TypeError 해결
    await authStore.login({
      email: form.email,
      password: form.password
    })
    
    // 2025-01-27: 저장된 URL로 리다이렉트 (QR 링크 우선)
    const redirectUrl = getRedirectUrl()
    console.log('🔐 [LOGIN] Redirecting to:', redirectUrl)
    
    // QR 페이지로 리다이렉트하는 경우 플래그 설정
    if (redirectUrl.includes('/qr-') || redirectUrl.includes('/devices/') || redirectUrl.includes('/employees/')) {
      if (process.client) {
        sessionStorage.setItem('redirected_from_login', 'true')
      }
    }
    
    await navigateTo(redirectUrl)
  } catch (err: any) {
    console.error('로그인 실패:', err)
    error.value = err.message || '로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 트렌디한 로그인 페이지 스타일 */
.login-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  position: relative;
  overflow: hidden;
}

/* 배경 애니메이션 */
.background-animation {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.floating-shapes {
  position: relative;
  width: 100%;
  height: 100%;
}

.shape {
  position: absolute;
  border-radius: 50%;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  animation: float 6s ease-in-out infinite;
}

.shape-1 {
  width: 80px;
  height: 80px;
  top: 10%;
  left: 10%;
  animation-delay: 0s;
}

.shape-2 {
  width: 120px;
  height: 120px;
  top: 20%;
  right: 15%;
  animation-delay: 1s;
}

.shape-3 {
  width: 60px;
  height: 60px;
  bottom: 20%;
  left: 20%;
  animation-delay: 2s;
}

.shape-4 {
  width: 100px;
  height: 100px;
  bottom: 10%;
  right: 10%;
  animation-delay: 3s;
}

.shape-5 {
  width: 40px;
  height: 40px;
  top: 50%;
  left: 50%;
  animation-delay: 4s;
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(180deg); }
}

/* 메인 컨테이너 */
.login-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  max-width: 1200px;
  width: 100%;
  position: relative;
  z-index: 1;
}

/* 로고 섹션 */
.logo-section {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 90px;
  height: 90px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 28px;
  margin-bottom: 2rem;
  color: white;
  box-shadow: 0 20px 25px -5px rgba(102, 126, 234, 0.3);
  animation: pulse-glow 2s ease-in-out infinite;
  position: relative;
  overflow: hidden;
}

.logo-icon::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  animation: shimmer 3s ease-in-out infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
  100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
}

@keyframes pulse-glow {
  0%, 100% { box-shadow: 0 20px 25px -5px rgba(102, 126, 234, 0.3); }
  50% { box-shadow: 0 20px 25px -5px rgba(102, 126, 234, 0.3), 0 0 30px rgba(102, 126, 234, 0.5); }
}

.logo-title {
  font-size: 3.5rem;
  font-weight: 900;
  margin-bottom: 1rem;
  line-height: 1.1;
  letter-spacing: -0.02em;
}

.logo-subtitle {
  font-size: 1.125rem;
  color: #64748b;
  line-height: 1.6;
}

/* 2025-01-27: InvenOne 로고 그라데이션 스타일 */
.gradient-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  background-size: 200% 200%;
  animation: gradient-shift 3s ease-in-out infinite;
}

@keyframes gradient-shift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

/* 로그인 폼 컨테이너 */
.login-form-container {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 24px;
  padding: 3rem;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
}

.form-header {
  text-align: center;
  margin-bottom: 2rem;
}

.form-title {
  font-size: 2rem;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 0.5rem;
}

.form-subtitle {
  color: #64748b;
  font-size: 1rem;
}

/* 로그인 폼 */
.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.input-label {
  font-weight: 600;
  color: #1e293b;
  font-size: 0.875rem;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  z-index: 10;
}

.form-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  font-size: 1rem;
  transition: all 0.3s ease;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
}

.form-input:focus {
  outline: none;
  border-color: #a855f7;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
  transform: translateY(-1px);
}

.form-input::placeholder {
  color: #94a3b8;
}

.form-input:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.password-toggle {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #64748b;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: 4px;
  transition: all 0.3s ease;
}

.password-toggle:hover {
  color: #a855f7;
  background: rgba(139, 92, 246, 0.1);
}

.password-toggle:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 에러 메시지 */
.error-message {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 12px;
  color: #dc2626;
  font-size: 0.875rem;
}

.error-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  background: #dc2626;
  border-radius: 50%;
  color: white;
  flex-shrink: 0;
}

/* 로그인 버튼 */
.login-button {
  width: 100%;
  padding: 1rem 2rem;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border: none;
  border-radius: 12px;
  color: white;
  font-weight: 600;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.login-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s ease;
}

.login-button:hover::before {
  left: 100%;
}

.login-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.login-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.login-button:disabled::before {
  display: none;
}

.loading-spinner {
  display: flex;
  align-items: center;
  justify-content: center;
}

.loading-spinner svg {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* 구분선 */
.divider {
  position: relative;
  text-align: center;
  margin: 2rem 0;
}

.divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1px;
  background: #e2e8f0;
}

.divider-text {
  background: rgba(255, 255, 255, 0.8);
  padding: 0 1rem;
  color: #64748b;
  font-size: 0.875rem;
  position: relative;
  z-index: 1;
}

/* 회원가입 섹션 */
.signup-section {
  text-align: center;
}

.signup-text {
  color: #64748b;
  font-size: 0.875rem;
}

.signup-link {
  color: #a855f7;
  text-decoration: none;
  font-weight: 600;
  transition: all 0.3s ease;
}

.signup-link:hover {
  color: #7c3aed;
  text-decoration: underline;
}



/* 반응형 */
@media (max-width: 1024px) {
  .login-container {
    grid-template-columns: 1fr;
    gap: 2rem;
    max-width: 500px;
  }
  
  .logo-section {
    order: 2;
  }
  
  .login-form-container {
    order: 1;
  }
  

}

@media (max-width: 768px) {
  .login-page {
    padding: 1rem;
  }
  
  .login-form-container {
    padding: 2rem;
  }
  
  .logo-title {
    font-size: 2rem;
  }
  
  .form-title {
    font-size: 1.5rem;
  }
  

}

@media (max-width: 480px) {
  .login-form-container {
    padding: 1.5rem;
  }
  
  .logo-icon {
    width: 60px;
    height: 60px;
  }
  
  .logo-title {
    font-size: 1.75rem;
  }
}
</style> 