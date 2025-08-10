<template>
  <div class="login-container">
    <!-- 背景装饰 -->
    <div class="login-background">
      <div class="bg-shape shape-1"></div>
      <div class="bg-shape shape-2"></div>
      <div class="bg-shape shape-3"></div>
    </div>

    <!-- 主题切换按钮 -->
    <div class="theme-controls">
      <el-button
        circle
        :icon="themeStore.isDark ? 'Sunny' : 'Moon'"
        @click="themeStore.toggleMode"
        class="theme-toggle"
      />
      <el-dropdown trigger="click" @command="handleThemeColorChange">
        <el-button circle class="color-picker">
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

    <!-- 登录卡片 -->
    <div class="login-card">
      <!-- 头部 -->
      <div class="login-header">
        <div class="logo-section">
          <h1 class="system-title">IT运维门户系统</h1>
          <p class="system-subtitle">智能化运维管理平台</p>
        </div>
      </div>

      <!-- 登录表单 -->
      <div class="login-form-container">
        <!-- 步骤指示器 -->
        <div class="step-indicator">
          <div class="step" :class="{ active: loginStep === 1, completed: loginStep > 1 }">
            <div class="step-number">1</div>
            <div class="step-label">身份识别</div>
          </div>
          <div class="step-line" :class="{ active: loginStep > 1 }"></div>
          <div class="step" :class="{ active: loginStep === 2 }">
            <div class="step-number">2</div>
            <div class="step-label">身份验证</div>
          </div>
        </div>

        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="currentRules"
          class="login-form"
          size="large"
          @keyup.enter="handleSubmit"
        >
          <!-- 第一步：用户标识输入 -->
          <div v-if="loginStep === 1" class="step-one">
            <div class="step-title">
              <h3>欢迎使用IT运维门户</h3>
              <p>请输入您的身份标识</p>
            </div>

            <el-form-item prop="userIdentifier">
              <el-input
                v-model="loginForm.userIdentifier"
                placeholder="邮箱、手机号或租户编码"
                prefix-icon="User"
                @input="onIdentifierInput"
              >
                <template #suffix>
                  <el-tooltip content="支持邮箱、手机号或租户编码" placement="top">
                    <el-icon class="input-help"><QuestionFilled /></el-icon>
                  </el-tooltip>
                </template>
              </el-input>
              <div class="input-hint">
                支持多种登录方式：邮箱、手机号或租户编码
              </div>
            </el-form-item>

            <el-button
              type="primary"
              class="login-button"
              :loading="discovering"
              :disabled="!loginForm.userIdentifier"
              @click="discoverTenant"
            >
              {{ discovering ? '查找中...' : '下一步' }}
            </el-button>
          </div>

          <!-- 第二步：身份验证 -->
          <div v-else class="step-two">
            <div class="step-title">
              <h3>身份验证</h3>
              <p>{{ selectedTenantInfo?.name || '请完成身份验证' }}</p>
            </div>

            <!-- 用户信息显示 -->
            <div class="user-info-display">
              <div class="user-identifier">{{ loginForm.userIdentifier }}</div>
              <el-button type="text" size="small" @click="goBackToStep1">
                <el-icon><ArrowLeft /></el-icon>
                返回修改
              </el-button>
            </div>

            <!-- 租户选择（如果有多个租户） -->
            <el-form-item v-if="availableTenants.length > 1" prop="tenantId">
              <el-select
                v-model="loginForm.tenantId"
                placeholder="请选择租户"
                style="width: 100%;"
                @change="onTenantChange"
              >
                <el-option
                  v-for="tenant in availableTenants"
                  :key="tenant.id"
                  :label="tenant.name"
                  :value="tenant.id"
                >
                  <div class="tenant-option">
                    <span class="tenant-name">{{ tenant.name }}</span>
                    <span class="tenant-code">{{ tenant.code }}</span>
                  </div>
                </el-option>
              </el-select>
            </el-form-item>

            <!-- 登录方式选择 -->
            <div class="login-method-selector">
              <el-radio-group v-model="loginMethod" @change="onLoginMethodChange">
                <el-radio label="password">密码登录</el-radio>
                <el-radio label="sms" :disabled="!isMobileNumber">短信验证码</el-radio>
                <el-radio label="email" :disabled="!isEmailAddress">邮箱验证码</el-radio>
              </el-radio-group>
            </div>

            <!-- 密码输入 -->
            <el-form-item v-if="loginMethod === 'password'" prop="password">
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="请输入密码"
                prefix-icon="Lock"
                show-password
              />
            </el-form-item>

            <!-- 验证码输入 -->
            <el-form-item v-else prop="verificationCode">
              <div class="verification-input">
                <el-input
                  v-model="loginForm.verificationCode"
                  placeholder="请输入验证码"
                  prefix-icon="Message"
                  maxlength="6"
                />
                <el-button
                  :disabled="!canSendCode"
                  @click="sendVerificationCode"
                  class="send-code-btn"
                  size="small"
                >
                  {{ codeCountdown > 0 ? `${codeCountdown}s` : '发送验证码' }}
                </el-button>
              </div>
            </el-form-item>

            <!-- 图形验证码 -->
            <el-form-item v-if="showCaptcha" prop="captcha">
              <div class="captcha-input">
                <el-input
                  v-model="loginForm.captcha"
                  placeholder="请输入图形验证码"
                  prefix-icon="Picture"
                  maxlength="4"
                />
                <div class="captcha-image" @click="refreshCaptcha">
                  <canvas ref="captchaCanvas" width="120" height="40"></canvas>
                  <div class="captcha-refresh">点击刷新</div>
                </div>
              </div>
            </el-form-item>

            <!-- 记住登录 -->
            <el-form-item>
              <div class="login-options">
                <el-checkbox v-model="loginForm.remember">记住登录状态</el-checkbox>
                <el-link type="primary" :underline="false">忘记密码？</el-link>
              </div>
            </el-form-item>

            <!-- 登录按钮 -->
            <el-form-item>
              <el-button
                type="primary"
                class="login-button"
                :loading="loading"
                @click="handleLogin"
              >
                {{ loading ? '登录中...' : '登录' }}
              </el-button>
            </el-form-item>
          </div>
        </el-form>

        <!-- 快速登录选项 -->
        <div class="quick-login">
          <div class="quick-login-title">快速登录演示账号</div>
          <div class="quick-login-buttons">
            <el-button
              v-for="account in demoAccounts"
              :key="account.username"
              size="small"
              :type="account.type"
              @click="quickLogin(account)"
            >
              {{ account.label }}
            </el-button>
          </div>
        </div>

        <!-- 登录方式切换 -->
        <div class="login-methods">
          <div class="method-divider">
            <span>其他登录方式</span>
          </div>
          <div class="method-buttons">
            <el-button circle disabled>
              <el-icon><Platform /></el-icon>
            </el-button>
            <el-button circle disabled>
              <el-icon><Message /></el-icon>
            </el-button>
            <el-button circle disabled>
              <el-icon><Cellphone /></el-icon>
            </el-button>
          </div>
        </div>
      </div>

      <!-- 底部信息 -->
      <div class="login-footer">
        <p class="copyright">© 2024 IT运维门户系统 - 演示版本</p>
        <p class="demo-notice">
          <el-icon><Warning /></el-icon>
          这是演示系统，请勿输入真实密码
        </p>
        <div class="demo-links">
          <el-button text @click="$router.push('/theme-demo')">
            <el-icon><Brush /></el-icon>
            主题演示
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  User, Lock, Platform, Message, Cellphone, Warning, ArrowLeft,
  QuestionFilled, Picture, Sunny, Moon, Brush
} from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore } from '@/stores/theme'

