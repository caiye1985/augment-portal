<template>
  <PageLayout
    title="任务日志"
    description="系统集成任务执行日志和状态监控"
    icon="Document"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="exportLogs">
        <el-icon><Download /></el-icon>
        导出日志
      </el-button>
      <el-button @click="refreshLogs">
        <el-icon><Refresh /></el-icon>
        刷新日志
      </el-button>
      <el-button @click="clearFilters">
        <el-icon><Delete /></el-icon>
        清空筛选
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in taskLogStatsCards" :key="stat.label">
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
      <!-- 日志搜索和筛选 -->
      <el-card shadow="never" style="margin-bottom: 20px;">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>日志筛选</span>
            <el-button size="small" @click="resetLogFilters">
              <el-icon><Refresh /></el-icon>
              重置筛选
            </el-button>
          </div>
        </template>

        <el-form inline>
          <el-form-item label="关键字搜索">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索日志内容、系统名称等"
              style="width: 250px;"
              clearable
              @input="handleSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </el-form-item>

          <el-form-item label="时间范围">
            <el-date-picker
              v-model="logDateRange"
              type="datetimerange"
              range-separator="至"
              start-placeholder="开始时间"
              end-placeholder="结束时间"
              style="width: 350px;"
              @change="handleDateRangeChange"
            />
          </el-form-item>

          <el-form-item label="集成系统">
            <el-select v-model="logSystemFilter" placeholder="选择系统" clearable style="width: 150px;" @change="handleFilterChange">
              <el-option label="全部系统" value="" />
              <el-option label="NetBox" value="netbox" />
              <el-option label="夜莺监控" value="nightingale" />
              <el-option label="Orion-Ops" value="orion-ops" />
              <el-option label="Zabbix" value="zabbix" />
              <el-option label="Prometheus" value="prometheus" />
            </el-select>
          </el-form-item>

          <el-form-item label="任务类型">
            <el-select v-model="logTypeFilter" placeholder="选择类型" clearable style="width: 150px;" @change="handleFilterChange">
              <el-option label="全部类型" value="" />
              <el-option label="数据同步" value="sync" />
              <el-option label="连接测试" value="connect" />
              <el-option label="配置更新" value="config" />
              <el-option label="状态检查" value="health_check" />
              <el-option label="数据导入" value="import" />
              <el-option label="数据导出" value="export" />
            </el-select>
          </el-form-item>

          <el-form-item label="执行状态">
            <el-select v-model="logStatusFilter" placeholder="选择状态" clearable style="width: 120px;" @change="handleFilterChange">
              <el-option label="全部状态" value="" />
              <el-option label="成功" value="success" />
              <el-option label="失败" value="error" />
              <el-option label="警告" value="warning" />
              <el-option label="进行中" value="running" />
            </el-select>
          </el-form-item>
        </el-form>
      </el-card>

      <!-- 任务日志表格 -->
      <el-card shadow="never">
        <template #header>
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>任务执行日志 ({{ filteredLogs.length }})</span>
            <div>
              <el-button size="small" type="primary" @click="exportLogs">
                <el-icon><Download /></el-icon>
                导出
              </el-button>
              <el-button size="small" @click="refreshLogs">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </div>
        </template>

        <!-- 任务日志表格 -->
        <el-table :data="filteredLogs" stripe style="width: 100%" v-loading="logsLoading">
          <el-table-column prop="time" label="执行时间" width="160" sortable />
          <el-table-column prop="system" label="集成系统" width="120">
            <template #default="{ row }">
              <div style="display: flex; align-items: center;">
                <el-icon style="margin-right: 6px;" :color="getSystemColor(row.system)">
                  <component :is="getSystemIcon(row.system)" />
                </el-icon>
                <span>{{ getSystemName(row.system) }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="operation" label="任务类型" width="120">
            <template #default="{ row }">
              <el-tag size="small" :type="getOperationType(row.operation)">
                {{ getOperationName(row.operation) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="执行状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getLogStatusType(row.status)" size="small">
                <el-icon style="margin-right: 4px;">
                  <component :is="getStatusIcon(row.status)" />
                </el-icon>
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="message" label="执行结果" min-width="200" show-overflow-tooltip />
          <el-table-column prop="duration" label="耗时" width="100" sortable>
            <template #default="{ row }">
              <span :class="getDurationClass(row.duration)">{{ row.duration }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="recordCount" label="处理记录" width="100" sortable />
          <el-table-column label="操作" width="120" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="viewLogDetail(row)" type="primary" link>
                <el-icon><View /></el-icon>
                详情
              </el-button>
              <el-button size="small" @click="retryTask(row)" type="warning" link v-if="row.status === 'error'">
                <el-icon><Refresh /></el-icon>
                重试
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div style="margin-top: 20px; display: flex; justify-content: space-between; align-items: center;">
          <div class="pagination-info">
            <span style="color: #909399; font-size: 14px;">
              共 {{ filteredLogs.length }} 条记录，显示第 {{ (logCurrentPage - 1) * logPageSize + 1 }} - {{ Math.min(logCurrentPage * logPageSize, filteredLogs.length) }} 条
            </span>
          </div>
          <el-pagination
            v-model:current-page="logCurrentPage"
            v-model:page-size="logPageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="filteredLogs.length"
            layout="sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>
    </template>
  </PageLayout>

  <!-- 日志详情对话框 -->
  <el-dialog v-model="showLogDetailDialog" title="任务执行详情" width="800px">
    <div v-if="selectedLog">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="执行时间">{{ selectedLog.time }}</el-descriptions-item>
        <el-descriptions-item label="集成系统">{{ getSystemName(selectedLog.system) }}</el-descriptions-item>
        <el-descriptions-item label="任务类型">{{ getOperationName(selectedLog.operation) }}</el-descriptions-item>
        <el-descriptions-item label="执行状态">
          <el-tag :type="getLogStatusType(selectedLog.status)">{{ getStatusText(selectedLog.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="执行耗时">{{ selectedLog.duration }}</el-descriptions-item>
        <el-descriptions-item label="处理记录">{{ selectedLog.recordCount || 0 }} 条</el-descriptions-item>
        <el-descriptions-item label="执行结果" :span="2">{{ selectedLog.message }}</el-descriptions-item>
        <el-descriptions-item label="详细日志" :span="2" v-if="selectedLog.details">
          <pre style="background: #f5f5f5; padding: 12px; border-radius: 4px; font-size: 12px; max-height: 200px; overflow-y: auto;">{{ selectedLog.details }}</pre>
        </el-descriptions-item>
      </el-descriptions>
    </div>
    <template #footer>
      <el-button @click="showLogDetailDialog = false">关闭</el-button>
      <el-button type="primary" @click="retryTask(selectedLog)" v-if="selectedLog?.status === 'error'">重试任务</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Download, Refresh, Delete, Search, Document, View,
  Connection, Monitor, Setting, CircleCheck, Warning,
  CircleClose, Loading
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const logCurrentPage = ref(1)
const logPageSize = ref(20)
const logDateRange = ref([])
const logSystemFilter = ref('')
const logTypeFilter = ref('')
const logStatusFilter = ref('')
const searchKeyword = ref('')
const logsLoading = ref(false)
const showLogDetailDialog = ref(false)
const selectedLog = ref(null)

// 任务日志数据
const taskLogs = ref([
  {
    id: 1,
    time: '2024-01-15 14:30:15',
    system: 'netbox',
    operation: 'sync',
    status: 'success',
    message: '成功同步 156 个设备信息',
    duration: '2.3s',
    recordCount: 156,
    details: '同步完成:\n- 新增设备: 12个\n- 更新设备: 144个\n- 删除设备: 0个\n- 同步IP地址: 1024个'
  },
  {
    id: 2,
    time: '2024-01-15 14:25:42',
    system: 'nightingale',
    operation: 'health_check',
    status: 'success',
    message: '监控系统健康检查通过',
    duration: '1.8s',
    recordCount: 89,
    details: '健康检查结果:\n- 监控主机: 89台\n- 活跃告警: 3个\n- 系统负载: 正常\n- 存储空间: 78%'
  },
  {
    id: 3,
    time: '2024-01-15 14:20:33',
    system: 'orion-ops',
    operation: 'connect',
    status: 'error',
    message: '连接自动化平台失败: 认证超时',
    duration: '30.0s',
    recordCount: 0,
    details: '错误详情:\n- 错误代码: AUTH_TIMEOUT\n- 错误信息: Authentication timeout after 30 seconds\n- 建议: 检查网络连接和认证配置'
  },
  {
    id: 4,
    time: '2024-01-15 14:15:28',
    system: 'netbox',
    operation: 'import',
    status: 'warning',
    message: '数据导入完成，部分记录存在警告',
    duration: '5.7s',
    recordCount: 234,
    details: '导入结果:\n- 成功导入: 220个\n- 警告记录: 14个\n- 失败记录: 0个\n- 警告原因: IP地址冲突'
  },
  {
    id: 5,
    time: '2024-01-15 14:10:15',
    system: 'prometheus',
    operation: 'config',
    status: 'success',
    message: '监控配置更新成功',
    duration: '1.2s',
    recordCount: 45,
    details: '配置更新:\n- 新增监控目标: 8个\n- 更新告警规则: 12条\n- 删除过期配置: 3个'
  },
  {
    id: 6,
    time: '2024-01-15 14:05:22',
    system: 'zabbix',
    operation: 'sync',
    status: 'running',
    message: '正在同步监控数据...',
    duration: '进行中',
    recordCount: 0,
    details: '同步进度:\n- 已处理主机: 45/89\n- 当前状态: 同步监控项\n- 预计剩余时间: 3分钟'
  }
])

// 统计卡片数据
const taskLogStatsCards = computed(() => [
  {
    label: '总任务数',
    value: taskLogs.value.length,
    icon: 'Document',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 12.5
  },
  {
    label: '成功任务',
    value: taskLogs.value.filter(log => log.status === 'success').length,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 8.3
  },
  {
    label: '失败任务',
    value: taskLogs.value.filter(log => log.status === 'error').length,
    icon: 'CircleClose',
    color: 'var(--el-color-danger, #f56c6c)',
    trend: -15.2
  },
  {
    label: '运行中任务',
    value: taskLogs.value.filter(log => log.status === 'running').length,
    icon: 'Loading',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 0
  }
])

// 筛选后的日志
const filteredLogs = computed(() => {
  let filtered = [...taskLogs.value]

  // 关键字搜索
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    filtered = filtered.filter(log =>
      log.message.toLowerCase().includes(keyword) ||
      log.system.toLowerCase().includes(keyword) ||
      log.operation.toLowerCase().includes(keyword)
    )
  }

  // 系统筛选
  if (logSystemFilter.value) {
    filtered = filtered.filter(log => log.system === logSystemFilter.value)
  }

  // 类型筛选
  if (logTypeFilter.value) {
    filtered = filtered.filter(log => log.operation === logTypeFilter.value)
  }

  // 状态筛选
  if (logStatusFilter.value) {
    filtered = filtered.filter(log => log.status === logStatusFilter.value)
  }

  // 时间范围筛选
  if (logDateRange.value && logDateRange.value.length === 2) {
    const [start, end] = logDateRange.value
    filtered = filtered.filter(log => {
      const logTime = new Date(log.time)
      return logTime >= start && logTime <= end
    })
  }

  return filtered.sort((a, b) => new Date(b.time) - new Date(a.time))
})

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const handleSearch = () => {
  // 搜索功能已通过computed实现
}

const handleDateRangeChange = () => {
  // 日期范围变化已通过computed实现
}

const handleFilterChange = () => {
  // 筛选变化已通过computed实现
}

const resetLogFilters = () => {
  searchKeyword.value = ''
  logDateRange.value = []
  logSystemFilter.value = ''
  logTypeFilter.value = ''
  logStatusFilter.value = ''
  ElMessage.success('筛选条件已重置')
}

const clearFilters = () => {
  resetLogFilters()
}

const refreshLogs = () => {
  logsLoading.value = true
  setTimeout(() => {
    logsLoading.value = false
    ElMessage.success('日志数据已刷新')
  }, 1000)
}

const exportLogs = () => {
  const data = filteredLogs.value.map(log => ({
    执行时间: log.time,
    集成系统: getSystemName(log.system),
    任务类型: getOperationName(log.operation),
    执行状态: getStatusText(log.status),
    执行结果: log.message,
    执行耗时: log.duration,
    处理记录: log.recordCount || 0
  }))

  const csv = [
    ['执行时间', '集成系统', '任务类型', '执行状态', '执行结果', '执行耗时', '处理记录'],
    ...data.map(row => [
      row.执行时间, row.集成系统, row.任务类型, row.执行状态,
      `"${row.执行结果}"`, row.执行耗时, row.处理记录
    ])
  ].map(row => row.join(',')).join('\n')

  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `任务日志_${new Date().toISOString().slice(0, 10)}.csv`
  link.click()

  ElMessage.success('日志导出成功')
}

const viewLogDetail = (log) => {
  selectedLog.value = log
  showLogDetailDialog.value = true
}

const retryTask = (log) => {
  ElMessage.info(`正在重试任务: ${log.message}`)
  // 这里可以添加重试逻辑
}

const handleSizeChange = (size) => {
  logPageSize.value = size
  logCurrentPage.value = 1
}

const handleCurrentChange = (page) => {
  logCurrentPage.value = page
}

// 辅助方法
const getSystemName = (system) => {
  const systemMap = {
    'netbox': 'NetBox',
    'nightingale': '夜莺监控',
    'orion-ops': 'Orion-Ops',
    'zabbix': 'Zabbix',
    'prometheus': 'Prometheus'
  }
  return systemMap[system] || system
}

const getSystemColor = (system) => {
  const colorMap = {
    'netbox': '#409eff',
    'nightingale': '#67c23a',
    'orion-ops': '#e6a23c',
    'zabbix': '#f56c6c',
    'prometheus': '#909399'
  }
  return colorMap[system] || '#909399'
}

const getSystemIcon = (system) => {
  const iconMap = {
    'netbox': 'Connection',
    'nightingale': 'Monitor',
    'orion-ops': 'Setting',
    'zabbix': 'View',
    'prometheus': 'TrendCharts'
  }
  return iconMap[system] || 'Document'
}

const getOperationName = (operation) => {
  const operationMap = {
    'sync': '数据同步',
    'connect': '连接测试',
    'config': '配置更新',
    'health_check': '健康检查',
    'import': '数据导入',
    'export': '数据导出'
  }
  return operationMap[operation] || operation
}

const getOperationType = (operation) => {
  const typeMap = {
    'sync': 'primary',
    'connect': 'success',
    'config': 'warning',
    'health_check': 'info',
    'import': 'primary',
    'export': 'info'
  }
  return typeMap[operation] || 'info'
}

const getLogStatusType = (status) => {
  const statusMap = {
    'success': 'success',
    'error': 'danger',
    'warning': 'warning',
    'running': 'primary'
  }
  return statusMap[status] || 'info'
}

const getStatusText = (status) => {
  const statusMap = {
    'success': '成功',
    'error': '失败',
    'warning': '警告',
    'running': '运行中'
  }
  return statusMap[status] || status
}

const getStatusIcon = (status) => {
  const iconMap = {
    'success': 'CircleCheck',
    'error': 'CircleClose',
    'warning': 'Warning',
    'running': 'Loading'
  }
  return iconMap[status] || 'Document'
}

const getDurationClass = (duration) => {
  if (duration === '进行中') return 'duration-running'
  const seconds = parseFloat(duration)
  if (seconds > 10) return 'duration-slow'
  if (seconds > 5) return 'duration-medium'
  return 'duration-fast'
}

onMounted(() => {
  console.log('任务日志页面已加载')
})
</script>

<style scoped>
.pagination-info {
  color: #909399;
  font-size: 14px;
}

.duration-fast {
  color: #67c23a;
}

.duration-medium {
  color: #e6a23c;
}

.duration-slow {
  color: #f56c6c;
}

.duration-running {
  color: #409eff;
  font-weight: 500;
}
</style>
