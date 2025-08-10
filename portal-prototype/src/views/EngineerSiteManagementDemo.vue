<template>
  <div class="engineer-site-demo">
    <el-card>
      <template #header>
        <div class="demo-header">
          <h2>工程师站点管理演示</h2>
          <p>这是重构后的工程师站点管理页面演示</p>
        </div>
      </template>

      <div class="demo-content">
        <el-alert
          title="功能重构说明"
          type="success"
          :closable="false"
          show-icon
        >
          <template #default>
            <p><strong>原功能：</strong>工程师直接负责租户管理</p>
            <p><strong>新功能：</strong>工程师负责站点管理，基于地理位置实现就近服务</p>
          </template>
        </el-alert>

        <el-row :gutter="20" style="margin-top: 20px;">
          <el-col :span="12">
            <el-card shadow="hover">
              <template #header>
                <h3>主要变更</h3>
              </template>
              <ul class="feature-list">
                <li>✅ 页面标题更新为"工程师负责站点管理"</li>
                <li>✅ 工程师分配对象从租户改为站点</li>
                <li>✅ 显示工程师负责的站点数量和覆盖城市</li>
                <li>✅ 支持按城市、租户、类型筛选站点</li>
                <li>✅ 基于地理位置的智能推荐</li>
                <li>✅ 工作负载计算基于站点数量</li>
                <li>✅ 保留分配历史记录功能</li>
              </ul>
            </el-card>
          </el-col>

          <el-col :span="12">
            <el-card shadow="hover">
              <template #header>
                <h3>新增功能</h3>
              </template>
              <ul class="feature-list">
                <li>🆕 站点筛选：城市、租户、类型</li>
                <li>🆕 智能推荐：基于地理位置就近原则</li>
                <li>🆕 距离显示：显示站点与工程师的距离</li>
                <li>🆕 城市覆盖：统计工程师覆盖的城市数量</li>
                <li>🆕 负载预估：站点数量 + 工单数量</li>
                <li>🆕 推荐标识：高亮显示推荐站点</li>
                <li>🆕 地理优化：考虑就近分配原则</li>
              </ul>
            </el-card>
          </el-col>
        </el-row>

        <div class="demo-actions" style="margin-top: 30px; text-align: center;">
          <el-button type="primary" size="large" @click="goToSiteManagement">
            <el-icon><Connection /></el-icon>
            进入工程师站点管理
          </el-button>
          <el-button size="large" @click="goToOriginalPage">
            <el-icon><View /></el-icon>
            查看原租户管理页面
          </el-button>
        </div>

        <el-divider />

        <div class="demo-stats">
          <h3>功能对比统计</h3>
          <el-row :gutter="20">
            <el-col :span="6">
              <el-statistic title="管理维度" value="站点级别" />
              <p class="stat-desc">从租户级别细化到站点级别</p>
            </el-col>
            <el-col :span="6">
              <el-statistic title="分配策略" value="地理就近" />
              <p class="stat-desc">基于地理位置优化分配</p>
            </el-col>
            <el-col :span="6">
              <el-statistic title="筛选维度" value="3个" />
              <p class="stat-desc">城市、租户、类型筛选</p>
            </el-col>
            <el-col :span="6">
              <el-statistic title="智能推荐" value="启用" />
              <p class="stat-desc">自动推荐就近站点</p>
            </el-col>
          </el-row>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { Connection, View } from '@element-plus/icons-vue'

const router = useRouter()

const goToSiteManagement = () => {
  router.push('/personnel/engineer-sites')
}

const goToOriginalPage = () => {
  router.push('/personnel/engineer-tenant')
}
</script>

<style scoped>
.engineer-site-demo {
  padding: 20px;
}

.demo-header {
  text-align: center;
}

.demo-header h2 {
  margin: 0 0 10px 0;
  color: #303133;
}

.demo-header p {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.feature-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.feature-list li {
  padding: 8px 0;
  border-bottom: 1px solid #f0f0f0;
  font-size: 14px;
  color: #606266;
}

.feature-list li:last-child {
  border-bottom: none;
}

.demo-actions {
  padding: 20px 0;
}

.demo-stats {
  text-align: center;
}

.demo-stats h3 {
  margin-bottom: 20px;
  color: #303133;
}

.stat-desc {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
}
</style>
