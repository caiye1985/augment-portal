<template>
  <PageLayout
    title="AI智能分析"
    description="智能问答、故障诊断和解决方案推荐系统"
    icon="MagicStick"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="newChat">
        <el-icon><Plus /></el-icon>
        新会话
      </el-button>
      <el-button @click="refreshAnalysis">
        <el-icon><Refresh /></el-icon>
        刷新分析
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in aiStatsCards" :key="stat.label">
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
      <!-- 智能问答 -->
      <el-tab-pane label="智能问答" name="chat">
        <div class="tab-content">
          <div class="chat-container">
            <div class="chat-sidebar">
              <!-- 会话历史 -->
              <div class="chat-history">
                <div class="history-header">
                  <h3>会话历史</h3>
                  <el-button size="small" @click="newChat">
                    <el-icon><Plus /></el-icon>
                    新会话
                  </el-button>
                </div>

                <div class="history-list">
                  <div
                    v-for="session in chatSessions"
                    :key="session.id"
                    class="history-item"
                    :class="{ active: currentSession === session.id }"
                    @click="switchSession(session.id)"
                  >
                    <div class="session-title">{{ session.title }}</div>
                    <div class="session-time">{{ session.time }}</div>
                  </div>
                </div>
              </div>

              <!-- 快捷问题 -->
              <div class="quick-questions">
                <h4>常见问题</h4>
                <div class="question-list">
                  <div
                    v-for="question in quickQuestions"
                    :key="question.id"
                    class="question-item"
                    @click="askQuestion(question.text)"
                  >
                    <el-icon><ChatDotRound /></el-icon>
                    <span>{{ question.text }}</span>
                  </div>
                </div>
              </div>
            </div>

            <div class="chat-main">
              <!-- 聊天消息区域 -->
              <div class="chat-messages" ref="messagesContainer">
                <div
                  v-for="message in currentMessages"
                  :key="message.id"
                  class="message-item"
                  :class="message.type"
                >
                  <div class="message-avatar">
                    <el-avatar v-if="message.type === 'user'" size="small">用</el-avatar>
                    <el-avatar v-else size="small" style="background: #409eff;">AI</el-avatar>
                  </div>

                  <div class="message-content">
                    <div class="message-text" v-html="message.content"></div>
                    <div class="message-time">{{ message.time }}</div>

                    <!-- AI回复的操作按钮 -->
                    <div v-if="message.type === 'ai'" class="message-actions">
                      <el-button size="small" text @click="copyMessage(message)">
                        <el-icon><CopyDocument /></el-icon>
                        复制
                      </el-button>
                      <el-button size="small" text @click="likeMessage(message)">
                        <el-icon><Like /></el-icon>
                        有用
                      </el-button>
                      <el-button size="small" text @click="dislikeMessage(message)">
                        <el-icon><Dislike /></el-icon>
                        无用
                      </el-button>
                    </div>
                  </div>
                </div>

                <!-- AI思考中状态 -->
                <div v-if="isThinking" class="message-item ai thinking">
                  <div class="message-avatar">
                    <el-avatar size="small" style="background: #409eff;">AI</el-avatar>
                  </div>
                  <div class="message-content">
                    <div class="thinking-animation">
                      <span></span>
                      <span></span>
                      <span></span>
                    </div>
                    <div class="message-text">AI正在思考中...</div>
                  </div>
                </div>
              </div>

              <!-- 输入区域 -->
              <div class="chat-input">
                <div class="input-toolbar">
                  <el-button size="small" @click="clearChat">清空对话</el-button>
                  <el-button size="small" @click="exportChat">导出对话</el-button>
                </div>

                <div class="input-area">
                  <el-input
                    v-model="inputMessage"
                    type="textarea"
                    :rows="3"
                    placeholder="请输入您的问题..."
                    @keydown.ctrl.enter="sendMessage"
                  />
                  <div class="input-actions">
                    <div class="input-tips">
                      <span>Ctrl + Enter 发送</span>
                    </div>
                    <el-button
                      type="primary"
                      @click="sendMessage"
                      :loading="isThinking"
                      :disabled="!inputMessage.trim()"
                    >
                      发送
                    </el-button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </el-tab-pane>

      <!-- 故障诊断 -->
      <el-tab-pane label="故障诊断" name="diagnosis">
        <div class="tab-content">
          <div class="diagnosis-container">
            <el-row :gutter="20">
              <el-col :span="16">
                <!-- 诊断向导 -->
                <el-card title="故障诊断向导">
                  <div class="diagnosis-wizard">
                    <el-steps :active="diagnosisStep" align-center>
                      <el-step title="故障描述" />
                      <el-step title="环境信息" />
                      <el-step title="AI分析" />
                      <el-step title="解决方案" />
                    </el-steps>

                    <!-- 步骤1: 故障描述 -->
                    <div v-if="diagnosisStep === 0" class="step-content">
                      <h3>请描述遇到的故障</h3>
                      <el-form :model="diagnosisForm" label-width="100px">
                        <el-form-item label="故障类型">
                          <el-select v-model="diagnosisForm.type" style="width: 100%">
                            <el-option label="网络故障" value="network" />
                            <el-option label="服务器故障" value="server" />
                            <el-option label="应用故障" value="application" />
                            <el-option label="数据库故障" value="database" />
                            <el-option label="其他" value="other" />
                          </el-select>
                        </el-form-item>
                        <el-form-item label="故障描述">
                          <el-input
                            v-model="diagnosisForm.description"
                            type="textarea"
                            :rows="4"
                            placeholder="请详细描述故障现象、发生时间、影响范围等..."
                          />
                        </el-form-item>
                        <el-form-item label="紧急程度">
                          <el-radio-group v-model="diagnosisForm.urgency">
                            <el-radio label="low">低</el-radio>
                            <el-radio label="medium">中</el-radio>
                            <el-radio label="high">高</el-radio>
                            <el-radio label="critical">紧急</el-radio>
                          </el-radio-group>
                        </el-form-item>
                      </el-form>
                    </div>

                    <!-- 步骤2: 环境信息 -->
                    <div v-if="diagnosisStep === 1" class="step-content">
                      <h3>环境信息收集</h3>
                      <el-form :model="diagnosisForm" label-width="100px">
                        <el-form-item label="操作系统">
                          <el-input v-model="diagnosisForm.os" placeholder="如: CentOS 7.9" />
                        </el-form-item>
                        <el-form-item label="相关服务">
                          <el-input v-model="diagnosisForm.services" placeholder="如: nginx, mysql, redis" />
                        </el-form-item>
                        <el-form-item label="错误日志">
                          <el-input
                            v-model="diagnosisForm.logs"
                            type="textarea"
                            :rows="4"
                            placeholder="请粘贴相关的错误日志..."
                          />
                        </el-form-item>
                        <el-form-item label="网络配置">
                          <el-input v-model="diagnosisForm.network" placeholder="IP地址、端口等网络信息" />
                        </el-form-item>
                      </el-form>
                    </div>

                    <!-- 步骤3: AI分析 -->
                    <div v-if="diagnosisStep === 2" class="step-content">
                      <div class="analysis-progress">
                        <h3>AI正在分析故障...</h3>
                        <el-progress :percentage="analysisProgress" :show-text="false" />
                        <div class="analysis-steps">
                          <div
                            v-for="step in analysisSteps"
                            :key="step.id"
                            class="analysis-step"
                            :class="{ active: step.active, completed: step.completed }"
                          >
                            <el-icon v-if="step.completed"><Check /></el-icon>
                            <el-icon v-else-if="step.active"><Loading /></el-icon>
                            <span>{{ step.text }}</span>
                          </div>
                        </div>
                      </div>
                    </div>

                    <!-- 步骤4: 解决方案 -->
                    <div v-if="diagnosisStep === 3" class="step-content">
                      <div class="solutions">
                        <h3>AI推荐解决方案</h3>
                        <div
                          v-for="solution in diagnosisSolutions"
                          :key="solution.id"
                          class="solution-item"
                        >
                          <div class="solution-header">
                            <h4>{{ solution.title }}</h4>
                            <el-tag :type="getSolutionType(solution.confidence)">
                              置信度: {{ solution.confidence }}%
                            </el-tag>
                          </div>
                          <p class="solution-description">{{ solution.description }}</p>
                          <div class="solution-steps">
                            <h5>执行步骤:</h5>
                            <ol>
                              <li v-for="step in solution.steps" :key="step">{{ step }}</li>
                            </ol>
                          </div>
                          <div class="solution-actions">
                            <el-button size="small" type="primary" @click="applySolution(solution)">
                              应用方案
                            </el-button>
                            <el-button size="small" @click="saveSolution(solution)">
                              保存到知识库
                            </el-button>
                          </div>
                        </div>
                      </div>
                    </div>

                    <!-- 导航按钮 -->
                    <div class="wizard-actions">
                      <el-button
                        v-if="diagnosisStep > 0"
                        @click="diagnosisStep--"
                      >
                        上一步
                      </el-button>
                      <el-button
                        v-if="diagnosisStep < 3"
                        type="primary"
                        @click="nextDiagnosisStep"
                      >
                        下一步
                      </el-button>
                      <el-button
                        v-if="diagnosisStep === 3"
                        type="success"
                        @click="completeDiagnosis"
                      >
                        完成诊断
                      </el-button>
                    </div>
                  </div>
                </el-card>
              </el-col>

              <el-col :span="8">
                <!-- 诊断历史 -->
                <el-card title="诊断历史" class="diagnosis-history">
                  <div class="history-list">
                    <div
                      v-for="record in diagnosisHistory"
                      :key="record.id"
                      class="history-record"
                      @click="loadDiagnosis(record)"
                    >
                      <div class="record-header">
                        <span class="record-title">{{ record.title }}</span>
                        <el-tag :type="getUrgencyType(record.urgency)" size="small">
                          {{ getUrgencyText(record.urgency) }}
                        </el-tag>
                      </div>
                      <div class="record-time">{{ record.time }}</div>
                      <div class="record-status">
                        <el-tag :type="record.solved ? 'success' : 'warning'" size="small">
                          {{ record.solved ? '已解决' : '未解决' }}
                        </el-tag>
                      </div>
                    </div>
                  </div>
                </el-card>

                <!-- AI统计 -->
                <el-card title="AI统计" class="ai-stats">
                  <div class="stats-grid">
                    <div class="stat-item">
                      <div class="stat-number">{{ aiStats.totalDiagnosis }}</div>
                      <div class="stat-label">总诊断次数</div>
                    </div>
                    <div class="stat-item">
                      <div class="stat-number">{{ aiStats.successRate }}%</div>
                      <div class="stat-label">解决成功率</div>
                    </div>
                    <div class="stat-item">
                      <div class="stat-number">{{ aiStats.avgTime }}</div>
                      <div class="stat-label">平均诊断时间</div>
                    </div>
                    <div class="stat-item">
                      <div class="stat-number">{{ aiStats.knowledgeBase }}</div>
                      <div class="stat-label">知识库条目</div>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </div>
      </el-tab-pane>

      <!-- 解决方案推荐 -->
      <el-tab-pane label="解决方案推荐" name="solutions">
        <div class="tab-content">
          <div class="solutions-container">
            <!-- 搜索和筛选 -->
            <div class="solutions-toolbar">
              <div class="search-bar">
                <el-input
                  v-model="solutionSearch"
                  placeholder="搜索解决方案..."
                  style="width: 300px"
                  clearable
                >
                  <template #prefix>
                    <el-icon><Search /></el-icon>
                  </template>
                </el-input>
                <el-select v-model="solutionCategory" placeholder="分类筛选" style="width: 150px" clearable>
                  <el-option label="网络" value="network" />
                  <el-option label="服务器" value="server" />
                  <el-option label="应用" value="application" />
                  <el-option label="数据库" value="database" />
                </el-select>
                <el-select v-model="solutionDifficulty" placeholder="难度筛选" style="width: 120px" clearable>
                  <el-option label="简单" value="easy" />
                  <el-option label="中等" value="medium" />
                  <el-option label="困难" value="hard" />
                </el-select>
              </div>
              <div class="toolbar-actions">
                <el-button type="primary" @click="createSolution">
                  <el-icon><Plus /></el-icon>
                  创建方案
                </el-button>
              </div>
            </div>

            <!-- 解决方案列表 -->
            <div class="solutions-grid">
              <div
                v-for="solution in filteredSolutions"
                :key="solution.id"
                class="solution-card"
                @click="viewSolution(solution)"
              >
                <div class="solution-header">
                  <h3>{{ solution.title }}</h3>
                  <div class="solution-meta">
                    <el-tag :type="getCategoryType(solution.category)" size="small">
                      {{ getCategoryText(solution.category) }}
                    </el-tag>
                    <el-tag :type="getDifficultyType(solution.difficulty)" size="small">
                      {{ getDifficultyText(solution.difficulty) }}
                    </el-tag>
                  </div>
                </div>

                <p class="solution-description">{{ solution.description }}</p>

                <div class="solution-stats">
                  <div class="stat">
                    <el-icon><View /></el-icon>
                    <span>{{ solution.views }}</span>
                  </div>
                  <div class="stat">
                    <el-icon><Like /></el-icon>
                    <span>{{ solution.likes }}</span>
                  </div>
                  <div class="stat">
                    <el-icon><Star /></el-icon>
                    <span>{{ solution.rating }}</span>
                  </div>
                </div>

                <div class="solution-footer">
                  <span class="solution-author">{{ solution.author }}</span>
                  <span class="solution-time">{{ solution.time }}</span>
                </div>
              </div>
            </div>

            <!-- 分页 -->
            <div class="pagination">
              <el-pagination
                v-model:current-page="solutionCurrentPage"
                v-model:page-size="solutionPageSize"
                :page-sizes="[12, 24, 48]"
                :total="filteredSolutions.length"
                layout="total, sizes, prev, pager, next, jumper"
              />
            </div>
          </div>
        </div>
      </el-tab-pane>

      <!-- AI模型管理 -->
      <el-tab-pane label="AI模型管理" name="models">
        <div class="tab-content">
          <div class="models-container">
            <el-row :gutter="20">
              <el-col :span="16">
                <!-- 模型列表 -->
                <el-card title="AI模型列表">
                  <el-table :data="aiModels" stripe style="width: 100%">
                    <el-table-column prop="name" label="模型名称" width="200" />
                    <el-table-column prop="type" label="类型" width="120">
                      <template #default="{ row }">
                        <el-tag :type="getModelTypeColor(row.type)">
                          {{ getModelTypeText(row.type) }}
                        </el-tag>
                      </template>
                    </el-table-column>
                    <el-table-column prop="version" label="版本" width="100" />
                    <el-table-column prop="status" label="状态" width="100">
                      <template #default="{ row }">
                        <el-tag :type="row.status === 'active' ? 'success' : 'info'">
                          {{ row.status === 'active' ? '运行中' : '已停止' }}
                        </el-tag>
                      </template>
                    </el-table-column>
                    <el-table-column prop="accuracy" label="准确率" width="100" />
                    <el-table-column prop="lastTrained" label="最后训练" width="160" />
                    <el-table-column label="操作" width="200" fixed="right">
                      <template #default="{ row }">
                        <el-button size="small" @click="trainModel(row)">训练</el-button>
                        <el-button size="small" @click="testModel(row)">测试</el-button>
                        <el-button
                          size="small"
                          :type="row.status === 'active' ? 'danger' : 'success'"
                          @click="toggleModel(row)"
                        >
                          {{ row.status === 'active' ? '停止' : '启动' }}
                        </el-button>
                      </template>
                    </el-table-column>
                  </el-table>
                </el-card>
              </el-col>

              <el-col :span="8">
                <!-- 模型性能 -->
                <el-card title="模型性能监控" class="model-performance">
                  <div class="performance-metrics">
                    <div class="metric-item">
                      <span class="metric-label">平均响应时间:</span>
                      <span class="metric-value">1.2s</span>
                    </div>
                    <div class="metric-item">
                      <span class="metric-label">今日请求数:</span>
                      <span class="metric-value">1,234</span>
                    </div>
                    <div class="metric-item">
                      <span class="metric-label">成功率:</span>
                      <span class="metric-value">98.5%</span>
                    </div>
                    <div class="metric-item">
                      <span class="metric-label">GPU使用率:</span>
                      <span class="metric-value">65%</span>
                    </div>
                  </div>
                </el-card>

                <!-- 训练配置 -->
                <el-card title="训练配置" class="training-config">
                  <el-form label-width="80px" size="small">
                    <el-form-item label="数据集">
                      <el-select v-model="trainingConfig.dataset" style="width: 100%">
                        <el-option label="故障诊断数据集" value="fault_diagnosis" />
                        <el-option label="解决方案数据集" value="solutions" />
                        <el-option label="问答数据集" value="qa" />
                      </el-select>
                    </el-form-item>
                    <el-form-item label="学习率">
                      <el-input v-model="trainingConfig.learningRate" placeholder="0.001" />
                    </el-form-item>
                    <el-form-item label="批次大小">
                      <el-input v-model="trainingConfig.batchSize" placeholder="32" />
                    </el-form-item>
                    <el-form-item label="训练轮数">
                      <el-input v-model="trainingConfig.epochs" placeholder="100" />
                    </el-form-item>
                  </el-form>

                  <el-button type="primary" style="width: 100%;" @click="startTraining">
                    开始训练
                  </el-button>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('chat')
