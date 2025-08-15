<template>
  <div class="qr-generator-page">
    <!-- 헤더 섹션 -->
    <div class="hero-section">
      <div class="hero-content">
        <div class="hero-icon">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 9h6v12H3z"/>
            <path d="M9 3h12v18H9z"/>
            <path d="M15 9h6"/>
            <path d="M15 15h6"/>
            <path d="M9 9h6"/>
            <path d="M9 15h6"/>
          </svg>
        </div>
        <h1 class="hero-title">
          <span class="gradient-text">QR 코드 생성기</span>
        </h1>
        <p class="hero-subtitle">
          장비와 직원을 위한 고품질 QR 코드를 생성하세요
        </p>
        
                 <!-- 전체 장비 액션 버튼 -->
         <div class="hero-actions">
           <BaseButton
             label="전체 장비 다운로드"
             variant="success"
             size="md"
             :loading="downloadingAll"
             :icon="'M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3'"
             @click="showDownloadOptions = true"
           />
           <BaseButton
             label="전체 장비 프린트"
             variant="primary"
             size="md"
             :loading="printingAll"
             :icon="'M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4zM9 17v2M15 17v2M9 9h6M9 13h6'"
             @click="showPrintOptions = true"
           />
           <!-- 2025-08-13: 일괄 QR 생성 버튼 추가 -->
           <BaseButton
             label="일괄 QR 생성"
             variant="accent"
             size="md"
             :loading="bulkGenerating"
             :icon="'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z'"
             @click="showBulkOptions = true"
           />
         </div>

         <!-- 다운로드 옵션 모달 -->
         <div v-if="showDownloadOptions" class="options-modal">
           <div class="options-content">
             <div class="options-header">
               <h3>전체 장비 다운로드 옵션</h3>
               <button @click="showDownloadOptions = false" class="close-btn">
                 <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <line x1="18" y1="6" x2="6" y2="18"/>
                   <line x1="6" y1="6" x2="18" y2="18"/>
                 </svg>
               </button>
             </div>
             <div class="options-body">
               <div class="option-group">
                 <label class="option-label">다운로드 형식</label>
                 <div class="option-options">
                   <label class="radio-option">
                     <input type="radio" v-model="downloadFormat" value="png" />
                     <span class="radio-custom"></span>
                     PNG 이미지
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="downloadFormat" value="svg" />
                     <span class="radio-custom"></span>
                     SVG 벡터
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="downloadFormat" value="zip" />
                     <span class="radio-custom"></span>
                     ZIP 압축파일
                   </label>
                 </div>
               </div>
               <div class="option-group">
                 <label class="option-label">QR 코드 링크 포함</label>
                 <div class="option-options">
                   <label class="radio-option">
                     <input type="radio" v-model="downloadLinkType" value="include" />
                     <span class="radio-custom"></span>
                     포함 (스캔 시 장비 페이지로 이동)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="downloadLinkType" value="linkOnly" />
                     <span class="radio-custom"></span>
                     링크로 바로 연결 (QR에 링크만 포함)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="downloadLinkType" value="none" />
                     <span class="radio-custom"></span>
                     미포함 (기본 QR 데이터만)
                   </label>
                 </div>
                 <p class="option-description">
                   링크를 포함하면 QR 코드를 스캔했을 때 해당 장비의 상세 페이지로 바로 이동할 수 있습니다. "링크로 바로 연결" 옵션은 QR 코드에 링크만 포함하여 즉시 접속이 가능합니다.
                 </p>
               </div>
             </div>
             <div class="options-footer">
               <BaseButton
                 label="취소"
                 variant="secondary"
                 size="sm"
                 @click="showDownloadOptions = false"
               />
               <BaseButton
                 label="다운로드 시작"
                 variant="success"
                 size="sm"
                 :loading="downloadingAll"
                 @click="executeDownload"
               />
             </div>
           </div>
         </div>

         <!-- 프린트 옵션 모달 -->
         <div v-if="showPrintOptions" class="options-modal">
           <div class="options-content">
             <div class="options-header">
               <h3>전체 장비 프린트 옵션</h3>
               <button @click="showPrintOptions = false" class="close-btn">
                 <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <line x1="18" y1="6" x2="6" y2="18"/>
                   <line x1="6" y1="6" x2="18" y2="18"/>
                 </svg>
               </button>
             </div>
             <div class="options-body">
               <div class="option-group">
                 <label class="option-label">프린트 레이아웃</label>
                 <div class="option-options">
                   <label class="radio-option">
                     <input type="radio" v-model="printLayout" value="grid" />
                     <span class="radio-custom"></span>
                     그리드 레이아웃 (여러 개씩)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="printLayout" value="individual" />
                     <span class="radio-custom"></span>
                     개별 레이아웃 (한 개씩)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="printLayout" value="compact" />
                     <span class="radio-custom"></span>
                     컴팩트 레이아웃 (밀집 배치)
                   </label>
                 </div>
               </div>
               <div class="option-group">
                 <label class="option-label">QR 코드 크기</label>
                 <div class="option-options">
                   <label class="radio-option">
                     <input type="radio" v-model="printQRSize" value="small" />
                     <span class="radio-custom"></span>
                     작게 (150px)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="printQRSize" value="medium" />
                     <span class="radio-custom"></span>
                     보통 (200px)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="printQRSize" value="large" />
                     <span class="radio-custom"></span>
                     크게 (250px)
                   </label>
                 </div>
               </div>
             </div>
             <div class="options-footer">
               <BaseButton
                 label="취소"
                 variant="secondary"
                 size="sm"
                 @click="showPrintOptions = false"
               />
               <BaseButton
                 label="프린트 시작"
                 variant="primary"
                 size="sm"
                 :loading="printingAll"
                 @click="executePrint"
               />
             </div>
           </div>
         </div>

         <!-- 일괄 생성 옵션 모달 -->
         <div v-if="showBulkOptions" class="options-modal">
           <div class="options-content">
             <div class="options-header">
               <h3>일괄 QR 생성 옵션</h3>
               <button @click="showBulkOptions = false" class="close-btn">
                 <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                   <line x1="18" y1="6" x2="6" y2="18"/>
                   <line x1="6" y1="6" x2="18" y2="18"/>
                 </svg>
               </button>
             </div>
             <div class="options-body">
               <div class="option-group">
                 <label class="option-label">생성 대상</label>
                 <div class="option-options">
                   <label class="radio-option">
                     <input type="radio" v-model="bulkTarget" value="all" />
                     <span class="radio-custom"></span>
                     전체 장비 ({{ filteredDevices.length }}개)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="bulkTarget" value="selected" />
                     <span class="radio-custom"></span>
                     선택된 장비
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="bulkTarget" value="filtered" />
                     <span class="radio-custom"></span>
                     필터된 장비
                   </label>
                 </div>
               </div>
               <div class="option-group">
                 <label class="option-label">출력 형식</label>
                 <div class="option-options">
                   <label class="radio-option">
                     <input type="radio" v-model="bulkFormat" value="zip" />
                     <span class="radio-custom"></span>
                     ZIP 압축파일
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="bulkFormat" value="pdf" />
                     <span class="radio-custom"></span>
                     PDF 문서
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="bulkFormat" value="individual" />
                     <span class="radio-custom"></span>
                     개별 파일
                   </label>
                 </div>
               </div>
               <div class="option-group">
                 <label class="option-label">QR 코드 링크 포함</label>
                 <div class="option-options">
                   <label class="radio-option">
                     <input type="radio" v-model="bulkLinkType" value="include" />
                     <span class="radio-custom"></span>
                     포함 (스캔 시 장비 페이지로 이동)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="bulkLinkType" value="linkOnly" />
                     <span class="radio-custom"></span>
                     링크로 바로 연결 (QR에 링크만 포함)
                   </label>
                   <label class="radio-option">
                     <input type="radio" v-model="bulkLinkType" value="none" />
                     <span class="radio-custom"></span>
                     미포함 (기본 QR 데이터만)
                   </label>
                 </div>
                 <p class="option-description">
                   링크를 포함하면 QR 코드를 스캔했을 때 해당 장비의 상세 페이지로 바로 이동할 수 있습니다. "링크로 바로 연결" 옵션은 QR 코드에 링크만 포함하여 즉시 접속이 가능합니다.
                 </p>
               </div>
             </div>
             <div class="options-footer">
               <BaseButton
                 label="취소"
                 variant="secondary"
                 size="sm"
                 @click="showBulkOptions = false"
               />
               <BaseButton
                 label="일괄 생성 시작"
                 variant="accent"
                 size="sm"
                 :loading="bulkGenerating"
                 @click="executeBulkGeneration"
               />
             </div>
           </div>
         </div>
      </div>
    </div>

    <!-- 메인 컨텐츠 -->
    <div class="main-content">
      <!-- QR 생성 방식 선택 -->
      <div class="section-card">
        <h2 class="section-title">QR 생성 방식 선택</h2>
        <div class="generation-mode-grid">
          <div 
            class="generation-mode-card"
            :class="{ active: generationMode === 'single' }"
            @click="generationMode = 'single'"
          >
            <div class="generation-mode-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                <circle cx="8.5" cy="8.5" r="1.5"/>
                <polyline points="21,15 16,10 5,21"/>
              </svg>
            </div>
            <h3 class="generation-mode-title">단일 QR 생성</h3>
            <p class="generation-mode-description">개별 장비/직원 QR 코드 생성</p>
          </div>
          
          <div 
            class="generation-mode-card"
            :class="{ active: generationMode === 'bulk' }"
            @click="generationMode = 'bulk'"
          >
            <div class="generation-mode-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/>
                <rect x="8" y="2" width="8" height="4" rx="1" ry="1"/>
                <path d="M9 14l2 2 4-4"/>
              </svg>
            </div>
            <h3 class="generation-mode-title">일괄 QR 생성</h3>
            <p class="generation-mode-description">여러 장비/직원 QR 코드 일괄 생성</p>
          </div>
          
          <div 
            class="generation-mode-card"
            :class="{ active: generationMode === 'template' }"
            @click="generationMode = 'template'"
          >
            <div class="generation-mode-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                <polyline points="14,2 14,8 20,8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
                <polyline points="10,9 9,9 8,9"/>
              </svg>
            </div>
            <h3 class="generation-mode-title">템플릿 기반 생성</h3>
            <p class="generation-mode-description">사용자 정의 템플릿으로 QR 생성</p>
          </div>
          
          <div 
            class="generation-mode-card"
            :class="{ active: generationMode === 'custom' }"
            @click="generationMode = 'custom'"
          >
            <div class="generation-mode-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
              </svg>
            </div>
            <h3 class="generation-mode-title">사용자 정의 생성</h3>
            <p class="generation-mode-description">직접 입력한 데이터로 QR 생성</p>
          </div>
        </div>
      </div>

      <!-- QR 타입 선택 (단일 생성 모드일 때만 표시) -->
      <div v-if="generationMode === 'single'" class="section-card">
        <h2 class="section-title">QR 코드 타입 선택</h2>
        <div class="qr-type-grid">
          <div 
            class="qr-type-card"
            :class="{ active: qrType === 'device' }"
            @click="qrType = 'device'"
          >
            <div class="qr-type-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <h3 class="qr-type-title">장비 QR 코드</h3>
            <p class="qr-type-description">장비 정보가 포함된 QR 코드</p>
          </div>
          
          <div 
            class="qr-type-card"
            :class="{ active: qrType === 'employee' }"
            @click="qrType = 'employee'"
          >
            <div class="qr-type-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <h3 class="qr-type-title">직원 QR 코드</h3>
            <p class="qr-type-description">직원 정보가 포함된 QR 코드</p>
          </div>
        </div>
      </div>

      <!-- 장비 선택 (단일 생성 모드에서 장비 QR 코드일 때만 표시) -->
      <div v-if="generationMode === 'single' && qrType === 'device'" class="section-card">
        <h2 class="section-title">장비 선택</h2>
        
        <!-- 검색 필터 -->
        <div class="search-container">
          <div class="search-input-wrapper">
            <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8"/>
              <path d="m21 21-4.35-4.35"/>
            </svg>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="장비명, 제조사, 모델명으로 검색..."
              class="search-input"
            />
          </div>
        </div>

        <!-- 장비 목록 -->
        <div class="device-grid">
          <div
            v-for="device in filteredDevices"
            :key="device.id"
            class="device-card"
            :class="{ selected: selectedDevice?.asset_number === device.asset_number }"
            @click="selectDevice(device)"
          >
            <div class="device-icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <div class="device-info">
              <h4 class="device-name">{{ device.manufacturer }} {{ device.model_name }}</h4>
              <p class="device-number">자산번호: {{ device.asset_number }}</p>
              <p class="device-status" :class="device.status">
                {{ getStatusText(device.status) }}
              </p>
            </div>
            <div class="device-check">
              <svg v-if="selectedDevice?.asset_number === device.asset_number" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="20,6 9,17 4,12"/>
              </svg>
            </div>
          </div>
        </div>
      </div>

      <!-- 일괄 생성 설정 (일괄 생성 모드일 때 표시) -->
      <div v-if="generationMode === 'bulk'" class="section-card">
        <h2 class="section-title">일괄 QR 생성 설정</h2>
        
        <div class="bulk-settings">
          <div class="setting-group">
            <label class="setting-label">생성 대상</label>
            <div class="setting-options">
              <label class="radio-option">
                <input type="radio" v-model="bulkTarget" value="all" />
                <span class="radio-custom"></span>
                전체 장비 ({{ filteredDevices.length }}개)
              </label>
              <label class="radio-option">
                <input type="radio" v-model="bulkTarget" value="selected" />
                <span class="radio-custom"></span>
                선택된 장비
              </label>
              <label class="radio-option">
                <input type="radio" v-model="bulkTarget" value="filtered" />
                <span class="radio-custom"></span>
                필터된 장비
              </label>
            </div>
          </div>

          <div class="setting-group">
            <label class="setting-label">출력 형식</label>
            <div class="setting-options">
              <label class="radio-option">
                <input type="radio" v-model="bulkFormat" value="zip" />
                <span class="radio-custom"></span>
                ZIP 압축파일
              </label>
              <label class="radio-option">
                <input type="radio" v-model="bulkFormat" value="pdf" />
                <span class="radio-custom"></span>
                PDF 문서
              </label>
              <label class="radio-option">
                <input type="radio" v-model="bulkFormat" value="individual" />
                <span class="radio-custom"></span>
                개별 파일
              </label>
            </div>
          </div>
        </div>

        <div class="bulk-actions">
          <BaseButton
            label="일괄 QR 생성 시작"
            variant="success"
            size="lg"
            :loading="bulkGenerating"
            :icon="'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z'"
            @click="startBulkGeneration"
          />
        </div>
      </div>

      <!-- 템플릿 기반 생성 설정 (템플릿 모드일 때 표시) -->
      <div v-if="generationMode === 'template'" class="section-card">
        <h2 class="section-title">템플릿 기반 QR 생성</h2>
        
        <div class="template-settings">
          <div class="setting-group">
            <label class="setting-label">템플릿 선택</label>
            <select v-model="selectedTemplate" class="template-select">
              <option value="">템플릿을 선택하세요</option>
              <option value="device-basic">장비 기본 템플릿</option>
              <option value="device-detailed">장비 상세 템플릿</option>
              <option value="employee-basic">직원 기본 템플릿</option>
              <option value="custom">사용자 정의 템플릿</option>
            </select>
          </div>

          <div class="setting-group">
            <label class="setting-label">템플릿 미리보기</label>
            <div class="template-preview">
              <pre class="template-code">{{ templatePreview }}</pre>
            </div>
          </div>
        </div>

        <div class="template-actions">
          <BaseButton
            label="템플릿으로 QR 생성"
            variant="accent"
            size="lg"
            :loading="templateGenerating"
            :icon="'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'"
            @click="generateFromTemplate"
          />
        </div>
      </div>

      <!-- 사용자 정의 생성 설정 (사용자 정의 모드일 때 표시) -->
      <div v-if="generationMode === 'custom'" class="section-card">
        <h2 class="section-title">사용자 정의 QR 생성</h2>
        
        <div class="custom-settings">
          <div class="setting-group">
            <label class="setting-label">QR 데이터 입력</label>
            <textarea
              v-model="customQRData"
              placeholder="QR 코드에 포함할 데이터를 JSON 형식으로 입력하세요..."
              class="custom-data-input"
              rows="10"
            ></textarea>
          </div>

          <div class="setting-group">
            <label class="setting-label">데이터 검증</label>
            <div class="validation-status" :class="validationStatus">
              {{ validationMessage }}
            </div>
          </div>
        </div>

        <div class="custom-actions">
          <BaseButton
            label="사용자 정의 QR 생성"
            variant="warning"
            size="lg"
            :loading="customGenerating"
            :icon="'M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'"
            @click="generateCustomQR"
          />
        </div>
      </div>

      <!-- QR 생성 섹션 -->
      <div v-if="selectedDevice || qrType === 'employee'" class="section-card">
        <h2 class="section-title">QR 코드 생성</h2>
        
        <!-- 선택된 장비 정보 -->
        <div v-if="selectedDevice" class="selected-device-info">
          <div class="device-preview">
            <div class="device-preview-icon">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                <line x1="8" y1="21" x2="16" y2="21"/>
                <line x1="12" y1="17" x2="12" y2="21"/>
              </svg>
            </div>
            <div class="device-preview-info">
              <h3 class="device-preview-name">{{ selectedDevice.manufacturer }} {{ selectedDevice.model_name }}</h3>
              <p class="device-preview-number">{{ selectedDevice.asset_number }}</p>
              <p class="device-preview-employee" v-if="selectedDevice.employees">
                담당자: {{ selectedDevice.employees.name }}
              </p>
            </div>
          </div>
        </div>

        <!-- QR 설정 -->
        <div class="qr-settings">
          <div class="setting-group">
            <label class="setting-label">QR 코드 형식</label>
            <div class="setting-options">
              <label class="radio-option">
                <input type="radio" v-model="qrFormat" value="png" />
                <span class="radio-custom"></span>
                PNG
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrFormat" value="svg" />
                <span class="radio-custom"></span>
                SVG
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrFormat" value="json" />
                <span class="radio-custom"></span>
                JSON
              </label>
            </div>
          </div>

          <div class="setting-group">
            <label class="setting-label">QR 코드 크기</label>
            <div class="size-slider">
              <input
                v-model="qrSize"
                type="range"
                min="128"
                max="512"
                step="32"
                class="size-range"
              />
              <span class="size-value">{{ qrSize }}px</span>
            </div>
          </div>

          <!-- 2025-08-13: QR 코드 품질 설정 추가 -->
          <div class="setting-group">
            <label class="setting-label">QR 코드 품질</label>
            <div class="setting-options">
              <label class="radio-option">
                <input type="radio" v-model="qrQuality" value="L" />
                <span class="radio-custom"></span>
                낮음 (7% 복구)
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrQuality" value="M" />
                <span class="radio-custom"></span>
                보통 (15% 복구)
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrQuality" value="Q" />
                <span class="radio-custom"></span>
                높음 (25% 복구)
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrQuality" value="H" />
                <span class="radio-custom"></span>
                최고 (30% 복구)
              </label>
            </div>
          </div>

          <!-- 2025-08-13: QR 코드 링크 포함 설정 추가 -->
          <div class="setting-group">
            <label class="setting-label">QR 코드 링크 포함</label>
            <div class="setting-options">
              <label class="radio-option">
                <input type="radio" v-model="qrLinkType" value="include" />
                <span class="radio-custom"></span>
                포함 (스캔 시 장비 페이지로 이동)
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrLinkType" value="linkOnly" />
                <span class="radio-custom"></span>
                링크로 바로 연결 (QR에 링크만 포함)
              </label>
              <label class="radio-option">
                <input type="radio" v-model="qrLinkType" value="none" />
                <span class="radio-custom"></span>
                미포함 (기본 QR 데이터만)
              </label>
            </div>
            <p class="setting-description">
              링크를 포함하면 QR 코드를 스캔했을 때 해당 장비의 상세 페이지로 바로 이동할 수 있습니다. "링크로 바로 연결" 옵션은 QR 코드에 링크만 포함하여 즉시 접속이 가능합니다.
            </p>
          </div>
        </div>

        <!-- 액션 버튼 -->
        <div class="action-buttons">
          <BaseButton
            label="QR 코드 생성"
            variant="accent"
            size="lg"
            :loading="generating"
            :icon="'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z'"
            @click="generateQR"
          />
        </div>
      </div>

      <!-- QR 결과 섹션 -->
      <div v-if="deviceQRUrl" class="section-card result-section">
        <h2 class="section-title">생성된 QR 코드</h2>
        
        <div class="qr-result">
          <div class="qr-display">
            <img :src="deviceQRUrl" :alt="`QR Code for ${selectedDevice?.asset_number}`" class="qr-image" />
          </div>
          
          <!-- 2025-08-13: QR 코드 메타데이터 표시 추가 -->
          <div v-if="qrMetadata" class="qr-metadata">
            <h4 class="metadata-title">QR 코드 정보</h4>
            <div class="metadata-grid">
              <div class="metadata-item">
                <span class="metadata-label">생성일시:</span>
                <span class="metadata-value">{{ formatDate(qrMetadata.generated_at) }}</span>
              </div>
              <div class="metadata-item">
                <span class="metadata-label">형식:</span>
                <span class="metadata-value">{{ qrMetadata.format }}</span>
              </div>
              <div class="metadata-item">
                <span class="metadata-label">버전:</span>
                <span class="metadata-value">{{ qrMetadata.version || '1.0' }}</span>
              </div>
              <div class="metadata-item">
                <span class="metadata-label">장비번호:</span>
                <span class="metadata-value">{{ qrMetadata.device_info?.asset_number }}</span>
              </div>
              <div class="metadata-item">
                <span class="metadata-label">담당자:</span>
                <span class="metadata-value">{{ qrMetadata.device_info?.employee || '미할당' }}</span>
              </div>
              <div class="metadata-item">
                <span class="metadata-label">부서:</span>
                <span class="metadata-value">{{ qrMetadata.device_info?.department || '-' }}</span>
              </div>
            </div>
          </div>
          
          <div class="qr-actions">
            <BaseButton
              label="다운로드"
              variant="success"
              :icon="'M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3'"
              @click="downloadQR"
            />
            <BaseButton
              label="인쇄"
              variant="primary"
              :icon="'M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4zM9 17v2M15 17v2M9 9h6M9 13h6'"
              @click="printDeviceQR"
            />
            <!-- 2025-08-13: QR 코드 검증 버튼 추가 -->
            <BaseButton
              label="검증"
              variant="warning"
              :icon="'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'"
              @click="validateGeneratedQR"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// 2024-12-19: 트렌디한 UI 디자인으로 QR 생성 페이지 완전 재설계
