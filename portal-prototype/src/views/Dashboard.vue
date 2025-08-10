<template>
  <PageLayout
    title="运维仪表板"
    description="实时监控系统状态和关键指标"
    icon="Monitor"
    :tags="[
      { text: '实时数据', type: 'success' },
      { text: 'v2.1.0', type: 'info' }
    ]"
    :tips="dashboardTips"
    :page-actions="dashboardActions"
    :show-page-info="true"
    @refresh="handleRefresh"
    @favorite-toggle="handleFavoriteToggle"
    @breadcrumb-action="handleBreadcrumbAction"
    @page-action="handlePageAction"
  >

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in dashboardStatsCards" :key="stat.label">
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
      <!-- 工单趋势图表 -->
      <el-col :span="12">
        <el-card class="demo-card">
          <template #header>
            <span>工单趋势</span>
          </template>
          <v-chart
            :option="ticketTrendOption"
            style="height: 300px;"
            autoresize
          />
        </el-card>
      </el-col>

      <!-- 工单分类分布 -->
      <el-col :span="12">
        <el-card class="demo-card">
          <template #header>
            <span>工单分类分布</span>
          </template>
          <v-chart
            :option="categoryOption"
            style="height: 300px;"
            autoresize
          />
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px;">
      <!-- 实时系统状态 -->
      <el-col :span="8">
        <el-card class="demo-card">
          <template #header>
            <span>实时系统状态</span>
          </template>
          <div v-if="realTimeData">
            <div style="margin-bottom: 15px;">
              <div style="display: flex; justify-content: space-between;">
                <span>在线用户</span>
                <strong>{{ realTimeData.activeUsers }}</strong>
              </div>
            </div>
            <div style="margin-bottom: 15px;">
              <div style="display: flex; justify-content: space-between;">
                <span>系统负载</span>
                <strong>{{ realTimeData.systemLoad }}</strong>
              </div>
            </div>
            <div style="margin-bottom: 15px;">
              <div style="display: flex; justify-content: space-between;">
                <span>内存使用率</span>
                <strong>{{ realTimeData.memoryUsage }}%</strong>
              </div>
            </div>
            <div>
              <div style="display: flex; justify-content: space-between;">
                <span>网络流量</span>
                <strong>{{ realTimeData.networkTraffic }}MB/s</strong>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 最新工单 -->
      <el-col :span="16">
        <el-card class="demo-card">
          <template #header>
            <span>最新工单</span>
          </template>
          <el-table :data="recentTickets" style="width: 100%">
            <el-table-column prop="id" label="工单号" width="100" />
            <el-table-column prop="title" label="标题" />
            <el-table-column prop="priority" label="优先级" width="80">
              <template #default="{ row }">
                <el-tag
                  :type="getPriorityType(row.priority)"
                  size="small"
                >
                  {{ row.priority }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag
                  :type="getStatusType(row.status)"
                  size="small"
                >
                  {{ row.status }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="createdAt" label="创建时间" width="150" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Refresh, Download } from '@element-plus/icons-vue'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, PieChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import { mockDashboardStats, mockTickets, createMockDataStream } from '@/data/mockData'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 注册ECharts组件
use([
  CanvasRenderer,
  LineChart,
  PieChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
])

const stats = ref(mockDashboardStats)
const realTimeData = ref(null)
const recentTickets = computed(() => mockTickets.slice(0, 5))

// 页面提示信息
const dashboardTips = ref([
  {
    title: '数据更新',
    description: '仪表板数据每30秒自动刷新一次，您也可以手动点击刷新按钮获取最新数据。',
    type: 'info',
    closable: true
  }
])

// 页面操作按钮配置
const dashboardActions = ref([
  {
    key: 'refresh',
    label: '刷新数据',
    type: 'primary',
    icon: 'Refresh'
  },
  {
    key: 'export',
    label: '导出报告',
    type: 'default',
    icon: 'Download'
  },
  {
    key: 'customize',
    label: '自定义布局',
    type: 'default',
    icon: 'Setting'
  },
  {
    key: 'fullscreen',
    label: '全屏显示',
    type: 'default',
    icon: 'FullScreen'
  },
  {
    key: 'settings',
    label: '仪表板设置',
    type: 'default',
    icon: 'Tools'
  }
])

let stopDataStream = null

// 统计卡片数据
const dashboardStatsCards = computed(() => [
  {
    label: '总工单数',
    value: stats.value.tickets.total,
    icon: 'Tickets',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 12.5
  },
  {
    label: '已解决工单',
    value: stats.value.tickets.resolved,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 8.3
  },
  {
    label: '待处理工单',
    value: stats.value.tickets.pending,
    icon: 'Clock',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -5.7
  },
  {
    label: 'SLA达成率',
    value: `${stats.value.performance.slaCompliance}%`,
    icon: 'TrendCharts',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 2.1
  }
])

// 工单趋势图表配置
const ticketTrendOption = computed(() => ({
  tooltip: {
    trigger: 'axis'
  },
  legend: {
    data: ['创建', '解决']
  },
  xAxis: {
    type: 'category',
    data: stats.value.trends.ticketTrends.map(item => item.date)
  },
  yAxis: {
    type: 'value'
  },
  series: [
    {
      name: '创建',
      type: 'line',
      data: stats.value.trends.ticketTrends.map(item => item.created),
      smooth: true
    },
    {
      name: '解决',
      type: 'line',
      data: stats.value.trends.ticketTrends.map(item => item.resolved),
      smooth: true
    }
  ]
}))

// 分类分布图表配置
const categoryOption = computed(() => ({
  tooltip: {
    trigger: 'item'
  },
  legend: {
    orient: 'vertical',
    left: 'left'
  },
  series: [
    {
      type: 'pie',
      radius: '50%',
      data: stats.value.trends.categoryDistribution,
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }
  ]
}))

// 获取优先级标签类型
const getPriorityType = (priority) => {
  const types = { '低': '', '中': 'warning', '高': 'danger', '紧急': 'danger' }
  return types[priority] || ''
}

// 获取状态标签类型
const getStatusType = (status) => {
  const types = {
    '待分配': 'info',
    '处理中': 'warning',
    '待验收': 'warning',
    '已完成': 'success',
    '已关闭': ''
  }
  return types[status] || ''
}

// 统计卡片点击处理
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const exportReport = () => {
  ElMessage.success('报告导出成功')
}

// 刷新数据
const refreshData = () => {
  ElMessage.success('数据已刷新')
  // 这里可以重新加载数据
}

// 页面刷新处理
const handleRefresh = () => {
  refreshData()
}

// 收藏切换处理
const handleFavoriteToggle = (data) => {
  const message = data.favorited ? '已添加到收藏' : '已从收藏中移除'
  ElMessage.success(message)
}

// 面包屑操作处理
const handleBreadcrumbAction = (action) => {
  handlePageAction(action)
}

// 页面操作处理
const handlePageAction = (actionKey) => {
  switch (actionKey) {
    case 'refresh':
      refreshData()
      break
    case 'export':
      exportReport()
      break
    case 'customize':
      ElMessage.info('自定义布局功能开发中...')
      break
    case 'fullscreen':
      toggleFullscreen()
      break
    case 'settings':
      ElMessage.info('仪表板设置功能开发中...')
      break
    default:
      ElMessage.info(`执行操作: ${actionKey}`)
  }
}

// 全屏切换
const toggleFullscreen = () => {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen()
    ElMessage.success('已进入全屏模式')
  } else {
    document.exitFullscreen()
    ElMessage.success('已退出全屏模式')
  }
}

