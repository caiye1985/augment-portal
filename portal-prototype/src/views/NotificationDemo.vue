<template>
  <PageLayout
    title="通知系统"
    description="消息推送和通知管理中心"
    icon="Bell"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新建通知
      </el-button>
      <el-button @click="markAllAsRead">
        <el-icon><Check /></el-icon>
        全部已读
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in notificationStatsCards" :key="stat.label">
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

    <!-- 功能标签页 -->
    <el-tabs v-model="activeTab" type="card" class="demo-tabs">
      <!-- 消息中心 -->
      <el-tab-pane label="消息中心" name="messages">
        <div class="tab-content">
          

          <!-- 消息筛选 -->
          <div class="message-filters">
            <el-button-group>
              <el-button
                :type="messageFilter === 'all' ? 'primary' : ''"
                @click="messageFilter = 'all'"
              >
                全部消息
              </el-button>
              <el-button
                :type="messageFilter === 'unread' ? 'primary' : ''"
                @click="messageFilter = 'unread'"
              >
                未读消息 <el-badge :value="unreadCount" class="item" />
              </el-button>
              <el-button
                :type="messageFilter === 'urgent' ? 'primary' : ''"
                @click="messageFilter = 'urgent'"
              >
                紧急通知
              </el-button>
              <el-button
                :type="messageFilter === 'system' ? 'primary' : ''"
                @click="messageFilter = 'system'"
              >
                系统通知
              </el-button>
            </el-button-group>

            <div class="filter-actions">
              <el-button @click="markAllAsRead">全部标记已读</el-button>
              <el-button @click="clearReadMessages">清空已读</el-button>
            </div>
          </div>

          <!-- 消息列表 -->
          <div class="message-list">
            <div
              v-for="message in filteredMessages"
              :key="message.id"
              class="message-item"
              :class="{ 'unread': !message.read, 'urgent': message.priority === 'urgent' }"
              @click="markAsRead(message)"
            >
              <div class="message-icon">
                <el-icon v-if="message.type === 'system'"><Setting /></el-icon>
                <el-icon v-else-if="message.type === 'ticket'"><Tickets /></el-icon>
                <el-icon v-else-if="message.type === 'alert'"><Warning /></el-icon>
                <el-icon v-else><Message /></el-icon>
              </div>

              <div class="message-content">
                <div class="message-header">
                  <h4 class="message-title">{{ message.title }}</h4>
                  <div class="message-meta">
                    <el-tag
                      :type="getPriorityType(message.priority)"
                      size="small"
                    >
                      {{ getPriorityText(message.priority) }}
                    </el-tag>
                    <span class="message-time">{{ formatTime(message.time) }}</span>
                  </div>
                </div>
                <p class="message-body">{{ message.content }}</p>
                <div class="message-actions" v-if="message.actions">
                  <el-button
                    v-for="action in message.actions"
                    :key="action.label"
                    size="small"
                    :type="action.type"
                    @click.stop="handleAction(action, message)"
                  >
                    {{ action.label }}
                  </el-button>
                </div>
              </div>

              <div class="message-status">
                <el-badge v-if="!message.read" is-dot />
              </div>
            </div>
          </div>

          <!-- 分页 -->
          <div class="pagination">
            <el-pagination
              v-model:current-page="currentPage"
              v-model:page-size="pageSize"
              :page-sizes="[10, 20, 50]"
              :total="filteredMessages.length"
              layout="total, sizes, prev, pager, next, jumper"
            />
          </div>
        </div>
      </el-tab-pane>

      <!-- 通知设置 -->
      <el-tab-pane label="通知设置" name="settings">
        <div class="tab-content">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-card title="通知渠道配置">
                <template #header>
                  <span>通知渠道配置</span>
                </template>

                <div class="setting-group">
                  <h4>邮件通知</h4>
                  <el-form label-width="120px">
                    <el-form-item label="启用邮件通知">
                      <el-switch v-model="settings.email.enabled" />
                    </el-form-item>
                    <el-form-item label="SMTP服务器">
                      <el-input v-model="settings.email.smtp" placeholder="smtp.example.com" />
                    </el-form-item>
                    <el-form-item label="端口">
                      <el-input v-model="settings.email.port" placeholder="587" />
                    </el-form-item>
                    <el-form-item label="发送邮箱">
                      <el-input v-model="settings.email.from" placeholder="noreply@example.com" />
                    </el-form-item>
                  </el-form>
                </div>

                <el-divider />

                <div class="setting-group">
                  <h4>短信通知</h4>
                  <el-form label-width="120px">
                    <el-form-item label="启用短信通知">
                      <el-switch v-model="settings.sms.enabled" />
                    </el-form-item>
                    <el-form-item label="服务商">
                      <el-select v-model="settings.sms.provider" style="width: 100%">
                        <el-option label="阿里云" value="aliyun" />
                        <el-option label="腾讯云" value="tencent" />
                        <el-option label="华为云" value="huawei" />
                      </el-select>
                    </el-form-item>
                    <el-form-item label="AccessKey">
                      <el-input v-model="settings.sms.accessKey" type="password" />
                    </el-form-item>
                  </el-form>
                </div>

                <el-divider />

                <div class="setting-group">
                  <h4>企业微信</h4>
                  <el-form label-width="120px">
                    <el-form-item label="启用企业微信">
                      <el-switch v-model="settings.wechat.enabled" />
                    </el-form-item>
                    <el-form-item label="企业ID">
                      <el-input v-model="settings.wechat.corpId" />
                    </el-form-item>
                    <el-form-item label="应用Secret">
                      <el-input v-model="settings.wechat.secret" type="password" />
                    </el-form-item>
                  </el-form>
                </div>
              </el-card>
            </el-col>

            <el-col :span="12">
              <el-card title="通知规则配置">
                <template #header>
                  <span>通知规则配置</span>
                </template>

                <div class="rule-list">
                  <div
                    v-for="rule in notificationRules"
                    :key="rule.id"
                    class="rule-item"
                  >
                    <div class="rule-header">
                      <h4>{{ rule.name }}</h4>
                      <el-switch v-model="rule.enabled" />
                    </div>
                    <p class="rule-description">{{ rule.description }}</p>
                    <div class="rule-channels">
                      <span>通知渠道：</span>
                      <el-tag
                        v-for="channel in rule.channels"
                        :key="channel"
                        size="small"
                        style="margin-right: 5px"
                      >
                        {{ getChannelText(channel) }}
                      </el-tag>
                    </div>
                    <div class="rule-actions">
                      <el-button size="small" @click="editRule(rule)">编辑</el-button>
                      <el-button size="small" @click="testRule(rule)">测试</el-button>
                    </div>
                  </div>
                </div>

                <el-button type="primary" style="width: 100%; margin-top: 16px">
                  添加通知规则
                </el-button>
              </el-card>
            </el-col>
          </el-row>

          <!-- 保存按钮 -->
          <div class="settings-actions">
            <el-button type="primary" @click="saveSettings">保存设置</el-button>
            <el-button @click="resetSettings">重置</el-button>
            <el-button @click="testNotification">发送测试通知</el-button>
          </div>
        </div>
      </el-tab-pane>

      <!-- 通知模板 -->
      <el-tab-pane label="通知模板" name="templates">
        <div class="tab-content">
          <div class="template-toolbar">
            <el-button type="primary" @click="createTemplate">
              <el-icon><Plus /></el-icon>
              创建模板
            </el-button>
          </div>

          <el-table :data="templates" stripe style="width: 100%">
            <el-table-column prop="name" label="模板名称" width="200" />
            <el-table-column prop="type" label="类型" width="120">
              <template #default="{ row }">
                <el-tag :type="getTemplateTypeColor(row.type)">
                  {{ getTemplateTypeText(row.type) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="subject" label="主题" min-width="200" />
            <el-table-column prop="channels" label="适用渠道" width="150">
              <template #default="{ row }">
                <el-tag
                  v-for="channel in row.channels"
                  :key="channel"
                  size="small"
                  style="margin-right: 5px"
                >
                  {{ getChannelText(channel) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.status === 'active' ? 'success' : 'info'">
                  {{ row.status === 'active' ? '启用' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="updatedTime" label="更新时间" width="160" />
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button size="small" @click="editTemplate(row)">编辑</el-button>
                <el-button size="small" @click="previewTemplate(row)">预览</el-button>
                <el-button size="small" type="danger" @click="deleteTemplate(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <!-- 发送记录 -->
      <el-tab-pane label="发送记录" name="logs">
        <div class="tab-content">
          <!-- 筛选条件 -->
          <div class="log-filters">
            <el-form inline>
              <el-form-item label="时间范围">
                <el-date-picker
                  v-model="logDateRange"
                  type="datetimerange"
                  range-separator="至"
                  start-placeholder="开始时间"
                  end-placeholder="结束时间"
                />
              </el-form-item>
              <el-form-item label="发送状态">
                <el-select v-model="logStatusFilter" placeholder="选择状态" clearable>
                  <el-option label="成功" value="success" />
                  <el-option label="失败" value="failed" />
                  <el-option label="发送中" value="sending" />
                </el-select>
              </el-form-item>
              <el-form-item label="通知渠道">
                <el-select v-model="logChannelFilter" placeholder="选择渠道" clearable>
                  <el-option label="邮件" value="email" />
                  <el-option label="短信" value="sms" />
                  <el-option label="企业微信" value="wechat" />
                  <el-option label="站内信" value="internal" />
                </el-select>
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="searchLogs">查询</el-button>
                <el-button @click="resetLogFilters">重置</el-button>
              </el-form-item>
            </el-form>
          </div>

          <!-- 发送记录表格 -->
          <el-table :data="sendLogs" stripe style="width: 100%">
            <el-table-column prop="id" label="记录ID" width="100" />
            <el-table-column prop="recipient" label="接收者" width="150" />
            <el-table-column prop="channel" label="渠道" width="100">
              <template #default="{ row }">
                <el-tag size="small">{{ getChannelText(row.channel) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="subject" label="主题" min-width="200" />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getLogStatusType(row.status)">
                  {{ getLogStatusText(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="sendTime" label="发送时间" width="160" />
            <el-table-column prop="errorMessage" label="错误信息" min-width="200" />
            <el-table-column label="操作" width="120" fixed="right">
              <template #default="{ row }">
                <el-button size="small" @click="viewLogDetail(row)">详情</el-button>
                <el-button
                  v-if="row.status === 'failed'"
                  size="small"
                  type="warning"
                  @click="resendNotification(row)"
                >
                  重发
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <!-- 分页 -->
          <div class="pagination">
            <el-pagination
              v-model:current-page="logCurrentPage"
              v-model:page-size="logPageSize"
              :page-sizes="[10, 20, 50, 100]"
              :total="sendLogs.length"
              layout="total, sizes, prev, pager, next, jumper"
            />
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Check, Refresh } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('messages')
const messageFilter = ref('all')
const currentPage = ref(1)
const pageSize = ref(10)
const logCurrentPage = ref(1)
const logPageSize = ref(20)
const logDateRange = ref([])
const logStatusFilter = ref('')
const logChannelFilter = ref('')

// 通知设置
const settings = ref({
  email: {
    enabled: true,
    smtp: 'smtp.example.com',
    port: '587',
    from: 'noreply@example.com'
  },
  sms: {
    enabled: false,
    provider: 'aliyun',
    accessKey: ''
  },
  wechat: {
    enabled: true,
    corpId: 'wx123456789',
    secret: ''
  }
})

// 演示数据
const messages = ref([
  {
    id: 1,
    type: 'system',
    title: '系统维护通知',
    content: '系统将于今晚22:00-24:00进行维护升级，期间可能影响部分功能使用。',
    priority: 'urgent',
    time: '2024-01-15 14:30:00',
    read: false,
    actions: [
      { label: '查看详情', type: 'primary', action: 'view' },
      { label: '确认知晓', type: 'success', action: 'confirm' }
    ]
  },
  {
    id: 2,
    type: 'ticket',
    title: '新工单分配通知',
    content: '您有一个新的紧急工单需要处理：服务器宕机故障 #TK-2024-001',
    priority: 'high',
    time: '2024-01-15 13:45:00',
    read: false,
    actions: [
      { label: '立即处理', type: 'primary', action: 'handle' }
    ]
  },
  {
    id: 3,
    type: 'alert',
    title: 'SLA超时预警',
    content: '工单 #TK-2024-002 即将超过SLA时限，请及时处理。',
    priority: 'high',
    time: '2024-01-15 12:20:00',
    read: true
  },
  {
    id: 4,
    type: 'info',
    title: '知识库更新',
    content: '新增了5篇技术文档，涵盖网络故障排查和服务器维护最佳实践。',
    priority: 'normal',
    time: '2024-01-15 10:15:00',
    read: true
  },
  {
    id: 5,
    type: 'system',
    title: '密码到期提醒',
    content: '您的密码将在7天后到期，请及时修改密码。',
    priority: 'normal',
    time: '2024-01-15 09:00:00',
    read: false
  }
])

const notificationRules = ref([
  {
    id: 1,
    name: '工单分配通知',
    description: '当工单被分配给工程师时发送通知',
    enabled: true,
    channels: ['email', 'internal']
  },
  {
    id: 2,
    name: 'SLA超时预警',
    description: '工单即将超过SLA时限时发送预警',
    enabled: true,
    channels: ['email', 'sms', 'wechat']
  },
  {
    id: 3,
    name: '系统故障告警',
    description: '系统检测到故障时立即发送告警',
    enabled: true,
    channels: ['sms', 'wechat']
  },
  {
    id: 4,
    name: '工单完成通知',
    description: '工单处理完成后通知相关人员',
    enabled: false,
    channels: ['email', 'internal']
  }
])

const templates = ref([
  {
    id: 1,
    name: '工单分配模板',
    type: 'ticket',
    subject: '新工单分配通知 - {{ticketTitle}}',
    channels: ['email', 'internal'],
    status: 'active',
    updatedTime: '2024-01-10 15:30:00'
  },
  {
    id: 2,
    name: 'SLA预警模板',
    type: 'alert',
    subject: 'SLA超时预警 - {{ticketNumber}}',
    channels: ['email', 'sms'],
    status: 'active',
    updatedTime: '2024-01-08 11:20:00'
  },
  {
    id: 3,
    name: '系统维护模板',
    type: 'system',
    subject: '系统维护通知',
    channels: ['email', 'wechat'],
    status: 'active',
    updatedTime: '2024-01-05 09:45:00'
  }
])

const sendLogs = ref([
  {
    id: 'LOG-001',
    recipient: 'zhang@example.com',
    channel: 'email',
    subject: '新工单分配通知 - 服务器宕机故障',
    status: 'success',
    sendTime: '2024-01-15 13:45:30',
    errorMessage: ''
  },
  {
    id: 'LOG-002',
    recipient: '13800138001',
    channel: 'sms',
    subject: 'SLA超时预警',
    status: 'failed',
    sendTime: '2024-01-15 12:20:15',
    errorMessage: '短信余额不足'
  },
  {
    id: 'LOG-003',
    recipient: 'admin@example.com',
    channel: 'email',
    subject: '系统维护通知',
    status: 'success',
    sendTime: '2024-01-15 14:30:00',
    errorMessage: ''
  }
])

// 计算属性
const unreadCount = computed(() => messages.value.filter(m => !m.read).length)
const todayCount = computed(() => {
  const today = new Date().toDateString()
  return messages.value.filter(m => new Date(m.time).toDateString() === today).length
})
const urgentCount = computed(() => messages.value.filter(m => m.priority === 'urgent').length)
const totalCount = computed(() => messages.value.length)

// 统计卡片数据
const notificationStatsCards = computed(() => [
  {
    label: '未读消息',
    value: unreadCount.value,
    icon: 'Message',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -8.3
  },
  {
    label: '今日消息',
    value: todayCount.value,
    icon: 'Calendar',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 15.7
  },
  {
    label: '紧急通知',
    value: urgentCount.value,
    icon: 'Warning',
    color: 'var(--el-color-error, #ef4444)',
    trend: -25.2
  },
  {
    label: '总消息数',
    value: totalCount.value,
    icon: 'Bell',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.5
  }
])

const filteredMessages = computed(() => {
  let filtered = messages.value

  switch (messageFilter.value) {
    case 'unread':
      filtered = filtered.filter(m => !m.read)
      break
    case 'urgent':
      filtered = filtered.filter(m => m.priority === 'urgent')
      break
    case 'system':
      filtered = filtered.filter(m => m.type === 'system')
      break
  }

  return filtered
})

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const showCreateDialog = ref(false)

const refreshData = () => {
  ElMessage.success('数据刷新成功')
}

const markAsRead = (message) => {
  message.read = true
  ElMessage.success('消息已标记为已读')
}

const markAllAsRead = () => {
  messages.value.forEach(m => m.read = true)
  ElMessage.success('所有消息已标记为已读')
}

const clearReadMessages = () => {
  ElMessageBox.confirm('确定要清空所有已读消息吗？', '确认清空', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const unreadMessages = messages.value.filter(m => !m.read)
    messages.value.splice(0, messages.value.length, ...unreadMessages)
    ElMessage.success('已读消息清空成功')
  })
}

const handleAction = (action, message) => {
  ElMessage.success(`执行操作：${action.label}`)
}

const getPriorityType = (priority) => {
  const types = {
    urgent: 'danger',
    high: 'warning',
    normal: '',
    low: 'info'
  }
  return types[priority] || ''
}

const getPriorityText = (priority) => {
  const texts = {
    urgent: '紧急',
    high: '高',
    normal: '普通',
    low: '低'
  }
  return texts[priority] || priority
}

const formatTime = (time) => {
  const now = new Date()
  const msgTime = new Date(time)
  const diff = now - msgTime

  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  return msgTime.toLocaleString()
}

const getChannelText = (channel) => {
  const texts = {
    email: '邮件',
    sms: '短信',
    wechat: '企业微信',
    internal: '站内信'
  }
  return texts[channel] || channel
}

const getTemplateTypeColor = (type) => {
  const colors = {
    ticket: 'primary',
    alert: 'warning',
    system: 'info',
    custom: 'success'
  }
  return colors[type] || ''
}

const getTemplateTypeText = (type) => {
  const texts = {
    ticket: '工单',
    alert: '告警',
    system: '系统',
    custom: '自定义'
  }
  return texts[type] || type
}

const getLogStatusType = (status) => {
  const types = {
    success: 'success',
    failed: 'danger',
    sending: 'warning'
  }
  return types[status] || ''
}

const getLogStatusText = (status) => {
  const texts = {
    success: '成功',
    failed: '失败',
    sending: '发送中'
  }
  return texts[status] || status
}

const saveSettings = () => {
  ElMessage.success('通知设置保存成功')
}

const resetSettings = () => {
  ElMessage.info('设置已重置')
}

const testNotification = () => {
  ElMessage.success('测试通知发送成功')
}

const editRule = (rule) => {
  ElMessage.info('编辑通知规则功能开发中...')
}

const testRule = (rule) => {
  ElMessage.success(`通知规则 "${rule.name}" 测试成功`)
}

const createTemplate = () => {
  ElMessage.info('创建模板功能开发中...')
}

const editTemplate = (template) => {
  ElMessage.info('编辑模板功能开发中...')
}

const previewTemplate = (template) => {
  ElMessage.info('预览模板功能开发中...')
}

const deleteTemplate = (template) => {
  ElMessageBox.confirm(`确定要删除模板 "${template.name}" 吗？`, '确认删除', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    const index = templates.value.findIndex(t => t.id === template.id)
    if (index !== -1) {
      templates.value.splice(index, 1)
    }
    ElMessage.success('模板删除成功')
  })
}

const searchLogs = () => {
  ElMessage.success('查询发送记录')
}

const resetLogFilters = () => {
  logDateRange.value = []
  logStatusFilter.value = ''
  logChannelFilter.value = ''
  ElMessage.info('筛选条件已重置')
}

const viewLogDetail = (log) => {
  ElMessage.info('查看发送记录详情功能开发中...')
}

const resendNotification = (log) => {
  ElMessageBox.confirm('确定要重新发送这条通知吗？', '确认重发', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    log.status = 'sending'
    setTimeout(() => {
      log.status = 'success'
      log.errorMessage = ''
      ElMessage.success('通知重发成功')
    }, 2000)
  })
}

onMounted(() => {
  console.log('通知系统模块已加载')
})
</script>

<style scoped>
.notification-demo {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  background: white;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.page-header h1 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 24px;
}

.page-header p {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.demo-tabs {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.tab-content {
  padding: 20px;
}

/* 统计卡片样式 */
.stats-row {
  margin-bottom: 24px;
}

.stat-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.stat-icon.unread {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-icon.today {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-icon.urgent {
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
  color: #e6a23c;
}

.stat-icon.total {
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  color: #409eff;
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 4px;
}

/* 消息筛选样式 */
.message-filters {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.filter-actions {
  display: flex;
  gap: 8px;
}

/* 消息列表样式 */
.message-list {
  background: white;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  overflow: hidden;
}

.message-item {
  display: flex;
  align-items: flex-start;
  padding: 16px;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.message-item:last-child {
  border-bottom: none;
}

.message-item:hover {
  background: #f8f9fa;
}

.message-item.unread {
  background: #f0f9ff;
  border-left: 4px solid #409eff;
}

.message-item.urgent {
  border-left: 4px solid #f56c6c;
}

.message-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #e4e7ed;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  flex-shrink: 0;
}

.message-content {
  flex: 1;
  min-width: 0;
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}

.message-title {
  margin: 0;
  font-size: 16px;
  font-weight: 500;
  color: #303133;
}

.message-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.message-time {
  font-size: 12px;
  color: #909399;
}

.message-body {
  margin: 0 0 12px 0;
  color: #606266;
  line-height: 1.5;
}

.message-actions {
  display: flex;
  gap: 8px;
}

.message-status {
  margin-left: 16px;
  flex-shrink: 0;
}

/* 设置页面样式 */
.setting-group {
  margin-bottom: 24px;
}

.setting-group h4 {
  margin: 0 0 16px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 500;
}

.settings-actions {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #e4e7ed;
  display: flex;
  gap: 12px;
}

/* 规则列表样式 */
.rule-list {
  max-height: 400px;
  overflow-y: auto;
}

.rule-item {
  padding: 16px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  margin-bottom: 12px;
  background: #fafafa;
}

.rule-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.rule-header h4 {
  margin: 0;
  font-size: 14px;
  font-weight: 500;
  color: #303133;
}

.rule-description {
  margin: 0 0 12px 0;
  color: #606266;
  font-size: 13px;
  line-height: 1.4;
}

.rule-channels {
  margin-bottom: 12px;
  font-size: 13px;
  color: #909399;
}

.rule-actions {
  display: flex;
  gap: 8px;
}

/* 模板工具栏 */
.template-toolbar {
  margin-bottom: 20px;
}

/* 日志筛选 */
.log-filters {
  background: #f8f9fa;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 20px;
}

/* 分页样式 */
.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .notification-demo {
    padding: 10px;
  }

  .stats-row .el-col {
    margin-bottom: 12px;
  }

  .message-filters {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .message-item {
    flex-direction: column;
    align-items: stretch;
  }

  .message-icon {
    align-self: flex-start;
    margin-bottom: 12px;
  }

  .message-header {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }

  .settings-actions {
    flex-direction: column;
  }
}

/* 表格样式优化 */
.el-table {
  border-radius: 8px;
  overflow: hidden;
}

.el-table .el-table__header {
  background: #f8f9fa;
}

.el-table .el-table__row:hover {
  background: #f5f7fa;
}

/* 卡片样式 */
.el-card {
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.el-card .el-card__header {
  background: #f8f9fa;
  border-bottom: 1px solid #e4e7ed;
}

/* 按钮样式 */
.el-button {
  border-radius: 6px;
}

.el-button-group .el-button {
  border-radius: 0;
}

.el-button-group .el-button:first-child {
  border-top-left-radius: 6px;
  border-bottom-left-radius: 6px;
}

.el-button-group .el-button:last-child {
  border-top-right-radius: 6px;
  border-bottom-right-radius: 6px;
}

/* 标签页样式 */
.demo-tabs .el-tabs__header {
  background: #f8f9fa;
  margin: 0;
  padding: 0 20px;
}

.demo-tabs .el-tabs__content {
  padding: 0;
}

/* 徽章样式 */
.el-badge {
  vertical-align: middle;
}

/* 表单样式 */
.el-form-item {
  margin-bottom: 18px;
}

.el-input, .el-select, .el-date-picker {
  border-radius: 6px;
}

/* 开关样式 */
.el-switch {
  vertical-align: middle;
}

/* 分割线样式 */
.el-divider {
  margin: 24px 0;
}
</style>