const currentSession = ref(1)
const inputMessage = ref('')
const isThinking = ref(false)
const diagnosisStep = ref(0)
const analysisProgress = ref(0)
const solutionSearch = ref('')
const solutionCategory = ref('')
const solutionDifficulty = ref('')
const solutionCurrentPage = ref(1)
const solutionPageSize = ref(12)

// 聊天相关数据
const chatSessions = ref([
  { id: 1, title: '网络连接问题', time: '2024-01-15 14:30' },
  { id: 2, title: '服务器性能优化', time: '2024-01-15 10:15' },
  { id: 3, title: '数据库查询慢', time: '2024-01-14 16:45' }
])

const quickQuestions = ref([
  { id: 1, text: '如何排查网络连接问题？' },
  { id: 2, text: '服务器CPU使用率过高怎么办？' },
  { id: 3, text: '数据库连接超时如何解决？' },
  { id: 4, text: '如何优化系统性能？' }
])

const chatMessages = ref({
  1: [
    {
      id: 1,
      type: 'user',
      content: '网络连接经常断开，怎么排查？',
      time: '14:30:15'
    },
    {
      id: 2,
      type: 'ai',
      content: '网络连接断开可能有多种原因，我建议按以下步骤排查：<br><br>1. <strong>检查物理连接</strong><br>   - 确认网线连接是否牢固<br>   - 检查网卡指示灯状态<br><br>2. <strong>检查网络配置</strong><br>   - 运行 <code>ipconfig /all</code> 查看IP配置<br>   - 检查DNS设置是否正确<br><br>3. <strong>测试网络连通性</strong><br>   - ping 网关地址<br>   - ping 外网地址（如8.8.8.8）<br><br>需要我详细解释某个步骤吗？',
      time: '14:30:32'
    }
  ],
  2: [],
  3: []
})