const router = useRouter()
const authStore = useAuthStore()
const themeStore = useThemeStore()

// 响应式数据
const loginFormRef = ref(null)
const loading = ref(false)
const discovering = ref(false)
const loginStep = ref(1) // 1: 身份识别, 2: 身份验证
const loginMethod = ref('password') // password, sms, email
const codeCountdown = ref(0)
const canSendCode = ref(true)
const showCaptcha = ref(false)
const captchaCode = ref('')
const captchaCanvas = ref(null)

// 登录表单
const loginForm = reactive({
  userIdentifier: '', // 用户标识（邮箱、手机号或租户编码）
  tenantId: '',
  username: '',
  password: '',
  verificationCode: '',
  captcha: '',
  remember: false
})

// 第一步验证规则
const step1Rules = {
  userIdentifier: [
    { required: true, message: '请输入邮箱、手机号或租户编码', trigger: 'blur' },
    { min: 3, max: 50, message: '长度在 3 到 50 个字符', trigger: 'blur' }
  ]
}

// 第二步验证规则
const step2Rules = {
  tenantId: [
    { required: true, message: '请选择租户', trigger: 'change' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: 'blur' }
  ],
  verificationCode: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    { len: 6, message: '验证码为6位数字', trigger: 'blur' }
  ],
  captcha: [
    { required: true, message: '请输入图形验证码', trigger: 'blur' },
    { len: 4, message: '图形验证码为4位', trigger: 'blur' }
  ]
}

