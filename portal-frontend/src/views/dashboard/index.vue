<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="24">
        <el-card>
          <h1>{{ $t('nav.dashboard') }}</h1>
          <p>欢迎使用 IT 运维门户系统</p>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-icon">
              <el-icon size="40" color="#409EFF">
                <Tickets />
              </el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-number">{{ stats.totalTickets }}</div>
              <div class="stat-label">总工单数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-icon">
              <el-icon size="40" color="#67C23A">
                <User />
              </el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-number">{{ stats.totalEngineers }}</div>
              <div class="stat-label">工程师数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-icon">
              <el-icon size="40" color="#E6A23C">
                <Document />
              </el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-number">{{ stats.totalKnowledge }}</div>
              <div class="stat-label">知识条目</div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <el-col :span="6">
        <el-card>
          <div class="stat-card">
            <div class="stat-icon">
              <el-icon size="40" color="#F56C6C">
                <Warning />
              </el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-number">{{ stats.pendingTickets }}</div>
              <div class="stat-label">待处理工单</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { Tickets, User, Document, Warning } from '@element-plus/icons-vue'

const stats = reactive({
  totalTickets: 1234,
  totalEngineers: 56,
  totalKnowledge: 789,
  pendingTickets: 23
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 20px;
}

.stat-icon {
  margin-right: 20px;
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  color: #333;
  line-height: 1;
}

.stat-label {
  font-size: 14px;
  color: #666;
  margin-top: 8px;
}
</style>