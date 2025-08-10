<template>
  <PageLayout
    title="绩效管理"
    description="工程师绩效评估和团队表现分析系统"
    icon="TrendCharts"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新建评估
      </el-button>
      <el-button @click="exportReport">
        <el-icon><Download /></el-icon>
        导出报告
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in performanceStatsCards" :key="stat.label">
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
      <!-- 绩效概览 -->
      <el-tab-pane label="绩效概览" name="overview">
        <div class="tab-content">


          <!-- 图表区域 -->
          <el-row :gutter="20" class="charts-row">
            <el-col :span="12">
              <el-card title="绩效趋势分析">
                <template #header>
                  <div class="card-header">
                    <span>绩效趋势分析</span>
                    <el-select v-model="trendPeriod" size="small" style="width: 120px">
                      <el-option label="最近7天" value="7d" />
                      <el-option label="最近30天" value="30d" />
                      <el-option label="最近3个月" value="3m" />
                      <el-option label="最近1年" value="1y" />
                    </el-select>
                  </div>
                </template>

                <div class="chart-container">
                  <div class="chart-placeholder">
                    <el-icon size="48"><TrendCharts /></el-icon>
                    <h3>绩效趋势图</h3>
                    <p>显示团队和个人绩效变化趋势</p>
                    <div class="mock-chart">
                      <div class="chart-legend">
                        <span class="legend-item team">团队平均</span>
                        <span class="legend-item individual">个人最高</span>
                        <span class="legend-item target">目标线</span>
                      </div>
                      <div class="trend-lines">
                        <div class="trend-line team-line"></div>
                        <div class="trend-line individual-line"></div>
                        <div class="trend-line target-line"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>

            <el-col :span="12">
              <el-card title="绩效分布">
                <div class="chart-container">
                  <div class="chart-placeholder">
                    <el-icon size="48"><PieChart /></el-icon>
                    <h3>绩效等级分布</h3>
                    <p>各绩效等级人员分布情况</p>
                    <div class="mock-pie">
                      <div class="pie-stats">
                        <div class="stat-item">
                          <span class="stat-color excellent"></span>
                          <span>优秀(90+): 8人</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-color good"></span>
                          <span>良好(80-89): 15人</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-color average"></span>
                          <span>一般(70-79): 12人</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-color poor"></span>
                          <span>待改进(<70): 3人</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <!-- 团队绩效对比 -->
          <el-row :gutter="20" class="team-row">
            <el-col :span="16">
              <el-card title="团队绩效对比">
                <div class="team-comparison">
                  <div
                    v-for="team in teamPerformance"
                    :key="team.id"
                    class="team-item"
                  >
                    <div class="team-header">
                      <div class="team-info">
                        <h4>{{ team.name }}</h4>
                        <span class="team-leader">负责人: {{ team.leader }}</span>
                      </div>
                      <div class="team-score">
                        <span class="score-value">{{ team.avgScore }}</span>
                        <span class="score-label">分</span>
                      </div>
                    </div>

                    <div class="team-progress">
                      <el-progress
                        :percentage="team.avgScore"
                        :color="getScoreColor(team.avgScore)"
                        :stroke-width="12"
                        :show-text="false"
                      />
                    </div>

                    <div class="team-metrics">
                      <div class="metric">
                        <span class="metric-label">成员数:</span>
                        <span class="metric-value">{{ team.memberCount }}人</span>
                      </div>
                      <div class="metric">
                        <span class="metric-label">解决工单:</span>
                        <span class="metric-value">{{ team.ticketsResolved }}个</span>
                      </div>
                      <div class="metric">
                        <span class="metric-label">平均响应:</span>
                        <span class="metric-value">{{ team.avgResponseTime }}</span>
                      </div>
                      <div class="metric">
                        <span class="metric-label">客户评分:</span>
                        <span class="metric-value">{{ team.customerRating }}分</span>
                      </div>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>

            <el-col :span="8">
              <el-card title="关键指标">
                <div class="kpi-metrics">
                  <div class="kpi-item">
                    <div class="kpi-header">
                      <span class="kpi-label">工单解决率</span>
                      <span class="kpi-value">{{ kpiMetrics.resolutionRate }}%</span>
                    </div>
                    <el-progress
                      :percentage="kpiMetrics.resolutionRate"
                      color="#67c23a"
                      :stroke-width="6"
                      :show-text="false"
                    />
                  </div>

                  <div class="kpi-item">
                    <div class="kpi-header">
                      <span class="kpi-label">首次解决率</span>
                      <span class="kpi-value">{{ kpiMetrics.firstCallResolution }}%</span>
                    </div>
                    <el-progress
                      :percentage="kpiMetrics.firstCallResolution"
                      color="#409eff"
                      :stroke-width="6"
                      :show-text="false"
                    />
                  </div>

                  <div class="kpi-item">
                    <div class="kpi-header">
                      <span class="kpi-label">平均响应时间</span>
                      <span class="kpi-value">{{ kpiMetrics.avgResponseTime }}</span>
                    </div>
                    <div class="kpi-trend">
                      <el-icon color="#67c23a"><Bottom /></el-icon>
                      <span>较上月减少15%</span>
                    </div>
                  </div>

                  <div class="kpi-item">
                    <div class="kpi-header">
                      <span class="kpi-label">知识库贡献</span>
                      <span class="kpi-value">{{ kpiMetrics.knowledgeContribution }}</span>
                    </div>
                    <div class="kpi-trend">
                      <el-icon color="#67c23a"><Top /></el-icon>
                      <span>较上月增加8篇</span>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>

      <!-- 工程师排行 -->
      <el-tab-pane label="工程师排行" name="ranking">
        <div class="tab-content">
          <div class="ranking-header">
            <div class="ranking-controls">
              <el-select v-model="rankingPeriod" style="width: 120px; margin-right: 12px">
                <el-option label="本月" value="month" />
                <el-option label="本季度" value="quarter" />
                <el-option label="本年度" value="year" />
              </el-select>
              <el-select v-model="rankingDepartment" style="width: 120px; margin-right: 12px">
                <el-option label="全部部门" value="all" />
                <el-option label="运维部" value="ops" />
                <el-option label="网络部" value="network" />
                <el-option label="安全部" value="security" />
              </el-select>
              <el-button type="primary" @click="refreshRanking">
                <el-icon><Refresh /></el-icon>
                刷新排行
              </el-button>
              <el-button @click="exportRanking">
                <el-icon><Download /></el-icon>
                导出数据
              </el-button>
            </div>
          </div>

          <el-card class="ranking-card">
            <el-table :data="engineerRankings" style="width: 100%" row-class-name="ranking-row">
              <el-table-column label="排名" width="80" align="center">
                <template #default="{ $index }">
                  <div class="ranking-badge">
                    <el-icon v-if="$index === 0" color="#FFD700" size="24"><Trophy /></el-icon>
                    <el-icon v-else-if="$index === 1" color="#C0C0C0" size="24"><Trophy /></el-icon>
                    <el-icon v-else-if="$index === 2" color="#CD7F32" size="24"><Trophy /></el-icon>
                    <span v-else class="rank-number">{{ $index + 1 }}</span>
                  </div>
                </template>
              </el-table-column>

              <el-table-column label="工程师" width="200">
                <template #default="{ row }">
                  <div class="engineer-info">
                    <el-avatar :size="40" :src="row.avatar">{{ row.name.charAt(0) }}</el-avatar>
                    <div class="engineer-details">
                      <div class="engineer-name">{{ row.name }}</div>
                      <div class="engineer-title">{{ row.title }}</div>
                    </div>
                  </div>
                </template>
              </el-table-column>

              <el-table-column prop="department" label="部门" width="120" />

              <el-table-column label="综合得分" width="180">
                <template #default="{ row }">
                  <div class="score-display">
                    <el-progress
                      :percentage="row.totalScore"
                      :color="getScoreColor(row.totalScore)"
                      :stroke-width="8"
                    />
                    <span class="score-text">{{ row.totalScore }}分</span>
                  </div>
                </template>
              </el-table-column>

              <el-table-column prop="ticketsResolved" label="解决工单" width="100" align="center" />

              <el-table-column prop="avgResolutionTime" label="平均处理时间" width="120" align="center" />

              <el-table-column label="客户评分" width="150" align="center">
                <template #default="{ row }">
                  <el-rate
                    :model-value="row.customerRating"
                    disabled
                    show-score
                    text-color="#ff9900"
                    score-template="{value}分"
                  />
                </template>
              </el-table-column>

              <el-table-column prop="slaCompliance" label="SLA达成率" width="120" align="center">
                <template #default="{ row }">
                  <el-tag :type="getSlaTagType(row.slaCompliance)">
                    {{ row.slaCompliance }}%
                  </el-tag>
                </template>
              </el-table-column>

              <el-table-column label="操作" width="150" align="center">
                <template #default="{ row }">
                  <el-button size="small" @click="viewEngineerDetail(row)">详情</el-button>
                  <el-button size="small" type="primary" @click="viewPerformanceHistory(row)">历史</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>

      <!-- 绩效评估 -->
      <el-tab-pane label="绩效评估" name="evaluation">
        <div class="tab-content">
          <div class="evaluation-header">
            <h3>绩效评估管理</h3>
            <div class="evaluation-actions">
              <el-button type="primary" @click="startNewEvaluation">
                <el-icon><Plus /></el-icon>
                新建评估
              </el-button>
              <el-button @click="importEvaluationData">
                <el-icon><Upload /></el-icon>
                导入数据
              </el-button>
            </div>
          </div>

          <el-row :gutter="20">
            <el-col :span="8">
              <el-card title="评估周期管理">
                <div class="evaluation-cycles">
                  <div
                    v-for="cycle in evaluationCycles"
                    :key="cycle.id"
                    class="cycle-item"
                    :class="{ active: cycle.status === 'active' }"
                  >
                    <div class="cycle-header">
                      <h4>{{ cycle.name }}</h4>
                      <el-tag :type="getCycleTagType(cycle.status)">{{ getCycleStatusText(cycle.status) }}</el-tag>
                    </div>
                    <div class="cycle-info">
                      <p>评估期间: {{ cycle.startDate }} - {{ cycle.endDate }}</p>
                      <p>参与人数: {{ cycle.participantCount }}人</p>
                      <p>完成进度: {{ cycle.completionRate }}%</p>
                    </div>
                    <div class="cycle-actions">
                      <el-button size="small" @click="manageCycle(cycle)">管理</el-button>
                      <el-button size="small" type="primary" @click="viewCycleReport(cycle)">报告</el-button>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>

            <el-col :span="16">
              <el-card title="评估指标配置">
                <div class="metrics-config">
                  <el-table :data="evaluationMetrics" style="width: 100%">
                    <el-table-column prop="category" label="评估类别" width="120" />
                    <el-table-column prop="metric" label="评估指标" width="200" />
                    <el-table-column prop="weight" label="权重" width="100" align="center">
                      <template #default="{ row }">
                        <span>{{ row.weight }}%</span>
                      </template>
                    </el-table-column>
                    <el-table-column prop="description" label="评估标准" />
                    <el-table-column label="状态" width="100" align="center">
                      <template #default="{ row }">
                        <el-switch v-model="row.enabled" />
                      </template>
                    </el-table-column>
                    <el-table-column label="操作" width="120" align="center">
                      <template #default="{ row }">
                        <el-button size="small" @click="editMetric(row)">编辑</el-button>
                      </template>
                    </el-table-column>
                  </el-table>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>

      <!-- 报表分析 -->
      <el-tab-pane label="报表分析" name="reports">
        <div class="tab-content">
          <div class="reports-header">
            <h3>绩效报表分析</h3>
            <div class="report-actions">
              <el-button type="primary" @click="generateReport">
                <el-icon><Document /></el-icon>
                生成报告
              </el-button>
              <el-button @click="scheduleReport">
                <el-icon><Timer /></el-icon>
                定时报告
              </el-button>
              <el-button @click="exportAllData">
                <el-icon><Download /></el-icon>
                导出数据
              </el-button>
            </div>
          </div>

          <el-row :gutter="20">
            <el-col :span="12">
              <el-card title="报表模板">
                <div class="report-templates">
                  <div
                    v-for="template in reportTemplates"
                    :key="template.id"
                    class="template-item"
                    @click="selectTemplate(template)"
                  >
                    <div class="template-icon">
                      <el-icon size="32"><Document /></el-icon>
                    </div>
                    <div class="template-info">
                      <h4>{{ template.name }}</h4>
                      <p>{{ template.description }}</p>
                      <div class="template-meta">
                        <span>更新时间: {{ template.updateTime }}</span>
                        <span>使用次数: {{ template.usageCount }}</span>
                      </div>
                    </div>
                    <div class="template-actions">
                      <el-button size="small" type="primary">使用</el-button>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>

            <el-col :span="12">
              <el-card title="历史报告">
                <div class="report-history">
                  <el-table :data="reportHistory" style="width: 100%">
                    <el-table-column prop="name" label="报告名称" />
                    <el-table-column prop="type" label="报告类型" width="120" />
                    <el-table-column prop="generateTime" label="生成时间" width="150" />
                    <el-table-column prop="fileSize" label="文件大小" width="100" />
                    <el-table-column label="状态" width="100" align="center">
                      <template #default="{ row }">
                        <el-tag :type="getReportStatusType(row.status)">
                          {{ getReportStatusText(row.status) }}
                        </el-tag>
                      </template>
                    </el-table-column>
                    <el-table-column label="操作" width="150" align="center">
                      <template #default="{ row }">
                        <el-button size="small" @click="downloadReport(row)">下载</el-button>
                        <el-button size="small" type="primary" @click="shareReport(row)">分享</el-button>
                      </template>
                    </el-table-column>
                  </el-table>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>
    </el-tabs>
    </template>

    <!-- 新建评估对话框 -->
    <el-dialog
      v-model="showCreateDialog"
      title="新建绩效评估"
      width="800px"
      :before-close="handleCloseDialog"
    >
      <el-form
        ref="evaluationFormRef"
        :model="evaluationForm"
        :rules="evaluationRules"
        label-width="120px"
        label-position="left"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="评估名称" prop="name">
              <el-input
                v-model="evaluationForm.name"
                placeholder="请输入评估名称"
                clearable
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="评估周期" prop="period">
              <el-select
                v-model="evaluationForm.period"
                placeholder="请选择评估周期"
                style="width: 100%"
              >
                <el-option label="月度评估" value="monthly" />
                <el-option label="季度评估" value="quarterly" />
                <el-option label="半年度评估" value="semi-annual" />
                <el-option label="年度评估" value="annual" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="评估开始时间" prop="startDate">
              <el-date-picker
                v-model="evaluationForm.startDate"
                type="date"
                placeholder="选择开始时间"
                style="width: 100%"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="评估结束时间" prop="endDate">
              <el-date-picker
                v-model="evaluationForm.endDate"
                type="date"
                placeholder="选择结束时间"
                style="width: 100%"
                format="YYYY-MM-DD"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="评估对象" prop="participants">
          <el-select
            v-model="evaluationForm.participants"
            multiple
            placeholder="请选择评估对象"
            style="width: 100%"
            filterable
          >
            <el-option
              v-for="engineer in engineerRankings"
              :key="engineer.id"
              :label="engineer.name"
              :value="engineer.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="评估指标配置">
          <el-table :data="evaluationForm.metrics" style="width: 100%">
            <el-table-column prop="category" label="评估类别" width="120" />
            <el-table-column prop="metric" label="评估指标" width="180" />
            <el-table-column label="权重" width="120" align="center">
              <template #default="{ row, $index }">
                <el-input-number
                  v-model="row.weight"
                  :min="0"
                  :max="100"
                  :step="5"
                  size="small"
                  @change="updateWeightTotal"
                />
              </template>
            </el-table-column>
            <el-table-column label="启用" width="80" align="center">
              <template #default="{ row }">
                <el-switch v-model="row.enabled" @change="updateWeightTotal" />
              </template>
            </el-table-column>
            <el-table-column prop="description" label="评估标准" />
          </el-table>
          <div class="weight-summary">
            <span>总权重: {{ totalWeight }}%</span>
            <el-tag :type="totalWeight === 100 ? 'success' : 'warning'">
              {{ totalWeight === 100 ? '权重配置正确' : '权重需要等于100%' }}
            </el-tag>
          </div>
        </el-form-item>

        <el-form-item label="评估说明" prop="description">
          <el-input
            v-model="evaluationForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入评估说明和要求"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="handleCloseDialog">取消</el-button>
          <el-button type="primary" @click="handleSaveEvaluation" :loading="saving">
            {{ saving ? '保存中...' : '保存' }}
          </el-button>
        </div>
      </template>
    </el-dialog>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  User, Medal, Timer, Star, TrendCharts, PieChart, Top, Bottom, Minus,
  Trophy, Refresh, Download, Plus, Upload, Document,
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('overview')
const trendPeriod = ref('30d')
const rankingPeriod = ref('month')
const rankingDepartment = ref('all')

