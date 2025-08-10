<template>
  <div class="iframe-container">
    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container" v-loading="loading" element-loading-text="正在加载..." element-loading-background="rgba(0, 0, 0, 0.1)">
      <div class="loading-content">
        <el-icon class="loading-icon" :size="48">
          <Loading />
        </el-icon>
        <p class="loading-text">正在加载{{ systemName }}...</p>
      </div>
    </div>

    <!-- iframe容器 -->
    <iframe
      v-show="!loading && !error"
      ref="iframeRef"
      :src="iframeSrc"
      frameborder="0"
      width="100%"
      :height="containerHeight"
      :style="{ height: containerHeight }"
      @load="onIframeLoad"
      @error="onIframeError"
      class="iframe-content">
    </iframe>

    <!-- 错误状态 -->
    <div v-if="error" class="error-container">
      <el-result
        icon="error"
        title="加载失败"
        :sub-title="errorMessage">
        <template #extra>
          <el-button type="primary" @click="reload">
            <el-icon><Refresh /></el-icon>
            重新加载
          </el-button>
        </template>
      </el-result>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { Loading, Refresh } from '@element-plus/icons-vue'

// Props定义
const props = defineProps({
  system: {
    type: String,
    required: true,
    validator: value => ['netbox', 'nightingale', 'orion-ops'].includes(value)
  },
  path: {
    type: String,
    default: ''
  },
  height: {
    type: [String, Number],
    default: '600px'
  }
})

// 响应式数据
const route = useRoute()
const authStore = useAuthStore()
const iframeRef = ref(null)
const loading = ref(true)
const error = ref(false)
const errorMessage = ref('')

// 计算属性
const systemName = computed(() => {
  const systemNames = {
    'netbox': '资产管理系统',
    'nightingale': '监控系统',
    'orion-ops': '自动化平台'
  }
  return systemNames[props.system] || '第三方系统'
})

const containerHeight = computed(() => {
  if (typeof props.height === 'number') {
    return `${props.height}px`
  }
  return props.height
})

const iframeSrc = computed(() => {
  const basePath = `/api/v1/proxy/${props.system}`
  const targetPath = props.path || route.params.path || ''
  const token = authStore.token || 'dev-token' // 开发模式使用默认token

  // 构建完整URL
  const fullPath = targetPath ? `${basePath}/${targetPath}` : basePath
  return `${fullPath}?portal_token=${token}`
})

// 方法
const onIframeLoad = () => {
  loading.value = false
  error.value = false

  // 设置iframe通信
  setupIframeCommunication()

  // 触发加载完成事件
  emit('load', {
    system: props.system,
    src: iframeSrc.value
  })
}

const onIframeError = () => {
  loading.value = false
  error.value = true
  errorMessage.value = `无法加载${systemName.value}，请检查网络连接或联系管理员`

  // 触发错误事件
  emit('error', {
    system: props.system,
    message: errorMessage.value
  })
}

const reload = () => {
  loading.value = true
  error.value = false

  // 重新设置iframe src
  if (iframeRef.value) {
    iframeRef.value.src = iframeSrc.value
  }

  // 触发重新加载事件
  emit('reload', {
    system: props.system
  })
}

const setupIframeCommunication = () => {
  // 设置iframe与父页面的通信
  const handleMessage = (event) => {
    // 安全检查：只接受同源消息
    if (event.origin !== window.location.origin) return

    try {
      const { type, data } = event.data

      switch (type) {
        case 'resize':
          // 动态调整iframe高度
          if (iframeRef.value && data.height) {
            iframeRef.value.style.height = data.height + 'px'
          }
          break
        case 'navigation':
          // 处理页面导航
          console.log('Iframe navigation:', data.url)
          emit('navigation', data)
          break
        case 'auth-refresh':
          // 处理认证刷新
          reload()
          break
        default:
          console.log('Unknown iframe message type:', type)
      }
    } catch (err) {
      console.error('Error handling iframe message:', err)
    }
  }

  window.addEventListener('message', handleMessage)

  // 清理函数
  return () => {
    window.removeEventListener('message', handleMessage)
  }
}

// 事件定义
const emit = defineEmits(['load', 'error', 'reload', 'navigation'])

// 生命周期
let cleanupCommunication = null

onMounted(() => {
  // 组件挂载时的初始化逻辑
  console.log(`IframeContainer mounted for system: ${props.system}`)
})

onUnmounted(() => {
  // 清理iframe通信监听器
  if (cleanupCommunication) {
    cleanupCommunication()
  }
})
</script>

<style scoped>
.iframe-container {
  position: relative;
  width: 100%;
  height: 100%;
  background: #f5f5f5;
  border-radius: 8px;
  overflow: hidden;
}

.loading-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 400px;
  background: #fafafa;
}

.loading-content {
  text-align: center;
}

.loading-icon {
  color: var(--el-color-primary);
  margin-bottom: 16px;
}

.loading-text {
  color: #666;
  font-size: 14px;
  margin: 0;
}

.iframe-content {
  border: none;
  background: white;
  transition: opacity 0.3s ease;
}

.error-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  min-height: 400px;
  background: white;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .iframe-container {
    border-radius: 4px;
  }

  .loading-container,
  .error-container {
    min-height: 300px;
  }
}
</style>
