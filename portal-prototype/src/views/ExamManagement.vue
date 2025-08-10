<template>
  <PageLayout
    title="考核管理"
    description="工程师技能考核安排、成绩统计、考试监控"
    icon="Document"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showScheduleDialog = true">
        <el-icon><Plus /></el-icon>
        安排考核
      </el-button>
      <el-button @click="exportResults">
        <el-icon><Download /></el-icon>
        导出成绩
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in examStatsCards" :key="stat.label">
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
      <el-row :gutter="20">
        <!-- 左侧考试列表 -->
        <el-col :span="16">
          <el-card>
            <template #header>
              <div class="card-header">
                <span>考试安排</span>
                <div class="header-filters">
                  <el-select v-model="filterStatus" placeholder="状态筛选" size="small" style="width: 120px;">
                    <el-option label="全部" value="" />
                    <el-option label="待考试" value="pending" />
                    <el-option label="进行中" value="ongoing" />
                    <el-option label="已完成" value="completed" />
                    <el-option label="已取消" value="cancelled" />
                  </el-select>
                  <el-select v-model="filterSkill" placeholder="技能筛选" size="small" style="width: 120px;">
                    <el-option label="全部" value="" />
                    <el-option label="Linux系统管理" value="Linux系统管理" />
                    <el-option label="Docker容器" value="Docker容器" />
                    <el-option label="Kubernetes" value="Kubernetes" />
                  </el-select>
                </div>
              </div>
            </template>

            <el-table :data="filteredExams" style="width: 100%">
              <el-table-column prop="examName" label="考试名称" width="200" />
              <el-table-column prop="skillName" label="技能" width="120" />
              <el-table-column prop="engineerName" label="考生" width="100" />
              <el-table-column prop="examDate" label="考试时间" width="150" />
              <el-table-column prop="duration" label="时长" width="80">
                <template #default="{ row }">
                  {{ row.duration }}分钟
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="getStatusType(row.status)" size="small">
                    {{ getStatusText(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="score" label="成绩" width="80">
                <template #default="{ row }">
                  <span v-if="row.score !== null" :class="row.score >= 80 ? 'score-pass' : 'score-fail'">
                    {{ row.score }}分
                  </span>
                  <span v-else class="score-pending">-</span>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="200">
                <template #default="{ row }">
                  <el-button v-if="row.status === 'pending'" size="small" @click="startExam(row)">
                    开始考试
                  </el-button>
                  <el-button v-if="row.status === 'ongoing'" size="small" type="warning" @click="monitorExam(row)">
                    监控
                  </el-button>
                  <el-button v-if="row.status === 'completed'" size="small" @click="viewResult(row)">
                    查看结果
                  </el-button>
                  <el-button size="small" @click="editExam(row)">编辑</el-button>
                  <el-button size="small" type="danger" @click="cancelExam(row)">取消</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </el-col>

        <!-- 右侧统计图表 -->
        <el-col :span="8">
          <el-card class="chart-card">
            <template #header>
              <span>成绩分布</span>
            </template>
            <div ref="scoreChart" style="height: 200px;"></div>
          </el-card>

          <el-card class="chart-card" style="margin-top: 20px;">
            <template #header>
              <span>通过率趋势</span>
            </template>
            <div ref="passRateChart" style="height: 200px;"></div>
          </el-card>

          <el-card class="monitor-card" style="margin-top: 20px;">
            <template #header>
              <span>实时监控</span>
            </template>
            <div class="monitor-list">
              <div
                v-for="exam in ongoingExams"
                :key="exam.id"
                class="monitor-item"
              >
                <div class="monitor-info">
                  <div class="exam-name">{{ exam.examName }}</div>
                  <div class="exam-progress">
                    <span>{{ exam.engineerName }}</span>
                    <el-progress
                      :percentage="exam.progress"
                      :stroke-width="6"
                      :show-text="false"
                    />
                    <span class="time-remaining">{{ exam.timeRemaining }}分钟</span>
                  </div>
                </div>
                <el-button size="small" @click="monitorExam(exam)">监控</el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </template>

    <!-- 安排考核对话框 -->
    <el-dialog v-model="showScheduleDialog" title="安排考核" width="800px">
      <el-form :model="scheduleForm" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="考试名称">
              <el-input v-model="scheduleForm.examName" placeholder="请输入考试名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="技能类型">
              <el-select v-model="scheduleForm.skillName" placeholder="请选择技能">
                <el-option label="Linux系统管理" value="Linux系统管理" />
                <el-option label="Docker容器技术" value="Docker容器技术" />
                <el-option label="Kubernetes编排" value="Kubernetes编排" />
                <el-option label="MySQL数据库" value="MySQL数据库" />
                <el-option label="网络故障排查" value="网络故障排查" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="考试时间">
              <el-date-picker
                v-model="scheduleForm.examDate"
                type="datetime"
                placeholder="选择考试时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="考试时长">
              <el-input-number
                v-model="scheduleForm.duration"
                :min="30"
                :max="180"
                placeholder="分钟"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="参考工程师">
          <el-select
            v-model="scheduleForm.engineerIds"
            multiple
            filterable
            placeholder="请选择工程师"
            style="width: 100%"
          >
            <el-option
              v-for="engineer in availableEngineers"
              :key="engineer.id"
              :label="`${engineer.name} (${engineer.department})`"
              :value="engineer.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="试卷选择">
          <el-select v-model="scheduleForm.paperId" placeholder="请选择试卷">
            <el-option
              v-for="paper in availablePapers"
              :key="paper.id"
              :label="`${paper.name} (${paper.questionCount}题)`"
              :value="paper.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="考试规则">
          <el-checkbox-group v-model="scheduleForm.rules">
            <el-checkbox value="allowReview">允许回顾题目</el-checkbox>
            <el-checkbox value="shuffleQuestions">随机题目顺序</el-checkbox>
            <el-checkbox value="showScore">考试结束显示成绩</el-checkbox>
            <el-checkbox value="preventCheating">防作弊模式</el-checkbox>
          </el-checkbox-group>
        </el-form-item>

        <el-form-item label="备注">
          <el-input
            v-model="scheduleForm.notes"
            type="textarea"
            :rows="3"
            placeholder="考试说明或注意事项"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showScheduleDialog = false">取消</el-button>
        <el-button type="primary" @click="scheduleExam">确定安排</el-button>
      </template>
    </el-dialog>

    <!-- 考试监控对话框 -->
    <el-dialog v-model="showMonitorDialog" title="考试监控" width="900px">
      <div v-if="currentMonitorExam" class="monitor-content">
        <div class="monitor-header">
          <div class="exam-info">
            <h3>{{ currentMonitorExam.examName }}</h3>
            <p>考生：{{ currentMonitorExam.engineerName }} | 技能：{{ currentMonitorExam.skillName }}</p>
          </div>
          <div class="exam-status">
            <el-tag :type="getStatusType(currentMonitorExam.status)">
              {{ getStatusText(currentMonitorExam.status) }}
            </el-tag>
          </div>
        </div>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-card>
              <template #header>考试进度</template>
              <div class="progress-info">
                <el-progress
                  :percentage="currentMonitorExam.progress"
                  :stroke-width="8"
                />
                <div class="progress-details">
                  <span>已答题：{{ currentMonitorExam.answeredQuestions }}/{{ currentMonitorExam.totalQuestions }}</span>
                  <span>剩余时间：{{ currentMonitorExam.timeRemaining }}分钟</span>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card>
              <template #header>异常监控</template>
              <div class="anomaly-list">
                <div
                  v-for="anomaly in currentMonitorExam.anomalies"
                  :key="anomaly.id"
                  class="anomaly-item"
                  :class="anomaly.level"
                >
                  <el-icon><Warning /></el-icon>
                  <span>{{ anomaly.message }}</span>
                  <span class="anomaly-time">{{ anomaly.time }}</span>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <el-card style="margin-top: 20px;">
          <template #header>操作日志</template>
          <el-table :data="currentMonitorExam.logs" style="width: 100%" max-height="200">
            <el-table-column prop="time" label="时间" width="120" />
            <el-table-column prop="action" label="操作" width="150" />
            <el-table-column prop="details" label="详情" />
          </el-table>
        </el-card>
      </div>

      <template #footer>
        <el-button @click="showMonitorDialog = false">关闭</el-button>
        <el-button type="warning" @click="pauseExam">暂停考试</el-button>
        <el-button type="danger" @click="terminateExam">终止考试</el-button>
      </template>
    </el-dialog>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Document, Plus, Download, Clock, CircleCheck, TrendCharts, Warning, Refresh
} from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const selectedMonth = ref(new Date())
const filterStatus = ref('')
const filterSkill = ref('')
const showScheduleDialog = ref(false)
const showMonitorDialog = ref(false)
const currentMonitorExam = ref(null)

// 图表引用
const scoreChart = ref(null)
const passRateChart = ref(null)

// 统计数据
const examStats = ref({
  totalExams: 45,
  pendingExams: 8,
  passRate: 87.5,
  avgScore: 82.3
})

// 统计卡片数据
const examStatsCards = computed(() => [
  {
    label: '总考试数',
    value: examStats.value.totalExams,
    icon: 'Document',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 12.5
  },
  {
    label: '待考试',
    value: examStats.value.pendingExams,
    icon: 'Clock',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -8.3
  },
  {
    label: '通过率',
    value: `${examStats.value.passRate}%`,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 5.7
  },
  {
    label: '平均分',
    value: examStats.value.avgScore,
    icon: 'TrendCharts',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 3.2
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

// 安排考核表单
const scheduleForm = reactive({
  examName: '',
  skillName: '',
  examDate: null,
  duration: 60,
  engineerIds: [],
  paperId: '',
  rules: ['showScore'],
  notes: ''
})

// 考试数据
const exams = ref([
  {
    id: '1',
    examName: 'Linux系统管理认证考试',
    skillName: 'Linux系统管理',
    engineerName: '张工程师',
    engineerId: '1',
    examDate: '2024-01-20 14:00',
    duration: 90,
    status: 'pending',
    score: null,
    progress: 0,
    timeRemaining: 90,
    answeredQuestions: 0,
    totalQuestions: 30,
    anomalies: [],
    logs: []
  },
  {
    id: '2',
    examName: 'Docker容器技术考核',
    skillName: 'Docker容器',
    engineerName: '李工程师',
    engineerId: '2',
    examDate: '2024-01-19 10:00',
    duration: 60,
    status: 'ongoing',
    score: null,
    progress: 45,
    timeRemaining: 33,
    answeredQuestions: 12,
    totalQuestions: 25,
    anomalies: [
      { id: '1', level: 'warning', message: '切换窗口次数过多', time: '14:25' }
    ],
    logs: [
      { time: '14:00', action: '开始考试', details: '考生进入考试界面' },
      { time: '14:15', action: '答题', details: '完成第1-8题' },
      { time: '14:25', action: '异常', details: '检测到窗口切换' }
    ]
  },
  {
    id: '3',
    examName: 'Kubernetes编排考试',
    skillName: 'Kubernetes',
    engineerName: '王工程师',
    engineerId: '3',
    examDate: '2024-01-18 16:00',
    duration: 120,
    status: 'completed',
    score: 88,
    progress: 100,
    timeRemaining: 0,
    answeredQuestions: 40,
    totalQuestions: 40,
    anomalies: [],
    logs: []
  }
])

// 可用工程师
const availableEngineers = ref([
  { id: '1', name: '张工程师', department: '系统运维部' },
  { id: '2', name: '李工程师', department: '网络运维部' },
  { id: '3', name: '王工程师', department: '应用运维部' },
  { id: '4', name: '赵工程师', department: '系统运维部' }
])

// 可用试卷
const availablePapers = ref([
  { id: '1', name: 'Linux系统管理基础', questionCount: 30 },
  { id: '2', name: 'Docker容器技术', questionCount: 25 },
  { id: '3', name: 'Kubernetes编排进阶', questionCount: 40 }
])

// 计算属性
const filteredExams = computed(() => {
  let result = exams.value

  if (filterStatus.value) {
    result = result.filter(exam => exam.status === filterStatus.value)
  }

  if (filterSkill.value) {
    result = result.filter(exam => exam.skillName === filterSkill.value)
  }

  return result
})

const ongoingExams = computed(() => {
  return exams.value.filter(exam => exam.status === 'ongoing')
})

// 方法
const getStatusType = (status) => {
  const types = {
    pending: 'warning',
    ongoing: 'primary',
    completed: 'success',
    cancelled: 'danger'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    pending: '待考试',
    ongoing: '进行中',
    completed: '已完成',
    cancelled: '已取消'
  }
  return texts[status] || '未知'
}

const onMonthChange = () => {
  ElMessage.info('月份已更新，重新加载统计数据')
}

const startExam = (exam) => {
  ElMessageBox.confirm('确定开始考试吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    exam.status = 'ongoing'
    ElMessage.success('考试已开始')
  })
}

const monitorExam = (exam) => {
  currentMonitorExam.value = exam
  showMonitorDialog.value = true
}

const viewResult = (exam) => {
  ElMessage.info(`查看 ${exam.engineerName} 的考试结果`)
}

const editExam = (exam) => {
  ElMessage.info(`编辑考试: ${exam.examName}`)
}

const cancelExam = (exam) => {
  ElMessageBox.confirm('确定取消这场考试吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    exam.status = 'cancelled'
    ElMessage.success('考试已取消')
  })
}

const scheduleExam = () => {
  if (!scheduleForm.examName || !scheduleForm.skillName || !scheduleForm.examDate) {
    ElMessage.error('请填写必填字段')
    return
  }

  // 为每个选中的工程师创建考试安排
  scheduleForm.engineerIds.forEach(engineerId => {
    const engineer = availableEngineers.value.find(e => e.id === engineerId)
    const newExam = {
      id: Date.now().toString() + Math.random(),
      examName: scheduleForm.examName,
      skillName: scheduleForm.skillName,
      engineerName: engineer.name,
      engineerId: engineerId,
      examDate: new Date(scheduleForm.examDate).toLocaleString(),
      duration: scheduleForm.duration,
      status: 'pending',
      score: null,
      progress: 0,
      timeRemaining: scheduleForm.duration,
      answeredQuestions: 0,
      totalQuestions: 30,
      anomalies: [],
      logs: []
    }

    exams.value.unshift(newExam)
  })

  showScheduleDialog.value = false
  ElMessage.success('考试安排成功')

  // 重置表单
  Object.assign(scheduleForm, {
    examName: '',
    skillName: '',
    examDate: null,
    duration: 60,
    engineerIds: [],
    paperId: '',
    rules: ['showScore'],
    notes: ''
  })
}

const pauseExam = () => {
  ElMessage.warning('考试已暂停')
}

const terminateExam = () => {
  ElMessageBox.confirm('确定终止考试吗？此操作不可恢复。', '警告', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'error'
  }).then(() => {
    if (currentMonitorExam.value) {
      currentMonitorExam.value.status = 'cancelled'
    }
    showMonitorDialog.value = false
    ElMessage.success('考试已终止')
  })
}

const exportResults = () => {
  ElMessage.success('成绩导出成功')
}

// 初始化图表
const initCharts = () => {
  nextTick(() => {
    // 成绩分布图
    if (scoreChart.value) {
      const scoreChartInstance = echarts.init(scoreChart.value)
      scoreChartInstance.setOption({
        tooltip: { trigger: 'item' },
        series: [{
          type: 'pie',
          radius: '70%',
          data: [
            { value: 15, name: '优秀(90-100)' },
            { value: 25, name: '良好(80-89)' },
            { value: 8, name: '及格(60-79)' },
            { value: 2, name: '不及格(<60)' }
          ]
        }]
      })
    }

    // 通过率趋势图
    if (passRateChart.value) {
      const passRateChartInstance = echarts.init(passRateChart.value)
      passRateChartInstance.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: {
          type: 'category',
          data: ['1月', '2月', '3月', '4月', '5月', '6月']
        },
        yAxis: { type: 'value', max: 100 },
        series: [{
          type: 'line',
          data: [85, 88, 92, 87, 90, 89],
          smooth: true
        }]
      })
    }
  })
}

