<template>
  <div class="global-search">
    <!-- 搜索触发按钮 -->
    <el-button
      v-if="!showSearchInput"
      circle
      size="small"
      class="search-trigger-btn"
      @click="openSearch"
      title="全局搜索 (Cmd+K)"
    >
      <el-icon><Search /></el-icon>
    </el-button>

    <!-- 搜索输入框 -->
    <div v-if="showSearchInput" class="search-input-container">
      <el-input
        ref="searchInputRef"
        v-model="searchQuery"
        placeholder="搜索功能、工单、工程师... (ESC退出)"
        clearable
        @keyup.enter="handleSearch"
        @keyup.esc="closeSearch"
        @blur="handleBlur"
        @input="handleInput"
        class="search-input"
      >
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
        <template #suffix>
          <el-button
            text
            size="small"
            @click="closeSearch"
            class="close-btn"
          >
            <el-icon><Close /></el-icon>
          </el-button>
        </template>
      </el-input>

      <!-- 搜索结果下拉面板 -->
      <div v-if="showResults && searchResults.length > 0" class="search-results">
        <div class="results-header">
          <span class="results-count">找到 {{ searchResults.length }} 个结果</span>
        </div>
        
        <div class="results-content">
          <!-- 功能模块结果 -->
          <div v-if="moduleResults.length > 0" class="result-section">
            <div class="section-title">
              <el-icon><Menu /></el-icon>
              功能模块
            </div>
            <div
              v-for="(item, index) in moduleResults"
              :key="`module-${index}`"
              class="result-item"
              @click="navigateToModule(item)"
            >
              <div class="item-icon">
                <el-icon><component :is="item.icon" /></el-icon>
              </div>
              <div class="item-content">
                <div class="item-title">{{ item.title }}</div>
                <div class="item-description">{{ item.description }}</div>
              </div>
              <div class="item-shortcut">
                <el-tag size="small" type="info">{{ item.category }}</el-tag>
              </div>
            </div>
          </div>

          <!-- 工单结果 -->
          <div v-if="ticketResults.length > 0" class="result-section">
            <div class="section-title">
              <el-icon><Tickets /></el-icon>
              工单
            </div>
            <div
              v-for="(item, index) in ticketResults"
              :key="`ticket-${index}`"
              class="result-item"
              @click="navigateToTicket(item)"
            >
              <div class="item-icon">
                <el-icon><Tickets /></el-icon>
              </div>
              <div class="item-content">
                <div class="item-title">{{ item.title }}</div>
                <div class="item-description">{{ item.ticketNo }} - {{ item.status }}</div>
              </div>
              <div class="item-shortcut">
                <el-tag size="small" :type="getStatusTagType(item.status)">
                  {{ item.status }}
                </el-tag>
              </div>
            </div>
          </div>

          <!-- 工程师结果 -->
          <div v-if="engineerResults.length > 0" class="result-section">
            <div class="section-title">
              <el-icon><User /></el-icon>
              工程师
            </div>
            <div
              v-for="(item, index) in engineerResults"
              :key="`engineer-${index}`"
              class="result-item"
              @click="navigateToEngineer(item)"
            >
              <div class="item-icon">
                <el-avatar size="small">{{ item.name.charAt(0) }}</el-avatar>
              </div>
              <div class="item-content">
                <div class="item-title">{{ item.name }}</div>
                <div class="item-description">{{ item.department }} - {{ item.skills.join(', ') }}</div>
              </div>
              <div class="item-shortcut">
                <el-tag size="small" :type="item.status === '在线' ? 'success' : 'info'">
                  {{ item.status }}
                </el-tag>
              </div>
            </div>
          </div>
        </div>

        <!-- 搜索提示 -->
        <div class="search-tips">
          <div class="tip-item">
            <kbd>↑</kbd><kbd>↓</kbd> 导航
          </div>
          <div class="tip-item">
            <kbd>Enter</kbd> 选择
          </div>
          <div class="tip-item">
            <kbd>Esc</kbd> 关闭
          </div>
        </div>
      </div>

      <!-- 无结果提示 -->
      <div v-if="showResults && searchResults.length === 0 && searchQuery" class="no-results">
        <div class="no-results-icon">
          <el-icon><Search /></el-icon>
        </div>
        <div class="no-results-text">
          <p>未找到相关结果</p>
          <p class="suggestion">尝试使用不同的关键词</p>
        </div>
      </div>

      <!-- 搜索历史 -->
      <div v-if="showResults && !searchQuery && searchHistory.length > 0" class="search-history">
        <div class="history-header">
          <span>最近搜索</span>
          <el-button text size="small" @click="clearHistory">清除</el-button>
        </div>
        <div class="history-items">
          <div
            v-for="(item, index) in searchHistory"
            :key="`history-${index}`"
            class="history-item"
            @click="searchQuery = item; handleInput()"
          >
            <el-icon><Clock /></el-icon>
            <span>{{ item }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 搜索遮罩 -->
    <div v-if="showSearchInput" class="search-overlay" @click="closeSearch"></div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search, Close, Menu, Tickets, User, Clock } from '@element-plus/icons-vue'

