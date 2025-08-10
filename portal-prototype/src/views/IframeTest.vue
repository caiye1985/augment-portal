<template>
  <PageLayout
    title="IframeContainer组件测试"
    description="测试通用iframe容器组件的功能"
    icon="Monitor"
  >
    <template #actions>
      <el-button @click="switchSystem">
        切换系统 (当前: {{ currentSystem }})
      </el-button>
      <el-button @click="toggleHeight">
        切换高度 (当前: {{ currentHeight }})
      </el-button>
    </template>

    <template #content>
      <el-row :gutter="20">
        <el-col :span="24">
          <el-card>
            <template #header>
              <div class="card-header">
                <span>IframeContainer 测试</span>
                <el-tag :type="getSystemType(currentSystem)">{{ getSystemName(currentSystem) }}</el-tag>
              </div>
            </template>
            
            <IframeContainer
              :system="currentSystem"
              :path="currentPath"
              :height="currentHeight"
              @load="onIframeLoad"
              @error="onIframeError"
              @reload="onIframeReload"
              @navigation="onIframeNavigation"
            />
          </el-card>
        </el-col>
      </el-row>

      <!-- 事件日志 -->
      <el-row :gutter="20" style="margin-top: 20px;">
        <el-col :span="24">
          <el-card>
            <template #header>
              <div class="card-header">
                <span>事件日志</span>
                <el-button size="small" @click="clearLogs">清空日志</el-button>
              </div>
            </template>
            
            <el-timeline>
              <el-timeline-item
                v-for="(log, index) in eventLogs"
                :key="index"
                :timestamp="log.timestamp"
                :type="log.type"
              >
                <strong>{{ log.event }}</strong>
                <div v-if="log.data">
                  <pre>{{ JSON.stringify(log.data, null, 2) }}</pre>
                </div>
              </el-timeline-item>
            </el-timeline>
            
            <el-empty v-if="eventLogs.length === 0" description="暂无事件日志" />
          </el-card>
        </el-col>
      </el-row>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import PageLayout from '@/components/PageLayout.vue'
import IframeContainer from '@/components/IframeContainer.vue'

// 响应式数据
const currentSystem = ref('netbox')
const currentPath = ref('')
const currentHeight = ref(600)
const eventLogs = ref([])

// 系统配置
const systems = ['netbox', 'nightingale', 'orion-ops']
const heights = [400, 600, 800]

// 计算属性
const getSystemName = (system) => {
  const names = {
    'netbox': '资产管理系统',
    'nightingale': '监控系统',
    'orion-ops': '自动化平台'
  }
  return names[system] || system
}

const getSystemType = (system) => {
  const types = {
    'netbox': 'primary',
    'nightingale': 'success',
    'orion-ops': 'warning'
  }
  return types[system] || 'info'
}

// 方法
const switchSystem = () => {
  const currentIndex = systems.indexOf(currentSystem.value)
  const nextIndex = (currentIndex + 1) % systems.length
  currentSystem.value = systems[nextIndex]
  
  addLog('系统切换', 'info', { 
    from: systems[currentIndex], 
    to: systems[nextIndex] 
  })
}

const toggleHeight = () => {
  const currentIndex = heights.indexOf(currentHeight.value)
  const nextIndex = (currentIndex + 1) % heights.length
  currentHeight.value = heights[nextIndex]
  
  addLog('高度切换', 'info', { 
    from: heights[currentIndex], 
    to: heights[nextIndex] 
  })
}

const addLog = (event, type = 'primary', data = null) => {
  eventLogs.value.unshift({
    event,
    type,
    data,
    timestamp: new Date().toLocaleTimeString()
  })
  
  // 限制日志数量
  if (eventLogs.value.length > 20) {
    eventLogs.value = eventLogs.value.slice(0, 20)
  }
}

const clearLogs = () => {
  eventLogs.value = []
}

// 事件处理
const onIframeLoad = (data) => {
  addLog('iframe加载完成', 'success', data)
}

const onIframeError = (data) => {
  addLog('iframe加载错误', 'danger', data)
}

const onIframeReload = (data) => {
  addLog('iframe重新加载', 'warning', data)
}

const onIframeNavigation = (data) => {
  addLog('iframe导航', 'info', data)
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

pre {
  background: #f5f5f5;
  padding: 8px;
  border-radius: 4px;
  font-size: 12px;
  margin: 8px 0 0 0;
  overflow-x: auto;
}
</style>