// 绩效统计数据
const performanceStats = reactive({
  totalEngineers: 38,
  avgScore: 85.2,
  slaCompliance: 94.8,
  customerSatisfaction: 4.6
})

// 统计卡片数据
const performanceStatsCards = computed(() => [
  {
    label: '工程师总数',
    value: performanceStats.totalEngineers,
    icon: 'User',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 7.9
  },
  {
    label: '平均绩效分',
    value: performanceStats.avgScore,
    icon: 'Medal',
    color: 'var(--el-color-success, #10b981)',
    trend: 3.2
  },
  {
    label: 'SLA达成率',
    value: `${performanceStats.slaCompliance}%`,
    icon: 'Timer',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 1.5
  },
  {
    label: '客户满意度',
    value: performanceStats.customerSatisfaction,
    icon: 'Star',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 0.3
  }
])

// 团队绩效数据
const teamPerformance = ref([
  {
    id: 1,
    name: '运维团队',
    leader: '张工程师',
    avgScore: 88,
    memberCount: 12,
    ticketsResolved: 156,
    avgResponseTime: '15分钟',
    customerRating: 4.7
  },
  {
    id: 2,
    name: '网络团队',
    leader: '李工程师',
    avgScore: 85,
    memberCount: 8,
    ticketsResolved: 89,
    avgResponseTime: '12分钟',
    customerRating: 4.5
  },
  {
    id: 3,
    name: '安全团队',
    leader: '王工程师',
    avgScore: 92,
    memberCount: 6,
    ticketsResolved: 67,
    avgResponseTime: '18分钟',
    customerRating: 4.8
  },
  {
    id: 4,
    name: '数据库团队',
    leader: '赵工程师',
    avgScore: 83,
    memberCount: 5,
    ticketsResolved: 45,
    avgResponseTime: '25分钟',
    customerRating: 4.4
  }
])

