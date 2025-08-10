<template>
  <PageLayout
    title="排班管理"
    description="管理工程师排班计划，确保7x24小时服务覆盖"
    icon="Calendar"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="createSchedule">
        <el-icon><Plus /></el-icon>
        创建排班
      </el-button>
      <el-button @click="exportSchedule">
        <el-icon><Download /></el-icon>
        导出排班表
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in scheduleStatsCards" :key="stat.label">
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



    <!-- 排班视图切换 -->
    <el-card class="view-controls">
      <div class="controls-header">
        <el-radio-group v-model="viewMode" @change="onViewModeChange">
          <el-radio-button label="calendar">日历视图</el-radio-button>
          <el-radio-button label="table">表格视图</el-radio-button>
          <el-radio-button label="gantt">甘特图</el-radio-button>
        </el-radio-group>

        <div class="view-filters">
          <el-select v-model="filterDepartment" placeholder="部门筛选" size="small" style="width: 120px;">
            <el-option label="全部" value="" />
            <el-option label="系统运维" value="系统运维" />
            <el-option label="网络运维" value="网络运维" />
            <el-option label="应用运维" value="应用运维" />
          </el-select>

          <el-select v-model="filterShift" placeholder="班次筛选" size="small" style="width: 120px;">
            <el-option label="全部" value="" />
            <el-option label="白班" value="day" />
            <el-option label="夜班" value="night" />
            <el-option label="值班" value="standby" />
          </el-select>
        </div>
      </div>
    </el-card>

    <!-- 日历视图 -->
    <el-card v-if="viewMode === 'calendar'" class="calendar-view">
      <template #header>
        <div class="calendar-header">
          <span>排班日历</span>
          <div class="calendar-controls">
            <el-button-group size="small">
              <el-button @click="prevWeek">
                <el-icon><ArrowLeft /></el-icon>
                上周
              </el-button>
              <el-button @click="currentWeek">今周</el-button>
              <el-button @click="nextWeek">
                下周
                <el-icon><ArrowRight /></el-icon>
              </el-button>
            </el-button-group>
          </div>
        </div>
      </template>

      <div class="calendar-content">
        <div class="calendar-grid">
          <!-- 日期头部 -->
          <div class="calendar-header-row">
            <div class="time-column">时间</div>
            <div
              v-for="date in weekDates"
              :key="date.date"
              class="date-column"
              :class="{ today: date.isToday }"
            >
              <div class="date-info">
                <div class="date-day">{{ date.day }}</div>
                <div class="date-date">{{ date.date }}</div>
              </div>
            </div>
          </div>

          <!-- 时间段行 -->
          <div
            v-for="timeSlot in timeSlots"
            :key="timeSlot.time"
            class="calendar-row"
          >
            <div class="time-cell">{{ timeSlot.time }}</div>
            <div
              v-for="date in weekDates"
              :key="`${date.date}-${timeSlot.time}`"
              class="schedule-cell"
              @click="editScheduleCell(date, timeSlot)"
            >
              <div
                v-for="engineer in getScheduleForCell(date.date, timeSlot.time)"
                :key="engineer.id"
                class="engineer-badge"
                :class="engineer.shiftType"
                :title="`${engineer.name} - ${engineer.department}`"
              >
                {{ engineer.name }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 表格视图 -->
    <el-card v-if="viewMode === 'table'" class="table-view">
      <template #header>
        <span>排班表格</span>
      </template>

      <el-table :data="filteredSchedules" style="width: 100%">
        <el-table-column prop="engineerName" label="工程师" width="120" />
        <el-table-column prop="department" label="部门" width="100" />
        <el-table-column prop="date" label="日期" width="120" />
        <el-table-column prop="shiftType" label="班次" width="100">
          <template #default="{ row }">
            <el-tag :type="getShiftTypeColor(row.shiftType)" size="small">
              {{ getShiftTypeName(row.shiftType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="startTime" label="开始时间" width="100" />
        <el-table-column prop="endTime" label="结束时间" width="100" />
        <el-table-column prop="location" label="值班地点" width="120" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusColor(row.status)" size="small">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button size="small" @click="editSchedule(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteSchedule(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 甘特图视图 -->
    <el-card v-if="viewMode === 'gantt'" class="gantt-view">
      <template #header>
        <span>排班甘特图</span>
      </template>

      <div class="gantt-content">
        <div class="gantt-sidebar">
          <div class="gantt-header">工程师</div>
          <div
            v-for="engineer in engineers"
            :key="engineer.id"
            class="gantt-row-label"
          >
            <div class="engineer-info">
              <span class="engineer-name">{{ engineer.name }}</span>
              <span class="engineer-dept">{{ engineer.department }}</span>
            </div>
          </div>
        </div>

        <div class="gantt-timeline">
          <div class="gantt-timeline-header">
            <div
              v-for="date in weekDates"
              :key="date.date"
              class="gantt-date-header"
            >
              {{ date.day }} {{ date.date }}
            </div>
          </div>

          <div
            v-for="engineer in engineers"
            :key="engineer.id"
            class="gantt-timeline-row"
          >
            <div
              v-for="date in weekDates"
              :key="date.date"
              class="gantt-day-cell"
            >
              <div
                v-for="schedule in getEngineerScheduleForDate(engineer.id, date.date)"
                :key="schedule.id"
                class="gantt-schedule-bar"
                :class="schedule.shiftType"
                :style="getGanttBarStyle(schedule)"
                :title="`${schedule.startTime} - ${schedule.endTime}`"
              >
                {{ getShiftTypeName(schedule.shiftType) }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 创建排班对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建排班" width="600px">
      <el-form :model="newSchedule" label-width="100px">
        <el-form-item label="工程师">
          <el-select v-model="newSchedule.engineerId" placeholder="请选择工程师">
            <el-option
              v-for="engineer in engineers"
              :key="engineer.id"
              :label="`${engineer.name} (${engineer.department})`"
              :value="engineer.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="日期范围">
          <el-date-picker
            v-model="newSchedule.dateRange"
            type="daterange"
            placeholder="选择日期范围"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="班次类型">
          <el-select v-model="newSchedule.shiftType" placeholder="请选择班次">
            <el-option label="白班 (09:00-18:00)" value="day" />
            <el-option label="夜班 (18:00-09:00)" value="night" />
            <el-option label="值班 (24小时)" value="standby" />
          </el-select>
        </el-form-item>

        <el-form-item label="值班地点">
          <el-input v-model="newSchedule.location" placeholder="请输入值班地点" />
        </el-form-item>

        <el-form-item label="备注">
          <el-input v-model="newSchedule.notes" type="textarea" rows="3" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="saveSchedule">保存</el-button>
      </template>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Calendar, Plus, Download, User, Clock, Promotion, TrendCharts,
  ArrowLeft, ArrowRight, Refresh
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const viewMode = ref('calendar')
const selectedWeek = ref(new Date())
const filterDepartment = ref('')
const filterShift = ref('')
const showCreateDialog = ref(false)

// 统计数据
const scheduleStats = ref({
  totalEngineers: 12,
  onDutyToday: 4,
  coverage: 95,
  avgWorkload: 8.5
})

// 统计卡片数据
const scheduleStatsCards = computed(() => [
  {
    label: '总工程师数',
    value: scheduleStats.value.totalEngineers,
    icon: 'User',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '今日值班',
    value: scheduleStats.value.onDutyToday,
    icon: 'Clock',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.3
  },
  {
    label: '覆盖率',
    value: `${scheduleStats.value.coverage}%`,
    icon: 'TrendCharts',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 2.1
  },
  {
    label: '平均工作量',
    value: `${scheduleStats.value.avgWorkload}h`,
    icon: 'Promotion',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -1.5
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

// 工程师数据
const engineers = ref([
  { id: '1', name: '张工程师', department: '系统运维' },
  { id: '2', name: '李工程师', department: '网络运维' },
  { id: '3', name: '王工程师', department: '应用运维' },
  { id: '4', name: '赵工程师', department: '系统运维' },
  { id: '5', name: '刘工程师', department: '网络运维' },
  { id: '6', name: '陈工程师', department: '应用运维' }
])

// 排班数据
const schedules = ref([
  {
    id: '1',
    engineerId: '1',
    engineerName: '张工程师',
    department: '系统运维',
    date: '2024-01-15',
    shiftType: 'day',
    startTime: '09:00',
    endTime: '18:00',
    location: '机房A',
    status: '正常',
    notes: ''
  },
  {
    id: '2',
    engineerId: '2',
    engineerName: '李工程师',
    department: '网络运维',
    date: '2024-01-15',
    shiftType: 'night',
    startTime: '18:00',
    endTime: '09:00',
    location: '机房B',
    status: '正常',
    notes: ''
  }
])

// 新排班表单
const newSchedule = reactive({
  engineerId: '',
  dateRange: [],
  shiftType: '',
  location: '',
  notes: ''
})

// 时间段
const timeSlots = ref([
  { time: '00:00', period: 'night' },
  { time: '02:00', period: 'night' },
  { time: '04:00', period: 'night' },
  { time: '06:00', period: 'night' },
  { time: '08:00', period: 'day' },
  { time: '10:00', period: 'day' },
  { time: '12:00', period: 'day' },
  { time: '14:00', period: 'day' },
  { time: '16:00', period: 'day' },
  { time: '18:00', period: 'night' },
  { time: '20:00', period: 'night' },
  { time: '22:00', period: 'night' }
])

// 计算属性
const weekDates = computed(() => {
  const dates = []
  const startOfWeek = new Date(selectedWeek.value)
  startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay() + 1) // 周一开始

  for (let i = 0; i < 7; i++) {
    const date = new Date(startOfWeek)
    date.setDate(startOfWeek.getDate() + i)

    dates.push({
      date: date.toISOString().split('T')[0],
      day: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][i],
      isToday: date.toDateString() === new Date().toDateString()
    })
  }

  return dates
})

const filteredSchedules = computed(() => {
  let result = schedules.value

  if (filterDepartment.value) {
    result = result.filter(s => s.department === filterDepartment.value)
  }

  if (filterShift.value) {
    result = result.filter(s => s.shiftType === filterShift.value)
  }

  return result
})

// 方法
const getShiftTypeColor = (type) => {
  const colors = { day: 'primary', night: 'warning', standby: 'success' }
  return colors[type] || 'info'
}

const getShiftTypeName = (type) => {
  const names = { day: '白班', night: '夜班', standby: '值班' }
  return names[type] || '未知'
}

const getStatusColor = (status) => {
  const colors = { '正常': 'success', '请假': 'warning', '调班': 'info' }
  return colors[status] || 'info'
}

const getScheduleForCell = (date, time) => {
  return schedules.value
    .filter(s => s.date === date)
    .filter(s => {
      const startHour = parseInt(s.startTime.split(':')[0])
      const endHour = parseInt(s.endTime.split(':')[0])
      const currentHour = parseInt(time.split(':')[0])

      if (s.shiftType === 'night' && endHour < startHour) {
        return currentHour >= startHour || currentHour < endHour
      }

      return currentHour >= startHour && currentHour < endHour
    })
    .map(s => ({
      id: s.id,
      name: s.engineerName,
      department: s.department,
      shiftType: s.shiftType
    }))
}

const getEngineerScheduleForDate = (engineerId, date) => {
  return schedules.value.filter(s => s.engineerId === engineerId && s.date === date)
}

const getGanttBarStyle = (schedule) => {
  const startHour = parseInt(schedule.startTime.split(':')[0])
  const endHour = parseInt(schedule.endTime.split(':')[0])

  let width, left

  if (schedule.shiftType === 'standby') {
    width = '100%'
    left = '0%'
  } else if (schedule.shiftType === 'night' && endHour < startHour) {
    // 跨天夜班
    width = '100%'
    left = '0%'
  } else {
    const duration = endHour - startHour
    width = `${(duration / 24) * 100}%`
    left = `${(startHour / 24) * 100}%`
  }

  return { width, left }
}

const onViewModeChange = () => {
  ElMessage.info(`切换到${viewMode.value === 'calendar' ? '日历' : viewMode.value === 'table' ? '表格' : '甘特图'}视图`)
}

const onWeekChange = () => {
  ElMessage.info('周期已更新')
}

const prevWeek = () => {
  const newDate = new Date(selectedWeek.value)
  newDate.setDate(newDate.getDate() - 7)
  selectedWeek.value = newDate
}

const nextWeek = () => {
  const newDate = new Date(selectedWeek.value)
  newDate.setDate(newDate.getDate() + 7)
  selectedWeek.value = newDate
}

const currentWeek = () => {
  selectedWeek.value = new Date()
}

const editScheduleCell = (date, timeSlot) => {
  ElMessage.info(`编辑 ${date.day} ${timeSlot.time} 的排班`)
}

const createSchedule = () => {
  showCreateDialog.value = true
}

const saveSchedule = () => {
  if (!newSchedule.engineerId || !newSchedule.dateRange || !newSchedule.shiftType) {
    ElMessage.error('请填写必填字段')
    return
  }

  // 生成排班记录
  const [startDate, endDate] = newSchedule.dateRange
  const engineer = engineers.value.find(e => e.id === newSchedule.engineerId)

  const currentDate = new Date(startDate)
  while (currentDate <= endDate) {
    const schedule = {
      id: Date.now().toString() + Math.random(),
      engineerId: newSchedule.engineerId,
      engineerName: engineer.name,
      department: engineer.department,
      date: currentDate.toISOString().split('T')[0],
      shiftType: newSchedule.shiftType,
      startTime: newSchedule.shiftType === 'day' ? '09:00' : newSchedule.shiftType === 'night' ? '18:00' : '00:00',
      endTime: newSchedule.shiftType === 'day' ? '18:00' : newSchedule.shiftType === 'night' ? '09:00' : '23:59',
      location: newSchedule.location,
      status: '正常',
      notes: newSchedule.notes
    }

    schedules.value.push(schedule)
    currentDate.setDate(currentDate.getDate() + 1)
  }

  showCreateDialog.value = false
  ElMessage.success('排班创建成功')

  // 重置表单
  Object.assign(newSchedule, {
    engineerId: '',
    dateRange: [],
    shiftType: '',
    location: '',
    notes: ''
  })
}

const editSchedule = (schedule) => {
  ElMessage.info(`编辑排班: ${schedule.engineerName}`)
}

const deleteSchedule = (schedule) => {
  const index = schedules.value.findIndex(s => s.id === schedule.id)
  if (index > -1) {
    schedules.value.splice(index, 1)
    ElMessage.success('排班删除成功')
  }
}

const exportSchedule = () => {
  ElMessage.success('排班表导出成功')
}

onMounted(() => {
  // 初始化数据
})
</script>

<style scoped>
.schedule-management {
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



.view-controls .el-card__body {
  padding: 16px 20px;
}

.controls-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.view-filters {
  display: flex;
  gap: 12px;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.calendar-content {
  overflow-x: auto;
}

.calendar-grid {
  min-width: 800px;
}

.calendar-header-row {
  display: grid;
  grid-template-columns: 80px repeat(7, 1fr);
  border-bottom: 2px solid #ebeef5;
}

.time-column {
  padding: 12px 8px;
  background: #f5f7fa;
  border-right: 1px solid #ebeef5;
  font-weight: 600;
  text-align: center;
}

.date-column {
  padding: 12px 8px;
  text-align: center;
  border-right: 1px solid #ebeef5;
  background: #f5f7fa;
}

.date-column.today {
  background: #e6f7ff;
  color: #1890ff;
}

.date-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.date-day {
  font-weight: 600;
  font-size: 14px;
}

.date-date {
  font-size: 12px;
  color: #909399;
}

.calendar-row {
  display: grid;
  grid-template-columns: 80px repeat(7, 1fr);
  border-bottom: 1px solid #ebeef5;
}

.time-cell {
  padding: 8px;
  background: #fafafa;
  border-right: 1px solid #ebeef5;
  text-align: center;
  font-size: 12px;
  color: #909399;
}

.schedule-cell {
  padding: 4px;
  border-right: 1px solid #ebeef5;
  min-height: 40px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.schedule-cell:hover {
  background: #f0f9ff;
}

.engineer-badge {
  display: inline-block;
  padding: 2px 6px;
  margin: 1px;
  border-radius: 4px;
  font-size: 11px;
  color: white;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 100%;
}

.engineer-badge.day {
  background: #409eff;
}

.engineer-badge.night {
  background: #e6a23c;
}

.engineer-badge.standby {
  background: #67c23a;
}

.gantt-content {
  display: flex;
  overflow-x: auto;
}

.gantt-sidebar {
  width: 200px;
  flex-shrink: 0;
  border-right: 1px solid #ebeef5;
}

.gantt-header {
  padding: 12px;
  background: #f5f7fa;
  border-bottom: 1px solid #ebeef5;
  font-weight: 600;
  text-align: center;
}

.gantt-row-label {
  padding: 12px;
  border-bottom: 1px solid #ebeef5;
  height: 60px;
  display: flex;
  align-items: center;
}

.engineer-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.engineer-name {
  font-weight: 500;
  color: #303133;
}

.engineer-dept {
  font-size: 12px;
  color: #909399;
}

.gantt-timeline {
  flex: 1;
  min-width: 700px;
}

.gantt-timeline-header {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  background: #f5f7fa;
  border-bottom: 1px solid #ebeef5;
}

.gantt-date-header {
  padding: 12px 8px;
  text-align: center;
  border-right: 1px solid #ebeef5;
  font-weight: 600;
  font-size: 14px;
}

.gantt-timeline-row {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  border-bottom: 1px solid #ebeef5;
  height: 60px;
}

.gantt-day-cell {
  position: relative;
  border-right: 1px solid #ebeef5;
  padding: 4px;
}

.gantt-schedule-bar {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  height: 24px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  color: white;
  font-weight: 500;
}

.gantt-schedule-bar.day {
  background: #409eff;
}

.gantt-schedule-bar.night {
  background: #e6a23c;
}

.gantt-schedule-bar.standby {
  background: #67c23a;
}
</style>
