<template>
  <PageLayout
    title="我的任务"
    description="查看和管理分配给我的工作任务"
    icon="List"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="createTask">
        <el-icon><Plus /></el-icon>
        新建任务
      </el-button>
      <el-button @click="loadTasks">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in taskStatsCards" :key="stat.label">
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

      <!-- 筛选和搜索 -->
      <div class="filter-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索任务标题或描述"
          style="width: 300px;"
          clearable
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>

        <el-select v-model="filterStatus" placeholder="任务状态" style="width: 150px;">
          <el-option label="全部" value="" />
          <el-option label="待处理" value="pending" />
          <el-option label="进行中" value="in-progress" />
          <el-option label="已完成" value="completed" />
          <el-option label="已逾期" value="overdue" />
        </el-select>

        <el-select v-model="filterPriority" placeholder="优先级" style="width: 120px;">
          <el-option label="全部" value="" />
          <el-option label="高" value="high" />
          <el-option label="中" value="medium" />
          <el-option label="低" value="low" />
        </el-select>

        <el-button @click="loadTasks">查询</el-button>
      </div>

      <!-- 任务列表 -->
      <div class="task-list">
        <div
          class="task-card"
          v-for="task in filteredTasks"
          :key="task.id"
          :class="{ 'overdue': task.isOverdue }"
        >
          <div class="task-header">
            <div class="task-title">
              <h3>{{ task.title }}</h3>
              <div class="task-tags">
                <el-tag :type="getPriorityType(task.priority)" size="small">
                  {{ getPriorityText(task.priority) }}
                </el-tag>
                <el-tag :type="getStatusType(task.status)" size="small">
                  {{ getStatusText(task.status) }}
                </el-tag>
                <el-tag v-if="task.isOverdue" type="danger" size="small">
                  已逾期
                </el-tag>
              </div>
            </div>
            <div class="task-actions">
              <el-button size="small" @click="viewTask(task)">查看</el-button>
              <el-button
                size="small"
                type="primary"
                @click="updateTaskStatus(task)"
                v-if="task.status !== 'completed'"
              >
                {{ task.status === 'pending' ? '开始' : '完成' }}
              </el-button>
            </div>
          </div>

          <div class="task-content">
            <div class="task-description">
              {{ task.description }}
            </div>

            <div class="task-info">
              <div class="info-item">
                <el-icon><Calendar /></el-icon>
                <span>创建时间: {{ task.createdAt }}</span>
              </div>
              <div class="info-item">
                <el-icon><Clock /></el-icon>
                <span>截止时间: {{ task.dueDate }}</span>
              </div>
              <div class="info-item">
                <el-icon><User /></el-icon>
                <span>分配人: {{ task.assignedBy }}</span>
              </div>
              <div class="info-item" v-if="task.ticketId">
                <el-icon><Document /></el-icon>
                <span>关联工单: #{{ task.ticketId }}</span>
              </div>
            </div>

            <div class="task-progress" v-if="task.status === 'in-progress'">
              <span class="progress-label">完成进度:</span>
              <el-progress
                :percentage="task.progress"
                :stroke-width="6"
                :show-text="true"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <div class="empty-state" v-if="filteredTasks.length === 0">
        <el-empty description="暂无任务数据">
          <el-button type="primary" @click="loadTasks">刷新数据</el-button>
        </el-empty>
      </div>

    <!-- 任务详情对话框 -->
    <el-dialog v-model="showTaskDialog" title="任务详情" width="600px">
      <div class="task-detail" v-if="selectedTask">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="detail-grid">
            <div class="detail-item">
              <span class="label">任务标题:</span>
              <span>{{ selectedTask.title }}</span>
            </div>
            <div class="detail-item">
              <span class="label">任务状态:</span>
              <el-tag :type="getStatusType(selectedTask.status)">
                {{ getStatusText(selectedTask.status) }}
              </el-tag>
            </div>
            <div class="detail-item">
              <span class="label">优先级:</span>
              <el-tag :type="getPriorityType(selectedTask.priority)">
                {{ getPriorityText(selectedTask.priority) }}
              </el-tag>
            </div>
            <div class="detail-item">
              <span class="label">分配人:</span>
              <span>{{ selectedTask.assignedBy }}</span>
            </div>
            <div class="detail-item">
              <span class="label">创建时间:</span>
              <span>{{ selectedTask.createdAt }}</span>
            </div>
            <div class="detail-item">
              <span class="label">截止时间:</span>
              <span>{{ selectedTask.dueDate }}</span>
            </div>
          </div>
        </div>

        <div class="detail-section">
          <h4>任务描述</h4>
          <p>{{ selectedTask.description }}</p>
        </div>

        <div class="detail-section" v-if="selectedTask.notes">
          <h4>备注信息</h4>
          <p>{{ selectedTask.notes }}</p>
        </div>
      </div>

      <template #footer>
        <el-button @click="showTaskDialog = false">关闭</el-button>
        <el-button
          type="primary"
          @click="updateTaskStatus(selectedTask)"
          v-if="selectedTask && selectedTask.status !== 'completed'"
        >
          {{ selectedTask.status === 'pending' ? '开始任务' : '完成任务' }}
        </el-button>
      </template>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Calendar, Clock, User, Document, Plus, Refresh } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const showTaskDialog = ref(false)