// KPI指标数据
const kpiMetrics = reactive({
  resolutionRate: 96.5,
  firstCallResolution: 78.3,
  avgResponseTime: '16.8分钟',
  knowledgeContribution: 23
})

// 工程师排行数据
const engineerRankings = ref([
  {
    id: 1,
    name: '张工程师',
    title: '高级运维工程师',
    department: '运维部',
    avatar: '',
    totalScore: 95,
    ticketsResolved: 45,
    avgResolutionTime: '12分钟',
    customerRating: 4.9,
    slaCompliance: 98.5
  },
  {
    id: 2,
    name: '李工程师',
    title: '网络工程师',
    department: '网络部',
    avatar: '',
    totalScore: 92,
    ticketsResolved: 38,
    avgResolutionTime: '15分钟',
    customerRating: 4.7,
    slaCompliance: 96.2
  },
  {
    id: 3,
    name: '王工程师',
    title: '安全工程师',
    department: '安全部',
    avatar: '',
    totalScore: 90,
    ticketsResolved: 32,
    avgResolutionTime: '18分钟',
    customerRating: 4.8,
    slaCompliance: 97.1
  },
  {
    id: 4,
    name: '赵工程师',
    title: '数据库工程师',
    department: '数据库部',
    avatar: '',
    totalScore: 88,
    ticketsResolved: 28,
    avgResolutionTime: '22分钟',
    customerRating: 4.5,
    slaCompliance: 94.8
  },
  {
    id: 5,
    name: '陈工程师',
    title: '运维工程师',
    department: '运维部',
    avatar: '',
    totalScore: 85,
    ticketsResolved: 35,
    avgResolutionTime: '20分钟',
    customerRating: 4.4,
    slaCompliance: 93.5
  }
])

