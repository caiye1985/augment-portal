<template>
  <PageLayout
    title="知识库管理"
    description="智能化知识管理系统，支持分类管理、审核流程和AI推荐"
    icon="Document"
  >
    <!-- 操作按钮 -->
    <template #actions>
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
      <el-button @click="refreshKnowledge">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in knowledgeStatsCards" :key="stat.label">
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

              <!-- 知识文档列表 -->
              <el-card class="list-card" style="margin-top: 20px;">
                <template #header>
                  <div class="card-header">
                    <span>知识文档</span>
                    <div class="header-actions">
                      <el-radio-group v-model="viewMode" size="small">
                        <el-radio-button label="list">列表</el-radio-button>
                        <el-radio-button label="card">卡片</el-radio-button>
                      </el-radio-group>
                    </div>
                  </div>
                </template>

                <!-- 列表视图 -->
                <div v-if="viewMode === 'list'" class="knowledge-table">
                  <el-table :data="filteredKnowledge" style="width: 100%">
                    <el-table-column prop="title" label="标题" min-width="200">
                      <template #default="{ row }">
                        <div class="doc-title-cell" @click="viewDocument(row)">
                          <div class="title-text">{{ row.title }}</div>
                          <div class="title-summary">{{ row.summary }}</div>
                        </div>
                      </template>
                    </el-table-column>
                    <el-table-column prop="category" label="分类" width="120">
                      <template #default="{ row }">
                        <el-tag size="small">{{ row.category }}</el-tag>
                      </template>
                    </el-table-column>
                    <el-table-column prop="status" label="状态" width="100">
                      <template #default="{ row }">
                        <el-tag :type="getStatusType(row.status)" size="small">
                          {{ getStatusText(row.status) }}
                        </el-tag>
                      </template>
                    </el-table-column>
                    <el-table-column prop="author" label="作者" width="120" />
                    <el-table-column prop="views" label="浏览量" width="100" sortable />
                    <el-table-column prop="likes" label="点赞" width="80" sortable />
                    <el-table-column prop="createdAt" label="创建时间" width="150" sortable />
                    <el-table-column label="操作" width="200" fixed="right">
                      <template #default="{ row }">
                        <el-button size="small" @click="viewDocument(row)">查看</el-button>
                        <el-button size="small" @click="editDocument(row)">编辑</el-button>
                        <el-dropdown @click.stop trigger="click">
                          <el-button size="small">
                            更多<el-icon class="el-icon--right"><ArrowDown /></el-icon>
                          </el-button>
                          <template #dropdown>
                            <el-dropdown-menu>
                              <el-dropdown-item @click="reviewDocument(row)" v-if="row.status === 'pending'">审核</el-dropdown-item>
                              <el-dropdown-item @click="publishDocument(row)" v-if="row.status === 'draft'">发布</el-dropdown-item>
                              <el-dropdown-item @click="duplicateDocument(row)">复制</el-dropdown-item>
                              <el-dropdown-item @click="exportDocument(row)">导出</el-dropdown-item>
                              <el-dropdown-item divided @click="deleteDocument(row)">删除</el-dropdown-item>
                            </el-dropdown-menu>
                          </template>
                        </el-dropdown>
                      </template>
                    </el-table-column>
                  </el-table>
                </div>

                <!-- 卡片视图 -->
                <div v-else class="knowledge-cards">
                  <div
                    v-for="doc in filteredKnowledge"
                    :key="doc.id"
                    class="knowledge-card"
                    @click="viewDocument(doc)"
                  >
                    <div class="card-header">
                      <h3 class="card-title">{{ doc.title }}</h3>
                      <el-tag :type="getStatusType(doc.status)" size="small">
                        {{ getStatusText(doc.status) }}
                      </el-tag>
                    </div>

                    <div class="card-meta">
                      <el-tag size="small">{{ doc.category }}</el-tag>
                      <span class="card-author">{{ doc.author }}</span>
                      <span class="card-date">{{ doc.createdAt }}</span>
                    </div>

                    <div class="card-summary">{{ doc.summary }}</div>

                    <div class="card-tags">
                      <el-tag
                        v-for="tag in doc.tags"
                        :key="tag"
                        size="small"
                        type="info"
                        class="tag-item"
                      >
                        {{ tag }}
                      </el-tag>
                    </div>

                    <div class="card-stats">
                      <div class="stats-left">
                        <span class="stat-item">
                          <el-icon><View /></el-icon>
                          {{ doc.views }}
                        </span>
                        <span class="stat-item">
                          <el-icon><Star /></el-icon>
                          {{ doc.likes }}
                        </span>
                        <span class="stat-item">
                          <el-icon><ChatDotRound /></el-icon>
                          {{ doc.comments || 0 }}
                        </span>
                      </div>
                      <div class="stats-right">
                        <el-button size="small" @click.stop="editDocument(doc)">编辑</el-button>
                        <el-button size="small" type="primary" @click.stop="viewDocument(doc)">查看</el-button>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- 分页 -->
                <div class="pagination-wrapper">
                  <el-pagination
                    v-model:current-page="currentPage"
                    v-model:page-size="pageSize"
                    :page-sizes="[10, 20, 50]"
                    :total="totalKnowledge"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handleCurrentChange"
                  />
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>

      <!-- 分类管理 -->
      <el-tab-pane label="分类管理" name="category">
        <div class="tab-content">
          <div class="toolbar">
            <div class="toolbar-left">
              <el-button type="primary" @click="showAddCategoryDialog = true">
                <el-icon><Plus /></el-icon>
                新建分类
              </el-button>
              <el-button @click="expandAllCategories">
                <el-icon><Expand /></el-icon>
                展开全部
              </el-button>
              <el-button @click="collapseAllCategories">
                <el-icon><Fold /></el-icon>
                收起全部
              </el-button>
            </div>
            <div class="toolbar-right">
              <el-button @click="refreshCategories">
                <el-icon><Refresh /></el-icon>
                刷新
              </el-button>
            </div>
          </div>

          <el-card class="category-management-card">
            <el-table
              :data="categoryList"
              style="width: 100%"
              row-key="id"
              :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
            >
              <el-table-column prop="name" label="分类名称" min-width="200">
                <template #default="{ row }">
                  <div class="category-name-cell">
                    <el-icon><Folder /></el-icon>
                    <span>{{ row.name }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="description" label="描述" min-width="200" />
              <el-table-column prop="count" label="文档数量" width="120" />
              <el-table-column prop="sort" label="排序" width="100" />
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 'active' ? 'success' : 'info'" size="small">
                    {{ row.status === 'active' ? '启用' : '禁用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="createdAt" label="创建时间" width="150" />
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button size="small" @click="editCategory(row)">编辑</el-button>
                  <el-button size="small" @click="addSubCategory(row)">添加子分类</el-button>
                  <el-button size="small" type="danger" @click="deleteCategory(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>

      <!-- 审核管理 -->
      <el-tab-pane label="审核管理" name="review">
        <div class="tab-content">
          <div class="toolbar">
            <div class="toolbar-left">
              <el-button type="primary" @click="batchApprove" :disabled="selectedReviews.length === 0">
                <el-icon><CircleCheck /></el-icon>
                批量通过
              </el-button>
              <el-button type="danger" @click="batchReject" :disabled="selectedReviews.length === 0">
                <el-icon><CircleClose /></el-icon>
                批量拒绝
              </el-button>
            </div>
            <div class="toolbar-right">
              <el-select v-model="reviewFilter" placeholder="审核状态">
                <el-option label="全部" value="" />
                <el-option label="待审核" value="pending" />
                <el-option label="已通过" value="approved" />
                <el-option label="已拒绝" value="rejected" />
              </el-select>
            </div>
          </div>

          <el-card class="review-card">
            <el-table
              :data="reviewList"
              style="width: 100%"
              @selection-change="handleReviewSelectionChange"
            >
              <el-table-column type="selection" width="55" />
              <el-table-column prop="title" label="文档标题" min-width="200">
                <template #default="{ row }">
                  <div class="doc-title-cell" @click="viewReviewDocument(row)">
                    <div class="title-text">{{ row.title }}</div>
                    <div class="title-summary">{{ row.summary }}</div>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="author" label="作者" width="120" />
              <el-table-column prop="category" label="分类" width="120">
                <template #default="{ row }">
                  <el-tag size="small">{{ row.category }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="submitTime" label="提交时间" width="150" />
              <el-table-column prop="status" label="审核状态" width="120">
                <template #default="{ row }">
                  <el-tag :type="getReviewStatusType(row.status)" size="small">
                    {{ getReviewStatusText(row.status) }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="reviewer" label="审核人" width="120" />
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button size="small" @click="viewReviewDocument(row)">查看</el-button>
                  <el-button size="small" type="success" @click="approveDocument(row)" v-if="row.status === 'pending'">通过</el-button>
                  <el-button size="small" type="danger" @click="rejectDocument(row)" v-if="row.status === 'pending'">拒绝</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 文档详情查看对话框 -->
    <el-dialog
      v-model="showDocumentDetail"
      :title="selectedDocument?.title"
      width="80%"
      class="document-detail-dialog"
    >
      <div v-if="selectedDocument" class="document-detail">
        <!-- 文档头部信息 -->
        <div class="document-header">
          <div class="document-meta">
            <div class="meta-item">
              <span class="meta-label">作者：</span>
              <span class="meta-value">{{ selectedDocument.author }}</span>
            </div>
            <div class="meta-item">
              <span class="meta-label">分类：</span>
              <el-tag size="small">{{ selectedDocument.category }}</el-tag>
            </div>
            <div class="meta-item">
              <span class="meta-label">状态：</span>
              <el-tag :type="getStatusType(selectedDocument.status)" size="small">
                {{ getStatusText(selectedDocument.status) }}
              </el-tag>
            </div>
            <div class="meta-item" v-if="selectedDocument.scope">
              <span class="meta-label">范围：</span>
              <el-tag :type="selectedDocument.scope === 'global' ? 'warning' : 'primary'" size="small">
                {{ selectedDocument.scope === 'global' ? '全局知识库' : '租户知识库' }}
              </el-tag>
            </div>
          </div>
          <div class="document-stats">
            <div class="stat-item">
              <el-icon><View /></el-icon>
              <span>{{ selectedDocument.views }}</span>
            </div>
            <div class="stat-item">
              <el-icon><Star /></el-icon>
              <span>{{ selectedDocument.likes }}</span>
            </div>
            <div class="stat-item">
              <el-icon><ChatDotRound /></el-icon>
              <span>{{ selectedDocument.comments }}</span>
            </div>
          </div>
        </div>

        <!-- 文档标签 -->
        <div class="document-tags" v-if="selectedDocument.tags">
          <el-tag
            v-for="tag in selectedDocument.tags"
            :key="tag"
            size="small"
            class="tag-item"
          >
            {{ tag }}
          </el-tag>
        </div>

        <!-- 文档内容 -->
        <div class="document-content">
          <div class="content-summary">
            <h4>摘要</h4>
            <p>{{ selectedDocument.summary }}</p>
          </div>
          <div class="content-body">
            <h4>正文</h4>
            <div class="markdown-content" v-html="formatMarkdown(selectedDocument.content)"></div>
          </div>
        </div>

        <!-- 文档操作 -->
        <div class="document-actions">
          <el-button @click="likeDocument(selectedDocument)">
            <el-icon><Star /></el-icon>
            点赞 ({{ selectedDocument.likes }})
          </el-button>
          <el-button @click="shareDocument(selectedDocument)">
            <el-icon><Share /></el-icon>
            分享
          </el-button>
          <el-button @click="downloadDocument(selectedDocument)">
            <el-icon><Download /></el-icon>
            下载
          </el-button>
          <el-button type="primary" @click="editDocument(selectedDocument)" v-if="canEditDocument(selectedDocument)">
            <el-icon><Edit /></el-icon>
            编辑
          </el-button>
        </div>
      </div>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { OfficeBuilding } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'
import {
  Plus, Upload, Download, Refresh, Document, View, Clock, Star,
  TrendCharts, Top, Minus, Folder, Edit, Search, ArrowDown,
  Expand, Fold, CircleCheck, CircleClose, ChatDotRound
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

const authStore = useAuthStore()

// 响应式数据
const activeTab = ref('overview')
const knowledgeScope = ref('tenant') // 'tenant' | 'global'
const showDocumentDetail = ref(false)
const selectedDocument = ref(null)
const searchText = ref('')
const sortBy = ref('latest')
const filterStatus = ref('')
const filterCategory = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const viewMode = ref('list')
const showCreateDialog = ref(false)
const showCategoryDialog = ref(false)
const showTagDialog = ref(false)
const showAddCategoryDialog = ref(false)
const selectedReviews = ref([])
const reviewFilter = ref('')

// 知识库统计数据
const knowledgeStats = ref({
  totalDocs: 156,
  totalViews: 12500,
  pendingReview: 8,
  avgRating: 4.6
})

// 统计卡片数据
const knowledgeStatsCards = computed(() => [
  {
    label: '文档总数',
    value: knowledgeStats.value.totalDocs,
    icon: 'Document',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 18.5
  },
  {
    label: '总浏览量',
    value: knowledgeStats.value.totalViews.toLocaleString(),
    icon: 'View',
    color: 'var(--el-color-success, #10b981)',
    trend: 25.3
  },
  {
    label: '待审核',
    value: knowledgeStats.value.pendingReview,
    icon: 'Clock',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -12.7
  },
  {
    label: '平均评分',
    value: knowledgeStats.value.avgRating,
    icon: 'Star',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 4.2
  }
])

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

// 知识文档数据
const knowledgeList = ref([
  {
    id: 1,
    title: 'Linux服务器性能调优完整指南',
    summary: '详细介绍Linux服务器性能监控、分析和优化的最佳实践，包括CPU、内存、磁盘和网络优化技巧。',
    content: `# Linux服务器性能调优完整指南

## 概述
Linux服务器性能调优是运维工程师必备的核心技能。本指南将从CPU、内存、磁盘I/O、网络等多个维度，详细介绍性能监控、分析和优化的最佳实践。

## 1. CPU性能优化

### 1.1 CPU使用率监控
使用以下命令监控CPU使用情况：
\`\`\`bash
# 实时监控CPU使用率
top
htop

# 查看CPU详细信息
cat /proc/cpuinfo

# 监控CPU负载
uptime
\`\`\`

### 1.2 CPU优化策略
- 调整进程优先级
- 优化CPU调度策略
- 合理配置CPU亲和性

## 2. 内存性能优化

### 2.1 内存监控
\`\`\`bash
# 查看内存使用情况
free -h
cat /proc/meminfo

# 监控内存使用详情
vmstat 1
\`\`\`

### 2.2 内存优化
- 调整swap分区大小
- 优化内存分配策略
- 清理内存缓存

## 3. 磁盘I/O优化

### 3.1 磁盘性能监控
\`\`\`bash
# 监控磁盘I/O
iostat -x 1
iotop
\`\`\`

### 3.2 磁盘优化策略
- 选择合适的文件系统
- 调整I/O调度器
- 优化磁盘分区

## 4. 网络性能优化

### 4.1 网络监控
\`\`\`bash
# 监控网络连接
netstat -i
ss -tuln
\`\`\`

### 4.2 网络优化
- 调整TCP参数
- 优化网络缓冲区
- 配置网络队列

## 总结
性能调优是一个持续的过程，需要根据实际业务场景进行针对性优化。建议定期监控系统性能指标，及时发现和解决性能瓶颈。`,
    category: '系统运维',
    status: 'published',
    author: '张工程师',
    tenantId: '1', // 阿里巴巴集团
    scope: 'tenant', // 租户级别
    views: 1250,
    likes: 89,
    comments: 23,
    tags: ['Linux', '性能优化', '服务器'],
    createdAt: '2024-01-10 14:30',
    updatedAt: '2024-01-15 09:20'
  },
  {
    id: 2,
    title: 'MySQL数据库备份与恢复策略',
    summary: '全面介绍MySQL数据库的备份策略、恢复方法和最佳实践，确保数据安全和业务连续性。',
    content: `# MySQL数据库备份与恢复策略

## 备份策略概述
数据库备份是保障数据安全的重要手段，本文档详细介绍MySQL数据库的备份策略和恢复方法。

## 1. 备份类型

### 1.1 物理备份
- 冷备份：停止MySQL服务进行备份
- 热备份：在线备份，不影响业务

### 1.2 逻辑备份
- mysqldump：最常用的逻辑备份工具
- mysqlpump：MySQL 5.7+的并行备份工具

## 2. 备份实践

### 2.1 全量备份
\`\`\`bash
# 使用mysqldump进行全量备份
mysqldump -u root -p --all-databases > full_backup.sql

# 备份单个数据库
mysqldump -u root -p database_name > db_backup.sql
\`\`\`

### 2.2 增量备份
\`\`\`bash
# 开启二进制日志
log-bin = mysql-bin

# 备份二进制日志
mysqlbinlog mysql-bin.000001 > binlog_backup.sql
\`\`\`

## 3. 恢复策略

### 3.1 全量恢复
\`\`\`bash
# 恢复全量备份
mysql -u root -p < full_backup.sql
\`\`\`

### 3.2 增量恢复
\`\`\`bash
# 恢复二进制日志
mysql -u root -p < binlog_backup.sql
\`\`\`

## 4. 自动化备份脚本
建议使用cron定时任务实现自动化备份，确保备份的及时性和可靠性。`,
    category: '数据库管理',
    status: 'published',
    author: '李工程师',
    tenantId: '1', // 阿里巴巴集团
    scope: 'tenant',
    views: 980,
    likes: 67,
    comments: 15,
    tags: ['MySQL', '备份', '恢复'],
    createdAt: '2024-01-08 16:45',
    updatedAt: '2024-01-12 11:30'
  },
  {
    id: 3,
    title: 'Docker容器化部署实践',
    summary: 'Docker容器技术在生产环境中的应用实践，包括镜像构建、容器编排和监控管理。',
    content: `# Docker容器化部署实践

## Docker基础概念
Docker是一个开源的容器化平台，可以将应用程序及其依赖打包成轻量级、可移植的容器。

## 1. 镜像构建最佳实践

### 1.1 Dockerfile优化
\`\`\`dockerfile
# 使用多阶段构建
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
\`\`\`

### 1.2 镜像优化技巧
- 使用.dockerignore文件
- 选择合适的基础镜像
- 减少镜像层数
- 清理不必要的文件

## 2. 容器编排

### 2.1 Docker Compose
\`\`\`yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: password
\`\`\`

### 2.2 Kubernetes部署
- Pod配置
- Service暴露
- Deployment管理
- ConfigMap配置

## 3. 监控和日志
- 容器资源监控
- 日志收集策略
- 健康检查配置`,
    category: '开发工具',
    status: 'pending',
    author: '王工程师',
    tenantId: '2', // 腾讯科技
    scope: 'tenant',
    views: 456,
    likes: 34,
    comments: 8,
    tags: ['Docker', '容器', '部署'],
    createdAt: '2024-01-15 10:20',
    updatedAt: '2024-01-15 10:20'
  },
  {
    id: 4,
    title: '网络安全防护体系建设',
    summary: '企业网络安全防护体系的规划、建设和管理，包括防火墙配置、入侵检测和安全审计。',
    content: '网络安全是企业IT基础设施的重要保障...',
    category: '网络安全',
    status: 'draft',
    author: '赵工程师',
    tenantId: null, // 全局知识库
    scope: 'global',
    views: 234,
    likes: 18,
    comments: 5,
    tags: ['网络安全', '防火墙', '入侵检测'],
    createdAt: '2024-01-14 09:15',
    updatedAt: '2024-01-15 14:30'
  },
  {
    id: 5,
    title: '故障排查方法论与实践',
    summary: '系统故障排查的方法论、工具使用和实际案例分析，提高故障处理效率和准确性。',
    content: '故障排查是运维工程师的核心技能...',
    category: '故障排查',
    status: 'published',
    author: '孙工程师',
    tenantId: null, // 全局知识库
    scope: 'global',
    views: 789,
    likes: 56,
    comments: 12,
    tags: ['故障排查', '监控', '日志分析'],
    createdAt: '2024-01-05 13:20',
    updatedAt: '2024-01-10 16:45'
  }
])

// 分类管理数据
const categoryList = ref([
  {
    id: 1,
    name: '系统运维',
    description: '服务器管理、系统监控、性能优化等相关知识',
    count: 45,
    sort: 1,
    status: 'active',
    createdAt: '2024-01-01 10:00',
    children: [
      {
        id: 11,
        name: 'Linux系统',
        description: 'Linux系统管理和配置',
        count: 25,
        sort: 1,
        status: 'active',
        createdAt: '2024-01-01 10:00'
      },
      {
        id: 12,
        name: 'Windows系统',
        description: 'Windows系统管理和配置',
        count: 20,
        sort: 2,
        status: 'active',
        createdAt: '2024-01-01 10:00'
      }
    ]
  },
  {
    id: 2,
    name: '数据库管理',
    description: '数据库安装、配置、优化和维护',
    count: 32,
    sort: 2,
    status: 'active',
    createdAt: '2024-01-01 10:00',
    children: [
      {
        id: 21,
        name: 'MySQL',
        description: 'MySQL数据库管理',
        count: 18,
        sort: 1,
        status: 'active',
        createdAt: '2024-01-01 10:00'
      },
      {
        id: 22,
        name: 'PostgreSQL',
        description: 'PostgreSQL数据库管理',
        count: 14,
        sort: 2,
        status: 'active',
        createdAt: '2024-01-01 10:00'
      }
    ]
  },
  {
    id: 3,
    name: '网络安全',
    description: '网络安全防护、漏洞修复、安全审计',
    count: 28,
    sort: 3,
    status: 'active',
    createdAt: '2024-01-01 10:00'
  }
])

// 审核列表数据
const reviewList = ref([
  {
    id: 1,
    title: 'Docker容器化部署实践',
    summary: 'Docker容器技术在生产环境中的应用实践',
    author: '王工程师',
    category: '开发工具',
    submitTime: '2024-01-15 10:20',
    status: 'pending',
    reviewer: '',
    reviewTime: ''
  },
  {
    id: 2,
    title: 'Kubernetes集群管理指南',
    summary: 'K8s集群的部署、配置和管理最佳实践',
    author: '陈工程师',
    category: '开发工具',
    submitTime: '2024-01-14 16:30',
    status: 'approved',
    reviewer: '管理员',
    reviewTime: '2024-01-15 09:15'
  },
  {
    id: 3,
    title: 'Redis缓存优化策略',
    summary: 'Redis缓存的配置优化和性能调优方法',
    author: '刘工程师',
    category: '数据库管理',
    submitTime: '2024-01-13 14:45',
    status: 'rejected',
    reviewer: '管理员',
    reviewTime: '2024-01-14 10:30'
  }
])

// 计算属性
const filteredKnowledge = computed(() => {
  let result = knowledgeList.value

  // 根据知识库范围筛选
  if (knowledgeScope.value === 'tenant') {
    // 租户知识库：只显示当前租户的文档
    const currentTenantId = authStore.currentTenant
    result = result.filter(doc => doc.scope === 'tenant' && doc.tenantId === currentTenantId)
  } else if (knowledgeScope.value === 'global') {
    // 全局知识库：只显示全局文档
    result = result.filter(doc => doc.scope === 'global')
  }

  if (searchText.value) {
    result = result.filter(doc =>
      doc.title.includes(searchText.value) ||
      doc.summary.includes(searchText.value) ||
      doc.tags.some(tag => tag.includes(searchText.value))
    )
  }

  if (filterStatus.value) {
    result = result.filter(doc => doc.status === filterStatus.value)
  }

  if (filterCategory.value) {
    result = result.filter(doc => doc.category === filterCategory.value)
  }

  return result
})

const totalKnowledge = computed(() => filteredKnowledge.value.length)

// 工具方法
const getTagType = (heat) => {
  switch (heat) {
    case 'high': return 'danger'
    case 'medium': return 'warning'
    case 'low': return ''
    default: return ''
  }
}

const getStatusType = (status) => {
  switch (status) {
    case 'published': return 'success'
    case 'pending': return 'warning'
    case 'draft': return 'info'
    case 'rejected': return 'danger'
    default: return ''
  }
}

const getStatusText = (status) => {
  switch (status) {
    case 'published': return '已发布'
    case 'pending': return '待审核'
    case 'draft': return '草稿'
    case 'rejected': return '已拒绝'
    default: return '未知'
  }
}

const getReviewStatusType = (status) => {
  switch (status) {
    case 'pending': return 'warning'
    case 'approved': return 'success'
    case 'rejected': return 'danger'
    default: return ''
  }
}

const getReviewStatusText = (status) => {
  switch (status) {
    case 'pending': return '待审核'
    case 'approved': return '已通过'
    case 'rejected': return '已拒绝'
    default: return '未知'
  }
}

// 基础事件处理方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const importKnowledge = () => {
  ElMessage.info('批量导入功能开发中...')
}

const exportKnowledge = () => {
  ElMessage.success('知识库导出成功')
}

const refreshKnowledge = () => {
  ElMessage.success('知识库已刷新')
}

const selectCategory = (data) => {
  filterCategory.value = data.name === '全部分类' ? '' : data.name
  ElMessage.info(`选择分类: ${data.name}`)
}

const searchByTag = (tagName) => {
  searchText.value = tagName
  searchKnowledge()
}

const searchKnowledge = () => {
  if (searchText.value) {
    ElMessage.info(`搜索: ${searchText.value}`)
  }
}

const resetFilters = () => {
  searchText.value = ''
  sortBy.value = 'latest'
  filterStatus.value = ''
  filterCategory.value = ''
  ElMessage.success('筛选条件已重置')
}

const handleSizeChange = (size) => {
  pageSize.value = size
}

const handleCurrentChange = (page) => {
  currentPage.value = page
}

// 知识库范围切换
const onScopeChange = (scope) => {
  ElMessage.success(`已切换到${scope === 'global' ? '全局知识库' : '租户知识库'}`)
}

// 知识文档操作方法
const viewDocument = (doc) => {
  selectedDocument.value = doc
  showDocumentDetail.value = true
}

// 格式化Markdown内容
const formatMarkdown = (content) => {
  // 简单的Markdown转HTML处理
  return content
    .replace(/^# (.*$)/gim, '<h1>$1</h1>')
    .replace(/^## (.*$)/gim, '<h2>$1</h2>')
    .replace(/^### (.*$)/gim, '<h3>$1</h3>')
    .replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/gim, '<em>$1</em>')
    .replace(/`([^`]*)`/gim, '<code>$1</code>')
    .replace(/\n/gim, '<br>')
}

// 检查是否可以编辑文档
const canEditDocument = (doc) => {
  // 系统管理员可以编辑所有文档
  if (authStore.isSystemAdmin) return true

  // 租户管理员可以编辑本租户的文档
  if (authStore.isTenantAdmin && doc.tenantId === authStore.currentTenant) return true

  // 文档作者可以编辑自己的文档
  if (doc.author === authStore.user?.name) return true

  return false
}

// 文档操作方法
const likeDocument = (doc) => {
  doc.likes += 1
  ElMessage.success('点赞成功')
}

const shareDocument = (doc) => {
  // 复制分享链接到剪贴板
  const shareUrl = `${window.location.origin}/knowledge/${doc.id}`
  navigator.clipboard.writeText(shareUrl).then(() => {
    ElMessage.success('分享链接已复制到剪贴板')
  }).catch(() => {
    ElMessage.error('复制失败，请手动复制链接')
  })
}

const downloadDocument = (doc) => {
  // 创建下载链接
  const content = `# ${doc.title}\n\n${doc.summary}\n\n${doc.content}`
  const blob = new Blob([content], { type: 'text/markdown' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `${doc.title}.md`
  a.click()
  URL.revokeObjectURL(url)
  ElMessage.success('文档下载成功')
}

const editDocument = (doc) => {
  ElMessage.info(`编辑文档: ${doc.title}`)
}

const reviewDocument = (doc) => {
  ElMessage.info(`审核文档: ${doc.title}`)
}

const publishDocument = (doc) => {
  ElMessage.success(`发布文档: ${doc.title}`)
}

const duplicateDocument = (doc) => {
  ElMessage.info(`复制文档: ${doc.title}`)
}

const exportDocument = (doc) => {
  ElMessage.success(`导出文档: ${doc.title}`)
}

const deleteDocument = async (doc) => {
  try {
    await ElMessageBox.confirm(`确定要删除文档 "${doc.title}" 吗？`, '确认删除', {
      type: 'warning'
    })
    ElMessage.success('文档已删除')
  } catch (error) {
    // 用户取消
  }
}

// 分类管理方法
const expandAllCategories = () => {
  ElMessage.info('展开全部分类')
}

const collapseAllCategories = () => {
  ElMessage.info('收起全部分类')
}

const refreshCategories = () => {
  ElMessage.success('分类列表已刷新')
}

const editCategory = (category) => {
  ElMessage.info(`编辑分类: ${category.name}`)
}

const addSubCategory = (category) => {
  ElMessage.info(`为 "${category.name}" 添加子分类`)
}

const deleteCategory = async (category) => {
  try {
    await ElMessageBox.confirm(`确定要删除分类 "${category.name}" 吗？`, '确认删除', {
      type: 'warning'
    })
    ElMessage.success('分类已删除')
  } catch (error) {
    // 用户取消
  }
}

// 审核管理方法
const handleReviewSelectionChange = (selection) => {
  selectedReviews.value = selection
}

const batchApprove = async () => {
  try {
    await ElMessageBox.confirm(`确定要批量通过 ${selectedReviews.value.length} 个文档吗？`, '确认操作', {
      type: 'warning'
    })
    ElMessage.success(`已批量通过 ${selectedReviews.value.length} 个文档`)
    selectedReviews.value = []
  } catch (error) {
    // 用户取消
  }
}

const batchReject = async () => {
  try {
    await ElMessageBox.confirm(`确定要批量拒绝 ${selectedReviews.value.length} 个文档吗？`, '确认操作', {
      type: 'warning'
    })
    ElMessage.success(`已批量拒绝 ${selectedReviews.value.length} 个文档`)
    selectedReviews.value = []
  } catch (error) {
    // 用户取消
  }
}

const viewReviewDocument = (doc) => {
  ElMessage.info(`查看待审核文档: ${doc.title}`)
}

const approveDocument = async (doc) => {
  try {
    await ElMessageBox.confirm(`确定要通过文档 "${doc.title}" 的审核吗？`, '确认通过', {
      type: 'success'
    })
    doc.status = 'approved'
    doc.reviewer = '管理员'
    doc.reviewTime = new Date().toLocaleString()
    ElMessage.success('文档审核通过')
  } catch (error) {
    // 用户取消
  }
}

const rejectDocument = async (doc) => {
  try {
    const { value: reason } = await ElMessageBox.prompt('请输入拒绝原因', '拒绝审核', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputPattern: /.+/,
      inputErrorMessage: '请输入拒绝原因'
    })

    doc.status = 'rejected'
    doc.reviewer = '管理员'
    doc.reviewTime = new Date().toLocaleString()
    doc.rejectReason = reason
    ElMessage.success('文档审核已拒绝')
  } catch (error) {
    // 用户取消
  }
}

// 组件挂载
onMounted(() => {
  console.log('知识库管理模块已加载')
})
</script>

<style scoped>
.knowledge-demo {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 28px;
  color: #303133;
  margin: 0 0 8px 0;
}

.page-header p {
  color: #606266;
  margin: 0;
  font-size: 14px;
}

.demo-tabs {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.tab-content {
  padding: 20px;
}

/* 工具栏样式 */
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.toolbar-left {
  display: flex;
  gap: 12px;
}

.toolbar-right {
  display: flex;
  gap: 12px;
}


/* 卡片样式 */
.category-card,
.tags-card,
.activity-card,
.filter-card,
.list-card,
.category-management-card,
.review-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* 分类树样式 */
.category-tree {
  margin-top: 16px;
}

.category-node {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}

.category-name {
  flex: 1;
  font-size: 14px;
}

.category-badge {
  margin-left: auto;
}

/* 标签云样式 */
.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}

.tag-item {
  cursor: pointer;
  transition: all 0.3s ease;
}

.tag-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

/* 活动列表样式 */
.activity-list {
  margin-top: 16px;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background-color: #f5f7fa;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.activity-content {
  flex: 1;
}

.activity-text {
  font-size: 14px;
  color: #303133;
  margin-bottom: 4px;
}

.activity-time {
  font-size: 12px;
  color: #909399;
}

/* 知识文档列表样式 */
.knowledge-table {
  margin-top: 16px;
}

.doc-title-cell {
  cursor: pointer;
}

.title-text {
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.title-summary {
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}

/* 知识卡片样式 */
.knowledge-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
  margin-top: 16px;
}

.knowledge-card {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 20px;
  background: white;
  cursor: pointer;
  transition: all 0.3s ease;
}

.knowledge-card:hover {
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.15);
  transform: translateY(-2px);
}

.card-title {
  font-size: 16px;
  font-weight: 500;
  color: #303133;
  margin: 0 0 8px 0;
  line-height: 1.4;
}

.card-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
}

.card-author,
.card-date {
  font-size: 12px;
  color: #909399;
}

.card-summary {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
  margin-bottom: 16px;
}

.card-tags {
  margin-bottom: 16px;
}

.card-tags .tag-item {
  margin-right: 8px;
  margin-bottom: 4px;
}

.card-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stats-left {
  display: flex;
  gap: 16px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #909399;
}

.stats-right {
  display: flex;
  gap: 8px;
}

/* 分页样式 */
.pagination-wrapper {
  margin-top: 20px;
  text-align: center;
}

/* 分类管理样式 */
.category-name-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 审核管理样式 */
.doc-title-cell {
  cursor: pointer;
}

.doc-title-cell:hover .title-text {
  color: #409eff;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .knowledge-demo {
    padding: 12px;
  }

  .toolbar {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }

  .stats-row .el-col {
    margin-bottom: 12px;
  }

  .knowledge-cards {
    grid-template-columns: 1fr;
  }

  .card-stats {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }

  .stats-left {
    justify-content: space-around;
  }
}

/* 动画效果 */
.knowledge-card,
.tag-item,
.activity-item {
  transition: all 0.3s ease;
}

.knowledge-card:hover {
  transform: translateY(-4px);
}

.tag-item:hover {
  transform: scale(1.05);
}

/* 状态标签颜色 */
.el-tag.el-tag--success {
  background-color: #f0f9ff;
  border-color: #67c23a;
  color: #67c23a;
}

.el-tag.el-tag--warning {
  background-color: #fdf6ec;
  border-color: #e6a23c;
  color: #e6a23c;
}

.el-tag.el-tag--danger {
  background-color: #fef0f0;
  border-color: #f56c6c;
  color: #f56c6c;
}

.el-tag.el-tag--info {
  background-color: #f4f4f5;
  border-color: #909399;
  color: #909399;
}

/* 文档详情对话框样式 */
.document-detail-dialog .el-dialog__body {
  padding: 20px;
  max-height: 70vh;
  overflow-y: auto;
}

.document-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.document-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding-bottom: 15px;
  border-bottom: 1px solid #ebeef5;
}

.document-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
}

.meta-label {
  color: #909399;
  font-weight: 500;
}

.meta-value {
  color: #303133;
}

.document-stats {
  display: flex;
  gap: 15px;
}

.document-stats .stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #909399;
  font-size: 14px;
}

.document-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding: 15px 0;
  border-bottom: 1px solid #ebeef5;
}

