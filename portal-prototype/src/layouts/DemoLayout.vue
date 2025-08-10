<template>
  <div class="demo-layout">
    <!-- 演示数据标识 -->
    <div class="mock-data-badge">
      演示数据
    </div>

    <el-container style="height: 100vh">
      <!-- 顶部导航 -->
      <el-header class="layout-header">
        <div class="header-content">
          <!-- 左侧Logo和标题 -->
          <div class="header-left">
            <div class="logo-section">
              <div class="logo-container">
                <img src="@/assets/logo.svg" alt="IT Portal" class="system-logo" />
                <div class="logo-text">
                  <h2>IT运维门户</h2>
                </div>
              </div>
            </div>
          </div>

          <!-- 中间顶级菜单 -->
          <div class="header-center">
            <el-menu
              :default-active="currentTopMenu"
              mode="horizontal"
              background-color="transparent"
              text-color="#ffffff"
              :active-text-color="themeStore.currentThemeColor.primary"
              @select="handleTopMenuSelect"
              class="top-menu"
              :ellipsis="false"
            >
              <el-menu-item
                v-for="menu in topMenus"
                :key="menu.path"
                :index="menu.path"
              >
                <el-icon><component :is="menu.meta.icon" /></el-icon>
                <span>{{ menu.meta.title }}</span>
              </el-menu-item>
            </el-menu>
          </div>

          <!-- 右侧功能区 -->
          <div class="header-right">
            <!-- 全局搜索 -->
            <div v-if="authStore.isLoggedIn" class="global-search-container">
              <GlobalSearch />
            </div>

            <!-- 收藏夹 -->
            <div v-if="authStore.isLoggedIn" class="favorites-container">
              <FavoritesPanel ref="favoritesRef" />
            </div>

            <!-- 全局租户切换器 -->
            <div v-if="authStore.isLoggedIn">
              <span class="switcher-label"></span>
              <el-select
                v-model="authStore.currentTenant"
                placeholder="选择租户"
                @change="handleTenantChange"
                style="width: 180px;"
                size="small"
                class="tenant-select"
              >
                <el-option
                  v-for="tenant in authStore.getUserAccessibleTenants"
                  :key="tenant.id"
                  :label="tenant.name"
                  :value="tenant.id"
                />
              </el-select>
            </div>

            <!-- 消息通知 -->
            <div class="notification-center" v-if="authStore.isLoggedIn">
              <el-badge :value="unreadCount" :hidden="unreadCount === 0">
                <el-button
                  circle
                  size="small"
                  class="notification-btn"
                  @click="showNotifications"
                >
                  <el-icon><Bell /></el-icon>
                </el-button>
              </el-badge>
            </div>

            <!-- 主题控制 -->
            <div class="theme-controls" v-if="authStore.isLoggedIn">
              <!-- 主题模式切换 -->
              <el-button
                circle
                size="small"
                :icon="themeStore.isDark ? 'Sunny' : 'Moon'"
                @click="themeStore.toggleMode"
                class="theme-toggle-btn"
                title="切换深色/浅色模式"
              />
              <!-- 主题色选择 -->
              <el-dropdown trigger="click" @command="handleThemeColorChange">
                <el-button circle size="small" class="color-picker-btn" title="选择主题色">
                  <el-icon><Brush /></el-icon>
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item
                      v-for="(colorConfig, colorKey) in themeStore.themeColors"
                      :key="colorKey"
                      :command="colorKey"
                      :class="{ active: themeStore.color === colorKey }"
                    >
                      <div class="color-option">
                        <div
                          class="color-dot"
                          :style="{ backgroundColor: colorConfig.primary }"
                        ></div>
                        {{ colorConfig.name }}
                      </div>
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>

            <!-- 角色标识 -->
            <div class="role-indicator" v-if="authStore.isLoggedIn">
              <el-tag :type="getRoleTagType(authStore.userRole)" size="small">
                {{ getRoleDisplayName(authStore.userRole) }}
              </el-tag>
            </div>

            <!-- 用户下拉菜单 -->
            <el-dropdown @command="handleUserMenuCommand">
              <span class="user-dropdown">
                <el-avatar size="small">{{ authStore.user?.name?.charAt(0) || '用' }}</el-avatar>
                <span class="username">{{ authStore.user?.name || '用户' }}</span>
                <el-icon><arrow-down /></el-icon>
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">
                    <el-icon><User /></el-icon>
                    个人设置
                  </el-dropdown-item>
                  <el-dropdown-item command="switchRole" v-if="canSwitchRole">
                    <el-icon><Switch /></el-icon>
                    切换角色
                  </el-dropdown-item>
                  <el-dropdown-item command="logout" divided>
                    <el-icon><SwitchButton /></el-icon>
                    退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </el-header>

      <el-container>
        <!-- 左侧二级菜单 -->
        <el-aside width="280px" class="layout-aside">
          <div class="aside-header">
            <h3>{{ currentTopMenuTitle }}</h3>
          </div>
          <el-menu
            :default-active="$route.path"
            router
            :background-color="menuBackgroundColor"
            :text-color="menuTextColor"
            :active-text-color="menuActiveTextColor"
            :collapse="false"
            class="side-menu"
          >
            <el-menu-item
              v-for="item in currentSideMenus"
              :key="item.path"
              :index="item.path"
            >
              <el-icon><component :is="item.meta.icon" /></el-icon>
              <span>{{ item.meta.title }}</span>
            </el-menu-item>
          </el-menu>
        </el-aside>

        <!-- 主内容区 -->
        <el-main class="layout-main">
          <div class="demo-container">
            <router-view v-slot="{ Component }">
              <transition name="fade" mode="out-in">
                <component :is="Component" />
              </transition>
            </router-view>
          </div>
        </el-main>
      </el-container>
    </el-container>

    <!-- 个人设置对话框 -->
    <el-dialog
      v-model="showProfileDialog"
      title="个人设置"
      width="80%"
      :close-on-click-modal="false"
      class="profile-dialog"
    >
      <ProfilePage />
    </el-dialog>

    <!-- 用户引导 -->
    <UserGuide ref="userGuideRef" :auto-start="true" />
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { User, Switch, SwitchButton, Bell, Brush } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'
import ProfilePage from '@/views/ProfilePage.vue'
import GlobalSearch from '@/components/GlobalSearch.vue'
import FavoritesPanel from '@/components/FavoritesPanel.vue'
import UserGuide from '@/components/UserGuide.vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const themeStore = useThemeStore()