// 当前验证规则
const currentRules = computed(() => {
  if (loginStep.value === 1) {
    return step1Rules
  } else {
    const rules = { ...step2Rules }
    if (loginMethod.value === 'password') {
      delete rules.verificationCode
    } else {
      delete rules.password
    }
    if (availableTenants.value.length <= 1) {
      delete rules.tenantId
    }
    if (!showCaptcha.value) {
      delete rules.captcha
    }
    return rules
  }
})

// 可用租户列表
const availableTenants = ref([])

// 选中的租户信息
const selectedTenantInfo = computed(() => {
  return availableTenants.value.find(t => t.id === loginForm.tenantId)
})

// 判断是否为手机号
const isMobileNumber = computed(() => {
  const mobileRegex = /^1[3-9]\d{9}$/
  return mobileRegex.test(loginForm.userIdentifier)
})

// 判断是否为邮箱
const isEmailAddress = computed(() => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(loginForm.userIdentifier)
})

// 演示账号
const demoAccounts = [
  {
    username: 'admin',
    password: 'password',
    label: '系统管理员',
    type: 'danger',
    role: 'system_admin'
  },
  {
    username: 'alibaba_admin',
    password: 'password',
    label: '租户管理员',
    type: 'warning',
    role: 'tenant_admin',
    tenantId: '1'
  },
  {
    username: 'client_user',
    password: 'password',
    label: '甲方用户',
    type: 'success',
    role: 'client_user',
    tenantId: '2'
  },
  {
    username: 'engineer1',
    password: 'password',
    label: '运维工程师',
    type: 'info',
    role: 'engineer'
  }
]

// 方法
const onIdentifierInput = () => {
  // 清除之前的租户发现结果
  availableTenants.value = []
  loginForm.tenantId = ''
}

const onLoginMethodChange = () => {
  // 清除验证码
  loginForm.verificationCode = ''
  codeCountdown.value = 0
  canSendCode.value = true
}

const onTenantChange = (tenantId) => {
  console.log('选择租户:', tenantId)
}

