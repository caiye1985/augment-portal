<template>
  <PageLayout
    title="智能派单系统"
    description="基于AI算法的智能工单分配和负载均衡"
    icon="Document"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showRuleDialog = true">
        <el-icon><Setting /></el-icon>
        派单规则
      </el-button>
      <el-button type="success" @click="autoDispatchAll">
        <el-icon><Document /></el-icon>
        批量派单
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in dispatchStatsCards" :key="stat.label">
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

    <!-- 派单统计 -->
    <div class="demo-stats">
      <div class="stat-card">
        <div class="stat-value">{{ dispatchStats.totalDispatched }}</div>
        <div class="stat-label">今日派单数</div>
      </div>
      <div class="stat-card" style="border-left-color: #67c23a;">
        <div class="stat-value" style="color: #67c23a;">{{ dispatchStats.autoSuccess }}%</div>
        <div class="stat-label">自动派单成功率</div>
      </div>
      <div class="stat-card" style="border-left-color: #e6a23c;">
        <div class="stat-value" style="color: #e6a23c;">{{ dispatchStats.avgMatchScore }}</div>
        <div class="stat-label">平均匹配度</div>
      </div>
      <div class="stat-card" style="border-left-color: #409eff;">
        <div class="stat-value" style="color: #409eff;">{{ dispatchStats.avgDispatchTime }}s</div>
        <div class="stat-label">平均派单时间</div>
      </div>
      <div class="stat-card" style="border-left-color: #f56c6c;">
        <div class="stat-value" style="color: #f56c6c;">{{ engineerStats.onlineCount }}</div>
        <div class="stat-label">在线工程师</div>
      </div>
      <div class="stat-card" style="border-left-color: #909399;">
        <div class="stat-value" style="color: #909399;">{{ engineerStats.avgWorkload }}%</div>
        <div class="stat-label">平均负载</div>
      </div>
    </div>

    <el-row :gutter="20">
      <!-- 待派单工单队列 -->
      <el-col :span="12">
        <el-card class="demo-card">
          <template #header>
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span>待派单队列</span>
              <el-badge :value="pendingTickets.length" class="item">
                <el-button size="small" @click="refreshQueue">刷新</el-button>
              </el-badge>
            </div>
          </template>

          <div v-if="pendingTickets.length === 0" style="text-align: center; padding: 40px; color: #909399;">
            <el-icon size="48"><DocumentChecked /></el-icon>
            <p style="margin-top: 16px;">暂无待派单工单</p>
          </div>

          <div v-else>
            <div
              v-for="ticket in pendingTickets"
              :key="ticket.id"
              class="ticket-item"
              @click="selectTicket(ticket)"
              :class="{ active: selectedTicket?.id === ticket.id }"
            >
              <div class="ticket-header">
                <span class="ticket-id">{{ ticket.id }}</span>
                <el-tag :type="getPriorityType(ticket.priority)" size="small">
                  {{ ticket.priority }}
                </el-tag>
              </div>
              <div class="ticket-title">{{ ticket.title }}</div>
              <div class="ticket-meta">
                <span>{{ ticket.category }}</span>
                <span>{{ ticket.createdAt }}</span>
              </div>
              <div class="ticket-actions">
                <el-button size="small" type="primary" @click.stop="autoDispatch(ticket)">
                  智能派单
                </el-button>
                <el-button size="small" @click.stop="manualDispatch(ticket)">
                  手动派单
                </el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 工程师负载监控 -->
      <el-col :span="12">
        <el-card class="demo-card">
          <template #header>
            <span>工程师负载监控</span>
          </template>

          <div class="engineer-list">
            <div
              v-for="engineer in engineers"
              :key="engineer.id"
              class="engineer-item"
            >
              <div class="engineer-info">
                <el-avatar :size="40">{{ engineer.name.charAt(0) }}</el-avatar>
                <div class="engineer-details">
                  <div class="engineer-name">{{ engineer.name }}</div>
                  <div class="engineer-skills">{{ engineer.skills.join(', ') }}</div>
                </div>
              </div>

              <div class="engineer-workload">
                <div class="workload-info">
                  <span>负载: {{ engineer.currentLoad }}/{{ engineer.maxLoad }}</span>
                  <span class="match-score" v-if="selectedTicket">
                    匹配度: {{ calculateMatchScore(engineer, selectedTicket) }}%
                  </span>
                </div>
                <el-progress
                  :percentage="(engineer.currentLoad / engineer.maxLoad) * 100"
                  :color="getLoadColor(engineer.currentLoad / engineer.maxLoad)"
                  :stroke-width="8"
                />
              </div>

              <div class="engineer-actions">
                <el-button
                  size="small"
                  :disabled="engineer.currentLoad >= engineer.maxLoad"
                  @click="assignToEngineer(engineer)"
                >
                  分配
                </el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 派单算法可视化 -->
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="24">
        <el-card class="demo-card">
          <template #header>
            <span>派单算法分析</span>
          </template>

          <div v-if="selectedTicket && algorithmResult">
            <el-row :gutter="20">
              <el-col :span="12">
                <h4>工单信息</h4>
                <el-descriptions :column="1" size="small">
                  <el-descriptions-item label="工单号">{{ selectedTicket.id }}</el-descriptions-item>
                  <el-descriptions-item label="标题">{{ selectedTicket.title }}</el-descriptions-item>
                  <el-descriptions-item label="优先级">{{ selectedTicket.priority }}</el-descriptions-item>
                  <el-descriptions-item label="分类">{{ selectedTicket.category }}</el-descriptions-item>
                  <el-descriptions-item label="所需技能">{{ selectedTicket.requiredSkills?.join(', ') || '通用' }}</el-descriptions-item>
                </el-descriptions>
              </el-col>

              <el-col :span="12">
                <h4>算法权重配置</h4>
                <div class="weight-config">
                  <div class="weight-item">
                    <span>技能匹配 (40%)</span>
                    <el-progress :percentage="40" color="#409eff" :stroke-width="6" />
                  </div>
                  <div class="weight-item">
                    <span>负载均衡 (25%)</span>
                    <el-progress :percentage="25" color="#67c23a" :stroke-width="6" />
                  </div>
                  <div class="weight-item">
                    <span>客户优先级 (20%)</span>
                    <el-progress :percentage="20" color="#e6a23c" :stroke-width="6" />
                  </div>
                  <div class="weight-item">
                    <span>历史绩效 (15%)</span>
                    <el-progress :percentage="15" color="#f56c6c" :stroke-width="6" />
                  </div>
                </div>
              </el-col>
            </el-row>

            <div style="margin-top: 20px;">
              <h4>推荐工程师排序</h4>
              <el-table :data="algorithmResult.recommendations" style="width: 100%">
                <el-table-column prop="rank" label="排名" width="80" />
                <el-table-column prop="engineerName" label="工程师" width="120" />
                <el-table-column prop="totalScore" label="总分" width="100">
                  <template #default="{ row }">
                    <el-tag :type="getScoreType(row.totalScore)">{{ row.totalScore }}%</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="skillScore" label="技能匹配" width="100" />
                <el-table-column prop="loadScore" label="负载评分" width="100" />
                <el-table-column prop="priorityScore" label="优先级评分" width="120" />
                <el-table-column prop="performanceScore" label="绩效评分" width="100" />
                <el-table-column prop="reason" label="推荐理由" min-width="200" />
              </el-table>
            </div>
          </div>

          <div v-else style="text-align: center; padding: 40px; color: #909399;">
            <el-icon size="48"><DataAnalysis /></el-icon>
            <p style="margin-top: 16px;">请选择工单查看算法分析</p>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 派单规则配置对话框 -->
    <el-dialog v-model="showRuleDialog" title="派单规则配置" width="800px">
      <el-form :model="ruleConfig" label-width="120px">
        <el-form-item label="规则名称">
          <el-input v-model="ruleConfig.name" placeholder="输入规则名称" />
        </el-form-item>

        <el-form-item label="适用条件">
          <el-row :gutter="10">
            <el-col :span="8">
              <el-select v-model="ruleConfig.priority" placeholder="优先级">
                <el-option label="全部" value="" />
                <el-option label="紧急" value="紧急" />
                <el-option label="高" value="高" />
                <el-option label="中" value="中" />
                <el-option label="低" value="低" />
              </el-select>
            </el-col>
            <el-col :span="8">
              <el-select v-model="ruleConfig.category" placeholder="分类">
                <el-option label="全部" value="" />
                <el-option label="硬件故障" value="硬件故障" />
                <el-option label="软件问题" value="软件问题" />
                <el-option label="网络故障" value="网络故障" />
                <el-option label="安全事件" value="安全事件" />
              </el-select>
            </el-col>
            <el-col :span="8">
              <el-time-picker
                v-model="ruleConfig.timeRange"
                is-range
                range-separator="至"
                start-placeholder="开始时间"
                end-placeholder="结束时间"
                format="HH:mm"
                value-format="HH:mm"
              />
            </el-col>
          </el-row>
        </el-form-item>

        <el-form-item label="权重配置">
          <div class="weight-sliders">
            <div class="slider-item">
              <label>技能匹配权重: {{ ruleConfig.weights.skill }}%</label>
              <el-slider v-model="ruleConfig.weights.skill" :max="100" />
            </div>
            <div class="slider-item">
              <label>负载均衡权重: {{ ruleConfig.weights.load }}%</label>
              <el-slider v-model="ruleConfig.weights.load" :max="100" />
            </div>
            <div class="slider-item">
              <label>客户优先级权重: {{ ruleConfig.weights.priority }}%</label>
              <el-slider v-model="ruleConfig.weights.priority" :max="100" />
            </div>
            <div class="slider-item">
              <label>历史绩效权重: {{ ruleConfig.weights.performance }}%</label>
              <el-slider v-model="ruleConfig.weights.performance" :max="100" />
            </div>
          </div>
        </el-form-item>

        <el-form-item label="派单策略">
          <el-radio-group v-model="ruleConfig.strategy">
            <el-radio label="best_match">最佳匹配</el-radio>
            <el-radio label="load_balance">负载均衡</el-radio>
            <el-radio label="round_robin">轮询分配</el-radio>
            <el-radio label="skill_priority">技能优先</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showRuleDialog = false">取消</el-button>
        <el-button type="primary" @click="saveRule">保存规则</el-button>
        <el-button type="success" @click="testRule">测试规则</el-button>
      </template>
    </el-dialog>

    <!-- 手动派单对话框 -->
    <el-dialog v-model="showManualDialog" title="手动派单" width="600px">
      <div v-if="selectedTicket">
        <h4>工单信息</h4>
        <el-descriptions :column="2" size="small" style="margin-bottom: 20px;">
          <el-descriptions-item label="工单号">{{ selectedTicket.id }}</el-descriptions-item>
          <el-descriptions-item label="优先级">{{ selectedTicket.priority }}</el-descriptions-item>
          <el-descriptions-item label="标题" :span="2">{{ selectedTicket.title }}</el-descriptions-item>
        </el-descriptions>

        <h4>选择工程师</h4>
        <el-table
          :data="engineers"
          @row-click="selectEngineerForManual"
          highlight-current-row
          style="width: 100%"
        >
          <el-table-column prop="name" label="姓名" width="100" />
          <el-table-column prop="skills" label="技能" min-width="150">
            <template #default="{ row }">
              {{ row.skills.join(', ') }}
            </template>
          </el-table-column>
          <el-table-column label="当前负载" width="120">
            <template #default="{ row }">
              {{ row.currentLoad }}/{{ row.maxLoad }}
            </template>
          </el-table-column>
          <el-table-column label="匹配度" width="100">
            <template #default="{ row }">
              {{ calculateMatchScore(row, selectedTicket) }}%
            </template>
          </el-table-column>
        </el-table>

        <div style="margin-top: 20px;">
          <el-input
            v-model="manualDispatchReason"
            type="textarea"
            :rows="3"
            placeholder="请输入派单原因（可选）"
          />
        </div>
      </div>

      <template #footer>
        <el-button @click="showManualDialog = false">取消</el-button>
        <el-button
          type="primary"
          :disabled="!selectedEngineer"
          @click="confirmManualDispatch"
        >
          确认派单
        </el-button>
      </template>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { User, TrendCharts, Setting, Document, Refresh } from '@element-plus/icons-vue'