// 故障诊断数据
const diagnosisForm = ref({
  type: '',
  description: '',
  urgency: 'medium',
  os: '',
  services: '',
  logs: '',
  network: ''
})

const analysisSteps = ref([
  { id: 1, text: '分析故障描述', active: false, completed: false },
  { id: 2, text: '检查环境信息', active: false, completed: false },
  { id: 3, text: '匹配知识库', active: false, completed: false },
  { id: 4, text: '生成解决方案', active: false, completed: false }
])

const diagnosisSolutions = ref([
  {
    id: 1,
    title: '重启网络服务',
    confidence: 85,
    description: '根据错误日志分析，可能是网络服务异常导致的连接问题',
    steps: [
      '停止网络服务：sudo systemctl stop network',
      '清理网络配置缓存：sudo ip addr flush dev eth0',
      '重启网络服务：sudo systemctl start network',
      '验证网络连接：ping -c 4 8.8.8.8'
    ]
  },
  {
    id: 2,
    title: '检查防火墙配置',
    confidence: 70,
    description: '防火墙规则可能阻止了网络连接',
    steps: [
      '查看防火墙状态：sudo iptables -L',
      '临时关闭防火墙：sudo systemctl stop firewalld',
      '测试网络连接',
      '如果恢复正常，调整防火墙规则'
    ]
  }
])

