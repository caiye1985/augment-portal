<template>
  <div class="profile-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon><User /></el-icon>
          个人设置
        </h1>
        <p class="page-description">管理您的个人信息、安全设置和系统偏好</p>
      </div>
    </div>

    <div class="profile-container">
      <el-row :gutter="20">
        <!-- 左侧用户信息卡片 -->
        <el-col :span="8">
          <el-card class="user-info-card">
            <div class="user-avatar-section">
              <el-avatar :size="80" :src="userInfo.avatar">
                {{ userInfo.name?.charAt(0) || 'U' }}
              </el-avatar>
              <el-button size="small" class="avatar-upload-btn">
                <el-icon><Camera /></el-icon>
                更换头像
              </el-button>
            </div>
            
            <div class="user-basic-info">
              <h3>{{ userInfo.name }}</h3>
              <p class="user-role">{{ getRoleDisplayName(userInfo.role) }}</p>
              <p class="user-email">{{ userInfo.email }}</p>
            </div>

            <div class="user-stats">
              <div class="stat-item">
                <span class="stat-label">当前租户</span>
                <span class="stat-value">{{ currentTenantName }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">可访问租户</span>
                <span class="stat-value">{{ accessibleTenantsCount }}</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">最后登录</span>
                <span class="stat-value">{{ lastLoginTime }}</span>
              </div>
            </div>
          </el-card>
        </el-col>

        <!-- 右侧设置面板 -->
        <el-col :span="16">
          <el-tabs v-model="activeTab" class="profile-tabs">
            <!-- 基本信息 -->
            <el-tab-pane label="基本信息" name="basic">
              <el-card>
                <el-form
                  ref="basicFormRef"
                  :model="basicForm"
                  :rules="basicRules"
                  label-width="100px"
                >
                  <el-form-item label="姓名" prop="name">
                    <el-input v-model="basicForm.name" placeholder="请输入姓名" />
                  </el-form-item>
                  
                  <el-form-item label="邮箱" prop="email">
                    <el-input v-model="basicForm.email" placeholder="请输入邮箱" />
                  </el-form-item>
                  
                  <el-form-item label="手机号" prop="phone">
                    <el-input v-model="basicForm.phone" placeholder="请输入手机号" />
                  </el-form-item>
                  
                  <el-form-item label="部门">
                    <el-input v-model="basicForm.department" disabled />
                  </el-form-item>
                  
                  <el-form-item label="个人简介">
                    <el-input
                      v-model="basicForm.bio"
                      type="textarea"
                      :rows="3"
                      placeholder="请输入个人简介"
                    />
                  </el-form-item>
                  
                  <el-form-item>
                    <el-button type="primary" @click="saveBasicInfo">保存基本信息</el-button>
                    <el-button @click="resetBasicForm">重置</el-button>
                  </el-form-item>
                </el-form>
              </el-card>
            </el-tab-pane>

            <!-- 安全设置 -->
            <el-tab-pane label="安全设置" name="security">
              <el-card>
                <el-form
                  ref="passwordFormRef"
                  :model="passwordForm"
                  :rules="passwordRules"
                  label-width="100px"
                >
                  <el-form-item label="当前密码" prop="currentPassword">
                    <el-input
                      v-model="passwordForm.currentPassword"
                      type="password"
                      placeholder="请输入当前密码"
                      show-password
                    />
                  </el-form-item>
                  
                  <el-form-item label="新密码" prop="newPassword">
                    <el-input
                      v-model="passwordForm.newPassword"
                      type="password"
                      placeholder="请输入新密码"
                      show-password
                    />
                  </el-form-item>
                  
                  <el-form-item label="确认密码" prop="confirmPassword">
                    <el-input
                      v-model="passwordForm.confirmPassword"
                      type="password"
                      placeholder="请再次输入新密码"
                      show-password
                    />
                  </el-form-item>
                  
                  <el-form-item>
                    <el-button type="primary" @click="changePassword">修改密码</el-button>
                    <el-button @click="resetPasswordForm">重置</el-button>
                  </el-form-item>
                </el-form>

                <!-- 安全选项 -->
                <el-divider content-position="left">安全选项</el-divider>
                <div class="security-options">
                  <div class="security-item">
                    <div class="security-info">
                      <h4>双因素认证</h4>
                      <p>为您的账户添加额外的安全保护</p>
                    </div>
                    <el-switch v-model="securitySettings.twoFactorAuth" />
                  </div>
                  
                  <div class="security-item">
                    <div class="security-info">
                      <h4>登录通知</h4>
                      <p>当有新设备登录时发送邮件通知</p>
                    </div>
                    <el-switch v-model="securitySettings.loginNotification" />
                  </div>
                </div>
              </el-card>
            </el-tab-pane>

            <!-- 系统偏好 -->
            <el-tab-pane label="系统偏好" name="preferences">
              <el-card>
                <el-form label-width="120px">
                  <el-form-item label="界面主题">
                    <el-radio-group v-model="preferences.theme">
                      <el-radio label="light">浅色主题</el-radio>
                      <el-radio label="dark">深色主题</el-radio>
                      <el-radio label="auto">跟随系统</el-radio>
                    </el-radio-group>
                  </el-form-item>
                  
                  <el-form-item label="语言设置">
                    <el-select v-model="preferences.language" style="width: 200px;">
                      <el-option label="简体中文" value="zh-CN" />
                      <el-option label="English" value="en-US" />
                    </el-select>
                  </el-form-item>
                  
                  <el-form-item label="时区设置">
                    <el-select v-model="preferences.timezone" style="width: 200px;">
                      <el-option label="北京时间 (UTC+8)" value="Asia/Shanghai" />
                      <el-option label="东京时间 (UTC+9)" value="Asia/Tokyo" />
                      <el-option label="纽约时间 (UTC-5)" value="America/New_York" />
                    </el-select>
                  </el-form-item>
                  
                  <el-form-item label="通知设置">
                    <div class="notification-settings">
                      <el-checkbox v-model="preferences.notifications.email">邮件通知</el-checkbox>
                      <el-checkbox v-model="preferences.notifications.browser">浏览器通知</el-checkbox>
                      <el-checkbox v-model="preferences.notifications.mobile">手机推送</el-checkbox>
                    </div>
                  </el-form-item>
                  
                  <el-form-item label="数据刷新">
                    <el-radio-group v-model="preferences.autoRefresh">
                      <el-radio :label="0">手动刷新</el-radio>
                      <el-radio :label="30">30秒</el-radio>
                      <el-radio :label="60">1分钟</el-radio>
                      <el-radio :label="300">5分钟</el-radio>
                    </el-radio-group>
                  </el-form-item>
                  
                  <el-form-item>
                    <el-button type="primary" @click="savePreferences">保存偏好设置</el-button>
                    <el-button @click="resetPreferences">恢复默认</el-button>
                  </el-form-item>
                </el-form>
              </el-card>
            </el-tab-pane>

            <!-- 租户权限 -->
            <el-tab-pane label="租户权限" name="tenants">
              <el-card>
                <div class="tenant-permissions">
                  <h3>可访问的租户</h3>
                  <div class="tenant-list">
                    <div
                      v-for="tenant in accessibleTenants"
                      :key="tenant.id"
                      class="tenant-item"
                    >
                      <div class="tenant-info">
                        <h4>{{ tenant.name }}</h4>
                        <p>{{ tenant.code }}</p>
                      </div>
                      <div class="tenant-status">
                        <el-tag
                          :type="tenant.id === authStore.currentTenant ? 'success' : 'info'"
                          size="small"
                        >
                          {{ tenant.id === authStore.currentTenant ? '当前租户' : '可访问' }}
                        </el-tag>
                      </div>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-tab-pane>
          </el-tabs>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { User, Camera } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

// 响应式数据
const activeTab = ref('basic')
const basicFormRef = ref(null)
const passwordFormRef = ref(null)

// 用户信息
const userInfo = computed(() => authStore.user || {})

// 当前租户名称
const currentTenantName = computed(() => {
  return authStore.getCurrentTenant?.name || '未选择'
})

// 可访问租户数量
const accessibleTenantsCount = computed(() => {
  return authStore.getUserAccessibleTenants?.length || 0
})

// 可访问的租户列表
const accessibleTenants = computed(() => {
  return authStore.getUserAccessibleTenants || []
})

// 最后登录时间
const lastLoginTime = ref('2024-01-15 10:30:00')

// 基本信息表单
const basicForm = reactive({
  name: '',
  email: '',
  phone: '',
  department: '',
  bio: ''
})

// 密码修改表单
const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 安全设置
const securitySettings = reactive({
  twoFactorAuth: false,
  loginNotification: true
})

// 系统偏好设置
const preferences = reactive({
  theme: 'light',
  language: 'zh-CN',
  timezone: 'Asia/Shanghai',
  notifications: {
    email: true,
    browser: true,
    mobile: false
  },
  autoRefresh: 60
})

// 表单验证规则
const basicRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ]
}

