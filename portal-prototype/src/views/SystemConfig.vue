<template>
  <PageLayout
    title="系统配置"
    description="系统参数配置、安全设置、集成配置管理"
    icon="Setting"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button @click="exportConfig">
        <el-icon><Download /></el-icon>
        导出配置
      </el-button>
      <el-button @click="importConfig">
        <el-icon><Upload /></el-icon>
        导入配置
      </el-button>
      <el-button type="primary" @click="saveAllConfig">
        <el-icon><Check /></el-icon>
        保存所有配置
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in configStatsCards" :key="stat.label">
          <StatCard
            :label="stat.label"
            :value="stat.value"
            :icon="stat.icon"
            :icon-color="stat.color"
            :trend="stat.trend"
            :loading="false"
            :clickable="true"
            @click="handleStatClick(stat)"
          />
        </el-col>
      </el-row>
    </template>

    <!-- 主要内容 -->
    <template #content>

    <!-- 配置选项卡 -->
    <el-tabs v-model="activeTab" class="config-tabs">
      <!-- 基础配置 -->
      <el-tab-pane label="基础配置" name="basic">
        <el-card>
          <template #header>
            <span>系统基础配置</span>
          </template>

          <el-form :model="basicConfig" label-width="150px">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="系统名称">
                  <el-input v-model="basicConfig.systemName" placeholder="请输入系统名称" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="系统版本">
                  <el-input v-model="basicConfig.systemVersion" placeholder="请输入系统版本" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="公司名称">
                  <el-input v-model="basicConfig.companyName" placeholder="请输入公司名称" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="联系邮箱">
                  <el-input v-model="basicConfig.contactEmail" placeholder="请输入联系邮箱" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="时区设置">
                  <el-select v-model="basicConfig.timezone" placeholder="请选择时区">
                    <el-option label="北京时间 (UTC+8)" value="Asia/Shanghai" />
                    <el-option label="东京时间 (UTC+9)" value="Asia/Tokyo" />
                    <el-option label="纽约时间 (UTC-5)" value="America/New_York" />
                    <el-option label="伦敦时间 (UTC+0)" value="Europe/London" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="默认语言">
                  <el-select v-model="basicConfig.defaultLanguage" placeholder="请选择默认语言">
                    <el-option label="简体中文" value="zh-CN" />
                    <el-option label="繁体中文" value="zh-TW" />
                    <el-option label="English" value="en-US" />
                    <el-option label="日本語" value="ja-JP" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="系统描述">
              <el-input
                v-model="basicConfig.systemDescription"
                type="textarea"
                :rows="3"
                placeholder="请输入系统描述"
              />
            </el-form-item>

            <el-form-item label="系统Logo">
              <el-upload
                class="logo-uploader"
                action="#"
                :show-file-list="false"
                :on-success="handleLogoSuccess"
                :before-upload="beforeLogoUpload"
              >
                <img v-if="basicConfig.logoUrl" :src="basicConfig.logoUrl" class="logo" />
                <el-icon v-else class="logo-uploader-icon"><Plus /></el-icon>
              </el-upload>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 安全配置 -->
      <el-tab-pane label="安全配置" name="security">
        <el-card>
          <template #header>
            <span>安全策略配置</span>
          </template>

          <el-form :model="securityConfig" label-width="150px">
            <el-form-item label="密码策略">
              <div class="password-policy">
                <el-checkbox v-model="securityConfig.passwordPolicy.requireUppercase">
                  包含大写字母
                </el-checkbox>
                <el-checkbox v-model="securityConfig.passwordPolicy.requireLowercase">
                  包含小写字母
                </el-checkbox>
                <el-checkbox v-model="securityConfig.passwordPolicy.requireNumbers">
                  包含数字
                </el-checkbox>
                <el-checkbox v-model="securityConfig.passwordPolicy.requireSpecialChars">
                  包含特殊字符
                </el-checkbox>
              </div>
            </el-form-item>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="最小密码长度">
                  <el-input-number
                    v-model="securityConfig.minPasswordLength"
                    :min="6"
                    :max="32"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="密码有效期(天)">
                  <el-input-number
                    v-model="securityConfig.passwordExpireDays"
                    :min="0"
                    :max="365"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="登录失败锁定次数">
                  <el-input-number
                    v-model="securityConfig.maxLoginAttempts"
                    :min="3"
                    :max="10"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="锁定时间(分钟)">
                  <el-input-number
                    v-model="securityConfig.lockoutDuration"
                    :min="5"
                    :max="1440"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="会话超时(分钟)">
                  <el-input-number
                    v-model="securityConfig.sessionTimeout"
                    :min="15"
                    :max="480"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="强制HTTPS">
                  <el-switch v-model="securityConfig.forceHttps" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="IP白名单">
              <el-input
                v-model="securityConfig.ipWhitelist"
                type="textarea"
                :rows="3"
                placeholder="每行一个IP地址或IP段，例如：192.168.1.0/24"
              />
            </el-form-item>

            <el-form-item label="安全功能">
              <el-checkbox-group v-model="securityConfig.securityFeatures">
                <el-checkbox label="enableCaptcha">启用图形验证码</el-checkbox>
                <el-checkbox label="enableTwoFactor">启用双因子认证</el-checkbox>
                <el-checkbox label="enableAuditLog">启用审计日志</el-checkbox>
                <el-checkbox label="enableLoginNotification">启用登录通知</el-checkbox>
              </el-checkbox-group>
            </el-form-item>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 邮件配置 -->
      <el-tab-pane label="邮件配置" name="email">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>邮件服务配置</span>
              <el-button size="small" @click="testEmailConfig">测试连接</el-button>
            </div>
          </template>

          <el-form :model="emailConfig" label-width="150px">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="SMTP服务器">
                  <el-input v-model="emailConfig.smtpHost" placeholder="请输入SMTP服务器地址" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="SMTP端口">
                  <el-input-number
                    v-model="emailConfig.smtpPort"
                    :min="1"
                    :max="65535"
                    style="width: 100%"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="用户名">
                  <el-input v-model="emailConfig.username" placeholder="请输入邮箱用户名" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="密码">
                  <el-input
                    v-model="emailConfig.password"
                    type="password"
                    placeholder="请输入邮箱密码"
                    show-password
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="发件人邮箱">
                  <el-input v-model="emailConfig.fromEmail" placeholder="请输入发件人邮箱" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="发件人名称">
                  <el-input v-model="emailConfig.fromName" placeholder="请输入发件人名称" />
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="加密方式">
                  <el-select v-model="emailConfig.encryption" placeholder="请选择加密方式">
                    <el-option label="无加密" value="none" />
                    <el-option label="SSL" value="ssl" />
                    <el-option label="TLS" value="tls" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="启用邮件服务">
                  <el-switch v-model="emailConfig.enabled" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-form>
        </el-card>
      </el-tab-pane>

      <!-- 集成配置 -->
      <el-tab-pane label="集成配置" name="integration">
        <el-card>
          <template #header>
            <span>第三方集成配置</span>
          </template>

          <el-collapse v-model="activeIntegrations">
            <!-- LDAP配置 -->
            <el-collapse-item title="LDAP认证" name="ldap">
              <el-form :model="integrationConfig.ldap" label-width="150px">
                <el-form-item label="启用LDAP">
                  <el-switch v-model="integrationConfig.ldap.enabled" />
                </el-form-item>

                <template v-if="integrationConfig.ldap.enabled">
                  <el-row :gutter="20">
                    <el-col :span="12">
                      <el-form-item label="LDAP服务器">
                        <el-input v-model="integrationConfig.ldap.host" placeholder="ldap://example.com" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="端口">
                        <el-input-number v-model="integrationConfig.ldap.port" :min="1" :max="65535" />
                      </el-form-item>
                    </el-col>
                  </el-row>

                  <el-form-item label="Base DN">
                    <el-input v-model="integrationConfig.ldap.baseDN" placeholder="dc=example,dc=com" />
                  </el-form-item>

                  <el-row :gutter="20">
                    <el-col :span="12">
                      <el-form-item label="管理员DN">
                        <el-input v-model="integrationConfig.ldap.adminDN" placeholder="cn=admin,dc=example,dc=com" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="管理员密码">
                        <el-input v-model="integrationConfig.ldap.adminPassword" type="password" show-password />
                      </el-form-item>
                    </el-col>
                  </el-row>
                </template>
              </el-form>
            </el-collapse-item>

            <!-- 钉钉配置 -->
            <el-collapse-item title="钉钉集成" name="dingtalk">
              <el-form :model="integrationConfig.dingtalk" label-width="150px">
                <el-form-item label="启用钉钉">
                  <el-switch v-model="integrationConfig.dingtalk.enabled" />
                </el-form-item>

                <template v-if="integrationConfig.dingtalk.enabled">
                  <el-row :gutter="20">
                    <el-col :span="12">
                      <el-form-item label="App Key">
                        <el-input v-model="integrationConfig.dingtalk.appKey" placeholder="请输入App Key" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="App Secret">
                        <el-input v-model="integrationConfig.dingtalk.appSecret" type="password" show-password />
                      </el-form-item>
                    </el-col>
                  </el-row>

                  <el-form-item label="Webhook URL">
                    <el-input v-model="integrationConfig.dingtalk.webhookUrl" placeholder="钉钉机器人Webhook地址" />
                  </el-form-item>
                </template>
              </el-form>
            </el-collapse-item>

            <!-- 企业微信配置 -->
            <el-collapse-item title="企业微信集成" name="wechat">
              <el-form :model="integrationConfig.wechat" label-width="150px">
                <el-form-item label="启用企业微信">
                  <el-switch v-model="integrationConfig.wechat.enabled" />
                </el-form-item>

                <template v-if="integrationConfig.wechat.enabled">
                  <el-row :gutter="20">
                    <el-col :span="12">
                      <el-form-item label="企业ID">
                        <el-input v-model="integrationConfig.wechat.corpId" placeholder="请输入企业ID" />
                      </el-form-item>
                    </el-col>
                    <el-col :span="12">
                      <el-form-item label="应用Secret">
                        <el-input v-model="integrationConfig.wechat.corpSecret" type="password" show-password />
                      </el-form-item>
                    </el-col>
                  </el-row>

                  <el-form-item label="应用ID">
                    <el-input v-model="integrationConfig.wechat.agentId" placeholder="请输入应用ID" />
                  </el-form-item>
                </template>
              </el-form>
            </el-collapse-item>
          </el-collapse>
        </el-card>
      </el-tab-pane>

      <!-- 系统监控 -->
      <el-tab-pane label="系统监控" name="monitoring">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-card>
              <template #header>
                <span>系统状态</span>
              </template>

              <div class="system-status">
                <div class="status-item">
                  <span class="status-label">CPU使用率</span>
                  <el-progress :percentage="systemStatus.cpuUsage" :color="getStatusColor(systemStatus.cpuUsage)" />
                </div>
                <div class="status-item">
                  <span class="status-label">内存使用率</span>
                  <el-progress :percentage="systemStatus.memoryUsage" :color="getStatusColor(systemStatus.memoryUsage)" />
                </div>
                <div class="status-item">
                  <span class="status-label">磁盘使用率</span>
                  <el-progress :percentage="systemStatus.diskUsage" :color="getStatusColor(systemStatus.diskUsage)" />
                </div>
                <div class="status-item">
                  <span class="status-label">网络延迟</span>
                  <span class="status-value">{{ systemStatus.networkLatency }}ms</span>
                </div>
              </div>
            </el-card>
          </el-col>

          <el-col :span="12">
            <el-card>
              <template #header>
                <span>服务状态</span>
              </template>

              <div class="service-status">
                <div
                  v-for="service in systemStatus.services"
                  :key="service.name"
                  class="service-item"
                >
                  <div class="service-info">
                    <span class="service-name">{{ service.name }}</span>
                    <el-tag :type="service.status === 'running' ? 'success' : 'danger'" size="small">
                      {{ service.status === 'running' ? '运行中' : '已停止' }}
                    </el-tag>
                  </div>
                  <div class="service-actions">
                    <el-button
                      v-if="service.status === 'stopped'"
                      size="small"
                      type="primary"
                      @click="startService(service)"
                    >
                      启动
                    </el-button>
                    <el-button
                      v-else
                      size="small"
                      type="warning"
                      @click="stopService(service)"
                    >
                      停止
                    </el-button>
                    <el-button size="small" @click="restartService(service)">重启</el-button>
                  </div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </el-tab-pane>
    </el-tabs>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Setting, Download, Upload, Check, Plus, Refresh, Lock
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('basic')
const activeIntegrations = ref(['ldap'])