const diagnosisHistory = ref([
  {
    id: 1,
    title: '网络连接断开',
    urgency: 'high',
    time: '2024-01-15 14:30',
    solved: true
  },
  {
    id: 2,
    title: '服务器响应慢',
    urgency: 'medium',
    time: '2024-01-15 10:15',
    solved: false
  }
])

// 解决方案数据
const solutions = ref([
  {
    id: 1,
    title: '网络连接故障排查指南',
    description: '详细介绍网络连接问题的排查方法和解决步骤',
    category: 'network',
    difficulty: 'medium',
    views: 1234,
    likes: 89,
    rating: 4.5,
    author: 'AI助手',
    time: '2024-01-15'
  },
  {
    id: 2,
    title: '服务器性能优化最佳实践',
    description: '从CPU、内存、磁盘等多个维度优化服务器性能',
    category: 'server',
    difficulty: 'hard',
    views: 2156,
    likes: 156,
    rating: 4.8,
    author: '运维专家',
    time: '2024-01-14'
  },
  {
    id: 3,
    title: 'MySQL数据库慢查询优化',
    description: '识别和优化MySQL数据库中的慢查询问题',
    category: 'database',
    difficulty: 'medium',
    views: 987,
    likes: 67,
    rating: 4.3,
    author: 'DBA团队',
    time: '2024-01-13'
  }
])

