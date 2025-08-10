<template>
  <PageLayout
    title="我的消息"
    description="查看和管理个人消息通知"
    icon="ChatDotRound"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button @click="markAllAsRead" :disabled="messageStats.unread === 0">
        <el-icon><Check /></el-icon>
        全部标记为已读
      </el-button>
      <el-button @click="deleteSelected" :disabled="selectedMessages.length === 0">
        <el-icon><Delete /></el-icon>
        删除选中
      </el-button>
      <el-button @click="loadMessages">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in messageStatsCards" :key="stat.label">
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

      <!-- 操作栏 -->
      <div class="toolbar">
        <el-button @click="markAllAsRead" :disabled="messageStats.unread === 0">
          <el-icon><Check /></el-icon>
          全部标记为已读
        </el-button>
        <el-button @click="deleteSelected" :disabled="selectedMessages.length === 0">
          <el-icon><Delete /></el-icon>
          删除选中
        </el-button>
        <el-button @click="loadMessages">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>

      <!-- 筛选栏 -->
      <div class="filter-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索消息内容"
          style="width: 300px;"
          clearable
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>

        <el-select v-model="filterType" placeholder="消息类型" style="width: 150px;">
          <el-option label="全部" value="" />
          <el-option label="系统通知" value="system" />
          <el-option label="工单消息" value="ticket" />
          <el-option label="任务消息" value="task" />
          <el-option label="审批消息" value="approval" />
        </el-select>

        <el-select v-model="filterStatus" placeholder="读取状态" style="width: 120px;">
          <el-option label="全部" value="" />
          <el-option label="未读" value="unread" />
          <el-option label="已读" value="read" />
        </el-select>

        <el-checkbox v-model="showImportantOnly">仅显示重要消息</el-checkbox>
      </div>

      <!-- 消息列表 -->
      <div class="message-list">
        <div class="message-header">
          <el-checkbox
            v-model="selectAll"
            @change="handleSelectAll"
            :indeterminate="isIndeterminate"
          >
            全选
          </el-checkbox>
          <span class="message-count">共 {{ filteredMessages.length }} 条消息</span>
        </div>

        <div
          class="message-item"
          v-for="message in filteredMessages"
          :key="message.id"
          :class="{ 'unread': !message.isRead, 'important': message.isImportant }"
          @click="readMessage(message)"
        >
          <div class="message-checkbox">
            <el-checkbox
              v-model="selectedMessages"
              :label="message.id"
              @click.stop
            />
          </div>

          <div class="message-content">
            <div class="message-header-info">
              <div class="message-title">
                <span class="title-text">{{ message.title }}</span>
                <div class="message-badges">
                  <el-tag :type="getTypeColor(message.type)" size="small">
                    {{ getTypeText(message.type) }}
                  </el-tag>
                  <el-tag v-if="message.isImportant" type="danger" size="small">
                    重要
                  </el-tag>
                  <span v-if="!message.isRead" class="unread-dot"></span>
                </div>
              </div>
              <div class="message-meta">
                <span class="sender">{{ message.sender }}</span>
                <span class="time">{{ message.createdAt }}</span>
              </div>
            </div>

            <div class="message-preview">
              {{ message.content }}
            </div>

            <div class="message-actions" @click.stop>
              <el-button size="small" @click="readMessage(message)">
                {{ message.isRead ? '查看' : '标记已读' }}
              </el-button>
              <el-button size="small" @click="toggleImportant(message)">
                {{ message.isImportant ? '取消重要' : '标记重要' }}
              </el-button>
              <el-button size="small" type="danger" @click="deleteMessage(message)">
                删除
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div class="empty-state" v-if="filteredMessages.length === 0">
        <el-empty description="暂无消息数据">
          <el-button type="primary" @click="loadMessages">刷新数据</el-button>
        </el-empty>
      </div>

    <!-- 消息详情对话框 -->
    <el-dialog v-model="showMessageDialog" title="消息详情" width="600px">
      <div class="message-detail" v-if="selectedMessage">
        <div class="detail-header">
          <h3>{{ selectedMessage.title }}</h3>
          <div class="detail-meta">
            <el-tag :type="getTypeColor(selectedMessage.type)">
              {{ getTypeText(selectedMessage.type) }}
            </el-tag>
            <el-tag v-if="selectedMessage.isImportant" type="danger">
              重要消息
            </el-tag>
          </div>
        </div>

        <div class="detail-info">
          <div class="info-item">
            <span class="label">发送人:</span>
            <span>{{ selectedMessage.sender }}</span>
          </div>
          <div class="info-item">
            <span class="label">发送时间:</span>
            <span>{{ selectedMessage.createdAt }}</span>
          </div>
          <div class="info-item" v-if="selectedMessage.relatedId">
            <span class="label">关联ID:</span>
            <span>{{ selectedMessage.relatedId }}</span>
          </div>
        </div>

        <div class="detail-content">
          <h4>消息内容</h4>
          <div class="content-text">{{ selectedMessage.content }}</div>
        </div>

        <div class="detail-actions" v-if="selectedMessage.actions">
          <h4>可执行操作</h4>
          <div class="action-buttons">
            <el-button
              v-for="action in selectedMessage.actions"
              :key="action.key"
              :type="action.type"
              @click="executeAction(action)"
            >
              {{ action.label }}
            </el-button>
          </div>
        </div>
      </div>

      <template #footer>
        <el-button @click="showMessageDialog = false">关闭</el-button>
        <el-button
          type="primary"
          @click="toggleImportant(selectedMessage)"
          v-if="selectedMessage"
        >
          {{ selectedMessage.isImportant ? '取消重要' : '标记重要' }}
        </el-button>
      </template>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Check, Delete, Refresh, Search } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const showMessageDialog = ref(false)