import { mockTickets } from '@/data/mockData'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const pendingTickets = ref([])
const selectedTicket = ref(null)
const selectedEngineer = ref(null)
const algorithmResult = ref(null)
const showRuleDialog = ref(false)
const showManualDialog = ref(false)
const manualDispatchReason = ref('')
const currentTenant = ref('1')

// 租户数据
const tenants = ref([
  { id: '1', name: '阿里巴巴集团', code: 'ALIBABA' },
  { id: '2', name: '腾讯科技', code: 'TENCENT' },
  { id: '3', name: '字节跳动', code: 'BYTEDANCE' }
])

// 派单统计
const dispatchStats = ref({
  totalDispatched: 156,
  autoSuccess: 94.2,
  avgMatchScore: 87.5,
  avgDispatchTime: 2.3
})

// 工程师统计
const engineerStats = ref({
  onlineCount: 12,
  avgWorkload: 68.5
})

// 统计卡片数据
const dispatchStatsCards = computed(() => [
  {
    label: '今日派单数',
    value: dispatchStats.value.totalDispatched,
    icon: 'Document',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 15.3
  },
  {
    label: '自动成功率',
    value: `${dispatchStats.value.autoSuccess}%`,
    icon: 'TrendCharts',
    color: 'var(--el-color-success, #10b981)',
    trend: 2.8
  },
  {
    label: '平均匹配分',
    value: dispatchStats.value.avgMatchScore,
    icon: 'User',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 1.2
  },
  {
    label: '平均派单时间',
    value: `${dispatchStats.value.avgDispatchTime}分钟`,
    icon: 'Clock',
    color: 'var(--el-color-info, #3b82f6)',
    trend: -5.7
  }
])

