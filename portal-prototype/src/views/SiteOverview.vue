<template>
  <PageLayout
    title="站点总览"
    description="基于NetBox的IT机房和办公地点管理，实现地理位置精确的运维服务分配"
    icon="OfficeBuilding"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="navigateToSiteManagement">
        <el-icon><Setting /></el-icon>
        站点管理
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in siteStatsCards" :key="stat.label">
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

    <!-- 地图视图标签页 -->
    <div v-if="activeTab === 'map'" class="map-view-content">
      <SiteMapView />
    </div>

    <!-- 列表视图标签页 -->
    <div v-if="activeTab === 'list'" class="list-view-content">
      <SiteManagement />
    </div>

    <!-- 统计分析标签页 -->
    <div v-if="activeTab === 'analytics'" class="analytics-content">
      <div class="analytics-dashboard">
        <!-- 站点分布统计 -->
        <div class="distribution-stats">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-card shadow="never" class="chart-card">
                <template #header>
                  <span>站点类型分布</span>
                </template>
                <div ref="typeChart" class="chart-container"></div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card shadow="never" class="chart-card">
                <template #header>
                  <span>站点状态分布</span>
                </template>
                <div ref="statusChart" class="chart-container"></div>
              </el-card>
            </el-col>
          </el-row>
        </div>

        <!-- 区域分布统计 -->
        <div class="region-stats">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-card shadow="never" class="chart-card">
                <template #header>
                  <span>区域分布统计</span>
                </template>
                <div ref="regionChart" class="chart-container"></div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card shadow="never" class="chart-card">
                <template #header>
                  <span>租户站点分布</span>
                </template>
                <div ref="tenantChart" class="chart-container"></div>
              </el-card>
            </el-col>
          </el-row>
        </div>

        <!-- 趋势分析 -->
        <div class="trend-analysis">
          <el-card shadow="never" class="chart-card">
            <template #header>
              <span>站点增长趋势</span>
            </template>
            <div ref="trendChart" class="trend-chart-container"></div>
          </el-card>
        </div>
      </div>
    </div>

    <!-- 设置标签页 -->
    <div v-if="activeTab === 'settings'" class="settings-content">
      <div class="settings-panel">
        <el-card shadow="never">
          <template #header>
            <span>站点管理设置</span>
          </template>

          <el-form :model="settings" label-width="120px">
            <el-form-item label="默认视图">
              <el-radio-group v-model="settings.defaultView">
                <el-radio label="map">地图视图</el-radio>
                <el-radio label="list">列表视图</el-radio>
              </el-radio-group>
            </el-form-item>

            <el-form-item label="自动刷新">
              <el-switch v-model="settings.autoRefresh" />
              <span class="setting-desc">启用后每5分钟自动刷新数据</span>
            </el-form-item>

            <el-form-item label="地图缩放级别">
              <el-slider
                v-model="settings.mapZoom"
                :min="1"
                :max="10"
                :step="0.5"
                show-input
              />
            </el-form-item>

            <el-form-item label="显示设置">
              <el-checkbox-group v-model="settings.displayOptions">
                <el-checkbox label="showCoordinates">显示坐标信息</el-checkbox>
                <el-checkbox label="showCapacity">显示容量信息</el-checkbox>
                <el-checkbox label="showSyncStatus">显示同步状态</el-checkbox>
                <el-checkbox label="showAssignedEngineers">显示分配工程师</el-checkbox>
              </el-checkbox-group>
            </el-form-item>

            <el-form-item label="数据同步">
              <el-button @click="syncFromNetbox" :loading="syncing">
                <el-icon><Refresh /></el-icon>
                从Netbox同步
              </el-button>
              <el-button @click="exportSiteData">
                <el-icon><Download /></el-icon>
                导出站点数据
              </el-button>
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveSettings">保存设置</el-button>
              <el-button @click="resetSettings">重置设置</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </div>
    </div>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  OfficeBuilding, Setting, Refresh, Download
} from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'
import SiteMapView from '@/components/SiteMapView.vue'
import SiteManagement from '@/components/SiteManagement.vue'
import {
  mockSites,
  mockTenants,
  siteManagementUtils
} from '@/data/mockData.js'

