<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useThemeStore } from '@/stores/theme'
import { useUserStore } from '@/stores/user'

const themeStore = useThemeStore()
const userStore = useUserStore()

onMounted(() => {
  // 初始化主题
  themeStore.initTheme()
  
  // 检查用户登录状态
  userStore.checkAuthStatus()
})
</script>

<style lang="scss">
#app {
  height: 100vh;
  width: 100vw;
}

// 全局样式重置
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

html, body {
  height: 100%;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

// Element Plus 样式定制
.el-menu {
  border-right: none !important;
}

.el-card {
  border: 1px solid var(--el-border-color-light);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
}

// 响应式设计
@media (max-width: 768px) {
  .el-aside {
    width: 0 !important;
  }
}
</style>