// AI模型数据
const aiModels = ref([
  {
    id: 1,
    name: '故障诊断模型',
    type: 'classification',
    version: 'v2.1',
    status: 'active',
    accuracy: '94.5%',
    lastTrained: '2024-01-10 15:30'
  },
  {
    id: 2,
    name: '智能问答模型',
    type: 'nlp',
    version: 'v1.8',
    status: 'active',
    accuracy: '91.2%',
    lastTrained: '2024-01-08 11:20'
  },
  {
    id: 3,
    name: '解决方案推荐',
    type: 'recommendation',
    version: 'v1.5',
    status: 'inactive',
    accuracy: '88.7%',
    lastTrained: '2024-01-05 09:45'
  }
])

const trainingConfig = ref({
  dataset: 'fault_diagnosis',
  learningRate: '0.001',
  batchSize: '32',
  epochs: '100'
})

// 统计数据
const aiStats = ref({
  totalDiagnosis: 1234,
  successRate: 94,
  avgTime: '2.3s',
  knowledgeBase: 5678
})

// 统计卡片数据
const aiStatsCards = computed(() => [
  {
    label: '总诊断次数',
    value: aiStats.value.totalDiagnosis,
    icon: 'MagicStick',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 18.5
  },
  {
    label: '解决成功率',
    value: `${aiStats.value.successRate}%`,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 5.2
  },
  {
    label: '平均诊断时间',
    value: aiStats.value.avgTime,
    icon: 'Timer',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: -12.3
  },
  {
    label: '知识库条目',
    value: aiStats.value.knowledgeBase,
    icon: 'Document',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 25.7
  }
])

// 计算属性
const currentMessages = computed(() => chatMessages.value[currentSession.value] || [])

const filteredSolutions = computed(() => {
  let filtered = solutions.value

  if (solutionSearch.value) {
    const search = solutionSearch.value.toLowerCase()
    filtered = filtered.filter(s =>
      s.title.toLowerCase().includes(search) ||
      s.description.toLowerCase().includes(search)
    )
  }

  if (solutionCategory.value) {
    filtered = filtered.filter(s => s.category === solutionCategory.value)
  }

  if (solutionDifficulty.value) {
    filtered = filtered.filter(s => s.difficulty === solutionDifficulty.value)
  }

  return filtered
})

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshAnalysis = () => {
  ElMessage.success('AI分析数据已刷新')
}

const newChat = () => {
  const newId = Math.max(...chatSessions.value.map(s => s.id)) + 1
  chatSessions.value.unshift({
    id: newId,
    title: '新会话',
    time: new Date().toLocaleString()
  })
  currentSession.value = newId
  chatMessages.value[newId] = []
}

const switchSession = (sessionId) => {
  currentSession.value = sessionId
}

const askQuestion = (question) => {
  inputMessage.value = question
  sendMessage()
}