const selectedMessage = ref(null)
const selectedMessages = ref([])
const searchKeyword = ref('')
const filterType = ref('')
const filterStatus = ref('')
const showImportantOnly = ref(false)
const selectAll = ref(false)

// 消息列表数据
const messageList = ref([
  {
    id: 1,
    title: '工单 #T001 已分配给您',
    content: '您有一个新的工单需要处理：修复生产环境数据库连接问题。请及时查看并处理。',
    type: 'ticket',
    sender: '系统自动',
    createdAt: '2024-01-15 09:30',
    isRead: false,
    isImportant: true,
    relatedId: 'T001',
    actions: [
      { key: 'view', label: '查看工单', type: 'primary' },
      { key: 'accept', label: '接受任务', type: 'success' }
    ]
  },
  {
    id: 2,
    title: '系统维护通知',
    content: '系统将于今晚22:00-24:00进行维护升级，期间可能影响部分功能使用，请提前做好准备。',
    type: 'system',
    sender: '运维部',
    createdAt: '2024-01-15 08:00',
    isRead: true,
    isImportant: true,
    relatedId: null,
    actions: null
  },
  {
    id: 3,
    title: '培训报名提醒',
    content: 'Java高级编程培训将于下周一开始，请确认您的参与状态。',
    type: 'task',
    sender: '人事部',
    createdAt: '2024-01-14 16:20',
    isRead: false,
    isImportant: false,
    relatedId: 'TR001',
    actions: [
      { key: 'confirm', label: '确认参与', type: 'success' },
      { key: 'decline', label: '无法参与', type: 'info' }
    ]
  },
  {
    id: 4,
    title: '工作流审批请求',
    content: '您有一个待审批的请假申请，申请人：张三，请假时间：2024-01-20至2024-01-22。',
    type: 'approval',
    sender: '工作流系统',
    createdAt: '2024-01-14 14:15',
    isRead: true,
    isImportant: false,
    relatedId: 'WF001',
    actions: [
      { key: 'approve', label: '批准', type: 'success' },
      { key: 'reject', label: '拒绝', type: 'danger' }
    ]
  },
  {
    id: 5,
    title: '密码即将过期提醒',
    content: '您的登录密码将在3天后过期，请及时修改密码以确保账户安全。',
    type: 'system',
    sender: '安全系统',
    createdAt: '2024-01-14 10:00',
    isRead: false,
    isImportant: false,
    relatedId: null,
    actions: [
      { key: 'change', label: '修改密码', type: 'primary' }
    ]
  }
])