onMounted(() => {
  // 启动实时数据流
  stopDataStream = createMockDataStream((data) => {
    realTimeData.value = data
  })
})

onUnmounted(() => {
  if (stopDataStream) {
    stopDataStream()
  }
})
</script>

<style scoped>
.dashboard-demo {
  padding: 20px;
  background: var(--bg-primary);
  color: var(--text-primary);
  min-height: 100vh;
}

.demo-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 20px;
  background: var(--bg-card);
  border-radius: 8px;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border-color);
}

.demo-title {
  margin: 0 0 8px 0;
  color: var(--text-primary);
  font-size: 24px;
  font-weight: 600;
}

.demo-subtitle {
  margin: 0;
  color: var(--text-secondary);
  font-size: 14px;
}

.demo-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: var(--bg-card);
  padding: 24px;
  border-radius: 8px;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border-color);
  border-left: 4px solid var(--primary-color);
  transition: var(--transition-base);
}

.stat-card:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: var(--text-primary);
  margin-bottom: 8px;
}

.stat-label {
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 500;
}

.demo-card {
  margin-bottom: 20px;
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  box-shadow: var(--shadow-sm);
}

.demo-card .el-card__header {
  background: var(--bg-card);
  border-bottom: 1px solid var(--border-color);
  color: var(--text-primary);
  font-weight: 600;
}

.demo-card .el-card__body {
  background: var(--bg-card);
  color: var(--text-primary);
}

.recent-tickets {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
}

.ticket-item {
  padding: 16px;
  border-bottom: 1px solid var(--border-color);
  background: var(--bg-card);
  color: var(--text-primary);
  transition: var(--transition-base);
}

.ticket-item:hover {
  background: var(--bg-hover);
}

.ticket-item:last-child {
  border-bottom: none;
}

.ticket-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.ticket-title {
  font-weight: 500;
  color: var(--text-primary);
}

.ticket-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: var(--text-secondary);
}

.ticket-description {
  color: var(--text-secondary);
  font-size: 14px;
  line-height: 1.5;
}

/* 确保ECharts图表在深色模式下正确显示 */
.demo-card .el-card__body > div {
  background: transparent !important;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .demo-stats {
    grid-template-columns: 1fr;
  }

  .demo-header {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
}
</style>