const sendMessage = async () => {
  if (!inputMessage.value.trim()) return

  const userMessage = {
    id: Date.now(),
    type: 'user',
    content: inputMessage.value,
    time: new Date().toLocaleTimeString()
  }

  if (!chatMessages.value[currentSession.value]) {
    chatMessages.value[currentSession.value] = []
  }

  chatMessages.value[currentSession.value].push(userMessage)

  // 更新会话标题
  const session = chatSessions.value.find(s => s.id === currentSession.value)
  if (session && session.title === '新会话') {
    session.title = inputMessage.value.substring(0, 20) + '...'
  }

  const question = inputMessage.value
  inputMessage.value = ''

  // 模拟AI思考
  isThinking.value = true
  await new Promise(resolve => setTimeout(resolve, 2000))

  const aiMessage = {
    id: Date.now() + 1,
    type: 'ai',
    content: generateAIResponse(question),
    time: new Date().toLocaleTimeString()
  }

  chatMessages.value[currentSession.value].push(aiMessage)
  isThinking.value = false

  // 滚动到底部
  nextTick(() => {
    const container = document.querySelector('.chat-messages')
    if (container) {
      container.scrollTop = container.scrollHeight
    }
  })
}

const generateAIResponse = (question) => {
  // 简单的AI回复生成逻辑
  const responses = [
    '根据您的问题，我建议您按照以下步骤进行排查...',
    '这是一个常见的问题，通常可以通过以下方法解决...',
    '让我为您分析一下可能的原因和解决方案...',
    '基于我的知识库，这种情况通常是由以下原因引起的...'
  ]
  return responses[Math.floor(Math.random() * responses.length)]
}

const copyMessage = (message) => {
  navigator.clipboard.writeText(message.content.replace(/<[^>]*>/g, ''))
  ElMessage.success('消息已复制到剪贴板')
}

const likeMessage = (message) => {
  ElMessage.success('感谢您的反馈')
}

const dislikeMessage = (message) => {
  ElMessage.info('我们会继续改进AI回复质量')
}

const clearChat = () => {
  chatMessages.value[currentSession.value] = []
  ElMessage.success('对话已清空')
}

const exportChat = () => {
  ElMessage.success('对话导出功能开发中...')
}

// 故障诊断相关方法
const nextDiagnosisStep = async () => {
  if (diagnosisStep.value === 1) {
    // 开始AI分析
    diagnosisStep.value = 2
    await simulateAnalysis()
    diagnosisStep.value = 3
  } else {
    diagnosisStep.value++
  }
}

const simulateAnalysis = async () => {
  analysisProgress.value = 0

  for (let i = 0; i < analysisSteps.value.length; i++) {
    analysisSteps.value[i].active = true

    // 模拟分析过程
    for (let j = 0; j <= 25; j++) {
      analysisProgress.value = i * 25 + j
      await new Promise(resolve => setTimeout(resolve, 50))
    }

    analysisSteps.value[i].active = false
    analysisSteps.value[i].completed = true
  }
}

const completeDiagnosis = () => {
  ElMessage.success('故障诊断完成')
  diagnosisStep.value = 0
  analysisProgress.value = 0
  analysisSteps.value.forEach(step => {
    step.active = false
    step.completed = false
  })
}

const applySolution = (solution) => {
  ElMessage.success(`开始应用解决方案: ${solution.title}`)
}

const saveSolution = (solution) => {
  ElMessage.success(`解决方案已保存到知识库: ${solution.title}`)
}

const loadDiagnosis = (record) => {
  ElMessage.info(`加载诊断记录: ${record.title}`)
}

// 解决方案相关方法
const createSolution = () => {
  ElMessage.info('创建解决方案功能开发中...')
}

const viewSolution = (solution) => {
  ElMessage.info(`查看解决方案: ${solution.title}`)
}

// AI模型相关方法
const trainModel = (model) => {
  ElMessage.success(`开始训练模型: ${model.name}`)
}

const testModel = (model) => {
  ElMessage.success(`开始测试模型: ${model.name}`)
}

const toggleModel = (model) => {
  model.status = model.status === 'active' ? 'inactive' : 'active'
  ElMessage.success(`模型 ${model.name} 已${model.status === 'active' ? '启动' : '停止'}`)
}

const startTraining = () => {
  ElMessage.success('开始训练AI模型')
}

// 工具方法
const getSolutionType = (confidence) => {
  if (confidence >= 80) return 'success'
  if (confidence >= 60) return 'warning'
  return 'danger'
}

const getUrgencyType = (urgency) => {
  const types = {
    low: 'info',
    medium: 'warning',
    high: 'danger',
    critical: 'danger'
  }
  return types[urgency] || 'info'
}

const getUrgencyText = (urgency) => {
  const texts = {
    low: '低',
    medium: '中',
    high: '高',
    critical: '紧急'
  }
  return texts[urgency] || urgency
}

const getCategoryType = (category) => {
  const types = {
    network: 'primary',
    server: 'success',
    application: 'warning',
    database: 'danger'
  }
  return types[category] || 'info'
}

const getCategoryText = (category) => {
  const texts = {
    network: '网络',
    server: '服务器',
    application: '应用',
    database: '数据库'
  }
  return texts[category] || category
}