// 路由
const router = useRouter()

// 响应式数据
const activeTab = ref('map')
const syncing = ref(false)

// 图表引用
const typeChart = ref(null)
const statusChart = ref(null)
const regionChart = ref(null)
const tenantChart = ref(null)
const trendChart = ref(null)

// 导航标签页
const navItems = ref([
  { name: 'map', label: '地图视图' },
  { name: 'list', label: '列表管理' },
  { name: 'analytics', label: '统计分析' },
  { name: 'settings', label: '设置' }
])

// 设置数据
const settings = reactive({
  defaultView: 'map',
  autoRefresh: false,
  mapZoom: 1.2,
  displayOptions: ['showCoordinates', 'showSyncStatus']
})

// 站点数据
const sites = ref([...mockSites])
const tenants = ref([...mockTenants])

// 站点统计数据
const siteStats = computed(() => {
  const totalSites = sites.value.length
  const activeSites = sites.value.filter(site => site.status === 'active').length
  const regions = new Set(sites.value.map(site => site.region)).size
  const tenantsWithSites = new Set(sites.value.map(site => site.tenantId)).size

  return [
    { title: '站点总数', value: totalSites, icon: 'OfficeBuilding' },
    { title: '活跃站点', value: activeSites, icon: 'Check' },
    { title: '覆盖区域', value: regions, icon: 'Location' },
    { title: '租户覆盖', value: tenantsWithSites, icon: 'User' }
  ]
})

// 统计卡片数据
const siteStatsCards = computed(() => {
  const totalSites = sites.value.length
  const activeSites = sites.value.filter(site => site.status === 'active').length
  const regions = new Set(sites.value.map(site => site.region)).size
  const tenantsWithSites = new Set(sites.value.map(site => site.tenantId)).size

  return [
    {
      label: '站点总数',
      value: totalSites,
      icon: 'OfficeBuilding',
      color: 'var(--el-color-primary, #6366f1)',
      trend: 5.2
    },
    {
      label: '活跃站点',
      value: activeSites,
      icon: 'Check',
      color: 'var(--el-color-success, #10b981)',
      trend: 2.1
    },
    {
      label: '覆盖区域',
      value: regions,
      icon: 'Location',
      color: 'var(--el-color-warning, #f59e0b)',
      trend: 0
    },
    {
      label: '租户覆盖',
      value: tenantsWithSites,
      icon: 'User',
      color: 'var(--el-color-info, #3b82f6)',
      trend: -1.5
    }
  ]
})

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const handleTabChange = (tabName) => {
  activeTab.value = tabName

  if (tabName === 'analytics') {
    nextTick(() => {
      initCharts()
    })
  }
}

const navigateToSiteManagement = () => {
  router.push('/system/tenants')
}

const refreshData = () => {
  ElMessage.success('数据已刷新')
}

const syncFromNetbox = async () => {
  syncing.value = true
  try {
    // 模拟同步过程
    await new Promise(resolve => setTimeout(resolve, 2000))
    ElMessage.success('Netbox数据同步成功')
  } catch (error) {
    ElMessage.error('同步失败：' + error.message)
  } finally {
    syncing.value = false
  }
}

const exportSiteData = () => {
  // 模拟导出功能
  const csvContent = [
    ['站点名称', '站点代码', '所属租户', '类型', '状态', '区域', '地址'].join(','),
    ...sites.value.map(site => [
      site.name,
      site.code,
      site.tenantName,
      site.type,
      site.status,
      site.region,
      site.address
    ].join(','))
  ].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `sites_overview_${new Date().toISOString().slice(0, 10)}.csv`
  link.click()

  ElMessage.success('站点数据导出成功')
}

const saveSettings = () => {
  // 保存设置到本地存储
  localStorage.setItem('siteOverviewSettings', JSON.stringify(settings))
  ElMessage.success('设置已保存')
}