// 当前选中的顶级菜单
const currentTopMenu = ref('')

// 消息通知相关
const unreadCount = ref(5) // 模拟未读消息数量
const showProfileDialog = ref(false) // 个人设置对话框
const favoritesRef = ref(null) // 收藏夹组件引用
const userGuideRef = ref(null) // 用户引导组件引用

// 获取顶级菜单
const topMenus = computed(() => {
  const routes = router.getRoutes()
  // 直接从所有路由中筛选出有topMenu标记的路由
  return routes.filter(route => route.meta?.topMenu)
})

// 获取当前顶级菜单的标题
const currentTopMenuTitle = computed(() => {
  const topMenu = topMenus.value.find(menu => menu.path === currentTopMenu.value)
  return topMenu?.meta?.title || '菜单'
})

// 获取当前的二级菜单
const currentSideMenus = computed(() => {
  const topMenu = topMenus.value.find(menu => menu.path === currentTopMenu.value)
  const children = topMenu?.children || []
  // 过滤掉隐藏的菜单项
  return children.filter(child => !child.meta?.hidden)
})

// 菜单颜色计算属性
const menuBackgroundColor = computed(() => {
  return themeStore.isDark ? 'var(--bg-secondary)' : '#304156'
})

const menuTextColor = computed(() => {
  return themeStore.isDark ? 'var(--text-secondary)' : '#bfcbd9'
})

const menuActiveTextColor = computed(() => {
  return themeStore.currentThemeColor.primary
})

// 根据当前路由确定顶级菜单
const updateCurrentTopMenu = () => {
  const pathSegments = route.path.split('/').filter(Boolean)
  if (pathSegments.length > 0) {
    const topPath = '/' + pathSegments[0]
    const foundMenu = topMenus.value.filter(item => !item.meta.hidden).find(menu => menu.path === topPath)
    if (foundMenu) {
      currentTopMenu.value = topPath
    } else {
      // 默认选择第一个菜单
      if (topMenus.value.length > 0) {
        currentTopMenu.value = topMenus.value[0].path
      }
    }
  }
}

// 处理顶级菜单选择
const handleTopMenuSelect = (path) => {
  currentTopMenu.value = path
  // 跳转到该菜单的默认子页面
  const topMenu = topMenus.value.find(menu => menu.path === path)
  if (topMenu && topMenu.redirect) {
    router.push(topMenu.redirect)
  } else if (topMenu && topMenu.children && topMenu.children.length > 0) {
    router.push(topMenu.children[0].path)
  }
}