// 工程师数据
const engineers = ref([
  {
    id: 1,
    name: '张工程师',
    skills: ['Linux', 'MySQL', 'Docker'],
    currentLoad: 3,
    maxLoad: 8,
    performance: 92.5,
    location: '北京'
  },
  {
    id: 2,
    name: '李工程师',
    skills: ['Windows', 'SQL Server', 'VMware'],
    currentLoad: 5,
    maxLoad: 8,
    performance: 88.3,
    location: '上海'
  },
  {
    id: 3,
    name: '王工程师',
    skills: ['网络设备', 'Cisco', 'Juniper'],
    currentLoad: 2,
    maxLoad: 6,
    performance: 95.1,
    location: '深圳'
  },
  {
    id: 4,
    name: '赵工程师',
    skills: ['安全', '防火墙', '入侵检测'],
    currentLoad: 7,
    maxLoad: 8,
    performance: 89.7,
    location: '广州'
  }
])

// 规则配置
const ruleConfig = ref({
  name: '',
  priority: '',
  category: '',
  timeRange: [],
  weights: {
    skill: 40,
    load: 25,
    priority: 20,
    performance: 15
  },
  strategy: 'best_match'
})

// 初始化待派单工单
onMounted(() => {
  pendingTickets.value = mockTickets
    .filter(ticket => ticket.status === '待分配')
    .slice(0, 8)
    .map(ticket => ({
      ...ticket,
      requiredSkills: getRequiredSkills(ticket.category)
    }))
})

