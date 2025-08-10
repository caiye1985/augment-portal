<template>
  <PageLayout
    title="工作流审批系统"
    description="可视化流程设计、智能审批、进度跟踪"
    icon="Share"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showDesigner = true">
        <el-icon><Plus /></el-icon>
        创建流程
      </el-button>
      <el-button @click="showApplyDialog = true">
        <el-icon><Document /></el-icon>
        发起申请
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in workflowStatsCards" :key="stat.label">
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

    <!-- 主要内容区 -->
    <el-tabs v-model="activeTab" class="workflow-tabs">
      <!-- 我的任务 -->
      <el-tab-pane label="我的任务" name="tasks">
        <el-card shadow="never">
          <el-table :data="myTasks" v-loading="loading">
            <el-table-column prop="title" label="申请标题" width="200" />
            <el-table-column prop="type" label="申请类型" width="120">
              <template #default="{ row }">
                <el-tag :type="getTypeColor(row.type)">{{ row.type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="applicant" label="申请人" width="100" />
            <el-table-column prop="currentStep" label="当前步骤" width="150" />
            <el-table-column prop="priority" label="优先级" width="100">
              <template #default="{ row }">
                <el-tag :type="getPriorityColor(row.priority)" size="small">{{ row.priority }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="deadline" label="截止时间" width="150" />
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getStatusColor(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200">
              <template #default="{ row }">
                <el-button size="small" @click="viewDetail(row)">查看</el-button>
                <el-button size="small" type="success" @click="approveTask(row)" v-if="row.status === '待审批'">
                  同意
                </el-button>
                <el-button size="small" type="danger" @click="rejectTask(row)" v-if="row.status === '待审批'">
                  拒绝
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 我的申请 -->
      <el-tab-pane label="我的申请" name="applications">
        <el-card shadow="never">
          <el-table :data="myApplications">
            <el-table-column prop="title" label="申请标题" width="200" />
            <el-table-column prop="type" label="申请类型" width="120">
              <template #default="{ row }">
                <el-tag :type="getTypeColor(row.type)">{{ row.type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createTime" label="申请时间" width="150" />
            <el-table-column prop="currentStep" label="当前步骤" width="150" />
            <el-table-column prop="progress" label="进度" width="120">
              <template #default="{ row }">
                <el-progress :percentage="row.progress" :color="getProgressColor(row.progress)" />
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getStatusColor(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click="viewProgress(row)">进度</el-button>
                <el-button size="small" type="warning" @click="withdrawApp(row)" v-if="row.status === '审批中'">
                  撤回
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 流程模板 -->
      <el-tab-pane label="流程模板" name="templates">
        <el-card shadow="never">
          <div class="template-grid">
            <div v-for="template in workflowTemplates" :key="template.id" class="template-card">
              <el-card shadow="hover" class="template-item">
                <div class="template-header">
                  <el-icon class="template-icon"><Document /></el-icon>
                  <h3>{{ template.name }}</h3>
                </div>
                <p class="template-desc">{{ template.description }}</p>
                <div class="template-stats">
                  <span>使用次数: {{ template.usageCount }}</span>
                  <span>平均时长: {{ template.avgDuration }}</span>
                </div>
                <div class="template-actions">
                  <el-button size="small" @click="useTemplate(template)">使用模板</el-button>
                  <el-button size="small" @click="editTemplate(template)">编辑</el-button>
                </div>
              </el-card>
            </div>
          </div>
        </el-card>
      </el-tab-pane>

      <!-- 流程设计 -->
      <el-tab-pane label="流程设计" name="design">
        <el-card shadow="never">
          <div class="designer-container">
            <div class="designer-toolbar">
              <el-button-group>
                <el-button @click="addNode('start')">开始节点</el-button>
                <el-button @click="addNode('approval')">审批节点</el-button>
                <el-button @click="addNode('condition')">条件节点</el-button>
                <el-button @click="addNode('end')">结束节点</el-button>
              </el-button-group>
              <div class="toolbar-actions">
                <el-button @click="saveWorkflow">保存</el-button>
                <el-button type="primary" @click="publishWorkflow">发布</el-button>
              </div>
            </div>
            <div class="designer-canvas" ref="designerCanvas">
              <div class="canvas-placeholder">
                <el-icon><Share /></el-icon>
                <p>拖拽节点到此处开始设计流程</p>
              </div>
            </div>
          </div>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <!-- 申请对话框 -->
    <el-dialog v-model="showApplyDialog" title="发起申请" width="600px">
      <el-form :model="newApplication" :rules="applicationRules" ref="applicationForm" label-width="100px">
        <el-form-item label="申请类型" prop="type">
          <el-select v-model="newApplication.type" placeholder="请选择申请类型">
            <el-option label="请假申请" value="请假申请" />
            <el-option label="设备采购" value="设备采购" />
            <el-option label="权限申请" value="权限申请" />
            <el-option label="系统变更" value="系统变更" />
          </el-select>
        </el-form-item>
        <el-form-item label="申请标题" prop="title">
          <el-input v-model="newApplication.title" placeholder="请输入申请标题" />
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="newApplication.priority" placeholder="请选择优先级">
            <el-option label="紧急" value="紧急" />
            <el-option label="高" value="高" />
            <el-option label="中" value="中" />
            <el-option label="低" value="低" />
          </el-select>
        </el-form-item>
        <el-form-item label="申请内容" prop="content">
          <el-input v-model="newApplication.content" type="textarea" rows="4" placeholder="请详细描述申请内容" />
        </el-form-item>
        <el-form-item label="附件">
          <el-upload
            class="upload-demo"
            drag
            action="#"
            multiple
            :auto-upload="false"
          >
            <el-icon class="el-icon--upload"><UploadFilled /></el-icon>
            <div class="el-upload__text">
              将文件拖到此处，或<em>点击上传</em>
            </div>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showApplyDialog = false">取消</el-button>
        <el-button type="primary" @click="submitApplication">提交申请</el-button>
      </template>
    </el-dialog>

    <!-- 进度跟踪对话框 -->
    <el-dialog v-model="showProgressDialog" title="审批进度" width="800px">
      <div class="progress-timeline">
        <el-timeline>
          <el-timeline-item
            v-for="(step, index) in progressSteps"
            :key="index"
            :type="getTimelineType(step.status)"
            :timestamp="step.time"
          >
            <div class="timeline-content">
              <h4>{{ step.title }}</h4>
              <p>{{ step.description }}</p>
              <div v-if="step.approver" class="approver-info">
                <span>审批人: {{ step.approver }}</span>
                <span v-if="step.comment" class="comment">意见: {{ step.comment }}</span>
              </div>
            </div>
          </el-timeline-item>
        </el-timeline>
      </div>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Share, Plus, Document, ArrowUp, ArrowDown, UploadFilled, Refresh, CircleCheck, Clock, TrendCharts } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('tasks')
const loading = ref(false)
const showDesigner = ref(false)
const showApplyDialog = ref(false)
const showProgressDialog = ref(false)
const designerCanvas = ref(null)

// 统计数据
const pendingApprovals = ref(23)
const completedApprovals = ref(156)

// 统计卡片数据
const workflowStatsCards = computed(() => [
  {
    label: '待审批',
    value: pendingApprovals.value,
    icon: 'Document',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 12
  },
  {
    label: '已完成',
    value: completedApprovals.value,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 8
  },
  {
    label: '平均处理时间',
    value: '2.5小时',
    icon: 'Clock',
    color: 'var(--el-color-info, #3b82f6)',
    trend: -15
  },
  {
    label: '审批通过率',
    value: '94.2%',
    icon: 'TrendCharts',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 2
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

// 我的任务数据
const myTasks = ref([
  {
    id: '1',
    title: '张三的请假申请',
    type: '请假申请',
    applicant: '张三',
    currentStep: '部门经理审批',
    priority: '中',
    deadline: '2024-01-16 18:00',
    status: '待审批'
  },
  {
    id: '2',
    title: '服务器采购申请',
    type: '设备采购',
    applicant: '李四',
    currentStep: 'IT部门审批',
    priority: '高',
    deadline: '2024-01-17 12:00',
    status: '待审批'
  },
  {
    id: '3',
    title: '数据库权限申请',
    type: '权限申请',
    applicant: '王五',
    currentStep: '安全审核',
    priority: '紧急',
    deadline: '2024-01-15 16:00',
    status: '审批中'
  }
])

// 我的申请数据
const myApplications = ref([
  {
    id: '1',
    title: '年假申请',
    type: '请假申请',
    createTime: '2024-01-10 09:00',
    currentStep: 'HR审批',
    progress: 75,
    status: '审批中'
  },
  {
    id: '2',
    title: '办公设备申请',
    type: '设备采购',
    createTime: '2024-01-08 14:30',
    currentStep: '已完成',
    progress: 100,
    status: '已通过'
  }
])

// 流程模板数据
const workflowTemplates = ref([
  {
    id: '1',
    name: '请假审批流程',
    description: '员工请假申请的标准审批流程',
    usageCount: 245,
    avgDuration: '2.5小时'
  },
  {
    id: '2',
    name: '设备采购流程',
    description: '办公设备和IT设备采购审批流程',
    usageCount: 89,
    avgDuration: '1.5天'
  },
  {
    id: '3',
    name: '权限申请流程',
    description: '系统权限和数据访问权限申请流程',
    usageCount: 156,
    avgDuration: '4小时'
  }
])

// 新申请表单
const newApplication = reactive({
  type: '',
  title: '',
  priority: '',
  content: ''
})

const applicationRules = {
  type: [{ required: true, message: '请选择申请类型', trigger: 'change' }],
  title: [{ required: true, message: '请输入申请标题', trigger: 'blur' }],
  priority: [{ required: true, message: '请选择优先级', trigger: 'change' }],
  content: [{ required: true, message: '请输入申请内容', trigger: 'blur' }]
}

// 进度步骤数据
const progressSteps = ref([
  {
    title: '申请提交',
    description: '申请已成功提交',
    status: 'success',
    time: '2024-01-10 09:00',
    approver: '系统',
    comment: ''
  },
  {
    title: '部门经理审批',
    description: '等待部门经理审批',
    status: 'success',
    time: '2024-01-10 10:30',
    approver: '张经理',
    comment: '同意申请'
  },
  {
    title: 'HR审批',
    description: '等待HR部门审批',
    status: 'primary',
    time: '2024-01-10 14:20',
    approver: '李主管',
    comment: ''
  },
  {
    title: '审批完成',
    description: '审批流程完成',
    status: 'info',
    time: '',
    approver: '',
    comment: ''
  }
])

// 方法
const getTypeColor = (type) => {
  const colors = {
    '请假申请': 'success',
    '设备采购': 'warning',
    '权限申请': 'danger',
    '系统变更': 'info'
  }
  return colors[type] || 'info'
}

const getPriorityColor = (priority) => {
  const colors = {
    '紧急': 'danger',
    '高': 'warning',
    '中': 'primary',
    '低': 'info'
  }
  return colors[priority] || 'info'
}

const getStatusColor = (status) => {
  const colors = {
    '待审批': 'warning',
    '审批中': 'primary',
    '已通过': 'success',
    '已拒绝': 'danger'
  }
  return colors[status] || 'info'
}

const getProgressColor = (progress) => {
  if (progress === 100) return '#67c23a'
  if (progress >= 50) return '#409eff'
  return '#e6a23c'
}

const getTimelineType = (status) => {
  const types = {
    'success': 'success',
    'primary': 'primary',
    'info': 'info'
  }
  return types[status] || 'info'
}

const viewDetail = (task) => {
  ElMessage.info(`查看任务详情: ${task.title}`)
}

const approveTask = (task) => {
  ElMessageBox.confirm(
    `确定要同意 "${task.title}" 吗？`,
    '确认审批',
    {
      confirmButtonText: '同意',
      cancelButtonText: '取消',
      type: 'success'
    }
  ).then(() => {
    task.status = '已通过'
    ElMessage.success('审批成功')
  })
}

const rejectTask = (task) => {
  ElMessageBox.prompt('请输入拒绝理由', '拒绝审批', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea'
  }).then(({ value }) => {
    task.status = '已拒绝'
    ElMessage.success('已拒绝申请')
  })
}

const viewProgress = (app) => {
  showProgressDialog.value = true
}

const withdrawApp = (app) => {
  ElMessageBox.confirm(
    `确定要撤回 "${app.title}" 吗？`,
    '确认撤回',
    {
      confirmButtonText: '撤回',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('申请已撤回')
  })
}

const useTemplate = (template) => {
  ElMessage.info(`使用模板: ${template.name}`)
  showApplyDialog.value = true
}

const editTemplate = (template) => {
  ElMessage.info(`编辑模板: ${template.name}`)
}

const addNode = (type) => {
  ElMessage.info(`添加${type}节点`)
}

const saveWorkflow = () => {
  ElMessage.success('流程保存成功')
}

const publishWorkflow = () => {
  ElMessage.success('流程发布成功')
}

const submitApplication = () => {
  ElMessage.success('申请提交成功')
  showApplyDialog.value = false
}
</script>

<style scoped>
.workflow-demo {
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

.stats-panel {
  margin-bottom: 20px;
}

.stat-card {
  position: relative;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 5px;
  margin-top: 10px;
  font-size: 12px;
}

.trend-icon.up {
  color: #67c23a;
}

.trend-icon.down {
  color: #f56c6c;
}

.workflow-tabs {
  background: white;
  border-radius: 8px;
}

.template-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.template-item {
  height: 200px;
}

.template-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.template-icon {
  font-size: 24px;
  color: #409eff;
}

.template-header h3 {
  margin: 0;
  font-size: 16px;
}

.template-desc {
  color: #606266;
  font-size: 14px;
  margin-bottom: 15px;
}

.template-stats {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #909399;
  margin-bottom: 15px;
}

.template-actions {
  display: flex;
  gap: 10px;
}

.designer-container {
  height: 500px;
  display: flex;
  flex-direction: column;
}

.designer-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  border-bottom: 1px solid #e4e7ed;
}

.designer-canvas {
  flex: 1;
  background: #f8f9fa;
  position: relative;
  overflow: hidden;
}

.canvas-placeholder {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  color: #909399;
}

.canvas-placeholder .el-icon {
  font-size: 48px;
  margin-bottom: 10px;
}

.progress-timeline {
  max-height: 400px;
  overflow-y: auto;
}

.timeline-content h4 {
  margin: 0 0 5px 0;
  font-size: 16px;
}

.timeline-content p {
  margin: 0 0 10px 0;
  color: #606266;
}

.approver-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
  font-size: 14px;
  color: #909399;
}

.comment {
  color: #409eff;
}
</style>