// 评估周期数据
const evaluationCycles = ref([
  {
    id: 1,
    name: '2024年第一季度评估',
    status: 'completed',
    startDate: '2024-01-01',
    endDate: '2024-03-31',
    participantCount: 38,
    completionRate: 100
  },
  {
    id: 2,
    name: '2024年第二季度评估',
    status: 'active',
    startDate: '2024-04-01',
    endDate: '2024-06-30',
    participantCount: 38,
    completionRate: 75
  },
  {
    id: 3,
    name: '2024年第三季度评估',
    status: 'pending',
    startDate: '2024-07-01',
    endDate: '2024-09-30',
    participantCount: 40,
    completionRate: 0
  }
])

// 评估指标数据
const evaluationMetrics = ref([
  {
    id: 1,
    category: '工作质量',
    metric: '工单解决质量',
    weight: 25,
    description: '工单解决的准确性和完整性',
    enabled: true
  },
  {
    id: 2,
    category: '工作效率',
    metric: '响应时间',
    weight: 20,
    description: '接收工单到开始处理的时间',
    enabled: true
  },
  {
    id: 3,
    category: '工作效率',
    metric: '解决时间',
    weight: 20,
    description: '从开始处理到完成解决的时间',
    enabled: true
  },
  {
    id: 4,
    category: '客户服务',
    metric: '客户满意度',
    weight: 15,
    description: '客户对服务质量的评价',
    enabled: true
  },
  {
    id: 5,
    category: '团队协作',
    metric: '知识分享',
    weight: 10,
    description: '知识库贡献和经验分享',
    enabled: true
  },
  {
    id: 6,
    category: '专业发展',
    metric: '技能提升',
    weight: 10,
    description: '技术能力和专业知识的提升',
    enabled: true
  }
])

