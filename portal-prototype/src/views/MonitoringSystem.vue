<template>
  <PageLayout
    title="监控系统"
    description="夜莺监控系统集成配置和管理"
    icon="Monitor"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>
        添加监控服务器
      </el-button>
      <el-button @click="testAllConnections">
        <el-icon><Connection /></el-icon>
        批量测试连接
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in monitoringStatsCards" :key="stat.label">
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
      <el-tabs v-model="activeTab" type="card" class="demo-tabs">
        <!-- 监控服务器列表 -->
        <el-tab-pane label="监控服务器" name="servers">
          <div class="tab-content">
            <el-table :data="monitoringServers" style="width: 100%">
              <el-table-column prop="name" label="服务器名称" width="200" />
              <el-table-column prop="host" label="服务器地址" width="200" />
              <el-table-column prop="port" label="端口" width="100" />
              <el-table-column label="状态" width="120">
                <template #default="{ row }">
                  <el-tag :type="getStatusType(row.status)">
                    {{ getStatusText(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="version" label="版本" width="120" />
              <el-table-column prop="lastCheck" label="最后检查" width="180" />
              <el-table-column label="操作" width="380">
                <template #default="{ row }">
                  <el-button size="small" @click="testConnection(row)">测试连接</el-button>
                  <el-button
                    size="small"
                    type="success"
                    @click="openConsole(row)"
                    :disabled="row.status !== 'connected'"
                    :title="row.status !== 'connected' ? '服务器未连接，无法打开控制台' : '打开夜莺监控控制台'"
                  >
                    <el-icon><Monitor /></el-icon>
                    打开控制台
                  </el-button>
                  <el-button size="small" type="primary" @click="editServer(row)">编辑</el-button>
                  <el-button size="small" type="warning" @click="viewAlerts(row)">告警</el-button>
                  <el-button size="small" type="danger" @click="deleteServer(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>

        <!-- 告警配置 -->
        <el-tab-pane label="告警配置" name="alerts">
          <div class="tab-content">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-card title="告警规则">
                  <el-table :data="alertRules" style="width: 100%">
                    <el-table-column prop="name" label="规则名称" />
                    <el-table-column prop="metric" label="监控指标" />
                    <el-table-column prop="threshold" label="阈值" width="100" />
                    <el-table-column label="状态" width="100">
                      <template #default="{ row }">
                        <el-switch v-model="row.enabled" />
                      </template>
                    </el-table-column>
                    <el-table-column label="操作" width="120">
                      <template #default="{ row }">
                        <el-button size="small" @click="editRule(row)">编辑</el-button>
                      </template>
                    </el-table-column>
                  </el-table>
                </el-card>
              </el-col>
              <el-col :span="12">
                <el-card title="通知配置">
                  <el-form :model="notificationConfig" label-width="120px">
                    <el-form-item label="邮件通知">
                      <el-switch v-model="notificationConfig.email" />
                    </el-form-item>
                    <el-form-item label="短信通知">
                      <el-switch v-model="notificationConfig.sms" />
                    </el-form-item>
                    <el-form-item label="钉钉通知">
                      <el-switch v-model="notificationConfig.dingtalk" />
                    </el-form-item>
                    <el-form-item label="企业微信">
                      <el-switch v-model="notificationConfig.wechat" />
                    </el-form-item>
                    <el-form-item>
                      <el-button type="primary" @click="saveNotificationConfig">保存配置</el-button>
                    </el-form-item>
                  </el-form>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>

        <!-- 监控概览 -->
        <el-tab-pane label="监控概览" name="overview">
          <div class="tab-content">
            <el-row :gutter="20">
              <el-col :span="8">
                <el-card title="系统状态">
                  <div class="overview-item">
                    <span class="overview-label">CPU使用率:</span>
                    <span class="overview-value">65%</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">内存使用率:</span>
                    <span class="overview-value">78%</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">磁盘使用率:</span>
                    <span class="overview-value">45%</span>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="8">
                <el-card title="网络状态">
                  <div class="overview-item">
                    <span class="overview-label">网络延迟:</span>
                    <span class="overview-value">12ms</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">丢包率:</span>
                    <span class="overview-value">0.1%</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">带宽使用:</span>
                    <span class="overview-value">156Mbps</span>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="8">
                <el-card title="服务状态">
                  <div class="overview-item">
                    <span class="overview-label">在线服务:</span>
                    <span class="overview-value">23/25</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">告警数量:</span>
                    <span class="overview-value">3</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">响应时间:</span>
                    <span class="overview-value">156ms</span>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>
      </el-tabs>
    </template>

    <!-- 添加监控服务器对话框 -->
    <el-dialog
      v-model="showAddDialog"
      title="添加监控服务器"
      width="600px"
    >
      <el-form
        ref="serverFormRef"
        :model="serverForm"
        :rules="serverRules"
        label-width="120px"
      >
        <el-form-item label="服务器名称" prop="name">
          <el-input v-model="serverForm.name" placeholder="请输入服务器名称" />
        </el-form-item>
        <el-form-item label="服务器地址" prop="host">
          <el-input v-model="serverForm.host" placeholder="请输入服务器地址" />
        </el-form-item>
        <el-form-item label="端口" prop="port">
          <el-input-number v-model="serverForm.port" :min="1" :max="65535" style="width: 100%" />
        </el-form-item>
        <el-form-item label="用户名" prop="username">
          <el-input v-model="serverForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="serverForm.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="serverForm.description" type="textarea" :rows="3" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="saveServer">保存</el-button>
        </div>
      </template>
    </el-dialog>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Connection, Refresh, Monitor } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'
import { useAuthStore } from '@/stores/auth'

// 响应式数据
const activeTab = ref('servers')
const showAddDialog = ref(false)
const serverFormRef = ref(null)
const authStore = useAuthStore()

// 监控服务器列表
const monitoringServers = ref([
  {
    id: 1,
    name: '主监控服务器',
    host: 'monitor1.example.com',
    port: 8080,
    status: 'connected',
    version: 'v5.2.1',
    lastCheck: '2024-01-15 14:30:00',
    description: '主要监控服务器'
  },
  {
    id: 2,
    name: '备用监控服务器',
    host: 'monitor2.example.com',
    port: 8080,
    status: 'disconnected',
    version: 'v5.2.0',
    lastCheck: '2024-01-15 12:15:00',
    description: '备用监控服务器'
  },
  {
    id: 3,
    name: '区域监控服务器',
    host: 'monitor3.example.com',
    port: 8080,
    status: 'connected',
    version: 'v5.2.1',
    lastCheck: '2024-01-15 14:25:00',
    description: '区域监控服务器'
  }
])

// 告警规则
const alertRules = ref([
  {
    id: 1,
    name: 'CPU使用率告警',
    metric: 'cpu_usage',
    threshold: '80%',
    enabled: true
  },
  {
    id: 2,
    name: '内存使用率告警',
    metric: 'memory_usage',
    threshold: '85%',
    enabled: true
  },
  {
    id: 3,
    name: '磁盘使用率告警',
    metric: 'disk_usage',
    threshold: '90%',
    enabled: false
  }
])

// 通知配置
const notificationConfig = reactive({
  email: true,
  sms: false,
  dingtalk: true,
  wechat: false
})

// 服务器表单
const serverForm = reactive({
  name: '',
  host: '',
  port: 8080,
  username: '',
  password: '',
  description: ''
})

// 表单验证规则
const serverRules = {
  name: [
    { required: true, message: '请输入服务器名称', trigger: 'blur' }
  ],
  host: [
    { required: true, message: '请输入服务器地址', trigger: 'blur' }
  ],
  port: [
    { required: true, message: '请输入端口号', trigger: 'blur' }
  ],
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

// 统计卡片数据
const monitoringStatsCards = computed(() => [
  {
    label: '监控服务器',
    value: monitoringServers.value.length,
    icon: 'Monitor',
    color: 'var(--el-color-primary)',
    trend: 0
  },
  {
    label: '在线服务器',
    value: monitoringServers.value.filter(s => s.status === 'online').length,
    icon: 'Connection',
    color: 'var(--el-color-success)',
    trend: 0
  },
  {
    label: '活跃告警',
    value: 3,
    icon: 'Warning',
    color: 'var(--el-color-warning)',
    trend: -2
  },
  {
    label: '告警规则',
    value: alertRules.value.filter(r => r.enabled).length,
    icon: 'Setting',
    color: 'var(--el-color-info)',
    trend: 1
  }
])

// 方法
const handleStatClick = (stat) => {
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const getStatusType = (status) => {
  const statusTypes = {
    'connected': 'success',
    'disconnected': 'danger',
    'connecting': 'warning',
    'online': 'success',
    'offline': 'danger'
  }
  return statusTypes[status] || 'info'
}

const getStatusText = (status) => {
  const statusTexts = {
    'connected': '已连接',
    'disconnected': '未连接',
    'connecting': '连接中',
    'online': '在线',
    'offline': '离线'
  }
  return statusTexts[status] || status
}

const testConnection = async (server) => {
  ElMessage.info(`正在测试 ${server.name} 连接...`)
  await new Promise(resolve => setTimeout(resolve, 2000))
  ElMessage.success('连接测试成功')
}

const testAllConnections = async () => {
  ElMessage.info('正在批量测试连接...')
  await new Promise(resolve => setTimeout(resolve, 3000))
  ElMessage.success('批量连接测试完成')
}

const editServer = (server) => {
  ElMessage.info(`编辑服务器: ${server.name}`)
}

const viewAlerts = (server) => {
  ElMessage.info(`查看 ${server.name} 的告警信息`)
}

const deleteServer = async (server) => {
  try {
    await ElMessageBox.confirm(`确定要删除服务器 ${server.name} 吗？`, '确认删除', {
      type: 'warning'
    })
    const index = monitoringServers.value.findIndex(s => s.id === server.id)
    if (index > -1) {
      monitoringServers.value.splice(index, 1)
      ElMessage.success('删除成功')
    }
  } catch {
    ElMessage.info('已取消删除')
  }
}

const editRule = (rule) => {
  ElMessage.info(`编辑告警规则: ${rule.name}`)
}

const saveNotificationConfig = () => {
  ElMessage.success('通知配置保存成功')
}

const saveServer = async () => {
  if (!serverFormRef.value) return

  try {
    await serverFormRef.value.validate()

    const newServer = {
      id: Date.now(),
      ...serverForm,
      status: 'offline',
      version: 'v5.2.1',
      lastCheck: new Date().toLocaleString()
    }

    monitoringServers.value.push(newServer)
    ElMessage.success('监控服务器添加成功')
    showAddDialog.value = false

    // 重置表单
    Object.keys(serverForm).forEach(key => {
      if (key === 'port') {
        serverForm[key] = 8080
      } else {
        serverForm[key] = ''
      }
    })
  } catch (error) {
    ElMessage.error('请检查表单填写是否完整')
  }
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
}

// 打开监控控制台
const openConsole = (server) => {
  if (server.status !== 'connected') {
    ElMessage.warning('服务器未连接，无法打开控制台')
    return
  }

  try {
    // 构建夜莺监控系统URL
    const token = authStore.token || 'dev-token'
    const consoleUrl = `/api/v1/proxy/nightingale/${server.id}/?portal_token=${token}`

    // 在新窗口打开控制台
    const newWindow = window.open(consoleUrl, '_blank', 'width=1200,height=800,scrollbars=yes,resizable=yes')

    if (newWindow) {
      ElMessage.success(`正在打开 ${server.name} 的监控控制台`)

      // 监听窗口关闭事件
      const checkClosed = setInterval(() => {
        if (newWindow.closed) {
          clearInterval(checkClosed)
          console.log(`监控控制台窗口已关闭: ${server.name}`)
        }
      }, 1000)
    } else {
      ElMessage.error('无法打开新窗口，请检查浏览器弹窗设置')
    }
  } catch (error) {
    console.error('打开监控控制台失败:', error)
    ElMessage.error('打开监控控制台失败，请稍后重试')
  }
}

onMounted(() => {
  console.log('监控系统模块已加载')
})
</script>

<style scoped>
.tab-content {
  padding: 20px 0;
}

.overview-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.overview-item:last-child {
  border-bottom: none;
}

.overview-label {
  color: #666;
}

.overview-value {
  font-weight: 600;
  color: #333;
}

.demo-tabs {
  margin-top: 20px;
}

.dialog-footer {
  text-align: right;
}
</style>