const selectedTask = ref(null)
const searchKeyword = ref('')
const filterStatus = ref('')
const filterPriority = ref('')

// 任务列表数据
const taskList = ref([
  {
    id: 1,
    title: '修复生产环境数据库连接问题',
    description: '生产环境数据库连接池配置异常，需要紧急修复',
    status: 'pending',
    priority: 'high',
    assignedBy: '张经理',
    createdAt: '2024-01-15 09:00',
    dueDate: '2024-01-15 18:00',
    ticketId: 'T001',
    progress: 0,
    isOverdue: false,
    notes: '需要在下班前完成修复'
  },
  {
    id: 2,
    title: '客户系统性能优化',
    description: '对客户A的系统进行性能分析和优化',
    status: 'in-progress',
    priority: 'medium',
    assignedBy: '李主管',
    createdAt: '2024-01-14 10:00',
    dueDate: '2024-01-18 17:00',
    ticketId: 'T002',
    progress: 45,
    isOverdue: false,
    notes: '已完成性能分析，正在进行优化'
  },
  {
    id: 3,
    title: '新员工技术培训准备',
    description: '准备下周新员工入职的技术培训材料',
    status: 'completed',
    priority: 'low',
    assignedBy: '王总监',
    createdAt: '2024-01-10 14:00',
    dueDate: '2024-01-14 17:00',
    ticketId: null,
    progress: 100,
    isOverdue: false,
    notes: '培训材料已准备完成'
  },
  {
    id: 4,
    title: '系统安全漏洞修复',
    description: '修复系统中发现的安全漏洞',
    status: 'pending',
    priority: 'high',
    assignedBy: '安全部',
    createdAt: '2024-01-12 16:00',
    dueDate: '2024-01-14 12:00',
    ticketId: 'T003',
    progress: 0,
    isOverdue: true,
    notes: '高优先级任务，需要立即处理'
  }
])

// 计算属性
const taskStats = computed(() => {
  const total = taskList.value.length
  const pending = taskList.value.filter(t => t.status === 'pending').length
  const inProgress = taskList.value.filter(t => t.status === 'in-progress').length
  const completed = taskList.value.filter(t => t.status === 'completed').length

  return { total, pending, inProgress, completed }
})

// 统计卡片数据
const taskStatsCards = computed(() => [
  {
    label: '总任务',
    value: taskStats.value.total,
    icon: 'List',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '待处理',
    value: taskStats.value.pending,
    icon: 'Clock',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -12.3
  },
  {
    label: '进行中',
    value: taskStats.value.inProgress,
    icon: 'Loading',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 5.7
  },
  {
    label: '已完成',
    value: taskStats.value.completed,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 15.2
  }
])