// 报表模板数据
const reportTemplates = ref([
  {
    id: 1,
    name: '月度绩效报告',
    description: '包含个人和团队月度绩效分析',
    updateTime: '2024-01-15',
    usageCount: 12
  },
  {
    id: 2,
    name: '季度绩效总结',
    description: '季度绩效趋势和改进建议',
    updateTime: '2024-01-10',
    usageCount: 8
  },
  {
    id: 3,
    name: 'SLA达成报告',
    description: '服务等级协议达成情况分析',
    updateTime: '2024-01-12',
    usageCount: 15
  },
  {
    id: 4,
    name: '客户满意度报告',
    description: '客户反馈和满意度统计分析',
    updateTime: '2024-01-08',
    usageCount: 6
  }
])

// 报告历史数据
const reportHistory = ref([
  {
    id: 1,
    name: '2024年1月绩效报告',
    type: '月度报告',
    generateTime: '2024-01-31 18:00:00',
    fileSize: '2.5MB',
    status: 'completed'
  },
  {
    id: 2,
    name: '2024年Q1季度报告',
    type: '季度报告',
    generateTime: '2024-01-30 16:30:00',
    fileSize: '4.2MB',
    status: 'completed'
  },
  {
    id: 3,
    name: 'SLA达成分析报告',
    type: 'SLA报告',
    generateTime: '2024-01-29 14:15:00',
    fileSize: '1.8MB',
    status: 'completed'
  }
])

