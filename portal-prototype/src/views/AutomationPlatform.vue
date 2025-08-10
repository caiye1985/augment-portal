<template>
  <PageLayout
    title="自动化平台"
    description="Orion-Ops自动化运维平台集成配置和管理"
    icon="Setting"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>
        添加自动化服务器
      </el-button>
      <el-button @click="syncAllServers">
        <el-icon><Refresh /></el-icon>
        同步所有服务器
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in automationStatsCards" :key="stat.label">
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
        <!-- 自动化服务器列表 -->
        <el-tab-pane label="自动化服务器" name="servers">
          <div class="tab-content">
            <el-table :data="automationServers" style="width: 100%">
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
              <el-table-column label="健康度" width="120">
                <template #default="{ row }">
                  <el-progress
                    :percentage="row.healthScore"
                    :status="row.healthScore >= 80 ? 'success' : row.healthScore >= 60 ? 'warning' : 'exception'"
                    :stroke-width="8"
                  />
                </template>
              </el-table-column>
              <el-table-column prop="machineCount" label="管理机器数" width="120" />
              <el-table-column prop="lastSync" label="最后同步" width="180" />
              <el-table-column label="操作" width="400">
                <template #default="{ row }">
                  <el-button size="small" @click="testConnection(row)">测试连接</el-button>
                  <el-button
                    size="small"
                    type="warning"
                    @click="openConsole(row)"
                    :disabled="row.status !== 'connected'"
                    :title="row.status !== 'connected' ? '服务器未连接，无法打开控制台' : '打开Orion-Ops控制台'"
                  >
                    <el-icon><Monitor /></el-icon>
                    打开控制台
                  </el-button>
                  <el-button size="small" type="primary" @click="editServer(row)">编辑</el-button>
                  <el-button size="small" type="success" @click="syncServer(row)">同步</el-button>
                  <el-button size="small" type="danger" @click="deleteServer(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>

        <!-- 任务管理 -->
        <el-tab-pane label="任务管理" name="tasks">
          <div class="tab-content">
            <div class="task-toolbar">
              <el-button type="primary" @click="createTask">
                <el-icon><Plus /></el-icon>
                创建任务
              </el-button>
              <el-button @click="refreshTasks">
                <el-icon><Refresh /></el-icon>
                刷新任务
              </el-button>
            </div>

            <el-table :data="automationTasks" style="width: 100%; margin-top: 20px">
              <el-table-column prop="name" label="任务名称" width="200" />
              <el-table-column prop="type" label="任务类型" width="120" />
              <el-table-column prop="server" label="执行服务器" width="150" />
              <el-table-column label="状态" width="120">
                <template #default="{ row }">
                  <el-tag :type="getTaskStatusType(row.status)">
                    {{ getTaskStatusText(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="progress" label="进度" width="120">
                <template #default="{ row }">
                  <el-progress :percentage="row.progress" :status="row.progress === 100 ? 'success' : ''" />
                </template>
              </el-table-column>
              <el-table-column prop="createTime" label="创建时间" width="180" />
              <el-table-column label="操作" width="200">
                <template #default="{ row }">
                  <el-button size="small" @click="viewTaskDetail(row)">详情</el-button>
                  <el-button size="small" type="primary" @click="executeTask(row)" :disabled="row.status === 'running'">
                    {{ row.status === 'running' ? '执行中' : '执行' }}
                  </el-button>
                  <el-button size="small" type="danger" @click="deleteTask(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>

        <!-- 机器管理 -->
        <el-tab-pane label="机器管理" name="machines">
          <div class="tab-content">
            <el-row :gutter="20">
              <el-col :span="8">
                <el-card title="机器统计">
                  <div class="machine-stat">
                    <div class="stat-item">
                      <span class="stat-label">总机器数:</span>
                      <span class="stat-value">{{ machineStats.total }}</span>
                    </div>
                    <div class="stat-item">
                      <span class="stat-label">在线机器:</span>
                      <span class="stat-value">{{ machineStats.online }}</span>
                    </div>
                    <div class="stat-item">
                      <span class="stat-label">离线机器:</span>
                      <span class="stat-value">{{ machineStats.offline }}</span>
                    </div>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="16">
                <el-card title="机器列表">
                  <el-table :data="machines.slice(0, 5)" style="width: 100%">
                    <el-table-column prop="name" label="机器名称" />
                    <el-table-column prop="ip" label="IP地址" />
                    <el-table-column label="状态" width="100">
                      <template #default="{ row }">
                        <el-tag :type="row.status === 'online' ? 'success' : 'danger'">
                          {{ row.status === 'online' ? '在线' : '离线' }}
                        </el-tag>
                      </template>
                    </el-table-column>
                    <el-table-column prop="os" label="操作系统" />
                    <el-table-column label="操作" width="120">
                      <template #default="{ row }">
                        <el-button size="small" @click="connectMachine(row)">连接</el-button>
                      </template>
                    </el-table-column>
                  </el-table>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>

        <!-- 脚本管理 -->
        <el-tab-pane label="脚本管理" name="scripts">
          <div class="tab-content">
            <div class="script-toolbar">
              <el-button type="primary" @click="createScript">
                <el-icon><Plus /></el-icon>
                新建脚本
              </el-button>
              <el-button @click="importScript">
                <el-icon><Upload /></el-icon>
                导入脚本
              </el-button>
            </div>

            <el-table :data="scripts" style="width: 100%; margin-top: 20px">
              <el-table-column prop="name" label="脚本名称" width="200" />
              <el-table-column prop="type" label="脚本类型" width="120" />
              <el-table-column prop="description" label="描述" />
              <el-table-column prop="createTime" label="创建时间" width="180" />
              <el-table-column label="操作" width="200">
                <template #default="{ row }">
                  <el-button size="small" @click="editScript(row)">编辑</el-button>
                  <el-button size="small" type="primary" @click="executeScript(row)">执行</el-button>
                  <el-button size="small" type="danger" @click="deleteScript(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>
      </el-tabs>
    </template>

    <!-- 添加自动化服务器对话框 -->
    <el-dialog
      v-model="showAddDialog"
      title="添加自动化服务器"
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
        <el-form-item label="API Token">
          <el-input v-model="serverForm.apiToken" placeholder="请输入API Token（可选）" />
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
import { Plus, Refresh, Setting, Upload, Monitor } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'
import { useAuthStore } from '@/stores/auth'

// 响应式数据
const activeTab = ref('servers')
const showAddDialog = ref(false)
const serverFormRef = ref(null)
const authStore = useAuthStore()

// 自动化服务器列表
const automationServers = ref([
  {
    id: 1,
    name: 'Orion-Ops主服务器',
    host: 'orion.example.com',
    port: 8080,
    status: 'connected',
    version: 'v2.1.0',
    machineCount: 45,
    lastSync: '2024-01-15 14:30:00',
    description: '主要自动化服务器',
    healthScore: 95
  },
  {
    id: 2,
    name: 'Orion-Ops备用服务器',
    host: 'orion-backup.example.com',
    port: 8080,
    status: 'disconnected',
    version: 'v2.0.8',
    machineCount: 23,
    lastSync: '2024-01-14 18:20:00',
    description: '备用自动化服务器',
    healthScore: 0
  },
  {
    id: 3,
    name: 'Orion-Ops区域服务器',
    host: 'orion-region.example.com',
    port: 8080,
    status: 'connected',
    version: 'v2.1.0',
    machineCount: 32,
    lastSync: '2024-01-15 14:25:00',
    description: '区域自动化服务器',
    healthScore: 88
  }
])

// 自动化任务列表
const automationTasks = ref([
  {
    id: 1,
    name: '系统更新任务',
    type: '批量执行',
    server: 'Orion-Ops主服务器',
    status: 'completed',
    progress: 100,
    createTime: '2024-01-15 10:00:00'
  },
  {
    id: 2,
    name: '日志清理任务',
    type: '定时任务',
    server: 'Orion-Ops主服务器',
    status: 'running',
    progress: 65,
    createTime: '2024-01-15 14:00:00'
  },
  {
    id: 3,
    name: '配置部署任务',
    type: '应用发布',
    server: 'Orion-Ops备用服务器',
    status: 'pending',
    progress: 0,
    createTime: '2024-01-15 15:00:00'
  }
])

// 机器统计
const machineStats = reactive({
  total: 68,
  online: 62,
  offline: 6
})

// 机器列表
const machines = ref([
  { id: 1, name: 'web-server-01', ip: '192.168.1.10', status: 'online', os: 'CentOS 7' },
  { id: 2, name: 'web-server-02', ip: '192.168.1.11', status: 'online', os: 'CentOS 7' },
  { id: 3, name: 'db-server-01', ip: '192.168.1.20', status: 'offline', os: 'Ubuntu 20.04' },
  { id: 4, name: 'cache-server-01', ip: '192.168.1.30', status: 'online', os: 'CentOS 8' },
  { id: 5, name: 'monitor-server-01', ip: '192.168.1.40', status: 'online', os: 'Ubuntu 18.04' }
])

// 脚本列表
const scripts = ref([
  {
    id: 1,
    name: '系统监控脚本',
    type: 'Shell',
    description: '监控系统资源使用情况',
    createTime: '2024-01-10 09:00:00'
  },
  {
    id: 2,
    name: '日志清理脚本',
    type: 'Python',
    description: '清理过期日志文件',
    createTime: '2024-01-12 14:30:00'
  },
  {
    id: 3,
    name: '备份脚本',
    type: 'Shell',
    description: '数据库备份脚本',
    createTime: '2024-01-14 16:00:00'
  }
])

// 服务器表单
const serverForm = reactive({
  name: '',
  host: '',
  port: 8080,
  username: '',
  password: '',
  apiToken: '',
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
const automationStatsCards = computed(() => [
  {
    label: '自动化服务器',
    value: automationServers.value.length,
    icon: 'Setting',
    color: 'var(--el-color-primary)',
    trend: 0
  },
  {
    label: '管理机器数',
    value: machineStats.total,
    icon: 'Monitor',
    color: 'var(--el-color-success)',
    trend: 3
  },
  {
    label: '运行任务',
    value: automationTasks.value.filter(t => t.status === 'running').length,
    icon: 'Loading',
    color: 'var(--el-color-warning)',
    trend: 1
  },
  {
    label: '脚本数量',
    value: scripts.value.length,
    icon: 'Document',
    color: 'var(--el-color-info)',
    trend: 2
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

const getTaskStatusType = (status) => {
  const statusMap = {
    'pending': 'info',
    'running': 'warning',
    'completed': 'success',
    'failed': 'danger'
  }
  return statusMap[status] || 'info'
}

const getTaskStatusText = (status) => {
  const statusMap = {
    'pending': '等待中',
    'running': '运行中',
    'completed': '已完成',
    'failed': '失败'
  }
  return statusMap[status] || '未知'
}

const testConnection = async (server) => {
  ElMessage.info(`正在测试 ${server.name} 连接...`)
  await new Promise(resolve => setTimeout(resolve, 2000))
  ElMessage.success('连接测试成功')
}

const syncAllServers = async () => {
  ElMessage.info('正在同步所有服务器...')
  await new Promise(resolve => setTimeout(resolve, 3000))
  ElMessage.success('所有服务器同步完成')
}

const editServer = (server) => {
  ElMessage.info(`编辑服务器: ${server.name}`)
}

const syncServer = async (server) => {
  ElMessage.info(`正在同步 ${server.name}...`)
  await new Promise(resolve => setTimeout(resolve, 2000))
  ElMessage.success('服务器同步完成')
}

const deleteServer = async (server) => {
  try {
    await ElMessageBox.confirm(`确定要删除服务器 ${server.name} 吗？`, '确认删除', {
      type: 'warning'
    })
    const index = automationServers.value.findIndex(s => s.id === server.id)
    if (index > -1) {
      automationServers.value.splice(index, 1)
      ElMessage.success('删除成功')
    }
  } catch {
    ElMessage.info('已取消删除')
  }
}

const createTask = () => {
  ElMessage.info('创建新任务')
}

const refreshTasks = () => {
  ElMessage.success('任务列表刷新成功')
}

const viewTaskDetail = (task) => {
  ElMessage.info(`查看任务详情: ${task.name}`)
}

const executeTask = async (task) => {
  ElMessage.info(`正在执行任务: ${task.name}`)
  task.status = 'running'
  task.progress = 0

  // 模拟任务执行进度
  const interval = setInterval(() => {
    task.progress += 10
    if (task.progress >= 100) {
      task.status = 'completed'
      clearInterval(interval)
      ElMessage.success('任务执行完成')
    }
  }, 500)
}

const deleteTask = async (task) => {
  try {
    await ElMessageBox.confirm(`确定要删除任务 ${task.name} 吗？`, '确认删除', {
      type: 'warning'
    })
    const index = automationTasks.value.findIndex(t => t.id === task.id)
    if (index > -1) {
      automationTasks.value.splice(index, 1)
      ElMessage.success('删除成功')
    }
  } catch {
    ElMessage.info('已取消删除')
  }
}

const connectMachine = (machine) => {
  ElMessage.info(`连接到机器: ${machine.name}`)
}

const createScript = () => {
  ElMessage.info('创建新脚本')
}

const importScript = () => {
  ElMessage.info('导入脚本')
}

const editScript = (script) => {
  ElMessage.info(`编辑脚本: ${script.name}`)
}

const executeScript = (script) => {
  ElMessage.info(`执行脚本: ${script.name}`)
}

const deleteScript = async (script) => {
  try {
    await ElMessageBox.confirm(`确定要删除脚本 ${script.name} 吗？`, '确认删除', {
      type: 'warning'
    })
    const index = scripts.value.findIndex(s => s.id === script.id)
    if (index > -1) {
      scripts.value.splice(index, 1)
      ElMessage.success('删除成功')
    }
  } catch {
    ElMessage.info('已取消删除')
  }
}

const saveServer = async () => {
  if (!serverFormRef.value) return

  try {
    await serverFormRef.value.validate()

    const newServer = {
      id: Date.now(),
      ...serverForm,
      status: 'disconnected',
      version: 'v2.1.0',
      machineCount: 0,
      lastSync: new Date().toLocaleString(),
      healthScore: 0
    }

    automationServers.value.push(newServer)
    ElMessage.success('自动化服务器添加成功')
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

// 打开Orion-Ops控制台
const openConsole = (server) => {
  if (server.status !== 'connected') {
    ElMessage.warning('服务器未连接，无法打开控制台')
    return
  }

  try {
    // 构建Orion-Ops系统URL
    const token = authStore.token || 'dev-token'
    const consoleUrl = `/api/v1/proxy/orion-ops/${server.id}/?portal_token=${token}`

    // 在新窗口打开控制台
    const newWindow = window.open(consoleUrl, '_blank', 'width=1400,height=900,scrollbars=yes,resizable=yes')

    if (newWindow) {
      ElMessage.success(`正在打开 ${server.name} 的Orion-Ops控制台`)

      // 监听窗口关闭事件
      const checkClosed = setInterval(() => {
        if (newWindow.closed) {
          clearInterval(checkClosed)
          console.log(`Orion-Ops控制台窗口已关闭: ${server.name}`)
        }
      }, 1000)

      // 可选：向新窗口发送初始化消息
      setTimeout(() => {
        if (!newWindow.closed) {
          try {
            newWindow.postMessage({
              type: 'init',
              data: {
                serverId: server.id,
                serverName: server.name,
                modules: ['console', 'machine', 'exec', 'log'] // 支持的Orion-Ops模块
              }
            }, '*')
          } catch (error) {
            console.log('无法向Orion-Ops窗口发送消息:', error)
          }
        }
      }, 2000)
    } else {
      ElMessage.error('无法打开新窗口，请检查浏览器弹窗设置')
    }
  } catch (error) {
    console.error('打开Orion-Ops控制台失败:', error)
    ElMessage.error('打开Orion-Ops控制台失败，请稍后重试')
  }
}

onMounted(() => {
  console.log('自动化平台模块已加载')
})
</script>

<style scoped>
.tab-content {
  padding: 20px 0;
}

.task-toolbar,
.script-toolbar {
  margin-bottom: 20px;
}

.machine-stat .stat-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.machine-stat .stat-item:last-child {
  border-bottom: none;
}

.stat-label {
  color: #666;
}

.stat-value {
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
