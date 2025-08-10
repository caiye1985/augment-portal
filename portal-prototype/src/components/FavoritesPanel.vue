<template>
  <div class="favorites-panel">
    <!-- 收藏夹触发按钮 -->
    <el-dropdown
      trigger="click"
      @visible-change="handleVisibleChange"
      placement="bottom-end"
      :hide-on-click="false"
    >
      <el-button circle size="small" class="favorites-trigger" title="我的收藏">
        <el-badge :value="favoriteCount" :hidden="favoriteCount === 0" :max="99">
          <el-icon><Star /></el-icon>
        </el-badge>
      </el-button>
      
      <template #dropdown>
        <div class="favorites-dropdown">
          <!-- 头部 -->
          <div class="favorites-header">
            <div class="header-title">
              <el-icon><Star /></el-icon>
              <span>我的收藏</span>
            </div>
            <div class="header-actions">
              <el-button
                text
                size="small"
                @click="showManageDialog = true"
                title="管理收藏"
              >
                <el-icon><Setting /></el-icon>
              </el-button>
            </div>
          </div>

          <!-- 收藏列表 -->
          <div class="favorites-content">
            <div v-if="favoritesList.length === 0" class="empty-favorites">
              <div class="empty-icon">
                <el-icon><Star /></el-icon>
              </div>
              <p>暂无收藏</p>
              <p class="empty-tip">点击页面右上角的星标按钮添加收藏</p>
            </div>

            <div v-else class="favorites-list">
              <!-- 分类显示收藏 -->
              <div
                v-for="category in categorizedFavorites"
                :key="category.name"
                class="favorite-category"
              >
                <div class="category-header">
                  <el-icon><component :is="category.icon" /></el-icon>
                  <span>{{ category.name }}</span>
                  <el-tag size="small" type="info">{{ category.items.length }}</el-tag>
                </div>
                
                <div class="category-items">
                  <div
                    v-for="item in category.items"
                    :key="item.path"
                    class="favorite-item"
                    @click="navigateToFavorite(item)"
                  >
                    <div class="item-icon">
                      <el-icon><component :is="getItemIcon(item.path)" /></el-icon>
                    </div>
                    <div class="item-content">
                      <div class="item-title">{{ item.title }}</div>
                      <div class="item-path">{{ item.path }}</div>
                    </div>
                    <div class="item-actions">
                      <el-button
                        text
                        size="small"
                        @click.stop="removeFavorite(item.path)"
                        class="remove-btn"
                        title="移除收藏"
                      >
                        <el-icon><Close /></el-icon>
                      </el-button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 底部操作 -->
          <div class="favorites-footer">
            <el-button
              text
              size="small"
              @click="exportFavorites"
              class="footer-action"
            >
              <el-icon><Download /></el-icon>
              导出收藏
            </el-button>
            <el-button
              text
              size="small"
              @click="showImportDialog = true"
              class="footer-action"
            >
              <el-icon><Upload /></el-icon>
              导入收藏
            </el-button>
          </div>
        </div>
      </template>
    </el-dropdown>

    <!-- 收藏管理对话框 -->
    <el-dialog
      v-model="showManageDialog"
      title="收藏管理"
      width="600px"
      :close-on-click-modal="false"
    >
      <div class="manage-content">
        <div class="manage-header">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索收藏..."
            clearable
            class="search-input"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
          
          <el-button
            type="danger"
            :disabled="selectedItems.length === 0"
            @click="batchRemoveFavorites"
          >
            <el-icon><Delete /></el-icon>
            批量删除 ({{ selectedItems.length }})
          </el-button>
        </div>

        <div class="manage-list">
          <el-table
            :data="filteredFavorites"
            @selection-change="handleSelectionChange"
            max-height="400"
          >
            <el-table-column type="selection" width="55" />
            <el-table-column label="页面" min-width="200">
              <template #default="{ row }">
                <div class="table-item">
                  <el-icon><component :is="getItemIcon(row.path)" /></el-icon>
                  <span>{{ row.title }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="path" label="路径" min-width="150" />
            <el-table-column label="添加时间" width="120">
              <template #default="{ row }">
                {{ formatTime(row.timestamp) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button
                  text
                  type="primary"
                  size="small"
                  @click="navigateToFavorite(row)"
                >
                  访问
                </el-button>
                <el-button
                  text
                  type="danger"
                  size="small"
                  @click="removeFavorite(row.path)"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </el-dialog>

    <!-- 导入收藏对话框 -->
    <el-dialog
      v-model="showImportDialog"
      title="导入收藏"
      width="500px"
      :close-on-click-modal="false"
    >
      <div class="import-content">
        <el-upload
          ref="uploadRef"
          :auto-upload="false"
          :show-file-list="false"
          accept=".json"
          :on-change="handleFileChange"
          drag
        >
          <div class="upload-area">
            <el-icon class="upload-icon"><UploadFilled /></el-icon>
            <div class="upload-text">
              <p>点击或拖拽文件到此处上传</p>
              <p class="upload-tip">支持 JSON 格式的收藏文件</p>
            </div>
          </div>
        </el-upload>
        
        <div v-if="importPreview.length > 0" class="import-preview">
          <div class="preview-header">
            <span>预览导入内容 ({{ importPreview.length }} 项)</span>
          </div>
          <div class="preview-list">
            <div
              v-for="item in importPreview"
              :key="item.path"
              class="preview-item"
            >
              <el-icon><component :is="getItemIcon(item.path)" /></el-icon>
              <span>{{ item.title }}</span>
              <el-tag size="small">{{ item.path }}</el-tag>
            </div>
          </div>
        </div>
      </div>
      
      <template #footer>
        <el-button @click="showImportDialog = false">取消</el-button>
        <el-button
          type="primary"
          :disabled="importPreview.length === 0"
          @click="confirmImport"
        >
          导入 ({{ importPreview.length }})
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Star,
  Setting,
  Close,
  Download,
  Upload,
  Search,
  Delete,
  UploadFilled,
  Monitor,
  Tickets,
  User,
  OfficeBuilding,
  Box,
  Document,
  Connection,
  List,
  ChatDotRound,
  UserFilled,
  Tools,
  Menu
} from '@element-plus/icons-vue'

const router = useRouter()

// 响应式数据
const favoritesList = ref([])
const showManageDialog = ref(false)
const showImportDialog = ref(false)
const searchKeyword = ref('')
const selectedItems = ref([])
const importPreview = ref([])
const uploadRef = ref(null)

// 路由图标映射
const routeIconMap = {
  '/workspace': 'Monitor',
  '/workspace/dashboard': 'Monitor',
  '/workspace/tasks': 'List',
  '/workspace/messages': 'ChatDotRound',
  '/tickets': 'Tickets',
  '/tickets/management': 'Tickets',
  '/tickets/dispatch': 'Connection',
  '/tickets/knowledge': 'Document',
  '/operations': 'Setting',
  '/operations/assets': 'Box',
  '/operations/monitoring': 'Monitor',
  '/ai': 'ChatDotRound',
  '/client': 'UserFilled',
  '/personnel': 'UserFilled',
  '/personnel/engineers': 'User',
  '/system': 'Tools',
  '/system/tenants': 'OfficeBuilding'
}

// 计算属性
const favoriteCount = computed(() => favoritesList.value.length)

const categorizedFavorites = computed(() => {
  const categories = {
    workspace: { name: '工作台', icon: 'Monitor', items: [] },
    tickets: { name: '工单服务', icon: 'Tickets', items: [] },
    operations: { name: '运维管理', icon: 'Setting', items: [] },
    personnel: { name: '人员管理', icon: 'UserFilled', items: [] },
    system: { name: '系统管理', icon: 'Tools', items: [] },
    other: { name: '其他', icon: 'Menu', items: [] }
  }

  favoritesList.value.forEach(item => {
    const path = item.path
    if (path.startsWith('/workspace')) {
      categories.workspace.items.push(item)
    } else if (path.startsWith('/tickets')) {
      categories.tickets.items.push(item)
    } else if (path.startsWith('/operations')) {
      categories.operations.items.push(item)
    } else if (path.startsWith('/personnel')) {
      categories.personnel.items.push(item)
    } else if (path.startsWith('/system')) {
      categories.system.items.push(item)
    } else {
      categories.other.items.push(item)
    }
  })

  return Object.values(categories).filter(category => category.items.length > 0)
})

const filteredFavorites = computed(() => {
  if (!searchKeyword.value) {
    return favoritesList.value
  }
  
  const keyword = searchKeyword.value.toLowerCase()
  return favoritesList.value.filter(item =>
    item.title.toLowerCase().includes(keyword) ||
    item.path.toLowerCase().includes(keyword)
  )
})

// 方法
const loadFavorites = () => {
  const saved = localStorage.getItem('page-favorites')
  if (saved) {
    try {
      const favoritesObj = JSON.parse(saved)
      favoritesList.value = Object.values(favoritesObj).sort((a, b) => b.timestamp - a.timestamp)
    } catch (error) {
      console.error('Failed to load favorites:', error)
      favoritesList.value = []
    }
  }
}

const saveFavorites = () => {
  const favoritesObj = {}
  favoritesList.value.forEach(item => {
    favoritesObj[item.path] = item
  })
  localStorage.setItem('page-favorites', JSON.stringify(favoritesObj))
}

const getItemIcon = (path) => {
  return routeIconMap[path] || 'Document'
}

const navigateToFavorite = (item) => {
  router.push(item.path)
  ElMessage.success(`已跳转到 ${item.title}`)
}

const removeFavorite = async (path) => {
  try {
    await ElMessageBox.confirm(
      '确定要移除这个收藏吗？',
      '确认移除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    favoritesList.value = favoritesList.value.filter(item => item.path !== path)
    saveFavorites()
    ElMessage.success('已移除收藏')
  } catch (error) {
    // 用户取消操作
  }
}

const handleVisibleChange = (visible) => {
  if (visible) {
    loadFavorites()
  }
}

const handleSelectionChange = (selection) => {
  selectedItems.value = selection
}

const batchRemoveFavorites = async () => {
  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedItems.value.length} 个收藏吗？`,
      '批量删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    const pathsToRemove = selectedItems.value.map(item => item.path)
    favoritesList.value = favoritesList.value.filter(item => !pathsToRemove.includes(item.path))
    saveFavorites()
    selectedItems.value = []
    ElMessage.success(`已删除 ${pathsToRemove.length} 个收藏`)
  } catch (error) {
    // 用户取消操作
  }
}

const exportFavorites = () => {
  if (favoritesList.value.length === 0) {
    ElMessage.warning('没有收藏可以导出')
    return
  }

  const dataStr = JSON.stringify(favoritesList.value, null, 2)
  const dataBlob = new Blob([dataStr], { type: 'application/json' })
  const url = URL.createObjectURL(dataBlob)
  
  const link = document.createElement('a')
  link.href = url
  link.download = `favorites-${new Date().toISOString().split('T')[0]}.json`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
  
  ElMessage.success('收藏已导出')
}

const handleFileChange = (file) => {
  const reader = new FileReader()
  reader.onload = (e) => {
    try {
      const data = JSON.parse(e.target.result)
      if (Array.isArray(data)) {
        importPreview.value = data.filter(item => 
          item.title && item.path && typeof item.title === 'string' && typeof item.path === 'string'
        )
      } else {
        ElMessage.error('文件格式不正确')
      }
    } catch (error) {
      ElMessage.error('文件解析失败')
    }
  }
  reader.readAsText(file.raw)
}

const confirmImport = () => {
  const existingPaths = new Set(favoritesList.value.map(item => item.path))
  const newItems = importPreview.value.filter(item => !existingPaths.has(item.path))
  
  if (newItems.length === 0) {
    ElMessage.warning('没有新的收藏可以导入')
    return
  }
  
  // 添加时间戳
  const itemsWithTimestamp = newItems.map(item => ({
    ...item,
    timestamp: Date.now()
  }))
  
  favoritesList.value.unshift(...itemsWithTimestamp)
  saveFavorites()
  
  showImportDialog.value = false
  importPreview.value = []
  ElMessage.success(`成功导入 ${newItems.length} 个收藏`)
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  const now = new Date()
  const diff = now - date
  
  if (diff < 24 * 60 * 60 * 1000) {
    return '今天'
  } else if (diff < 7 * 24 * 60 * 60 * 1000) {
    return `${Math.floor(diff / (24 * 60 * 60 * 1000))}天前`
  } else {
    return date.toLocaleDateString()
  }
}

// 生命周期
onMounted(() => {
  loadFavorites()
})

// 暴露方法给父组件
defineExpose({
  addFavorite: (item) => {
    const exists = favoritesList.value.some(fav => fav.path === item.path)
    if (!exists) {
      favoritesList.value.unshift({
        ...item,
        timestamp: Date.now()
      })
      saveFavorites()
    }
  },
  removeFavorite: (path) => {
    favoritesList.value = favoritesList.value.filter(item => item.path !== path)
    saveFavorites()
  }
})
</script>

<style scoped>
.favorites-trigger {
  background: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: white !important;
  transition: all 0.3s ease;
}

.favorites-trigger:hover {
  background: rgba(255, 255, 255, 0.2) !important;
  transform: scale(1.05);
}

.favorites-dropdown {
  width: 320px;
  max-height: 500px;
  background: var(--el-bg-color);
  border-radius: 8px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  border: 1px solid var(--el-border-color-light);
  overflow: hidden;
}

.favorites-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: var(--el-fill-color-lighter);
  border-bottom: 1px solid var(--el-border-color-lighter);
}

.header-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.favorites-content {
  max-height: 350px;
  overflow-y: auto;
}

.empty-favorites {
  padding: 40px 20px;
  text-align: center;
  color: var(--el-text-color-regular);
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.empty-favorites p {
  margin: 8px 0;
  line-height: 1.5;
}

.empty-tip {
  font-size: 12px;
  opacity: 0.7;
}

.favorite-category {
  margin-bottom: 16px;
}

.category-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px 8px;
  font-size: 12px;
  font-weight: 600;
  color: var(--el-text-color-regular);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  background: var(--el-fill-color-lighter);
}

.category-items {
  padding: 0 8px;
}

.favorite-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 8px;
  cursor: pointer;
  border-radius: 6px;
  transition: all 0.2s ease;
  margin-bottom: 2px;
}

.favorite-item:hover {
  background: var(--el-fill-color-light);
}

.item-icon {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
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
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-path {
  font-size: 11px;
  color: var(--el-text-color-placeholder);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-actions {
  flex-shrink: 0;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.favorite-item:hover .item-actions {
  opacity: 1;
}

.remove-btn {
  padding: 2px 4px !important;
  min-height: auto !important;
  color: var(--el-color-danger);
}

.favorites-footer {
  display: flex;
  justify-content: space-around;
  padding: 12px 16px;
  background: var(--el-fill-color-lighter);
  border-top: 1px solid var(--el-border-color-lighter);
}

.footer-action {
  font-size: 12px;
  color: var(--el-text-color-regular);
}

.footer-action:hover {
  color: var(--el-color-primary);
}

/* 管理对话框样式 */
.manage-content {
  padding: 0;
}

.manage-header {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
  align-items: center;
}

.search-input {
  flex: 1;
}

.manage-list {
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 6px;
  overflow: hidden;
}

.table-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 导入对话框样式 */
.import-content {
  padding: 0;
}

.upload-area {
  padding: 40px 20px;
  text-align: center;
  color: var(--el-text-color-regular);
}

.upload-icon {
  font-size: 48px;
  margin-bottom: 16px;
  color: var(--el-color-primary);
}

.upload-text p {
  margin: 8px 0;
  line-height: 1.5;
}

.upload-tip {
  font-size: 12px;
  opacity: 0.7;
}

.import-preview {
  margin-top: 20px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 6px;
  overflow: hidden;
}

.preview-header {
  padding: 12px 16px;
  background: var(--el-fill-color-lighter);
  border-bottom: 1px solid var(--el-border-color-lighter);
  font-weight: 600;
  font-size: 14px;
}

.preview-list {
  max-height: 200px;
  overflow-y: auto;
  padding: 8px;
}

.preview-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  border-radius: 4px;
  margin-bottom: 4px;
  background: var(--el-fill-color-lighter);
}

.preview-item:last-child {
  margin-bottom: 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .favorites-dropdown {
    width: 280px;
  }
  
  .manage-header {
    flex-direction: column;
    align-items: stretch;
  }
}

/* 深色模式适配 */
[data-theme="dark"] .favorites-dropdown {
  background: var(--el-bg-color);
  border-color: var(--el-border-color);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

/* 滚动条样式 */
.favorites-content::-webkit-scrollbar,
.preview-list::-webkit-scrollbar {
  width: 6px;
}

.favorites-content::-webkit-scrollbar-track,
.preview-list::-webkit-scrollbar-track {
  background: var(--el-fill-color-lighter);
}

.favorites-content::-webkit-scrollbar-thumb,
.preview-list::-webkit-scrollbar-thumb {
  background: var(--el-border-color);
  border-radius: 3px;
}

.favorites-content::-webkit-scrollbar-thumb:hover,
.preview-list::-webkit-scrollbar-thumb:hover {
  background: var(--el-border-color-dark);
}
</style>