const getDifficultyType = (difficulty) => {
  const types = {
    easy: 'success',
    medium: 'warning',
    hard: 'danger'
  }
  return types[difficulty] || 'info'
}

const getDifficultyText = (difficulty) => {
  const texts = {
    easy: '简单',
    medium: '中等',
    hard: '困难'
  }
  return texts[difficulty] || difficulty
}

const getModelTypeColor = (type) => {
  const colors = {
    classification: 'primary',
    nlp: 'success',
    recommendation: 'warning'
  }
  return colors[type] || 'info'
}

const getModelTypeText = (type) => {
  const texts = {
    classification: '分类',
    nlp: '自然语言',
    recommendation: '推荐'
  }
  return texts[type] || type
}

onMounted(() => {
  console.log('AI智能分析模块已加载')
})
</script>

<style scoped>
.ai-analysis-demo {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  background: white;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.page-header h1 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 24px;
}

.page-header p {
  margin: 0;
  color: #606266;
  font-size: 14px;
}

.demo-tabs {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.tab-content {
  padding: 20px;
}

/* 聊天容器样式 */
.chat-container {
  display: flex;
  height: 700px;
  gap: 20px;
}

.chat-sidebar {
  width: 280px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.chat-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: white;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  overflow: hidden;
}

/* 聊天历史样式 */
.chat-history {
  background: white;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  padding: 16px;
  flex: 1;
}

.history-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.history-header h3 {
  margin: 0;
  color: #303133;
  font-size: 16px;
}

.history-list {
  max-height: 300px;
  overflow-y: auto;
}

.history-item {
  padding: 12px;
  border-radius: 6px;
  cursor: pointer;
  margin-bottom: 8px;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.history-item:hover {
  background: #f5f7fa;
}

.history-item.active {
  background: #e6f7ff;
  border-color: #409eff;
}

.session-title {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
  margin-bottom: 4px;
}

.session-time {
  font-size: 12px;
  color: #909399;
}

/* 快捷问题样式 */
.quick-questions {
  background: white;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  padding: 16px;
}

.quick-questions h4 {
  margin: 0 0 12px 0;
  color: #303133;
  font-size: 14px;
}

.question-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.question-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 13px;
  color: #606266;
}

.question-item:hover {
  background: #f5f7fa;
  color: #409eff;
}

/* 聊天消息样式 */
.chat-messages {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  background: #fafafa;
}

.message-item {
  display: flex;
  margin-bottom: 20px;
  align-items: flex-start;
  gap: 12px;
}

.message-item.user {
  flex-direction: row-reverse;
}

.message-item.user .message-content {
  background: #409eff;
  color: white;
  border-radius: 18px 18px 4px 18px;
}

.message-item.ai .message-content {
  background: white;
  border: 1px solid #e4e7ed;
  border-radius: 18px 18px 18px 4px;
}

.message-avatar {
  flex-shrink: 0;
}

.message-content {
  max-width: 70%;
  padding: 12px 16px;
  position: relative;
}

.message-text {
  line-height: 1.5;
  margin-bottom: 8px;
}

.message-text:last-child {
  margin-bottom: 0;
}

.message-time {
  font-size: 12px;
  opacity: 0.7;
  margin-top: 4px;
}

.message-actions {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}

/* AI思考动画 */
.thinking .message-content {
  background: white;
  border: 1px solid #e4e7ed;
}

.thinking-animation {
  display: flex;
  gap: 4px;
  margin-bottom: 8px;
}

.thinking-animation span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #409eff;
  animation: thinking 1.4s infinite ease-in-out;
}

.thinking-animation span:nth-child(1) {
  animation-delay: -0.32s;
}

.thinking-animation span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes thinking {
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
}

/* 聊天输入样式 */
.chat-input {
  border-top: 1px solid #e4e7ed;
  background: white;
}

.input-toolbar {
  padding: 12px 16px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  gap: 8px;
}

.input-area {
  padding: 16px;
}

.input-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
}

.input-tips {
  font-size: 12px;
  color: #909399;
}

/* 故障诊断样式 */
.diagnosis-container {
  background: white;
  border-radius: 8px;
  padding: 0;
}

.diagnosis-wizard {
  padding: 24px;
}

.step-content {
  margin: 32px 0;
  min-height: 300px;
}

.step-content h3 {
  margin: 0 0 20px 0;
  color: #303133;
  font-size: 18px;
}

.wizard-actions {
  margin-top: 32px;
  text-align: center;
  padding-top: 24px;
  border-top: 1px solid #e4e7ed;
}

/* 分析进度样式 */
.analysis-progress {
  text-align: center;
  padding: 40px 20px;
}

.analysis-progress h3 {
  margin-bottom: 24px;
  color: #303133;
}

.analysis-steps {
  margin-top: 32px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-width: 300px;
  margin-left: auto;
  margin-right: auto;
}

.analysis-step {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-radius: 8px;
  background: #f8f9fa;
  transition: all 0.3s ease;
}