// 租户发现服务
const discoverTenant = async () => {
  if (!loginForm.userIdentifier) {
    ElMessage.error('请输入身份标识')
    return
  }

  discovering.value = true

  try {
    // 模拟租户发现API调用
    await new Promise(resolve => setTimeout(resolve, 1500))

    // 模拟根据用户标识查找租户
    const mockTenants = [
      { id: '1', name: '阿里巴巴集团', code: 'ALIBABA' },
      { id: '2', name: '腾讯科技', code: 'TENCENT' },
      { id: '3', name: '字节跳动', code: 'BYTEDANCE' }
    ]

    // 根据输入类型模拟不同的发现结果
    if (isEmailAddress.value) {
      // 邮箱可能对应多个租户
      const domain = loginForm.userIdentifier.split('@')[1]
      if (domain === 'alibaba-inc.com') {
        availableTenants.value = [mockTenants[0]]
      } else if (domain === 'tencent.com') {
        availableTenants.value = [mockTenants[1]]
      } else {
        // 通用邮箱可能对应多个租户
        availableTenants.value = mockTenants
      }
    } else if (isMobileNumber.value) {
      // 手机号通常对应单个租户
      availableTenants.value = [mockTenants[0]]
    } else {
      // 租户编码直接匹配
      const tenant = mockTenants.find(t =>
        t.code.toLowerCase() === loginForm.userIdentifier.toLowerCase()
      )
      availableTenants.value = tenant ? [tenant] : []
    }

    if (availableTenants.value.length === 0) {
      ElMessage.error('未找到对应的租户，请检查输入信息')
      return
    }

    // 如果只有一个租户，自动选择
    if (availableTenants.value.length === 1) {
      loginForm.tenantId = availableTenants.value[0].id
    }

    // 进入第二步
    loginStep.value = 2

    // 根据输入类型设置默认登录方式
    if (isMobileNumber.value) {
      loginMethod.value = 'sms'
    } else if (isEmailAddress.value) {
      loginMethod.value = 'email'
    } else {
      loginMethod.value = 'password'
    }

    // 在某些情况下显示图形验证码（模拟安全策略）
    showCaptcha.value = Math.random() > 0.5 // 50%概率显示验证码
    if (showCaptcha.value) {
      setTimeout(() => {
        generateCaptcha()
      }, 100)
    }

    ElMessage.success(`发现 ${availableTenants.value.length} 个可用租户`)
  } catch (error) {
    ElMessage.error('租户发现失败，请稍后重试')
  } finally {
    discovering.value = false
  }
}

// 返回第一步
const goBackToStep1 = () => {
  loginStep.value = 1
  availableTenants.value = []
  loginForm.tenantId = ''
  loginForm.password = ''
  loginForm.verificationCode = ''
}

// 发送验证码
const sendVerificationCode = async () => {
  if (!canSendCode.value) return

  try {
    // 模拟发送验证码
    await new Promise(resolve => setTimeout(resolve, 1000))

    ElMessage.success(`验证码已发送到 ${loginForm.userIdentifier}`)

    // 开始倒计时
    canSendCode.value = false
    codeCountdown.value = 60

    const timer = setInterval(() => {
      codeCountdown.value--
      if (codeCountdown.value <= 0) {
        clearInterval(timer)
        canSendCode.value = true
      }
    }, 1000)
  } catch (error) {
    ElMessage.error('验证码发送失败')
  }
}

// 处理表单提交
const handleSubmit = () => {
  if (loginStep.value === 1) {
    discoverTenant()
  } else {
    handleLogin()
  }
}

const handleLogin = async () => {
  if (!loginFormRef.value) return

  try {
    await loginFormRef.value.validate()

    // 图形验证码验证
    if (showCaptcha.value) {
      if (loginForm.captcha.toUpperCase() !== captchaCode.value) {
        refreshCaptcha()
        throw new Error('图形验证码错误')
      }
    }

    // 验证码登录验证
    if (loginMethod.value !== 'password') {
      if (loginForm.verificationCode !== '123456') {
        throw new Error('验证码错误')
      }
    }

    loading.value = true

    // 调用登录API
    const credentials = {
      username: loginForm.username,
      password: loginForm.password,
      tenantId: loginForm.tenantId
    }

    const result = await authStore.login(credentials)

    if (result.success) {
      ElMessage.success('登录成功')
      // 跳转到主页
      router.push('/')
    }
  } catch (error) {
    ElMessage.error(error.message || '登录失败')
  } finally {
    loading.value = false
  }
}

const quickLogin = (account) => {
  loginForm.username = account.username
  loginForm.password = account.password
  if (account.tenantId) {
    loginForm.tenantId = account.tenantId
  }

  // 自动登录
  setTimeout(() => {
    handleLogin()
  }, 500)
}

