<template>
  <div class="profile-container">
    <!-- 헤더 섹션 -->
    <div class="page-header animate-fade-in-up">
      <div class="header-content">
        <div class="header-info">
          <h1 class="page-title">프로필 설정</h1>
          <p class="page-subtitle">계정 정보를 관리하고 설정을 변경하세요</p>
        </div>
        <div class="profile-avatar">
          <div class="avatar-circle">
            <span class="avatar-text">{{ user?.email?.charAt(0).toUpperCase() || 'U' }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="main-content animate-fade-in-up" style="animation-delay: 0.1s;">
      <div class="content-grid">
        <!-- 기본 정보 섹션 -->
        <div class="info-section">
          <div class="section-card">
            <div class="section-header">
              <div class="section-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M20 21V19C20 17.9391 19.5786 16.9217 18.8284 16.1716C18.0783 15.4214 17.0609 15 16 15H8C6.93913 15 5.92172 15.4214 5.17157 16.1716C4.42143 16.9217 4 17.9391 4 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M12 11C14.2091 11 16 9.20914 16 7C16 4.79086 14.2091 3 12 3C9.79086 3 8 4.79086 8 7C8 9.20914 9.79086 11 12 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
              <h2 class="section-title">기본 정보</h2>
            </div>
            
            <form @submit.prevent="updateProfile" class="profile-form">
              <div class="form-group">
                <label class="form-label">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M4 4H20C21.1 4 22 4.9 22 6V18C22 19.1 21.1 20 20 20H4C2.9 20 2 19.1 2 18V6C2 4.9 2.9 4 4 4Z" stroke="currentColor" stroke-width="2"/>
                    <polyline points="22,6 12,13 2,6" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  이메일 주소
                </label>
                <input
                  v-model="profileForm.email"
                  type="email"
                  class="input-modern bg-gray-50"
                  readonly
                />
                <p class="input-hint">이메일 주소는 변경할 수 없습니다</p>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M3 9L12 2L21 9V20C21 20.5304 20.7893 21.0391 20.4142 21.4142C20.0391 21.7893 19.5304 22 19 22H5C4.46957 22 3.96086 21.7893 3.58579 21.4142C3.21071 21.0391 3 20.5304 3 20V9Z" stroke="currentColor" stroke-width="2"/>
                    <polyline points="9,22 9,12 15,12 15,22" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  회사명
                </label>
                <input
                  v-model="profileForm.company_name"
                  type="text"
                  required
                  class="input-modern"
                  placeholder="회사명을 입력하세요"
                />
              </div>
              
              <div class="form-actions">
                <button 
                  type="submit"
                  :disabled="profileLoading"
                  class="btn-gradient save-btn"
                >
                  <span v-if="!profileLoading" class="btn-content">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M19 21H5C3.89543 21 3 20.1046 3 19V5C3 3.89543 3.89543 3 5 3H16L21 8V19C21 20.1046 20.1046 21 19 21Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      <polyline points="17,21 17,13 7,13 7,21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      <polyline points="7,3 7,8 15,8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    저장
                  </span>
                  <span v-else class="btn-content">
                    <div class="loading-spinner"></div>
                    저장 중...
                  </span>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- 비밀번호 변경 섹션 -->
        <div class="password-section">
          <div class="section-card">
            <div class="section-header">
              <div class="section-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                  <circle cx="12" cy="16" r="1" stroke="currentColor" stroke-width="2"/>
                  <path d="M7 11V7C7 5.9 7.9 5 9 5H15C16.1 5 17 5.9 17 7V11" stroke="currentColor" stroke-width="2"/>
                </svg>
              </div>
              <h2 class="section-title">비밀번호 변경</h2>
            </div>
            
            <form @submit.prevent="changePassword" class="password-form">
              <div class="form-group">
                <label class="form-label">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" stroke="currentColor" stroke-width="2"/>
                    <circle cx="12" cy="16" r="1" stroke="currentColor" stroke-width="2"/>
                    <path d="M7 11V7C7 5.9 7.9 5 9 5H15C16.1 5 17 5.9 17 7V11" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  현재 비밀번호
                </label>
                <input
                  v-model="passwordForm.current_password"
                  type="password"
                  required
                  class="input-modern"
                  placeholder="현재 비밀번호를 입력하세요"
                />
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  새 비밀번호
                </label>
                <input
                  v-model="passwordForm.new_password"
                  type="password"
                  required
                  class="input-modern"
                  placeholder="새 비밀번호를 입력하세요"
                />
                <p class="input-hint">최소 6자 이상 입력해주세요</p>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M9 12L11 14L15 10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  새 비밀번호 확인
                </label>
                <input
                  v-model="passwordForm.confirm_password"
                  type="password"
                  required
                  class="input-modern"
                  :class="{ 'error': passwordForm.new_password !== passwordForm.confirm_password && passwordForm.confirm_password }"
                  placeholder="새 비밀번호를 다시 입력하세요"
                />
                <div v-if="passwordForm.new_password !== passwordForm.confirm_password && passwordForm.confirm_password" class="error-message">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                    <line x1="15" y1="9" x2="9" y2="15" stroke="currentColor" stroke-width="2"/>
                    <line x1="9" y1="9" x2="15" y2="15" stroke="currentColor" stroke-width="2"/>
                  </svg>
                  비밀번호가 일치하지 않습니다
                </div>
              </div>
              
              <div class="form-actions">
                <button 
                  type="submit"
                  :disabled="passwordLoading || !isPasswordValid"
                  class="btn-gradient change-btn"
                >
                  <span v-if="!passwordLoading" class="btn-content">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    비밀번호 변경
                  </span>
                  <span v-else class="btn-content">
                    <div class="loading-spinner"></div>
                    변경 중...
                  </span>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- 계정 정보 섹션 -->
        <div class="account-section">
          <div class="section-card">
            <div class="section-header">
              <div class="section-icon">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 2L2 7L12 12L22 7L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M2 17L12 22L22 17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M2 12L12 17L22 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </div>
              <h2 class="section-title">계정 정보</h2>
            </div>
            
            <div class="account-info">
              <div class="info-item">
                <span class="info-label">회사명</span>
                <span class="info-value company-name">{{ user?.company_name || '정보 없음' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">가입일</span>
                <span class="info-value">{{ formatDate(user?.created_at) }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">마지막 로그인</span>
                <span class="info-value">{{ user && 'last_login' in user ? formatDate((user as any).last_login) : '정보 없음' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">계정 상태</span>
                <span class="status-badge active">활성</span>
              </div>
            </div>
            
            <div class="account-actions">
              <button @click="logout" class="btn-secondary logout-btn">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M9 21H5C4.46957 21 3.96086 20.7893 3.58579 20.4142C3.21071 20.0391 3 19.5304 3 19V5C3 4.46957 3.21071 3.96086 3.58579 3.58579C3.96086 3.21071 4.46957 3 5 3H9" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <polyline points="16,17 21,12 16,7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <line x1="21" y1="12" x2="9" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                로그아웃
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

// 2025-01-27: 배포 환경에서 useAuthStore 오류 해결을 위해 명시적 import 추가
import { useAuthStore } from '~/stores/auth'

const authStore = useAuthStore()
const user = computed(() => authStore.user)

// Form data
const profileForm = reactive({
  email: user.value?.email || '',
  company_name: user.value?.company_name || ''
})

const passwordForm = reactive({
  current_password: '',
  new_password: '',
  confirm_password: ''
})

// Loading states
const profileLoading = ref(false)
const passwordLoading = ref(false)

// Computed properties
const isPasswordValid = computed(() => {
  return passwordForm.new_password.length >= 6 && 
         passwordForm.new_password === passwordForm.confirm_password
})

// Methods
const formatDate = (dateString?: string) => {
  if (!dateString) return '정보 없음'
  return new Date(dateString).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const updateProfile = async () => {
  try {
    profileLoading.value = true
    await authStore.updateProfile(profileForm)
    alert('프로필이 성공적으로 업데이트되었습니다')
  } catch (err: any) {
    console.error('Failed to update profile:', err)
    alert('프로필 업데이트에 실패했습니다')
  } finally {
    profileLoading.value = false
  }
}

const changePassword = async () => {
  if (!isPasswordValid.value) {
    alert('비밀번호를 올바르게 입력해주세요')
    return
  }

  try {
    passwordLoading.value = true
    // 비밀번호 변경 로직은 백엔드에서 구현 필요
    console.log('Password change requested')
    alert('비밀번호 변경 기능은 준비 중입니다')
    
    // Reset password form
    passwordForm.current_password = ''
    passwordForm.new_password = ''
    passwordForm.confirm_password = ''
  } catch (err: any) {
    console.error('Failed to change password:', err)
    alert('비밀번호 변경에 실패했습니다')
  } finally {
    passwordLoading.value = false
  }
}

const logout = async () => {
  if (confirm('정말 로그아웃하시겠습니까?')) {
    await authStore.logout()
    await navigateTo('/login')
  }
}

// Watch for user changes
watch(user, (newUser) => {
  if (newUser) {
    profileForm.email = newUser.email
    profileForm.company_name = newUser.company_name
  }
}, { immediate: true })
</script>

<style scoped>
.profile-container {
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.page-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 32px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.page-title {
  font-size: 32px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  color: #6b7280;
  font-size: 16px;
  font-weight: 500;
}

.profile-avatar {
  display: flex;
  align-items: center;
}

.avatar-circle {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
}

.main-content {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.content-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 32px;
}

.section-card {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 32px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.section-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 32px;
}

.section-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.section-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
}

.profile-form, .password-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #374151;
  font-size: 14px;
}

.form-label svg {
  color: #667eea;
}

.input-modern {
  background: rgba(255, 255, 255, 0.8);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 16px;
  padding: 16px 20px;
  font-size: 16px;
  transition: all 0.3s ease;
  color: #1f2937;
}

.input-modern:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  transform: translateY(-2px);
}

.input-modern.error {
  border-color: #ef4444;
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.input-modern::placeholder {
  color: #9ca3af;
}

.input-hint {
  color: #6b7280;
  font-size: 12px;
  margin-top: 4px;
}

.error-message {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
  border: 1px solid #fecaca;
  border-radius: 8px;
  color: #dc2626;
  font-size: 12px;
  font-weight: 500;
  margin-top: 4px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

.save-btn, .change-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
}

.btn-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.account-info {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 24px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.5);
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.info-label {
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
}

.info-value {
  color: #1f2937;
  font-size: 14px;
  font-weight: 600;
}

.company-name {
  color: #667eea;
  font-weight: 700;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 11px;
  font-weight: 600;
}

.status-badge.active {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.account-actions {
  display: flex;
  justify-content: center;
}

.logout-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: rgba(239, 68, 68, 0.1);
  border-color: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

.logout-btn:hover {
  background: rgba(239, 68, 68, 0.2);
  border-color: #ef4444;
}

/* 반응형 디자인 */
@media (max-width: 768px) {
  .profile-container {
    padding: 16px;
  }
  
  .header-content {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .page-title {
    font-size: 24px;
  }
  
  .section-card {
    padding: 24px;
  }
  
  .section-header {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }
  
  .info-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }
}
</style> 