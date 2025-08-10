<template>
  <PageLayout
    title="租户管理"
    description="多租户数据隔离管理，支持租户切换和权限控制"
    icon="OfficeBuilding"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新增租户
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in tenantStats" :key="stat.label">
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

    <!-- 标签页导航 -->
    <el-tabs v-model="activeTab" @tab-change="handleTabChange" class="management-tabs">
      <!-- 租户管理标签页 -->
      <el-tab-pane label="租户管理" name="tenants">

        <!-- 租户切换器 -->
        <div class="tenant-switcher">
          <el-card shadow="never" class="switcher-card">
            <div class="switcher-content">
              <div class="current-tenant">
                <span class="label">当前租户：</span>
                <el-tag type="primary" size="large">{{ currentTenant.name }}</el-tag>
                <el-tag type="info" size="small">{{ currentTenant.code }}</el-tag>
              </div>
              <el-select
                v-model="selectedTenantId"
                placeholder="切换租户"
                @change="switchTenant"
                class="tenant-selector"
              >
                <el-option
                  v-for="tenant in tenants"
                  :key="tenant.id"
                  :label="`${tenant.name} (${tenant.code})`"
                  :value="tenant.id"
                />
              </el-select>
            </div>
          </el-card>
        </div>

        <!-- 标签页内容 -->
        <div v-if="activeTab === 'tenants'" class="tenant-content">
          <!-- 租户列表 -->
          <div class="tenant-list">
            <el-card shadow="never">
              <template #header>
                <div class="card-header">
                  <span>租户列表</span>
                  <div class="header-stats">
                    <el-statistic title="总租户数" :value="tenants.length" />
                    <el-statistic title="活跃租户" :value="activeTenants" />
                  </div>
                </div>
              </template>

              <el-table :data="tenants" style="width: 100%" v-loading="loading">
                <el-table-column prop="name" label="租户名称" width="200">
                  <template #default="{ row }">
                    <div class="tenant-name">
                      <el-avatar :size="32" :src="row.logo" :alt="row.name">
                        {{ row.name.charAt(0) }}
                      </el-avatar>
                      <span>{{ row.name }}</span>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column prop="code" label="租户代码" width="120" />
                <el-table-column prop="type" label="租户类型" width="120">
                  <template #default="{ row }">
                    <el-tag :type="getTenantTypeColor(row.type)">{{ row.type }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag :type="row.status === '活跃' ? 'success' : 'danger'">
                      {{ row.status }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="userCount" label="用户数量" width="100" />
                <el-table-column prop="dataSize" label="数据量" width="120" />
                <el-table-column prop="createdTime" label="创建时间" width="180" />
                <el-table-column label="操作" width="280" fixed="right">
                  <template #default="{ row }">
                    <el-button size="small" @click="viewTenant(row)">查看</el-button>
                    <el-button size="small" type="primary" @click="editTenant(row)">编辑</el-button>
                    <el-button size="small" type="warning" @click="manageTenantSites(row)">
                      <el-icon><OfficeBuilding /></el-icon>
                      站点管理
                    </el-button>
                    <el-button size="small" type="danger" @click="deleteTenant(row)">删除</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </div>
        </div>

        <!-- 数据隔离展示 -->
        <div class="data-isolation-demo">
          <el-card shadow="never">
            <template #header>
              <span>数据隔离演示</span>
            </template>
            <div class="isolation-content">
              <div class="isolation-stats">
                <el-row :gutter="20">
                  <el-col :span="6">
                    <el-statistic title="当前租户工单" :value="currentTenantStats.tickets" />
                  </el-col>
                  <el-col :span="6">
                    <el-statistic title="当前租户用户" :value="currentTenantStats.users" />
                  </el-col>
                  <el-col :span="6">
                    <el-statistic title="当前租户知识库" :value="currentTenantStats.knowledge" />
                  </el-col>
                  <el-col :span="6">
                    <el-statistic title="数据隔离率" :value="100" suffix="%" />
                  </el-col>
                </el-row>
              </div>
              <div class="isolation-chart">
                <div ref="isolationChart" style="height: 300px;"></div>
              </div>
            </div>
          </el-card>
        </div>
      </el-tab-pane>

      <!-- 租户类型管理标签页 -->
      <el-tab-pane label="租户类型管理" name="tenantTypes">
        <div class="tenant-types-management">
          <!-- 租户类型操作栏 -->
          <div class="types-actions">
            <el-button type="primary" @click="showTenantTypeDialog = true">
              <el-icon><Plus /></el-icon>
              新增租户类型
            </el-button>
          </div>

          <!-- 租户类型列表 -->
          <el-card shadow="never" class="types-card">
            <el-table :data="tenantTypes" style="width: 100%">
              <el-table-column prop="name" label="类型名称" width="150">
                <template #default="{ row }">
                  <el-tag :type="row.color" size="large">{{ row.name }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="description" label="描述" min-width="200" />
              <el-table-column prop="price" label="价格" width="120">
                <template #default="{ row }">
                  <span class="price-text">
                    {{ row.price === 0 ? '免费' : `¥${row.price}` }}
                  </span>
                </template>
              </el-table-column>
              <el-table-column prop="maxUsers" label="最大用户数" width="120">
                <template #default="{ row }">
                  {{ row.maxUsers === -1 ? '无限制' : row.maxUsers }}
                </template>
              </el-table-column>
              <el-table-column prop="maxSites" label="最大站点数" width="120">
                <template #default="{ row }">
                  {{ row.maxSites === -1 ? '无限制' : row.maxSites }}
                </template>
              </el-table-column>
              <el-table-column prop="features" label="功能特性" min-width="200">
                <template #default="{ row }">
                  <el-tag
                    v-for="feature in row.features.slice(0, 2)"
                    :key="feature"
                    size="small"
                    style="margin-right: 4px;"
                  >
                    {{ feature }}
                  </el-tag>
                  <el-tag v-if="row.features.length > 2" size="small" type="info">
                    +{{ row.features.length - 2 }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button size="small" @click="viewTenantType(row)">查看</el-button>
                  <el-button size="small" type="primary" @click="editTenantType(row)">编辑</el-button>
                  <el-button size="small" type="danger" @click="deleteTenantType(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 创建租户对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建租户" width="600px">
      <el-form :model="newTenant" :rules="tenantRules" ref="tenantForm" label-width="100px">
        <el-form-item label="租户名称" prop="name">
          <el-input v-model="newTenant.name" placeholder="请输入租户名称" />
        </el-form-item>
        <el-form-item label="租户代码" prop="code">
          <el-input v-model="newTenant.code" placeholder="请输入租户代码" />
        </el-form-item>
        <el-form-item label="租户类型" prop="type">
          <el-select v-model="newTenant.type" placeholder="请选择租户类型">
            <el-option
              v-for="type in tenantTypes"
              :key="type.id"
              :label="type.name"
              :value="type.name"
            >
              <div style="display: flex; justify-content: space-between; align-items: center;">
                <span>{{ type.name }}</span>
                <el-tag :type="type.color" size="small">{{ type.price === 0 ? '免费' : `¥${type.price}` }}</el-tag>
              </div>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="newTenant.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="newTenant.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="newTenant.description" type="textarea" rows="3" placeholder="请输入租户描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createTenant">确定</el-button>
      </template>
    </el-dialog>

    <!-- 站点管理对话框 -->
    <el-dialog
      v-model="showSiteManagementDialog"
      :title="`${selectedTenantForSites?.name} - 站点管理`"
      width="90%"
      :close-on-click-modal="false"
      class="site-management-dialog"
    >
      <SiteManagement
        v-if="selectedTenantForSites"
        :tenant-id="selectedTenantForSites.id"
        :tenant-name="selectedTenantForSites.name"
      />
    </el-dialog>

    <!-- 创建租户类型对话框 -->
    <el-dialog v-model="showTenantTypeDialog" title="创建租户类型" width="600px">
      <el-form :model="newTenantType" :rules="tenantTypeRules" ref="tenantTypeForm" label-width="100px">
        <el-form-item label="类型名称" prop="name">
          <el-input v-model="newTenantType.name" placeholder="请输入租户类型名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="newTenantType.description" type="textarea" rows="3" placeholder="请输入租户类型描述" />
        </el-form-item>
        <el-form-item label="最大用户数" prop="maxUsers">
          <el-input-number v-model="newTenantType.maxUsers" :min="-1" placeholder="最大用户数，-1表示无限制" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">-1表示无限制</span>
        </el-form-item>
        <el-form-item label="最大站点数" prop="maxSites">
          <el-input-number v-model="newTenantType.maxSites" :min="-1" placeholder="最大站点数，-1表示无限制" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">-1表示无限制</span>
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input-number v-model="newTenantType.price" :min="0" placeholder="价格" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">单位：元</span>
        </el-form-item>
        <el-form-item label="标签颜色" prop="color">
          <el-select v-model="newTenantType.color" placeholder="请选择标签颜色">
            <el-option label="主要" value="primary" />
            <el-option label="成功" value="success" />
            <el-option label="信息" value="info" />
            <el-option label="警告" value="warning" />
            <el-option label="危险" value="danger" />
          </el-select>
        </el-form-item>
        <el-form-item label="功能特性">
          <el-input
            v-model="featureInput"
            placeholder="输入功能特性，按回车添加"
            @keyup.enter="addFeature"
          />
          <div style="margin-top: 10px;">
            <el-tag
              v-for="(feature, index) in newTenantType.features"
              :key="index"
              closable
              @close="removeFeature(index)"
              style="margin-right: 8px; margin-bottom: 8px;"
            >
              {{ feature }}
            </el-tag>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showTenantTypeDialog = false">取消</el-button>
        <el-button type="primary" @click="createTenantType">确定</el-button>
      </template>
    </el-dialog>

    <!-- 编辑租户类型对话框 -->
    <el-dialog v-model="showTenantTypeEditDialog" title="编辑租户类型" width="600px">
      <el-form :model="editingTenantType" :rules="tenantTypeRules" ref="editTenantTypeForm" label-width="100px" v-if="editingTenantType">
        <el-form-item label="类型名称" prop="name">
          <el-input v-model="editingTenantType.name" placeholder="请输入租户类型名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="editingTenantType.description" type="textarea" rows="3" placeholder="请输入租户类型描述" />
        </el-form-item>
        <el-form-item label="最大用户数" prop="maxUsers">
          <el-input-number v-model="editingTenantType.maxUsers" :min="-1" placeholder="最大用户数，-1表示无限制" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">-1表示无限制</span>
        </el-form-item>
        <el-form-item label="最大站点数" prop="maxSites">
          <el-input-number v-model="editingTenantType.maxSites" :min="-1" placeholder="最大站点数，-1表示无限制" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">-1表示无限制</span>
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input-number v-model="editingTenantType.price" :min="0" placeholder="价格" />
          <span style="margin-left: 10px; color: #909399; font-size: 12px;">单位：元</span>
        </el-form-item>
        <el-form-item label="标签颜色" prop="color">
          <el-select v-model="editingTenantType.color" placeholder="请选择标签颜色">
            <el-option label="主要" value="primary" />
            <el-option label="成功" value="success" />
            <el-option label="信息" value="info" />
            <el-option label="警告" value="warning" />
            <el-option label="危险" value="danger" />
          </el-select>
        </el-form-item>
        <el-form-item label="功能特性">
          <el-input
            v-model="editFeatureInput"
            placeholder="输入功能特性，按回车添加"
            @keyup.enter="addEditFeature"
          />
          <div style="margin-top: 10px;">
            <el-tag
              v-for="(feature, index) in editingTenantType.features"
              :key="index"
              closable
              @close="removeEditFeature(index)"
              style="margin-right: 8px; margin-bottom: 8px;"
            >
              {{ feature }}
            </el-tag>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showTenantTypeEditDialog = false">取消</el-button>
        <el-button type="primary" @click="updateTenantType">确定</el-button>
      </template>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { OfficeBuilding, Plus, Refresh } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'
import SiteManagement from '@/components/SiteManagement.vue'
import { mockTenants, mockSites, mockTenantTypes } from '@/data/mockData.js'

// 响应式数据
const loading = ref(false)
const showCreateDialog = ref(false)
const showSiteManagementDialog = ref(false)
const selectedTenantId = ref('1')
const selectedTenantForSites = ref(null)
const isolationChart = ref(null)
const activeTab = ref('tenants')

// 导航标签页
const navItems = ref([
  { name: 'tenants', label: '租户管理' },
  { name: 'tenantTypes', label: '租户类型管理' }
])

// 标签页切换处理
const handleTabChange = (tabName) => {
  activeTab.value = tabName
}

// 当前租户信息
const currentTenant = ref({
  id: '1',
  name: '阿里巴巴集团',
  code: 'ALIBABA'
})

// 租户列表数据 - 使用mockData中的数据
const tenants = ref([...mockTenants])

// 租户类型数据
const tenantTypes = ref([...mockTenantTypes])

// 租户类型管理相关状态
const showTenantTypeDialog = ref(false)
const showTenantTypeEditDialog = ref(false)
const editingTenantType = ref(null)

// 新租户类型表单
const newTenantType = reactive({
  name: '',
  description: '',
  features: [],
  maxUsers: 100,
  maxSites: 10,
  price: 0,
  color: 'info'
})

// 租户类型表单验证规则
const tenantTypeRules = {
  name: [
    { required: true, message: '请输入租户类型名称', trigger: 'blur' }
  ],
  description: [
    { required: true, message: '请输入租户类型描述', trigger: 'blur' }
  ],
  price: [
    { required: true, message: '请输入价格', trigger: 'blur' },
    { type: 'number', min: 0, message: '价格不能小于0', trigger: 'blur' }
  ]
}

// 功能特性输入
const featureInput = ref('')
const editFeatureInput = ref('')

// 租户统计数据
const tenantStats = computed(() => {
  const totalSites = mockSites.length
  const activeSites = mockSites.filter(site => site.status === 'active').length

  return [
    {
      label: '租户总数',
      value: tenants.value.length,
      icon: 'OfficeBuilding',
      color: 'var(--el-color-primary, #6366f1)',
      trend: 8.5
    },
    {
      label: '活跃租户',
      value: activeTenants.value,
      icon: 'User',
      color: 'var(--el-color-success, #10b981)',
      trend: 12.3
    },
    {
      label: '站点总数',
      value: totalSites,
      icon: 'Location',
      color: 'var(--el-color-warning, #f59e0b)',
      trend: 5.7
    },
    {
      label: '活跃站点',
      value: activeSites,
      icon: 'CircleCheck',
      color: 'var(--el-color-info, #3b82f6)',
      trend: -2.1
    }
  ]
})

// 当前租户统计数据
const currentTenantStats = ref({
  tickets: 1245,
  users: 1250,
  knowledge: 856
})

// 计算活跃租户数量
const activeTenants = computed(() => {
  return tenants.value.filter(t => t.status === '活跃').length
})

// 新租户表单数据
const newTenant = reactive({
  name: '',
  code: '',
  type: '',
  contact: '',
  phone: '',
  description: ''
})

// 表单验证规则
const tenantRules = {
  name: [{ required: true, message: '请输入租户名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入租户代码', trigger: 'blur' }],
  type: [{ required: true, message: '请选择租户类型', trigger: 'change' }],
  contact: [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入联系电话', trigger: 'blur' }]
}

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const getTenantTypeColor = (type) => {
  const colors = {
    '企业版': 'success',
    '专业版': 'warning',
    '基础版': 'info'
  }
  return colors[type] || 'info'
}

const switchTenant = (tenantId) => {
  const tenant = tenants.value.find(t => t.id === tenantId)
  if (tenant) {
    currentTenant.value = tenant
    ElMessage.success(`已切换到租户：${tenant.name}`)
    // 模拟数据更新
    updateTenantStats(tenantId)
  }
}

const updateTenantStats = (tenantId) => {
  // 模拟不同租户的数据
  const statsMap = {
    '1': { tickets: 1245, users: 1250, knowledge: 856 },
    '2': { tickets: 980, users: 980, knowledge: 642 },
    '3': { tickets: 750, users: 750, knowledge: 423 },
    '4': { tickets: 420, users: 420, knowledge: 256 }
  }
  currentTenantStats.value = statsMap[tenantId] || statsMap['1']
  nextTick(() => {
    initIsolationChart()
  })
}

const viewTenant = (tenant) => {
  ElMessage.info(`查看租户：${tenant.name}`)
}

const editTenant = (tenant) => {
  ElMessage.info(`编辑租户：${tenant.name}`)
}

const deleteTenant = (tenant) => {
  ElMessageBox.confirm(
    `确定要删除租户 "${tenant.name}" 吗？此操作不可恢复。`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('删除成功')
  }).catch(() => {
    ElMessage.info('已取消删除')
  })
}

const manageTenantSites = (tenant) => {
  selectedTenantForSites.value = tenant
  showSiteManagementDialog.value = true
}

const createTenant = () => {
  ElMessage.success('租户创建成功')
  showCreateDialog.value = false
}

const refreshData = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
    ElMessage.success('数据刷新成功')
  }, 1000)
}

// 租户类型管理方法
const addFeature = () => {
  if (featureInput.value.trim()) {
    newTenantType.features.push(featureInput.value.trim())
    featureInput.value = ''
  }
}

const removeFeature = (index) => {
  newTenantType.features.splice(index, 1)
}

const addEditFeature = () => {
  if (editFeatureInput.value.trim() && editingTenantType.value) {
    editingTenantType.value.features.push(editFeatureInput.value.trim())
    editFeatureInput.value = ''
  }
}

const removeEditFeature = (index) => {
  if (editingTenantType.value) {
    editingTenantType.value.features.splice(index, 1)
  }
}

const createTenantType = () => {
  const newId = Math.max(...tenantTypes.value.map(t => t.id)) + 1
  const newType = {
    id: newId,
    ...newTenantType
  }
  tenantTypes.value.push(newType)

  // 重置表单
  Object.assign(newTenantType, {
    name: '',
    description: '',
    features: [],
    maxUsers: 100,
    maxSites: 10,
    price: 0,
    color: 'info'
  })

  showTenantTypeDialog.value = false
  ElMessage.success('租户类型创建成功')
}

const viewTenantType = (type) => {
  ElMessage.info(`查看租户类型：${type.name}`)
}

const editTenantType = (type) => {
  editingTenantType.value = { ...type, features: [...type.features] }
  showTenantTypeEditDialog.value = true
}

const updateTenantType = () => {
  if (editingTenantType.value) {
    const index = tenantTypes.value.findIndex(t => t.id === editingTenantType.value.id)
    if (index !== -1) {
      tenantTypes.value[index] = { ...editingTenantType.value }
      ElMessage.success('租户类型更新成功')
    }
  }
  showTenantTypeEditDialog.value = false
  editingTenantType.value = null
}

const deleteTenantType = (type) => {
  ElMessageBox.confirm(
    `确定要删除租户类型"${type.name}"吗？`,
    '确认删除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    const index = tenantTypes.value.findIndex(t => t.id === type.id)
    if (index !== -1) {
      tenantTypes.value.splice(index, 1)
      ElMessage.success('租户类型删除成功')
    }
  }).catch(() => {
    ElMessage.info('已取消删除')
  })
}