// 根据分类获取所需技能
const getRequiredSkills = (category) => {
  const skillMap = {
    '硬件故障': ['Linux', 'Windows'],
    '软件问题': ['MySQL', 'Docker'],
    '网络故障': ['网络设备', 'Cisco'],
    '安全事件': ['安全', '防火墙']
  }
  return skillMap[category] || ['通用']
}

// 获取优先级标签类型
const getPriorityType = (priority) => {
  const types = { '低': '', '中': 'warning', '高': 'danger', '紧急': 'danger' }
  return types[priority] || ''
}

// 获取负载颜色
const getLoadColor = (ratio) => {
  if (ratio < 0.6) return '#67c23a'
  if (ratio < 0.8) return '#e6a23c'
  return '#f56c6c'
}

// 获取分数类型
const getScoreType = (score) => {
  if (score >= 90) return 'success'
  if (score >= 70) return 'warning'
  return 'danger'
}

// 计算匹配度
const calculateMatchScore = (engineer, ticket) => {
  if (!ticket) return 0

  let score = 0

  // 技能匹配 (40%)
  const requiredSkills = ticket.requiredSkills || []
  const matchedSkills = engineer.skills.filter(skill =>
    requiredSkills.some(required => skill.includes(required) || required.includes(skill))
  )
  const skillScore = requiredSkills.length > 0 ?
    (matchedSkills.length / requiredSkills.length) * 40 : 40

  // 负载评分 (25%)
  const loadRatio = engineer.currentLoad / engineer.maxLoad
  const loadScore = (1 - loadRatio) * 25

  // 优先级评分 (20%)
  const priorityScore = ticket.priority === '紧急' ? 20 :
                       ticket.priority === '高' ? 15 :
                       ticket.priority === '中' ? 10 : 5

  // 绩效评分 (15%)
  const performanceScore = (engineer.performance / 100) * 15

  score = skillScore + loadScore + priorityScore + performanceScore
  return Math.round(Math.min(100, Math.max(0, score)))
}