// 统计卡片数据
const configStatsCards = computed(() => [
  {
    label: '配置项总数',
    value: 156,
    icon: 'Setting',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '已启用服务',
    value: 12,
    icon: 'Check',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.3
  },
  {
    label: '集成系统',
    value: activeIntegrations.value.length,
    icon: 'Plus',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 5.7
  },
  {
    label: '安全等级',
    value: 'A+',
    icon: 'Lock',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 0
  }
])

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
}

// 基础配置
const basicConfig = reactive({
  systemName: 'IT运维门户系统',
  systemVersion: '1.0.0',
  companyName: '示例科技有限公司',
  contactEmail: 'admin@example.com',
  timezone: 'Asia/Shanghai',
  defaultLanguage: 'zh-CN',
  systemDescription: '企业级IT运维管理平台，提供工单管理、资产管理、监控告警等功能',
  logoUrl: ''
})

// 安全配置
const securityConfig = reactive({
  passwordPolicy: {
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: false
  },
  minPasswordLength: 8,
  passwordExpireDays: 90,
  maxLoginAttempts: 5,
  lockoutDuration: 30,
  sessionTimeout: 120,
  forceHttps: true,
  ipWhitelist: '',
  securityFeatures: ['enableCaptcha', 'enableAuditLog']
})

