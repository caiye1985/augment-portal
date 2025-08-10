<template>
  <PageLayout
    title="资产管理"
    description="Netbox资产管理系统集成配置"
    icon="Box"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="testConnection">
        <el-icon><Connection /></el-icon>
        测试连接
      </el-button>
      <el-button @click="syncAssets">
        <el-icon><Refresh /></el-icon>
        同步资产
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in assetStatsCards" :key="stat.label">
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
      <el-tabs v-model="activeTab" type="card" class="demo-tabs">
        <!-- Netbox配置 -->
        <el-tab-pane label="Netbox配置" name="config">
          <div class="tab-content">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-card title="服务器配置">
                  <el-form
                    ref="configFormRef"
                    :model="netboxConfig"
                    :rules="configRules"
                    label-width="120px"
                  >
                    <el-form-item label="服务器地址" prop="server">
                      <el-input
                        v-model="netboxConfig.server"
                        placeholder="例如: netbox.example.com"
                      />
                    </el-form-item>
                    <el-form-item label="端口" prop="port">
                      <el-input-number
                        v-model="netboxConfig.port"
                        :min="1"
                        :max="65535"
                        style="width: 100%"
                      />
                    </el-form-item>
                    <el-form-item label="API Token" prop="token">
                      <el-input
                        v-model="netboxConfig.token"
                        type="password"
                        placeholder="请输入API Token"
                        show-password
                      />
                    </el-form-item>
                    <el-form-item label="使用HTTPS" prop="useHttps">
                      <el-switch v-model="netboxConfig.useHttps" />
                    </el-form-item>
                    <el-form-item>
                      <el-button type="primary" @click="saveConfig">保存配置</el-button>
                      <el-button @click="testConnection">测试连接</el-button>
                    </el-form-item>
                  </el-form>
                </el-card>
              </el-col>

              <el-col :span="12">
                <el-card title="同步配置">
                  <el-form :model="syncConfig" label-width="120px">
                    <el-form-item label="自动同步">
                      <el-switch v-model="syncConfig.autoSync" />
                    </el-form-item>
                    <el-form-item label="同步间隔" v-if="syncConfig.autoSync">
                      <el-select v-model="syncConfig.syncInterval" style="width: 100%">
                        <el-option label="每小时" value="1h" />
                        <el-option label="每6小时" value="6h" />
                        <el-option label="每12小时" value="12h" />
                        <el-option label="每天" value="24h" />
                      </el-select>
                    </el-form-item>
                    <el-form-item label="同步范围">
                      <el-checkbox-group v-model="syncConfig.syncScope">
                        <el-checkbox value="sites">站点</el-checkbox>
                        <el-checkbox value="locations">位置</el-checkbox>
                        <el-checkbox value="devices">设备</el-checkbox>
                        <el-checkbox value="ips">IP地址</el-checkbox>
                        <el-checkbox value="cables">线缆</el-checkbox>
                      </el-checkbox-group>
                    </el-form-item>
                    <el-form-item>
                      <el-button type="primary" @click="saveSyncConfig">保存同步配置</el-button>
                    </el-form-item>
                  </el-form>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>

        <!-- Netbox系统 -->
        <el-tab-pane label="Netbox系统" name="netbox-system">
          <div class="tab-content">
            <el-alert
              title="Netbox资产管理系统"
              description="通过iframe集成的Netbox系统，支持完整的资产管理功能"
              type="info"
              :closable="false"
              style="margin-bottom: 20px"
            />

            <IframeContainer
              system="netbox"
              :height="700"
              @load="onNetboxLoad"
              @error="onNetboxError"
              @reload="onNetboxReload"
            />
          </div>
        </el-tab-pane>

        <!-- 资产概览 -->
        <el-tab-pane label="资产概览" name="overview">
          <div class="tab-content">
            <el-row :gutter="20">
              <el-col :span="8">
                <el-card title="站点统计">
                  <div class="stat-item">
                    <span class="stat-label">总站点数:</span>
                    <span class="stat-value">{{ assetStats.totalSites }}</span>
                  </div>
                  <div class="stat-item">
                    <span class="stat-label">活跃站点:</span>
                    <span class="stat-value">{{ assetStats.activeSites }}</span>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="8">
                <el-card title="设备统计">
                  <div class="stat-item">
                    <span class="stat-label">总设备数:</span>
                    <span class="stat-value">{{ assetStats.totalDevices }}</span>
                  </div>
                  <div class="stat-item">
                    <span class="stat-label">在线设备:</span>
                    <span class="stat-value">{{ assetStats.onlineDevices }}</span>
                  </div>
                </el-card>
              </el-col>
              <el-col :span="8">
                <el-card title="IP地址统计">
                  <div class="stat-item">
                    <span class="stat-label">总IP数:</span>
                    <span class="stat-value">{{ assetStats.totalIPs }}</span>
                  </div>
                  <div class="stat-item">
                    <span class="stat-label">已分配:</span>
                    <span class="stat-value">{{ assetStats.assignedIPs }}</span>
                  </div>
                </el-card>
              </el-col>
            </el-row>

            <el-card title="最近同步记录" style="margin-top: 20px">
              <el-table :data="syncHistory" style="width: 100%">
                <el-table-column prop="syncTime" label="同步时间" width="180" />
                <el-table-column prop="syncType" label="同步类型" width="120" />
                <el-table-column prop="recordCount" label="记录数量" width="120" />
                <el-table-column prop="status" label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag :type="row.status === 'success' ? 'success' : 'danger'">
                      {{ row.status === 'success' ? '成功' : '失败' }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="duration" label="耗时" width="100" />
                <el-table-column prop="message" label="备注" />
              </el-table>
            </el-card>
          </div>
        </el-tab-pane>
      </el-tabs>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Connection, Refresh, Box } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'
