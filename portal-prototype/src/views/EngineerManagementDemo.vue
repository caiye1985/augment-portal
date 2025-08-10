<template>
  <PageLayout
    title="工程师管理系统"
    description="工程师档案、技能认证、排班管理、负载监控"
    icon="User"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新增工程师
      </el-button>
      <el-button @click="exportData">
        <el-icon><Download /></el-icon>
        导出数据
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20" class="metrics-row">
        <el-col :span="6" v-for="stat in engineerStatsCards" :key="stat.label">
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
      <!-- 左侧工程师列表 -->
      <el-col :span="16">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>工程师列表</span>
              <div class="header-filters">
                <el-select v-model="filterStatus" placeholder="状态筛选" size="small" style="width: 120px;">
                  <el-option label="全部" value="" />
                  <el-option label="在线" value="在线" />
                  <el-option label="离线" value="离线" />
                  <el-option label="忙碌" value="忙碌" />
                </el-select>
                <el-select v-model="filterLevel" placeholder="级别筛选" size="small" style="width: 120px;">
                  <el-option label="全部" value="" />
                  <el-option label="高级工程师" value="高级工程师" />
                  <el-option label="中级工程师" value="中级工程师" />
                  <el-option label="初级工程师" value="初级工程师" />
                </el-select>
              </div>
            </div>
          </template>

          <el-table :data="filteredEngineers" @row-click="selectEngineer" highlight-current-row>
            <el-table-column width="60">
              <template #default="{ row }">
                <el-avatar :size="40" :src="row.avatar">{{ row.name.charAt(0) }}</el-avatar>
              </template>
            </el-table-column>
            <el-table-column prop="name" label="姓名" width="100" />
            <el-table-column prop="level" label="级别" width="120">
              <template #default="{ row }">
                <el-tag :type="getLevelColor(row.level)">{{ row.level }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="getStatusColor(row.status)" size="small">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="workload" label="当前负载" width="100">
              <template #default="{ row }">
                <el-progress :percentage="row.workload" :color="getWorkloadColor(row.workload)" />
              </template>
            </el-table-column>
            <el-table-column prop="skillScore" label="技能评分" width="100">
              <template #default="{ row }">
                <el-rate v-model="row.skillScore" disabled show-score />
              </template>
            </el-table-column>
            <el-table-column prop="department" label="部门" width="120" />
            <el-table-column label="操作" width="150">
              <template #default="{ row }">
                <el-button size="small" @click.stop="viewProfile(row)">档案</el-button>
                <el-button size="small" type="primary" @click.stop="assignTask(row)">派单</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>

      <!-- 右侧详情面板 -->
      <el-col :span="8">
        <el-card shadow="never" v-if="selectedEngineer.id">
          <template #header>
            <div class="profile-header">
              <el-avatar :size="50" :src="selectedEngineer.avatar">
                {{ selectedEngineer.name.charAt(0) }}
              </el-avatar>
              <div class="profile-info">
                <h3>{{ selectedEngineer.name }}</h3>
                <p>{{ selectedEngineer.level }} · {{ selectedEngineer.department }}</p>
              </div>
            </div>
          </template>

          <!-- 技能雷达图 -->
          <div class="skill-section">
            <h4>技能雷达图</h4>
            <div ref="skillChart" style="height: 200px;"></div>
          </div>

          <!-- 工作负载 -->
          <div class="workload-section">
            <h4>工作负载趋势</h4>
            <div ref="workloadChart" style="height: 150px;"></div>
          </div>

          <!-- 排班信息 -->
          <div class="schedule-section">
            <h4>本周排班</h4>
            <el-calendar v-model="scheduleDate" class="mini-calendar">
              <template #date-cell="{ data }">
                <div class="schedule-cell">
                  <span>{{ data.day.split('-').slice(2).join('-') }}</span>
                  <div v-if="getScheduleStatus(data.day)" class="schedule-status">
                    <el-tag size="small" :type="getScheduleColor(data.day)">
                      {{ getScheduleStatus(data.day) }}
                    </el-tag>
                  </div>
                </div>
              </template>
            </el-calendar>
          </div>

          <!-- 最近工单 -->
          <div class="recent-tickets">
            <h4>最近工单</h4>
            <div class="ticket-list">
              <div v-for="ticket in selectedEngineer.recentTickets" :key="ticket.id" class="ticket-item">
                <div class="ticket-info">
                  <span class="ticket-title">{{ ticket.title }}</span>
                  <el-tag size="small" :type="ticket.status === '已完成' ? 'success' : 'warning'">
                    {{ ticket.status }}
                  </el-tag>
                </div>
                <div class="ticket-time">{{ ticket.updateTime }}</div>
              </div>
            </div>
          </div>
        </el-card>

        <el-empty v-else description="请选择工程师查看详情" />
      </el-col>
    </el-row>
    </template>

    <!-- 创建工程师对话框 -->
    <el-dialog v-model="showCreateDialog" title="新增工程师" width="600px">
      <el-form :model="newEngineer" :rules="engineerRules" ref="engineerForm" label-width="100px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="newEngineer.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="工号" prop="employeeId">
          <el-input v-model="newEngineer.employeeId" placeholder="请输入工号" />
        </el-form-item>
        <el-form-item label="级别" prop="level">
          <el-select v-model="newEngineer.level" placeholder="请选择级别">
            <el-option label="高级工程师" value="高级工程师" />
            <el-option label="中级工程师" value="中级工程师" />
            <el-option label="初级工程师" value="初级工程师" />
          </el-select>
        </el-form-item>
        <el-form-item label="部门" prop="department">
          <el-select v-model="newEngineer.department" placeholder="请选择部门">
            <el-option label="技术部" value="技术部" />
            <el-option label="运维部" value="运维部" />
            <el-option label="网络部" value="网络部" />
          </el-select>
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="newEngineer.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="newEngineer.email" placeholder="请输入邮箱" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createEngineer">确定</el-button>
      </template>
    </el-dialog>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Plus, Download, CircleCheck, TrendCharts, Medal, Refresh } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 路由实例