const router = useRouter()

// 响应式数据
const showSearchInput = ref(false)
const searchQuery = ref('')
const showResults = ref(false)
const searchResults = ref([])
const searchHistory = ref([])
const searchInputRef = ref(null)
const selectedIndex = ref(-1)

// 模拟数据
const mockModules = [
  { title: '工单管理', description: '创建、查看和管理工单', icon: 'Tickets', path: '/tickets', category: '核心功能' },
  { title: '工程师管理', description: '管理工程师信息和技能', icon: 'User', path: '/personnel/engineers', category: '人员管理' },
  { title: '运维仪表板', description: '查看系统运行状态和统计', icon: 'Monitor', path: '/workspace/dashboard', category: '工作台' },
  { title: '智能派单', description: '自动分配工单给合适的工程师', icon: 'Connection', path: '/tickets/dispatch', category: '智能功能' },
  { title: '知识库', description: '查看和管理运维知识', icon: 'Document', path: '/tickets/knowledge', category: '知识管理' },
  { title: '资产管理', description: '管理IT资产和设备', icon: 'Box', path: '/operations/assets', category: '运维管理' },
  { title: '监控系统', description: '查看系统监控数据', icon: 'Monitor', path: '/operations/monitoring', category: '运维管理' },
  { title: '租户管理', description: '管理多租户配置', icon: 'OfficeBuilding', path: '/system/tenants', category: '系统管理' },
  { title: '用户管理', description: '管理系统用户', icon: 'User', path: '/system/users', category: '系统管理' },
  { title: '我的任务', description: '查看分配给我的任务', icon: 'List', path: '/workspace/tasks', category: '工作台' }
]

const mockTickets = [
  { ticketNo: 'TK202501001', title: '服务器CPU使用率过高', status: '处理中', priority: '高' },
  { ticketNo: 'TK202501002', title: '数据库连接异常', status: '待分配', priority: '紧急' },
  { ticketNo: 'TK202501003', title: '网络延迟问题', status: '已完成', priority: '中' },
  { ticketNo: 'TK202501004', title: '邮件服务器故障', status: '待验收', priority: '高' },
  { ticketNo: 'TK202501005', title: '备份任务失败', status: '处理中', priority: '中' }
]

const mockEngineers = [
  { name: '张工程师', department: '运维部', skills: ['Linux', 'Docker', 'Kubernetes'], status: '在线' },
  { name: '李工程师', department: '网络部', skills: ['网络配置', '防火墙', 'VPN'], status: '忙碌' },
  { name: '王工程师', department: '数据库部', skills: ['MySQL', 'PostgreSQL', 'Redis'], status: '在线' },
  { name: '刘工程师', department: '安全部', skills: ['安全审计', '漏洞扫描', '应急响应'], status: '离线' }
]

// 计算属性
const moduleResults = computed(() => 
  searchResults.value.filter(item => item.type === 'module')
)

const ticketResults = computed(() => 
  searchResults.value.filter(item => item.type === 'ticket')
)

const engineerResults = computed(() => 
  searchResults.value.filter(item => item.type === 'engineer')
)

// 方法
const openSearch = () => {
  showSearchInput.value = true
  showResults.value = true
  nextTick(() => {
    searchInputRef.value?.focus()
  })
}