import IframeContainer from '@/components/IframeContainer.vue'

// 响应式数据
const activeTab = ref('config')
const configFormRef = ref(null)

// Netbox配置
const netboxConfig = reactive({
  server: 'netbox.example.com',
  port: 443,
  token: '',
  useHttps: true
})

// 同步配置
const syncConfig = reactive({
  autoSync: true,
  syncInterval: '6h',
  syncScope: ['sites', 'devices', 'ips']
})

// 资产统计数据
const assetStats = reactive({
  totalSites: 15,
  activeSites: 14,
  totalDevices: 256,
  onlineDevices: 238,
  totalIPs: 1024,
  assignedIPs: 756
})

// 统计卡片数据
const assetStatsCards = computed(() => [
  {
    label: '总站点数',
    value: assetStats.totalSites,
    icon: 'OfficeBuilding',
    color: 'var(--el-color-primary)',
    trend: 2.1
  },
  {
    label: '总设备数',
    value: assetStats.totalDevices,
    icon: 'Monitor',
    color: 'var(--el-color-success)',
    trend: 5.3
  },
  {
    label: '在线设备',
    value: assetStats.onlineDevices,
    icon: 'Connection',
    color: 'var(--el-color-warning)',
    trend: 1.2
  },
  {
    label: 'IP使用率',
    value: `${Math.round((assetStats.assignedIPs / assetStats.totalIPs) * 100)}%`,
    icon: 'Network',
    color: 'var(--el-color-info)',
    trend: -0.5
  }
])

// 同步历史记录
const syncHistory = ref([
  {
    syncTime: '2024-01-15 14:30:00',
    syncType: '全量同步',
    recordCount: 256,
    status: 'success',
    duration: '2分30秒',
    message: '同步完成'
  },
  {
    syncTime: '2024-01-15 08:30:00',
    syncType: '增量同步',
    recordCount: 12,
    status: 'success',
    duration: '15秒',
    message: '同步完成'
  },
  {
    syncTime: '2024-01-14 20:30:00',
    syncType: '增量同步',
    recordCount: 0,
    status: 'failed',
    duration: '5秒',
    message: 'API连接超时'
  }
])

// 表单验证规则
const configRules = {
  server: [
    { required: true, message: '请输入服务器地址', trigger: 'blur' }
  ],
  port: [
    { required: true, message: '请输入端口号', trigger: 'blur' }
  ],
  token: [
    { required: true, message: '请输入API Token', trigger: 'blur' }
  ]
}

// 方法
const handleStatClick = (stat) => {
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const testConnection = async () => {
  try {
    ElMessage.info('正在测试连接...')
    // 模拟连接测试
    await new Promise(resolve => setTimeout(resolve, 2000))
    ElMessage.success('连接测试成功')
  } catch (error) {
    ElMessage.error('连接测试失败')
  }
}

const syncAssets = async () => {
  try {
    ElMessage.info('正在同步资产数据...')
    // 模拟同步过程
    await new Promise(resolve => setTimeout(resolve, 3000))
    ElMessage.success('资产同步完成')
  } catch (error) {
    ElMessage.error('资产同步失败')
  }
}

const saveConfig = async () => {
  if (!configFormRef.value) return

  try {
    await configFormRef.value.validate()
    ElMessage.success('配置保存成功')
  } catch (error) {
    ElMessage.error('请检查配置信息')
  }
}

const saveSyncConfig = () => {
  ElMessage.success('同步配置保存成功')
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
}

// Netbox iframe事件处理
const onNetboxLoad = (data) => {
  console.log('Netbox系统加载完成:', data)
  ElMessage.success('Netbox系统加载成功')
}

const onNetboxError = (data) => {
  console.error('Netbox系统加载失败:', data)
  ElMessage.error('Netbox系统加载失败，请检查网络连接或联系管理员')
}

const onNetboxReload = (data) => {
  console.log('Netbox系统重新加载:', data)
  ElMessage.info('正在重新加载Netbox系统...')
}

onMounted(() => {
  console.log('资产管理模块已加载')
})
</script>

<style scoped>
.tab-content {
  padding: 20px 0;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
}

.stat-item:last-child {
  border-bottom: none;
}

.stat-label {
  color: #666;
}

.stat-value {
  font-weight: 600;
  color: #333;
}

.demo-tabs {
  margin-top: 20px;
}
</style>