const router = useRouter()

// 响应式数据
const showCreateDialog = ref(false)
const filterStatus = ref('')
const filterLevel = ref('')
const selectedEngineer = ref({})
const scheduleDate = ref(new Date())
const skillChart = ref(null)
const workloadChart = ref(null)

// 工程师数据
const engineers = ref([
  {
    id: '1',
    name: '张三',
    employeeId: 'ENG001',
    level: '高级工程师',
    status: '在线',
    workload: 85,
    skillScore: 4.5,
    department: '技术部',
    avatar: '',
    phone: '13800138001',
    email: 'zhangsan@company.com',
    skills: {
      'Linux运维': 90,
      '网络配置': 85,
      '数据库管理': 80,
      '故障排查': 95,
      '自动化脚本': 75
    },
    recentTickets: [
      { id: 'T001', title: '服务器CPU使用率过高', status: '已完成', updateTime: '2024-01-15 14:30' },
      { id: 'T002', title: '网络连接异常', status: '处理中', updateTime: '2024-01-15 16:20' }
    ]
  },
  {
    id: '2',
    name: '李四',
    employeeId: 'ENG002',
    level: '中级工程师',
    status: '忙碌',
    workload: 92,
    skillScore: 4.0,
    department: '运维部',
    avatar: '',
    phone: '13800138002',
    email: 'lisi@company.com',
    skills: {
      'Linux运维': 75,
      '网络配置': 80,
      '数据库管理': 70,
      '故障排查': 85,
      '自动化脚本': 65
    },
    recentTickets: [
      { id: 'T003', title: '数据库连接超时', status: '处理中', updateTime: '2024-01-15 15:45' }
    ]
  },
  {
    id: '3',
    name: '王五',
    employeeId: 'ENG003',
    level: '初级工程师',
    status: '离线',
    workload: 45,
    skillScore: 3.5,
    department: '网络部',
    avatar: '',
    phone: '13800138003',
    email: 'wangwu@company.com',
    skills: {
      'Linux运维': 60,
      '网络配置': 70,
      '数据库管理': 50,
      '故障排查': 65,
      '自动化脚本': 45
    },
    recentTickets: [
      { id: 'T004', title: '路由器配置更新', status: '已完成', updateTime: '2024-01-14 10:15' }
    ]
  }
])


const filteredEngineers = computed(() => {
  return engineers.value.filter(engineer => {
    const statusMatch = !filterStatus.value || engineer.status === filterStatus.value
    const levelMatch = !filterLevel.value || engineer.level === filterLevel.value
    return statusMatch && levelMatch
  })
})

// 计算属性
const onlineEngineers = computed(() => {
  return engineers.value.filter(e => e.status === '在线').length
})

// 统计卡片数据
const engineerStatsCards = computed(() => [
  {
    label: '总工程师数',
    value: engineers.value.length,
    icon: 'User',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '在线工程师',
    value: onlineEngineers.value,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.3
  },
  {
    label: '平均负载',
    value: '75.6%',
    icon: 'TrendCharts',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -3.2
  },
  {
    label: '技能认证',
    value: engineers.value.filter(e => e.certifications && e.certifications.length > 0).length,
    icon: 'Medal',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 15.7
  },
  {
    label: '技能认证率',
    value: '89.2%',
    icon: 'Medal',
    color: 'var(--el-color-error, #ef4444)',
    trend: 5.3
  }
])

// 新工程师表单
const newEngineer = reactive({
  name: '',
  employeeId: '',
  level: '',
  department: '',
  phone: '',
  email: ''
})

const engineerRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  employeeId: [{ required: true, message: '请输入工号', trigger: 'blur' }],
  level: [{ required: true, message: '请选择级别', trigger: 'change' }],
  department: [{ required: true, message: '请选择部门', trigger: 'change' }]
}

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
}

const getLevelColor = (level) => {
  const colors = {
    '高级工程师': 'danger',
    '中级工程师': 'warning',
    '初级工程师': 'success'
  }
  return colors[level] || 'info'
}

const getStatusColor = (status) => {
  const colors = {
    '在线': 'success',
    '离线': 'info',
    '忙碌': 'warning'
  }
  return colors[status] || 'info'
}

const getWorkloadColor = (workload) => {
  if (workload >= 90) return '#f56c6c'
  if (workload >= 70) return '#e6a23c'
  return '#67c23a'
}

const selectEngineer = (engineer) => {
  selectedEngineer.value = engineer
  nextTick(() => {
    initSkillChart()
    initWorkloadChart()
  })
}

const viewProfile = (engineer) => {
  // 使用编程式导航跳转到工程师档案页面
  router.push({
    name: 'PersonnelEngineerProfile',
    params: { engineerId: engineer.id }
  })
}

const assignTask = (engineer) => {
  ElMessage.info(`为 ${engineer.name} 分配新任务`)
}

const createEngineer = () => {
  ElMessage.success('工程师创建成功')
  showCreateDialog.value = false
}

const exportData = () => {
  ElMessage.success('数据导出成功')
}

const getScheduleStatus = (date) => {
  // 模拟排班数据
  const schedules = {
    '2024-01-15': '白班',
    '2024-01-16': '夜班',
    '2024-01-17': '休息',
    '2024-01-18': '白班'
  }
  return schedules[date]
}

const getScheduleColor = (date) => {
  const status = getScheduleStatus(date)
  const colors = {
    '白班': 'success',
    '夜班': 'warning',
    '休息': 'info'
  }
  return colors[status] || 'info'
}

// 初始化技能雷达图
const initSkillChart = () => {
  if (!skillChart.value || !selectedEngineer.value.skills) return

  const chart = echarts.init(skillChart.value)
  const skills = selectedEngineer.value.skills
  const option = {
    radar: {
      indicator: Object.keys(skills).map(key => ({
        name: key,
        max: 100
      }))
    },
    series: [{
      name: '技能评分',
      type: 'radar',
      data: [{
        value: Object.values(skills),
        name: selectedEngineer.value.name
      }]
    }]
  }
  chart.setOption(option)
}

// 初始化工作负载图表
const initWorkloadChart = () => {
  if (!workloadChart.value) return

  const chart = echarts.init(workloadChart.value)
  const option = {
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    yAxis: {
      type: 'value',
      max: 100
    },
    series: [{
      data: [65, 78, 85, 92, 88, 45, 30],
      type: 'line',
      smooth: true,
      areaStyle: {}
    }]
  }
  chart.setOption(option)
}

// 监听选中工程师变化
watch(selectedEngineer, () => {
  nextTick(() => {
    initSkillChart()
    initWorkloadChart()
  })
})

onMounted(() => {
  // 默认选择第一个工程师
  if (engineers.value.length > 0) {
    selectedEngineer.value = engineers.value[0]
  }
})
</script>

<style scoped>
.engineer-management-demo {
  padding: 20px;
  background: var(--bg-primary);
  color: var(--text-primary);
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 20px;
  background: var(--gradient-bg);
  border-radius: 12px;
  color: var(--text-inverse);
  border: 1px solid var(--border-color);
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

.stats-cards {
  margin-bottom: 20px;
}

.stat-card {
  position: relative;
  overflow: hidden;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  color: var(--text-primary);
}

.stat-extra {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
}

.stat-icon {
  font-size: 32px;
  color: #409eff;
  opacity: 0.3;
}

.stat-icon.online {
  color: #67c23a;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-filters {
  display: flex;
  gap: 10px;
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 15px;
}

.profile-info h3 {
  margin: 0;
  font-size: 18px;
}

.profile-info p {
  margin: 5px 0 0 0;
  color: var(--text-secondary);
  font-size: 14px;
}

.skill-section,
.workload-section,
.schedule-section,
.recent-tickets {
  margin-bottom: 20px;
}

.skill-section h4,
.workload-section h4,
.schedule-section h4,
.recent-tickets h4 {
  margin: 0 0 10px 0;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-primary);
}

.mini-calendar {
  transform: scale(0.8);
  transform-origin: top left;
}

.schedule-cell {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}

.schedule-status {
  font-size: 10px;
}

.ticket-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.ticket-item {
  padding: 10px;
  background: var(--bg-tertiary);
  border-radius: 6px;
  border-left: 3px solid var(--primary-color);
  color: var(--text-primary);
}

.ticket-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 5px;
}

.ticket-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--text-primary);
}

.ticket-time {
  font-size: 12px;
  color: var(--text-secondary);
}
</style>
