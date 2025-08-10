<template>
  <div class="page-layout">
    <!-- 增强的面包屑导航（集成页面信息） -->
    <!-- :page-title="title" -->

    <BreadcrumbNav
      :show-quick-nav="showQuickNav"
      :custom-breadcrumbs="customBreadcrumbs"
      :page-actions="pageActions"
      :page-description="description"
      :page-icon="icon"
      :page-tags="tags"
      :show-page-info="showPageInfo"
      @action-click="handleBreadcrumbAction"
      @refresh="handleRefresh"
      @favorite-toggle="handleFavoriteToggle"
      @page-action="handlePageAction"
    />

    <!-- 页面提示信息（独立显示） -->
    <div v-if="showTips && tips.length > 0" class="page-tips-container">
      <el-alert
        v-for="(tip, index) in tips"
        :key="index"
        :title="tip.title"
        :description="tip.description"
        :type="tip.type || 'info'"
        :closable="tip.closable !== false"
        show-icon
        class="page-tip"
      />
    </div>

    <!-- 中间区域：统计数据展示 -->
    <div v-if="$slots.stats" class="stats-container" :class="{ 'stats-collapsed': statsCollapsed }">
      <div class="stats-header">
        <h3 class="stats-title">数据概览</h3>
        <el-button 
          text 
          @click="toggleStats" 
          class="collapse-btn"
          :icon="statsCollapsed ? 'ArrowDown' : 'ArrowUp'"
        >
          {{ statsCollapsed ? '展开' : '收起' }}
        </el-button>
      </div>
      <div class="stats-content" v-show="!statsCollapsed">
        <slot name="stats"></slot>
      </div>
    </div>

    <!-- 筛选区域（可选） -->
    <div v-if="$slots.filters" class="filters-container">
      <el-card shadow="never" class="filter-card">
        <slot name="filters"></slot>
      </el-card>
    </div>

    <!-- 底部区域：主要内容 -->
    <div class="content-container">
      <slot name="content"></slot>
      <slot></slot> <!-- 默认插槽，向后兼容 -->
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import BreadcrumbNav from './BreadcrumbNav.vue'

// Props
const props = defineProps({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  },
  icon: {
    type: String,
    default: ''
  },
  padding: {
    type: String,
    default: '20px',
    validator: (value) => {
      // 验证padding值格式
      return /^\d+(px|rem|em|%)(\s+\d+(px|rem|em|%))*$/.test(value)
    }
  },
  background: {
    type: String,
    default: 'var(--bg-page, #f5f5f5)'
  },
  statsCollapsible: {
    type: Boolean,
    default: true
  },
  showQuickNav: {
    type: Boolean,
    default: true
  },
  customBreadcrumbs: {
    type: Array,
    default: () => []
  },
  tags: {
    type: Array,
    default: () => []
  },
  tips: {
    type: Array,
    default: () => []
  },
  showTips: {
    type: Boolean,
    default: true
  },
  showPageInfo: {
    type: Boolean,
    default: true
  },
  pageActions: {
    type: Array,
    default: () => []
  }
})

// Emits
const emit = defineEmits(['breadcrumb-action', 'refresh', 'favorite-toggle', 'page-action'])

// 响应式数据
const statsCollapsed = ref(false)

// 方法
const toggleStats = () => {
  statsCollapsed.value = !statsCollapsed.value
  // 持久化保存状态
  localStorage.setItem('page-layout-stats-collapsed', statsCollapsed.value.toString())
}

// 面包屑相关方法
const handleBreadcrumbAction = (action) => {
  emit('breadcrumb-action', action)
}

const handleRefresh = () => {
  emit('refresh')
}

const handleFavoriteToggle = (data) => {
  emit('favorite-toggle', data)
}

const handlePageAction = (actionKey) => {
  emit('page-action', actionKey)
}

// 生命周期
onMounted(() => {
  // 从localStorage恢复折叠状态
  const saved = localStorage.getItem('page-layout-stats-collapsed')
  if (saved !== null) {
    statsCollapsed.value = saved === 'true'
  }
})
</script>

<style scoped>
.page-layout {
  padding: v-bind(padding);
  background: v-bind(background);
  min-height: calc(100vh - 60px);
}

/* 页面提示信息容器 */
.page-tips-container {
  margin-bottom: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.page-tip {
  border-radius: 6px;
  font-size: 13px;
}

/* 统计数据容器样式 */
.stats-container {
  margin-bottom: 20px;
  background: var(--el-bg-color, #ffffff);
  border-radius: 8px;
  box-shadow: var(--el-box-shadow-lighter, 0 1px 2px 0 rgb(0 0 0 / 0.05));
  border: 1px solid var(--el-border-color-light, #f1f5f9);
  transition: all 0.3s ease;
  overflow: hidden;
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid var(--el-border-color-lighter, #f1f5f9);
  background: var(--el-fill-color-lighter, #fafafa);
}

.stats-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary, #303133);
}

.collapse-btn {
  font-size: 14px;
}

.stats-content {
  padding: 20px;
  transition: all 0.3s ease;
}

.stats-collapsed .stats-content {
  padding: 0;
  height: 0;
  overflow: hidden;
}

/* 筛选区域样式 */
.filters-container {
  margin-bottom: 20px;
}

.filter-card {
  border: 1px solid var(--el-border-color-light, #f1f5f9);
  box-shadow: var(--el-box-shadow-lighter, 0 1px 2px 0 rgb(0 0 0 / 0.05));
  transition: all 0.3s ease;
}

/* 内容容器样式 */
.content-container {
  flex: 1;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-layout {
    padding: 12px;
  }
  
  .stats-header {
    padding: 12px 16px;
  }
  
  .stats-content {
    padding: 16px;
  }
}

@media (max-width: 480px) {
  .page-layout {
    padding: 8px;
  }
}

/* 深色模式适配 */
[data-theme="dark"] {
  .page-header,
  .stats-container,
  .filter-card {
    background: var(--el-bg-color, #2d2d2d);
    border-color: var(--el-border-color, #4c4d4f);
    box-shadow: var(--el-box-shadow-dark, 0 2px 4px rgba(0, 0, 0, 0.3));
  }
  
  .stats-header {
    background: var(--el-fill-color, #3a3a3a);
    border-color: var(--el-border-color, #4c4d4f);
  }
}

/* 系统深色模式偏好适配 */
@media (prefers-color-scheme: dark) {
  .page-header,
  .stats-container,
  .filter-card {
    border-color: var(--el-border-color, #334155);
  }
}

/* 主题切换过渡效果 */
.page-header,
.stats-container,
.filter-card {
  transition: background-color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease;
}

.page-title,
.page-description,
.stats-title {
  transition: color 0.3s ease;
}
</style>
