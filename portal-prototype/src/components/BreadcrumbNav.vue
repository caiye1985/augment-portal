<template>
  <div class="breadcrumb-nav">
    <!-- 左侧区域：面包屑导航 + 页面信息 -->
    <div class="nav-left">
      <!-- 面包屑导航 -->
      <el-breadcrumb separator="/" class="custom-breadcrumb">
        <el-breadcrumb-item
          v-for="(item, index) in breadcrumbItems"
          :key="index"
          :to="item.path && index < breadcrumbItems.length - 1 ? item.path : undefined"
          :class="{ 'is-current': index === breadcrumbItems.length - 1 }"
        >
          <div class="breadcrumb-item-content">
            <el-icon v-if="item.icon" class="breadcrumb-icon">
              <component :is="item.icon" />
            </el-icon>
            <span class="breadcrumb-text">{{ item.title }}</span>
            
            <!-- 当前页面的操作菜单 -->
            <el-dropdown
              v-if="index === breadcrumbItems.length - 1 && item.actions && item.actions.length > 0"
              trigger="click"
              @command="handleActionCommand"
              class="breadcrumb-actions"
            >
              <el-button text size="small" class="action-trigger">
                <el-icon><MoreFilled /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item
                    v-for="action in item.actions"
                    :key="action.key"
                    :command="action.key"
                    :disabled="action.disabled"
                  >
                    <el-icon v-if="action.icon">
                      <component :is="action.icon" />
                    </el-icon>
                    {{ action.label }}
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </el-breadcrumb-item>
      </el-breadcrumb>

      <!-- 页面信息区域 -->
      <div v-if="showPageInfo && (pageTitle || pageDescription || pageTags.length > 0)" class="page-info">
        <!-- 页面标题和图标 -->
        <div v-if="pageTitle" class="page-title-section">
          <div class="page-title-content">
            <el-icon v-if="pageIcon" class="page-title-icon">
              <component :is="pageIcon" />
            </el-icon>
            <span class="page-title-text">{{ pageTitle }}</span>
            
            <!-- 页面标签 -->
            <div v-if="pageTags.length > 0" class="page-tags-inline">
              <el-tag
                v-for="tag in pageTags"
                :key="tag.text"
                :type="tag.type || 'info'"
                size="small"
                class="page-tag-inline"
              >
                {{ tag.text }}
              </el-tag>
            </div>
          </div>
        </div>
        
        <!-- 页面描述 -->
        <div v-if="pageDescription" class="page-description-inline">
          {{ pageDescription }}
        </div>
      </div>
    </div>

    <!-- 页面操作区域 -->
    <div class="page-actions">
      <!-- 页面主要操作按钮 -->
      <div v-if="pageActions && pageActions.length > 0" class="primary-actions">
        <el-button
          v-for="action in pageActions.slice(0, 3)"
          :key="action.key"
          :type="action.type || 'default'"
          :icon="action.icon"
          size="small"
          @click="handlePageAction(action.key)"
          class="action-btn"
        >
          {{ action.label }}
        </el-button>
        
        <!-- 更多操作下拉菜单 -->
        <el-dropdown
          v-if="pageActions.length > 3"
          trigger="click"
          @command="handlePageAction"
          class="more-actions"
        >
          <el-button size="small" class="action-btn">
            更多
            <el-icon class="el-icon--right"><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item
                v-for="action in pageActions.slice(3)"
                :key="action.key"
                :command="action.key"
                :disabled="action.disabled"
              >
                <el-icon v-if="action.icon">
                  <component :is="action.icon" />
                </el-icon>
                {{ action.label }}
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>

      <!-- 快速导航按钮 -->
      <div v-if="showQuickNav" class="quick-nav">
        <el-tooltip content="返回上级" placement="bottom">
          <el-button
            circle
            size="small"
            :disabled="breadcrumbItems.length <= 1"
            @click="goBack"
            class="quick-nav-btn"
          >
            <el-icon><ArrowLeft /></el-icon>
          </el-button>
        </el-tooltip>
        
        <el-tooltip content="刷新当前页面" placement="bottom">
          <el-button
            circle
            size="small"
            @click="refreshPage"
            class="quick-nav-btn"
          >
            <el-icon><Refresh /></el-icon>
          </el-button>
        </el-tooltip>

        <el-tooltip content="收藏当前页面" placement="bottom">
          <el-button
            circle
            size="small"
            :type="isCurrentPageFavorited ? 'primary' : 'default'"
            @click="toggleFavorite"
            class="quick-nav-btn"
          >
            <el-icon><Star /></el-icon>
          </el-button>
        </el-tooltip>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { 
  ArrowLeft, 
  Refresh, 
  Star, 
  MoreFilled,
  ArrowDown,
  Monitor,
  Tickets,
  User,
  Setting,
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

const route = useRoute()
const router = useRouter()

const props = defineProps({
  showQuickNav: {
    type: Boolean,
    default: true
  },
  customBreadcrumbs: {
    type: Array,
    default: () => []
  },
  pageActions: {
    type: Array,
    default: () => []
  },
  pageTitle: {
    type: String,
    default: ''
  },
  pageDescription: {
    type: String,
    default: ''
  },
  pageIcon: {
    type: String,
    default: ''
  },
  pageTags: {
    type: Array,
    default: () => []
  },
  showPageInfo: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['action-click', 'refresh', 'favorite-toggle', 'page-action'])

// 响应式数据
const isCurrentPageFavorited = ref(false)

// 路由到图标的映射
const routeIconMap = {
  '/workspace': 'Monitor',
  '/workspace/dashboard': 'Monitor',
  '/workspace/tasks': 'List',
  '/workspace/messages': 'ChatDotRound',
  '/tickets': 'Tickets',
  '/tickets/management': 'Tickets',
  '/tickets/dispatch': 'Connection',
  '/tickets/knowledge': 'Document',
  '/tickets/categories': 'Menu',
  '/operations': 'Setting',
  '/operations/assets': 'Box',
  '/operations/monitoring': 'Monitor',
  '/operations/automation': 'Setting',
  '/operations/integration': 'Document',
  '/ai': 'ChatDotRound',
  '/ai/analysis': 'ChatDotRound',
  '/client': 'UserFilled',
  '/client/management': 'OfficeBuilding',
  '/personnel': 'UserFilled',
  '/personnel/engineers': 'User',
  '/personnel/skills': 'Medal',
  '/personnel/training': 'Reading',
  '/personnel/schedule': 'Calendar',
  '/personnel/performance': 'TrendCharts',
  '/system': 'Tools',
  '/system/tenants': 'OfficeBuilding',
  '/system/sites': 'OfficeBuilding',
  '/system/departments': 'Coordinate',
  '/system/users': 'User',
  '/system/system-config': 'Setting'
}

// 路由到标题的映射
const routeTitleMap = {
  '/workspace': '工作台',
  '/workspace/dashboard': '运维仪表板',
  '/workspace/tasks': '我的任务',
  '/workspace/messages': '我的消息',
  '/tickets': '工单服务',
  '/tickets/management': '工单管理',
  '/tickets/dispatch': '智能派单',
  '/tickets/knowledge': '知识库',
  '/tickets/categories': '分类管理',
  '/operations': '运维管理',
  '/operations/assets': '资产管理',
  '/operations/monitoring': '监控系统',
  '/operations/automation': '自动化平台',
  '/operations/integration': '任务日志',
  '/ai': '智能分析',
  '/ai/analysis': 'AI智能分析',
  '/client': '甲方服务',
  '/client/management': '甲方管理',
  '/personnel': '人员管理',
  '/personnel/engineers': '工程师管理',
  '/personnel/skills': '技能管理',
  '/personnel/training': '培训管理',
  '/personnel/schedule': '排班管理',
  '/personnel/performance': '绩效管理',
  '/system': '系统管理',
  '/system/tenants': '租户管理',
  '/system/sites': '站点总览',
  '/system/departments': '部门管理',
  '/system/users': '用户管理',
  '/system/system-config': '系统配置'
}

// 计算面包屑项目
const breadcrumbItems = computed(() => {
  if (props.customBreadcrumbs.length > 0) {
    return props.customBreadcrumbs
  }

  const pathSegments = route.path.split('/').filter(Boolean)
  const items = []
  let currentPath = ''

  // 添加首页
  items.push({
    title: '首页',
    path: '/',
    icon: 'House'
  })

  // 构建面包屑路径
  pathSegments.forEach((segment, index) => {
    currentPath += '/' + segment
    const title = routeTitleMap[currentPath] || segment
    const icon = routeIconMap[currentPath]
    
    items.push({
      title,
      path: currentPath,
      icon,
      actions: index === pathSegments.length - 1 ? getCurrentPageActions() : undefined
    })
  })

  return items
})

// 获取当前页面的操作菜单
const getCurrentPageActions = () => {
  const currentPath = route.path
  const actions = []

  // 根据不同页面返回不同的操作
  if (currentPath.includes('/tickets')) {
    actions.push(
      { key: 'create', label: '新建工单', icon: 'Plus' },
      { key: 'export', label: '导出数据', icon: 'Download' },
      { key: 'settings', label: '页面设置', icon: 'Setting' }
    )
  } else if (currentPath.includes('/personnel')) {
    actions.push(
      { key: 'add', label: '添加人员', icon: 'Plus' },
      { key: 'import', label: '批量导入', icon: 'Upload' },
      { key: 'export', label: '导出数据', icon: 'Download' }
    )
  } else if (currentPath.includes('/dashboard')) {
    actions.push(
      { key: 'refresh', label: '刷新数据', icon: 'Refresh' },
      { key: 'customize', label: '自定义布局', icon: 'Setting' },
      { key: 'export', label: '导出报告', icon: 'Download' }
    )
  }

  // 通用操作
  actions.push(
    { key: 'help', label: '页面帮助', icon: 'QuestionFilled' }
  )

  return actions
}

// 方法
const goBack = () => {
  if (breadcrumbItems.value.length > 1) {
    const previousItem = breadcrumbItems.value[breadcrumbItems.value.length - 2]
    if (previousItem.path) {
      router.push(previousItem.path)
    } else {
      router.go(-1)
    }
  }
}

const refreshPage = () => {
  emit('refresh')
  ElMessage.success('页面已刷新')
  // 可以在这里添加页面刷新逻辑
  window.location.reload()
}

const toggleFavorite = () => {
  isCurrentPageFavorited.value = !isCurrentPageFavorited.value
  emit('favorite-toggle', {
    path: route.path,
    title: breadcrumbItems.value[breadcrumbItems.value.length - 1]?.title,
    favorited: isCurrentPageFavorited.value
  })
  
  const message = isCurrentPageFavorited.value ? '已添加到收藏' : '已从收藏中移除'
  ElMessage.success(message)
  
  // 保存到本地存储
  saveFavoriteStatus()
}

const handleActionCommand = (command) => {
  emit('action-click', command)
  
  // 默认处理一些通用操作
  switch (command) {
    case 'refresh':
      refreshPage()
      break
    case 'help':
      ElMessage.info('帮助功能开发中...')
      break
    default:
      ElMessage.info(`执行操作: ${command}`)
  }
}

const handlePageAction = (actionKey) => {
  emit('page-action', actionKey)
}

const saveFavoriteStatus = () => {
  const favorites = JSON.parse(localStorage.getItem('page-favorites') || '{}')
  if (isCurrentPageFavorited.value) {
    favorites[route.path] = {
      title: breadcrumbItems.value[breadcrumbItems.value.length - 1]?.title,
      path: route.path,
      timestamp: Date.now()
    }
  } else {
    delete favorites[route.path]
  }
  localStorage.setItem('page-favorites', JSON.stringify(favorites))
}

const loadFavoriteStatus = () => {
  const favorites = JSON.parse(localStorage.getItem('page-favorites') || '{}')
  isCurrentPageFavorited.value = !!favorites[route.path]
}

// 监听路由变化
watch(() => route.path, () => {
  loadFavoriteStatus()
}, { immediate: true })
</script>

<style scoped>
.breadcrumb-nav {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 12px 16px;
  margin-bottom: 16px;
  background: var(--el-bg-color);
  border-radius: 8px;
  border: 1px solid var(--el-border-color-lighter);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
  min-height: 48px;
}

.nav-left {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.custom-breadcrumb {
  flex-shrink: 0;
}

/* 页面信息区域 */
.page-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-left: 4px;
}

.page-title-section {
  display: flex;
  align-items: center;
}

.page-title-content {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.page-title-icon {
  font-size: 16px;
  color: var(--el-color-primary);
  flex-shrink: 0;
}

.page-title-text {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  line-height: 1.2;
}

.page-tags-inline {
  display: flex;
  gap: 6px;
  align-items: center;
  flex-wrap: wrap;
}

.page-tag-inline {
  font-size: 11px;
  height: 18px;
  line-height: 16px;
  padding: 0 6px;
}

.page-description-inline {
  font-size: 12px;
  color: var(--el-text-color-regular);
  line-height: 1.3;
  margin-left: 24px; /* 对齐图标后的位置 */
}

.breadcrumb-item-content {
  display: flex;
  align-items: center;
  gap: 6px;
}

.breadcrumb-icon {
  font-size: 14px;
  color: var(--el-color-primary);
}

.breadcrumb-text {
  font-size: 14px;
}

.breadcrumb-actions {
  margin-left: 8px;
}

.action-trigger {
  padding: 2px 4px !important;
  min-height: auto !important;
  color: var(--el-text-color-regular);
}

.action-trigger:hover {
  color: var(--el-color-primary);
}

/* 自定义面包屑样式 */
.custom-breadcrumb :deep(.el-breadcrumb__item) {
  font-size: 14px;
}

.custom-breadcrumb :deep(.el-breadcrumb__item:not(:last-child)) {
  color: var(--el-text-color-regular);
  cursor: pointer;
  transition: color 0.3s ease;
}

.custom-breadcrumb :deep(.el-breadcrumb__item:not(:last-child):hover) {
  color: var(--el-color-primary);
}

.custom-breadcrumb :deep(.el-breadcrumb__item.is-current) {
  color: var(--el-text-color-primary);
  font-weight: 500;
}

.custom-breadcrumb :deep(.el-breadcrumb__separator) {
  color: var(--el-text-color-placeholder);
  margin: 0 8px;
}

/* 页面操作区域 */
.page-actions {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  flex-shrink: 0;
  margin-top: 2px; /* 微调对齐 */
}

.primary-actions {
  display: flex;
  align-items: center;
  gap: 8px;
}

.action-btn {
  height: 32px;
  padding: 0 12px;
  font-size: 13px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.more-actions {
  margin-left: 4px;
}

.quick-nav {
  display: flex;
  align-items: center;
  gap: 6px;
  padding-left: 12px;
  border-left: 1px solid var(--el-border-color-lighter);
}

.quick-nav-btn {
  width: 28px;
  height: 28px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color);
  color: var(--el-text-color-regular);
  transition: all 0.3s ease;
}

.quick-nav-btn:hover:not(:disabled) {
  border-color: var(--el-color-primary);
  color: var(--el-color-primary);
  transform: translateY(-1px);
}

.quick-nav-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.quick-nav-btn.el-button--primary {
  background: var(--el-color-primary);
  border-color: var(--el-color-primary);
  color: white;
}

.quick-nav-btn.el-button--primary:hover {
  background: var(--el-color-primary-light-3);
  border-color: var(--el-color-primary-light-3);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .breadcrumb-nav {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
    padding: 12px;
  }
  
  .nav-left {
    gap: 6px;
  }
  
  .page-actions {
    justify-content: space-between;
    border-top: 1px solid var(--el-border-color-lighter);
    padding-top: 12px;
    margin-top: 0;
  }
  
  .primary-actions {
    flex: 1;
    justify-content: flex-start;
  }
  
  .quick-nav {
    border-left: none;
    padding-left: 0;
  }
  
  .breadcrumb-text {
    font-size: 13px;
  }
  
  .breadcrumb-icon {
    font-size: 13px;
  }
  
  .action-btn {
    font-size: 12px;
    padding: 0 8px;
    height: 28px;
  }
  
  .page-title-text {
    font-size: 14px;
  }
  
  .page-title-icon {
    font-size: 14px;
  }
  
  .page-description-inline {
    font-size: 11px;
    margin-left: 18px;
  }
  
  .page-tags-inline {
    gap: 4px;
  }
  
  .page-tag-inline {
    font-size: 10px;
    height: 16px;
    line-height: 14px;
    padding: 0 4px;
  }
}

@media (max-width: 480px) {
  .custom-breadcrumb :deep(.el-breadcrumb__item:not(:last-child):not(:first-child)) {
    display: none;
  }
  
  .custom-breadcrumb :deep(.el-breadcrumb__item:nth-last-child(2)::after) {
    content: '...';
    margin: 0 8px;
    color: var(--el-text-color-placeholder);
  }
}

/* 深色模式适配 */
[data-theme="dark"] .breadcrumb-nav {
  background: var(--el-bg-color);
  border-color: var(--el-border-color);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

[data-theme="dark"] .quick-nav {
  border-color: var(--el-border-color);
}

[data-theme="dark"] .quick-nav-btn {
  background: var(--el-bg-color);
  border-color: var(--el-border-color);
}

/* 动画效果 */
.breadcrumb-nav {
  animation: slideInDown 0.3s ease-out;
}

@keyframes slideInDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 面包屑项目的悬停效果 */
.custom-breadcrumb :deep(.el-breadcrumb__item:not(:last-child)) {
  position: relative;
}

.custom-breadcrumb :deep(.el-breadcrumb__item:not(:last-child)::before) {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 2px;
  background: var(--el-color-primary);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.custom-breadcrumb :deep(.el-breadcrumb__item:not(:last-child):hover::before) {
  transform: scaleX(1);
}
</style>