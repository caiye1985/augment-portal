<template>
  <div class="professional-page-layout">
    <!-- 专业页面头部 -->
    <div class="professional-header" v-if="showHeader">
      <div class="header-content">
        <div class="header-main">
          <div class="header-icon" v-if="icon">
            <el-icon :size="32">
              <component :is="icon" />
            </el-icon>
          </div>
          <div class="header-text">
            <h1 class="header-title">{{ title }}</h1>
            <p class="header-description" v-if="description">{{ description }}</p>
          </div>
        </div>
        <div class="header-actions" v-if="$slots.actions">
          <slot name="actions"></slot>
        </div>
      </div>
      <div class="header-stats" v-if="stats && stats.length > 0">
        <div class="stat-item" v-for="stat in stats" :key="stat.label">
          <div class="stat-value">{{ stat.value }}</div>
          <div class="stat-label">{{ stat.label }}</div>
        </div>
      </div>
    </div>

    <!-- 专业导航栏 -->
    <div class="professional-nav" v-if="navItems && navItems.length > 0">
      <el-tabs v-model="activeTab" @tab-click="handleTabClick" class="professional-tabs">
        <el-tab-pane 
          v-for="item in navItems" 
          :key="item.name"
          :label="item.label" 
          :name="item.name"
        >
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- 主要内容区域 -->
    <div class="professional-content">
      <slot></slot>
    </div>

    <!-- 专业页脚 -->
    <div class="professional-footer" v-if="showFooter">
      <slot name="footer">
        <div class="footer-content">
          <div class="footer-info">
            <span class="footer-text">{{ footerText || '智能运维管理平台' }}</span>
            <span class="footer-version">v{{ version || '1.0.0' }}</span>
          </div>
          <div class="footer-actions" v-if="$slots.footerActions">
            <slot name="footerActions"></slot>
          </div>
        </div>
      </slot>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

// Props定义
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
  stats: {
    type: Array,
    default: () => []
  },
  navItems: {
    type: Array,
    default: () => []
  },
  showHeader: {
    type: Boolean,
    default: true
  },
  showFooter: {
    type: Boolean,
    default: false
  },
  footerText: {
    type: String,
    default: ''
  },
  version: {
    type: String,
    default: ''
  }
})

// Emits定义
const emit = defineEmits(['tab-change'])

// 响应式数据
const activeTab = ref(props.navItems.length > 0 ? props.navItems[0].name : '')

// 计算属性
const hasStats = computed(() => props.stats && props.stats.length > 0)

// 方法
const handleTabClick = (tab) => {
  activeTab.value = tab.name
  emit('tab-change', tab.name)
}
</script>

<style scoped>
.professional-page-layout {
  min-height: 100vh;
  background: var(--bg-primary);
  color: var(--text-primary);
  padding: 24px;
  display: flex;
  flex-direction: column;
}

/* 专业页面头部 */
.professional-header {
  background: var(--gradient-bg);
  border-radius: 16px;
  padding: 32px;
  margin-bottom: 24px;
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--border-secondary);
  position: relative;
  overflow: hidden;
}

.professional-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: var(--gradient-button);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
}

.header-main {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-icon {
  width: 64px;
  height: 64px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-inverse);
  backdrop-filter: blur(10px);
}

.header-text {
  flex: 1;
}

.header-title {
  font-size: 32px;
  font-weight: 700;
  color: var(--text-inverse);
  margin: 0 0 8px 0;
  line-height: 1.2;
}

.header-description {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
  line-height: 1.5;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.header-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 24px;
  padding-top: 24px;
  border-top: 1px solid rgba(255, 255, 255, 0.2);
}

.stat-item {
  text-align: center;
  padding: 16px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  backdrop-filter: blur(10px);
  transition: var(--transition-base);
}

.stat-item:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-inverse);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.8);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 500;
}

/* 专业导航栏 */
.professional-nav {
  background: var(--bg-card);
  border-radius: 12px;
  padding: 0;
  margin-bottom: 24px;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border-primary);
  overflow: hidden;
}

.professional-tabs {
  background: transparent;
}

.professional-tabs :deep(.el-tabs__header) {
  background: var(--bg-tertiary);
  margin: 0;
  border-bottom: 1px solid var(--border-primary);
}

.professional-tabs :deep(.el-tabs__nav-wrap) {
  padding: 0 24px;
}

.professional-tabs :deep(.el-tabs__item) {
  color: var(--text-secondary);
  font-weight: 500;
  padding: 16px 24px;
  transition: var(--transition-fast);
  border-radius: 8px 8px 0 0;
  margin-right: 4px;
}

.professional-tabs :deep(.el-tabs__item:hover) {
  color: var(--text-primary);
  background: var(--bg-hover);
}

.professional-tabs :deep(.el-tabs__item.is-active) {
  color: var(--primary-color);
  background: var(--bg-card);
  font-weight: 600;
}

.professional-tabs :deep(.el-tabs__active-bar) {
  background: var(--primary-color);
  height: 3px;
}

/* 主要内容区域 */
.professional-content {
  flex: 1;
  background: var(--bg-card);
  border-radius: 12px;
  padding: 32px;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border-primary);
  min-height: 400px;
}

/* 专业页脚 */
.professional-footer {
  background: var(--bg-secondary);
  border-radius: 12px;
  padding: 20px 32px;
  margin-top: 24px;
  border: 1px solid var(--border-primary);
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.footer-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.footer-text {
  color: var(--text-secondary);
  font-size: 14px;
}

.footer-version {
  color: var(--text-tertiary);
  font-size: 12px;
  background: var(--bg-tertiary);
  padding: 4px 8px;
  border-radius: 4px;
  font-family: monospace;
}

.footer-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .professional-page-layout {
    padding: 16px;
  }
  
  .professional-header {
    padding: 24px;
  }
  
  .header-content {
    flex-direction: column;
    gap: 16px;
  }
  
  .header-main {
    flex-direction: column;
    text-align: center;
  }
  
  .header-title {
    font-size: 24px;
  }
  
  .header-stats {
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: 16px;
  }
  
  .professional-content {
    padding: 20px;
  }
  
  .footer-content {
    flex-direction: column;
    gap: 12px;
    text-align: center;
  }
}

@media (max-width: 480px) {
  .header-stats {
    grid-template-columns: 1fr 1fr;
  }
  
  .stat-value {
    font-size: 24px;
  }
  
  .professional-tabs :deep(.el-tabs__nav-wrap) {
    padding: 0 16px;
  }
  
  .professional-tabs :deep(.el-tabs__item) {
    padding: 12px 16px;
    font-size: 14px;
  }
}
</style>
