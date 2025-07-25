<template>
  <div class="space-y-6">
    <!-- Key Metrics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">총 직원 수</p>
            <p class="text-2xl font-bold text-gray-900">{{ stats?.total_employees || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">총 장비 수</p>
            <p class="text-2xl font-bold text-gray-900">{{ stats?.total_devices || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">활성 장비</p>
            <p class="text-2xl font-bold text-gray-900">{{ stats?.active_devices || 0 }}</p>
          </div>
          <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
            </svg>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-sm font-medium text-gray-600">회사명</p>
            <p class="text-2xl font-bold text-gray-900">{{ stats?.company_name || '데이터몬스' }}</p>
          </div>
          <div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Charts Section -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Department Distribution -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">부서별 장비 분포</h3>
        <div v-if="dashboard?.department_distribution?.length" class="space-y-4">
          <div 
            v-for="dept in dashboard.department_distribution" 
            :key="dept.department"
            class="flex items-center justify-between"
          >
            <div class="flex items-center">
              <div class="w-4 h-4 bg-blue-500 rounded-full mr-3"></div>
              <span class="text-sm font-medium text-gray-700">{{ dept.department }}</span>
            </div>
            <div class="flex items-center space-x-4">
              <span class="text-sm text-gray-500">{{ dept.employee_count }}명</span>
              <span class="text-sm text-gray-500">{{ dept.device_count }}개</span>
            </div>
          </div>
        </div>
        <div v-else class="text-center py-8">
          <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
            </svg>
          </div>
          <p class="text-gray-500 text-sm">부서별 데이터가 없습니다</p>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">최근 등록 현황</h3>
        <div v-if="dashboard?.recent_employees?.length || dashboard?.recent_devices?.length" class="space-y-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center mr-3">
                <span class="text-white text-sm font-medium">{{ dashboard?.recent_employees?.length || 0 }}</span>
              </div>
              <span class="text-sm font-medium text-gray-700">직원</span>
            </div>
            <span class="text-sm text-gray-500">{{ dashboard?.recent_employees?.length || 0 }}명</span>
          </div>
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center mr-3">
                <span class="text-white text-sm font-medium">{{ dashboard?.recent_devices?.length || 0 }}</span>
              </div>
              <span class="text-sm font-medium text-gray-700">장비</span>
            </div>
            <span class="text-sm text-gray-500">{{ dashboard?.recent_devices?.length || 0 }}개</span>
          </div>
        </div>
        <div v-else class="text-center py-8">
          <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
            </svg>
          </div>
          <p class="text-gray-500 text-sm">최근 등록 데이터가 없습니다</p>
        </div>
      </div>
    </div>

    <!-- Recent Activities -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Recent Employees -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">최근 등록 직원</h3>
        </div>
        <div class="p-6">
          <div v-if="dashboard?.recent_employees?.length" class="space-y-4">
            <div 
              v-for="employee in dashboard.recent_employees" 
              :key="employee.id"
              class="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
            >
              <div class="flex items-center">
                <div class="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center mr-3">
                  <span class="text-white font-medium text-sm">{{ employee.name.charAt(0) }}</span>
                </div>
                <div>
                  <p class="font-semibold text-gray-900 text-sm">{{ employee.name }}</p>
                  <p class="text-xs text-gray-600">{{ employee.department }} · {{ employee.position }}</p>
                </div>
              </div>
              <span class="text-xs text-gray-400">{{ formatDate(employee.created_at) }}</span>
            </div>
          </div>
          <div v-else class="text-center py-8">
            <p class="text-gray-500 text-sm">등록된 직원이 없습니다</p>
          </div>
        </div>
      </div>

      <!-- Recent Devices -->
      <div class="bg-white rounded-lg shadow-sm border border-gray-200">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">최근 등록 장비</h3>
        </div>
        <div class="p-6">
          <div v-if="dashboard?.recent_devices?.length" class="space-y-4">
            <div 
              v-for="device in dashboard.recent_devices" 
              :key="device.id"
              class="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
            >
              <div class="flex items-center">
                <div class="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center mr-3">
                  <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                </div>
                <div>
                  <p class="font-semibold text-gray-900 text-sm">{{ device.asset_number }}</p>
                  <p class="text-xs text-gray-600">{{ device.manufacturer }} {{ device.model_name }}</p>
                </div>
              </div>
              <span class="text-xs text-gray-400">{{ formatDate(device.created_at) }}</span>
            </div>
          </div>
          <div v-else class="text-center py-8">
            <p class="text-gray-500 text-sm">등록된 장비가 없습니다</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { DashboardStats, DashboardData } from '~/types'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const authStore = useAuthStore()
const api = useApi()

// State
const loading = ref(true)
const error = ref<string | null>(null)
const stats = ref<DashboardStats | null>(null)
const dashboard = ref<DashboardData | null>(null)

// Load dashboard data
const loadDashboard = async () => {
  try {
    loading.value = true
    error.value = null
    
    // Check if user is authenticated
    if (!authStore.isAuthenticated) {
      console.log('🔐 [DASHBOARD] User not authenticated, redirecting to login')
      await navigateTo('/login')
      return
    }
    
    console.log('🔐 [DASHBOARD] User authenticated, loading dashboard data')
    
    // Load stats and dashboard data in parallel
    const [statsResponse, dashboardResponse] = await Promise.all([
      api.users.getStats(),
      api.users.getDashboard()
    ])
    
    stats.value = statsResponse.stats
    dashboard.value = dashboardResponse.dashboard
  } catch (err: any) {
    error.value = err.message || '대시보드 데이터를 불러올 수 없습니다'
    console.error('Dashboard loading error:', err)
    
    // If unauthorized, redirect to login
    if (err.message.includes('401') || err.message.includes('403')) {
      console.log('🔐 [DASHBOARD] Unauthorized, redirecting to login')
      await navigateTo('/login')
    }
  } finally {
    loading.value = false
  }
}

// Format date
const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString('ko-KR')
}

// Load data on mount
onMounted(() => {
  loadDashboard()
})
</script> 