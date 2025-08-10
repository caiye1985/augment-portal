<template>
  <div class="knowledge-demo">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1>📚 知识库管理</h1>
      <p>智能化知识管理系统，支持分类管理、审核流程和AI推荐</p>
    </div>

    <!-- 功能标签页 -->
    <el-tabs v-model="activeTab" type="card" class="demo-tabs">
      <!-- 知识库概览 -->
      <el-tab-pane label="知识库概览" name="overview">
        <div class="tab-content">
          <!-- 操作工具栏 -->
          <div class="toolbar">
            <div class="toolbar-left">
              <el-button type="primary" @click="showCreateDialog = true">
                <el-icon><Plus /></el-icon>
                新建文档
              </el-button>
              <el-button @click="importKnowledge">
                <el-icon><Upload /></el-icon>
                批量导入
              </el-button>
              <el-button @click="exportKnowledge">
                <el-icon><Download /></el-icon>
                导出知识库
              </el-button>
            </div>
            <div class="toolbar-right">
              <el-button @click="refreshKnowledge">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </div>

          <!-- 知识库统计卡片 -->
          <el-row :gutter="20" class="stats-row">
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-content">
                  <div class="stat-icon docs">
                    <el-icon><Document /></el-icon>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ knowledgeStats.totalDocs }}</div>
                    <div class="stat-label">文档总数</div>
                  </div>
                  <div class="stat-trend up">
                    <el-icon><TrendCharts /></el-icon>
                    <span>+15</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-content">
                  <div class="stat-icon views">
                    <el-icon><View /></el-icon>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ knowledgeStats.totalViews }}</div>
                    <div class="stat-label">总浏览量</div>
                  </div>
                  <div class="stat-trend up">
                    <el-icon><Top /></el-icon>
                    <span>+1.2k</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-content">
                  <div class="stat-icon pending">
                    <el-icon><Clock /></el-icon>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ knowledgeStats.pendingReview }}</div>
                    <div class="stat-label">待审核</div>
                  </div>
                  <div class="stat-trend stable">
                    <el-icon><Minus /></el-icon>
                    <span>0</span>
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-content">
                  <div class="stat-icon rating">
                    <el-icon><Star /></el-icon>
                  </div>
                  <div class="stat-info">
                    <div class="stat-number">{{ knowledgeStats.avgRating }}</div>
                    <div class="stat-label">平均评分</div>
                  </div>
                  <div class="stat-trend up">
                    <el-icon><Top /></el-icon>
                    <span>+0.3</span>
                  </div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <el-row :gutter="20">
            <!-- 左侧：分类导航和标签 -->
            <el-col :span="6">
              <!-- 知识分类树 -->
              <el-card class="category-card">
                <template #header>
                  <div class="card-header">
                    <span>知识分类</span>
                    <el-button size="small" @click="showCategoryDialog = true">
                      <el-icon><Plus /></el-icon>
                      管理分类
                    </el-button>
                  </div>
                </template>
                
                <el-tree
                  :data="categoryTree"
                  :props="{ children: 'children', label: 'name' }"
                  node-key="id"
                  :default-expanded-keys="[1]"
                  @node-click="selectCategory"
                  class="category-tree"
                >
                  <template #default="{ data }">
                    <div class="category-node">
                      <el-icon><Folder /></el-icon>
                      <span class="category-name">{{ data.name }}</span>
                      <el-badge :value="data.count" class="category-badge" />
                    </div>
                  </template>
                </el-tree>
              </el-card>

              <!-- 热门标签 -->
              <el-card class="tags-card" style="margin-top: 20px;">
                <template #header>
                  <div class="card-header">
                    <span>热门标签</span>
                    <el-button size="small" @click="showTagDialog = true">
                      <el-icon><Plus /></el-icon>
                      管理标签
                    </el-button>
                  </div>
                </template>
                
                <div class="tag-cloud">
                  <el-tag
                    v-for="tag in popularTags"
                    :key="tag.name"
                    :type="getTagType(tag.heat)"
                    @click="searchByTag(tag.name)"
                    class="tag-item"
                  >
                    {{ tag.name }} ({{ tag.count }})
                  </el-tag>
                </div>
              </el-card>

              <!-- 最近活动 -->
              <el-card class="activity-card" style="margin-top: 20px;">
                <template #header>
                  <span>最近活动</span>
                </template>
                
                <div class="activity-list">
                  <div 
                    v-for="activity in recentActivities" 
                    :key="activity.id"
                    class="activity-item"
                  >
                    <div class="activity-icon">
                      <el-icon v-if="activity.type === 'create'" color="#67c23a"><Plus /></el-icon>
                      <el-icon v-else-if="activity.type === 'update'" color="#409eff"><Edit /></el-icon>
                      <el-icon v-else-if="activity.type === 'review'" color="#e6a23c"><View /></el-icon>
                    </div>
                    <div class="activity-content">
                      <div class="activity-text">{{ activity.description }}</div>
                      <div class="activity-time">{{ activity.time }}</div>
                    </div>
                  </div>
                </div>
              </el-card>
            </el-col>

            <!-- 右侧：主内容区 -->
            <el-col :span="18">
              <!-- 搜索和筛选 -->
              <el-card class="filter-card">
                <el-row :gutter="16">
                  <el-col :span="8">
                    <el-input
                      v-model="searchText"
                      placeholder="搜索知识库内容、标题、标签..."
                      clearable
                      @keyup.enter="searchKnowledge"
                    >
                      <template #prefix>
                        <el-icon><Search /></el-icon>
                      </template>
                      <template #append>
                        <el-button @click="searchKnowledge">搜索</el-button>
                      </template>
                    </el-input>
                  </el-col>
                  <el-col :span="3">
                    <el-select v-model="sortBy" placeholder="排序方式">
                      <el-option label="最新发布" value="latest" />
                      <el-option label="最多浏览" value="views" />
                      <el-option label="最多点赞" value="likes" />
                      <el-option label="评分最高" value="rating" />
                    </el-select>
                  </el-col>
                  <el-col :span="3">
                    <el-select v-model="filterStatus" placeholder="状态筛选">
                      <el-option label="全部" value="" />
                      <el-option label="已发布" value="published" />
                      <el-option label="草稿" value="draft" />
                      <el-option label="待审核" value="pending" />
                      <el-option label="已拒绝" value="rejected" />
                    </el-select>
                  </el-col>
                  <el-col :span="3">
                    <el-select v-model="filterCategory" placeholder="分类筛选">
                      <el-option label="全部分类" value="" />
                      <el-option label="系统运维" value="系统运维" />
                      <el-option label="数据库管理" value="数据库管理" />
                      <el-option label="网络安全" value="网络安全" />
                      <el-option label="故障排查" value="故障排查" />
                    </el-select>
                  </el-col>
                  <el-col :span="3">
                    <el-button @click="resetFilters">重置筛选</el-button>
                  </el-col>
                </el-row>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus, Upload, Download, Refresh, Document, View, Clock, Star,
  TrendCharts, Top, Minus, Folder, Edit, Search
} from '@element-plus/icons-vue'