// 生成图形验证码
const generateCaptcha = () => {
  if (!captchaCanvas.value) return

  const canvas = captchaCanvas.value
  const ctx = canvas.getContext('2d')

  // 清空画布
  ctx.clearRect(0, 0, canvas.width, canvas.height)

  // 生成随机验证码
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  let code = ''
  for (let i = 0; i < 4; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  captchaCode.value = code

  // 设置背景
  ctx.fillStyle = '#f0f2f5'
  ctx.fillRect(0, 0, canvas.width, canvas.height)

  // 绘制干扰线
  for (let i = 0; i < 5; i++) {
    ctx.strokeStyle = `hsl(${Math.random() * 360}, 50%, 70%)`
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(Math.random() * canvas.width, Math.random() * canvas.height)
    ctx.lineTo(Math.random() * canvas.width, Math.random() * canvas.height)
    ctx.stroke()
  }

  // 绘制验证码文字
  ctx.font = 'bold 20px Arial'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'

  for (let i = 0; i < code.length; i++) {
    ctx.fillStyle = `hsl(${Math.random() * 360}, 60%, 40%)`
    const x = 30 * i + 15
    const y = canvas.height / 2 + (Math.random() - 0.5) * 10
    const angle = (Math.random() - 0.5) * 0.5

    ctx.save()
    ctx.translate(x, y)
    ctx.rotate(angle)
    ctx.fillText(code[i], 0, 0)
    ctx.restore()
  }

  // 绘制干扰点
  for (let i = 0; i < 30; i++) {
    ctx.fillStyle = `hsl(${Math.random() * 360}, 50%, 60%)`
    ctx.beginPath()
    ctx.arc(Math.random() * canvas.width, Math.random() * canvas.height, 1, 0, 2 * Math.PI)
    ctx.fill()
  }
}

// 刷新验证码
const refreshCaptcha = () => {
  generateCaptcha()
  loginForm.captcha = ''
}

// 处理主题色切换
const handleThemeColorChange = (color) => {
  themeStore.setColor(color)
}

onMounted(() => {
  // 初始化主题
  themeStore.initTheme()

  // 如果已经登录，直接跳转到主页
  if (authStore.isLoggedIn) {
    router.push('/')
  }

  // 初始化图形验证码
  setTimeout(() => {
    generateCaptcha()
  }, 100)
})
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
}

/* 背景装饰 */
.login-background {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: hidden;
}

.bg-shape {
  position: absolute;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  animation: float 6s ease-in-out infinite;
}

.shape-1 {
  width: 200px;
  height: 200px;
  top: 10%;
  left: 10%;
  animation-delay: 0s;
}

.shape-2 {
  width: 150px;
  height: 150px;
  top: 60%;
  right: 10%;
  animation-delay: 2s;
}

.shape-3 {
  width: 100px;
  height: 100px;
  bottom: 20%;
  left: 20%;
  animation-delay: 4s;
}

@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(180deg); }
}

/* 主题控制 */
.theme-controls {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
  display: flex;
  gap: 10px;
}

.theme-toggle,
.color-picker {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border: none;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.theme-toggle:hover,
.color-picker:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

.color-option {
  display: flex;
  align-items: center;
  gap: 8px;
}

.color-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
}

/* 登录卡片 */
.login-card {
  background: var(--bg-card);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 40px;
  width: 100%;
  max-width: 450px;
  box-shadow: var(--shadow-xl);
  position: relative;
  z-index: 1;
  border: 1px solid var(--border-light);
  transition: background-color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease;
}