// 2024-12-19: TypeScript 오류 수정 - useApi composable 사용으로 변경
// 2025-01-27: QR 생성 로직 수정 - asset_number 사용 및 폐기된 장비 제외
// 2025-08-13: QR 생성기 고도화 - 고급 기능 및 메타데이터 추가

import { ref, computed, onMounted } from 'vue'
import { defineAsyncComponent } from 'vue'

const BaseButton = defineAsyncComponent(() => import('~/components/BaseButton.vue'))

// API composable 사용
const { devices: devicesApi, qr: qrApi } = useApi()

// 상태 관리
const qrType = ref<'device' | 'employee'>('device')
// 2025-01-27: QR 생성 방식 선택 추가
const generationMode = ref<'single' | 'bulk' | 'template' | 'custom'>('single')
const searchQuery = ref('')
const selectedDevice = ref<any>(null)
const qrFormat = ref<'png' | 'svg' | 'json'>('png') // 2024-12-19: 'json' 타입 추가
const qrSize = ref(256)
const qrQuality = ref<'L' | 'M' | 'Q' | 'H'>('M') // 2025-08-13: QR 품질 설정 추가
const qrLinkType = ref<'include' | 'linkOnly' | 'none'>('include') // 2025-01-27: QR 링크 타입 설정 (기본값: include)
const generating = ref(false)
const deviceQRUrl = ref('')
const qrMetadata = ref<any>(null) // 2025-08-13: QR 메타데이터 추가
const downloadingAll = ref(false)
const printingAll = ref(false)
const bulkGenerating = ref(false) // 2025-08-13: 일괄 생성 상태 추가