// 响应式数据
const activeTab = ref('overview')
const searchText = ref('')
const sortBy = ref('latest')
const filterStatus = ref('')
const filterCategory = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const showCreateDialog = ref(false)
const showCategoryDialog = ref(false)
const showTagDialog = ref(false)

// 知识库统计数据
const knowledgeStats = ref({
  totalDocs: 156,
  totalViews: 12500,
  pendingReview: 8,
  avgRating: 4.6
})

// 分类树数据
const categoryTree = ref([
  {
    id: 1,
    name: '全部分类',
    count: 156,
    children: [
      { id: 2, name: '系统运维', count: 45 },
      { id: 3, name: '数据库管理', count: 32 },
      { id: 4, name: '网络安全', count: 28 },
      { id: 5, name: '故障排查', count: 35 },
      { id: 6, name: '开发工具', count: 16 }
    ]
  }
])

// 热门标签
const popularTags = ref([
  { name: 'Linux', count: 45, heat: 'high' },
  { name: 'MySQL', count: 32, heat: 'high' },
  { name: 'Docker', count: 28, heat: 'medium' },
  { name: 'Nginx', count: 25, heat: 'medium' },
  { name: 'Redis', count: 22, heat: 'medium' },
  { name: 'Python', count: 18, heat: 'low' },
  { name: 'Shell', count: 15, heat: 'low' },
  { name: 'Git', count: 12, heat: 'low' }
])

// 最近活动
const recentActivities = ref([
  {
    id: 1,
    type: 'create',
    description: '张工程师创建了《Linux性能调优指南》',
    time: '2小时前'
  },
  {
    id: 2,
    type: 'update',
    description: '李工程师更新了《MySQL备份策略》',
    time: '4小时前'
  },
  {
    id: 3,
    type: 'review',
    description: '王工程师审核通过了《Docker部署实践》',
    time: '6小时前'
  }
])

// 工具方法
const getTagType = (heat) => {
  switch (heat) {
    case 'high': return 'danger'
    case 'medium': return 'warning'
    case 'low': return ''
    default: return ''
  }
}

// 事件处理方法
const importKnowledge = () => {
  ElMessage.info('批量导入功能')
}

const exportKnowledge = () => {
  ElMessage.success('知识库导出成功')
}

const refreshKnowledge = () => {
  ElMessage.success('知识库已刷新')
}

const selectCategory = (data) => {
  ElMessage.info(`选择分类: ${data.name}`)
}

const searchByTag = (tagName) => {
  searchText.value = tagName
  ElMessage.info(`搜索标签: ${tagName}`)
}

const searchKnowledge = () => {
  ElMessage.info(`搜索: ${searchText.value}`)
}

const resetFilters = () => {
  searchText.value = ''
  sortBy.value = 'latest'
  filterStatus.value = ''
  filterCategory.value = ''
}

// 组件挂载
onMounted(() => {
  console.log('知识库管理模块已加载')
})
</script>