const closeSearch = () => {
  showSearchInput.value = false
  showResults.value = false
  searchQuery.value = ''
  selectedIndex.value = -1
}

const handleBlur = () => {
  // 延迟关闭，允许点击搜索结果
  setTimeout(() => {
    if (!document.activeElement?.closest('.search-results')) {
      closeSearch()
    }
  }, 200)
}

const handleInput = () => {
  if (!searchQuery.value.trim()) {
    searchResults.value = []
    return
  }

  const query = searchQuery.value.toLowerCase()
  const results = []

  // 搜索功能模块
  mockModules.forEach(module => {
    if (module.title.toLowerCase().includes(query) || 
        module.description.toLowerCase().includes(query) ||
        module.category.toLowerCase().includes(query)) {
      results.push({ ...module, type: 'module' })
    }
  })

  // 搜索工单
  mockTickets.forEach(ticket => {
    if (ticket.title.toLowerCase().includes(query) || 
        ticket.ticketNo.toLowerCase().includes(query) ||
        ticket.status.toLowerCase().includes(query)) {
      results.push({ ...ticket, type: 'ticket' })
    }
  })

  // 搜索工程师
  mockEngineers.forEach(engineer => {
    if (engineer.name.toLowerCase().includes(query) || 
        engineer.department.toLowerCase().includes(query) ||
        engineer.skills.some(skill => skill.toLowerCase().includes(query))) {
      results.push({ ...engineer, type: 'engineer' })
    }
  })

  searchResults.value = results.slice(0, 10) // 限制结果数量
}

const handleSearch = () => {
  if (!searchQuery.value.trim()) return

  // 添加到搜索历史
  if (!searchHistory.value.includes(searchQuery.value)) {
    searchHistory.value.unshift(searchQuery.value)
    if (searchHistory.value.length > 5) {
      searchHistory.value.pop()
    }
    saveSearchHistory()
  }

  // 如果有结果，导航到第一个结果
  if (searchResults.value.length > 0) {
    const firstResult = searchResults.value[0]
    if (firstResult.type === 'module') {
      navigateToModule(firstResult)
    } else if (firstResult.type === 'ticket') {
      navigateToTicket(firstResult)
    } else if (firstResult.type === 'engineer') {
      navigateToEngineer(firstResult)
    }
  }
}

const navigateToModule = (module) => {
  router.push(module.path)
  closeSearch()
  ElMessage.success(`已跳转到${module.title}`)
}

const navigateToTicket = (ticket) => {
  router.push(`/tickets?search=${ticket.ticketNo}`)
  closeSearch()
  ElMessage.success(`已跳转到工单 ${ticket.ticketNo}`)
}

const navigateToEngineer = (engineer) => {
  router.push(`/personnel/engineers?search=${engineer.name}`)
  closeSearch()
  ElMessage.success(`已跳转到工程师 ${engineer.name}`)
}

const getStatusTagType = (status) => {
  const typeMap = {
    '处理中': 'warning',
    '待分配': 'info',
    '已完成': 'success',
    '待验收': 'primary',
    '已关闭': 'info'
  }
  return typeMap[status] || 'info'
}

const clearHistory = () => {
  searchHistory.value = []
  localStorage.removeItem('global-search-history')
}

const saveSearchHistory = () => {
  localStorage.setItem('global-search-history', JSON.stringify(searchHistory.value))
}

const loadSearchHistory = () => {
  const saved = localStorage.getItem('global-search-history')
  if (saved) {
    try {
      searchHistory.value = JSON.parse(saved)
    } catch (error) {
      console.error('Failed to load search history:', error)
    }
  }
}

// 键盘快捷键处理
const handleKeydown = (event) => {
  // Cmd+K 或 Ctrl+K 打开搜索
  if ((event.metaKey || event.ctrlKey) && event.key === 'k') {
    event.preventDefault()
    if (!showSearchInput.value) {
      openSearch()
    }
  }
  
  // ESC 关闭搜索
  if (event.key === 'Escape' && showSearchInput.value) {
    closeSearch()
  }
}