// 2025-01-27: 새로운 생성 방식 관련 상태 추가
const bulkTarget = ref<'all' | 'selected' | 'filtered'>('all')
const bulkFormat = ref<'zip' | 'pdf' | 'individual'>('zip')
const selectedTemplate = ref('')
const templatePreview = ref('')
const templateGenerating = ref(false)
const customQRData = ref('')
const customGenerating = ref(false)
const validationStatus = ref<'idle' | 'valid' | 'invalid'>('idle')
const validationMessage = ref('데이터를 입력하세요')

// 2025-01-27: 옵션 모달 관련 상태 추가
const showDownloadOptions = ref(false)
const showPrintOptions = ref(false)
const showBulkOptions = ref(false)

// 2025-01-27: 다운로드 옵션 관련 상태
const downloadFormat = ref<'png' | 'svg' | 'zip'>('png')
const downloadLinkType = ref<'include' | 'linkOnly' | 'none'>('include')

// 2025-01-27: 프린트 옵션 관련 상태
const printLayout = ref<'grid' | 'individual' | 'compact'>('grid')
const printQRSize = ref<'small' | 'medium' | 'large'>('medium')

// 2025-01-27: 일괄 생성 옵션 관련 상태
const bulkLinkType = ref<'include' | 'linkOnly' | 'none'>('include')