.document-content {
  flex: 1;
}

.content-summary,
.content-body {
  margin-bottom: 20px;
}

.content-summary h4,
.content-body h4 {
  margin: 0 0 10px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.content-summary p {
  margin: 0;
  color: #606266;
  line-height: 1.6;
}

.markdown-content {
  color: #303133;
  line-height: 1.8;
  font-size: 14px;
}

.markdown-content h1,
.markdown-content h2,
.markdown-content h3 {
  margin: 20px 0 10px 0;
  color: #2c3e50;
}

.markdown-content h1 {
  font-size: 24px;
  border-bottom: 2px solid #ebeef5;
  padding-bottom: 10px;
}

.markdown-content h2 {
  font-size: 20px;
}

.markdown-content h3 {
  font-size: 18px;
}

.markdown-content pre {
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  padding: 15px;
  overflow-x: auto;
  margin: 15px 0;
}

.markdown-content code {
  background: #f1f3f4;
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 13px;
}

.markdown-content pre code {
  background: none;
  padding: 0;
}

.document-actions {
  display: flex;
  gap: 10px;
  padding-top: 15px;
  border-top: 1px solid #ebeef5;
  justify-content: flex-end;
}

/* 范围切换器样式 */
.scope-switcher {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.1);
  padding: 8px 12px;
  border-radius: 6px;
  backdrop-filter: blur(10px);
}

.switcher-label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.9);
  white-space: nowrap;
}

.tenant-info {
  display: flex;
  align-items: center;
}
</style>