onMounted(() => {
  initCharts()
})

// 导出方法供其他组件使用
defineExpose({
  initCharts
})
</script>

<style scoped>
.exam-management {
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

/* 统计容器样式 */
.stats-container {
  margin-bottom: 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.stats-title {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
}

.stats-row {
  padding: 16px;
  background: #fafafa;
  margin-bottom: 0;
}

.stat-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  height: 100%;
}

.stat-card.compact .el-card__body {
  padding: 12px 16px;
}

.stat-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: white;
  flex-shrink: 0;
}

.stat-icon.total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-icon.pending {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-icon.pass-rate {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-icon.avg-score {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-info {
  flex: 1;
  margin-left: 12px;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-filters {
  display: flex;
  gap: 12px;
}

.score-pass {
  color: #67c23a;
  font-weight: 600;
}

.score-fail {
  color: #f56c6c;
  font-weight: 600;
}

.score-pending {
  color: #909399;
}

.chart-card {
  margin-bottom: 20px;
}

.chart-card:last-of-type {
  margin-bottom: 0;
}

/* 右侧图表区域样式优化 */
.el-col[span="8"] {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.el-col[span="8"] .el-card {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.el-col[span="8"] .el-card .el-card__body {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.monitor-card {
  max-height: 300px;
  overflow-y: auto;
}

.monitor-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.monitor-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 6px;
}

.monitor-info {
  flex: 1;
}

.exam-name {
  font-weight: 500;
  margin-bottom: 8px;
}

.exam-progress {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #606266;
}

.time-remaining {
  color: #e6a23c;
  font-weight: 500;
}

.monitor-content {
  padding: 20px 0;
}

.monitor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #ebeef5;
}

.exam-info h3 {
  margin: 0 0 5px 0;
  color: #303133;
}

.exam-info p {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.progress-info {
  text-align: center;
}

.progress-details {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
  font-size: 12px;
  color: #606266;
}

.anomaly-list {
  max-height: 150px;
  overflow-y: auto;
}

.anomaly-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  margin-bottom: 8px;
  border-radius: 4px;
  font-size: 12px;
}

.anomaly-item.warning {
  background: #fdf6ec;
  color: #e6a23c;
}

.anomaly-item.error {
  background: #fef0f0;
  color: #f56c6c;
}

.anomaly-time {
  margin-left: auto;
  color: #909399;
}
</style>