// 租户切换处理
const handleTenantChange = async (tenantId) => {
  try {
    await authStore.switchTenant(tenantId)
    ElMessage.success(`已切换到租户：${authStore.getCurrentTenant?.name}`)
    // 刷新当前页面数据
    window.location.reload()
  } catch (error) {
    ElMessage.error(error.message)
  }
}

// 主题色切换处理
const handleThemeColorChange = (colorKey) => {
  themeStore.setColor(colorKey)
  ElMessage.success(`已切换到${themeStore.themeColors[colorKey].name}主题`)
}

// 获取角色标签类型
const getRoleTagType = (role) => {
  const typeMap = {
    'system_admin': 'danger',
    'tenant_admin': 'warning',
    'client_user': 'success',
    'engineer': 'info'
  }
  return typeMap[role] || 'info'
}

// 获取角色显示名称
const getRoleDisplayName = (role) => {
  const nameMap = {
    'system_admin': '管理员',
    'tenant_admin': '租户管理员',
    'client_user': '甲方用户',
    'engineer': '运维工程师'
  }
  return nameMap[role] || '用户'
}

// 检查是否可以切换角色
const canSwitchRole = computed(() => {
  const allowedRoles = authStore.getAllowedRoles()
  return allowedRoles.length > 1
})

// 处理用户菜单命令
const handleUserMenuCommand = async (command) => {
  switch (command) {
    case 'profile':
      showProfileDialog.value = true
      break
    case 'switchRole':
      await handleSwitchRole()
      break
    case 'logout':
      await handleLogout()
      break
  }
}

// 显示消息通知
const showNotifications = () => {
  ElMessage.info('消息通知功能开发中...')
  // 这里可以打开消息通知面板
}

// 处理角色切换
const handleSwitchRole = async () => {
  const allowedRoles = authStore.getAllowedRoles()
  if (allowedRoles.length <= 1) {
    ElMessage.warning('您当前没有可切换的角色')
    return
  }

  try {
    // 创建角色选项的HTML
    const roleOptions = allowedRoles.map(role =>
      `<option value="${role}">${getRoleDisplayName(role)}</option>`
    ).join('')

    const { value: newRole } = await ElMessageBox({
      title: '角色切换',
      message: `
        <div style="margin: 20px 0;">
          <p style="margin-bottom: 15px;">请选择要切换的角色：</p>
          <select id="roleSelect" style="width: 100%; padding: 8px; border: 1px solid #dcdfe6; border-radius: 4px;">
            ${roleOptions}
          </select>
        </div>
      `,
      dangerouslyUseHTMLString: true,
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      beforeClose: (action, instance, done) => {
        if (action === 'confirm') {
          const select = document.getElementById('roleSelect')
          instance.confirmButtonLoading = true
          setTimeout(() => {
            instance.confirmButtonLoading = false
            done()
          }, 300)
          return select.value
        } else {
          done()
        }
      }
    })

    if (newRole) {
      const select = document.getElementById('roleSelect')
      const selectedRole = select?.value
      if (selectedRole) {
        await authStore.switchRole(selectedRole)
        ElMessage.success(`已切换到角色：${getRoleDisplayName(selectedRole)}`)
        // 刷新页面以应用新角色权限
        window.location.reload()
      }
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '角色切换失败')
    }
  }
}