const filteredTasks = computed(() => {
  return taskList.value.filter(task => {
    const keywordMatch = !searchKeyword.value ||
      task.title.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
      task.description.toLowerCase().includes(searchKeyword.value.toLowerCase())

    const statusMatch = !filterStatus.value || task.status === filterStatus.value
    const priorityMatch = !filterPriority.value || task.priority === filterPriority.value

    return keywordMatch && statusMatch && priorityMatch
  })
})

// 方法
const getPriorityType = (priority) => {
  const types = { high: 'danger', medium: 'warning', low: 'info' }
  return types[priority] || 'info'
}

const getPriorityText = (priority) => {
  const texts = { high: '高', medium: '中', low: '低' }
  return texts[priority] || '未知'
}

const getStatusType = (status) => {
  const types = {
    pending: 'info',
    'in-progress': 'warning',
    completed: 'success',
    overdue: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待处理',
    'in-progress': '进行中',
    completed: '已完成',
    overdue: '已逾期'
  }
  return texts[status] || '未知'
}

// 统计卡片点击处理
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const createTask = () => {
  ElMessage.info('新建任务功能开发中...')
}

const loadTasks = () => {
  // 这里可以调用API加载数据
  ElMessage.success('任务数据已刷新')
}

const viewTask = (task) => {
  selectedTask.value = task
  showTaskDialog.value = true
}

const updateTaskStatus = async (task) => {
  try {
    let newStatus = ''
    let message = ''

    if (task.status === 'pending') {
      newStatus = 'in-progress'
      message = '任务已开始'
      task.progress = 10
    } else if (task.status === 'in-progress') {
      await ElMessageBox.confirm('确定要完成这个任务吗？', '确认完成', {
        type: 'warning'
      })
      newStatus = 'completed'
      message = '任务已完成'
      task.progress = 100
    }

    task.status = newStatus
    ElMessage.success(message)

    if (showTaskDialog.value) {
      showTaskDialog.value = false
    }
  } catch (error) {
    // 用户取消操作
  }
}

onMounted(() => {
  // 组件挂载时的初始化逻辑
})
</script>

<style scoped>
.my-tasks {
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

.task-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--bg-card);
  padding: 20px;
  border-radius: 8px;
  box-shadow: var(--shadow-sm);
  text-align: center;
  border-left: 4px solid var(--primary-color);
  border: 1px solid var(--border-color);
}

.stat-card.pending {
  border-left-color: #6b7280;
}

.stat-card.in-progress {
  border-left-color: #f59e0b;
}

.stat-card.completed {
  border-left-color: #10b981;
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

.filter-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  padding: 16px;
  background: #f9fafb;
  border-radius: 8px;
}

.task-list {
  display: grid;
  gap: 16px;
}

.task-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  border: 1px solid #e5e7eb;
  transition: all 0.2s;
}

.task-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.task-card.overdue {
  border-left: 4px solid #ef4444;
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.task-title {
  flex: 1;
}

.task-title h3 {
  margin: 0 0 8px 0;
  color: #1f2937;
}

.task-tags {
  display: flex;
  gap: 8px;
}

.task-actions {
  display: flex;
  gap: 8px;
}

.task-content {
  display: grid;
  gap: 16px;
}

.task-description {
  color: #6b7280;
  line-height: 1.5;
}

.task-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #6b7280;
  font-size: 14px;
}

.task-progress {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-label {
  font-weight: 500;
  color: #374151;
  min-width: 80px;
}

.empty-state {
  text-align: center;
  padding: 40px;
}

.task-detail {
  padding: 10px 0;
}

.detail-section {
  margin-bottom: 24px;
}

.detail-section h4 {
  margin: 0 0 12px 0;
  color: #1f2937;
  border-bottom: 1px solid #e5e7eb;
  padding-bottom: 8px;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 12px;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.detail-item .label {
  font-weight: 500;
  color: #374151;
  min-width: 80px;
}

/* 主题适配通过CSS变量统一管理，无需额外的深色模式样式 */
</style>
