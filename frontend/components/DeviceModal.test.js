// 2025-01-27: DeviceModal 컴포넌트 테스트 - device.capacity.trim 오류 수정 검증
import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import DeviceModal from './DeviceModal.vue'

describe('DeviceModal - device.capacity.trim 오류 수정', () => {
  let wrapper

  beforeEach(() => {
    wrapper = mount(DeviceModal, {
      props: {
        device: null,
        employees: []
      }
    })
  })

  it('should handle null capacity values without throwing trim error', () => {
    // 2025-01-27: null capacity 값으로 테스트
    const vm = wrapper.vm
    
    // memoryDevices에 null capacity 추가
    vm.memoryDevices = [
      { capacity: null, unit: 'GB' },
      { capacity: '', unit: 'GB' },
      { capacity: 0, unit: 'GB' },
      { capacity: '8', unit: 'GB' }
    ]
    
    // formatMemoryString이 오류 없이 실행되어야 함
    expect(() => vm.formatMemoryString()).not.toThrow()
    expect(vm.formatMemoryString()).toBe('8GB')
  })

  it('should handle undefined capacity values without throwing trim error', () => {
    // 2025-01-27: undefined capacity 값으로 테스트
    const vm = wrapper.vm
    
    // storageDevices에 undefined capacity 추가
    vm.storageDevices = [
      { type: 'SSD', capacity: undefined, unit: 'GB' },
      { type: 'HDD', capacity: '', unit: 'TB' },
      { type: 'SSD', capacity: 0, unit: 'GB' },
      { type: 'SSD', capacity: '256', unit: 'GB' }
    ]
    
    // formatStorageString이 오류 없이 실행되어야 함
    expect(() => vm.formatStorageString()).not.toThrow()
    expect(vm.formatStorageString()).toBe('SSD 256GB')
  })

  it('should handle mixed capacity types correctly', () => {
    // 2025-01-27: 다양한 타입의 capacity 값으로 테스트
    const vm = wrapper.vm
    
    vm.memoryDevices = [
      { capacity: null, unit: 'GB' },
      { capacity: undefined, unit: 'GB' },
      { capacity: '', unit: 'GB' },
      { capacity: 0, unit: 'GB' },
      { capacity: '16', unit: 'GB' },
      { capacity: 32, unit: 'GB' }
    ]
    
    expect(() => vm.formatMemoryString()).not.toThrow()
    expect(vm.formatMemoryString()).toBe('16GB / 32GB')
  })

  it('should filter out empty, null, and undefined capacities', () => {
    // 2025-01-27: 빈 값들을 올바르게 필터링하는지 테스트
    const vm = wrapper.vm
    
    vm.storageDevices = [
      { type: 'SSD', capacity: null, unit: 'GB' },
      { type: 'HDD', capacity: undefined, unit: 'TB' },
      { type: 'SSD', capacity: '', unit: 'GB' },
      { type: 'SSD', capacity: 0, unit: 'GB' },
      { type: 'SSD', capacity: '512', unit: 'GB' },
      { type: 'HDD', capacity: 1, unit: 'TB' }
    ]
    
    const result = vm.formatStorageString()
    expect(result).toBe('SSD 512GB / HDD 1TB')
    expect(result).not.toContain('null')
    expect(result).not.toContain('undefined')
    expect(result).not.toContain('GB / HDD TB') // 빈 capacity가 필터링되었는지 확인
  })

  it('should handle number capacity values correctly', () => {
    // 2025-01-27: 숫자 타입 capacity 값 테스트
    const vm = wrapper.vm
    
    vm.memoryDevices = [
      { capacity: 8, unit: 'GB' },
      { capacity: 16, unit: 'GB' },
      { capacity: 32, unit: 'GB' }
    ]
    
    expect(() => vm.formatMemoryString()).not.toThrow()
    expect(vm.formatMemoryString()).toBe('8GB / 16GB / 32GB')
  })

  it('should handle string capacity values correctly', () => {
    // 2025-01-27: 문자열 타입 capacity 값 테스트
    const vm = wrapper.vm
    
    vm.storageDevices = [
      { type: 'SSD', capacity: '256', unit: 'GB' },
      { type: 'HDD', capacity: '1', unit: 'TB' },
      { type: 'SSD', capacity: '512', unit: 'GB' }
    ]
    
    expect(() => vm.formatStorageString()).not.toThrow()
    expect(vm.formatStorageString()).toBe('SSD 256GB / HDD 1TB / SSD 512GB')
  })

  it('should handle zero capacity values correctly', () => {
    // 2025-01-27: 0 값 처리 테스트
    const vm = wrapper.vm
    
    vm.memoryDevices = [
      { capacity: 0, unit: 'GB' },
      { capacity: '0', unit: 'GB' },
      { capacity: 8, unit: 'GB' }
    ]
    
    expect(() => vm.formatMemoryString()).not.toThrow()
    expect(vm.formatMemoryString()).toBe('8GB')
  })
})