/* 深色模式下的登录卡片样式 */
[data-theme="dark"] .login-card {
  background: var(--bg-card);
  border-color: var(--border-color);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

/* 头部样式 */
.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.system-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0 0 8px 0;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.system-subtitle {
  font-size: 14px;
  color: var(--text-secondary);
  margin: 0;
}

/* 表单样式 */
.login-form-container {
  margin-bottom: 20px;
}

.login-form .el-form-item {
  margin-bottom: 20px;
}

.tenant-option {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tenant-name {
  font-weight: 500;
}

.tenant-code {
  font-size: 12px;
  color: var(--text-regular);
}

.login-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.login-button {
  width: 100%;
  height: 45px;
  font-size: 16px;
  font-weight: 600;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border: none;
}

/* 快速登录 */
.quick-login {
  margin: 30px 0;
  text-align: center;
}

.quick-login-title {
  font-size: 14px;
  color: var(--text-secondary);
  margin-bottom: 15px;
}

.quick-login-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

/* 登录方式 */
.login-methods {
  text-align: center;
  margin-top: 30px;
}

.method-divider {
  position: relative;
  margin-bottom: 20px;
}

.method-divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1px;
  background: #e4e7ed;
}

.method-divider span {
  background: white;
  padding: 0 15px;
  color: #909399;
  font-size: 12px;
  position: relative;
  z-index: 1;
}

.method-buttons {
  display: flex;
  justify-content: center;
  gap: 15px;
}

/* 底部 */
.login-footer {
  text-align: center;
  margin-top: 30px;
}

.copyright {
  font-size: 12px;
  color: #909399;
  margin: 0 0 10px 0;
}

.demo-notice {
  font-size: 12px;
  color: #e6a23c;
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
}

.demo-links {
  margin-top: 15px;
  text-align: center;
}

.demo-links .el-button {
  color: var(--text-secondary);
  font-size: 12px;
}

.demo-links .el-button:hover {
  color: var(--primary-color);
}

/* 二段式登录样式 */
.step-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 30px;
  padding: 0 20px;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.step-number {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 14px;
  background: #f5f7fa;
  color: #909399;
  transition: all 0.3s ease;
}

.step.active .step-number {
  background: #409eff;
  color: white;
}

.step.completed .step-number {
  background: #67c23a;
  color: white;
}

.step-label {
  font-size: 12px;
  color: #909399;
  transition: color 0.3s ease;
}

.step.active .step-label,
.step.completed .step-label {
  color: #303133;
  font-weight: 500;
}

.step-line {
  width: 60px;
  height: 2px;
  background: #e4e7ed;
  margin: 0 20px;
  transition: background 0.3s ease;
}

.step-line.active {
  background: #67c23a;
}

.step-title {
  text-align: center;
  margin-bottom: 30px;
}

.step-title h3 {
  margin: 0 0 8px 0;
  font-size: 20px;
  color: #303133;
}

.step-title p {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.input-hint {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
  line-height: 1.4;
}

.input-help {
  color: #909399;
  cursor: help;
}

.user-info-display {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: #f5f7fa;
  border-radius: 6px;
  margin-bottom: 20px;
}

.user-identifier {
  font-weight: 500;
  color: #303133;
}

.login-method-selector {
  margin-bottom: 20px;
}

.login-method-selector .el-radio-group {
  display: flex;
  justify-content: space-between;
  width: 100%;
}

.verification-input {
  display: flex;
  gap: 8px;
}

.verification-input .el-input {
  flex: 1;
}

.send-code-btn {
  white-space: nowrap;
  min-width: 100px;
}

.captcha-input {
  display: flex;
  gap: 8px;
  align-items: center;
}

.captcha-input .el-input {
  flex: 1;
}

.captcha-image {
  position: relative;
  cursor: pointer;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  overflow: hidden;
  transition: border-color 0.3s ease;
}

.captcha-image:hover {
  border-color: #409eff;
}

.captcha-image canvas {
  display: block;
}

.captcha-refresh {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(0, 0, 0, 0.7);
  color: white;
  text-align: center;
  font-size: 10px;
  padding: 2px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.captcha-image:hover .captcha-refresh {
  opacity: 1;
}

.step-one,
.step-two {
  animation: fadeInUp 0.3s ease;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式设计 */
@media (max-width: 480px) {
  .step-indicator {
    padding: 0 10px;
  }

  .step-line {
    width: 40px;
    margin: 0 10px;
  }

  .verification-input {
    flex-direction: column;
    gap: 12px;
  }

  .send-code-btn {
    width: 100%;
  }
}
</style>