// 初始化数据隔离图表
const initIsolationChart = () => {
  if (!isolationChart.value) return

  const chart = echarts.init(isolationChart.value)
  const option = {
    title: {
      text: '租户数据隔离分布',
      left: 'center'
    },
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '数据分布',
        type: 'pie',
        radius: '50%',
        data: [
          { value: currentTenantStats.value.tickets, name: '工单数据' },
          { value: currentTenantStats.value.users, name: '用户数据' },
          { value: currentTenantStats.value.knowledge, name: '知识库数据' }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }
  chart.setOption(option)
}

onMounted(() => {
  nextTick(() => {
    initIsolationChart()
  })
})
</script>

<style scoped>
.tenant-management-demo {
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

.tenant-switcher {
  margin-bottom: 20px;
}

.switcher-card {
  border: 2px solid #e4e7ed;
}

.switcher-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.current-tenant {
  display: flex;
  align-items: center;
  gap: 10px;
}

.label {
  font-weight: 600;
  color: #606266;
}

.tenant-selector {
  width: 200px;
}

.tenant-list {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-stats {
  display: flex;
  gap: 40px;
}

.tenant-name {
  display: flex;
  align-items: center;
  gap: 10px;
}

.data-isolation-demo {
  margin-bottom: 20px;
}

.isolation-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.isolation-stats {
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

/* 站点管理对话框样式 */
.site-management-dialog .el-dialog__body {
  padding: 10px 20px 20px;
}

/* 深色模式适配 */
[data-theme="dark"] .site-management-dialog .el-dialog {
  background-color: var(--bg-card);
  border-color: var(--border-color);
}

[data-theme="dark"] .site-management-dialog .el-dialog__header {
  background-color: var(--bg-card);
  border-bottom-color: var(--border-color);
}

[data-theme="dark"] .site-management-dialog .el-dialog__title {
  color: var(--text-primary);
}

/* 租户类型管理样式 */
.tenant-types-management {
  padding: 20px 0;
}

.types-actions {
  margin-bottom: 20px;
  display: flex;
  justify-content: flex-start;
}

.types-card {
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.price-text {
  font-weight: 600;
  color: var(--el-color-primary);
}

.management-tabs {
  margin-bottom: 20px;
}

.management-tabs .el-tabs__header {
  margin-bottom: 20px;
}

.management-tabs .el-tabs__item {
  font-size: 16px;
  font-weight: 500;
}

/* 深色模式下的租户类型管理样式 */
[data-theme="dark"] .types-card {
  background-color: var(--bg-card);
  border-color: var(--border-color);
}

[data-theme="dark"] .price-text {
  color: var(--primary-color);
}
</style>