// 2025-01-27: QR 링크 타입에 따른 includeLink 값 계산
const includeLink = computed(() => {
  return qrLinkType.value === 'include' || qrLinkType.value === 'linkOnly'
})

// 2025-01-27: 링크만 포함하는지 여부 계산
const linkOnly = computed(() => {
  return qrLinkType.value === 'linkOnly'
})

// 장비 데이터
const devices = ref<any[]>([])

// 필터된 장비 목록 (폐기된 장비 제외)
const filteredDevices = computed(() => {
  // 2025-01-27: Exclude disposed devices from QR generation
  let filtered = devices.value.filter(device => device.purpose !== '폐기')
  
  if (!searchQuery.value) return filtered
  
  const query = searchQuery.value.toLowerCase()
  return filtered.filter(device => 
    device.manufacturer?.toLowerCase().includes(query) ||
    device.model_name?.toLowerCase().includes(query) ||
    device.asset_number?.toLowerCase().includes(query)
  )
})

// 상태 텍스트 변환
const getStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    active: '사용 중',
    inactive: '미사용',
    maintenance: '정비 중',
    retired: '폐기'
  }
  return statusMap[status] || status
}

// 장비 선택
const selectDevice = (device: any) => {
  selectedDevice.value = device
  deviceQRUrl.value = ''
  qrMetadata.value = null // 2025-08-13: 메타데이터 초기화
}

// QR 코드 생성
const generateQR = async () => {
  if (!selectedDevice.value) return
  
  generating.value = true
  try {
    // 2025-01-27: Use asset_number consistently for QR generation
    // 2025-08-13: Include link parameter for direct navigation
    const response = await qrApi.getDeviceQR(selectedDevice.value.asset_number, qrFormat.value, includeLink.value, linkOnly.value)
    
    if (qrFormat.value === 'json') {
      // JSON 응답인 경우
      const qrResponse = response as any
      deviceQRUrl.value = qrResponse.qrUrl || qrResponse.data?.qrUrl
      qrMetadata.value = qrResponse.metadata // 2025-08-13: 메타데이터 저장
    } else {
      // Blob 응답인 경우 (PNG/SVG)
      const blob = response as Blob
      deviceQRUrl.value = URL.createObjectURL(blob)
      // 2025-08-13: 기본 메타데이터 생성
      qrMetadata.value = {
        generated_at: new Date().toISOString(),
        format: qrFormat.value,
        version: '2.0',
        device_info: {
          asset_number: selectedDevice.value.asset_number,
          manufacturer: selectedDevice.value.manufacturer,
          model_name: selectedDevice.value.model_name,
          employee: selectedDevice.value.employees?.name || '미할당',
          department: selectedDevice.value.employees?.department || '',
          purpose: selectedDevice.value.purpose
        },
        direct_link: includeLink.value ? `${window.location.origin}/devices/${selectedDevice.value.asset_number}` : null,
        link_type: qrLinkType.value // 2025-01-27: 링크 타입 정보 추가
      }
    }
  } catch (error) {
    console.error('QR 생성 실패:', error)
  } finally {
    generating.value = false
  }
}

