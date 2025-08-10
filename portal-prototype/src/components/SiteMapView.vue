<template>
  <div class="site-map-view">
    <!-- 地图控制面板 -->
    <div class="map-controls">
      <el-card shadow="never" class="control-card">
        <el-row :gutter="20">
          <el-col :span="6">
            <el-select v-model="filters.tenantId" placeholder="筛选租户" @change="handleFilterChange" clearable>
              <el-option label="全部租户" value="" />
              <el-option
                v-for="tenant in tenants"
                :key="tenant.id"
                :label="tenant.name"
                :value="tenant.id"
              />
            </el-select>
          </el-col>
          <el-col :span="6">
            <el-select v-model="filters.status" placeholder="筛选状态" @change="handleFilterChange" clearable>
              <el-option label="全部状态" value="" />
              <el-option label="活跃" value="active" />
              <el-option label="非活跃" value="inactive" />
              <el-option label="维护中" value="maintenance" />
            </el-select>
          </el-col>
          <el-col :span="6">
            <el-select v-model="filters.type" placeholder="筛选类型" @change="handleFilterChange" clearable>
              <el-option label="全部类型" value="" />
              <el-option label="数据中心" value="数据中心" />
              <el-option label="办公室" value="办公室" />
              <el-option label="研发中心" value="研发中心" />
              <el-option label="科技园区" value="科技园区" />
            </el-select>
          </el-col>
          <el-col :span="6">
            <el-button-group>
              <el-button
                :type="viewMode === 'map' ? 'primary' : ''"
                @click="switchViewMode('map')"
              >
                <el-icon><Location /></el-icon>
                地图视图
              </el-button>
              <el-button
                :type="viewMode === 'list' ? 'primary' : ''"
                @click="switchViewMode('list')"
              >
                <el-icon><List /></el-icon>
                列表视图
              </el-button>
            </el-button-group>
          </el-col>
        </el-row>
      </el-card>
    </div>


    <!-- 地图视图 -->
    <div v-if="viewMode === 'map'" class="map-container">
      <el-card shadow="never">
        <template #header>
          <div class="map-header">
            <span>站点地理分布</span>
            <div class="map-legend">
              <div class="legend-item">
                <span class="legend-dot active"></span>
                <span>活跃</span>
              </div>
              <div class="legend-item">
                <span class="legend-dot inactive"></span>
                <span>非活跃</span>
              </div>
              <div class="legend-item">
                <span class="legend-dot maintenance"></span>
                <span>维护中</span>
              </div>
            </div>
          </div>
        </template>

        <div ref="mapChart" class="map-chart" :style="{ height: mapHeight + 'px' }"></div>
      </el-card>
    </div>

    <!-- 列表视图 -->
    <div v-if="viewMode === 'list'" class="list-container">
      <el-card shadow="never">
        <template #header>
          <span>站点列表</span>
        </template>

        <el-table :data="filteredSites" style="width: 100%">
          <el-table-column prop="name" label="站点名称" width="200">
            <template #default="{ row }">
              <div class="site-name">
                <el-icon class="site-icon"><OfficeBuilding /></el-icon>
                <span>{{ row.name }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="tenantName" label="所属租户" width="150" />
          <el-table-column prop="type" label="类型" width="120" class-name="hidden-sm">
            <template #default="{ row }">
              <el-tag :type="getSiteTypeColor(row.type)">{{ row.type }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getSiteStatusColor(row.status)">
                {{ getSiteStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="region" label="区域" width="100" class-name="hidden-sm" />
          <el-table-column prop="address" label="地址" min-width="200" show-overflow-tooltip class-name="hidden-xs" />
          <el-table-column label="坐标" width="150" class-name="hidden-xs">
            <template #default="{ row }">
              {{ row.longitude }}, {{ row.latitude }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120">
            <template #default="{ row }">
              <el-button size="small" @click="viewSiteDetail(row)">查看详情</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>

    <!-- 站点详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="站点详情" width="600px">
      <div v-if="selectedSite" class="site-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="站点名称">{{ selectedSite.name }}</el-descriptions-item>
          <el-descriptions-item label="站点代码">{{ selectedSite.code }}</el-descriptions-item>
          <el-descriptions-item label="所属租户">{{ selectedSite.tenantName }}</el-descriptions-item>
          <el-descriptions-item label="站点类型">{{ selectedSite.type }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getSiteStatusColor(selectedSite.status)">
              {{ getSiteStatusText(selectedSite.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="区域">{{ selectedSite.region }}</el-descriptions-item>
          <el-descriptions-item label="地址" :span="2">{{ selectedSite.address }}</el-descriptions-item>
          <el-descriptions-item label="经度">{{ selectedSite.longitude }}</el-descriptions-item>
          <el-descriptions-item label="纬度">{{ selectedSite.latitude }}</el-descriptions-item>
          <el-descriptions-item label="容量">{{ selectedSite.capacity }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ selectedSite.createdAt }}</el-descriptions-item>
          <el-descriptions-item label="描述" :span="2">{{ selectedSite.description }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick, watch } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Location, List, OfficeBuilding
} from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import {
  mockSites,
  mockTenants
} from '@/data/mockData.js'

// 响应式数据
const mapChart = ref(null)
const viewMode = ref('map')
const showDetailDialog = ref(false)
const selectedSite = ref(null)
const mapHeight = ref(500)

// 筛选条件
const filters = reactive({
  tenantId: '',
  status: '',
  type: ''
})

// 数据
const sites = ref([...mockSites])
const tenants = ref([...mockTenants])

// 计算属性
const filteredSites = computed(() => {
  let filtered = sites.value

  if (filters.tenantId) {
    filtered = filtered.filter(site => site.tenantId === filters.tenantId)
  }

  if (filters.status) {
    filtered = filtered.filter(site => site.status === filters.status)
  }

  if (filters.type) {
    filtered = filtered.filter(site => site.type === filters.type)
  }

  return filtered
})

const activeSites = computed(() => {
  return filteredSites.value.filter(site => site.status === 'active').length
})

const coveredRegions = computed(() => {
  const regions = new Set(filteredSites.value.map(site => site.region))
  return regions.size
})

const coveredTenants = computed(() => {
  const tenantIds = new Set(filteredSites.value.map(site => site.tenantId))
  return tenantIds.size
})

// 地图数据
const mapData = computed(() => {
  return filteredSites.value.map(site => ({
    name: site.name,
    value: [site.longitude, site.latitude, site],
    symbolSize: getSymbolSize(site.type),
    itemStyle: {
      color: getStatusColor(site.status)
    }
  }))
})

// 方法
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

const getStatusColor = (status) => {
  const colorMap = {
    'active': '#67c23a',
    'inactive': '#909399',
    'maintenance': '#e6a23c'
  }
  return colorMap[status] || '#909399'
}

const getSymbolSize = (type) => {
  const sizeMap = {
    '数据中心': 15,
    '办公室': 10,
    '研发中心': 12,
    '科技园区': 13
  }
  return sizeMap[type] || 10
}

const handleFilterChange = () => {
  if (viewMode.value === 'map') {
    nextTick(() => {
      updateMapData()
    })
  }
}

const switchViewMode = (mode) => {
  viewMode.value = mode
  if (mode === 'map') {
    nextTick(() => {
      initMap()
    })
  }
}

const viewSiteDetail = (site) => {
  selectedSite.value = site
  showDetailDialog.value = true
}

// 注册中国地图数据
const registerChinaMap = async () => {
  try {
    // 使用简化的中国地图GeoJSON数据
    const chinaGeoJSON = {
      type: 'FeatureCollection',
      features: [
        {
          type: 'Feature',
          properties: { name: 'China' },
          geometry: {
            type: 'Polygon',
            coordinates: [[
              [73.66, 53.56], [134.77, 53.56], [134.77, 18.16], [73.66, 18.16], [73.66, 53.56]
            ]]
          }
        }
      ]
    }

    // 注册地图
    echarts.registerMap('china', chinaGeoJSON)
    return Promise.resolve()
  } catch (error) {
    console.error('地图注册失败:', error)
    return Promise.reject(error)
  }
}

// 显示备用内容
const showFallbackContent = () => {
  // 切换到列表视图作为备用方案
  viewMode.value = 'list'
  ElMessage.info('地图加载失败，已切换到列表视图')
}

// 地图相关方法
const initMap = () => {
  if (!mapChart.value) return

  const chart = echarts.init(mapChart.value)

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
      },
      formatter: (params) => {
        if (params.data && params.data.value && params.data.value[2]) {
          const site = params.data.value[2]
          return `
            <div style="padding: 8px;">
              <div style="font-weight: bold; margin-bottom: 4px;">${site.name}</div>
              <div>租户: ${site.tenantName}</div>
              <div>类型: ${site.type}</div>
              <div>状态: ${getSiteStatusText(site.status)}</div>
              <div>地址: ${site.address}</div>
            </div>
          `
        }
        return params.name
      }
    },
    geo: {
      map: 'china',
      roam: true,
      zoom: 1.2,
      center: [104.114129, 37.550339],
      itemStyle: {
        areaColor: isDarkMode ? '#2a2f3f' : '#f3f3f3',
        borderColor: isDarkMode ? '#4a5568' : '#999',
        borderWidth: 0.5
      },
      emphasis: {
        itemStyle: {
          areaColor: isDarkMode ? '#323749' : '#e6f7ff'
        }
      },
      label: {
        show: false,
        color: isDarkMode ? 'var(--text-secondary)' : '#666'
      }
    },
    series: [
      {
        type: 'scatter',
        coordinateSystem: 'geo',
        data: mapData.value,
        symbolSize: (val) => val[2] ? getSymbolSize(val[2].type) : 10,
        itemStyle: {
          color: (params) => {
            return params.data.value[2] ? getStatusColor(params.data.value[2].status) : '#909399'
          }
        },
        emphasis: {
          scale: 1.5
        }
      }
    ]
  }

  chart.setOption(option)

  // 添加点击事件
  chart.on('click', (params) => {
    if (params.data && params.data.value && params.data.value[2]) {
      viewSiteDetail(params.data.value[2])
    }
  })

  // 响应窗口大小变化
  window.addEventListener('resize', () => {
    chart.resize()
  })
}

const updateMapData = () => {
  if (!mapChart.value) return

  const chart = echarts.getInstanceByDom(mapChart.value)
  if (chart) {
    chart.setOption({
      series: [{
        data: mapData.value
      }]
    })
  }
}

// 监听筛选条件变化
watch(() => filteredSites.value, () => {
  if (viewMode.value === 'map') {
    nextTick(() => {
      updateMapData()
    })
  }
}, { deep: true })

// 组件挂载
onMounted(() => {
  // 注册中国地图数据
  registerChinaMap().then(() => {
    if (viewMode.value === 'map') {
      nextTick(() => {
        initMap()
      })
    }
  }).catch((error) => {
    console.error('地图数据加载失败:', error)
    ElMessage.error('地图数据加载失败，将显示备用内容')
    showFallbackContent()
  })
})
</script>

<style scoped>
.site-map-view {
  padding: 20px;
}

.map-controls {
  margin-bottom: 20px;
}

.control-card {
  border: 1px solid var(--border-color);
}

.site-stats {
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
  border: 1px solid var(--border-color);
}

.map-container,
.list-container {
  margin-bottom: 20px;
}

.map-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.map-legend {
  display: flex;
  gap: 16px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
}

.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.legend-dot.active {
  background-color: #67c23a;
}

.legend-dot.inactive {
  background-color: #909399;
}

.legend-dot.maintenance {
  background-color: #e6a23c;
}

.map-chart {
  width: 100%;
  min-height: 500px;
}

.site-name {
  display: flex;
  align-items: center;
  gap: 8px;
}

.site-icon {
  color: var(--primary-color);
}

.site-detail {
  padding: 20px 0;
}

/* 深色模式适配 */
[data-theme="dark"] .control-card,
[data-theme="dark"] .stat-card,
[data-theme="dark"] .map-container .el-card,
[data-theme="dark"] .list-container .el-card {
  background-color: var(--bg-card);
  border-color: var(--border-color);
}

[data-theme="dark"] .site-map-view {
  background-color: var(--bg-primary);
  color: var(--text-primary);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .site-map-view {
    padding: 10px;
  }

  .map-controls .el-col {
    margin-bottom: 10px;
  }

  .site-stats .el-col {
    margin-bottom: 10px;
  }

  .map-chart {
    min-height: 400px !important;
  }

  /* 移动端表格优化 */
  .list-container .el-table {
    font-size: 12px;
  }

  .list-container .el-table .el-table__cell {
    padding: 8px 4px;
  }

  /* 隐藏部分列在小屏幕上 */
  .list-container .el-table .el-table-column--hidden-sm {
    display: none;
  }
}

@media (max-width: 480px) {
  .site-map-view {
    padding: 5px;
  }

  .map-controls .el-row {
    flex-direction: column;
  }

  .map-controls .el-col {
    width: 100% !important;
    margin-bottom: 8px;
  }

  .site-stats .el-row {
    flex-direction: column;
  }

  .site-stats .el-col {
    width: 100% !important;
    margin-bottom: 8px;
  }

  .map-legend {
    flex-direction: column;
    gap: 8px;
  }

  .map-chart {
    min-height: 300px !important;
  }

  /* 极小屏幕表格优化 */
  .list-container .el-table {
    font-size: 11px;
  }

  .list-container .el-table .el-table__cell {
    padding: 6px 2px;
  }

  /* 在极小屏幕上只显示关键列 */
  .list-container .el-table .el-table-column--hidden-xs {
    display: none;
  }
}
</style>