// 选择工单
const selectTicket = (ticket) => {
  selectedTicket.value = ticket

  // 生成算法分析结果
  const recommendations = engineers.value
    .map(engineer => {
      const totalScore = calculateMatchScore(engineer, ticket)
      return {
        rank: 0,
        engineerName: engineer.name,
        totalScore,
        skillScore: Math.round(Math.random() * 40 + 60),
        loadScore: Math.round((1 - engineer.currentLoad / engineer.maxLoad) * 100),
        priorityScore: Math.round(Math.random() * 20 + 70),
        performanceScore: Math.round(engineer.performance),
        reason: generateRecommendReason(engineer, ticket, totalScore)
      }
    })
    .sort((a, b) => b.totalScore - a.totalScore)
    .map((item, index) => ({ ...item, rank: index + 1 }))

  algorithmResult.value = {
    recommendations,
    bestMatch: recommendations[0]
  }
}

// 生成推荐理由
const generateRecommendReason = (engineer, ticket, score) => {
  const reasons = []

  if (score >= 90) {
    reasons.push('技能高度匹配')
  } else if (score >= 70) {
    reasons.push('技能基本匹配')
  }

  if (engineer.currentLoad / engineer.maxLoad < 0.6) {
    reasons.push('负载较轻')
  }

  if (engineer.performance > 90) {
    reasons.push('历史绩效优秀')
  }

  return reasons.join('，') || '综合评估推荐'
}

// 刷新队列
const refreshQueue = () => {
  ElMessage.success('队列已刷新')
}

// 自动派单
const autoDispatch = (ticket) => {
  selectTicket(ticket)

  setTimeout(() => {
    const bestEngineer = algorithmResult.value.bestMatch

    // 移除工单
    const index = pendingTickets.value.findIndex(t => t.id === ticket.id)
    if (index > -1) {
      pendingTickets.value.splice(index, 1)
    }

    // 更新工程师负载
    const engineer = engineers.value.find(e => e.name === bestEngineer.engineerName)
    if (engineer) {
      engineer.currentLoad++
    }

    ElMessage.success(`工单 ${ticket.id} 已自动派给 ${bestEngineer.engineerName}`)
    selectedTicket.value = null
    algorithmResult.value = null
  }, 1000)
}

// 手动派单
const manualDispatch = (ticket) => {
  selectedTicket.value = ticket
  selectedEngineer.value = null
  manualDispatchReason.value = ''
  showManualDialog.value = true
}

// 选择工程师进行手动派单
const selectEngineerForManual = (engineer) => {
  selectedEngineer.value = engineer
}