// QR 다운로드
const downloadQR = () => {
  if (!deviceQRUrl.value) return
  
  const link = document.createElement('a')
  link.href = deviceQRUrl.value
  link.download = `qr-${selectedDevice.value?.asset_number}.${qrFormat.value}`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// QR 인쇄
const printDeviceQR = () => {
  if (deviceQRUrl.value) {
    const printWindow = window.open('', '', 'width=400,height=500')
    if (printWindow) {
      printWindow.document.write(`
        <html>
          <head>
            <title>QR Code - ${selectedDevice.value?.asset_number}</title>
            <style>
              body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                text-align: center;
                padding: 20px;
                margin: 0;
                background: white;
              }
              .qr-container {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 400px;
              }
              .qr-code {
                margin-bottom: 20px;
              }
              .product-number {
                border: 2px solid #333;
                padding: 10px 20px;
                border-radius: 8px;
                font-size: 18px;
                font-weight: bold;
                background: #f8f9fa;
                color: #333;
              }
              .device-info {
                margin-top: 15px;
                font-size: 14px;
                color: #666;
              }
            </style>
          </head>
          <body>
            <div class="qr-container">
              <div class="qr-code">
                <img src="${deviceQRUrl.value}" style="max-width: 300px; height: auto;" />
              </div>
              <div class="product-number">
                ${selectedDevice.value?.asset_number}
              </div>
              <div class="device-info">
                <p>${selectedDevice.value?.manufacturer} ${selectedDevice.value?.model_name}</p>
                <p>담당자: ${selectedDevice.value?.employees?.name}</p>
              </div>
            </div>
          </body>
        </html>
      `)
      printWindow.document.close()
      printWindow.print()
    }
  }
}

// 2025-08-13: QR 코드 검증 기능 추가
const validateGeneratedQR = async () => {
  if (!selectedDevice.value) return
  
  try {
    // QR 코드 데이터 생성
    const qrData = {
      t: 'd',
      i: selectedDevice.value.id,
      a: selectedDevice.value.asset_number,
      m: selectedDevice.value.manufacturer,
      n: selectedDevice.value.model_name,
      s: selectedDevice.value.serial_number,
      e: selectedDevice.value.employees?.name || '',
      c: 'Company Name',
      g: new Date().toISOString().split('T')[0],
      dt: selectedDevice.value.device_type || '',
      cpu: selectedDevice.value.cpu || '',
      mem: selectedDevice.value.memory || '',
      str: selectedDevice.value.storage || '',
      os: selectedDevice.value.os || '',
      ca: selectedDevice.value.created_at ? new Date(selectedDevice.value.created_at).toISOString().split('T')[0] : '',
      v: '2.0'
    }
    
    const qrString = JSON.stringify(qrData)
    const validationResult = await qrApi.validate(qrString)
    
    if (validationResult.is_valid) {
      alert('QR 코드가 유효합니다!')
    } else {
      alert('QR 코드가 유효하지 않습니다.')
    }
  } catch (error) {
    console.error('QR 검증 실패:', error)
    alert('QR 코드 검증에 실패했습니다.')
  }
}

// 2025-08-13: 일괄 QR 생성 기능 추가
const bulkGenerateQR = async () => {
  const availableDevices = devices.value.filter(device => device.purpose !== '폐기')
  
  if (availableDevices.length === 0) {
    alert('생성할 장비가 없습니다.')
    return
  }
  
  bulkGenerating.value = true
  try {
    const deviceIds = availableDevices.map(device => device.id)
    // 2025-08-13: Include link parameter for bulk generation
    const response = await qrApi.bulkDeviceQR(deviceIds, 'json', false, includeLink.value)
    
    console.log('일괄 QR 생성 결과:', response)
    alert(`일괄 QR 생성 완료!\n총 ${response.total_requested}개 중 ${response.total_generated}개 생성됨\n성공률: ${response.success_rate}`)
    
  } catch (error) {
    console.error('일괄 QR 생성 실패:', error)
    alert('일괄 QR 생성에 실패했습니다.')
  } finally {
    bulkGenerating.value = false
  }
}

// 2025-01-27: 옵션 모달 실행 함수들 추가
const executeDownload = async () => {
  showDownloadOptions.value = false
  
  // 2025-01-27: Exclude disposed devices from bulk operations
  const availableDevices = devices.value.filter(device => device.purpose !== '폐기')
  
  if (availableDevices.length === 0) {
    alert('다운로드할 장비가 없습니다.')
    return
  }
  
  downloadingAll.value = true
  try {
    // 각 장비의 QR 코드를 개별적으로 다운로드
    for (const device of availableDevices) {
      try {
        const includeLinkForDownload = downloadLinkType.value === 'include' || downloadLinkType.value === 'linkOnly'
        const linkOnlyForDownload = downloadLinkType.value === 'linkOnly'
        const qrResponse = await qrApi.getDeviceQR(device.asset_number, downloadFormat.value, includeLinkForDownload, linkOnlyForDownload)
        
        if (qrResponse instanceof Blob) {
          const url = URL.createObjectURL(qrResponse)
          const link = document.createElement('a')
          link.href = url
          link.download = `qr-${device.asset_number}.${downloadFormat.value}`
          document.body.appendChild(link)
          link.click()
          document.body.removeChild(link)
          URL.revokeObjectURL(url)
          
          // 다운로드 간격을 두어 브라우저가 처리할 시간을 줍니다
          await new Promise(resolve => setTimeout(resolve, 100))
        }
      } catch (error) {
        console.error(`장비 ${device.asset_number} QR 다운로드 실패:`, error)
      }
    }
    
    alert('전체 장비 QR 코드가 성공적으로 다운로드되었습니다.')
  } catch (error) {
    console.error('전체 장비 다운로드 실패:', error)
    alert('전체 장비 다운로드에 실패했습니다.')
  } finally {
    downloadingAll.value = false
  }
}

const executePrint = async () => {
  showPrintOptions.value = false
  
  // 2025-01-27: Exclude disposed devices from bulk operations
  const availableDevices = devices.value.filter(device => device.purpose !== '폐기')
  
  if (availableDevices.length === 0) {
    alert('프린트할 장비가 없습니다.')
    return
  }
  
  printingAll.value = true
  try {
    // 모든 장비의 QR 코드를 생성하고 프린트 페이지 열기
    const printWindow = window.open('', '', 'width=800,height=600')
    if (printWindow) {
      let printContent = `
        <html>
          <head>
            <title>전체 장비 QR 코드</title>
            <style>
              body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0;
                padding: 20px;
                background: white;
              }
              .qr-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                max-width: 100%;
              }
              .qr-item {
                text-align: center;
                padding: 15px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                page-break-inside: avoid;
              }
              .qr-code {
                margin-bottom: 10px;
              }
              .qr-code img {
                max-width: ${printQRSize.value === 'small' ? '150px' : printQRSize.value === 'large' ? '250px' : '200px'};
                height: auto;
              }
              .device-number {
                font-weight: bold;
                font-size: 14px;
                margin-bottom: 5px;
                color: #333;
              }
              .device-info {
                font-size: 12px;
                color: #666;
                margin-bottom: 5px;
              }
              .employee-info {
                font-size: 11px;
                color: #888;
              }
              @media print {
                .qr-item {
                  border: 1px solid #ccc;
                }
              }
            </style>
          </head>
          <body>
            <h1 style="text-align: center; margin-bottom: 30px;">전체 장비 QR 코드</h1>
            <div class="qr-grid">
      `
      
      // 각 장비의 QR 코드를 생성하여 HTML에 추가
      for (const device of availableDevices) {
        try {
          const includeLinkForPrint = bulkLinkType.value === 'include' || bulkLinkType.value === 'linkOnly'
          const linkOnlyForPrint = bulkLinkType.value === 'linkOnly'
          const qrResponse = await qrApi.getDeviceQR(device.asset_number, 'png', includeLinkForPrint, linkOnlyForPrint)
          let qrUrl = ''
          
          if (typeof qrResponse === 'object' && 'qrUrl' in qrResponse) {
            qrUrl = (qrResponse as any).qrUrl
          } else {
            const blob = qrResponse as Blob
            qrUrl = URL.createObjectURL(blob)
          }
          
          printContent += `
            <div class="qr-item">
              <div class="qr-code">
                <img src="${qrUrl}" alt="QR Code for ${device.asset_number}" />
              </div>
              <div class="device-number">${device.asset_number}</div>
              <div class="device-info">${device.manufacturer} ${device.model_name}</div>
              <div class="employee-info">담당자: ${device.employees?.name || '미배정'}</div>
            </div>
          `
        } catch (error) {
          console.error(`장비 ${device.asset_number} QR 생성 실패:`, error)
          printContent += `
            <div class="qr-item">
              <div class="device-number">${device.asset_number}</div>
              <div class="device-info">QR 생성 실패</div>
            </div>
          `
        }
      }
      
      printContent += `
            </div>
          </body>
        </html>
      `
      
      printWindow.document.write(printContent)
      printWindow.document.close()
      
      // 프린트 다이얼로그 열기
      setTimeout(() => {
        printWindow.print()
      }, 1000)
    }
  } catch (error) {
    console.error('전체 장비 프린트 실패:', error)
    alert('전체 장비 프린트에 실패했습니다.')
  } finally {
    printingAll.value = false
  }
}

const executeBulkGeneration = async () => {
  showBulkOptions.value = false
  
  let targetDevices: any[] = []
  
  switch (bulkTarget.value) {
    case 'all':
      targetDevices = filteredDevices.value
      break
    case 'selected':
      if (!selectedDevice.value) {
        alert('선택된 장비가 없습니다.')
        return
      }
      targetDevices = [selectedDevice.value]
      break
    case 'filtered':
      targetDevices = filteredDevices.value
      break
  }
  
  if (targetDevices.length === 0) {
    alert('생성할 장비가 없습니다.')
    return
  }
  
  bulkGenerating.value = true
  try {
    const deviceIds = targetDevices.map(device => device.id)
    const includeLinkForBulk = bulkLinkType.value === 'include' || bulkLinkType.value === 'linkOnly'
    const response = await qrApi.bulkDeviceQR(deviceIds, 'json', false, includeLinkForBulk)
    
    console.log('일괄 QR 생성 결과:', response)
    alert(`일괄 QR 생성 완료!\n총 ${response.total_requested}개 중 ${response.total_generated}개 생성됨\n성공률: ${response.success_rate}`)
    
  } catch (error) {
    console.error('일괄 QR 생성 실패:', error)
    alert('일괄 QR 생성에 실패했습니다.')
  } finally {
    bulkGenerating.value = false
  }
}

// 2025-01-27: 새로운 생성 방식 관련 함수들 추가
const startBulkGeneration = async () => {
  let targetDevices: any[] = []
  
  switch (bulkTarget.value) {
    case 'all':
      targetDevices = filteredDevices.value
      break
    case 'selected':
      if (!selectedDevice.value) {
        alert('선택된 장비가 없습니다.')
        return
      }
      targetDevices = [selectedDevice.value]
      break
    case 'filtered':
      targetDevices = filteredDevices.value
      break
  }
  
  if (targetDevices.length === 0) {
    alert('생성할 장비가 없습니다.')
    return
  }
  
  bulkGenerating.value = true
  try {
    const deviceIds = targetDevices.map(device => device.id)
    const response = await qrApi.bulkDeviceQR(deviceIds, bulkFormat.value, false, includeLink.value)
    
    console.log('일괄 QR 생성 결과:', response)
    alert(`일괄 QR 생성 완료!\n총 ${response.total_requested}개 중 ${response.total_generated}개 생성됨\n성공률: ${response.success_rate}`)
    
  } catch (error) {
    console.error('일괄 QR 생성 실패:', error)
    alert('일괄 QR 생성에 실패했습니다.')
  } finally {
    bulkGenerating.value = false
  }
}

const generateFromTemplate = async () => {
  if (!selectedTemplate.value) {
    alert('템플릿을 선택해주세요.')
    return
  }
  
  templateGenerating.value = true
  try {
    // 템플릿에 따른 QR 데이터 생성
    const templateData = getTemplateData(selectedTemplate.value)
    const response = await qrApi.generateFromTemplate(templateData, qrFormat.value)
    
    console.log('템플릿 QR 생성 결과:', response)
    alert('템플릿 기반 QR 생성이 완료되었습니다.')
    
  } catch (error) {
    console.error('템플릿 QR 생성 실패:', error)
    alert('템플릿 기반 QR 생성에 실패했습니다.')
  } finally {
    templateGenerating.value = false
  }
}

const generateCustomQR = async () => {
  if (!customQRData.value.trim()) {
    alert('QR 데이터를 입력해주세요.')
    return
  }
  
  // JSON 데이터 검증
  try {
    JSON.parse(customQRData.value)
    validationStatus.value = 'valid'
    validationMessage.value = '유효한 JSON 데이터입니다.'
  } catch (error) {
    validationStatus.value = 'invalid'
    validationMessage.value = '유효하지 않은 JSON 형식입니다.'
    return
  }
  
  customGenerating.value = true
  try {
    const response = await qrApi.generateCustom(customQRData.value, qrFormat.value)
    
    console.log('사용자 정의 QR 생성 결과:', response)
    alert('사용자 정의 QR 생성이 완료되었습니다.')
    
  } catch (error) {
    console.error('사용자 정의 QR 생성 실패:', error)
    alert('사용자 정의 QR 생성에 실패했습니다.')
  } finally {
    customGenerating.value = false
  }
}

const getTemplateData = (templateType: string) => {
  switch (templateType) {
    case 'device-basic':
      return {
        type: 'device',
        fields: ['asset_number', 'manufacturer', 'model_name', 'serial_number']
      }
    case 'device-detailed':
      return {
        type: 'device',
        fields: ['asset_number', 'manufacturer', 'model_name', 'serial_number', 'device_type', 'cpu', 'memory', 'storage', 'os']
      }
    case 'employee-basic':
      return {
        type: 'employee',
        fields: ['name', 'email', 'department', 'position']
      }
    default:
      return {}
  }
}

// 템플릿 미리보기 업데이트
const updateTemplatePreview = () => {
  if (!selectedTemplate.value) {
    templatePreview.value = ''
    return
  }
  
  const templateData = getTemplateData(selectedTemplate.value)
  templatePreview.value = JSON.stringify(templateData, null, 2)
}

// 템플릿 선택 변경 시 미리보기 업데이트
watch(selectedTemplate, updateTemplatePreview)

// 2025-08-13: 날짜 포맷팅 함수 추가
const formatDate = (dateString: string) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 전체 장비 다운로드
const downloadAllDevices = async () => {
  // 2025-01-27: Exclude disposed devices from bulk operations
  const availableDevices = devices.value.filter(device => device.purpose !== '폐기')
  
  if (availableDevices.length === 0) {
    alert('다운로드할 장비가 없습니다.')
    return
  }
  
  downloadingAll.value = true
  try {
    // 각 장비의 QR 코드를 개별적으로 다운로드
    for (const device of availableDevices) {
      try {
        const qrResponse = await qrApi.getDeviceQR(device.asset_number, 'png')
        if (qrResponse instanceof Blob) {
          const url = URL.createObjectURL(qrResponse)
          const link = document.createElement('a')
          link.href = url
          link.download = `qr-${device.asset_number}.png`
          document.body.appendChild(link)
          link.click()
          document.body.removeChild(link)
          URL.revokeObjectURL(url)
          
          // 다운로드 간격을 두어 브라우저가 처리할 시간을 줍니다
          await new Promise(resolve => setTimeout(resolve, 100))
        }
      } catch (error) {
        console.error(`장비 ${device.asset_number} QR 다운로드 실패:`, error)
      }
    }
    
    alert('전체 장비 QR 코드가 성공적으로 다운로드되었습니다.')
  } catch (error) {
    console.error('전체 장비 다운로드 실패:', error)
    alert('전체 장비 다운로드에 실패했습니다.')
  } finally {
    downloadingAll.value = false
  }
}

// 전체 장비 프린트
const printAllDevices = async () => {
  // 2025-01-27: Exclude disposed devices from bulk operations
  const availableDevices = devices.value.filter(device => device.purpose !== '폐기')
  
  if (availableDevices.length === 0) {
    alert('프린트할 장비가 없습니다.')
    return
  }
  
  printingAll.value = true
  try {
    // 모든 장비의 QR 코드를 생성하고 프린트 페이지 열기
    const printWindow = window.open('', '', 'width=800,height=600')
    if (printWindow) {
      let printContent = `
        <html>
          <head>
            <title>전체 장비 QR 코드</title>
            <style>
              body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
                margin: 0;
                padding: 20px;
                background: white;
              }
              .qr-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                max-width: 100%;
              }
              .qr-item {
                text-align: center;
                padding: 15px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                page-break-inside: avoid;
              }
              .qr-code {
                margin-bottom: 10px;
              }
              .qr-code img {
                max-width: 150px;
                height: auto;
              }
              .device-number {
                font-weight: bold;
                font-size: 14px;
                margin-bottom: 5px;
                color: #333;
              }
              .device-info {
                font-size: 12px;
                color: #666;
                margin-bottom: 5px;
              }
              .employee-info {
                font-size: 11px;
                color: #888;
              }
              @media print {
                .qr-item {
                  border: 1px solid #ccc;
                }
              }
            </style>
          </head>
          <body>
            <h1 style="text-align: center; margin-bottom: 30px;">전체 장비 QR 코드</h1>
            <div class="qr-grid">
      `
      
      // 각 장비의 QR 코드를 생성하여 HTML에 추가
      for (const device of availableDevices) {
        try {
          const qrResponse = await qrApi.getDeviceQR(device.asset_number, 'png')
          let qrUrl = ''
          
          if (typeof qrResponse === 'object' && 'qrUrl' in qrResponse) {
            qrUrl = (qrResponse as any).qrUrl
          } else {
            const blob = qrResponse as Blob
            qrUrl = URL.createObjectURL(blob)
          }
          
          printContent += `
            <div class="qr-item">
              <div class="qr-code">
                <img src="${qrUrl}" alt="QR Code for ${device.asset_number}" />
              </div>
              <div class="device-number">${device.asset_number}</div>
              <div class="device-info">${device.manufacturer} ${device.model_name}</div>
              <div class="employee-info">담당자: ${device.employees?.name || '미배정'}</div>
            </div>
          `
        } catch (error) {
          console.error(`장비 ${device.asset_number} QR 생성 실패:`, error)
          printContent += `
            <div class="qr-item">
              <div class="device-number">${device.asset_number}</div>
              <div class="device-info">QR 생성 실패</div>
            </div>
          `
        }
      }
      
      printContent += `
            </div>
          </body>
        </html>
      `
      
      printWindow.document.write(printContent)
      printWindow.document.close()
      
      // 프린트 다이얼로그 열기
      setTimeout(() => {
        printWindow.print()
      }, 1000)
    }
  } catch (error) {
    console.error('전체 장비 프린트 실패:', error)
    alert('전체 장비 프린트에 실패했습니다.')
  } finally {
    printingAll.value = false
  }
}

// 장비 데이터 로드
const loadDevices = async () => {
  try {
    // 2024-12-19: useApi composable 사용으로 변경하여 TypeScript 오류 해결
    const response = await devicesApi.getAll()
    devices.value = response.devices
  } catch (error) {
    console.error('장비 데이터 로드 실패:', error)
  }
}

onMounted(() => {
  loadDevices()
})
</script>

<style scoped>
/* 트렌디한 QR 생성 페이지 스타일 */
.qr-generator-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  padding: 2rem 0;
}