// 处理退出登录
const handleLogout = async () => {
  try {
    await ElMessageBox.confirm(
      '确定要退出登录吗？',
      '退出确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    authStore.logout()
    ElMessage.success('已退出登录')
    router.push('/login')
  } catch (error) {
    // 用户取消操作
  }
}

// 监听路由变化
watch(() => route.path, () => {
  updateCurrentTopMenu()
}, { immediate: true })

// 初始化认证状态
onMounted(() => {
  authStore.initializeAuth()
  // 初始化主题
  themeStore.initTheme()
})

// 调试信息
watch(topMenus, (newMenus) => {
  console.log('Top menus updated:', newMenus)
}, { immediate: true })
</script>

<style scoped>
.demo-layout {
  position: relative;
}

.mock-data-badge {
  position: fixed;
  top: 20px;
  right: 20px;
  background: linear-gradient(45deg, #ff6b6b, #ee5a24);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: bold;
  z-index: 9999;
  box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

/* 头部样式 - 使用CSS变量实现主题适配 */
.layout-header {
  background: var(--gradient-bg);
  color: var(--text-inverse);
  line-height: 60px;
  padding: 0 20px;
  box-shadow: var(--shadow-md);
  position: relative;
  z-index: 100;
  transition: var(--transition-base);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
}

.header-left {
  flex-shrink: 0;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 12px;
}

.system-logo {
  width: 32px;
  height: 32px;
  filter: brightness(0) invert(1); /* 白色图标 */
}

.logo-text h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
  margin: 0 20px;
  overflow-x: auto;
  min-width: 0;
}

.top-menu {
  border-bottom: none !important;
  background: transparent !important;
  display: flex;
  flex-wrap: nowrap;
  min-width: max-content;
  position: relative;
  z-index: 10;
}

.top-menu .el-menu-item {
  height: 60px;
  line-height: 60px;
  border-bottom: 3px solid transparent;
  margin: 0 4px;
  padding: 0 12px;
  border-radius: 0;
  transition: all 0.3s ease;
  flex-shrink: 0;
  white-space: nowrap;
}

.top-menu .el-menu-item:hover {
  background-color: rgba(255, 255, 255, 0.1) !important;
  border-bottom-color: rgba(255, 255, 255, 0.3);
}

.top-menu .el-menu-item.is-active {
  background-color: rgba(255, 255, 255, 0.15) !important;
  border-bottom-color: #409eff;
  color: #409eff !important;
}

.header-right {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 12px;
}

/* 全局搜索和收藏夹容器 */
.global-search-container,
.favorites-container {
  display: flex;
  align-items: center;
}

/* 全局租户切换器样式 */
.tenant-switcher-global {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.1);
  padding: 6px 12px;
  border-radius: 6px;
  backdrop-filter: blur(10px);
}

.switcher-label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.9);
  white-space: nowrap;
}

/* 租户选择器样式 */
.tenant-select {
  background: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
}

.tenant-select .el-input__wrapper {
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
}

.tenant-select .el-input__inner {
  color: white !important;
}

.tenant-select .el-input__inner::placeholder {
  color: rgba(255, 255, 255, 0.6) !important;
}

/* 主题控制样式 */
.theme-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.theme-toggle-btn,
.color-picker-btn {
  background: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: white !important;
  transition: all 0.3s ease;
}

.theme-toggle-btn:hover,
.color-picker-btn:hover {
  background: rgba(255, 255, 255, 0.2) !important;
  transform: scale(1.05);
}

.color-option {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 0;
}

.color-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.color-option.active .color-dot {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(var(--primary-color-rgb), 0.3);
}

/* 消息通知样式 */
.notification-center {
  display: flex;
  align-items: center;
}

.notification-btn {
  background: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: white !important;
  transition: all 0.3s ease;
}

.notification-btn:hover {
  background: rgba(255, 255, 255, 0.2) !important;
  transform: scale(1.05);
}

/* 角色指示器样式 */
.role-indicator {
  display: flex;
  align-items: center;
}

.user-dropdown {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.user-dropdown:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.username {
  font-size: 14px;
  font-weight: 500;
}

/* 侧边栏样式 */
.layout-aside {
  background: var(--bg-secondary);
  box-shadow: 2px 0 8px rgba(0,0,0,0.1);
  border-right: 1px solid var(--border-color);
  transition: var(--transition-base);
}

.aside-header {
  padding: 20px;
  border-bottom: 1px solid var(--border-color);
  background: var(--bg-tertiary);
}

.aside-header h3 {
  margin: 0;
  color: var(--text-primary);
  font-size: 16px;
  font-weight: 500;
}

.side-menu {
  border-right: none;
  padding: 8px;
}

.side-menu .el-menu-item {
  height: 48px;
  line-height: 48px;
  margin: 4px 0;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.side-menu .el-menu-item:hover {
  background-color: var(--bg-tertiary) !important;
  color: var(--text-primary) !important;
  transform: translateX(4px);
}

.side-menu .el-menu-item.is-active {
  background-color: rgba(var(--primary-color-rgb), 0.1) !important;
  color: var(--primary-color) !important;
  border-radius: 6px;
  transform: translateX(4px);
  box-shadow: 0 2px 8px rgba(var(--primary-color-rgb), 0.3);
}

/* 主内容区样式 - 使用CSS变量实现主题适配 */
.layout-main {
  background: var(--bg-secondary);
  padding: 0;
  overflow: hidden;
  transition: var(--transition-base);
}

.demo-container {
  height: 100%;
  overflow: auto;
  background: var(--bg-primary);
  color: var(--text-primary);
  transition: var(--transition-base);
}

/* 过渡动画 */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .header-center {
    margin: 0 20px;
  }

  .top-menu .el-menu-item {
    margin: 0 4px;
    padding: 0 12px;
  }
}

@media (max-width: 768px) {
  .layout-header {
    padding: 0 15px;
  }

  .header-content {
    flex-direction: column;
    height: auto;
    gap: 10px;
    padding: 10px 0;
  }

  .header-center {
    margin: 0;
    width: 100%;
  }

  .top-menu {
    width: 100%;
    justify-content: center;
  }

  .top-menu .el-menu-item {
    margin: 0 2px;
    padding: 0 8px;
    font-size: 13px;
  }

  .layout-aside {
    width: 240px !important;
  }

  .aside-header {
    padding: 15px;
  }

  .aside-header h3 {
    font-size: 14px;
  }

  .mock-data-badge {
    top: 10px;
    right: 10px;
    padding: 6px 12px;
    font-size: 11px;
  }
}

@media (max-width: 480px) {
  .logo-section h2 {
    font-size: 16px;
  }

  .top-menu .el-menu-item {
    padding: 0 6px;
    font-size: 12px;
  }

  .layout-aside {
    width: 180px !important;
  }
}

/* 滚动条样式 */
.demo-container::-webkit-scrollbar {
  width: 6px;
}

.demo-container::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.demo-container::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.demo-container::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}

