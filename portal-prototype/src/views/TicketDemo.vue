<template>
  <PageLayout
    title="工单管理"
    description="智能化工单管理系统，集成AI分析和知识推荐"
    icon="Tickets"
    :tags="[
      { text: 'AI增强', type: 'success' },
      { text: '智能派单', type: 'warning' }
    ]"
    :page-actions="ticketActions"
    :show-page-info="true"
    @page-action="handlePageAction"
  >

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in ticketStatsCards" :key="stat.label">
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
      <!-- 工单列表 -->
      <el-tab-pane label="工单列表" name="list">
        <div class="tab-content">

          <!-- 筛选和搜索 -->
          <el-card class="filter-card">
            <el-row :gutter="16">
              <el-col :span="6">
                <el-input
                  v-model="searchText"
                  placeholder="搜索工单标题、ID或描述"
                  clearable
                >
                  <template #prefix>
                    <el-icon><Search /></el-icon>
                  </template>
                </el-input>
              </el-col>
              <el-col :span="3">
                <el-select v-model="filterStatus" placeholder="状态筛选" clearable>
                  <el-option label="全部" value="" />
                  <el-option label="待分配" value="待分配" />
                  <el-option label="处理中" value="处理中" />
                  <el-option label="待验收" value="待验收" />
                  <el-option label="已完成" value="已完成" />
                  <el-option label="已关闭" value="已关闭" />
                </el-select>
              </el-col>
              <el-col :span="3">
                <el-select v-model="filterPriority" placeholder="优先级筛选" clearable>
                  <el-option label="全部" value="" />
                  <el-option label="紧急" value="紧急" />
                  <el-option label="高" value="高" />
                  <el-option label="中" value="中" />
                  <el-option label="低" value="低" />
                </el-select>
              </el-col>
              <el-col :span="3">
                <el-select v-model="filterCategory" placeholder="分类筛选" clearable>
                  <el-option label="全部" value="" />
                  <el-option label="硬件故障" value="硬件故障" />
                  <el-option label="软件问题" value="软件问题" />
                  <el-option label="网络故障" value="网络故障" />
                  <el-option label="安全事件" value="安全事件" />
                  <el-option label="系统维护" value="系统维护" />
                </el-select>
              </el-col>
              <el-col :span="3">
                <el-select v-model="filterAssignee" placeholder="处理人筛选" clearable>
                  <el-option label="全部" value="" />
                  <el-option label="张工程师" value="张工程师" />
                  <el-option label="李工程师" value="李工程师" />
                  <el-option label="王工程师" value="王工程师" />
                  <el-option label="未分配" value="未分配" />
                </el-select>
              </el-col>
              <el-col :span="3">
                <el-select v-model="filterWorkflow" placeholder="工作流状态" clearable>
                  <el-option label="全部" value="" />
                  <el-option label="待审批" value="待审批" />
                  <el-option label="审批中" value="审批中" />
                  <el-option label="已审批" value="已审批" />
                  <el-option label="审批拒绝" value="审批拒绝" />
                </el-select>
              </el-col>
              <el-col :span="3">
                <el-button @click="resetFilters">重置筛选</el-button>
              </el-col>
            </el-row>
          </el-card>

          <!-- 工单列表 -->
          <el-card class="list-card">
            <template #header>
              <div class="card-header">
                <span>工单列表</span>
                <div class="header-actions">
                  <el-switch
                    v-model="showAIAnalysis"
                    active-text="AI分析"
                    inactive-text="关闭AI"
                  />
                </div>
              </div>
            </template>

            <el-table
              :data="filteredTickets"
              style="width: 100%"
              @row-click="viewTicketDetail"
              @selection-change="handleSelectionChange"
              row-style="cursor: pointer;"
              stripe
            >
              <el-table-column type="selection" width="55" />
              <el-table-column prop="id" label="工单号" width="120" sortable>
                <template #default="{ row }">
                  <div class="ticket-id">
                    <span>{{ row.id }}</span>
                    <el-icon v-if="row.hasAIAnalysis" color="#409eff" class="ai-icon">
                      <MagicStick />
                    </el-icon>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="title" label="标题" min-width="250">
                <template #default="{ row }">
                  <div class="ticket-title">
                    <div class="title-text">{{ row.title }}</div>
                    <div class="title-desc" v-if="row.description">{{ row.description.substring(0, 50) }}...</div>
                  </div>
                </template>
              </el-table-column>
              <el-table-column prop="priority" label="优先级" width="100" sortable>
                <template #default="{ row }">
                  <el-tag :type="getPriorityType(row.priority)" size="small">
                    {{ row.priority }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="100" sortable>
                <template #default="{ row }">
                  <el-tag :type="getStatusType(row.status)" size="small">
                    {{ row.status }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="tenant" label="租户" width="120">
                <template #default="{ row }">
                  <el-tag type="primary" size="small">{{ row.tenant }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="workflowStatus" label="工作流" width="100">
                <template #default="{ row }">
                  <el-tag :type="getWorkflowType(row.workflowStatus)" size="small">
                    {{ row.workflowStatus }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="category" label="分类" width="120" />
              <el-table-column prop="assignee" label="处理人" width="120">
                <template #default="{ row }">
                  <div class="assignee-info" v-if="row.assignee">
                    <el-avatar :size="24" :src="row.assigneeAvatar">{{ row.assignee.charAt(0) }}</el-avatar>
                    <span class="assignee-name">{{ row.assignee }}</span>
                  </div>
                  <span v-else class="unassigned">未分配</span>
                </template>
              </el-table-column>
              <el-table-column prop="createdAt" label="创建时间" width="150" sortable />
              <el-table-column label="SLA状态" width="120">
                <template #default="{ row }">
                  <div class="sla-status">
                    <el-progress
                      :percentage="row.slaProgress"
                      :color="getSLAColor(row.slaProgress)"
                      :stroke-width="6"
                      :show-text="false"
                    />
                    <span class="sla-text">{{ row.slaRemaining }}</span>
                  </div>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="200" fixed="right">
                <template #default="{ row }">
                  <el-button size="small" @click.stop="viewTicketDetail(row)">详情</el-button>
                  <el-button size="small" @click.stop="editTicket(row)">编辑</el-button>
                  <el-dropdown @click.stop trigger="click">
                    <el-button size="small">
                      更多<el-icon class="el-icon--right"><arrow-down /></el-icon>
                    </el-button>
                    <template #dropdown>
                      <el-dropdown-menu>
                        <el-dropdown-item @click="assignTicket(row)">分配</el-dropdown-item>
                        <el-dropdown-item @click="analyzeTicket(row)">AI分析</el-dropdown-item>
                        <el-dropdown-item @click="createKnowledge(row)">转知识库</el-dropdown-item>
                        <el-dropdown-item @click="duplicateTicket(row)">复制</el-dropdown-item>
                        <el-dropdown-item divided @click="deleteTicket(row)">删除</el-dropdown-item>
                      </el-dropdown-menu>
                    </template>
                  </el-dropdown>
                </template>
              </el-table-column>
            </el-table>

            <!-- 分页 -->
            <div class="pagination-wrapper">
              <el-pagination
                v-model:current-page="currentPage"
                v-model:page-size="pageSize"
                :page-sizes="[10, 20, 50, 100]"
                :total="totalTickets"
                layout="total, sizes, prev, pager, next, jumper"
                @size-change="handleSizeChange"
                @current-change="handleCurrentChange"
              />
            </div>
          </el-card>
        </div>
      </el-tab-pane>

      <!-- 工单详情 -->
      <el-tab-pane label="工单详情" name="detail" v-if="selectedTicket">
        <div class="tab-content">
          <el-row :gutter="20">
            <!-- 左侧：工单信息 -->
            <el-col :span="16">
              <el-card class="detail-card">
                <template #header>
                  <div class="detail-header">
                    <div class="ticket-info">
                      <h3>{{ selectedTicket.title }}</h3>
                      <div class="ticket-meta">
                        <el-tag :type="getPriorityType(selectedTicket.priority)" size="small">
                          {{ selectedTicket.priority }}
                        </el-tag>
                        <el-tag :type="getStatusType(selectedTicket.status)" size="small">
                          {{ selectedTicket.status }}
                        </el-tag>
                        <span class="ticket-id">工单号: {{ selectedTicket.id }}</span>
                      </div>
                    </div>
                    <div class="detail-actions">
                      <el-button @click="editTicket(selectedTicket)">编辑</el-button>
                      <el-button type="primary" @click="analyzeTicket(selectedTicket)">AI分析</el-button>
                    </div>
                  </div>
                </template>

                <!-- 工单基本信息 -->
                <div class="ticket-details">
                  <el-descriptions :column="2" border>
                    <el-descriptions-item label="创建人">{{ selectedTicket.creator || selectedTicket.reporter }}</el-descriptions-item>
                    <el-descriptions-item label="处理人">{{ selectedTicket.assignee || '未分配' }}</el-descriptions-item>
                    <el-descriptions-item label="创建时间">{{ selectedTicket.createdAt }}</el-descriptions-item>
                    <el-descriptions-item label="更新时间">{{ selectedTicket.updatedAt }}</el-descriptions-item>
                    <el-descriptions-item label="问题分类">{{ selectedTicket.category }}</el-descriptions-item>
                    <el-descriptions-item label="SLA状态">
                      <el-progress
                        :percentage="selectedTicket.slaProgress || 75"
                        :color="getSLAColor(selectedTicket.slaProgress || 75)"
                        :stroke-width="6"
                      />
                    </el-descriptions-item>
                  </el-descriptions>

                  <div class="description-section">
                    <h4>问题描述</h4>
                    <div class="description-content">{{ selectedTicket.description }}</div>
                  </div>

                  <!-- 处理记录 -->
                  <div class="process-logs">
                    <h4>处理记录</h4>
                    <el-timeline>
                      <el-timeline-item
                        v-for="log in getProcessLogs(selectedTicket)"
                        :key="log.id"
                        :timestamp="log.timestamp"
                        :type="log.type"
                      >
                        <div class="log-content">
                          <div class="log-header">
                            <span class="log-operator">{{ log.operator }}</span>
                            <span class="log-action">{{ log.action }}</span>
                          </div>
                          <div class="log-description">{{ log.description }}</div>
                        </div>
                      </el-timeline-item>
                    </el-timeline>
                  </div>
                </div>
              </el-card>
            </el-col>

            <!-- 右侧：AI分析面板 -->
            <el-col :span="8">
              <el-card class="ai-panel">
                <template #header>
                  <div class="ai-header">
                    <el-icon color="#409eff"><MagicStick /></el-icon>
                    <span>AI智能分析</span>
                  </div>
                </template>

                <!-- AI分析结果 -->
                <div class="ai-content" v-if="aiAnalysisResult">
                  <div class="analysis-section">
                    <h5>问题分析</h5>
                    <div class="analysis-text">{{ aiAnalysisResult.problemAnalysis }}</div>
                  </div>

                  <div class="analysis-section">
                    <h5>可能原因</h5>
                    <ul class="cause-list">
                      <li v-for="cause in aiAnalysisResult.possibleCauses" :key="cause">{{ cause }}</li>
                    </ul>
                  </div>

                  <div class="analysis-section">
                    <h5>推荐解决方案</h5>
                    <div class="solution-list">
                      <div
                        v-for="solution in aiAnalysisResult.recommendedSolutions"
                        :key="solution.id"
                        class="solution-item"
                        @click="applySolution(solution)"
                      >
                        <div class="solution-title">{{ solution.title }}</div>
                        <div class="solution-desc">{{ solution.description }}</div>
                        <div class="solution-confidence">
                          <span>置信度: </span>
                          <el-progress
                            :percentage="solution.confidence"
                            :stroke-width="4"
                            :show-text="false"
                          />
                          <span>{{ solution.confidence }}%</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="analysis-section">
                    <h5>相关知识</h5>
                    <div class="knowledge-list">
                      <div
                        v-for="knowledge in aiAnalysisResult.relatedKnowledge"
                        :key="knowledge.id"
                        class="knowledge-item"
                        @click="viewKnowledge(knowledge)"
                      >
                        <el-icon><Document /></el-icon>
                        <span class="knowledge-title">{{ knowledge.title }}</span>
                        <span class="knowledge-relevance">{{ knowledge.relevance }}%</span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- AI分析加载状态 -->
                <div class="ai-loading" v-else-if="isAnalyzing">
                  <el-icon class="is-loading"><Loading /></el-icon>
                  <p>AI正在分析中...</p>
                </div>

                <!-- 未分析状态 -->
                <div class="ai-empty" v-else>
                  <el-icon><MagicStick /></el-icon>
                  <p>点击"AI分析"按钮获取智能建议</p>
                  <el-button type="primary" @click="analyzeTicket(selectedTicket)">
                    开始AI分析
                  </el-button>
                </div>
              </el-card>

              <!-- 快速操作面板 -->
              <el-card class="quick-actions" style="margin-top: 20px;">
                <template #header>
                  <span>快速操作</span>
                </template>
                <div class="action-buttons">
                  <el-button @click="assignTicket(selectedTicket)" block>
                    <el-icon><User /></el-icon>
                    分配工程师
                  </el-button>
                  <el-button @click="updateStatus(selectedTicket)" block>
                    <el-icon><Edit /></el-icon>
                    更新状态
                  </el-button>
                  <el-button @click="createKnowledge(selectedTicket)" block>
                    <el-icon><Document /></el-icon>
                    转知识库
                  </el-button>
                  <el-button @click="addComment(selectedTicket)" block>
                    <el-icon><ChatDotRound /></el-icon>
                    添加备注
                  </el-button>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 创建工单对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建工单" width="900px" class="create-ticket-dialog">
      <el-form ref="createFormRef" :model="newTicket" :rules="createRules" label-width="120px">
        <!-- 基本信息 -->
        <div class="form-section">
          <h4 class="section-title">基本信息</h4>
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="工单标题" prop="title">
                <el-input
                  v-model="newTicket.title"
                  placeholder="请输入工单标题"
                  maxlength="200"
                  show-word-limit
                />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="优先级" prop="priority">
                <el-select v-model="newTicket.priority" placeholder="请选择优先级">
                  <el-option label="低" value="LOW" />
                  <el-option label="普通" value="NORMAL" />
                  <el-option label="高" value="HIGH" />
                  <el-option label="紧急" value="URGENT" />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>

          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="分类" prop="category">
                <el-select v-model="newTicket.category" placeholder="请选择分类" @change="onCategoryChange">
                  <el-option
                    v-for="category in categories"
                    :key="category.id"
                    :label="category.name"
                    :value="category.name"
                  />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="子分类">
                <el-select v-model="newTicket.subcategory" placeholder="请选择子分类" :disabled="!newTicket.category">
                  <el-option
                    v-for="sub in subcategories"
                    :key="sub"
                    :label="sub"
                    :value="sub"
                  />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>

          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="截止时间">
                <el-date-picker
                  v-model="newTicket.dueTime"
                  type="datetime"
                  placeholder="请选择截止时间"
                  style="width: 100%"
                  :disabled-date="disabledDate"
                />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="联系人">
                <el-input v-model="newTicket.contact" placeholder="请输入联系人" />
              </el-form-item>
            </el-col>
          </el-row>

          <el-form-item label="问题描述" prop="description">
            <el-input
              v-model="newTicket.description"
              type="textarea"
              :rows="4"
              placeholder="请详细描述问题现象、影响范围、复现步骤等..."
              maxlength="2000"
              show-word-limit
            />
          </el-form-item>
        </div>

        <!-- 附件上传 -->
        <div class="form-section">
          <h4 class="section-title">附件信息</h4>
          <el-form-item label="相关附件">
            <el-upload
              class="upload-demo"
              drag
              action="#"
              multiple
              :auto-upload="false"
              :on-change="handleFileChange"
            >
              <el-icon class="el-icon--upload"><upload-filled /></el-icon>
              <div class="el-upload__text">
                将文件拖到此处，或<em>点击上传</em>
              </div>
              <template #tip>
                <div class="el-upload__tip">
                  支持 jpg/png/gif/pdf/doc/docx 文件，且不超过 10MB
                </div>
              </template>
            </el-upload>
          </el-form-item>
        </div>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showCreateDialog = false">取消</el-button>
          <el-button @click="saveDraft">保存草稿</el-button>
          <el-button type="primary" @click="createTicket" :loading="creating">
            {{ creating ? '创建中...' : '创建工单' }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 工单详情对话框 -->
    <el-dialog
      v-model="showDetailDialog"
      title="工单详情"
      width="800px"
    >
      <div v-if="selectedTicket">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="工单号">{{ selectedTicket.id }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusType(selectedTicket.status)">
              {{ selectedTicket.status }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="优先级">
            <el-tag :type="getPriorityType(selectedTicket.priority)">
              {{ selectedTicket.priority }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="分类">{{ selectedTicket.category }}</el-descriptions-item>
          <el-descriptions-item label="处理人">{{ selectedTicket.assignee }}</el-descriptions-item>
          <el-descriptions-item label="报告人">{{ selectedTicket.reporter }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ selectedTicket.createdAt }}</el-descriptions-item>
          <el-descriptions-item label="更新时间">{{ selectedTicket.updatedAt }}</el-descriptions-item>
          <el-descriptions-item label="标题" :span="2">{{ selectedTicket.title }}</el-descriptions-item>
          <el-descriptions-item label="描述" :span="2">{{ selectedTicket.description }}</el-descriptions-item>
        </el-descriptions>

        <!-- 工单操作历史 -->
        <div style="margin-top: 20px;">
          <h4>处理历史</h4>
          <el-timeline>
            <el-timeline-item timestamp="2024-01-15 10:30" placement="top">
              <el-card>
                <h4>工单已创建</h4>
                <p>用户提交了新的工单请求</p>
              </el-card>
            </el-timeline-item>
            <el-timeline-item timestamp="2024-01-15 11:00" placement="top">
              <el-card>
                <h4>工单已分配</h4>
                <p>工单已分配给 {{ selectedTicket.assignee }}</p>
              </el-card>
            </el-timeline-item>
            <el-timeline-item timestamp="2024-01-15 14:30" placement="top">
              <el-card>
                <h4>开始处理</h4>
                <p>工程师开始处理该工单</p>
              </el-card>
            </el-timeline-item>
          </el-timeline>
        </div>
      </div>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus, Search, User, Download, Refresh, Tickets, Clock, Loading,
  CircleCheck, TrendCharts, Bottom, Top, Minus, MagicStick,
  Document, Edit, ChatDotRound, ArrowDown, UploadFilled, Share, Lock
} from '@element-plus/icons-vue'
import { categoryService } from '@/services/categoryService'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('list')
const tickets = ref([])
const searchText = ref('')
const filterStatus = ref('')
const filterPriority = ref('')
const filterCategory = ref('')
const filterAssignee = ref('')
const filterWorkflow = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const showCreateDialog = ref(false)
const selectedTicket = ref(null)
const selectedTickets = ref([])
const showAIAnalysis = ref(true)
const isAnalyzing = ref(false)
const aiAnalysisResult = ref(null)
const currentTenant = ref('1')
const statsCollapsed = ref(false) // 统计卡片收缩状态

// 页面操作按钮配置
const ticketActions = ref([
  {
    key: 'create',
    label: '新建工单',
    type: 'primary',
    icon: 'Plus'
  },
  {
    key: 'refresh',
    label: '刷新数据',
    type: 'default',
    icon: 'Refresh'
  },
  {
    key: 'export',
    label: '导出数据',
    type: 'default',
    icon: 'Download'
  },
  {
    key: 'import',
    label: '批量导入',
    type: 'default',
    icon: 'Upload'
  },
  {
    key: 'batch',
    label: '批量操作',
    type: 'default',
    icon: 'Operation'
  },
  {
    key: 'template',
    label: '工单模板',
    type: 'default',
    icon: 'Document'
  },
  {
    key: 'settings',
    label: '工单设置',
    type: 'default',
    icon: 'Setting'
  }
])

// 租户数据
const tenants = ref([
  { id: '1', name: '阿里巴巴集团', code: 'ALIBABA' },
  { id: '2', name: '腾讯科技', code: 'TENCENT' },
  { id: '3', name: '字节跳动', code: 'BYTEDANCE' }
])

// 工单统计数据 - 已移动到computed版本

// AI分析统计
const aiStats = ref({
  totalAnalyzed: 89,
  accuracyRate: 92,
  avgTime: 3.2
})

// AI分析历史
const aiAnalysisHistory = ref([
  {
    ticketId: 'T000001',
    ticketTitle: '服务器CPU使用率过高',
    analysisTime: '2024-01-15 14:30',
    confidence: 95,
    status: '已解决'
  },
  {
    ticketId: 'T000002',
    ticketTitle: '数据库连接超时',
    analysisTime: '2024-01-15 13:45',
    confidence: 88,
    status: '处理中'
  },
  {
    ticketId: 'T000003',
    ticketTitle: '网络延迟异常',
    analysisTime: '2024-01-15 12:20',
    confidence: 91,
    status: '已解决'
  }
])

// 新工单表单
const newTicket = ref({
  title: '',
  description: '',
  priority: '',
  category: '',
  subcategory: '',
  dueTime: null,
  contact: '',
  enableAI: true
})

// 表单验证规则
const createRules = {
  title: [
    { required: true, message: '请输入工单标题', trigger: 'blur' },
    { min: 5, max: 200, message: '标题长度在 5 到 200 个字符', trigger: 'blur' }
  ],
  description: [
    { required: true, message: '请输入问题描述', trigger: 'blur' },
    { min: 10, max: 2000, message: '描述长度在 10 到 2000 个字符', trigger: 'blur' }
  ],
  priority: [
    { required: true, message: '请选择优先级', trigger: 'change' }
  ],
  category: [
    { required: true, message: '请选择分类', trigger: 'change' }
  ]
}

// 表单状态
const creating = ref(false)
const createFormRef = ref(null)

// 分类数据
const categories = ref([])
const subcategories = ref([])

// 初始化工单数据
const initTickets = () => {
  tickets.value = [
    {
      id: 'T000001',
      title: '服务器CPU使用率过高告警',
      description: '生产环境Web服务器CPU使用率持续超过90%，影响系统响应速度',
      priority: '紧急',
      status: '处理中',
      category: '硬件故障',
      tenant: '阿里巴巴集团',
      workflowStatus: '已审批',
      assignee: '张工程师',
      assigneeAvatar: '',
      creator: '系统监控',
      reporter: '系统监控',
      createdAt: '2024-01-15 09:30',
      updatedAt: '2024-01-15 14:20',
      sla: '4小时',
      slaProgress: 65,
      slaRemaining: '1.5小时',
      hasAIAnalysis: true
    },
    {
      id: 'T000002',
      title: '数据库连接超时问题',
      description: '应用程序连接数据库时频繁出现超时错误，影响业务正常运行',
      priority: '高',
      status: '待分配',
      category: '软件问题',
      tenant: '阿里巴巴集团',
      workflowStatus: '待审批',
      assignee: '',
      assigneeAvatar: '',
      creator: '李用户',
      reporter: '李用户',
      createdAt: '2024-01-15 10:15',
      updatedAt: '2024-01-15 10:15',
      sla: '8小时',
      slaProgress: 25,
      slaRemaining: '6小时',
      hasAIAnalysis: false
    },
    {
      id: 'T000003',
      title: '网络设备端口故障',
      description: '核心交换机端口24出现间歇性断连，影响部分用户网络访问',
      priority: '中',
      status: '已完成',
      category: '网络故障',
      assignee: '王工程师',
      assigneeAvatar: '',
      creator: '网络监控',
      reporter: '网络监控',
      createdAt: '2024-01-14 16:45',
      updatedAt: '2024-01-15 11:30',
      sla: '24小时',
      slaProgress: 100,
      slaRemaining: '已完成',
      hasAIAnalysis: true
    },
    {
      id: 'T000004',
      title: '邮件服务器存储空间不足',
      description: '邮件服务器磁盘使用率达到95%，需要清理或扩容',
      priority: '高',
      status: '待验收',
      category: '系统维护',
      assignee: '赵工程师',
      assigneeAvatar: '',
      creator: '系统管理员',
      reporter: '系统管理员',
      createdAt: '2024-01-15 08:20',
      updatedAt: '2024-01-15 13:45',
      sla: '12小时',
      slaProgress: 85,
      slaRemaining: '2小时',
      hasAIAnalysis: true
    },
    {
      id: 'T000005',
      title: '用户权限配置异常',
      description: '新员工无法访问OA系统，需要配置相应权限',
      priority: '低',
      status: '处理中',
      category: '安全事件',
      assignee: '李工程师',
      assigneeAvatar: '',
      creator: '人事部',
      reporter: '人事部',
      createdAt: '2024-01-15 11:00',
      updatedAt: '2024-01-15 12:30',
      sla: '48小时',
      slaProgress: 15,
      slaRemaining: '44小时',
      hasAIAnalysis: false
    }
  ]
}

// 筛选后的工单列表
const filteredTickets = computed(() => {
  let result = tickets.value

  // 根据当前租户筛选工单（多租户数据隔离）
  const currentTenantName = tenants.value.find(t => t.id === currentTenant.value)?.name
  if (currentTenantName) {
    result = result.filter(ticket => ticket.tenant === currentTenantName)
  }

  if (searchText.value) {
    result = result.filter(ticket =>
      ticket.title.includes(searchText.value) ||
      ticket.id.includes(searchText.value) ||
      ticket.description.includes(searchText.value)
    )
  }

  if (filterStatus.value) {
    result = result.filter(ticket => ticket.status === filterStatus.value)
  }

  if (filterPriority.value) {
    result = result.filter(ticket => ticket.priority === filterPriority.value)
  }

  if (filterCategory.value) {
    result = result.filter(ticket => ticket.category === filterCategory.value)
  }

  if (filterAssignee.value) {
    if (filterAssignee.value === '未分配') {
      result = result.filter(ticket => !ticket.assignee)
    } else {
      result = result.filter(ticket => ticket.assignee === filterAssignee.value)
    }
  }

  if (filterWorkflow.value) {
    result = result.filter(ticket => ticket.workflowStatus === filterWorkflow.value)
  }

  return result
})

// 总工单数
const totalTickets = computed(() => filteredTickets.value.length)

// 工单统计概览
const ticketStats = computed(() => {
  const total = filteredTickets.value.length
  const urgent = filteredTickets.value.filter(t => t.priority === '紧急').length
  const processing = filteredTickets.value.filter(t => t.status === '处理中').length
  const completed = filteredTickets.value.filter(t => t.status === '已完成').length

  return {
    total,
    urgent,
    processing,
    completed,
    completionRate: total > 0 ? Math.round((completed / total) * 100) : 0
  }
})

// 统计卡片数据
const ticketStatsCards = computed(() => [
  {
    label: '工单总数',
    value: ticketStats.value.total,
    icon: 'Tickets',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 12.5
  },
  {
    label: '紧急工单',
    value: ticketStats.value.urgent,
    icon: 'Clock',
    color: 'var(--el-color-error, #ef4444)',
    trend: -8.3
  },
  {
    label: '处理中',
    value: ticketStats.value.processing,
    icon: 'Loading',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 5.7
  },
  {
    label: '完成率',
    value: `${ticketStats.value.completionRate}%`,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 3.2
  }
])

// 工具方法
const getPriorityType = (priority) => {
  const types = { '低': '', '中': 'warning', '高': 'danger', '紧急': 'danger' }
  return types[priority] || ''
}

const getStatusType = (status) => {
  const types = {
    '待分配': 'info',
    '处理中': 'warning',
    '待验收': 'warning',
    '已完成': 'success',
    '已关闭': ''
  }
  return types[status] || ''
}

const getWorkflowType = (workflowStatus) => {
  const types = {
    '待审批': 'warning',
    '审批中': 'primary',
    '已审批': 'success',
    '审批拒绝': 'danger'
  }
  return types[workflowStatus] || 'info'
}

const getSLAColor = (progress) => {
  if (progress >= 80) return '#f56c6c'
  if (progress >= 60) return '#e6a23c'
  return '#67c23a'
}

const getProcessLogs = (ticket) => {
  return [
    {
      id: 1,
      timestamp: ticket.createdAt,
      type: 'primary',
      operator: ticket.creator,
      action: '创建工单',
      description: '工单已创建，等待分配处理人员'
    },
    {
      id: 2,
      timestamp: ticket.updatedAt,
      type: 'success',
      operator: '系统',
      action: '自动分析',
      description: 'AI系统已完成初步分析，生成解决方案建议'
    },
    {
      id: 3,
      timestamp: ticket.updatedAt,
      type: 'warning',
      operator: ticket.assignee || '待分配',
      action: '开始处理',
      description: '工程师已接收工单，开始问题诊断'
    }
  ]
}

// 事件处理方法
const resetFilters = () => {
  searchText.value = ''
  filterStatus.value = ''
  filterPriority.value = ''
  filterCategory.value = ''
  filterAssignee.value = ''
  filterWorkflow.value = ''
}

// 统计卡片点击处理
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
  initTickets()
}

// 页面操作处理
const handlePageAction = (actionKey) => {
  switch (actionKey) {
    case 'create':
      showCreateDialog.value = true
      break
    case 'refresh':
      refreshData()
      break
    case 'export':
      exportData()
      break
    case 'import':
      ElMessage.info('批量导入功能开发中...')
      break
    case 'batch':
      if (selectedTickets.value.length === 0) {
        ElMessage.warning('请先选择要操作的工单')
      } else {
        ElMessage.info(`批量操作 ${selectedTickets.value.length} 个工单`)
      }
      break
    case 'template':
      ElMessage.info('工单模板功能开发中...')
      break
    case 'settings':
      ElMessage.info('工单设置功能开发中...')
      break
    default:
      ElMessage.info(`执行操作: ${actionKey}`)
  }
}

const exportData = () => {
  ElMessage.success('数据导出成功')
}

// 租户切换
const onTenantChange = (tenantId) => {
  ElMessage.success(`已切换到租户：${tenants.value.find(t => t.id === tenantId)?.name}`)
  // 重新加载当前租户的工单数据
  initTickets()
}

// 切换统计卡片显示状态
const toggleStats = () => {
  statsCollapsed.value = !statsCollapsed.value
  // 保存用户偏好到localStorage
  localStorage.setItem('ticketStatsCollapsed', statsCollapsed.value.toString())
}

const refreshTickets = () => {
  ElMessage.success('工单列表已刷新')
  initTickets()
}

const exportTickets = () => {
  ElMessage.success('工单数据导出成功')
}

const batchAssign = () => {
  ElMessage.info(`批量分配 ${selectedTickets.value.length} 个工单`)
}

const handleSelectionChange = (selection) => {
  selectedTickets.value = selection
}

const handleSizeChange = (size) => {
  pageSize.value = size
}

const handleCurrentChange = (page) => {
  currentPage.value = page
}

const handleFileChange = (file) => {
  ElMessage.info(`上传文件: ${file.name}`)
}

// 工单操作方法
const viewTicketDetail = (ticket) => {
  selectedTicket.value = ticket
  activeTab.value = 'detail'
}

const editTicket = (ticket) => {
  ElMessage.info(`编辑工单: ${ticket.id}`)
}

const deleteTicket = async (ticket) => {
  try {
    await ElMessageBox.confirm(`确定要删除工单 ${ticket.id} 吗？`, '确认删除', {
      type: 'warning'
    })

    const index = tickets.value.findIndex(t => t.id === ticket.id)
    if (index > -1) {
      tickets.value.splice(index, 1)
      ElMessage.success('工单已删除')
    }
  } catch (error) {
    // 用户取消
  }
}

const assignTicket = (ticket) => {
  ElMessageBox.confirm(
    `工单 ${ticket.id} 需要在派单管理页面进行分配，是否跳转到派单管理页面？`,
    '工单分配',
    {
      confirmButtonText: '跳转到派单管理',
      cancelButtonText: '取消',
      type: 'info'
    }
  ).then(() => {
    // 这里应该使用路由跳转到派单管理页面
    // 由于这是演示代码，暂时使用消息提示
    ElMessage.success('正在跳转到派单管理页面...')
    // 实际项目中应该使用: this.$router.push('/dispatch')
  }).catch(() => {
    // 用户取消
  })
}

const duplicateTicket = (ticket) => {
  ElMessage.info(`复制工单 ${ticket.id}`)
}

const updateStatus = (ticket) => {
  ElMessage.info(`更新工单状态: ${ticket.id}`)
}

const addComment = (ticket) => {
  ElMessage.info(`添加备注: ${ticket.id}`)
}

// AI分析相关方法
const analyzeTicket = async (ticket) => {
  isAnalyzing.value = true
  aiAnalysisResult.value = null

  ElMessage.info('开始AI分析...')

  // 模拟AI分析过程
  setTimeout(() => {
    aiAnalysisResult.value = {
      problemAnalysis: '根据工单描述分析，这是一个典型的服务器性能问题。CPU使用率过高通常由以下几个方面引起：进程异常、资源不足、配置不当等。',
      possibleCauses: [
        '某个进程占用CPU资源过多',
        '服务器内存不足导致频繁交换',
        '数据库查询效率低下',
        '定时任务在高峰期执行',
        '病毒或恶意软件感染'
      ],
      recommendedSolutions: [
        {
          id: 1,
          title: '检查进程资源占用',
          description: '使用top命令查看CPU占用最高的进程，分析是否有异常进程',
          confidence: 95
        },
        {
          id: 2,
          title: '优化数据库查询',
          description: '检查慢查询日志，优化数据库索引和查询语句',
          confidence: 88
        },
        {
          id: 3,
          title: '调整定时任务',
          description: '将定时任务调整到业务低峰期执行，避免资源冲突',
          confidence: 82
        }
      ],
      relatedKnowledge: [
        {
          id: 1,
          title: 'Linux服务器性能优化指南',
          relevance: 95
        },
        {
          id: 2,
          title: 'CPU使用率过高问题排查手册',
          relevance: 92
        },
        {
          id: 3,
          title: '数据库性能调优最佳实践',
          relevance: 85
        }
      ]
    }

    isAnalyzing.value = false
    ticket.hasAIAnalysis = true
    ElMessage.success('AI分析完成')
  }, 2000)
}

const applySolution = (solution) => {
  ElMessage.success(`应用解决方案: ${solution.title}`)
}

const viewKnowledge = (knowledge) => {
  ElMessage.info(`查看知识: ${knowledge.title}`)
}

const createKnowledge = (ticket) => {
  ElMessage.success(`工单 ${ticket.id} 已转换为知识库条目`)
}

const viewAnalysisDetail = (analysis) => {
  ElMessage.info(`查看分析详情: ${analysis.ticketId}`)
}

// 加载分类数据
const loadCategories = async () => {
  try {
    const categoryData = await categoryService.getCategories()
    categories.value = categoryData.filter(cat => cat.level === 1 && cat.status === 'enabled')
  } catch (error) {
    console.error('加载分类数据失败:', error)
    ElMessage.error('加载分类数据失败')
  }
}

// 获取子分类
const getSubcategories = async (categoryName) => {
  try {
    const category = categories.value.find(cat => cat.name === categoryName)
    if (category) {
      const subCats = await categoryService.getSubCategories(category.id)
      return subCats.filter(sub => sub.status === 'enabled').map(sub => sub.name)
    }
    return []
  } catch (error) {
    console.error('获取子分类失败:', error)
    return []
  }
}

// 分类变更处理
const onCategoryChange = async () => {
  newTicket.value.subcategory = ''
  if (newTicket.value.category) {
    const subCats = await getSubcategories(newTicket.value.category)
    subcategories.value = subCats
  } else {
    subcategories.value = []
  }
}

// 禁用日期（不能选择过去的日期）
const disabledDate = (time) => {
  return time.getTime() < Date.now() - 24 * 60 * 60 * 1000
}

// 保存草稿
const saveDraft = () => {
  ElMessage.success('草稿已保存')
}

// 创建工单
const createTicket = async () => {
  if (!createFormRef.value) return

  try {
    await createFormRef.value.validate()
    creating.value = true

    // 模拟API调用
    await new Promise(resolve => setTimeout(resolve, 1500))

    const ticket = {
      id: `T${String(Date.now()).slice(-6)}`,
      title: newTicket.value.title,
      description: newTicket.value.description,
      priority: newTicket.value.priority,
      category: newTicket.value.category,
      subcategory: newTicket.value.subcategory,
      status: '待分配', // 新建工单默认状态为待分配
      assignee: '', // 不在创建时分配
      reporter: '当前用户',
      createdAt: new Date().toLocaleString(),
      updatedAt: new Date().toLocaleString(),
      dueTime: newTicket.value.dueTime ? new Date(newTicket.value.dueTime).toLocaleString() : '',
      contact: newTicket.value.contact,
      sla: '24小时',
      slaProgress: 0,
      slaRemaining: '24小时',
      hasAIAnalysis: false
    }

    tickets.value.unshift(ticket)

    // 重置表单
    resetCreateForm()

    showCreateDialog.value = false
    creating.value = false
    ElMessage.success('工单创建成功！工单已进入待分配队列，请前往派单管理页面进行分配。')

    // 如果启用AI分析，自动进行分析
    if (newTicket.value.enableAI) {
      setTimeout(() => {
        analyzeTicket(ticket)
      }, 2000)
    }
  } catch (error) {
    creating.value = false
    ElMessage.error('请检查输入信息')
  }
}

// 重置创建表单
const resetCreateForm = () => {
  Object.assign(newTicket.value, {
    title: '',
    description: '',
    priority: '',
    category: '',
    subcategory: '',
    dueTime: null,
    contact: '',
    enableAI: true
  })
}

// 组件挂载
onMounted(() => {
  console.log('工单管理模块已加载')
  initTickets()
  loadCategories()
})
</script>

<style scoped>
.ticket-demo {
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

/* 筛选卡片样式 */
.filter-card {
  margin-bottom: 20px;
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px 0 rgba(0, 0, 0, 0.06);
}

/* 统计容器样式 */
.stats-container {
  margin-bottom: 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.stats-title {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
}

.stats-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* 统计卡片样式 */
.stats-row {
  padding: 16px;
  background: #fafafa;
  margin-bottom: 0;
}

.stat-card {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  height: 100%;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
}

.stat-card.compact .el-card__body {
  padding: 12px 16px;
}

.stat-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0;
}

.stat-card.compact .stat-content {
  padding: 0;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: white;
  flex-shrink: 0;
}

.stat-icon.total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-icon.pending {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-icon.processing {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-icon.completed {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-info {
  flex: 1;
  margin-left: 12px;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
}

.stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 2px;
}

.stat-trend {
  display: flex;
  align-items: center;
  font-size: 12px;
  font-weight: 500;
}

.stat-trend.up {
  color: #67c23a;
}

.stat-trend.down {
  color: #f56c6c;
}

.stat-trend.stable {
  color: #909399;
}

.stat-trend span {
  margin-left: 4px;
}

/* 列表卡片样式 */
.list-card {
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

/* 工单表格样式 */
.ticket-id {
  display: flex;
  align-items: center;
  gap: 8px;
}

.ai-icon {
  font-size: 16px;
}

.ticket-title {
  display: flex;
  flex-direction: column;
}

.title-text {
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.title-desc {
  font-size: 12px;
  color: #909399;
}

.assignee-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.assignee-name {
  font-size: 14px;
  color: #303133;
}

.unassigned {
  color: #909399;
  font-style: italic;
}

.sla-status {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.sla-text {
  font-size: 12px;
  color: #606266;
}

.pagination-wrapper {
  margin-top: 20px;
  text-align: center;
}

/* 工单详情样式 */
.detail-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.ticket-info h3 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 20px;
}

.ticket-meta {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ticket-id {
  color: #909399;
  font-size: 14px;
}

.detail-actions {
  display: flex;
  gap: 12px;
}

.ticket-details {
  margin-top: 20px;
}

.description-section {
  margin: 20px 0;
}

.description-section h4 {
  margin: 0 0 12px 0;
  color: #303133;
  font-size: 16px;
}

.description-content {
  padding: 16px;
  background-color: #f8f9fa;
  border-radius: 6px;
  color: #606266;
  line-height: 1.6;
}

.process-logs {
  margin: 20px 0;
}

.process-logs h4 {
  margin: 0 0 16px 0;
  color: #303133;
  font-size: 16px;
}

.log-content {
  padding: 8px 0;
}

.log-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 4px;
}

.log-operator {
  font-weight: 500;
  color: #303133;
}

.log-action {
  color: #409eff;
  font-size: 14px;
}

.log-description {
  color: #606266;
  font-size: 14px;
}

.attachments {
  margin: 20px 0;
}

.attachments h4 {
  margin: 0 0 12px 0;
  color: #303133;
  font-size: 16px;
}

.attachment-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.attachment-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  background-color: #fafafa;
}

.file-name {
  flex: 1;
  color: #303133;
}

.file-size {
  color: #909399;
  font-size: 12px;
}

/* AI分析面板样式 */
.ai-panel {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.ai-header {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #409eff;
  font-weight: 500;
}

.ai-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.analysis-section h5 {
  margin: 0 0 12px 0;
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}

.analysis-text {
  color: #606266;
  line-height: 1.6;
  font-size: 14px;
}

.cause-list {
  margin: 0;
  padding-left: 20px;
  color: #606266;
}

.cause-list li {
  margin-bottom: 8px;
  font-size: 14px;
}

.solution-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.solution-item {
  padding: 12px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  background-color: #fafafa;
  cursor: pointer;
  transition: all 0.3s ease;
}

.solution-item:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px 0 rgba(64, 158, 255, 0.12);
}

.solution-title {
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.solution-desc {
  color: #606266;
  font-size: 12px;
  margin-bottom: 8px;
}

.solution-confidence {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #909399;
}

.knowledge-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.knowledge-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  background-color: #fafafa;
  cursor: pointer;
  transition: all 0.3s ease;
}

.knowledge-item:hover {
  border-color: #409eff;
  background-color: #f0f9ff;
}

.knowledge-title {
  flex: 1;
  color: #303133;
  font-size: 12px;
}

.knowledge-relevance {
  color: #409eff;
  font-size: 12px;
  font-weight: 500;
}

.ai-loading {
  text-align: center;
  padding: 40px 20px;
  color: #909399;
}

.ai-loading .is-loading {
  font-size: 32px;
  margin-bottom: 16px;
}

.ai-empty {
  text-align: center;
  padding: 40px 20px;
  color: #909399;
}

.ai-empty .el-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

/* 快速操作面板样式 */
.quick-actions {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.action-buttons .el-button {
  justify-content: flex-start;
}

/* AI统计卡片样式 */
.ai-stat-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.ai-stat {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
}

.ai-stat .stat-info {
  margin-left: 0;
}

.analysis-history {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .ticket-demo {
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

  .detail-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }

  .ticket-meta {
    flex-wrap: wrap;
  }
}

/* 创建工单对话框样式 */
.create-ticket-dialog .el-dialog__body {
  max-height: 70vh;
  overflow-y: auto;
}

.form-section {
  margin-bottom: 30px;
  padding: 20px;
  background: #fafafa;
  border-radius: 8px;
  border-left: 4px solid #409eff;
}

.section-title {
  margin: 0 0 20px 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-title::before {
  content: '';
  width: 4px;
  height: 16px;
  background: #409eff;
  border-radius: 2px;
}



.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.upload-demo {
  width: 100%;
}

.el-upload-dragger {
  width: 100% !important;
}
</style>