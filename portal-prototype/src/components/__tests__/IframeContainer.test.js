import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import IframeContainer from '../IframeContainer.vue'
import { useAuthStore } from '@/stores/auth'

// Mock vue-router
vi.mock('vue-router', () => ({
  useRoute: () => ({
    params: { path: '' }
  })
}))

describe('IframeContainer', () => {
  let wrapper
  let pinia

  beforeEach(() => {
    pinia = createPinia()
    
    // 设置auth store的mock数据
    const authStore = useAuthStore(pinia)
    authStore.token = 'test-token'
  })

  afterEach(() => {
    if (wrapper) {
      wrapper.unmount()
    }
  })

  it('应该正确渲染加载状态', () => {
    wrapper = mount(IframeContainer, {
      props: {
        system: 'netbox'
      },
      global: {
        plugins: [pinia]
      }
    })

    expect(wrapper.find('.loading-container').exists()).toBe(true)
    expect(wrapper.text()).toContain('正在加载资产管理系统')
  })

  it('应该正确构建iframe URL', () => {
    wrapper = mount(IframeContainer, {
      props: {
        system: 'netbox',
        path: 'dcim/sites'
      },
      global: {
        plugins: [pinia]
      }
    })

    const iframe = wrapper.find('iframe')
    expect(iframe.attributes('src')).toContain('/api/v1/proxy/netbox/dcim/sites')
    expect(iframe.attributes('src')).toContain('portal_token=test-token')
  })

  it('应该支持不同的系统类型', () => {
    const systems = [
      { system: 'netbox', name: '资产管理系统' },
      { system: 'nightingale', name: '监控系统' },
      { system: 'orion-ops', name: '自动化平台' }
    ]

    systems.forEach(({ system, name }) => {
      wrapper = mount(IframeContainer, {
        props: { system },
        global: {
          plugins: [pinia]
        }
      })

      expect(wrapper.text()).toContain(`正在加载${name}`)
      wrapper.unmount()
    })
  })

  it('应该处理iframe加载完成事件', async () => {
    wrapper = mount(IframeContainer, {
      props: {
        system: 'netbox'
      },
      global: {
        plugins: [pinia]
      }
    })

    const iframe = wrapper.find('iframe')
    await iframe.trigger('load')

    expect(wrapper.emitted('load')).toBeTruthy()
    expect(wrapper.emitted('load')[0][0]).toEqual({
      system: 'netbox',
      src: expect.stringContaining('/api/v1/proxy/netbox')
    })
  })

  it('应该处理iframe错误事件', async () => {
    wrapper = mount(IframeContainer, {
      props: {
        system: 'netbox'
      },
      global: {
        plugins: [pinia]
      }
    })

    const iframe = wrapper.find('iframe')
    await iframe.trigger('error')

    expect(wrapper.find('.error-container').exists()).toBe(true)
    expect(wrapper.emitted('error')).toBeTruthy()
    expect(wrapper.text()).toContain('加载失败')
  })

  it('应该支持重新加载功能', async () => {
    wrapper = mount(IframeContainer, {
      props: {
        system: 'netbox'
      },
      global: {
        plugins: [pinia]
      }
    })

    // 触发错误状态
    const iframe = wrapper.find('iframe')
    await iframe.trigger('error')

    // 点击重新加载按钮
    const reloadButton = wrapper.find('.error-container button')
    await reloadButton.trigger('click')

    expect(wrapper.emitted('reload')).toBeTruthy()
    expect(wrapper.find('.loading-container').exists()).toBe(true)
  })

  it('应该正确设置iframe高度', () => {
    wrapper = mount(IframeContainer, {
      props: {
        system: 'netbox',
        height: 800
      },
      global: {
        plugins: [pinia]
      }
    })

    const iframe = wrapper.find('iframe')
    expect(iframe.attributes('height')).toBe('800px')
  })
})