// 计算属性
const messageStats = computed(() => {
  const total = messageList.value.length
  const unread = messageList.value.filter(m => !m.isRead).length
  const important = messageList.value.filter(m => m.isImportant).length

  return { total, unread, important }
})

// 统计卡片数据
const messageStatsCards = computed(() => [
  {
    label: '总消息',
    value: messageStats.value.total,
    icon: 'ChatDotRound',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 12.5
  },
  {
    label: '未读消息',
    value: messageStats.value.unread,
    icon: 'Bell',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -8.3
  },
  {
    label: '重要消息',
    value: messageStats.value.important,
    icon: 'Star',
    color: 'var(--el-color-error, #ef4444)',
    trend: 5.7
  },
  {
    label: '今日消息',
    value: messageList.value.filter(m => {
      const today = new Date().toDateString()
      return new Date(m.createdAt).toDateString() === today
    }).length,
    icon: 'Calendar',
    color: 'var(--el-color-success, #10b981)',
    trend: 15.2
  }
])

const filteredMessages = computed(() => {
  return messageList.value.filter(message => {
    const keywordMatch = !searchKeyword.value ||
      message.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      message.content.toLowerCase().includes(searchKeyword.value.toLowerCase())

    const typeMatch = !filterType.value || message.type === filterType.value
    const statusMatch = !filterStatus.value ||
      (filterStatus.value === 'read' && message.isRead) ||
      (filterStatus.value === 'unread' && !message.isRead)

    const importantMatch = !showImportantOnly.value || message.isImportant

    return keywordMatch && typeMatch && statusMatch && importantMatch
  })
})

const isIndeterminate = computed(() => {
  const selectedCount = selectedMessages.value.length
  const totalCount = filteredMessages.value.length
  return selectedCount > 0 && selectedCount < totalCount
})

// 方法
const getTypeColor = (type) => {
  const colors = {
    system: 'info',
    ticket: 'warning',
    task: 'primary',
    approval: 'success'
  }
  return colors[type] || 'info'
}

const getTypeText = (type) => {
  const texts = {
    system: '系统通知',
    ticket: '工单消息',
    task: '任务消息',
    approval: '审批消息'
  }
  return texts[type] || '未知'
}

const handleSelectAll = (checked) => {
  if (checked) {
    selectedMessages.value = filteredMessages.value.map(m => m.id)
  } else {
    selectedMessages.value = []
  }
}

const readMessage = (message) => {
  if (!message.isRead) {
    message.isRead = true
    ElMessage.success('消息已标记为已读')
  }
  selectedMessage.value = message
  showMessageDialog.value = true
}

const toggleImportant = (message) => {
  message.isImportant = !message.isImportant
  const action = message.isImportant ? '标记为重要' : '取消重要标记'
  ElMessage.success(`消息已${action}`)
}

const deleteMessage = async (message) => {
  try {
    await ElMessageBox.confirm('确定要删除这条消息吗？', '确认删除', {
      type: 'warning'
    })

    const index = messageList.value.findIndex(m => m.id === message.id)
    if (index > -1) {
      messageList.value.splice(index, 1)
      ElMessage.success('消息删除成功')
    }
  } catch (error) {
    // 用户取消删除
  }
}

const markAllAsRead = () => {
  messageList.value.forEach(message => {
    message.isRead = true
  })
  ElMessage.success('所有消息已标记为已读')
}

