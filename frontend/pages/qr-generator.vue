<template>
  <div class="container py-8">
    <!-- Header with improved design -->
    <div class="mb-8 text-center">
      <div class="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full mb-4">
        <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
        </svg>
      </div>
      <h1 class="text-4xl font-bold text-gray-900 mb-3">QR 코드 생성기</h1>
      <p class="text-lg text-gray-600 max-w-2xl mx-auto">직원 및 장비별 QR 코드를 생성하고 관리하세요</p>
    </div>

    <!-- QR Type Selection with improved cards -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-8 mb-8">
      <h2 class="text-2xl font-semibold mb-6 text-gray-900">QR 코드 유형 선택</h2>
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <button 
          @click="selectedType = 'device'"
          :class="[
            'group relative p-6 border-2 rounded-xl text-left transition-all duration-300 hover:shadow-lg',
            selectedType === 'device' 
              ? 'border-blue-500 bg-blue-50 shadow-md' 
              : 'border-gray-200 hover:border-blue-300 bg-white'
          ]"
        >
          <div class="flex items-start space-x-4">
            <div :class="[
              'flex-shrink-0 w-12 h-12 rounded-lg flex items-center justify-center transition-colors',
              selectedType === 'device' ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-600 group-hover:bg-blue-100'
            ]">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
              </svg>
            </div>
            <div class="flex-1">
              <h3 class="text-xl font-semibold text-gray-900 mb-2">장비 QR 코드</h3>
              <p class="text-gray-600 mb-4">개별 장비의 상세 정보가 포함된 QR 코드</p>
              <div class="space-y-2">
                <div class="flex items-center text-sm text-gray-500">
                  <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  자산 번호, 모델명, 시리얼 번호
                </div>
                <div class="flex items-center text-sm text-gray-500">
                  <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  담당자 정보
                </div>
                <div class="flex items-center text-sm text-gray-500">
                  <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  장비 사양
                </div>
              </div>
            </div>
          </div>
        </button>

        <button 
          @click="selectedType = 'employee'"
          :class="[
            'group relative p-6 border-2 rounded-xl text-left transition-all duration-300 hover:shadow-lg',
            selectedType === 'employee' 
              ? 'border-blue-500 bg-blue-50 shadow-md' 
              : 'border-gray-200 hover:border-blue-300 bg-white'
          ]"
        >
          <div class="flex items-start space-x-4">
            <div :class="[
              'flex-shrink-0 w-12 h-12 rounded-lg flex items-center justify-center transition-colors',
              selectedType === 'employee' ? 'bg-blue-500 text-white' : 'bg-gray-100 text-gray-600 group-hover:bg-blue-100'
            ]">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
              </svg>
            </div>
            <div class="flex-1">
              <h3 class="text-xl font-semibold text-gray-900 mb-2">직원 QR 코드</h3>
              <p class="text-gray-600 mb-4">직원 정보와 할당된 장비 목록이 포함된 QR 코드</p>
              <div class="space-y-2">
                <div class="flex items-center text-sm text-gray-500">
                  <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  직원명, 부서, 직급
                </div>
                <div class="flex items-center text-sm text-gray-500">
                  <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  할당된 모든 장비 목록
                </div>
                <div class="flex items-center text-sm text-gray-500">
                  <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
                  </svg>
                  연락처 정보
                </div>
              </div>
            </div>
          </div>
        </button>
      </div>
    </div>

    <!-- Device QR Generation with improved layout -->
    <div v-if="selectedType === 'device'" class="space-y-8">
      <!-- Device Selection with improved search -->
      <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
        <div class="flex items-center mb-6">
          <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center mr-4">
            <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
          </div>
          <h3 class="text-2xl font-semibold text-gray-900">장비 선택</h3>
        </div>
        
        <!-- Enhanced Search -->
        <div class="mb-6">
          <div class="relative">
            <input
              v-model="deviceSearchQuery"
              type="text"
              placeholder="자산번호, 제조사, 모델명으로 검색..."
              class="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
            />
            <svg class="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
          </div>
        </div>

        <!-- Device List with improved cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="device in filteredDevices"
            :key="device.id"
            @click="selectedDevice = device"
            :class="[
              'p-4 border-2 rounded-lg cursor-pointer transition-all duration-200 hover:shadow-md',
              selectedDevice?.id === device.id 
                ? 'border-blue-500 bg-blue-50' 
                : 'border-gray-200 hover:border-blue-300'
            ]"
          >
            <div class="flex items-start space-x-3">
              <div class="flex-shrink-0 w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                </svg>
              </div>
              <div class="flex-1 min-w-0">
                <h4 class="font-semibold text-gray-900 truncate">{{ device.asset_number }}</h4>
                <p class="text-sm text-gray-600 truncate">{{ device.manufacturer }} {{ device.model_name }}</p>
                <p class="text-xs text-gray-500 mt-1">담당: {{ device.employees?.name }}</p>
              </div>
            </div>
          </div>
        </div>

        <div v-if="filteredDevices.length === 0" class="text-center py-8">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
          </svg>
          <p class="text-gray-500 mt-2">검색 결과가 없습니다</p>
        </div>
      </div>

      <!-- Generate Device QR with improved layout -->
      <div v-if="selectedDevice" class="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
        <div class="flex items-center mb-6">
          <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center mr-4">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
            </svg>
          </div>
          <h3 class="text-2xl font-semibold text-gray-900">QR 코드 생성</h3>
        </div>
        
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- QR Options with improved form -->
          <div class="space-y-6">
            <div class="bg-gray-50 rounded-lg p-4">
              <h4 class="font-semibold text-gray-900 mb-3">선택된 장비</h4>
              <div class="space-y-2">
                <p class="text-sm"><span class="font-medium">자산번호:</span> {{ selectedDevice.asset_number }}</p>
                <p class="text-sm"><span class="font-medium">제조사:</span> {{ selectedDevice.manufacturer }}</p>
                <p class="text-sm"><span class="font-medium">모델명:</span> {{ selectedDevice.model_name }}</p>
                <p class="text-sm"><span class="font-medium">담당자:</span> {{ selectedDevice.employees?.name }}</p>
              </div>
            </div>
            
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">QR 코드 형식</label>
                <select v-model="deviceQRFormat" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="png">PNG 이미지</option>
                  <option value="svg">SVG 벡터</option>
                </select>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">크기</label>
                <select v-model="deviceQRSize" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="200">작음 (200px)</option>
                  <option value="300">중간 (300px)</option>
                  <option value="400">큼 (400px)</option>
                </select>
              </div>

              <button 
                @click="generateDeviceQR"
                :disabled="deviceQRLoading"
                class="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center"
              >
                <svg v-if="deviceQRLoading" class="animate-spin w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                </svg>
                {{ deviceQRLoading ? '생성 중...' : 'QR 코드 생성' }}
              </button>
            </div>
          </div>

          <!-- QR Preview with improved design -->
          <div class="flex flex-col items-center">
            <h4 class="font-semibold text-gray-900 mb-4">QR 코드 미리보기</h4>
            <div v-if="deviceQRUrl" class="text-center">
              <div class="inline-block p-6 bg-white border-2 border-gray-200 rounded-xl shadow-sm">
                <img :src="deviceQRUrl" alt="Device QR Code" class="max-w-full" />
              </div>
              <div class="mt-6 space-x-3">
                <button @click="downloadDeviceQR" class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors duration-200">
                  <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                  </svg>
                  다운로드
                </button>
                <button @click="printDeviceQR" class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors duration-200">
                  <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                  </svg>
                  인쇄
                </button>
              </div>
            </div>
            <div v-else class="text-center py-12 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300 w-full">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
              </svg>
              <p class="text-gray-500 mt-2">QR 코드가 여기에 표시됩니다</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Employee QR Generation with similar improvements -->
    <div v-if="selectedType === 'employee'" class="space-y-8">
      <!-- Employee Selection -->
      <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
        <div class="flex items-center mb-6">
          <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center mr-4">
            <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
            </svg>
          </div>
          <h3 class="text-2xl font-semibold text-gray-900">직원 선택</h3>
        </div>
        
        <!-- Enhanced Search -->
        <div class="mb-6">
          <div class="relative">
            <input
              v-model="employeeSearchQuery"
              type="text"
              placeholder="직원명, 부서, 직급으로 검색..."
              class="w-full pl-12 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
            />
            <svg class="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
            </svg>
          </div>
        </div>

        <!-- Employee List with improved cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="employee in filteredEmployees"
            :key="employee.id"
            @click="selectedEmployee = employee"
            :class="[
              'p-4 border-2 rounded-lg cursor-pointer transition-all duration-200 hover:shadow-md',
              selectedEmployee?.id === employee.id 
                ? 'border-purple-500 bg-purple-50' 
                : 'border-gray-200 hover:border-purple-300'
            ]"
          >
            <div class="flex items-start space-x-3">
              <div class="flex-shrink-0 w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                <svg class="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                </svg>
              </div>
              <div class="flex-1 min-w-0">
                <h4 class="font-semibold text-gray-900 truncate">{{ employee.name }}</h4>
                <p class="text-sm text-gray-600 truncate">{{ employee.department }}</p>
                <p class="text-xs text-gray-500 mt-1">{{ employee.position }}</p>
              </div>
            </div>
          </div>
        </div>

        <div v-if="filteredEmployees.length === 0" class="text-center py-8">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
          </svg>
          <p class="text-gray-500 mt-2">검색 결과가 없습니다</p>
        </div>
      </div>

      <!-- Generate Employee QR -->
      <div v-if="selectedEmployee" class="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
        <div class="flex items-center mb-6">
          <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center mr-4">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
            </svg>
          </div>
          <h3 class="text-2xl font-semibold text-gray-900">QR 코드 생성</h3>
        </div>
        
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
          <!-- QR Options -->
          <div class="space-y-6">
            <div class="bg-gray-50 rounded-lg p-4">
              <h4 class="font-semibold text-gray-900 mb-3">선택된 직원</h4>
              <div class="space-y-2">
                <p class="text-sm"><span class="font-medium">이름:</span> {{ selectedEmployee.name }}</p>
                <p class="text-sm"><span class="font-medium">부서:</span> {{ selectedEmployee.department }}</p>
                <p class="text-sm"><span class="font-medium">직급:</span> {{ selectedEmployee.position }}</p>
              </div>
            </div>
            
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">QR 코드 형식</label>
                <select v-model="employeeQRFormat" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="png">PNG 이미지</option>
                  <option value="svg">SVG 벡터</option>
                </select>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">크기</label>
                <select v-model="employeeQRSize" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="200">작음 (200px)</option>
                  <option value="300">중간 (300px)</option>
                  <option value="400">큼 (400px)</option>
                </select>
              </div>

              <button 
                @click="generateEmployeeQR"
                :disabled="employeeQRLoading"
                class="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-semibold py-3 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center"
              >
                <svg v-if="employeeQRLoading" class="animate-spin w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
                </svg>
                {{ employeeQRLoading ? '생성 중...' : 'QR 코드 생성' }}
              </button>
            </div>
          </div>

          <!-- QR Preview -->
          <div class="flex flex-col items-center">
            <h4 class="font-semibold text-gray-900 mb-4">QR 코드 미리보기</h4>
            <div v-if="employeeQRUrl" class="text-center">
              <div class="inline-block p-6 bg-white border-2 border-gray-200 rounded-xl shadow-sm">
                <img :src="employeeQRUrl" alt="Employee QR Code" class="max-w-full" />
              </div>
              <div class="mt-6 space-x-3">
                <button @click="downloadEmployeeQR" class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors duration-200">
                  <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                  </svg>
                  다운로드
                </button>
                <button @click="printEmployeeQR" class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors duration-200">
                  <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                  </svg>
                  인쇄
                </button>
              </div>
            </div>
            <div v-else class="text-center py-12 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300 w-full">
              <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z"/>
              </svg>
              <p class="text-gray-500 mt-2">QR 코드가 여기에 표시됩니다</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Bulk QR Generation with improved design -->
    <div class="bg-white rounded-xl border border-gray-200 shadow-sm p-8">
      <div class="flex items-center mb-6">
        <div class="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center mr-4">
          <svg class="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
          </svg>
        </div>
        <h3 class="text-2xl font-semibold text-gray-900">일괄 QR 코드 생성</h3>
      </div>
      <p class="text-gray-600 mb-6">여러 장비의 QR 코드를 한 번에 생성할 수 있습니다.</p>
      
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">생성할 장비 수</label>
          <select v-model="bulkDeviceCount" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            <option value="5">최근 5개</option>
            <option value="10">최근 10개</option>
            <option value="20">최근 20개</option>
            <option value="all">모든 장비</option>
          </select>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">형식</label>
          <select v-model="bulkQRFormat" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
            <option value="png">PNG 이미지</option>
            <option value="json">JSON 데이터</option>
          </select>
        </div>
        <div class="flex items-end">
          <button 
            @click="generateBulkQR"
            :disabled="bulkQRLoading"
            class="w-full bg-orange-600 hover:bg-orange-700 disabled:bg-gray-400 text-white font-semibold py-2 px-6 rounded-lg transition-colors duration-200 flex items-center justify-center"
          >
            <svg v-if="bulkQRLoading" class="animate-spin w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
            </svg>
            {{ bulkQRLoading ? '생성 중...' : '일괄 생성' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Device, Employee } from '~/types'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const api = useApi()

// State
const selectedType = ref<'device' | 'employee'>('device')
const devices = ref<Device[]>([])
const employees = ref<Employee[]>([])
const loading = ref(true)

// Device QR state
const selectedDevice = ref<Device | null>(null)
const deviceSearchQuery = ref('')
const deviceQRFormat = ref<'png' | 'svg'>('png')
const deviceQRSize = ref('300')
const deviceQRUrl = ref<string | null>(null)
const deviceQRLoading = ref(false)

// Employee QR state
const selectedEmployee = ref<Employee | null>(null)
const employeeSearchQuery = ref('')
const employeeQRFormat = ref<'png' | 'svg'>('png')
const employeeQRSize = ref('300')
const employeeQRUrl = ref<string | null>(null)
const employeeQRLoading = ref(false)

// Bulk QR state
const bulkDeviceCount = ref('10')
const bulkQRFormat = ref<'png' | 'json'>('png')
const bulkQRLoading = ref(false)

// Computed
const filteredDevices = computed(() => {
  if (!deviceSearchQuery.value) return devices.value
  
  const query = deviceSearchQuery.value.toLowerCase()
  return devices.value.filter(device =>
    device.asset_number.toLowerCase().includes(query) ||
    device.manufacturer?.toLowerCase().includes(query) ||
    device.model_name?.toLowerCase().includes(query)
  )
})

const filteredEmployees = computed(() => {
  if (!employeeSearchQuery.value) return employees.value
  
  const query = employeeSearchQuery.value.toLowerCase()
  return employees.value.filter(employee =>
    employee.name.toLowerCase().includes(query) ||
    employee.department.toLowerCase().includes(query) ||
    employee.position.toLowerCase().includes(query)
  )
})

// Methods
const loadData = async () => {
  try {
    loading.value = true
    const [devicesResponse, employeesResponse] = await Promise.all([
      api.devices.getAll(),
      api.employees.getAll()
    ])
    devices.value = devicesResponse.devices
    employees.value = employeesResponse.employees
  } catch (error) {
    console.error('Failed to load data:', error)
  } finally {
    loading.value = false
  }
}

const generateDeviceQR = async () => {
  if (!selectedDevice.value) return
  
  try {
    deviceQRLoading.value = true
    const blob = await api.qr.getDeviceQR(
      selectedDevice.value.id, 
      deviceQRFormat.value
    ) as Blob
    
    deviceQRUrl.value = URL.createObjectURL(blob)
  } catch (error) {
    console.error('Failed to generate device QR:', error)
  } finally {
    deviceQRLoading.value = false
  }
}

const generateEmployeeQR = async () => {
  if (!selectedEmployee.value) return
  
  try {
    employeeQRLoading.value = true
    const blob = await api.qr.getEmployeeQR(
      selectedEmployee.value.id, 
      employeeQRFormat.value
    ) as Blob
    
    employeeQRUrl.value = URL.createObjectURL(blob)
  } catch (error) {
    console.error('Failed to generate employee QR:', error)
  } finally {
    employeeQRLoading.value = false
  }
}

const downloadDeviceQR = () => {
  if (deviceQRUrl.value && selectedDevice.value) {
    const a = document.createElement('a')
    a.href = deviceQRUrl.value
    a.download = `qr_device_${selectedDevice.value.asset_number}.${deviceQRFormat.value}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  }
}

const downloadEmployeeQR = () => {
  if (employeeQRUrl.value && selectedEmployee.value) {
    const a = document.createElement('a')
    a.href = employeeQRUrl.value
    a.download = `qr_employee_${selectedEmployee.value.name}.${employeeQRFormat.value}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  }
}

const printDeviceQR = () => {
  if (deviceQRUrl.value) {
    const printWindow = window.open('', '', 'width=400,height=400')
    if (printWindow) {
      printWindow.document.write(`
        <html>
          <head><title>QR Code - ${selectedDevice.value?.asset_number}</title></head>
          <body style="text-align: center; padding: 20px;">
            <h3>${selectedDevice.value?.asset_number}</h3>
            <img src="${deviceQRUrl.value}" style="max-width: 100%;" />
            <p>담당자: ${selectedDevice.value?.employees?.name}</p>
          </body>
        </html>
      `)
      printWindow.document.close()
      printWindow.print()
    }
  }
}

const printEmployeeQR = () => {
  if (employeeQRUrl.value) {
    const printWindow = window.open('', '', 'width=400,height=400')
    if (printWindow) {
      printWindow.document.write(`
        <html>
          <head><title>QR Code - ${selectedEmployee.value?.name}</title></head>
          <body style="text-align: center; padding: 20px;">
            <h3>${selectedEmployee.value?.name}</h3>
            <img src="${employeeQRUrl.value}" style="max-width: 100%;" />
            <p>${selectedEmployee.value?.department} - ${selectedEmployee.value?.position}</p>
          </body>
        </html>
      `)
      printWindow.document.close()
      printWindow.print()
    }
  }
}

const generateBulkQR = async () => {
  try {
    bulkQRLoading.value = true
    
    let deviceIds: string[]
    if (bulkDeviceCount.value === 'all') {
      deviceIds = devices.value.map(d => d.id)
    } else {
      const count = parseInt(bulkDeviceCount.value)
      deviceIds = devices.value.slice(0, count).map(d => d.id)
    }
    
    const result = await api.qr.bulkDeviceQR(deviceIds, bulkQRFormat.value)
    
    // Download as JSON file
    const blob = new Blob([JSON.stringify(result, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `bulk_qr_codes_${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    
  } catch (error) {
    console.error('Failed to generate bulk QR:', error)
  } finally {
    bulkQRLoading.value = false
  }
}

// Load data on mount
onMounted(() => {
  loadData()
})

// Reset selection when type changes
watch(selectedType, () => {
  selectedDevice.value = null
  selectedEmployee.value = null
  deviceQRUrl.value = null
  employeeQRUrl.value = null
})
</script> 