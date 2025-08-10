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
          </div>
        </el-card>

        <!-- 空状态 -->
        <el-card shadow="never" v-else>
          <el-empty description="请选择工程师查看站点分配信息">
            <template #image>
              <el-icon size="60" color="#c0c4cc"><UserFilled /></el-icon>
            </template>
          </el-empty>
        </el-card>
      </el-col>
    </el-row>
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

const exportAssignment = () => {
  const data = engineers.value.map(engineer => ({
    工程师姓名: engineer.name,
    部门: engineer.department,
    级别: engineer.level,
    负责站点数: getEngineerSiteCount(engineer.id),
    覆盖城市数: getEngineerCityCount(engineer.id),
    工作地点: engineer.location
  }))

  console.log('导出数据:', data)
  ElMessage.success('站点分配配置导出成功')
}

const batchAssign = () => {
  showBatchDialog.value = true
}

// 计算属性
const filteredEngineers = computed(() => {
  if (!searchText.value) return engineers.value
  return engineers.value.filter(engineer =>
    engineer.name.includes(searchText.value) ||
    engineer.department.includes(searchText.value)
  )
})

const assignedEngineers = computed(() => {
  return engineers.value.filter(e => getEngineerSiteCount(e.id) > 0).length
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

// 主要方法
const selectEngineer = (engineer) => {
  selectedEngineer.value = engineer
  // 获取工程师已分配的站点
  const engineerSites = siteManagementUtils.getSitesByEngineer(engineer.id)
  selectedSites.value = engineerSites.map(site => site.id)
  selectedTenants.value = [...(engineer.assignedTenants || [])]
  updateSelectAllSiteState()
}

const handleSelectAllSites = (checked) => {
  if (checked) {
    selectedSites.value = filteredSites.value.map(s => s.id)
  } else {
    selectedSites.value = []
  }
}

const handleSiteChange = () => {
  updateSelectAllSiteState()
}

const updateSelectAllSiteState = () => {
  selectAllSites.value = selectedSites.value.length === filteredSites.value.length
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

const getAssignmentStatusType = (engineer) => {
  const siteCount = getEngineerSiteCount(engineer.id)
  if (siteCount === 0) return 'info'
  if (siteCount <= 5) return 'success'
  if (siteCount <= 10) return 'warning'
  return 'danger'
}

const getAssignmentStatusText = (engineer) => {
  const siteCount = getEngineerSiteCount(engineer.id)
  if (siteCount === 0) return '未分配'
  if (siteCount <= 5) return '轻负载'
  if (siteCount <= 10) return '中负载'
  return '高负载'
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

  // 调用认证store的方法更新工程师站点
  authStore.setEngineerSites?.(selectedEngineer.value.id, selectedSites.value)

  ElMessage.success(`已保存 ${selectedEngineer.value.name} 的站点分配`)
}

// 组件挂载时初始化数据
onMounted(() => {
  console.log('工程师站点管理页面已加载')
})
</script>

<style scoped>
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
  align-items: center;
  gap: 8px;
}

.stat-label {
  font-size: 12px;
  color: #909399;
}

.stat-value {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.assignment-indicator {
  margin-top: 8px;
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

.location-info {
  font-size: 12px;
  color: #409eff;
  margin: 2px 0 0 0;
}

.header-actions {
  display: flex;
  gap: 8px;
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
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 15px;
}

.workload-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: white;
  border-radius: 6px;
  border: 1px solid #ebeef5;
}

.workload-label {
  font-size: 13px;
  color: #606266;
}

.workload-value {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}
</style>