const deleteSelected = async () => {
  if (selectedMessages.value.length === 0) return

  try {
    await ElMessageBox.confirm(`确定要删除选中的 ${selectedMessages.value.length} 条消息吗？`, '确认删除', {
      type: 'warning'
    })

    selectedMessages.value.forEach(messageId => {
      const index = messageList.value.findIndex(m => m.id === messageId)
      if (index > -1) {
        messageList.value.splice(index, 1)
      }
    })

    selectedMessages.value = []
    selectAll.value = false
    ElMessage.success('选中的消息已删除')
  } catch (error) {
    // 用户取消删除
  }
}

const executeAction = (action) => {
  ElMessage.info(`执行操作: ${action.label}`)
  // 这里可以根据action.key执行具体的操作
}

// 统计卡片点击处理
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const loadMessages = () => {
  // 这里可以调用API加载数据
  ElMessage.success('消息数据已刷新')
}

onMounted(() => {
  // 组件挂载时的初始化逻辑
})
</script>

<style scoped>
.my-messages {
  padding: 20px;
  background: var(--bg-primary);
  color: var(--text-primary);
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0 0 8px 0;
  color: var(--text-primary);
}

.page-header p {
  margin: 0;
  color: var(--text-secondary);
}

.message-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  text-align: center;
  border-left: 4px solid #3b82f6;
}

.stat-card.unread {
  border-left-color: #f59e0b;
}

.stat-card.important {
  border-left-color: #ef4444;
}

.stat-number {
  font-size: 2rem;
  font-weight: bold;
  color: #1f2937;
  margin-bottom: 4px;
}

.stat-label {
  color: #6b7280;
  font-size: 14px;
}

.toolbar {
  margin-bottom: 16px;
}

.filter-bar {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 20px;
  padding: 16px;
  background: #f9fafb;
  border-radius: 8px;
}

.message-list {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.message-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e5e7eb;
}

.message-count {
  color: #6b7280;
  font-size: 14px;
}

.message-item {
  display: flex;
  padding: 16px 20px;
  border-bottom: 1px solid #f3f4f6;
  cursor: pointer;
  transition: all 0.2s;
}

.message-item:hover {
  background: #f9fafb;
}

.message-item.unread {
  background: #fef3c7;
}

.message-item.important {
  border-left: 4px solid #ef4444;
}

.message-checkbox {
  margin-right: 12px;
  display: flex;
  align-items: flex-start;
  padding-top: 2px;
}

.message-content {
  flex: 1;
}

.message-header-info {
  margin-bottom: 8px;
}

.message-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.title-text {
  font-weight: 500;
  color: #1f2937;
}

.message-badges {
  display: flex;
  align-items: center;
  gap: 8px;
}

.unread-dot {
  width: 8px;
  height: 8px;
  background: #ef4444;
  border-radius: 50%;
}

.message-meta {
  display: flex;
  gap: 16px;
  color: #6b7280;
  font-size: 14px;
}

.message-preview {
  color: #6b7280;
  line-height: 1.5;
  margin-bottom: 12px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.message-actions {
  display: flex;
  gap: 8px;
}

.empty-state {
  text-align: center;
  padding: 40px;
}

.message-detail {
  padding: 10px 0;
}

.detail-header {
  margin-bottom: 20px;
}

.detail-header h3 {
  margin: 0 0 8px 0;
  color: #1f2937;
}

.detail-meta {
  display: flex;
  gap: 8px;
}

.detail-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  margin-bottom: 20px;
  padding: 16px;
  background: #f9fafb;
  border-radius: 6px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.info-item .label {
  font-weight: 500;
  color: #374151;
  min-width: 80px;
}

.detail-content {
  margin-bottom: 20px;
}

.detail-content h4 {
  margin: 0 0 12px 0;
  color: #1f2937;
}

.content-text {
  line-height: 1.6;
  color: #374151;
  padding: 16px;
  background: #f9fafb;
  border-radius: 6px;
}

.detail-actions h4 {
  margin: 0 0 12px 0;
  color: #1f2937;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

/* 主题适配通过CSS变量统一管理，无需额外的深色模式样式 */
</style>