const passwordRules = {
  currentPassword: [{ required: true, message: '请输入当前密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

// 方法
const getRoleDisplayName = (role) => {
  const nameMap = {
    'system_admin': '系统管理员',
    'tenant_admin': '租户管理员',
    'client_user': '甲方用户',
    'engineer': '运维工程师'
  }
  return nameMap[role] || '用户'
}

const saveBasicInfo = async () => {
  if (!basicFormRef.value) return
  
  try {
    await basicFormRef.value.validate()
    // 这里应该调用API保存基本信息
    ElMessage.success('基本信息保存成功')
  } catch (error) {
    ElMessage.error('请检查输入信息')
  }
}

const resetBasicForm = () => {
  initBasicForm()
}

const changePassword = async () => {
  if (!passwordFormRef.value) return
  
  try {
    await passwordFormRef.value.validate()
    // 这里应该调用API修改密码
    ElMessage.success('密码修改成功')
    resetPasswordForm()
  } catch (error) {
    ElMessage.error('请检查输入信息')
  }
}

const resetPasswordForm = () => {
  Object.assign(passwordForm, {
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  })
}

const savePreferences = () => {
  // 这里应该调用API保存偏好设置
  localStorage.setItem('userPreferences', JSON.stringify(preferences))
  ElMessage.success('偏好设置保存成功')
}

const resetPreferences = () => {
  Object.assign(preferences, {
    theme: 'light',
    language: 'zh-CN',
    timezone: 'Asia/Shanghai',
    notifications: {
      email: true,
      browser: true,
      mobile: false
    },
    autoRefresh: 60
  })
}

const initBasicForm = () => {
  if (userInfo.value) {
    Object.assign(basicForm, {
      name: userInfo.value.name || '',
      email: userInfo.value.email || '',
      phone: userInfo.value.phone || '',
      department: userInfo.value.department || '',
      bio: userInfo.value.bio || ''
    })
  }
}

onMounted(() => {
  initBasicForm()
  
  // 加载保存的偏好设置
  const savedPreferences = localStorage.getItem('userPreferences')
  if (savedPreferences) {
    Object.assign(preferences, JSON.parse(savedPreferences))
  }
})
</script>

<style scoped>
.profile-page {
  padding: 20px;
}

.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 30px;
  border-radius: 12px;
  margin-bottom: 24px;
}

.page-title {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
}

.page-description {
  margin: 0;
  opacity: 0.9;
}

.profile-container {
  max-width: 1200px;
}

/* 用户信息卡片 */
.user-info-card {
  text-align: center;
}

.user-avatar-section {
  margin-bottom: 20px;
  position: relative;
}

.avatar-upload-btn {
  margin-top: 10px;
  font-size: 12px;
}

.user-basic-info h3 {
  margin: 0 0 8px 0;
  font-size: 20px;
  color: #2c3e50;
}

.user-role {
  color: #409eff;
  font-weight: 500;
  margin: 0 0 5px 0;
}

.user-email {
  color: #909399;
  font-size: 14px;
  margin: 0 0 20px 0;
}

.user-stats {
  border-top: 1px solid #ebeef5;
  padding-top: 20px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
}

.stat-label {
  color: #909399;
  font-size: 14px;
}

.stat-value {
  font-weight: 500;
  color: #2c3e50;
}

/* 设置面板 */
.profile-tabs {
  background: white;
}

.security-options {
  margin-top: 20px;
}

.security-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #ebeef5;
}

.security-item:last-child {
  border-bottom: none;
}

.security-info h4 {
  margin: 0 0 5px 0;
  font-size: 16px;
  color: #2c3e50;
}

.security-info p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}

.notification-settings {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

/* 租户权限 */
.tenant-permissions h3 {
  margin: 0 0 20px 0;
  color: #2c3e50;
}

.tenant-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.tenant-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fafafa;
}

.tenant-info h4 {
  margin: 0 0 5px 0;
  font-size: 16px;
  color: #2c3e50;
}

.tenant-info p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}
</style>