// 生命周期
onMounted(() => {
  loadSearchHistory()
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.global-search {
  position: relative;
}

.search-trigger-btn {
  background: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: white !important;
  transition: all 0.3s ease;
}

.search-trigger-btn:hover {
  background: rgba(255, 255, 255, 0.2) !important;
  transform: scale(1.05);
}

.search-input-container {
  position: fixed;
  top: 80px;
  left: 50%;
  transform: translateX(-50%);
  width: 600px;
  max-width: 90vw;
  z-index: 2000;
  background: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  border: 1px solid var(--el-border-color-light);
  overflow: hidden;
}

.search-input {
  border: none;
  box-shadow: none;
}

.search-input .el-input__wrapper {
  border: none;
  box-shadow: none;
  padding: 16px 20px;
  font-size: 16px;
  background: transparent;
}

.close-btn {
  color: var(--el-text-color-regular);
}

.search-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  z-index: 1999;
  backdrop-filter: blur(4px);
}

.search-results {
  max-height: 400px;
  overflow-y: auto;
  border-top: 1px solid var(--el-border-color-lighter);
}

.results-header {
  padding: 12px 20px;
  background: var(--el-fill-color-lighter);
  border-bottom: 1px solid var(--el-border-color-lighter);
}

.results-count {
  font-size: 12px;
  color: var(--el-text-color-regular);
}

.results-content {
  padding: 8px 0;
}

.result-section {
  margin-bottom: 16px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 20px;
  font-size: 12px;
  font-weight: 600;
  color: var(--el-text-color-regular);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.result-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  border-left: 3px solid transparent;
}

.result-item:hover {
  background: var(--el-fill-color-light);
  border-left-color: var(--el-color-primary);
}

.item-icon {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--el-fill-color);
  border-radius: 6px;
  color: var(--el-color-primary);
}

.item-content {
  flex: 1;
  min-width: 0;
}

.item-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
  margin-bottom: 2px;
}

.item-description {
  font-size: 12px;
  color: var(--el-text-color-regular);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-shortcut {
  flex-shrink: 0;
}

.no-results {
  padding: 40px 20px;
  text-align: center;
  color: var(--el-text-color-regular);
}

.no-results-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.no-results-text p {
  margin: 0;
  line-height: 1.5;
}

.suggestion {
  font-size: 12px;
  opacity: 0.7;
}

.search-history {
  border-top: 1px solid var(--el-border-color-lighter);
  padding: 16px 0;
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px 12px;
  font-size: 12px;
  font-weight: 600;
  color: var(--el-text-color-regular);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.history-items {
  padding: 0 8px;
}

.history-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  cursor: pointer;
  border-radius: 6px;
  font-size: 14px;
  color: var(--el-text-color-regular);
  transition: all 0.2s ease;
}

.history-item:hover {
  background: var(--el-fill-color-light);
  color: var(--el-text-color-primary);
}

.search-tips {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding: 12px 20px;
  background: var(--el-fill-color-lighter);
  border-top: 1px solid var(--el-border-color-lighter);
}

.tip-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: var(--el-text-color-regular);
}

kbd {
  display: inline-block;
  padding: 2px 6px;
  font-size: 11px;
  line-height: 1;
  color: var(--el-text-color-regular);
  background: var(--el-fill-color);
  border: 1px solid var(--el-border-color);
  border-radius: 3px;
  font-family: monospace;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .search-input-container {
    width: 95vw;
    top: 70px;
  }
  
  .search-input .el-input__wrapper {
    padding: 12px 16px;
    font-size: 14px;
  }
  
  .result-item {
    padding: 10px 16px;
  }
  
  .item-icon {
    width: 28px;
    height: 28px;
  }
  
  .search-tips {
    display: none;
  }
}

/* 深色模式适配 */
[data-theme="dark"] .search-input-container {
  background: var(--el-bg-color);
  border-color: var(--el-border-color);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
}

/* 滚动条样式 */
.search-results::-webkit-scrollbar {
  width: 6px;
}

.search-results::-webkit-scrollbar-track {
  background: var(--el-fill-color-lighter);
}

.search-results::-webkit-scrollbar-thumb {
  background: var(--el-border-color);
  border-radius: 3px;
}

.search-results::-webkit-scrollbar-thumb:hover {
  background: var(--el-border-color-dark);
}
</style>