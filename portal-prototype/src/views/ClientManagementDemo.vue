<template>
  <PageLayout
    title="甲方管理"
    description="客户管理和专属运维服务界面"
    icon="User"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新增客户
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in clientStatsCards" :key="stat.label">
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
      <!-- 运维仪表板 -->
      <el-tab-pane label="运维仪表板" name="dashboard">
        <div class="tab-content">
          <!-- 关键指标卡片 -->
          <el-row :gutter="20" class="metrics-row">
            <el-col :span="6">
              <el-card class="metric-card health">
                <div class="metric-content">
                  <div class="metric-icon">
                    <el-icon><Monitor /></el-icon>
                  </div>
                  <div class="metric-info">
                    <div class="metric-value">98.5%</div>
                    <div class="metric-label">系统健康度</div>
                  </div>
                  <div class="metric-trend up">
                    <el-icon><TrendCharts /></el-icon>
                    <span>+0.3%</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="metric-card tickets">
                <div class="metric-content">
                  <div class="metric-icon">
                    <el-icon><Tickets /></el-icon>
                  </div>
                  <div class="metric-info">
                    <div class="metric-value">{{ dashboardStats.activeTickets }}</div>
                    <div class="metric-label">活跃工单</div>
                  </div>
                  <div class="metric-trend down">
                    <el-icon><Bottom /></el-icon>
                    <span>-5</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="metric-card assets">
                <div class="metric-content">
                  <div class="metric-icon">
                    <el-icon><Box /></el-icon>
                  </div>
                  <div class="metric-info">
                    <div class="metric-value">{{ dashboardStats.totalAssets }}</div>
                    <div class="metric-label">设备资产</div>
                  </div>
                  <div class="metric-trend stable">
                    <el-icon><Minus /></el-icon>
                    <span>0</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="metric-card alerts">
                <div class="metric-content">
                  <div class="metric-icon">
                    <el-icon><Warning /></el-icon>
                  </div>
                  <div class="metric-info">
                    <div class="metric-value">{{ dashboardStats.activeAlerts }}</div>
                    <div class="metric-label">活跃告警</div>
                  </div>
                  <div class="metric-trend up">
                    <el-icon><Top /></el-icon>
                    <span>+2</span>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <!-- 图表区域 -->
          <el-row :gutter="20" class="charts-row">
            <el-col :span="12">
              <el-card title="系统性能趋势">
                <div class="chart-container">
                  <div class="chart-placeholder">
                    <el-icon size="48"><TrendCharts /></el-icon>
                    <h3>系统性能趋势图</h3>
                    <p>显示CPU、内存、磁盘使用率变化</p>
                    <div class="mock-chart">
                      <div class="chart-legend">
                        <span class="legend-item cpu">CPU使用率</span>
                        <span class="legend-item memory">内存使用率</span>
                        <span class="legend-item disk">磁盘使用率</span>
                      </div>
                      <div class="chart-bars">
                        <div class="bar-group">
                          <div class="bar cpu" style="height: 60%"></div>
                          <div class="bar memory" style="height: 45%"></div>
                          <div class="bar disk" style="height: 30%"></div>
                        </div>
                        <div class="bar-group">
                          <div class="bar cpu" style="height: 65%"></div>
                          <div class="bar memory" style="height: 50%"></div>
                          <div class="bar disk" style="height: 35%"></div>
                        </div>
                        <div class="bar-group">
                          <div class="bar cpu" style="height: 55%"></div>
                          <div class="bar memory" style="height: 40%"></div>
                          <div class="bar disk" style="height: 25%"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card title="工单处理统计">
                <div class="chart-container">
                  <div class="chart-placeholder">
                    <el-icon size="48"><PieChart /></el-icon>
                    <h3>工单状态分布</h3>
                    <p>各状态工单数量统计</p>
                    <div class="mock-pie">
                      <div class="pie-stats">
                        <div class="stat-item">
                          <span class="stat-color new"></span>
                          <span>新建: 12</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-color processing"></span>
                          <span>处理中: 8</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-color resolved"></span>
                          <span>已解决: 25</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-color closed"></span>
                          <span>已关闭: 156</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <!-- 实时告警和最新工单 -->
          <el-row :gutter="20" class="info-row">
            <el-col :span="12">
              <el-card title="实时告警">
                <template #header>
                  <div class="card-header">
                    <span>实时告警</span>
                    <el-badge :value="realtimeAlerts.length" class="item">
                      <el-button size="small" @click="refreshAlerts">
                        <el-icon><Refresh /></el-icon>
                        刷新
                      </el-button>
                    </el-badge>
                  </div>
                </template>

                <div class="alerts-list">
                  <div
                    v-for="alert in realtimeAlerts"
                    :key="alert.id"
                    class="alert-item"
                    :class="alert.level"
                  >
                    <div class="alert-icon">
                      <el-icon><Warning /></el-icon>
                    </div>
                    <div class="alert-content">
                      <div class="alert-title">{{ alert.title }}</div>
                      <div class="alert-description">{{ alert.description }}</div>
                      <div class="alert-time">{{ alert.time }}</div>
                    </div>
                    <div class="alert-actions">
                      <el-button size="small" @click="handleAlert(alert)">处理</el-button>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card title="最新工单">
                <template #header>
                  <div class="card-header">
                    <span>最新工单</span>
                    <el-button size="small" @click="viewAllTickets">
                      查看全部
                    </el-button>
                  </div>
                </template>

                <div class="tickets-list">
                  <div
                    v-for="ticket in recentTickets"
                    :key="ticket.id"
                    class="ticket-item"
                    @click="viewTicket(ticket)"
                  >
                    <div class="ticket-header">
                      <span class="ticket-number">{{ ticket.number }}</span>
                      <el-tag :type="getTicketStatusType(ticket.status)" size="small">
                        {{ ticket.status }}
                      </el-tag>
                    </div>
                    <div class="ticket-title">{{ ticket.title }}</div>
                    <div class="ticket-meta">
                      <span class="ticket-assignee">{{ ticket.assignee }}</span>
                      <span class="ticket-time">{{ ticket.time }}</span>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>

      <!-- 设备资产 -->
      <el-tab-pane label="设备资产" name="assets">
        <div class="tab-content">
          <!-- 资产统计 -->
          <el-row :gutter="20" class="asset-stats">
            <el-col :span="6">
              <div class="stat-card">
                <div class="stat-icon servers">
                  <el-icon><Monitor /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ assetStats.servers }}</div>
                  <div class="stat-label">服务器</div>
                </div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card">
                <div class="stat-icon network">
                  <el-icon><Connection /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ assetStats.network }}</div>
                  <div class="stat-label">网络设备</div>
                </div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card">
                <div class="stat-icon storage">
                  <el-icon><Box /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ assetStats.storage }}</div>
                  <div class="stat-label">存储设备</div>
                </div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card">
                <div class="stat-icon security">
                  <el-icon><Lock /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ assetStats.security }}</div>
                  <div class="stat-label">安全设备</div>
                </div>
              </div>
            </el-col>
          </el-row>

          <!-- 设备列表 -->
          <el-card title="设备列表" class="assets-table">
            <template #header>
              <div class="table-header">
                <span>设备列表</span>
                <div class="header-actions">
                  <el-input
                    v-model="assetSearch"
                    placeholder="搜索设备..."
                    style="width: 200px"
                    clearable
                  >
                    <template #prefix>
                      <el-icon><Search /></el-icon>
                    </template>
                  </el-input>
                  <el-select v-model="assetTypeFilter" placeholder="设备类型" style="width: 120px" clearable>
                    <el-option label="服务器" value="server" />
                    <el-option label="网络设备" value="network" />
                    <el-option label="存储设备" value="storage" />
                  </el-select>
                </div>
              </div>
            </template>

            <el-table :data="filteredAssets" stripe style="width: 100%">
              <el-table-column prop="name" label="设备名称" width="150" />
              <el-table-column prop="type" label="设备类型" width="120">
                <template #default="{ row }">
                  <el-tag :type="getAssetTypeColor(row.type)" size="small">
                    {{ getAssetTypeText(row.type) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="ip" label="IP地址" width="130" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 'online' ? 'success' : 'danger'" size="small">
                    {{ row.status === 'online' ? '在线' : '离线' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="location" label="位置" width="120" />
              <el-table-column prop="cpu" label="CPU使用率" width="120">
                <template #default="{ row }">
                  <el-progress :percentage="row.cpu" :show-text="false" :stroke-width="6" />
                  <span style="margin-left: 8px; font-size: 12px;">{{ row.cpu }}%</span>
                </template>
              </el-table-column>
              <el-table-column prop="memory" label="内存使用率" width="120">
                <template #default="{ row }">
                  <el-progress :percentage="row.memory" :show-text="false" :stroke-width="6" />
                  <span style="margin-left: 8px; font-size: 12px;">{{ row.memory }}%</span>
                </template>
              </el-table-column>
              <el-table-column prop="lastCheck" label="最后检查" width="160" />
              <el-table-column label="操作" width="150" fixed="right">
                <template #default="{ row }">
                  <el-button size="small" @click="viewAssetDetail(row)">详情</el-button>
                  <el-button size="small" @click="monitorAsset(row)">监控</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>

      <!-- 故障管理 -->
      <el-tab-pane label="故障管理" name="faults">
        <div class="tab-content">
          <!-- 故障统计 -->
          <el-row :gutter="20" class="fault-stats">
            <el-col :span="6">
              <el-card class="fault-stat-card critical">
                <div class="fault-stat-content">
                  <div class="fault-stat-number">{{ faultStats.critical }}</div>
                  <div class="fault-stat-label">严重故障</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="fault-stat-card major">
                <div class="fault-stat-content">
                  <div class="fault-stat-number">{{ faultStats.major }}</div>
                  <div class="fault-stat-label">重要故障</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="fault-stat-card minor">
                <div class="fault-stat-content">
                  <div class="fault-stat-number">{{ faultStats.minor }}</div>
                  <div class="fault-stat-label">一般故障</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="fault-stat-card resolved">
                <div class="fault-stat-content">
                  <div class="fault-stat-number">{{ faultStats.resolved }}</div>
                  <div class="fault-stat-label">已解决</div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <!-- 故障列表 -->
          <el-card title="故障报告" class="faults-table">
            <el-table :data="faults" stripe style="width: 100%">
              <el-table-column prop="id" label="故障ID" width="100" />
              <el-table-column prop="title" label="故障标题" min-width="200" />
              <el-table-column prop="level" label="严重级别" width="120">
                <template #default="{ row }">
                  <el-tag :type="getFaultLevelType(row.level)" size="small">
                    {{ getFaultLevelText(row.level) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="affectedAssets" label="影响设备" width="100" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="getFaultStatusType(row.status)" size="small">
                    {{ row.status }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="reportTime" label="报告时间" width="160" />
              <el-table-column prop="resolveTime" label="解决时间" width="160" />
              <el-table-column label="操作" width="150" fixed="right">
                <template #default="{ row }">
                  <el-button size="small" @click="viewFaultDetail(row)">详情</el-button>
                  <el-button
                    v-if="row.status !== '已解决'"
                    size="small"
                    type="primary"
                    @click="resolveFault(row)"
                  >
                    解决
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>

      <!-- 工单统计 -->
      <el-tab-pane label="工单统计" name="ticket-stats">
        <div class="tab-content">
          <!-- 统计概览 -->
          <el-row :gutter="20" class="ticket-overview">
            <el-col :span="8">
              <el-card title="工单概览" class="overview-card">
                <div class="overview-stats">
                  <div class="overview-item">
                    <span class="overview-label">总工单数:</span>
                    <span class="overview-value">{{ ticketOverview.total }}</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">本月新增:</span>
                    <span class="overview-value">{{ ticketOverview.thisMonth }}</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">平均解决时间:</span>
                    <span class="overview-value">{{ ticketOverview.avgResolveTime }}</span>
                  </div>
                  <div class="overview-item">
                    <span class="overview-label">客户满意度:</span>
                    <span class="overview-value">{{ ticketOverview.satisfaction }}%</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="8">
              <el-card title="SLA达成率" class="sla-card">
                <div class="sla-progress">
                  <el-progress
                    type="circle"
                    :percentage="slaStats.overall"
                    :width="120"
                    :stroke-width="8"
                  >
                    <template #default="{ percentage }">
                      <span class="sla-percentage">{{ percentage }}%</span>
                      <div class="sla-label">总体SLA</div>
                    </template>
                  </el-progress>
                </div>
                <div class="sla-details">
                  <div class="sla-item">
                    <span>紧急工单:</span>
                    <span>{{ slaStats.urgent }}%</span>
                  </div>
                  <div class="sla-item">
                    <span>高优先级:</span>
                    <span>{{ slaStats.high }}%</span>
                  </div>
                  <div class="sla-item">
                    <span>普通工单:</span>
                    <span>{{ slaStats.normal }}%</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="8">
              <el-card title="工程师绩效" class="performance-card">
                <div class="engineer-list">
                  <div
                    v-for="engineer in topEngineers"
                    :key="engineer.id"
                    class="engineer-item"
                  >
                    <div class="engineer-info">
                      <el-avatar :size="32">{{ engineer.name.charAt(0) }}</el-avatar>
                      <div class="engineer-details">
                        <div class="engineer-name">{{ engineer.name }}</div>
                        <div class="engineer-stats">{{ engineer.resolved }}个工单</div>
                      </div>
                    </div>
                    <div class="engineer-rating">
                      <el-rate v-model="engineer.rating" disabled size="small" />
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <!-- 趋势图表 -->
          <el-row :gutter="20" class="trend-charts">
            <el-col :span="12">
              <el-card title="工单趋势分析">
                <div class="chart-placeholder">
                  <el-icon size="48"><TrendCharts /></el-icon>
                  <h3>工单数量趋势</h3>
                  <p>显示最近30天工单创建和解决趋势</p>
                </div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card title="响应时间分析">
                <div class="chart-placeholder">
                  <el-icon size="48"><Timer /></el-icon>
                  <h3>平均响应时间</h3>
                  <p>各优先级工单的平均响应时间统计</p>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>

      <!-- 报表中心 -->
      <el-tab-pane label="报表中心" name="reports">
        <div class="tab-content">
          <!-- 报表模板 -->
          <div class="report-templates">
            <h3>预置报表模板</h3>
            <el-row :gutter="20">
              <el-col :span="6" v-for="template in reportTemplates" :key="template.id">
                <el-card class="report-template-card" @click="generateReport(template)">
                  <div class="template-icon">
                    <el-icon><component :is="template.icon" /></el-icon>
                  </div>
                  <div class="template-info">
                    <h4>{{ template.name }}</h4>
                    <p>{{ template.description }}</p>
                  </div>
                  <div class="template-actions">
                    <el-button size="small" type="primary">生成报表</el-button>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>

          <!-- 自定义报表 -->
          <el-card title="自定义报表" class="custom-report">
            <el-form :model="customReport" label-width="100px">
              <el-row :gutter="20">
                <el-col :span="12">
                  <el-form-item label="报表名称">
                    <el-input v-model="customReport.name" placeholder="请输入报表名称" />
                  </el-form-item>
                  <el-form-item label="时间范围">
                    <el-date-picker
                      v-model="customReport.dateRange"
                      type="daterange"
                      range-separator="至"
                      start-placeholder="开始日期"
                      end-placeholder="结束日期"
                      style="width: 100%"
                    />
                  </el-form-item>
                  <el-form-item label="数据维度">
                    <el-checkbox-group v-model="customReport.dimensions">
                      <el-checkbox value="tickets">工单数据</el-checkbox>
                      <el-checkbox value="assets">资产数据</el-checkbox>
                      <el-checkbox value="performance">性能数据</el-checkbox>
                      <el-checkbox value="sla">SLA数据</el-checkbox>
                    </el-checkbox-group>
                  </el-form-item>
                </el-col>
                <el-col :span="12">
                  <el-form-item label="报表格式">
                    <el-radio-group v-model="customReport.format">
                      <el-radio label="pdf">PDF</el-radio>
                      <el-radio label="excel">Excel</el-radio>
                      <el-radio label="word">Word</el-radio>
                    </el-radio-group>
                  </el-form-item>
                  <el-form-item label="发送方式">
                    <el-checkbox-group v-model="customReport.delivery">
                      <el-checkbox label="email">邮件发送</el-checkbox>
                      <el-checkbox label="download">直接下载</el-checkbox>
                      <el-checkbox label="schedule">定时生成</el-checkbox>
                    </el-checkbox-group>
                  </el-form-item>
                  <el-form-item>
                    <el-button type="primary" @click="generateCustomReport">生成报表</el-button>
                    <el-button @click="saveReportTemplate">保存模板</el-button>
                  </el-form-item>
                </el-col>
              </el-row>
            </el-form>
          </el-card>

          <!-- 报表历史 -->
          <el-card title="报表历史" class="report-history">
            <el-table :data="reportHistory" stripe style="width: 100%">
              <el-table-column prop="name" label="报表名称" width="200" />
              <el-table-column prop="type" label="类型" width="120" />
              <el-table-column prop="format" label="格式" width="100" />
              <el-table-column prop="generateTime" label="生成时间" width="160" />
              <el-table-column prop="size" label="文件大小" width="120" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === '已完成' ? 'success' : 'warning'" size="small">
                    {{ row.status }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="150" fixed="right">
                <template #default="{ row }">
                  <el-button size="small" @click="downloadReport(row)">下载</el-button>
                  <el-button size="small" @click="shareReport(row)">分享</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>
    </el-tabs>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('dashboard')
const assetSearch = ref('')
const assetTypeFilter = ref('')
const showCreateDialog = ref(false)

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
}

// 仪表板统计数据
const dashboardStats = ref({
  activeTickets: 23,
  totalAssets: 156,
  activeAlerts: 5
})

// 统计卡片数据
const clientStatsCards = computed(() => [
  {
    label: '系统健康度',
    value: '98.5%',
    icon: 'Monitor',
    color: 'var(--el-color-success, #10b981)',
    trend: 0.3
  },
  {
    label: '活跃工单',
    value: dashboardStats.value.activeTickets,
    icon: 'Tickets',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -5
  },
  {
    label: '总资产数',
    value: dashboardStats.value.totalAssets,
    icon: 'Box',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 12
  },
  {
    label: '活跃告警',
    value: dashboardStats.value.activeAlerts,
    icon: 'Warning',
    color: 'var(--el-color-error, #ef4444)',
    trend: -2
  }
])

// 实时告警数据
const realtimeAlerts = ref([
  {
    id: 1,
    title: 'CPU使用率过高',
    description: '服务器 SRV-WEB-01 CPU使用率达到 95%',
    level: 'critical',
    time: '2分钟前'
  },
  {
    id: 2,
    title: '磁盘空间不足',
    description: '数据库服务器磁盘使用率超过 90%',
    level: 'warning',
    time: '5分钟前'
  },
  {
    id: 3,
    title: '网络连接异常',
    description: '交换机 SW-CORE-01 出现间歇性连接问题',
    level: 'major',
    time: '10分钟前'
  }
])

// 最新工单数据
const recentTickets = ref([
  {
    id: 1,
    number: 'TK-2024-001',
    title: '服务器性能优化',
    status: '处理中',
    assignee: '张工程师',
    time: '1小时前'
  },
  {
    id: 2,
    number: 'TK-2024-002',
    title: '网络故障排查',
    status: '已分配',
    assignee: '李工程师',
    time: '2小时前'
  },
  {
    id: 3,
    number: 'TK-2024-003',
    title: '数据库备份恢复',
    status: '新建',
    assignee: '未分配',
    time: '3小时前'
  }
])

// 资产统计数据
const assetStats = ref({
  servers: 45,
  network: 28,
  storage: 12,
  security: 8
})

// 设备资产数据
const assets = ref([
  {
    id: 1,
    name: 'SRV-WEB-01',
    type: 'server',
    ip: '192.168.1.10',
    status: 'online',
    location: '机房A-01',
    cpu: 75,
    memory: 68,
    lastCheck: '2024-01-15 14:30:00'
  },
  {
    id: 2,
    name: 'SW-CORE-01',
    type: 'network',
    ip: '192.168.1.1',
    status: 'online',
    location: '机房A-核心',
    cpu: 45,
    memory: 32,
    lastCheck: '2024-01-15 14:25:00'
  },
  {
    id: 3,
    name: 'SRV-DB-01',
    type: 'server',
    ip: '192.168.1.20',
    status: 'offline',
    location: '机房B-01',
    cpu: 0,
    memory: 0,
    lastCheck: '2024-01-15 12:15:00'
  }
])

// 故障统计数据
const faultStats = ref({
  critical: 2,
  major: 5,
  minor: 8,
  resolved: 156
})

// 故障数据
const faults = ref([
  {
    id: 'F-001',
    title: '核心交换机端口故障',
    level: 'critical',
    affectedAssets: 15,
    status: '处理中',
    reportTime: '2024-01-15 10:30:00',
    resolveTime: '-'
  },
  {
    id: 'F-002',
    title: 'Web服务器响应慢',
    level: 'major',
    affectedAssets: 3,
    status: '已分配',
    reportTime: '2024-01-15 11:45:00',
    resolveTime: '-'
  },
  {
    id: 'F-003',
    title: '打印机连接问题',
    level: 'minor',
    affectedAssets: 1,
    status: '已解决',
    reportTime: '2024-01-15 09:20:00',
    resolveTime: '2024-01-15 10:15:00'
  }
])

// 工单概览数据
const ticketOverview = ref({
  total: 1234,
  thisMonth: 89,
  avgResolveTime: '4.2小时',
  satisfaction: 94
})

// SLA统计数据
const slaStats = ref({
  overall: 94,
  urgent: 98,
  high: 95,
  normal: 92
})

// 顶级工程师数据
const topEngineers = ref([
  { id: 1, name: '张工程师', resolved: 45, rating: 5 },
  { id: 2, name: '李工程师', resolved: 38, rating: 4 },
  { id: 3, name: '王工程师', resolved: 32, rating: 4 }
])

// 报表模板数据
const reportTemplates = ref([
  {
    id: 1,
    name: '月度运维报告',
    description: '包含系统状态、工单统计、性能分析',
    icon: 'Document'
  },
  {
    id: 2,
    name: 'SLA达成报告',
    description: '服务等级协议达成情况分析',
    icon: 'TrendCharts'
  },
  {
    id: 3,
    name: '资产状态报告',
    description: '设备资产健康状况和使用情况',
    icon: 'Box'
  },
  {
    id: 4,
    name: '故障分析报告',
    description: '故障统计、原因分析和改进建议',
    icon: 'Warning'
  }
])

// 自定义报表数据
const customReport = ref({
  name: '',
  dateRange: [],
  dimensions: ['tickets'],
  format: 'pdf',
  delivery: ['download']
})

// 报表历史数据
const reportHistory = ref([
  {
    id: 1,
    name: '2024年1月运维报告',
    type: '月度报告',
    format: 'PDF',
    generateTime: '2024-01-15 14:30:00',
    size: '2.5MB',
    status: '已完成'
  },
  {
    id: 2,
    name: 'SLA达成分析',
    type: 'SLA报告',
    format: 'Excel',
    generateTime: '2024-01-14 16:20:00',
    size: '1.8MB',
    status: '已完成'
  }
])

// 计算属性
const filteredAssets = computed(() => {
  let filtered = assets.value

  if (assetSearch.value) {
    const search = assetSearch.value.toLowerCase()
    filtered = filtered.filter(asset =>
      asset.name.toLowerCase().includes(search) ||
      asset.ip.includes(search)
    )
  }

  if (assetTypeFilter.value) {
    filtered = filtered.filter(asset => asset.type === assetTypeFilter.value)
  }

  return filtered
})

// 方法
const refreshAlerts = () => {
  ElMessage.success('告警数据已刷新')
}

const handleAlert = (alert) => {
  ElMessage.info(`处理告警: ${alert.title}`)
}

const viewAllTickets = () => {
  ElMessage.info('跳转到工单列表页面')
}

const viewTicket = (ticket) => {
  ElMessage.info(`查看工单: ${ticket.number}`)
}

const getTicketStatusType = (status) => {
  const types = {
    '新建': 'info',
    '已分配': 'warning',
    '处理中': 'primary',
    '已解决': 'success'
  }
  return types[status] || 'info'
}

const getAssetTypeColor = (type) => {
  const colors = {
    server: 'primary',
    network: 'success',
    storage: 'warning',
    security: 'danger'
  }
  return colors[type] || 'info'
}

const getAssetTypeText = (type) => {
  const texts = {
    server: '服务器',
    network: '网络设备',
    storage: '存储设备',
    security: '安全设备'
  }
  return texts[type] || type
}

const viewAssetDetail = (asset) => {
  ElMessage.info(`查看设备详情: ${asset.name}`)
}

const monitorAsset = (asset) => {
  ElMessage.info(`监控设备: ${asset.name}`)
}

const getFaultLevelType = (level) => {
  const types = {
    critical: 'danger',
    major: 'warning',
    minor: 'info'
  }
  return types[level] || 'info'
}

const getFaultLevelText = (level) => {
  const texts = {
    critical: '严重',
    major: '重要',
    minor: '一般'
  }
  return texts[level] || level
}

const getFaultStatusType = (status) => {
  const types = {
    '新建': 'info',
    '已分配': 'warning',
    '处理中': 'primary',
    '已解决': 'success'
  }
  return types[status] || 'info'
}

const viewFaultDetail = (fault) => {
  ElMessage.info(`查看故障详情: ${fault.id}`)
}

const resolveFault = (fault) => {
  ElMessageBox.confirm(`确定要解决故障 ${fault.id} 吗？`, '确认解决', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    fault.status = '已解决'
    fault.resolveTime = new Date().toLocaleString()
    ElMessage.success('故障已标记为解决')
  })
}

const generateReport = (template) => {
  ElMessage.success(`开始生成报表: ${template.name}`)
}

const generateCustomReport = () => {
  if (!customReport.value.name) {
    ElMessage.warning('请输入报表名称')
    return
  }
  ElMessage.success('自定义报表生成中...')
}

const saveReportTemplate = () => {
  ElMessage.success('报表模板已保存')
}

const downloadReport = (report) => {
  ElMessage.success(`下载报表: ${report.name}`)
}

const shareReport = (report) => {
  ElMessage.info(`分享报表: ${report.name}`)
}

onMounted(() => {
  console.log('甲方管理模块已加载')
})
</script>

<style scoped>
.client-management-demo {
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

/* 指标卡片样式 */
.metrics-row {
  margin-bottom: 24px;
}

.metric-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  overflow: hidden;
}

.metric-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
}

.metric-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.metric-card.health .metric-icon {
  background: linear-gradient(135deg, #67c23a 0%, #85ce61 100%);
}

.metric-card.tickets .metric-icon {
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
}

.metric-card.assets .metric-icon {
  background: linear-gradient(135deg, #e6a23c 0%, #ebb563 100%);
}

.metric-card.alerts .metric-icon {
  background: linear-gradient(135deg, #f56c6c 0%, #f78989 100%);
}

.metric-info {
  flex: 1;
  margin-left: 16px;
}

.metric-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
}

.metric-label {
  font-size: 14px;
  color: #909399;
  margin-top: 4px;
}

.metric-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 500;
}

.metric-trend.up {
  color: #67c23a;
}

.metric-trend.down {
  color: #f56c6c;
}

.metric-trend.stable {
  color: #909399;
}

/* 图表区域样式 */
.charts-row {
  margin-bottom: 24px;
}

.chart-container {
  height: 300px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.chart-placeholder {
  text-align: center;
  color: #909399;
}

.chart-placeholder h3 {
  margin: 16px 0 8px 0;
  color: #303133;
}

.chart-placeholder p {
  margin: 0;
  font-size: 14px;
}

.mock-chart {
  margin-top: 20px;
  width: 100%;
  max-width: 400px;
}

.chart-legend {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: 16px;
}

.legend-item {
  display: flex;
  align-items: center;
  font-size: 12px;
}

.legend-item::before {
  content: '';
  width: 12px;
  height: 12px;
  border-radius: 2px;
  margin-right: 6px;
}

.legend-item.cpu::before {
  background: #409eff;
}

.legend-item.memory::before {
  background: #67c23a;
}

.legend-item.disk::before {
  background: #e6a23c;
}

.chart-bars {
  display: flex;
  justify-content: center;
  gap: 20px;
  height: 100px;
  align-items: flex-end;
}

.bar-group {
  display: flex;
  gap: 4px;
  align-items: flex-end;
}

.bar {
  width: 12px;
  border-radius: 2px 2px 0 0;
}

.bar.cpu {
  background: #409eff;
}

.bar.memory {
  background: #67c23a;
}

.bar.disk {
  background: #e6a23c;
}

.mock-pie {
  margin-top: 20px;
}

.pie-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-width: 200px;
  margin: 0 auto;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
}

.stat-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
}

.stat-color.new {
  background: #409eff;
}

.stat-color.processing {
  background: #e6a23c;
}

.stat-color.resolved {
  background: #67c23a;
}

.stat-color.closed {
  background: #909399;
}

/* 信息行样式 */
.info-row {
  margin-bottom: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.alerts-list {
  max-height: 300px;
  overflow-y: auto;
}

.alert-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px;
  border-radius: 6px;
  margin-bottom: 8px;
  border-left: 4px solid transparent;
  background: #f8f9fa;
}

.alert-item.critical {
  border-left-color: #f56c6c;
  background: #fef0f0;
}

.alert-item.warning {
  border-left-color: #e6a23c;
  background: #fdf6ec;
}

.alert-item.major {
  border-left-color: #409eff;
  background: #ecf5ff;
}

.alert-icon {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e4e7ed;
  color: #909399;
  flex-shrink: 0;
}

.alert-content {
  flex: 1;
  min-width: 0;
}

.alert-title {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.alert-description {
  font-size: 13px;
  color: #606266;
  line-height: 1.4;
  margin-bottom: 4px;
}

.alert-time {
  font-size: 12px;
  color: #909399;
}

.alert-actions {
  flex-shrink: 0;
}

.tickets-list {
  max-height: 300px;
  overflow-y: auto;
}

.ticket-item {
  padding: 12px;
  border-radius: 6px;
  margin-bottom: 8px;
  background: #f8f9fa;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.ticket-item:hover {
  background: #e6f7ff;
  border-color: #409eff;
}

.ticket-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.ticket-number {
  font-size: 13px;
  font-weight: 500;
  color: #409eff;
}

.ticket-title {
  font-size: 14px;
  color: #303133;
  margin-bottom: 8px;
}

.ticket-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #909399;
}

/* 资产统计样式 */
.asset-stats {
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  border: 1px solid #e4e7ed;
  transition: all 0.3s ease;
}

.stat-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  transform: translateY(-2px);
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

.stat-icon.servers {
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
}

.stat-icon.network {
  background: linear-gradient(135deg, #67c23a 0%, #85ce61 100%);
}

.stat-icon.storage {
  background: linear-gradient(135deg, #e6a23c 0%, #ebb563 100%);
}

.stat-icon.security {
  background: linear-gradient(135deg, #f56c6c 0%, #f78989 100%);
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

/* 资产表格样式 */
.assets-table {
  margin-top: 20px;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

/* 故障统计样式 */
.fault-stats {
  margin-bottom: 24px;
}

.fault-stat-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  text-align: center;
}

.fault-stat-card.critical {
  background: linear-gradient(135deg, #f56c6c 0%, #f78989 100%);
  color: white;
}

.fault-stat-card.major {
  background: linear-gradient(135deg, #e6a23c 0%, #ebb563 100%);
  color: white;
}

.fault-stat-card.minor {
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
  color: white;
}

.fault-stat-card.resolved {
  background: linear-gradient(135deg, #67c23a 0%, #85ce61 100%);
  color: white;
}

.fault-stat-content {
  padding: 24px;
}

.fault-stat-number {
  font-size: 32px;
  font-weight: bold;
  line-height: 1;
  margin-bottom: 8px;
}

.fault-stat-label {
  font-size: 14px;
  opacity: 0.9;
}

/* 故障表格样式 */
.faults-table {
  margin-top: 20px;
}

/* 工单概览样式 */
.ticket-overview {
  margin-bottom: 24px;
}

.overview-card {
  height: 100%;
}

.overview-stats {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.overview-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.overview-item:last-child {
  border-bottom: none;
}

.overview-label {
  color: #909399;
  font-size: 14px;
}

.overview-value {
  color: #303133;
  font-weight: 500;
  font-size: 16px;
}

/* SLA卡片样式 */
.sla-card {
  height: 100%;
  text-align: center;
}

.sla-progress {
  margin-bottom: 20px;
}

.sla-percentage {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.sla-label {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.sla-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.sla-item {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  color: #606266;
}

/* 绩效卡片样式 */
.performance-card {
  height: 100%;
}

.engineer-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.engineer-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 6px;
}

.engineer-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.engineer-details {
  flex: 1;
}

.engineer-name {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
}

.engineer-stats {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}

.engineer-rating {
  flex-shrink: 0;
}

/* 趋势图表样式 */
.trend-charts {
  margin-bottom: 24px;
}

/* 报表模板样式 */
.report-templates {
  margin-bottom: 32px;
}

.report-templates h3 {
  margin: 0 0 20px 0;
  color: #303133;
  font-size: 18px;
}

.report-template-card {
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  height: 200px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.report-template-card:hover {
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
  transform: translateY(-2px);
}

.template-icon {
  font-size: 48px;
  color: #409eff;
  margin-bottom: 16px;
}

.template-info h4 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 16px;
}

.template-info p {
  margin: 0 0 16px 0;
  color: #606266;
  font-size: 13px;
  line-height: 1.4;
}

.template-actions {
  margin-top: auto;
}

/* 自定义报表样式 */
.custom-report {
  margin-bottom: 32px;
}

/* 报表历史样式 */
.report-history {
  margin-top: 20px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .client-management-demo {
    padding: 10px;
  }

  .metrics-row .el-col,
  .asset-stats .el-col,
  .fault-stats .el-col {
    margin-bottom: 12px;
  }

  .charts-row .el-col,
  .info-row .el-col,
  .ticket-overview .el-col,
  .trend-charts .el-col {
    margin-bottom: 20px;
  }

  .metric-content {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }

  .metric-trend {
    justify-content: center;
  }

  .table-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .header-actions {
    flex-direction: column;
  }

  .header-actions .el-input,
  .header-actions .el-select {
    width: 100% !important;
  }

  .report-templates .el-col {
    margin-bottom: 16px;
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

/* 标签页样式 */
.demo-tabs .el-tabs__header {
  background: #f8f9fa;
  margin: 0;
  padding: 0 20px;
}

.demo-tabs .el-tabs__content {
  padding: 0;
}

/* 进度条样式 */
.el-progress {
  margin: 0;
}

/* 表单样式 */
.el-form-item {
  margin-bottom: 18px;
}

.el-input, .el-select, .el-date-picker {
  border-radius: 6px;
}

/* 复选框组样式 */
.el-checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* 单选框组样式 */
.el-radio-group {
  display: flex;
  gap: 16px;
}

/* 评分组件样式 */
.el-rate {
  height: auto;
}

/* 滚动条样式 */
.alerts-list::-webkit-scrollbar,
.tickets-list::-webkit-scrollbar {
  width: 6px;
}

.alerts-list::-webkit-scrollbar-track,
.tickets-list::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.alerts-list::-webkit-scrollbar-thumb,
.tickets-list::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.alerts-list::-webkit-scrollbar-thumb:hover,
.tickets-list::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