// 工具函数
const getScoreColor = (score) => {
  if (score >= 90) return '#67c23a'
  if (score >= 80) return '#e6a23c'
  if (score >= 70) return '#f56c6c'
  return '#909399'
}

const getSlaTagType = (sla) => {
  if (sla >= 95) return 'success'
  if (sla >= 90) return 'warning'
  return 'danger'
}

const getCycleTagType = (status) => {
  switch (status) {
    case 'active': return 'success'
    case 'completed': return 'info'
    case 'pending': return 'warning'
    default: return 'info'
  }
}

const getCycleStatusText = (status) => {
  switch (status) {
    case 'active': return '进行中'
    case 'completed': return '已完成'
    case 'pending': return '待开始'
    default: return '未知'
  }
}

const getReportStatusType = (status) => {
  switch (status) {
    case 'completed': return 'success'
    case 'generating': return 'warning'
    case 'failed': return 'danger'
    default: return 'info'
  }
}

const getReportStatusText = (status) => {
  switch (status) {
    case 'completed': return '已完成'
    case 'generating': return '生成中'
    case 'failed': return '失败'
    default: return '未知'
  }
}

// 事件处理方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const showCreateDialog = ref(false)
const saving = ref(false)
const evaluationFormRef = ref(null)

// 评估表单数据
const evaluationForm = reactive({
  name: '',
  period: '',
  startDate: '',
  endDate: '',
  participants: [],
  description: '',
  metrics: [
    {
      id: 1,
      category: '工作质量',
      metric: '工单解决质量',
      weight: 25,
      description: '工单解决的准确性和完整性',
      enabled: true
    },
    {
      id: 2,
      category: '工作效率',
      metric: '响应时间',
      weight: 20,
      description: '接收工单到开始处理的时间',
      enabled: true
    },
    {
      id: 3,
      category: '工作效率',
      metric: '解决时间',
      weight: 20,
      description: '从开始处理到完成解决的时间',
      enabled: true
    },
    {
      id: 4,
      category: '客户服务',
      metric: '客户满意度',
      weight: 15,
      description: '客户对服务质量的评价',
      enabled: true
    },
    {
      id: 5,
      category: '团队协作',
      metric: '知识分享',
      weight: 10,
      description: '知识库贡献和经验分享',
      enabled: true
    },
    {
      id: 6,
      category: '专业发展',
      metric: '技能提升',
      weight: 10,
      description: '技术能力和专业知识的提升',
      enabled: true
    }
  ]
})