.analysis-step.active {
  background: #e6f7ff;
  border: 1px solid #409eff;
}

.analysis-step.completed {
  background: #f0f9ff;
  color: #67c23a;
}

/* 解决方案样式 */
.solutions {
  max-height: 400px;
  overflow-y: auto;
}

.solution-item {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 16px;
  border: 1px solid #e4e7ed;
}

.solution-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.solution-header h4 {
  margin: 0;
  color: #303133;
  font-size: 16px;
}

.solution-description {
  margin: 0 0 16px 0;
  color: #606266;
  line-height: 1.5;
}

.solution-steps {
  margin-bottom: 16px;
}

.solution-steps h5 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 14px;
}

.solution-steps ol {
  margin: 0;
  padding-left: 20px;
  color: #606266;
}

.solution-steps li {
  margin-bottom: 4px;
  line-height: 1.4;
}

.solution-actions {
  display: flex;
  gap: 8px;
}

/* 诊断历史样式 */
.diagnosis-history {
  margin-bottom: 20px;
}

.history-record {
  padding: 12px;
  border-radius: 6px;
  cursor: pointer;
  margin-bottom: 8px;
  transition: all 0.3s ease;
  border: 1px solid #f0f0f0;
}

.history-record:hover {
  background: #f5f7fa;
  border-color: #409eff;
}

.record-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.record-title {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

.record-time {
  font-size: 12px;
  color: #909399;
  margin-bottom: 8px;
}

.record-status {
  text-align: right;
}

/* AI统计样式 */
.ai-stats {
  margin-top: 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.stat-item {
  text-align: center;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-item .stat-number {
  font-size: 20px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
}

.stat-item .stat-label {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

/* 解决方案容器样式 */
.solutions-container {
  background: white;
  border-radius: 8px;
  padding: 0;
}

.solutions-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e4e7ed;
  flex-wrap: wrap;
  gap: 16px;
}

.search-bar {
  display: flex;
  gap: 12px;
  align-items: center;
}

.toolbar-actions {
  display: flex;
  gap: 12px;
}

.solutions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
  padding: 20px;
}

.solution-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  border: 1px solid #e4e7ed;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.solution-card:hover {
  border-color: #409eff;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
  transform: translateY(-2px);
}

.solution-card .solution-header {
  margin-bottom: 12px;
}

.solution-card .solution-header h3 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 500;
}

.solution-meta {
  display: flex;
  gap: 8px;
}

.solution-card .solution-description {
  margin: 0 0 16px 0;
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
}

.solution-stats {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
}

.solution-stats .stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #909399;
}

.solution-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #909399;
}

.solution-author {
  font-weight: 500;
}

/* 模型管理样式 */
.models-container {
  background: white;
  border-radius: 8px;
  padding: 0;
}

.model-performance {
  margin-bottom: 20px;
}

.performance-metrics {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.metric-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14px;
}

.metric-label {
  color: #909399;
}

.metric-value {
  color: #303133;
  font-weight: 500;
}

.training-config {
  margin-top: 20px;
}

/* 分页样式 */
.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
  padding: 0 20px 20px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .ai-analysis-demo {
    padding: 10px;
  }

  .chat-container {
    flex-direction: column;
    height: auto;
  }

  .chat-sidebar {
    width: 100%;
    order: 2;
  }

  .chat-main {
    order: 1;
    height: 500px;
  }

  .solutions-grid {
    grid-template-columns: 1fr;
  }

  .solutions-toolbar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-bar {
    flex-direction: column;
  }

  .search-bar .el-input,
  .search-bar .el-select {
    width: 100% !important;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }
}

/* 表格样式优化 */
.el-table {
  border-radius: 8px;
  overflow: hidden;
}

.el-table .el-table__header {
  background: #f8f9fa;
}

.el-table .el-table__row:hover {
  background: #f5f7fa;
}

/* 卡片样式 */
.el-card {
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.el-card .el-card__header {
  background: #f8f9fa;
  border-bottom: 1px solid #e4e7ed;
}

/* 按钮样式 */
.el-button {
  border-radius: 6px;
}

/* 标签页样式 */
.demo-tabs .el-tabs__header {
  background: #f8f9fa;
  margin: 0;
  padding: 0 20px;
}

.demo-tabs .el-tabs__content {
  padding: 0;
}

/* 步骤条样式 */
.el-steps {
  margin-bottom: 32px;
}

/* 进度条样式 */
.el-progress {
  margin: 24px 0;
}

/* 表单样式 */
.el-form-item {
  margin-bottom: 18px;
}

.el-input, .el-select, .el-textarea {
  border-radius: 6px;
}

/* 代码样式 */
code {
  background: #f5f5f5;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 13px;
  color: #e6a23c;
}

/* 滚动条样式 */
.chat-messages::-webkit-scrollbar,
.history-list::-webkit-scrollbar,
.solutions::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track,
.history-list::-webkit-scrollbar-track,
.solutions::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb,
.history-list::-webkit-scrollbar-thumb,
.solutions::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover,
.history-list::-webkit-scrollbar-thumb:hover,
.solutions::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
