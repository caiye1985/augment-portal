<template>
  <PageLayout
    title="工程师负责站点管理"
    description="管理运维工程师负责的站点范围，基于地理位置实现精准的工单分配和就近服务"
    icon="UserFilled"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="batchAssign">
        <el-icon><Connection /></el-icon>
        批量分配
      </el-button>
      <el-button @click="exportAssignment">
        <el-icon><Download /></el-icon>
        导出配置
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in assignmentStatsCards" :key="stat.label">
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
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span>工程师列表</span>
              <div class="header-filters">
                <el-input
                  v-model="searchText"
                  placeholder="搜索工程师"
                  size="small"
                  style="width: 200px;"
                  clearable
                >
                  <template #prefix>
                    <el-icon><Search /></el-icon>
                  </template>
                </el-input>
              </div>
            </div>
          </template>

          <div class="engineer-list">
            <div
              v-for="engineer in filteredEngineers"
              :key="engineer.id"
              class="engineer-item"
              :class="{ active: selectedEngineer?.id === engineer.id }"
              @click="selectEngineer(engineer)"
            >
              <div class="engineer-info">
                <el-avatar :size="40" :src="engineer.avatar">
                  {{ engineer.name.charAt(0) }}
                </el-avatar>
                <div class="engineer-details">
                  <h4>{{ engineer.name }}</h4>
                  <p>{{ engineer.level }} · {{ engineer.department }}</p>
                </div>
              </div>
              <div class="engineer-stats">
                <div class="stat-item">
                  <span class="stat-label">负责站点</span>
                  <span class="stat-value">{{ getEngineerSiteCount(engineer.id) }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">覆盖城市</span>
                  <span class="stat-value">{{ getEngineerCityCount(engineer.id) }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">工单数量</span>
                  <span class="stat-value">{{ engineer.ticketCount || 0 }}</span>
                </div>
                <!-- 分配状态指示器 -->
                <div class="assignment-indicator">
                  <el-tag
                    size="small"
                    :type="getAssignmentStatusType(engineer)"
                    style="margin-top: 4px;"
                  >
                    {{ getAssignmentStatusText(engineer) }}
                  </el-tag>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧站点分配 -->
      <el-col :span="12">
        <el-card shadow="never" v-if="selectedEngineer">
          <template #header>
            <div class="assignment-header">
              <div class="engineer-profile">
                <el-avatar :size="50" :src="selectedEngineer.avatar">
                  {{ selectedEngineer.name.charAt(0) }}
                </el-avatar>
                <div class="profile-info">
                  <h3>{{ selectedEngineer.name }}</h3>
                  <p>{{ selectedEngineer.level }} · {{ selectedEngineer.department }}</p>
                  <p class="location-info">工作地点：{{ selectedEngineer.location }}</p>
                </div>
              </div>
              <div class="header-actions">
                <el-button size="small" @click="showSiteHistory">
                  <el-icon><Clock /></el-icon>
                  分配历史
                </el-button>
                <el-button type="primary" @click="saveAssignment">
                  <el-icon><Check /></el-icon>
                  保存分配
                </el-button>
              </div>
            </div>
          </template>

          <div class="site-assignment">
            <!-- 站点筛选 -->
            <div class="site-filters">
              <el-row :gutter="10">
                <el-col :span="8">
                  <el-select v-model="siteFilters.city" placeholder="按城市筛选" clearable size="small">
                    <el-option
                      v-for="city in availableCities"
                      :key="city"
                      :label="city"
                      :value="city"
                    />
                  </el-select>
                </el-col>
                <el-col :span="8">
                  <el-select v-model="siteFilters.tenantId" placeholder="按租户筛选" clearable size="small">
                    <el-option
                      v-for="tenant in tenants"
                      :key="tenant.id"
                      :label="tenant.name"
                      :value="tenant.id"
                    />
                  </el-select>
                </el-col>
                <el-col :span="8">
                  <el-select v-model="siteFilters.type" placeholder="按类型筛选" clearable size="small">
                    <el-option
                      v-for="type in siteTypes"
                      :key="type"
                      :label="type"
                      :value="type"
                    />
                  </el-select>
                </el-col>
              </el-row>
            </div>

            <h4>站点分配</h4>
            <div class="assignment-controls">
              <el-checkbox
                v-model="selectAllSites"
                @change="handleSelectAllSites"
                :indeterminate="isSiteIndeterminate"
              >
                全选
              </el-checkbox>
              <span class="assignment-count">
                已选择 {{ selectedSites.length }} / {{ filteredSites.length }} 个站点
              </span>
              <el-button size="small" type="text" @click="showRecommendations">
                <el-icon><TrendCharts /></el-icon>
                智能推荐
              </el-button>
            </div>

            <div class="site-list">
              <el-checkbox-group v-model="selectedSites" @change="handleSiteChange">
                <div
                  v-for="site in filteredSites"
                  :key="site.id"
                  class="site-item"
                  :class="{ 'recommended': site.isRecommended }"
                >
                  <el-checkbox :label="site.id" class="site-checkbox">
                    <div class="site-info">
                      <div class="site-basic">
                        <h5>{{ site.name }}</h5>
                        <span class="site-code">{{ site.code }}</span>
                        <el-tag size="small" :type="getSiteTypeColor(site.type)">
                          {{ site.type }}
                        </el-tag>
                      </div>
                      <div class="site-details">
                        <p class="site-tenant">{{ site.tenantName }}</p>
                        <p class="site-location">{{ site.city }} · {{ site.address }}</p>
                      </div>
                      <div class="site-stats">
                        <el-tag size="small" type="info">
                          {{ getSiteTicketCount(site.id) }} 工单
                        </el-tag>
                        <span class="distance" v-if="site.distance">
                          {{ site.distance }}km
                        </span>
                      </div>
                    </div>
                  </el-checkbox>
                </div>
              </el-checkbox-group>
            </div>

            <!-- 工作负载预估 -->
            <div class="workload-estimation" v-if="selectedSites.length > 0">
              <h4>工作负载预估</h4>
              <div class="workload-info">
                <div class="workload-item">
                  <span class="workload-label">负责站点数量</span>
                  <span class="workload-value">{{ selectedSites.length }}</span>
                </div>
                <div class="workload-item">
                  <span class="workload-label">覆盖城市数量</span>
                  <span class="workload-value">{{ estimatedCityCount }}</span>
                </div>
                <div class="workload-item">
                  <span class="workload-label">预计工单数量</span>
                  <span class="workload-value">{{ estimatedTickets }}</span>
                </div>
                <div class="workload-item">
                  <span class="workload-label">平均距离</span>
                  <span class="workload-value">{{ averageDistance }}km</span>
                </div>
              </div>
              <el-progress
                :percentage="estimatedWorkload"
                :color="getWorkloadProgressColor(estimatedWorkload)"
                :stroke-width="8"
              />
            </div>

            <!-- 站点分配 -->
            <div class="site-assignment">
              <h4>站点分配</h4>
              <div class="site-assignment-controls">
                <div class="assignment-method">
                  <el-radio-group v-model="siteAssignmentMethod" @change="handleAssignmentMethodChange">
                    <el-radio label="tenant">按租户选择</el-radio>
                    <el-radio label="cascader">级联选择</el-radio>
                  </el-radio-group>
                </div>
                <div class="site-stats">
                  <span class="assignment-count">
                    已分配 {{ assignedSites.length }} 个站点
                  </span>
                </div>
              </div>

              <!-- 按租户选择站点 -->
              <div v-if="siteAssignmentMethod === 'tenant'" class="tenant-site-selection">
                <el-tabs v-model="activeTenantTab" type="card" @tab-change="handleTenantTabChange">
                  <el-tab-pane
                    v-for="tenantId in selectedTenants"
                    :key="tenantId"
                    :label="getTenantName(tenantId)"
                    :name="tenantId"
                  >
                    <div class="tenant-sites">
                      <div class="site-controls">
                        <el-checkbox
                          v-model="selectAllSitesForTenant[tenantId]"
                          @change="handleSelectAllSites(tenantId)"
                          :indeterminate="isSiteIndeterminate(tenantId)"
                        >
                          全选该租户站点
                        </el-checkbox>
                        <span class="site-count">
                          {{ getSitesByTenant(tenantId).length }} 个站点
                        </span>
                      </div>

                      <div class="site-list">
                        <el-checkbox-group
                          v-model="selectedSitesByTenant[tenantId]"
                          @change="handleSiteChange(tenantId)"
                        >
                          <div
                            v-for="site in getSitesByTenant(tenantId)"
                            :key="site.id"
                            class="site-item"
                          >
                            <el-checkbox :label="site.id" class="site-checkbox">
                              <div class="site-info">
                                <div class="site-basic">
                                  <h6>{{ site.name }}</h6>
                                  <span class="site-code">{{ site.code }}</span>
                                </div>
                                <div class="site-meta">
                                  <el-tag size="small" :type="getSiteTypeColor(site.type)">
                                    {{ site.type }}
                                  </el-tag>
                                  <el-tag size="small" :type="getSiteStatusColor(site.status)">
                                    {{ getSiteStatusText(site.status) }}
                                  </el-tag>
                                </div>
                              </div>
                            </el-checkbox>
                          </div>
                        </el-checkbox-group>
                      </div>
                    </div>
                  </el-tab-pane>
                </el-tabs>
              </div>

              <!-- 级联选择站点 -->
              <div v-if="siteAssignmentMethod === 'cascader'" class="cascader-site-selection">
                <div class="cascader-controls">
                  <el-cascader
                    v-model="cascaderSelectedSites"
                    :options="tenantSiteCascaderOptions"
                    :props="cascaderProps"
                    multiple
                    collapse-tags
                    collapse-tags-tooltip
                    placeholder="选择租户和站点"
                    style="width: 100%"
                    @change="handleCascaderChange"
                  />
                </div>
                <div class="cascader-summary" v-if="cascaderSelectedSites.length > 0">
                  <h5>已选择的站点</h5>
                  <div class="selected-sites-summary">
                    <div
                      v-for="(sites, tenantId) in groupedSelectedSites"
                      :key="tenantId"
                      class="tenant-sites-group"
                    >
                      <div class="tenant-group-header">
                        <span class="tenant-name">{{ getTenantName(tenantId) }}</span>
                        <span class="site-count">{{ sites.length }} 个站点</span>
                      </div>
                      <div class="site-tags">
                        <el-tag
                          v-for="site in sites"
                          :key="site.id"
                          closable
                          @close="removeSiteFromSelection(site.id)"
                          class="site-tag"
                        >
                          {{ site.name }}
                        </el-tag>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 已分配站点列表 -->
              <div class="assigned-sites-list" v-if="assignedSites.length > 0">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                  <h5 style="margin: 0;">当前已分配站点 ({{ assignedSites.length }})</h5>
                  <div class="site-stats-mini">
                    <el-tag size="small" type="success">
                      活跃: {{ assignedSites.filter(s => s.status === 'active').length }}
                    </el-tag>
                    <el-tag size="small" type="info" style="margin-left: 8px;">
                      租户: {{ new Set(assignedSites.map(s => s.tenantId)).size }}
                    </el-tag>
                  </div>
                </div>
                <el-table :data="assignedSites" style="width: 100%" size="small">
                  <el-table-column prop="name" label="站点名称" width="150">
                    <template #default="{ row }">
                      <div style="display: flex; align-items: center;">
                        <el-icon style="margin-right: 6px; color: #409eff;"><OfficeBuilding /></el-icon>
                        <span>{{ row.name }}</span>
                      </div>
                    </template>
                  </el-table-column>
                  <el-table-column prop="tenantName" label="所属租户" width="120" />
                  <el-table-column prop="type" label="类型" width="100">
                    <template #default="{ row }">
                      <el-tag size="small" :type="getSiteTypeColor(row.type)">
                        {{ row.type }}
                      </el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column prop="status" label="状态" width="100">
                    <template #default="{ row }">
                      <el-tag size="small" :type="getSiteStatusColor(row.status)">
                        {{ getSiteStatusText(row.status) }}
                      </el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column prop="assignedAt" label="分配时间" width="120" />
                  <el-table-column label="操作" width="80">
                    <template #default="{ row }">
                      <el-button size="small" type="danger" @click="removeSiteAssignment(row.id)" title="移除站点分配">
                        <el-icon><Close /></el-icon>
                      </el-button>
                    </template>
                  </el-table-column>
                </el-table>
              </div>

              <!-- 空状态提示 -->
              <div v-else class="empty-sites-state" style="text-align: center; padding: 40px 0; color: #909399;">
                <el-icon size="48" style="margin-bottom: 16px;"><OfficeBuilding /></el-icon>
                <p>暂无分配的站点</p>
                <p style="font-size: 12px;">请在上方选择要分配的站点</p>
              </div>

              <!-- 批量操作 -->
              <div class="site-batch-operations" style="margin-top: 16px; text-align: center;">
                <el-button-group>
                  <el-button size="small" type="primary" @click="batchAssignSites" :disabled="assignedSites.length === 0">
                    <el-icon><Check /></el-icon>
                    批量分配站点
                  </el-button>
                  <el-button size="small" type="warning" @click="clearAllSiteAssignments" :disabled="assignedSites.length === 0">
                    <el-icon><Delete /></el-icon>
                    清空站点分配
                  </el-button>
                  <el-button size="small" type="info" @click="showSiteAssignmentHistory">
                    <el-icon><Clock /></el-icon>
                    分配历史
                  </el-button>
                </el-button-group>
              </div>
            </div>
          </div>
        </el-card>

        <el-empty v-else description="请选择工程师进行租户分配" />
      </el-col>
    </el-row>

    <!-- 批量分配对话框 -->
    <el-dialog v-model="showBatchDialog" title="批量分配租户" width="600px">
      <el-form :model="batchForm" label-width="100px">
        <el-form-item label="选择工程师">
          <el-select
            v-model="batchForm.engineerIds"
            multiple
            placeholder="请选择工程师"
            style="width: 100%;"
          >
            <el-option
              v-for="engineer in engineers"
              :key="engineer.id"
              :label="engineer.name"
              :value="engineer.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="选择租户">
          <el-select
            v-model="batchForm.tenantIds"
            multiple
            placeholder="请选择租户"
            style="width: 100%;"
          >
            <el-option
              v-for="tenant in tenants"
              :key="tenant.id"
              :label="tenant.name"
              :value="tenant.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="分配策略">
          <el-radio-group v-model="batchForm.strategy">
            <el-radio label="replace">替换现有分配</el-radio>
            <el-radio label="append">追加到现有分配</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showBatchDialog = false">取消</el-button>
        <el-button type="primary" @click="executeBatchAssign">确定</el-button>
      </template>
    </el-dialog>

    <!-- 站点分配历史对话框 -->
    <el-dialog v-model="showSiteHistoryDialog" title="站点分配历史" width="800px">
      <div class="site-assignment-history">
        <div class="history-filters">
          <el-row :gutter="20">
            <el-col :span="8">
              <el-select v-model="historyFilter.engineerId" placeholder="选择工程师" clearable>
                <el-option
                  v-for="engineer in engineers"
                  :key="engineer.id"
                  :label="engineer.name"
                  :value="engineer.id"
                />
              </el-select>
            </el-col>
            <el-col :span="8">
              <el-select v-model="historyFilter.action" placeholder="操作类型" clearable>
                <el-option label="分配" value="assign" />
                <el-option label="移除" value="remove" />
                <el-option label="批量分配" value="batch_assign" />
              </el-select>
            </el-col>
            <el-col :span="8">
              <el-date-picker
                v-model="historyFilter.dateRange"
                type="daterange"
                placeholder="选择日期范围"
                style="width: 100%"
              />
            </el-col>
          </el-row>
        </div>

        <el-table :data="filteredSiteAssignmentHistory" style="width: 100%; margin-top: 20px;">
          <el-table-column prop="timestamp" label="时间" width="180" />
          <el-table-column prop="engineerName" label="工程师" width="120" />
          <el-table-column prop="action" label="操作" width="100">
            <template #default="{ row }">
              <el-tag :type="getActionColor(row.action)" size="small">
                {{ getActionText(row.action) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="siteName" label="站点" width="150" />
          <el-table-column prop="tenantName" label="租户" width="120" />
          <el-table-column prop="operator" label="操作人" width="100" />
          <el-table-column prop="reason" label="备注" min-width="150" show-overflow-tooltip />
        </el-table>
      </div>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  UserFilled, Connection, Download, User, CircleCheck, OfficeBuilding,
  TrendCharts, Search, Check, Refresh, Close, Clock, Delete
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'
import { useAuthStore } from '@/stores/auth'
import {
  mockSites,
  mockTenants,
  mockEngineers,
  mockEngineerSiteAssignments,
  mockSiteAssignmentHistory,
  siteManagementUtils
} from '@/data/mockData.js'

const authStore = useAuthStore()

// 基础数据
const sites = ref([...mockSites])
const tenants = ref([...mockTenants])
const engineers = ref([...mockEngineers])
const siteAssignments = ref([...mockEngineerSiteAssignments])

// 响应式数据
const searchText = ref('')
const selectedEngineer = ref(null)
const selectedSites = ref([])
const selectedTenants = ref([])
const selectAllSites = ref(false)
const selectAllTenants = ref(false)
const showBatchDialog = ref(false)
const showSiteHistoryDialog = ref(false)

// 站点筛选相关
const siteFilters = reactive({
  city: '',
  tenantId: '',
  type: '',
  status: 'active'
})

// 站点分配相关
const siteAssignmentMethod = ref('direct')
const showRecommendations = ref(false)

// 统计卡片数据
const assignmentStatsCards = computed(() => [
  {
    label: '总工程师数',
    value: engineers.value.length,
    icon: 'User',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '已分配工程师',
    value: assignedEngineers.value,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.3
  },
  {
    label: '平均负责站点',
    value: `${avgSitesPerEngineer.value}个`,
    icon: 'OfficeBuilding',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 5.7
  },
  {
    label: '站点覆盖率',
    value: `${siteCoverageRate.value}%`,
    icon: 'TrendCharts',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 15.2
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

// 站点分配相关数据
const siteAssignmentMethod = ref('tenant')
const activeTenantTab = ref('')
const selectedSitesByTenant = ref({})
const selectAllSitesForTenant = ref({})
const cascaderSelectedSites = ref([])
const assignedSites = ref([])

// 站点分配历史
const siteAssignmentHistory = ref([...mockSiteAssignmentHistory])
const historyFilter = reactive({
  engineerId: '',
  action: '',
  dateRange: []
})

// 工程师数据 - 使用mockData
const engineers = ref([...mockEngineers])

// 租户数据 - 使用mockData
const tenants = ref([...mockTenants])

// 站点数据 - 使用mockData
const sites = ref([...mockSites])

// 批量分配表单
const batchForm = reactive({
  engineerIds: [],
  tenantIds: [],
  strategy: 'replace'
})

// 计算属性
const filteredEngineers = computed(() => {
  if (!searchText.value) return engineers.value
  return engineers.value.filter(engineer =>
    engineer.name.includes(searchText.value) ||
    engineer.department.includes(searchText.value)
  )
})

const assignedEngineers = computed(() => {
  return engineers.value.filter(e => e.assignedTenants?.length > 0).length
})

const avgSitesPerEngineer = computed(() => {
  const total = engineers.value.reduce((sum, e) => sum + getEngineerSiteCount(e.id), 0)
  return (total / engineers.value.length).toFixed(1)
})

const siteCoverageRate = computed(() => {
  const assignedSiteIds = new Set()
  siteAssignments.value.forEach(assignment => {
    if (assignment.status === 'active') {
      assignedSiteIds.add(assignment.siteId)
    }
  })
  return ((assignedSiteIds.size / sites.value.length) * 100).toFixed(1)
})

// 站点筛选相关计算属性
const availableCities = computed(() => {
  const cities = new Set()
  sites.value.forEach(site => {
    if (site.city) cities.add(site.city)
  })
  return Array.from(cities).sort()
})

const siteTypes = computed(() => {
  const types = new Set()
  sites.value.forEach(site => {
    if (site.type) types.add(site.type)
  })
  return Array.from(types).sort()
})

const filteredSites = computed(() => {
  let filtered = sites.value

  // 城市筛选
  if (siteFilters.city) {
    filtered = filtered.filter(site => site.city === siteFilters.city)
  }

  // 租户筛选
  if (siteFilters.tenantId) {
    filtered = filtered.filter(site => site.tenantId === siteFilters.tenantId)
  }

  // 类型筛选
  if (siteFilters.type) {
    filtered = filtered.filter(site => site.type === siteFilters.type)
  }

  // 状态筛选
  if (siteFilters.status) {
    filtered = filtered.filter(site => site.status === siteFilters.status)
  }

  return filtered
})

const isIndeterminate = computed(() => {
  const selected = selectedTenants.value.length
  return selected > 0 && selected < tenants.value.length
})

// 站点分配相关计算属性
const tenantSiteCascaderOptions = computed(() => {
  return tenants.value.map(tenant => ({
    value: tenant.id,
    label: tenant.name,
    children: sites.value
      .filter(site => site.tenantId === tenant.id)
      .map(site => ({
        value: site.id,
        label: site.name
      }))
  }))
})

const cascaderProps = {
  multiple: true,
  checkStrictly: false,
  emitPath: true
}

const groupedSelectedSites = computed(() => {
  const grouped = {}
  cascaderSelectedSites.value.forEach(path => {
    const [tenantId, siteId] = path
    if (!grouped[tenantId]) {
      grouped[tenantId] = []
    }
    const site = sites.value.find(s => s.id === siteId)
    if (site) {
      grouped[tenantId].push(site)
    }
  })
  return grouped
})

const filteredSiteAssignmentHistory = computed(() => {
  let filtered = [...siteAssignmentHistory.value]

  if (historyFilter.engineerId) {
    filtered = filtered.filter(h => h.engineerId === historyFilter.engineerId)
  }

  if (historyFilter.action) {
    filtered = filtered.filter(h => h.action === historyFilter.action)
  }

  if (historyFilter.dateRange && historyFilter.dateRange.length === 2) {
    const [start, end] = historyFilter.dateRange
    filtered = filtered.filter(h => {
      const date = new Date(h.timestamp)
      return date >= start && date <= end
    })
  }

  return filtered.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
})

// 站点分配相关的计算属性
const estimatedCityCount = computed(() => {
  const cities = new Set()
  selectedSites.value.forEach(siteId => {
    const site = sites.value.find(s => s.id === siteId)
    if (site && site.city) cities.add(site.city)
  })
  return cities.size
})

const estimatedTickets = computed(() => {
  return selectedSites.value.reduce((sum, siteId) => {
    return sum + getSiteTicketCount(siteId)
  }, 0)
})

const averageDistance = computed(() => {
  if (!selectedEngineer.value || selectedSites.value.length === 0) return 0

  const engineerLocation = selectedEngineer.value.location
  let totalDistance = 0
  let validDistances = 0

  selectedSites.value.forEach(siteId => {
    const site = sites.value.find(s => s.id === siteId)
    if (site && site.city) {
      // 简化的距离计算，实际应该使用地理位置API
      const distance = calculateDistance(engineerLocation, site.city)
      if (distance > 0) {
        totalDistance += distance
        validDistances++
      }
    }
  })

  return validDistances > 0 ? (totalDistance / validDistances).toFixed(1) : 0
})

const estimatedWorkload = computed(() => {
  // 基于站点数量和工单数量计算负载百分比
  const maxSites = 20 // 假设最大管理站点数
  const maxTickets = 200 // 假设最大处理工单数

  const siteLoad = (selectedSites.value.length / maxSites) * 50
  const ticketLoad = (estimatedTickets.value / maxTickets) * 50

  return Math.min(siteLoad + ticketLoad, 100)
})

// 站点选择状态
const isSiteIndeterminate = computed(() => {
  const selectedCount = selectedSites.value.length
  const totalCount = filteredSites.value.length
  return selectedCount > 0 && selectedCount < totalCount
})

// 方法
const selectEngineer = (engineer) => {
  selectedEngineer.value = engineer
  // 获取工程师已分配的站点
  const engineerSites = siteManagementUtils.getSitesByEngineer(engineer.id)
  selectedSites.value = engineerSites.map(site => site.id)
  selectedTenants.value = [...(engineer.assignedTenants || [])]
  updateSelectAllState()
}

const handleSelectAllSites = (checked) => {
  if (checked) {
    selectedSites.value = filteredSites.value.map(s => s.id)
  } else {
    selectedSites.value = []
  }
}

const handleSelectAll = (checked) => {
  if (checked) {
    selectedTenants.value = tenants.value.map(t => t.id)
  } else {
    selectedTenants.value = []
  }
}

const handleSiteChange = () => {
  updateSelectAllSiteState()
}

const handleTenantChange = () => {
  updateSelectAllState()
}

const updateSelectAllSiteState = () => {
  selectAllSites.value = selectedSites.value.length === filteredSites.value.length
}

const updateSelectAllState = () => {
  selectAllTenants.value = selectedTenants.value.length === tenants.value.length
}

// 站点相关工具方法
const getEngineerSiteCount = (engineerId) => {
  return siteAssignments.value.filter(
    assignment => assignment.engineerId === engineerId && assignment.status === 'active'
  ).length
}

const getEngineerCityCount = (engineerId) => {
  const engineerSites = siteManagementUtils.getSitesByEngineer(engineerId)
  const cities = new Set()
  engineerSites.forEach(site => {
    if (site.city) cities.add(site.city)
  })
  return cities.size
}

const getSiteTicketCount = (siteId) => {
  // 模拟站点工单数量，实际应该从API获取
  const site = sites.value.find(s => s.id === siteId)
  return site?.ticketCount || Math.floor(Math.random() * 20) + 1
}

const getSiteTypeColor = (type) => {
  const colorMap = {
    '数据中心': 'primary',
    '办公室': 'success',
    '研发中心': 'warning',
    '科技园区': 'info'
  }
  return colorMap[type] || 'default'
}

const calculateDistance = (location1, location2) => {
  // 简化的距离计算，实际应该使用地理位置API
  const distanceMap = {
    '北京市-北京市': 0,
    '北京市-上海市': 1200,
    '北京市-广州市': 2100,
    '北京市-深圳市': 2200,
    '上海市-上海市': 0,
    '上海市-广州市': 1300,
    '上海市-深圳市': 1400,
    '广州市-广州市': 0,
    '广州市-深圳市': 120,
    '深圳市-深圳市': 0
  }

  const key1 = `${location1}-${location2}`
  const key2 = `${location2}-${location1}`

  return distanceMap[key1] || distanceMap[key2] || Math.floor(Math.random() * 500) + 100
}

const getTenantTicketCount = (tenantId) => {
  const tenant = tenants.value.find(t => t.id === tenantId)
  return tenant?.ticketCount || 0
}

const getWorkloadLevel = (workload) => {
  if (workload >= 90) return '超负荷'
  if (workload >= 70) return '高负载'
  if (workload >= 50) return '中等负载'
  return '轻负载'
}

const getWorkloadColor = (workload) => {
  if (workload >= 90) return 'danger'
  if (workload >= 70) return 'warning'
  if (workload >= 50) return 'primary'
  return 'success'
}

const getRecommendation = (workload) => {
  if (workload >= 90) return '不建议分配'
  if (workload >= 70) return '谨慎分配'
  return '可以分配'
}

const getRecommendationColor = (workload) => {
  if (workload >= 90) return 'danger'
  if (workload >= 70) return 'warning'
  return 'success'
}

const getWorkloadProgressColor = (workload) => {
  if (workload >= 90) return '#f56c6c'
  if (workload >= 70) return '#e6a23c'
  if (workload >= 50) return '#409eff'
  return '#67c23a'
}

// 站点推荐方法
const showRecommendations = () => {
  if (!selectedEngineer.value) return

  const engineerLocation = selectedEngineer.value.location
  const recommendations = []

  // 基于地理位置就近原则推荐站点
  sites.value.forEach(site => {
    if (site.status === 'active') {
      const distance = calculateDistance(engineerLocation, site.city)
      const isAssigned = selectedSites.value.includes(site.id)

      if (!isAssigned && distance <= 500) { // 500km以内的站点
        recommendations.push({
          ...site,
          distance,
          isRecommended: true,
          recommendReason: distance <= 100 ? '同城站点' : '就近站点'
        })
      }
    }
  })

  // 按距离排序
  recommendations.sort((a, b) => a.distance - b.distance)

  // 标记推荐站点
  sites.value.forEach(site => {
    const recommended = recommendations.find(r => r.id === site.id)
    site.isRecommended = !!recommended
    if (recommended) {
      site.distance = recommended.distance
      site.recommendReason = recommended.recommendReason
    }
  })

  ElMessage.success(`为 ${selectedEngineer.value.name} 推荐了 ${recommendations.length} 个就近站点`)
}

// 显示站点分配历史
const showSiteHistory = () => {
  if (!selectedEngineer.value) return

  const engineerHistory = mockSiteAssignmentHistory.filter(
    record => record.engineerId === selectedEngineer.value.id
  )

  console.log('站点分配历史:', engineerHistory)
  showSiteHistoryDialog.value = true
  ElMessage.info(`查看 ${selectedEngineer.value.name} 的站点分配历史`)
}

const saveAssignment = () => {
  if (!selectedEngineer.value) return

  // 移除工程师的旧站点分配
  const oldAssignments = siteAssignments.value.filter(
    assignment => assignment.engineerId === selectedEngineer.value.id
  )
  oldAssignments.forEach(assignment => {
    assignment.status = 'inactive'
  })

  // 添加新的站点分配
  selectedSites.value.forEach(siteId => {
    const site = sites.value.find(s => s.id === siteId)
    if (site) {
      siteAssignments.value.push({
        id: `assign-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        engineerId: selectedEngineer.value.id,
        engineerName: selectedEngineer.value.name,
        tenantId: site.tenantId,
        tenantName: site.tenantName,
        siteId: site.id,
        siteName: site.name,
        assignedAt: new Date().toISOString().split('T')[0],
        assignedBy: 'admin',
        status: 'active',
        priority: 'primary'
      })
    }
  })

  // 更新工程师的租户分配（保持兼容性）
  selectedEngineer.value.assignedTenants = [...selectedTenants.value]

  // 调用认证store的方法更新工程师站点
  authStore.setEngineerSites?.(selectedEngineer.value.id, selectedSites.value)

  ElMessage.success(`已保存 ${selectedEngineer.value.name} 的站点分配`)
}

const batchAssign = () => {
  showBatchDialog.value = true
}

const executeBatchAssign = () => {
  if (batchForm.engineerIds.length === 0 || batchForm.tenantIds.length === 0) {
    ElMessage.warning('请选择工程师和租户')
    return
  }

  batchForm.engineerIds.forEach(engineerId => {
    const engineer = engineers.value.find(e => e.id === engineerId)
    if (engineer) {
      if (batchForm.strategy === 'replace') {
        engineer.assignedTenants = [...batchForm.tenantIds]
      } else {
        const existing = new Set(engineer.assignedTenants || [])
        batchForm.tenantIds.forEach(id => existing.add(id))
        engineer.assignedTenants = Array.from(existing)
      }

      // 更新认证store
      authStore.setEngineerTenants(engineerId, engineer.assignedTenants)
    }
  })

  ElMessage.success('批量分配完成')
  showBatchDialog.value = false

  // 重置表单
  Object.assign(batchForm, {
    engineerIds: [],
    tenantIds: [],
    strategy: 'replace'
  })
}

const exportAssignment = () => {
  const data = engineers.value.map(engineer => ({
    name: engineer.name,
    department: engineer.department,
    assignedTenants: engineer.assignedTenants?.map(id => {
      const tenant = tenants.value.find(t => t.id === id)
      return tenant?.name
    }).join(', ') || '无'
  }))

  const csv = [
    ['工程师姓名', '部门', '负责租户'],
    ...data.map(row => [row.name, row.department, row.assignedTenants])
  ].map(row => row.join(',')).join('\n')

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = '工程师租户分配.csv'
  link.click()

  ElMessage.success('配置导出成功')
}

// 站点分配相关方法
const getTenantName = (tenantId) => {
  const tenant = tenants.value.find(t => t.id === tenantId)
  return tenant?.name || ''
}

const getSitesByTenant = (tenantId) => {
  return sites.value.filter(site => site.tenantId === tenantId)
}

const getSiteTypeColor = (type) => {
  const typeMap = {
    '数据中心': 'primary',
    '办公室': 'success',
    '研发中心': 'warning',
    '科技园区': 'info'
  }
  return typeMap[type] || 'info'
}

const getSiteStatusColor = (status) => {
  const statusMap = {
    'active': 'success',
    'inactive': 'info',
    'maintenance': 'warning'
  }
  return statusMap[status] || 'info'
}

const getSiteStatusText = (status) => {
  const statusMap = {
    'active': '活跃',
    'inactive': '非活跃',
    'maintenance': '维护中'
  }
  return statusMap[status] || status
}

const handleAssignmentMethodChange = () => {
  // 切换分配方式时清空选择
  selectedSitesByTenant.value = {}
  cascaderSelectedSites.value = []
}

const handleTenantTabChange = (tenantId) => {
  activeTenantTab.value = tenantId
  // 初始化该租户的站点选择状态
  if (!selectedSitesByTenant.value[tenantId]) {
    selectedSitesByTenant.value[tenantId] = []
  }
}

const handleSelectAllSites = (tenantId) => {
  const sites = getSitesByTenant(tenantId)
  if (selectAllSitesForTenant.value[tenantId]) {
    selectedSitesByTenant.value[tenantId] = sites.map(site => site.id)
  } else {
    selectedSitesByTenant.value[tenantId] = []
  }
}

const handleSiteChange = (tenantId) => {
  const sites = getSitesByTenant(tenantId)
  const selected = selectedSitesByTenant.value[tenantId] || []
  selectAllSitesForTenant.value[tenantId] = selected.length === sites.length
}

const isSiteIndeterminate = (tenantId) => {
  const sites = getSitesByTenant(tenantId)
  const selected = selectedSitesByTenant.value[tenantId] || []
  return selected.length > 0 && selected.length < sites.length
}

const handleCascaderChange = () => {
  // 级联选择器变化时更新已分配站点
  updateAssignedSites()
}

const removeSiteFromSelection = (siteId) => {
  cascaderSelectedSites.value = cascaderSelectedSites.value.filter(path => {
    const [, selectedSiteId] = path
    return selectedSiteId !== siteId
  })
  updateAssignedSites()
}

const updateAssignedSites = () => {
  const allSelectedSites = []

  if (siteAssignmentMethod.value === 'tenant') {
    // 从按租户选择的方式收集站点
    Object.keys(selectedSitesByTenant.value).forEach(tenantId => {
      const siteIds = selectedSitesByTenant.value[tenantId] || []
      siteIds.forEach(siteId => {
        const site = sites.value.find(s => s.id === siteId)
        if (site) {
          allSelectedSites.push({
            ...site,
            tenantName: getTenantName(tenantId),
            assignedAt: new Date().toISOString().slice(0, 10)
          })
        }
      })
    })
  } else {
    // 从级联选择器收集站点
    cascaderSelectedSites.value.forEach(path => {
      const [tenantId, siteId] = path
      const site = sites.value.find(s => s.id === siteId)
      if (site) {
        allSelectedSites.push({
          ...site,
          tenantName: getTenantName(tenantId),
          assignedAt: new Date().toISOString().slice(0, 10)
        })
      }
    })
  }

  assignedSites.value = allSelectedSites
}

const removeSiteAssignment = (siteId) => {
  if (siteAssignmentMethod.value === 'tenant') {
    // 从按租户选择中移除
    Object.keys(selectedSitesByTenant.value).forEach(tenantId => {
      const index = selectedSitesByTenant.value[tenantId].indexOf(siteId)
      if (index > -1) {
        selectedSitesByTenant.value[tenantId].splice(index, 1)
      }
    })
  } else {
    // 从级联选择器中移除
    cascaderSelectedSites.value = cascaderSelectedSites.value.filter(path => {
      const [, selectedSiteId] = path
      return selectedSiteId !== siteId
    })
  }
  updateAssignedSites()
  ElMessage.success('站点分配已移除')
}

const batchAssignSites = () => {
  if (assignedSites.value.length === 0) {
    ElMessage.warning('请先选择要分配的站点')
    return
  }

  // 模拟批量分配站点
  ElMessage.success(`已为 ${selectedEngineer.value?.name} 批量分配 ${assignedSites.value.length} 个站点`)

  // 添加分配历史记录
  assignedSites.value.forEach(site => {
    siteAssignmentHistory.value.unshift({
      id: 'history-' + Date.now() + '-' + site.id,
      timestamp: new Date().toISOString().slice(0, 19).replace('T', ' '),
      engineerId: selectedEngineer.value.id,
      engineerName: selectedEngineer.value.name,
      action: 'assign',
      siteId: site.id,
      siteName: site.name,
      tenantId: site.tenantId,
      tenantName: site.tenantName,
      operator: '当前用户',
      reason: '批量分配操作'
    })
  })
}

const clearAllSiteAssignments = () => {
  selectedSitesByTenant.value = {}
  cascaderSelectedSites.value = []
  assignedSites.value = []
  selectAllSitesForTenant.value = {}
  ElMessage.success('已清空所有站点分配')
}

const showSiteAssignmentHistory = () => {
  showSiteHistoryDialog.value = true
}

const getActionColor = (action) => {
  const actionMap = {
    'assign': 'success',
    'remove': 'danger',
    'batch_assign': 'primary'
  }
  return actionMap[action] || 'info'
}

const getActionText = (action) => {
  const actionMap = {
    'assign': '分配',
    'remove': '移除',
    'batch_assign': '批量分配'
  }
  return actionMap[action] || action
}

// 获取工程师分配的站点数量
const getEngineerSiteCount = (engineerId) => {
  return siteAssignmentHistory.value.filter(h =>
    h.engineerId === engineerId && h.action === 'assign'
  ).length
}

// 获取工程师分配状态类型
const getAssignmentStatusType = (engineer) => {
  const tenantCount = engineer.assignedTenants?.length || 0
  const siteCount = getEngineerSiteCount(engineer.id)

  if (tenantCount === 0) return 'info'
  if (siteCount === 0) return 'warning'
  if (tenantCount >= 3 && siteCount >= 5) return 'danger'
  if (tenantCount >= 2 || siteCount >= 3) return 'warning'
  return 'success'
}

// 获取工程师分配状态文本
const getAssignmentStatusText = (engineer) => {
  const tenantCount = engineer.assignedTenants?.length || 0
  const siteCount = getEngineerSiteCount(engineer.id)

  if (tenantCount === 0) return '未分配'
  if (siteCount === 0) return '仅租户'
  if (tenantCount >= 3 && siteCount >= 5) return '高负载'
  if (tenantCount >= 2 || siteCount >= 3) return '中负载'
  return '正常'
}

onMounted(() => {
  // 默认选择第一个工程师
  if (engineers.value.length > 0) {
    selectEngineer(engineers.value[0])
  }
})
</script>

<style scoped>
.engineer-tenant-management {
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

.stats-cards {
  margin-bottom: 20px;
}

.stat-card {
  position: relative;
  overflow: hidden;
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

.stat-icon.assigned {
  color: #67c23a;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.engineer-list {
  max-height: 600px;
  overflow-y: auto;
}

.engineer-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: all 0.3s;
}

.engineer-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.1);
}

.engineer-item.active {
  border-color: #409eff;
  background: #f0f9ff;
}

.engineer-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.engineer-details h4 {
  margin: 0 0 5px 0;
  font-size: 16px;
  color: #303133;
}

.engineer-details p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}

.engineer-stats {
  display: flex;
  flex-direction: column;
  gap: 5px;
  text-align: right;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  font-size: 12px;
}

.stat-label {
  color: #909399;
}

.stat-value {
  color: #303133;
  font-weight: 500;
}

.assignment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.engineer-profile {
  display: flex;
  align-items: center;
  gap: 15px;
}

.profile-info h3 {
  margin: 0 0 5px 0;
  font-size: 18px;
  color: #303133;
}

.profile-info p {
  margin: 0;
  font-size: 14px;
  color: #909399;
}

.tenant-assignment h4 {
  margin: 0 0 15px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.assignment-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 6px;
}

.assignment-count {
  font-size: 14px;
  color: #606266;
}

.tenant-list {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 10px;
}

.tenant-item {
  margin-bottom: 10px;
}

.tenant-checkbox {
  width: 100%;
}

.tenant-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  margin-left: 10px;
}

.tenant-basic h5 {
  margin: 0 0 3px 0;
  font-size: 14px;
  color: #303133;
}

.tenant-code {
  font-size: 12px;
  color: #909399;
}

/* 站点相关样式 */
.site-filters {
  margin-bottom: 15px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.site-assignment {
  margin-top: 20px;
}

.site-list {
  max-height: 400px;
  overflow-y: auto;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  padding: 10px;
}

.site-item {
  margin-bottom: 12px;
  padding: 8px;
  border-radius: 6px;
  transition: all 0.3s;
}

.site-item.recommended {
  background: #f0f9ff;
  border: 1px solid #409eff;
}

.site-checkbox {
  width: 100%;
}

.site-info {
  display: flex;
  flex-direction: column;
  width: 100%;
  margin-left: 10px;
}

.site-basic {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 5px;
}

.site-basic h5 {
  margin: 0;
  font-size: 14px;
  color: #303133;
  font-weight: 600;
}

.site-code {
  font-size: 12px;
  color: #909399;
  background: #f5f7fa;
  padding: 2px 6px;
  border-radius: 4px;
}

.site-details {
  margin-bottom: 5px;
}

.site-tenant {
  margin: 0 0 2px 0;
  font-size: 13px;
  color: #606266;
}

.site-location {
  margin: 0;
  font-size: 12px;
  color: #909399;
}

.site-stats {
  display: flex;
  align-items: center;
  gap: 8px;
}

.distance {
  font-size: 12px;
  color: #409eff;
  background: #ecf5ff;
  padding: 2px 6px;
  border-radius: 4px;
}

.location-info {
  font-size: 12px;
  color: #909399;
  margin: 2px 0 0 0;
}

.header-actions {
  display: flex;
  gap: 8px;
}

.workload-estimation {
  margin-top: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
}

.workload-estimation h4 {
  margin: 0 0 15px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.workload-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 15px;
}

.workload-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.workload-label {
  font-size: 14px;
  color: #606266;
}

.workload-value {
  font-weight: 500;
  color: #303133;
}

/* 站点分配样式 */
.site-assignment {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #e4e7ed;
}

.site-assignment h4 {
  margin: 0 0 16px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 500;
}

.site-assignment-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.assignment-method {
  flex: 1;
}

.site-stats {
  color: #909399;
  font-size: 14px;
}

.tenant-site-selection {
  margin-bottom: 20px;
}

.tenant-sites {
  padding: 16px 0;
}

.site-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #f0f0f0;
}

.site-count {
  color: #909399;
  font-size: 13px;
}

.site-list {
  max-height: 300px;
  overflow-y: auto;
}

.site-item {
  margin-bottom: 8px;
  padding: 8px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  transition: all 0.3s;
}

.site-item:hover {
  border-color: #409eff;
  background-color: #f0f9ff;
}

.site-checkbox {
  width: 100%;
}

.site-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-left: 8px;
}

.site-basic h6 {
  margin: 0 0 4px 0;
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.site-code {
  color: #909399;
  font-size: 12px;
}

.site-meta {
  display: flex;
  gap: 4px;
}

.cascader-site-selection {
  margin-bottom: 20px;
}

.cascader-controls {
  margin-bottom: 16px;
}

.cascader-summary {
  margin-top: 16px;
}

.cascader-summary h5 {
  margin: 0 0 12px 0;
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.tenant-sites-group {
  margin-bottom: 16px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 6px;
}

.tenant-group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.tenant-name {
  font-weight: 500;
  color: #303133;
}

.site-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.site-tag {
  margin: 0;
}

.assigned-sites-list {
  margin: 20px 0;
}

.assigned-sites-list h5 {
  margin: 0 0 12px 0;
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.site-batch-operations {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f0f0f0;
}

/* 站点分配历史样式 */
.site-assignment-history {
  padding: 20px 0;
}

.history-filters {
  margin-bottom: 20px;
}
</style>