/* 히어로 섹션 */
.hero-section {
  text-align: center;
  margin-bottom: 3rem;
  padding: 0 2rem;
}

.hero-content {
  max-width: 600px;
  margin: 0 auto;
}

.hero-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 24px;
  margin-bottom: 1.5rem;
  color: white;
  box-shadow: 0 20px 25px -5px rgba(139, 92, 246, 0.3);
  animation: float 3s ease-in-out infinite;
}

.hero-title {
  font-size: 3rem;
  font-weight: 800;
  margin-bottom: 1rem;
  line-height: 1.2;
}

.hero-subtitle {
  font-size: 1.125rem;
  color: #64748b;
  line-height: 1.6;
  margin-bottom: 2rem;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

/* 메인 컨텐츠 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

/* 섹션 카드 */
.section-card {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 24px;
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  transition: all 0.3s ease;
}

.section-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.section-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  color: #1e293b;
}

/* QR 타입 그리드 */
.qr-type-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.qr-type-card {
  background: rgba(255, 255, 255, 0.6);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 20px;
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.qr-type-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.qr-type-card:hover {
  transform: translateY(-8px);
  border-color: rgba(139, 92, 246, 0.5);
  box-shadow: 0 20px 25px -5px rgba(139, 92, 246, 0.2);
}

.qr-type-card.active {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  border-color: #a855f7;
  box-shadow: 0 20px 25px -5px rgba(139, 92, 246, 0.3);
}

.qr-type-card.active::before {
  opacity: 1;
}

.qr-type-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 16px;
  margin-bottom: 1rem;
  color: white;
}