/* 菜单图标样式 */
.el-menu-item .el-icon {
  margin-right: 8px;
  font-size: 16px;
}

/* 头部菜单图标样式 */
.top-menu .el-menu-item .el-icon {
  margin-right: 6px;
  font-size: 18px;
}

/* 个人设置对话框样式 */
.profile-dialog .el-dialog__body {
  padding: 0;
  max-height: 80vh;
  overflow: hidden;
}

.profile-dialog .el-dialog {
  margin-top: 5vh !important;
}

/* 深色主题下的logo适配 */
@media (prefers-color-scheme: dark) {
  .system-logo {
    filter: brightness(0) invert(1);
  }
}

/* 浅色主题下的logo适配 */
@media (prefers-color-scheme: light) {
  .system-logo {
    filter: brightness(0) invert(1);
  }
}

/*
 * 优雅的一级菜单可见性修复方案
 * 保持原有设计风格，仅增强文字可见性
 */

/* 基础菜单项样式 - 保持原有简洁风格 */
.top-menu .el-menu-item {
  /* 保持原有的过渡效果 */
  transition: all 0.3s ease;

  /* 保持原有的内边距和布局 */
  position: relative;
}

/* 非激活状态 - 微调文字颜色和阴影 */
.top-menu .el-menu-item:not(.is-active) {
  /* 使用稍深的灰色提高对比度，但保持优雅 */
  color: rgba(255, 255, 255, 0.95) !important;

  /* 添加微妙的文字阴影增强可读性 */
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);

  /* 保持原有的透明背景 */
  background: transparent;
}

/* 激活状态 - 保持原有设计，仅增强文字阴影 */
.top-menu .el-menu-item.is-active {
  /* 使用主题色 */
  color: var(--primary-color) !important;

  /* 保持原有的半透明背景 */
  background: rgba(255, 255, 255, 0.15) !important;

  /* 增强文字阴影确保在渐变背景上可见 */
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);

  /* 使用主题色的底部边框 */
  border-bottom: 3px solid var(--primary-color) !important;
}

/* Hover状态 - 保持原有风格，仅微调 */
.top-menu .el-menu-item:not(.is-active):hover {
  /* 微妙的背景高亮 */
  background: rgba(255, 255, 255, 0.1) !important;

  /* 保持白色文字但增强阴影 */
  color: rgba(255, 255, 255, 1) !important;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5);
}

/* 激活状态的hover效果 */
.top-menu .el-menu-item.is-active:hover {
  /* 稍微增强背景透明度 */
  background: rgba(255, 255, 255, 0.2) !important;

  /* 使用主题色文字 */
  color: var(--primary-color) !important;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5);
}

/* 深色主题适配 */
[data-theme="dark"] .top-menu .el-menu-item:not(.is-active) {
  /* 深色主题下使用浅色文字 */
  color: rgba(255, 255, 255, 0.9) !important;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
}

[data-theme="dark"] .top-menu .el-menu-item:not(.is-active):hover {
  background: rgba(255, 255, 255, 0.1) !important;
  color: rgba(255, 255, 255, 1) !important;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.7);
}

[data-theme="dark"] .top-menu .el-menu-item.is-active {
  /* 深色主题下激活状态使用主题色 */
  color: var(--primary-color) !important;
  background: rgba(255, 255, 255, 0.1) !important;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.6);
}

/* 注意：Element Plus组件的深色模式样式已移至 theme.css 统一管理 */
</style>