const resetSettings = () => {
  Object.assign(settings, {
    defaultView: 'map',
    autoRefresh: false,
    mapZoom: 1.2,
    displayOptions: ['showCoordinates', 'showSyncStatus']
  })
  ElMessage.success('设置已重置')
}

// 图表初始化
const initCharts = () => {
  initTypeChart()
  initStatusChart()
  initRegionChart()
  initTenantChart()
  initTrendChart()
}

const initTypeChart = () => {
  if (!typeChart.value) return

  const chart = echarts.init(typeChart.value)
  const typeData = {}

  sites.value.forEach(site => {
    typeData[site.type] = (typeData[site.type] || 0) + 1
  })

  // 检测当前主题模式
  const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark'

  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'item',
      backgroundColor: isDarkMode ? 'var(--bg-overlay)' : '#ffffff',
      borderColor: isDarkMode ? 'var(--border-color)' : '#e4e7ed',
      textStyle: {
        color: isDarkMode ? 'var(--text-primary)' : '#303133'
      }
    },
    legend: {
      textStyle: {
        color: isDarkMode ? 'var(--text-primary)' : '#303133'
      }
    },
    series: [{
      type: 'pie',
      radius: '60%',
      data: Object.entries(typeData).map(([name, value]) => ({ name, value })),
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: isDarkMode ? 'rgba(0, 0, 0, 0.8)' : 'rgba(0, 0, 0, 0.5)'
        }
      }
    }]
  }

  chart.setOption(option)
}

const initStatusChart = () => {
  if (!statusChart.value) return

  const chart = echarts.init(statusChart.value)
  const statusData = {}

  sites.value.forEach(site => {
    statusData[site.status] = (statusData[site.status] || 0) + 1
  })

  // 检测当前主题模式
  const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark'

  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'item',
      backgroundColor: isDarkMode ? 'var(--bg-overlay)' : '#ffffff',
      borderColor: isDarkMode ? 'var(--border-color)' : '#e4e7ed',
      textStyle: {
        color: isDarkMode ? 'var(--text-primary)' : '#303133'
      }
    },
    legend: {
      textStyle: {
        color: isDarkMode ? 'var(--text-primary)' : '#303133'
      }
    },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      data: Object.entries(statusData).map(([name, value]) => ({ name, value })),
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: isDarkMode ? 'rgba(0, 0, 0, 0.8)' : 'rgba(0, 0, 0, 0.5)'
        }
      }
    }]
  }

  chart.setOption(option)
}

const initRegionChart = () => {
  if (!regionChart.value) return

  const chart = echarts.init(regionChart.value)
  const regionData = {}

  sites.value.forEach(site => {
    regionData[site.region] = (regionData[site.region] || 0) + 1
  })

  // 检测当前主题模式
  const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark'

  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      backgroundColor: isDarkMode ? 'var(--bg-overlay)' : '#ffffff',
      borderColor: isDarkMode ? 'var(--border-color)' : '#e4e7ed',
      textStyle: {
        color: isDarkMode ? 'var(--text-primary)' : '#303133'
      }
    },
    xAxis: {
      type: 'category',
      data: Object.keys(regionData),
      axisLabel: {
        color: isDarkMode ? 'var(--text-secondary)' : '#666'
      },
      axisLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-color)' : '#e4e7ed'
        }
      }
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        color: isDarkMode ? 'var(--text-secondary)' : '#666'
      },
      axisLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-color)' : '#e4e7ed'
        }
      },
      splitLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-light)' : '#f0f0f0'
        }
      }
    },
    series: [{
      type: 'bar',
      data: Object.values(regionData),
      itemStyle: {
        color: '#409eff'
      }
    }]
  }

  chart.setOption(option)
}