.qr-type-title {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #1e293b;
}

.qr-type-description {
  color: #64748b;
  font-size: 0.875rem;
}

/* 검색 컨테이너 */
.search-container {
  margin-bottom: 2rem;
}

.search-input-wrapper {
  position: relative;
  max-width: 500px;
}

.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  z-index: 10;
}

.search-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  font-size: 1rem;
  transition: all 0.3s ease;
}

.search-input:focus {
  outline: none;
  border-color: #a855f7;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

/* 장비 그리드 */
.device-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1rem;
}

.device-card {
  background: rgba(255, 255, 255, 0.6);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.device-card:hover {
  transform: translateY(-4px);
  border-color: rgba(139, 92, 246, 0.3);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.device-card.selected {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(139, 92, 246, 0.05) 100%);
  border-color: #a855f7;
  box-shadow: 0 10px 15px -3px rgba(139, 92, 246, 0.2);
}

.device-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #475569 0%, #1e293b 100%);
  border-radius: 12px;
  color: white;
  flex-shrink: 0;
}

.device-info {
  flex: 1;
}

.device-name {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.25rem;
  color: #1e293b;
}

.device-number {
  font-size: 0.875rem;
  color: #64748b;
  margin-bottom: 0.25rem;
}

.device-status {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  display: inline-block;
}