// 表单验证规则
const evaluationRules = {
  name: [
    { required: true, message: '请输入评估名称', trigger: 'blur' },
    { min: 2, max: 50, message: '评估名称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  period: [
    { required: true, message: '请选择评估周期', trigger: 'change' }
  ],
  startDate: [
    { required: true, message: '请选择开始时间', trigger: 'change' }
  ],
  endDate: [
    { required: true, message: '请选择结束时间', trigger: 'change' }
  ],
  participants: [
    { required: true, message: '请选择评估对象', trigger: 'change' },
    { type: 'array', min: 1, message: '至少选择一个评估对象', trigger: 'change' }
  ]
}

// 计算总权重
const totalWeight = computed(() => {
  return evaluationForm.metrics
    .filter(metric => metric.enabled)
    .reduce((sum, metric) => sum + metric.weight, 0)
})

const exportReport = () => {
  ElMessage.success('报告导出成功')
}

const refreshRanking = () => {
  ElMessage.success('排行榜数据已刷新')
}

const exportRanking = () => {
  ElMessage.success('排行榜数据导出成功')
}

const viewEngineerDetail = (engineer) => {
  ElMessage.info(`查看 ${engineer.name} 的详细信息`)
}

const viewPerformanceHistory = (engineer) => {
  ElMessage.info(`查看 ${engineer.name} 的绩效历史`)
}

const startNewEvaluation = () => {
  showCreateDialog.value = true
}

// 更新权重总计
const updateWeightTotal = () => {
  // 权重更新时的逻辑处理
  console.log('权重总计:', totalWeight.value)
}

// 处理对话框关闭
const handleCloseDialog = () => {
  showCreateDialog.value = false
  resetForm()
}

// 重置表单
const resetForm = () => {
  if (evaluationFormRef.value) {
    evaluationFormRef.value.resetFields()
  }
  evaluationForm.name = ''
  evaluationForm.period = ''
  evaluationForm.startDate = ''
  evaluationForm.endDate = ''
  evaluationForm.participants = []
  evaluationForm.description = ''
  // 重置指标权重
  evaluationForm.metrics.forEach(metric => {
    metric.enabled = true
  })
  evaluationForm.metrics[0].weight = 25
  evaluationForm.metrics[1].weight = 20
  evaluationForm.metrics[2].weight = 20
  evaluationForm.metrics[3].weight = 15
  evaluationForm.metrics[4].weight = 10
  evaluationForm.metrics[5].weight = 10
}

// 保存评估
const handleSaveEvaluation = async () => {
  if (!evaluationFormRef.value) return

  try {
    // 验证表单
    await evaluationFormRef.value.validate()

    // 验证权重总计
    if (totalWeight.value !== 100) {
      ElMessage.error('评估指标权重总计必须等于100%')
      return
    }

    // 验证日期
    if (new Date(evaluationForm.endDate) <= new Date(evaluationForm.startDate)) {
      ElMessage.error('结束时间必须晚于开始时间')
      return
    }

    saving.value = true

    // 模拟保存过程
    await new Promise(resolve => setTimeout(resolve, 1500))

    // 创建新的评估记录
    const newEvaluation = {
      id: Date.now(),
      name: evaluationForm.name,
      period: evaluationForm.period,
      startDate: evaluationForm.startDate,
      endDate: evaluationForm.endDate,
      participants: evaluationForm.participants,
      description: evaluationForm.description,
      metrics: evaluationForm.metrics.filter(m => m.enabled),
      status: 'pending',
      createdAt: new Date().toISOString(),
      createdBy: '当前用户',
      participantCount: evaluationForm.participants.length,
      completionRate: 0
    }

    // 添加到评估周期列表
    evaluationCycles.value.unshift(newEvaluation)

    ElMessage.success('绩效评估创建成功')
    handleCloseDialog()
  } catch (error) {
    console.error('表单验证失败:', error)
    ElMessage.error('请检查表单填写是否完整')
  } finally {
    saving.value = false
  }
}

const importEvaluationData = () => {
  ElMessage.info('导入评估数据')
}

const manageCycle = (cycle) => {
  ElMessage.info(`管理评估周期: ${cycle.name}`)
}

const viewCycleReport = (cycle) => {
  ElMessage.info(`查看评估报告: ${cycle.name}`)
}

const editMetric = (metric) => {
  ElMessage.info(`编辑评估指标: ${metric.metric}`)
}

const generateReport = () => {
  ElMessage.success('报告生成中，请稍候...')
}

const scheduleReport = () => {
  ElMessage.info('设置定时报告')
}

const exportAllData = () => {
  ElMessage.success('数据导出成功')
}

const selectTemplate = (template) => {
  ElMessage.info(`选择报表模板: ${template.name}`)
}

const downloadReport = (report) => {
  ElMessage.success(`下载报告: ${report.name}`)
}

const shareReport = (report) => {
  ElMessage.info(`分享报告: ${report.name}`)
}

// 组件挂载
onMounted(() => {
  console.log('绩效管理模块已加载')
})
</script>

<style scoped>
.performance-demo {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 28px;
  color: #303133;
  margin: 0 0 8px 0;
}

.page-header p {
  color: #606266;
  margin: 0;
  font-size: 14px;
}

.demo-tabs {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.tab-content {
  padding: 20px;
}


/* 图表区域样式 */
.charts-row {
  margin-bottom: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
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
  color: #606266;
}

.chart-placeholder p {
  margin: 0;
  font-size: 14px;
}

.mock-chart {
  margin-top: 20px;
  width: 100%;
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

.legend-item.team::before {
  background-color: #409eff;
}

.legend-item.individual::before {
  background-color: #67c23a;
}

.legend-item.target::before {
  background-color: #e6a23c;
}

.trend-lines {
  height: 120px;
  position: relative;
  background: linear-gradient(to right, #f8f9fa 0%, #e9ecef 50%, #f8f9fa 100%);
  border-radius: 4px;
}

.trend-line {
  position: absolute;
  height: 2px;
  width: 80%;
  left: 10%;
  border-radius: 1px;
}

.trend-line.team-line {
  background-color: #409eff;
  top: 40%;
  transform: rotate(2deg);
}

.trend-line.individual-line {
  background-color: #67c23a;
  top: 30%;
  transform: rotate(3deg);
}

.trend-line.target-line {
  background-color: #e6a23c;
  top: 50%;
  border-style: dashed;
}

.mock-pie {
  margin-top: 20px;
}

.pie-stats {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  font-size: 14px;
}

.stat-color {
  width: 16px;
  height: 16px;
  border-radius: 2px;
  margin-right: 8px;
}

.stat-color.excellent {
  background-color: #67c23a;
}

.stat-color.good {
  background-color: #409eff;
}

.stat-color.average {
  background-color: #e6a23c;
}

.stat-color.poor {
  background-color: #f56c6c;
}

/* 团队绩效对比样式 */
.team-row {
  margin-bottom: 24px;
}

.team-comparison {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.team-item {
  padding: 20px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background-color: #fafafa;
  transition: all 0.3s ease;
}

.team-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 12px 0 rgba(64, 158, 255, 0.12);
}

.team-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.team-info h4 {
  margin: 0 0 4px 0;
  color: #303133;
  font-size: 16px;
}

.team-leader {
  font-size: 12px;
  color: #909399;
}

.team-score {
  text-align: right;
}

.score-value {
  font-size: 24px;
  font-weight: bold;
  color: #409eff;
}

.score-label {
  font-size: 12px;
  color: #909399;
}

.team-progress {
  margin-bottom: 12px;
}

.team-metrics {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.metric {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
}

.metric-label {
  color: #909399;
}

.metric-value {
  color: #303133;
  font-weight: 500;
}

/* KPI指标样式 */
.kpi-metrics {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.kpi-item {
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  background-color: #fafafa;
}

.kpi-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.kpi-label {
  font-size: 14px;
  color: #606266;
}

.kpi-value {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}

.kpi-trend {
  display: flex;
  align-items: center;
  font-size: 12px;
  color: #67c23a;
  margin-top: 8px;
}

.kpi-trend span {
  margin-left: 4px;
}

/* 排行榜样式 */
.ranking-header {
  margin-bottom: 20px;
}

.ranking-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ranking-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.ranking-badge {
  display: flex;
  align-items: center;
  justify-content: center;
}

.rank-number {
  font-size: 18px;
  font-weight: bold;
  color: #606266;
}

.engineer-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.engineer-details {
  display: flex;
  flex-direction: column;
}

.engineer-name {
  font-weight: 500;
  color: #303133;
}

.engineer-title {
  font-size: 12px;
  color: #909399;
}

.score-display {
  display: flex;
  align-items: center;
  gap: 12px;
}

.score-text {
  font-weight: 500;
  color: #303133;
  min-width: 50px;
}

/* 评估管理样式 */
.evaluation-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.evaluation-header h3 {
  margin: 0;
  color: #303133;
}

.evaluation-actions {
  display: flex;
  gap: 12px;
}

.evaluation-cycles {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.cycle-item {
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background-color: #fafafa;
  transition: all 0.3s ease;
}

.cycle-item.active {
  border-color: #67c23a;
  background-color: #f0f9ff;
}

.cycle-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px 0 rgba(64, 158, 255, 0.12);
}

.cycle-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.cycle-header h4 {
  margin: 0;
  color: #303133;
  font-size: 16px;
}

.cycle-info {
  margin-bottom: 12px;
}

.cycle-info p {
  margin: 4px 0;
  font-size: 14px;
  color: #606266;
}

.cycle-actions {
  display: flex;
  gap: 8px;
}

.metrics-config {
  background-color: white;
}

/* 报表分析样式 */
.reports-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.reports-header h3 {
  margin: 0;
  color: #303133;
}

.report-actions {
  display: flex;
  gap: 12px;
}

.report-templates {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.template-item {
  display: flex;
  align-items: center;
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background-color: #fafafa;
  cursor: pointer;
  transition: all 0.3s ease;
}

.template-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px 0 rgba(64, 158, 255, 0.12);
}

.template-icon {
  margin-right: 16px;
  color: #409eff;
}

.template-info {
  flex: 1;
}

.template-info h4 {
  margin: 0 0 4px 0;
  color: #303133;
  font-size: 16px;
}

.template-info p {
  margin: 0 0 8px 0;
  color: #606266;
  font-size: 14px;
}

.template-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #909399;
}

.template-actions {
  margin-left: 16px;
}

.report-history {
  background-color: white;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .performance-demo {
    padding: 12px;
  }

  .stats-row .el-col {
    margin-bottom: 12px;
  }

  .team-metrics {
    grid-template-columns: 1fr;
  }

  .ranking-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .evaluation-header,
  .reports-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
}

/* 新建评估对话框样式 */
.weight-summary {
  margin-top: 10px;
  padding: 10px;
  background-color: #f5f7fa;
  border-radius: 4px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.weight-summary span {
  font-weight: 500;
}

.dialog-footer {
  text-align: right;
}

.el-form-item {
  margin-bottom: 20px;
}

.el-table .el-input-number {
  width: 80px;
}
</style>