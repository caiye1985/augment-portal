<template>
  <div class="site-management">
    <!-- 站点管理说明 -->
    <div class="site-description" v-if="!props.tenantId">
      <el-alert
        title="站点管理说明"
        type="info"
        :closable="false"
        show-icon
      >
        <template #default>
          <p>站点是从NetBox同步的IT机房和办公地点信息，用于精确定位租户的运维地点。通过站点管理，可以：</p>
          <ul>
            <li>• 避免工程师跨城市分配任务的尴尬</li>
            <li>• 为全国各地的租户公司提供本地化运维服务</li>
            <li>• 实现基于地理位置的智能任务分配</li>
            <li>• 提供站点级别的资源管理和监控</li>
          </ul>
        </template>
      </el-alert>
    </div>

    <!-- 租户站点管理说明 -->
    <div class="tenant-site-description" v-if="props.tenantId && props.tenantName">
      <el-alert
        :title="`${props.tenantName} - 站点管理`"
        type="success"
        :closable="false"
        show-icon
      >
        <template #default>
          <p>管理 <strong>{{ props.tenantName }}</strong> 的所有站点信息，包括IT机房、办公地点等。这些站点将用于工程师任务分配和本地化运维服务。</p>
        </template>
      </el-alert>
    </div>

    <!-- 搜索和筛选区域 -->
    <div class="search-filters">
      <el-card shadow="never" class="filter-card">
        <el-row :gutter="20">
          <el-col :span="6">
            <el-input
              v-model="searchQuery"
              placeholder="搜索站点名称、地址或代码"
              @input="handleSearch"
              clearable
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </el-col>
          <el-col :span="4">
            <el-select v-model="filters.status" placeholder="状态筛选" @change="handleFilter" clearable>
              <el-option label="全部" value="" />
              <el-option label="活跃" value="active" />
              <el-option label="非活跃" value="inactive" />
              <el-option label="维护中" value="maintenance" />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-select v-model="filters.region" placeholder="区域筛选" @change="handleFilter" clearable>
              <el-option label="全部" value="" />
              <el-option label="华北" value="华北" />
              <el-option label="华东" value="华东" />
              <el-option label="华南" value="华南" />
              <el-option label="西南" value="西南" />
            </el-select>
          </el-col>
          <el-col :span="4">
            <el-select v-model="filters.type" placeholder="类型筛选" @change="handleFilter" clearable>
              <el-option label="全部" value="" />
              <el-option label="数据中心" value="数据中心" />
              <el-option label="办公室" value="办公室" />
              <el-option label="研发中心" value="研发中心" />
              <el-option label="科技园区" value="科技园区" />
            </el-select>
          </el-col>
          <el-col :span="6">
            <el-button type="primary" @click="handleCreateSite">
              <el-icon><Plus /></el-icon>
              新增站点
            </el-button>
            <el-button @click="syncFromNetbox" :loading="syncing">
              <el-icon><Refresh /></el-icon>
              从Netbox同步
            </el-button>
            <el-button @click="showSyncHistoryDialog = true">
              <el-icon><Document /></el-icon>
              同步历史
            </el-button>
          </el-col>
        </el-row>
      </el-card>
    </div>

    <!-- 站点统计 -->
    <div class="site-stats">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card shadow="never" class="stat-card">
            <el-statistic title="站点总数" :value="siteStats.total" />
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="never" class="stat-card">
            <el-statistic title="活跃站点" :value="siteStats.active" />
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="never" class="stat-card">
            <el-statistic title="同步成功" :value="siteStats.syncStatus.synced" />
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="never" class="stat-card">
            <el-statistic title="同步失败" :value="siteStats.syncStatus.failed" />
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 站点列表 -->
    <div class="site-list">
      <el-card shadow="never">
        <template #header>
          <div class="card-header">
            <span>站点列表</span>
            <div class="header-actions">
              <el-button size="small" @click="handleBatchDelete" :disabled="!selectedSites.length">
                批量删除
              </el-button>
              <el-button size="small" @click="exportSites">
                导出数据
              </el-button>
            </div>
          </div>
        </template>

        <el-table
          :data="filteredSites"
          style="width: 100%"
          v-loading="loading"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="name" label="站点名称" width="200">
            <template #default="{ row }">
              <div class="site-name">
                <el-icon class="site-icon"><OfficeBuilding /></el-icon>
                <span>{{ row.name }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="code" label="站点代码" width="120" class-name="hidden-sm" />
          <el-table-column prop="tenantName" label="所属租户" width="150" class-name="hidden-sm" />
          <el-table-column prop="type" label="站点类型" width="120" class-name="hidden-xs">
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
          <el-table-column prop="syncStatus" label="同步状态" width="120" class-name="hidden-xs">
            <template #default="{ row }">
              <el-tag :type="getSyncStatusColor(row.syncStatus)">
                {{ getSyncStatusText(row.syncStatus) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="创建时间" width="180" class-name="hidden-xs" />
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button size="small" @click="viewSite(row)">查看</el-button>
              <el-button size="small" type="primary" @click="editSite(row)">编辑</el-button>
              <el-button size="small" type="danger" @click="deleteSite(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="totalSites"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>
    </div>

    <!-- 创建/编辑站点对话框 -->
    <el-dialog
      v-model="showCreateDialog"
      :title="editingSite ? '编辑站点' : '创建站点'"
      width="800px"
      @close="resetForm"
    >
      <el-form :model="siteForm" :rules="siteRules" ref="siteFormRef" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="站点名称" prop="name">
              <el-input v-model="siteForm.name" placeholder="请输入站点名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="站点代码" prop="code">
              <el-input v-model="siteForm.code" placeholder="请输入站点代码" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所属租户" prop="tenantId">
              <el-select v-model="siteForm.tenantId" placeholder="请选择租户" style="width: 100%">
                <el-option
                  v-for="tenant in availableTenants"
                  :key="tenant.id"
                  :label="tenant.name"
                  :value="tenant.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="站点类型" prop="type">
              <el-select v-model="siteForm.type" placeholder="请选择站点类型" style="width: 100%">
                <el-option label="数据中心" value="数据中心" />
                <el-option label="办公室" value="办公室" />
                <el-option label="研发中心" value="研发中心" />
                <el-option label="科技园区" value="科技园区" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="siteForm.status" placeholder="请选择状态" style="width: 100%">
                <el-option label="活跃" value="active" />
                <el-option label="非活跃" value="inactive" />
                <el-option label="维护中" value="maintenance" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="区域" prop="region">
              <el-select v-model="siteForm.region" placeholder="请选择区域" style="width: 100%">
                <el-option label="华北" value="华北" />
                <el-option label="华东" value="华东" />
                <el-option label="华南" value="华南" />
                <el-option label="西南" value="西南" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="地址" prop="address">
          <el-input v-model="siteForm.address" placeholder="请输入详细地址，用于工程师导航定位" />
          <div class="form-help-text">详细地址将帮助工程师快速定位到具体的运维地点</div>
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="经度" prop="longitude">
              <el-input-number
                v-model="siteForm.longitude"
                :precision="6"
                :min="-180"
                :max="180"
                placeholder="请输入经度"
                style="width: 100%"
              />
              <div class="form-help-text">用于地图定位和距离计算</div>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="纬度" prop="latitude">
              <el-input-number
                v-model="siteForm.latitude"
                :precision="6"
                :min="-90"
                :max="90"
                placeholder="请输入纬度"
                style="width: 100%"
              />
              <div class="form-help-text">配合经度实现精确地理定位</div>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="容量描述" prop="capacity">
          <el-input v-model="siteForm.capacity" placeholder="请输入容量描述，如：500台服务器" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="siteForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入站点描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="saveSite" :loading="saving">
          {{ editingSite ? '更新' : '创建' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 站点详情对话框 -->
    <el-dialog v-model="showDetailDialog" title="站点详情" width="800px">
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
          <el-descriptions-item label="经纬度">
            {{ selectedSite.longitude }}, {{ selectedSite.latitude }}
          </el-descriptions-item>
          <el-descriptions-item label="容量">{{ selectedSite.capacity }}</el-descriptions-item>
          <el-descriptions-item label="同步状态">
            <el-tag :type="getSyncStatusColor(selectedSite.syncStatus)">
              {{ getSyncStatusText(selectedSite.syncStatus) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="最后同步时间">{{ selectedSite.lastSyncAt }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ selectedSite.createdAt }}</el-descriptions-item>
          <el-descriptions-item label="Netbox ID">{{ selectedSite.netboxId }}</el-descriptions-item>
          <el-descriptions-item label="描述" :span="2">{{ selectedSite.description }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>

    <!-- 同步进度对话框 -->
    <el-dialog v-model="showSyncDialog" title="Netbox数据同步" width="600px" :close-on-click-modal="false">
      <div class="sync-progress">
        <div v-if="syncProgress.status === 'running'" class="sync-running">
          <el-progress :percentage="syncProgress.percentage" :status="syncProgress.status" />
          <p class="sync-message">{{ syncProgress.message }}</p>
        </div>
        <div v-else-if="syncProgress.status === 'success'" class="sync-success">
          <el-result icon="success" title="同步完成" :sub-title="syncProgress.message">
            <template #extra>
              <el-button type="primary" @click="showSyncDialog = false">确定</el-button>
            </template>
          </el-result>
        </div>
        <div v-else-if="syncProgress.status === 'error'" class="sync-error">
          <el-result icon="error" title="同步失败" :sub-title="syncProgress.message">
            <template #extra>
              <el-button @click="showSyncDialog = false">关闭</el-button>
              <el-button type="primary" @click="retrySync">重试</el-button>
            </template>
          </el-result>
        </div>
      </div>
    </el-dialog>

    <!-- 同步历史对话框 -->
    <el-dialog v-model="showSyncHistoryDialog" title="Netbox同步历史" width="900px">
      <div class="sync-history">
        <!-- 同步统计 -->
        <div class="sync-stats">
          <el-row :gutter="20">
            <el-col :span="6">
              <el-card shadow="never" class="stat-card">
                <el-statistic title="总同步次数" :value="syncLogs.length" />
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card shadow="never" class="stat-card">
                <el-statistic title="成功次数" :value="successfulSyncs" />
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card shadow="never" class="stat-card">
                <el-statistic title="失败次数" :value="failedSyncs" />
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card shadow="never" class="stat-card">
                <el-statistic title="成功率" :value="successRate" suffix="%" />
              </el-card>
            </el-col>
          </el-row>
        </div>

        <!-- 同步日志列表 -->
        <div class="sync-logs">
          <el-card shadow="never">
            <template #header>
              <div class="card-header">
                <span>同步日志</span>
                <div class="header-actions">
                  <el-button size="small" @click="refreshSyncLogs">
                    <el-icon><Refresh /></el-icon>
                    刷新
                  </el-button>
                  <el-button size="small" @click="clearSyncLogs">
                    清空日志
                  </el-button>
                </div>
              </div>
            </template>

            <el-table :data="syncLogs" style="width: 100%">
              <el-table-column prop="startTime" label="开始时间" width="180" />
              <el-table-column prop="endTime" label="结束时间" width="180" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="getSyncLogStatusColor(row.status)">
                    {{ getSyncLogStatusText(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="totalSites" label="总站点数" width="100" />
              <el-table-column prop="syncedSites" label="同步成功" width="100" />
              <el-table-column prop="failedSites" label="同步失败" width="100" />
              <el-table-column prop="newSites" label="新增站点" width="100" />
              <el-table-column prop="updatedSites" label="更新站点" width="100" />
              <el-table-column prop="message" label="消息" min-width="200" show-overflow-tooltip />
              <el-table-column label="操作" width="120">
                <template #default="{ row }">
                  <el-button size="small" @click="viewSyncLogDetail(row)">详情</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </div>
    </el-dialog>

    <!-- 同步日志详情对话框 -->
    <el-dialog v-model="showSyncLogDetailDialog" title="同步日志详情" width="700px">
      <div v-if="selectedSyncLog" class="sync-log-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="同步ID">{{ selectedSyncLog.syncId }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getSyncLogStatusColor(selectedSyncLog.status)">
              {{ getSyncLogStatusText(selectedSyncLog.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="开始时间">{{ selectedSyncLog.startTime }}</el-descriptions-item>
          <el-descriptions-item label="结束时间">{{ selectedSyncLog.endTime }}</el-descriptions-item>
          <el-descriptions-item label="总站点数">{{ selectedSyncLog.totalSites }}</el-descriptions-item>
          <el-descriptions-item label="同步成功">{{ selectedSyncLog.syncedSites }}</el-descriptions-item>
          <el-descriptions-item label="同步失败">{{ selectedSyncLog.failedSites }}</el-descriptions-item>
          <el-descriptions-item label="新增站点">{{ selectedSyncLog.newSites }}</el-descriptions-item>
          <el-descriptions-item label="更新站点">{{ selectedSyncLog.updatedSites }}</el-descriptions-item>
          <el-descriptions-item label="删除站点">{{ selectedSyncLog.deletedSites }}</el-descriptions-item>
          <el-descriptions-item label="消息" :span="2">{{ selectedSyncLog.message }}</el-descriptions-item>
        </el-descriptions>

        <!-- 详细操作日志 -->
        <div v-if="selectedSyncLog.details && selectedSyncLog.details.length" class="sync-details">
          <h4>详细操作</h4>
          <el-table :data="selectedSyncLog.details" style="width: 100%">
            <el-table-column prop="siteId" label="站点ID" width="120" />
            <el-table-column prop="action" label="操作" width="100">
              <template #default="{ row }">
                <el-tag :type="getSyncActionColor(row.action)" size="small">
                  {{ getSyncActionText(row.action) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="message" label="消息" min-width="200" />
          </el-table>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Search, Plus, Refresh, OfficeBuilding, Document
} from '@element-plus/icons-vue'
import {
  mockSites,
  mockTenants,
  mockSiteStats,
  mockNetboxSyncLogs,
  siteManagementUtils
} from '@/data/mockData.js'

// Props
const props = defineProps({
  tenantId: {
    type: String,
    default: ''
  },
  tenantName: {
    type: String,
    default: ''
  }
})

// 响应式数据
const loading = ref(false)
const saving = ref(false)
const syncing = ref(false)
const showCreateDialog = ref(false)
const showDetailDialog = ref(false)
const showSyncDialog = ref(false)
const showSyncHistoryDialog = ref(false)
const showSyncLogDetailDialog = ref(false)
const editingSite = ref(null)
const selectedSite = ref(null)
const selectedSites = ref([])
const selectedSyncLog = ref(null)
const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const siteFormRef = ref(null)

// 筛选条件
const filters = reactive({
  status: '',
  region: '',
  type: '',
  tenantId: props.tenantId || ''
})

// 站点表单数据
const siteForm = reactive({
  name: '',
  code: '',
  tenantId: '',
  type: '',
  status: 'active',
  region: '',
  address: '',
  longitude: null,
  latitude: null,
  capacity: '',
  description: ''
})

// 同步进度
const syncProgress = reactive({
  status: 'idle', // idle, running, success, error
  percentage: 0,
  message: ''
})

// 表单验证规则
const siteRules = {
  name: [
    { required: true, message: '请输入站点名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  code: [
    { required: true, message: '请输入站点代码', trigger: 'blur' },
    { pattern: /^[A-Z0-9-]+$/, message: '站点代码只能包含大写字母、数字和连字符', trigger: 'blur' }
  ],
  tenantId: [
    { required: true, message: '请选择所属租户', trigger: 'change' }
  ],
  type: [
    { required: true, message: '请选择站点类型', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ],
  region: [
    { required: true, message: '请选择区域', trigger: 'change' }
  ],
  address: [
    { required: true, message: '请输入地址', trigger: 'blur' }
  ],
  longitude: [
    { required: true, message: '请输入经度', trigger: 'blur' },
    { type: 'number', min: -180, max: 180, message: '经度范围为 -180 到 180', trigger: 'blur' }
  ],
  latitude: [
    { required: true, message: '请输入纬度', trigger: 'blur' },
    { type: 'number', min: -90, max: 90, message: '纬度范围为 -90 到 90', trigger: 'blur' }
  ]
}

// 计算属性
const sites = ref([...mockSites])
const availableTenants = ref([...mockTenants])
const siteStats = ref({ ...mockSiteStats })
const syncLogs = ref([...mockNetboxSyncLogs])

const filteredSites = computed(() => {
  return siteManagementUtils.searchSites(searchQuery.value, filters)
})

const totalSites = computed(() => filteredSites.value.length)

// 同步统计计算属性
const successfulSyncs = computed(() => {
  return syncLogs.value.filter(log => log.status === 'success').length
})

const failedSyncs = computed(() => {
  return syncLogs.value.filter(log => log.status === 'partial_success' || log.status === 'failed').length
})

const successRate = computed(() => {
  if (syncLogs.value.length === 0) return 0
  return Math.round((successfulSyncs.value / syncLogs.value.length) * 100)
})

// 方法
const handleSearch = () => {
  currentPage.value = 1
}

const handleFilter = () => {
  currentPage.value = 1
}

const handleSelectionChange = (selection) => {
  selectedSites.value = selection
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
}

const handleCurrentChange = (page) => {
  currentPage.value = page
}

// 站点状态相关方法
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

const getSiteTypeColor = (type) => {
  const typeMap = {
    '数据中心': 'primary',
    '办公室': 'success',
    '研发中心': 'warning',
    '科技园区': 'info'
  }
  return typeMap[type] || 'info'
}

const getSyncStatusColor = (status) => {
  const statusMap = {
    'synced': 'success',
    'pending': 'warning',
    'failed': 'danger'
  }
  return statusMap[status] || 'info'
}

const getSyncStatusText = (status) => {
  const statusMap = {
    'synced': '已同步',
    'pending': '待同步',
    'failed': '同步失败'
  }
  return statusMap[status] || status
}

// 同步日志状态相关方法
const getSyncLogStatusColor = (status) => {
  const statusMap = {
    'success': 'success',
    'partial_success': 'warning',
    'failed': 'danger'
  }
  return statusMap[status] || 'info'
}

const getSyncLogStatusText = (status) => {
  const statusMap = {
    'success': '成功',
    'partial_success': '部分成功',
    'failed': '失败'
  }
  return statusMap[status] || status
}

const getSyncActionColor = (action) => {
  const actionMap = {
    'updated': 'primary',
    'created': 'success',
    'deleted': 'danger',
    'failed': 'danger'
  }
  return actionMap[action] || 'info'
}

const getSyncActionText = (action) => {
  const actionMap = {
    'updated': '更新',
    'created': '创建',
    'deleted': '删除',
    'failed': '失败'
  }
  return actionMap[action] || action
}

// CRUD操作
const handleCreateSite = () => {
  // 如果有指定租户ID，自动预设
  if (props.tenantId) {
    siteForm.tenantId = props.tenantId
  }
  showCreateDialog.value = true
}

const viewSite = (site) => {
  selectedSite.value = site
  showDetailDialog.value = true
}

const editSite = (site) => {
  editingSite.value = site
  Object.assign(siteForm, {
    name: site.name,
    code: site.code,
    tenantId: site.tenantId,
    type: site.type,
    status: site.status,
    region: site.region,
    address: site.address,
    longitude: site.longitude,
    latitude: site.latitude,
    capacity: site.capacity,
    description: site.description
  })
  showCreateDialog.value = true
}

const deleteSite = async (site) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除站点 "${site.name}" 吗？此操作不可恢复。`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    // 模拟删除操作
    const index = sites.value.findIndex(s => s.id === site.id)
    if (index > -1) {
      sites.value.splice(index, 1)
      ElMessage.success('站点删除成功')
    }
  } catch {
    ElMessage.info('已取消删除')
  }
}

const saveSite = async () => {
  if (!siteFormRef.value) return

  try {
    await siteFormRef.value.validate()
    saving.value = true

    // 模拟保存操作
    await new Promise(resolve => setTimeout(resolve, 1000))

    if (editingSite.value) {
      // 更新站点
      const index = sites.value.findIndex(s => s.id === editingSite.value.id)
      if (index > -1) {
        sites.value[index] = {
          ...sites.value[index],
          ...siteForm,
          tenantName: availableTenants.value.find(t => t.id === siteForm.tenantId)?.name || ''
        }
      }
      ElMessage.success('站点更新成功')
    } else {
      // 创建新站点
      const newSite = {
        id: 'site-' + Date.now(),
        ...siteForm,
        tenantName: availableTenants.value.find(t => t.id === siteForm.tenantId)?.name || '',
        syncStatus: 'pending',
        lastSyncAt: '',
        netboxId: '',
        createdAt: new Date().toISOString().slice(0, 19).replace('T', ' ')
      }
      sites.value.unshift(newSite)
      ElMessage.success('站点创建成功')
    }

    showCreateDialog.value = false
    resetForm()
  } catch (error) {
    console.error('保存站点失败:', error)
  } finally {
    saving.value = false
  }
}

const resetForm = () => {
  editingSite.value = null
  Object.assign(siteForm, {
    name: '',
    code: '',
    tenantId: '',
    type: '',
    status: 'active',
    region: '',
    address: '',
    longitude: null,
    latitude: null,
    capacity: '',
    description: ''
  })
  if (siteFormRef.value) {
    siteFormRef.value.clearValidate()
  }
}

const handleBatchDelete = async () => {
  if (!selectedSites.value.length) return

  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedSites.value.length} 个站点吗？此操作不可恢复。`,
      '确认批量删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    // 模拟批量删除
    const idsToDelete = selectedSites.value.map(site => site.id)
    sites.value = sites.value.filter(site => !idsToDelete.includes(site.id))
    selectedSites.value = []
    ElMessage.success(`成功删除 ${idsToDelete.length} 个站点`)
  } catch {
    ElMessage.info('已取消删除')
  }
}

const exportSites = () => {
  // 模拟导出功能
  const csvContent = [
    ['站点名称', '站点代码', '所属租户', '类型', '状态', '区域', '地址'].join(','),
    ...filteredSites.value.map(site => [
      site.name,
      site.code,
      site.tenantName,
      site.type,
      getSiteStatusText(site.status),
      site.region,
      site.address
    ].join(','))
  ].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `sites_${new Date().toISOString().slice(0, 10)}.csv`
  link.click()

  ElMessage.success('站点数据导出成功')
}

// Netbox同步功能
const syncFromNetbox = async () => {
  syncing.value = true
  showSyncDialog.value = true
  syncProgress.status = 'running'
  syncProgress.percentage = 0
  syncProgress.message = '正在连接Netbox服务器...'

  try {
    // 模拟同步过程
    for (let i = 0; i <= 100; i += 10) {
      await new Promise(resolve => setTimeout(resolve, 200))
      syncProgress.percentage = i

      if (i === 20) {
        syncProgress.message = '正在获取站点数据...'
      } else if (i === 50) {
        syncProgress.message = '正在解析站点信息...'
      } else if (i === 80) {
        syncProgress.message = '正在更新本地数据...'
      } else if (i === 100) {
        syncProgress.message = '同步完成'
      }
    }

    // 使用工具函数模拟同步
    const syncResult = await siteManagementUtils.simulateNetboxSync()

    syncProgress.status = 'success'
    syncProgress.message = `同步完成！共处理 ${syncResult.totalSites} 个站点，更新 ${syncResult.updatedSites} 个站点。`

    // 更新站点数据
    sites.value.forEach(site => {
      site.syncStatus = 'synced'
      site.lastSyncAt = new Date().toISOString().slice(0, 19).replace('T', ' ')
    })

    // 添加同步日志记录
    const newSyncLog = {
      ...syncResult,
      id: 'log-' + Date.now()
    }
    syncLogs.value.unshift(newSyncLog)

    ElMessage.success('Netbox数据同步成功')
  } catch (error) {
    syncProgress.status = 'error'
    syncProgress.message = '同步失败：' + (error.message || '未知错误')
    ElMessage.error('Netbox数据同步失败')
  } finally {
    syncing.value = false
  }
}

const retrySync = () => {
  syncFromNetbox()
}

// 同步历史相关方法
const viewSyncLogDetail = (log) => {
  selectedSyncLog.value = log
  showSyncLogDetailDialog.value = true
}

const refreshSyncLogs = () => {
  // 模拟刷新同步日志
  ElMessage.success('同步日志已刷新')
}

const clearSyncLogs = async () => {
  try {
    await ElMessageBox.confirm(
      '确定要清空所有同步日志吗？此操作不可恢复。',
      '确认清空',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    syncLogs.value = []
    ElMessage.success('同步日志已清空')
  } catch {
    ElMessage.info('已取消清空')
  }
}

// 监听租户变化
watch(() => props.tenantId, (newTenantId) => {
  filters.tenantId = newTenantId
}, { immediate: true })

// 组件挂载
onMounted(() => {
  // 初始化数据
})
</script>

<style scoped>
.site-management {
  padding: 20px;
}

.site-description {
  margin-bottom: 20px;
}

.site-description ul {
  margin: 8px 0 0 0;
  padding-left: 16px;
}

.site-description li {
  margin-bottom: 4px;
  color: var(--text-secondary);
}

.form-help-text {
  font-size: 12px;
  color: var(--text-secondary);
  margin-top: 4px;
  line-height: 1.4;
}

.search-filters {
  margin-bottom: 20px;
}

.filter-card {
  border: 1px solid var(--border-color);
}

.site-stats {
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
  border: 1px solid var(--border-color);
}

.site-list {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.site-name {
  display: flex;
  align-items: center;
  gap: 8px;
}

.site-icon {
  color: var(--primary-color);
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.site-detail {
  padding: 20px 0;
}

.sync-progress {
  padding: 20px;
  text-align: center;
}

.sync-message {
  margin-top: 10px;
  color: var(--text-secondary);
}

/* 同步历史样式 */
.sync-history {
  padding: 20px 0;
}

.sync-stats {
  margin-bottom: 20px;
}

.sync-logs {
  margin-top: 20px;
}

.sync-log-detail {
  padding: 20px 0;
}

.sync-details {
  margin-top: 20px;
}

.sync-details h4 {
  margin: 0 0 16px 0;
  color: var(--text-primary);
  font-size: 14px;
  font-weight: 500;
}

/* 深色模式适配 */
[data-theme="dark"] .filter-card,
[data-theme="dark"] .stat-card,
[data-theme="dark"] .site-list .el-card {
  background-color: var(--bg-card);
  border-color: var(--border-color);
}

[data-theme="dark"] .site-management {
  background-color: var(--bg-primary);
  color: var(--text-primary);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .site-management {
    padding: 10px;
  }

  .search-filters .el-col {
    margin-bottom: 10px;
  }

  .site-stats .el-col {
    margin-bottom: 10px;
  }

  /* 表格响应式优化 */
  .site-list .el-table {
    font-size: 12px;
  }

  .site-list .el-table .el-table__cell {
    padding: 8px 4px;
  }

  /* 隐藏部分列在小屏幕上 */
  .site-list .el-table .hidden-sm {
    display: none;
  }
}

@media (max-width: 480px) {
  .site-management {
    padding: 5px;
  }

  .search-filters .el-row,
  .site-stats .el-row {
    flex-direction: column;
  }

  .search-filters .el-col,
  .site-stats .el-col {
    width: 100% !important;
    margin-bottom: 8px;
  }

  .header-actions {
    flex-direction: column;
    gap: 5px;
  }

  /* 极小屏幕表格优化 */
  .site-list .el-table {
    font-size: 11px;
  }

  .site-list .el-table .el-table__cell {
    padding: 6px 2px;
  }

  /* 在极小屏幕上只显示关键列 */
  .site-list .el-table .hidden-xs {
    display: none;
  }

  /* 对话框在小屏幕上的优化 */
  .el-dialog {
    width: 95% !important;
    margin: 5vh auto !important;
  }

  .el-dialog__body {
    padding: 10px !important;
  }
}
</style>