.device-status.active {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.device-status.inactive {
  background: rgba(100, 116, 139, 0.1);
  color: #475569;
}

.device-status.maintenance {
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
}

.device-status.retired {
  background: rgba(239, 68, 68, 0.1);
  color: #dc2626;
}

.device-check {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #10b981 0%, #047857 100%);
  border-radius: 8px;
  color: white;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.device-card.selected .device-check {
  opacity: 1;
}

/* 선택된 장비 정보 */
.selected-device-info {
  margin-bottom: 2rem;
}

.device-preview {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: rgba(139, 92, 246, 0.05);
  border: 1px solid rgba(139, 92, 246, 0.2);
  border-radius: 16px;
  padding: 1.5rem;
}

.device-preview-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #a855f7 0%, #7c3aed 100%);
  border-radius: 16px;
  color: white;
}

.device-preview-name {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 0.25rem;
  color: #1e293b;
}

.device-preview-number {
  font-size: 0.875rem;
  color: #64748b;
  margin-bottom: 0.25rem;
}

.device-preview-employee {
  font-size: 0.875rem;
  color: #10b981;
  font-weight: 500;
}

/* QR 설정 */
.qr-settings {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

/* 일괄 생성 설정 */
.bulk-settings {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.bulk-actions {
  text-align: center;
  margin-top: 2rem;
}

/* 템플릿 설정 */
.template-settings {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.template-select {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  font-size: 1rem;
  transition: all 0.3s ease;
}

.template-select:focus {
  outline: none;
  border-color: #a855f7;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

.template-preview {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 1rem;
  max-height: 200px;
  overflow-y: auto;
}

.template-code {
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.875rem;
  color: #1e293b;
  margin: 0;
  white-space: pre-wrap;
}

.template-actions {
  text-align: center;
  margin-top: 2rem;
}

/* 사용자 정의 설정 */
.custom-settings {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.custom-data-input {
  width: 100%;
  padding: 1rem;
  border: 2px solid #e2e8f0;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(10px);
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.875rem;
  resize: vertical;
  transition: all 0.3s ease;
}

.custom-data-input:focus {
  outline: none;
  border-color: #a855f7;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
}

.validation-status {
  padding: 0.75rem 1rem;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 500;
}

.validation-status.idle {
  background: rgba(100, 116, 139, 0.1);
  color: #475569;
}

.validation-status.valid {
  background: rgba(16, 185, 129, 0.1);
  color: #059669;
}

.validation-status.invalid {
  background: rgba(239, 68, 68, 0.1);
  color: #dc2626;
}

.custom-actions {
  text-align: center;
  margin-top: 2rem;
}

.setting-group {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.setting-label {
  font-weight: 600;
  color: #1e293b;
  font-size: 0.875rem;
}

.setting-options {
  display: flex;
  gap: 1rem;
}

.radio-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-size: 0.875rem;
  color: #64748b;
}

.radio-option input[type="radio"] {
  display: none;
}

.radio-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #e2e8f0;
  border-radius: 50%;
  position: relative;
  transition: all 0.3s ease;
}

.radio-option input[type="radio"]:checked + .radio-custom {
  border-color: #a855f7;
  background: #a855f7;
}

.radio-option input[type="radio"]:checked + .radio-custom::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background: white;
  border-radius: 50%;
}

.size-slider {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.size-range {
  flex: 1;
  height: 6px;
  border-radius: 3px;
  background: #e2e8f0;
  outline: none;
  -webkit-appearance: none;
  appearance: none;
}

.size-range::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #a855f7;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.size-value {
  font-weight: 600;
  color: #1e293b;
  min-width: 60px;
  text-align: right;
}

/* 액션 버튼 */
.action-buttons {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

/* QR 결과 섹션 */
.result-section {
  text-align: center;
}

.qr-result {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2rem;
}

.qr-display {
  background: white;
  border-radius: 20px;
  padding: 2rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.qr-image {
  max-width: 300px;
  height: auto;
  border-radius: 12px;
}

.qr-actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  justify-content: center;
}

/* 애니메이션 */
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

/* 반응형 */
@media (max-width: 768px) {
  .hero-title {
    font-size: 2rem;
  }
  
  .hero-icon {
    width: 60px;
    height: 60px;
  }
  
  .hero-actions {
    flex-direction: column;
    width: 100%;
    max-width: 300px;
    margin: 0 auto;
  }
  
  .section-card {
    padding: 1.5rem;
    margin-bottom: 1.5rem;
  }
  
  .qr-type-grid {
    grid-template-columns: 1fr;
  }
  
  .device-grid {
    grid-template-columns: 1fr;
  }
  
  .qr-settings {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
  
  .action-buttons {
    flex-direction: column;
  }
  
  .qr-actions {
    flex-direction: column;
    width: 100%;
  }
  
  .main-content {
    padding: 0 1rem;
  }
  
  .hero-section {
    padding: 0 1rem;
  }
}

/* 2025-08-13: QR 메타데이터 스타일 추가 */
.qr-metadata {
  margin-top: 2rem;
  padding: 1.5rem;
  background: rgba(139, 92, 246, 0.05);
  border: 1px solid rgba(139, 92, 246, 0.2);
  border-radius: 16px;
}

.metadata-title {
  font-size: 1.125rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: #1e293b;
}

.metadata-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.metadata-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid rgba(139, 92, 246, 0.1);
}

.metadata-item:last-child {
  border-bottom: none;
}

.metadata-label {
  font-weight: 500;
  color: #64748b;
  font-size: 0.875rem;
}

.metadata-value {
  font-weight: 600;
  color: #1e293b;
  font-size: 0.875rem;
}

/* 2025-08-13: 설정 설명 스타일 추가 */
.setting-description {
  font-size: 0.75rem;
  color: #64748b;
  margin-top: 0.5rem;
  line-height: 1.4;
}

/* 2025-01-27: 옵션 모달 스타일 추가 */
.options-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.options-content {
  background: white;
  border-radius: 20px;
  padding: 0;
  max-width: 500px;
  width: 90%;
  max-height: 80vh;
  overflow-y: auto;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  animation: modalSlideIn 0.3s ease-out;
}

.options-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e2e8f0;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 20px 20px 0 0;
}

.options-header h3 {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.close-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 8px;
  cursor: pointer;
  color: #64748b;
  transition: all 0.3s ease;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 1);
  color: #1e293b;
  transform: scale(1.1);
}

.options-body {
  padding: 2rem;
}

.option-group {
  margin-bottom: 2rem;
}

.option-group:last-child {
  margin-bottom: 0;
}

.option-label {
  font-weight: 600;
  color: #1e293b;
  font-size: 0.875rem;
  margin-bottom: 1rem;
  display: block;
}

.option-options {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.option-options .radio-option {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  cursor: pointer;
  font-size: 0.875rem;
  color: #64748b;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.option-options .radio-option:hover {
  background: rgba(139, 92, 246, 0.05);
  color: #1e293b;
}

.option-options .radio-option input[type="radio"] {
  display: none;
}

.option-options .radio-custom {
  width: 20px;
  height: 20px;
  border: 2px solid #e2e8f0;
  border-radius: 50%;
  position: relative;
  transition: all 0.3s ease;
  flex-shrink: 0;
}

.option-options .radio-option input[type="radio"]:checked + .radio-custom {
  border-color: #a855f7;
  background: #a855f7;
}

.option-options .radio-option input[type="radio"]:checked + .radio-custom::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 8px;
  height: 8px;
  background: white;
  border-radius: 50%;
}

.option-description {
  font-size: 0.75rem;
  color: #64748b;
  margin-top: 0.75rem;
  line-height: 1.4;
  padding: 0.75rem;
  background: rgba(139, 92, 246, 0.05);
  border-radius: 8px;
  border-left: 3px solid #a855f7;
}

.options-footer {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  padding: 1.5rem 2rem;
  border-top: 1px solid #e2e8f0;
  background: #f8fafc;
  border-radius: 0 0 20px 20px;
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* 애니메이션 */
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}
</style> 