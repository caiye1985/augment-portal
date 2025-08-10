<template>
  <el-card class="stat-card" shadow="never" :class="[`stat-card--${size}`, { 'stat-card--clickable': clickable }]" @click="handleClick">
    <div class="stat-content">
      <!-- 图标区域 -->
      <div class="stat-icon" v-if="icon || $slots.icon">
        <slot name="icon">
          <el-icon :size="iconSize" :color="iconColor">
            <component :is="icon" />
          </el-icon>
        </slot>
      </div>
      
      <!-- 信息区域 -->
      <div class="stat-info">
        <div class="stat-value" :style="{ color: valueColor }">
          {{ formattedValue }}
          <span v-if="unit" class="stat-unit">{{ unit }}</span>
        </div>
        <div class="stat-label">{{ label }}</div>
        
        <!-- 趋势指示器 -->
        <div v-if="trend !== null && trend !== undefined" class="stat-trend">
          <el-icon :color="trendColor" class="trend-icon">
            <component :is="trendIcon" />
          </el-icon>
          <span :style="{ color: trendColor }" class="trend-text">
            {{ Math.abs(trend) }}%
          </span>
          <span class="trend-label">{{ trendLabel }}</span>
        </div>
        
        <!-- 额外信息 -->
        <div v-if="extra" class="stat-extra">{{ extra }}</div>
      </div>
      
      <!-- 操作区域 -->
      <div v-if="$slots.actions" class="stat-actions">
        <slot name="actions"></slot>
      </div>
    </div>
    
    <!-- 加载状态 -->
    <div v-if="loading" class="stat-loading">
      <el-icon class="is-loading">
        <Loading />
      </el-icon>
    </div>
  </el-card>
</template>

<script setup>
import { computed, defineProps, defineEmits } from 'vue'

// Props
const props = defineProps({
  label: {
    type: String,
    required: true
  },
  value: {
    type: [Number, String],
    required: true
  },
  unit: {
    type: String,
    default: ''
  },
  icon: {
    type: String,
    default: ''
  },
  iconColor: {
    type: String,
    default: 'var(--el-color-primary, #6366f1)'
  },
  valueColor: {
    type: String,
    default: 'var(--el-text-color-primary, #1e293b)'
  },
  trend: {
    type: Number,
    default: null
  },
  trendLabel: {
    type: String,
    default: '较上期'
  },
  extra: {
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'default',
    validator: (value) => ['small', 'default', 'large'].includes(value)
  },
  loading: {
    type: Boolean,
    default: false
  },
  clickable: {
    type: Boolean,
    default: false
  },
  precision: {
    type: Number,
    default: 0
  }
})

// Emits
const emit = defineEmits(['click'])

// 计算属性
const iconSize = computed(() => {
  const sizeMap = {
    small: 24,
    default: 32,
    large: 40
  }
  return sizeMap[props.size]
})

const formattedValue = computed(() => {
  if (typeof props.value === 'number') {
    if (props.precision > 0) {
      return props.value.toFixed(props.precision)
    }
    return props.value.toLocaleString()
  }
  return props.value
})

const trendIcon = computed(() => {
  if (props.trend > 0) return 'TrendCharts'
  if (props.trend < 0) return 'TrendCharts'
  return 'Minus'
})

const trendColor = computed(() => {
  if (props.trend > 0) return 'var(--el-color-success, #10b981)'
  if (props.trend < 0) return 'var(--el-color-error, #ef4444)'
  return 'var(--el-text-color-placeholder, #94a3b8)'
})

// 方法
const handleClick = () => {
  if (props.clickable) {
    emit('click')
  }
}
</script>

<style scoped>
.stat-card {
  border: 1px solid var(--el-border-color-light, #f1f5f9);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.stat-card:hover {
  box-shadow: var(--el-box-shadow, 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1));
  transform: translateY(-2px);
}

.stat-card--clickable {
  cursor: pointer;
}

.stat-card--clickable:hover {
  border-color: var(--el-color-primary, #6366f1);
}

.stat-content {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  position: relative;
}

/* 图标样式 */
.stat-icon {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
  border-radius: 12px;
  background: var(--el-fill-color-lighter, #f1f5f9);
  transition: background-color 0.3s ease;
}

.stat-card--small .stat-icon {
  width: 48px;
  height: 48px;
}

.stat-card--large .stat-icon {
  width: 72px;
  height: 72px;
}

/* 信息区域样式 */
.stat-info {
  flex: 1;
  min-width: 0;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  line-height: 1;
  margin-bottom: 4px;
  display: flex;
  align-items: baseline;
  gap: 4px;
  transition: color 0.3s ease;
}

.stat-card--small .stat-value {
  font-size: 24px;
}

.stat-card--large .stat-value {
  font-size: 32px;
}

.stat-unit {
  font-size: 0.6em;
  font-weight: 500;
  color: var(--el-text-color-regular, #64748b);
}

.stat-label {
  font-size: 14px;
  color: var(--el-text-color-regular, #64748b);
  margin-bottom: 4px;
  font-weight: 500;
  transition: color 0.3s ease;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 500;
}

.trend-icon {
  font-size: 14px;
}

.trend-text {
  font-weight: 600;
}

.trend-label {
  color: var(--el-text-color-placeholder, #94a3b8);
}

.stat-extra {
  font-size: 12px;
  color: var(--el-text-color-placeholder, #94a3b8);
  margin-top: 4px;
}

/* 操作区域样式 */
.stat-actions {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* 加载状态样式 */
.stat-loading {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .stat-content {
    gap: 12px;
  }
  
  .stat-icon {
    width: 48px;
    height: 48px;
  }
  
  .stat-value {
    font-size: 24px;
  }
  
  .stat-label {
    font-size: 13px;
  }
}

/* 深色模式适配 */
[data-theme="dark"] {
  .stat-card {
    border-color: var(--el-border-color, #4c4d4f);
  }
  
  .stat-icon {
    background: var(--el-fill-color, #3a3a3a);
  }
  
  .stat-loading {
    background: rgba(45, 45, 45, 0.8);
  }
}

/* 系统深色模式偏好适配 */
@media (prefers-color-scheme: dark) {
  .stat-card {
    border-color: var(--el-border-color, #334155);
  }
  
  .stat-icon {
    background: var(--el-fill-color, #334155);
  }
}
</style>