// 邮件配置
const emailConfig = reactive({
  enabled: true,
  smtpHost: 'smtp.example.com',
  smtpPort: 587,
  username: 'noreply@example.com',
  password: '',
  fromEmail: 'noreply@example.com',
  fromName: 'IT运维系统',
  encryption: 'tls'
})

// 集成配置
const integrationConfig = reactive({
  ldap: {
    enabled: false,
    host: '',
    port: 389,
    baseDN: '',
    adminDN: '',
    adminPassword: ''
  },
  dingtalk: {
    enabled: false,
    appKey: '',
    appSecret: '',
    webhookUrl: ''
  },
  wechat: {
    enabled: false,
    corpId: '',
    corpSecret: '',
    agentId: ''
  }
})

// 系统状态
const systemStatus = ref({
  cpuUsage: 45,
  memoryUsage: 68,
  diskUsage: 32,
  networkLatency: 15,
  services: [
    { name: 'Web服务', status: 'running' },
    { name: '数据库服务', status: 'running' },
    { name: '缓存服务', status: 'running' },
    { name: '消息队列', status: 'stopped' },
    { name: '定时任务', status: 'running' }
  ]
})

// 方法
const getStatusColor = (percentage) => {
  if (percentage < 50) return '#67c23a'
  if (percentage < 80) return '#e6a23c'
  return '#f56c6c'
}