// 确认手动派单
const confirmManualDispatch = () => {
  if (!selectedEngineer.value) {
    ElMessage.error('请选择工程师')
    return
  }

  // 移除工单
  const index = pendingTickets.value.findIndex(t => t.id === selectedTicket.value.id)
  if (index > -1) {
    pendingTickets.value.splice(index, 1)
  }

  // 更新工程师负载
  selectedEngineer.value.currentLoad++

  ElMessage.success(`工单 ${selectedTicket.value.id} 已手动派给 ${selectedEngineer.value.name}`)
  showManualDialog.value = false
  selectedTicket.value = null
  algorithmResult.value = null
}

// 分配给工程师
const assignToEngineer = (engineer) => {
  if (!selectedTicket.value) {
    ElMessage.warning('请先选择工单')
    return
  }

  autoDispatch(selectedTicket.value)
}

// 批量自动派单
const autoDispatchAll = () => {
  if (pendingTickets.value.length === 0) {
    ElMessage.warning('暂无待派单工单')
    return
  }

  ElMessage.success(`开始批量派单 ${pendingTickets.value.length} 个工单...`)

  // 模拟批量派单过程
  const dispatchInterval = setInterval(() => {
    if (pendingTickets.value.length > 0) {
      const ticket = pendingTickets.value[0]
      autoDispatch(ticket)
    } else {
      clearInterval(dispatchInterval)
      ElMessage.success('批量派单完成')
    }
  }, 2000)
}

// 租户切换
const onTenantChange = (tenantId) => {
  ElMessage.success(`已切换到租户：${tenants.value.find(t => t.id === tenantId)?.name}`)
  // 重新加载当前租户的工程师和工单数据
  loadTenantData()
}

// 加载租户数据
const loadTenantData = () => {
  // 模拟根据租户加载不同的工程师和工单数据
  const currentTenantName = tenants.value.find(t => t.id === currentTenant.value)?.name
  ElMessage.info(`正在加载 ${currentTenantName} 的数据...`)
}

// 保存规则
const saveRule = () => {
  ElMessage.success('派单规则已保存')
  showRuleDialog.value = false
}

// 测试规则
const testRule = () => {
  ElMessage.info('规则测试功能开发中...')
}

// 统计卡片点击处理
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
  // 重新初始化数据
  pendingTickets.value = mockTickets
    .filter(ticket => ticket.status === '待分配')
    .slice(0, 8)
    .map(ticket => ({
      ...ticket,
      requiredSkills: getRequiredSkills(ticket.category)
    }))
}
</script>

<style scoped>
.ticket-item {
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  padding: 12px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.3s;
}

.ticket-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.2);
}

.ticket-item.active {
  border-color: #409eff;
  background-color: #f0f9ff;
}

.ticket-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.ticket-id {
  font-weight: 600;
  color: #409eff;
}

.ticket-title {
  font-size: 14px;
  margin-bottom: 8px;
  color: #303133;
}

.ticket-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #909399;
  margin-bottom: 12px;
}

.ticket-actions {
  display: flex;
  gap: 8px;
}

.engineer-list {
  max-height: 400px;
  overflow-y: auto;
}

.engineer-item {
  display: flex;
  align-items: center;
  padding: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  margin-bottom: 12px;
  gap: 12px;
}

.engineer-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.engineer-details {
  flex: 1;
}

.engineer-name {
  font-weight: 600;
  margin-bottom: 4px;
}

.engineer-skills {
  font-size: 12px;
  color: #909399;
}

.engineer-workload {
  flex: 2;
  margin-right: 12px;
}

.workload-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  margin-bottom: 4px;
}

.match-score {
  color: #409eff;
  font-weight: 600;
}

.weight-config {
  space-y: 12px;
}

.weight-item {
  margin-bottom: 12px;
}

.weight-item span {
  display: block;
  margin-bottom: 4px;
  font-size: 14px;
}

.weight-sliders {
  space-y: 16px;
}

.slider-item {
  margin-bottom: 16px;
}

.slider-item label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  color: #606266;
}
</style>