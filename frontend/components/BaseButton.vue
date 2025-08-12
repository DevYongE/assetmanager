<template>
  <button
    :class="buttonClasses"
    :disabled="disabled || loading"
    :type="type"
    @click="$emit('click', $event)"
  >
    <!-- 로딩 스피너 -->
    <div v-if="loading" class="loading-spinner">
      <svg class="animate-spin" width="16" height="16" viewBox="0 0 24 24" fill="none">
        <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-dasharray="31.416" stroke-dashoffset="31.416">
          <animate attributeName="stroke-dasharray" dur="2s" values="0 31.416;15.708 15.708;0 31.416" repeatCount="indefinite"/>
          <animate attributeName="stroke-dashoffset" dur="2s" values="0;-15.708;-31.416" repeatCount="indefinite"/>
        </circle>
      </svg>
    </div>
    
    <!-- 아이콘 -->
    <svg
      v-else-if="icon"
      class="button-icon"
      width="16"
      height="16"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path :d="icon" />
    </svg>
    
    <!-- 텍스트 -->
    <span v-if="label || $slots.default" class="button-text">
      <slot>{{ loading ? loadingText : label }}</slot>
    </span>
  </button>
</template>

<script setup lang="ts">
// 2024-12-19: 트렌디한 UI 디자인으로 BaseButton 컴포넌트 완전 재설계

interface Props {
  label?: string
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'ghost' | 'accent'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  loadingText?: string
  disabled?: boolean
  icon?: string
  type?: 'button' | 'submit' | 'reset'
  fullWidth?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  loading: false,
  loadingText: '로딩 중...',
  disabled: false,
  type: 'button',
  fullWidth: false
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const buttonClasses = computed(() => {
  const baseClasses = [
    'btn-modern',
    `btn-${props.variant}`,
    `btn-${props.size}`,
    'relative',
    'overflow-hidden',
    'transition-all',
    'duration-300',
    'ease-out',
    'transform',
    'hover:scale-105',
    'active:scale-95',
    'focus:outline-none',
    'focus:ring-4',
    'focus:ring-opacity-20',
    'disabled:opacity-50',
    'disabled:cursor-not-allowed',
    'disabled:transform-none',
    'disabled:hover:transform-none'
  ]

  // 풀위드 클래스
  if (props.fullWidth) {
    baseClasses.push('w-full')
  }

  // 변형별 포커스 링 색상
  const focusRingColors = {
    primary: 'focus:ring-blue-500',
    secondary: 'focus:ring-gray-500',
    success: 'focus:ring-green-500',
    danger: 'focus:ring-red-500',
    warning: 'focus:ring-yellow-500',
    ghost: 'focus:ring-purple-500',
    accent: 'focus:ring-purple-500'
  }

  baseClasses.push(focusRingColors[props.variant])

  return baseClasses.join(' ')
})
</script>

<style scoped>
/* 트렌디한 버튼 스타일링 */
.btn-modern {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-weight: 600;
  font-size: 0.875rem;
  line-height: 1.25rem;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

/* 버튼 크기 */
.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.75rem;
  border-radius: 8px;
}

.btn-md {
  padding: 0.75rem 1.5rem;
  font-size: 0.875rem;
  border-radius: 12px;
}

.btn-lg {
  padding: 1rem 2rem;
  font-size: 1rem;
  border-radius: 16px;
}

/* 버튼 변형 */
.btn-primary {
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
}

.btn-primary:hover {
  background: linear-gradient(135deg, #334155 0%, #0f172a 100%);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.btn-accent {
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
}

.btn-accent:hover {
  background: linear-gradient(135deg, #9333ea 0%, #6b21a8 100%);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.btn-success {
  background: linear-gradient(135deg, #10b981 0%, #047857 100%);
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
}

.btn-success:hover {
  background: linear-gradient(135deg, #059669 0%, #065f46 100%);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.btn-danger {
  background: linear-gradient(135deg, #ef4444 0%, #b91c1c 100%);
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
}

.btn-danger:hover {
  background: linear-gradient(135deg, #dc2626 0%, #991b1b 100%);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.btn-warning {
  background: linear-gradient(135deg, #f59e0b 0%, #b45309 100%);
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
}

.btn-warning:hover {
  background: linear-gradient(135deg, #d97706 0%, #92400e 100%);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.btn-ghost {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  color: #334155;
  border: 1px solid rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}

.btn-ghost:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.btn-secondary {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  color: white;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
}

.btn-secondary:hover {
  background: linear-gradient(135deg, #475569 0%, #334155 100%);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

/* 로딩 스피너 */
.loading-spinner {
  display: flex;
  align-items: center;
  justify-content: center;
}

.loading-spinner svg {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

/* 버튼 아이콘 */
.button-icon {
  flex-shrink: 0;
}

/* 버튼 텍스트 */
.button-text {
  white-space: nowrap;
}

/* 글래스모피즘 효과 */
.btn-modern::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s ease;
}

.btn-modern:hover::before {
  left: 100%;
}

/* 비활성화 상태 */
.btn-modern:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none !important;
  box-shadow: none !important;
}

.btn-modern:disabled::before {
  display: none;
}

/* 포커스 상태 */
.btn-modern:focus {
  outline: none;
}

/* 반응형 */
@media (max-width: 768px) {
  .btn-sm {
    padding: 0.375rem 0.75rem;
    font-size: 0.75rem;
  }
  
  .btn-md {
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
  }
  
  .btn-lg {
    padding: 0.75rem 1.5rem;
    font-size: 1rem;
  }
}
</style>
