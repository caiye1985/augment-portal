import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useThemeStore = defineStore('theme', () => {
  // 主题模式：light | dark
  const mode = ref(localStorage.getItem('theme-mode') || 'light')
  
  // 主题色：blue | purple | green | orange | red | pink | cyan | emerald
  const color = ref(localStorage.getItem('theme-color') || 'blue')
  
  // 主题色配置
  const themeColors = {
    blue: {
      name: '蓝色',
      primary: '#6366f1',
      primaryDark: '#4f46e5',
      primaryLight: '#818cf8'
    },
    purple: {
      name: '紫色',
      primary: '#8b5cf6',
      primaryDark: '#7c3aed',
      primaryLight: '#a78bfa'
    },
    green: {
      name: '绿色',
      primary: '#10b981',
      primaryDark: '#059669',
      primaryLight: '#34d399'
    },
    orange: {
      name: '橙色',
      primary: '#f59e0b',
      primaryDark: '#d97706',
      primaryLight: '#fbbf24'
    },
    red: {
      name: '红色',
      primary: '#ef4444',
      primaryDark: '#dc2626',
      primaryLight: '#f87171'
    },
    pink: {
      name: '粉色',
      primary: '#ec4899',
      primaryDark: '#db2777',
      primaryLight: '#f472b6'
    },
    cyan: {
      name: '青色',
      primary: '#06b6d4',
      primaryDark: '#0891b2',
      primaryLight: '#22d3ee'
    },
    emerald: {
      name: '翠绿',
      primary: '#059669',
      primaryDark: '#047857',
      primaryLight: '#10b981'
    }
  }
  
  // 计算属性
  const isDark = computed(() => mode.value === 'dark')
  const currentThemeColor = computed(() => themeColors[color.value])
  
  // 设置主题模式
  const setMode = (newMode) => {
    mode.value = newMode
    localStorage.setItem('theme-mode', newMode)
    applyTheme()
  }
  
  // 设置主题色
  const setColor = (newColor) => {
    if (themeColors[newColor]) {
      color.value = newColor
      localStorage.setItem('theme-color', newColor)
      applyTheme()
    }
  }
  
  // 切换主题模式
  const toggleMode = () => {
    setMode(mode.value === 'light' ? 'dark' : 'light')
  }
  
  // 应用主题到DOM
  const applyTheme = () => {
    const html = document.documentElement
    const themeColor = themeColors[color.value]
    
    // 设置主题模式
    html.setAttribute('data-theme', mode.value)
    html.setAttribute('data-theme-color', color.value)
    
    // 设置CSS变量
    html.style.setProperty('--el-color-primary', themeColor.primary)
    html.style.setProperty('--el-color-primary-dark-2', themeColor.primaryDark)
    html.style.setProperty('--el-color-primary-light-3', themeColor.primaryLight)
    html.style.setProperty('--el-color-primary-light-5', themeColor.primaryLight + '80')
    html.style.setProperty('--el-color-primary-light-7', themeColor.primaryLight + '40')
    html.style.setProperty('--el-color-primary-light-8', themeColor.primaryLight + '20')
    html.style.setProperty('--el-color-primary-light-9', themeColor.primaryLight + '10')
    
    // 设置自定义CSS变量
    html.style.setProperty('--primary-color', themeColor.primary)
    html.style.setProperty('--primary-dark', themeColor.primaryDark)
    html.style.setProperty('--primary-light', themeColor.primaryLight)
  }
  
  // 初始化主题
  const initTheme = () => {
    // 检测系统主题偏好
    if (!localStorage.getItem('theme-mode')) {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      mode.value = prefersDark ? 'dark' : 'light'
    }
    
    applyTheme()
    
    // 监听系统主题变化
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (!localStorage.getItem('theme-mode')) {
        setMode(e.matches ? 'dark' : 'light')
      }
    })
  }
  
  // 获取主题配置
  const getThemeConfig = () => {
    return {
      mode: mode.value,
      color: color.value,
      colorConfig: currentThemeColor.value
    }
  }
  
  // 导入主题配置
  const importThemeConfig = (config) => {
    if (config.mode && ['light', 'dark'].includes(config.mode)) {
      setMode(config.mode)
    }
    if (config.color && themeColors[config.color]) {
      setColor(config.color)
    }
  }
  
  return {
    // 状态
    mode,
    color,
    themeColors,
    
    // 计算属性
    isDark,
    currentThemeColor,
    
    // 方法
    setMode,
    setColor,
    toggleMode,
    applyTheme,
    initTheme,
    getThemeConfig,
    importThemeConfig
  }
})