const handleLogoSuccess = (response, file) => {
  basicConfig.logoUrl = URL.createObjectURL(file.raw)
  ElMessage.success('Logo上传成功')
}

const beforeLogoUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

const testEmailConfig = async () => {
  try {
    ElMessage.info('正在测试邮件配置...')
    // 模拟测试邮件配置
    await new Promise(resolve => setTimeout(resolve, 2000))
    ElMessage.success('邮件配置测试成功')
  } catch (error) {
    ElMessage.error('邮件配置测试失败')
  }
}

const startService = (service) => {
  service.status = 'running'
  ElMessage.success(`${service.name} 启动成功`)
}

const stopService = (service) => {
  service.status = 'stopped'
  ElMessage.warning(`${service.name} 已停止`)
}

const restartService = (service) => {
  ElMessage.info(`正在重启 ${service.name}...`)
  setTimeout(() => {
    service.status = 'running'
    ElMessage.success(`${service.name} 重启成功`)
  }, 1000)
}

const saveAllConfig = () => {
  ElMessageBox.confirm('确定保存所有配置吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    ElMessage.success('配置保存成功')
  })
}

const exportConfig = () => {
  ElMessage.success('配置导出成功')
}

const importConfig = () => {
  ElMessage.info('导入配置功能开发中...')
}

// 定时更新系统状态
const updateSystemStatus = () => {
  systemStatus.value.cpuUsage = Math.floor(Math.random() * 100)
  systemStatus.value.memoryUsage = Math.floor(Math.random() * 100)
  systemStatus.value.diskUsage = Math.floor(Math.random() * 100)
  systemStatus.value.networkLatency = Math.floor(Math.random() * 50) + 5
}

onMounted(() => {
  // 每30秒更新一次系统状态
  setInterval(updateSystemStatus, 30000)
})
</script>

<style scoped>
.system-config {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
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

.config-tabs {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.password-policy {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.logo-uploader .logo {
  width: 100px;
  height: 100px;
  display: block;
  border-radius: 6px;
}

.logo-uploader .el-upload {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: border-color 0.3s;
}

.logo-uploader .el-upload:hover {
  border-color: #409eff;
}

.logo-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 100px;
  height: 100px;
  text-align: center;
  line-height: 100px;
}

.system-status {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.status-label {
  width: 80px;
  font-size: 14px;
  color: #606266;
}

.status-value {
  font-weight: 600;
  color: #303133;
}

.service-status {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.service-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 6px;
}

.service-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.service-name {
  font-weight: 500;
  color: #303133;
}

.service-actions {
  display: flex;
  gap: 8px;
}
</style>