const initTenantChart = () => {
  if (!tenantChart.value) return

  const chart = echarts.init(tenantChart.value)
  const tenantData = {}

  sites.value.forEach(site => {
    tenantData[site.tenantName] = (tenantData[site.tenantName] || 0) + 1
  })

  // 检测当前主题模式
  const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark'

  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      backgroundColor: isDarkMode ? 'var(--bg-overlay)' : '#ffffff',
      borderColor: isDarkMode ? 'var(--border-color)' : '#e4e7ed',
      textStyle: {
        color: isDarkMode ? 'var(--text-primary)' : '#303133'
      }
    },
    xAxis: {
      type: 'value',
      axisLabel: {
        color: isDarkMode ? 'var(--text-secondary)' : '#666'
      },
      axisLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-color)' : '#e4e7ed'
        }
      },
      splitLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-light)' : '#f0f0f0'
        }
      }
    },
    yAxis: {
      type: 'category',
      data: Object.keys(tenantData),
      axisLabel: {
        color: isDarkMode ? 'var(--text-secondary)' : '#666'
      },
      axisLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-color)' : '#e4e7ed'
        }
      }
    },
    series: [{
      type: 'bar',
      data: Object.values(tenantData),
      itemStyle: {
        color: '#67c23a'
      }
    }]
  }

  chart.setOption(option)
}

const initTrendChart = () => {
  if (!trendChart.value) return

  const chart = echarts.init(trendChart.value)

  // 模拟趋势数据
  const months = ['1月', '2月', '3月', '4月', '5月', '6月']
  const trendData = [12, 15, 18, 22, 25, 28]

  // 检测当前主题模式
  const isDarkMode = document.documentElement.getAttribute('data-theme') === 'dark'

  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'axis',
      backgroundColor: isDarkMode ? 'var(--bg-overlay)' : '#ffffff',
      borderColor: isDarkMode ? 'var(--border-color)' : '#e4e7ed',
      textStyle: {
        color: isDarkMode ? 'var(--text-primary)' : '#303133'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: months,
      axisLabel: {
        color: isDarkMode ? 'var(--text-secondary)' : '#666'
      },
      axisLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-color)' : '#e4e7ed'
        }
      }
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        color: isDarkMode ? 'var(--text-secondary)' : '#666'
      },
      axisLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-color)' : '#e4e7ed'
        }
      },
      splitLine: {
        lineStyle: {
          color: isDarkMode ? 'var(--border-light)' : '#f0f0f0'
        }
      }
    },
    series: [{
      type: 'line',
      data: trendData,
      smooth: true,
      itemStyle: {
        color: '#e6a23c'
      },
      lineStyle: {
        color: '#e6a23c'
      },
      areaStyle: {
        color: 'rgba(230, 162, 60, 0.2)'
      }
    }]
  }

  chart.setOption(option)
}

// 组件挂载
onMounted(() => {
  // 加载保存的设置
  const savedSettings = localStorage.getItem('siteOverviewSettings')
  if (savedSettings) {
    Object.assign(settings, JSON.parse(savedSettings))
  }

  // 根据默认视图设置初始标签页
  activeTab.value = settings.defaultView
})
</script>

<style scoped>
.map-view-content,
.list-view-content,
.analytics-content,
.settings-content {
  padding: 20px 0;
}

.analytics-dashboard {
  padding: 0;
}

.distribution-stats,
.region-stats {
  margin-bottom: 20px;
}

.chart-card {
  border: 1px solid var(--border-color);
}

.chart-container {
  height: 300px;
  width: 100%;
}

.trend-chart-container {
  height: 400px;
  width: 100%;
}

.settings-panel {
  max-width: 800px;
}

.setting-desc {
  margin-left: 10px;
  color: var(--text-secondary);
  font-size: 12px;
}

/* 深色模式适配 */
[data-theme="dark"] .chart-card {
  background-color: var(--bg-card);
  border-color: var(--border-color);
}

[data-theme="dark"] .analytics-content,
[data-theme="dark"] .settings-content {
  background-color: var(--bg-primary);
  color: var(--text-primary);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .map-view-content,
  .list-view-content,
  .analytics-content,
  .settings-content {
    padding: 10px 0;
  }

  .distribution-stats .el-col,
  .region-stats .el-col {
    margin-bottom: 20px;
  }

  .chart-container {
    height: 250px;
  }

  .trend-chart-container {
    height: 300px;
  }
}
</style>
