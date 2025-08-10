<template>
  <div class="engineer-profile">
    <!-- 面包屑导航 -->
    <el-breadcrumb class="breadcrumb" separator="/">
      <el-breadcrumb-item :to="{ name: 'Engineers' }">工程师管理</el-breadcrumb-item>
      <el-breadcrumb-item>{{ engineerInfo.name }}的档案</el-breadcrumb-item>
    </el-breadcrumb>

    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon><User /></el-icon>
          工程师档案管理
        </h1>
        <p class="page-description">管理工程师个人档案、技能认证和考核记录</p>
      </div>
      <div class="header-actions">
        <el-button @click="goBackToManagement">
          <el-icon><ArrowLeft /></el-icon>
          返回工程师管理
        </el-button>
        <el-button type="primary" @click="editProfile">
          <el-icon><Edit /></el-icon>
          编辑档案
        </el-button>
        <el-button @click="exportProfile">
          <el-icon><Download /></el-icon>
          导出档案
        </el-button>
      </div>
    </div>

    <el-row :gutter="20">
      <!-- 左侧个人信息 -->
      <el-col :span="8">
        <el-card class="profile-card">
          <div class="profile-header">
            <el-avatar :size="80" :src="engineerInfo.avatar">
              {{ engineerInfo.name?.charAt(0) }}
            </el-avatar>
            <div class="profile-info">
              <h3>{{ engineerInfo.name }}</h3>
              <p class="job-title">{{ engineerInfo.jobTitle }}</p>
              <p class="department">{{ engineerInfo.department }}</p>
            </div>
          </div>

          <div class="profile-stats">
            <div class="stat-item">
              <span class="stat-label">工作年限</span>
              <span class="stat-value">{{ engineerInfo.workYears }}年</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">技能认证</span>
              <span class="stat-value">{{ certifiedSkills.length }}项</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">完成工单</span>
              <span class="stat-value">{{ engineerInfo.completedTickets }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">客户评分</span>
              <el-rate v-model="engineerInfo.rating" disabled show-score />
            </div>
          </div>

          <div class="contact-info">
            <h4>联系信息</h4>
            <div class="contact-item">
              <el-icon><Message /></el-icon>
              <span>{{ engineerInfo.email }}</span>
            </div>
            <div class="contact-item">
              <el-icon><Phone /></el-icon>
              <span>{{ engineerInfo.phone }}</span>
            </div>
            <div class="contact-item">
              <el-icon><Location /></el-icon>
              <span>{{ engineerInfo.location }}</span>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧详细信息 -->
      <el-col :span="16">
        <el-tabs v-model="activeTab" class="profile-tabs">
          <!-- 技能管理 -->
          <el-tab-pane label="技能管理" name="skills">
            <el-card>
              <template #header>
                <div class="card-header">
                  <span>技能认证</span>
                  <el-button type="primary" size="small" @click="showSkillDialog = true">
                    <el-icon><Plus /></el-icon>
                    添加技能
                  </el-button>
                </div>
              </template>

              <div class="skills-grid">
                <div
                  v-for="skill in engineerSkills"
                  :key="skill.id"
                  class="skill-card"
                  :class="{ certified: skill.certified }"
                >
                  <div class="skill-header">
                    <h4>{{ skill.name }}</h4>
                    <div class="skill-actions">
                      <el-button 
                        v-if="!skill.certified" 
                        size="small" 
                        type="primary"
                        @click="takeExam(skill)"
                      >
                        参加考试
                      </el-button>
                      <el-button size="small" @click="viewSkillDetail(skill)">
                        查看详情
                      </el-button>
                    </div>
                  </div>
                  
                  <div class="skill-level">
                    <span class="level-label">技能等级：</span>
                    <el-tag :type="getSkillLevelType(skill.level)">
                      {{ getSkillLevelText(skill.level) }}
                    </el-tag>
                  </div>
                  
                  <div class="skill-progress">
                    <span class="progress-label">掌握程度：</span>
                    <el-progress 
                      :percentage="skill.proficiency" 
                      :color="getProgressColor(skill.proficiency)"
                      :stroke-width="6"
                    />
                  </div>
                  
                  <div class="skill-certification" v-if="skill.certified">
                    <el-icon class="cert-icon"><Medal /></el-icon>
                    <span class="cert-text">已认证</span>
                    <span class="cert-date">{{ skill.certDate }}</span>
                  </div>
                  
                  <div class="skill-exam" v-else-if="skill.examTaken">
                    <el-icon class="exam-icon"><Clock /></el-icon>
                    <span class="exam-text">考试成绩：{{ skill.examScore }}分</span>
                    <span class="exam-status" :class="skill.examScore >= 80 ? 'pass' : 'fail'">
                      {{ skill.examScore >= 80 ? '通过' : '未通过' }}
                    </span>
                  </div>
                </div>
              </div>
            </el-card>
          </el-tab-pane>

          <!-- 考核记录 -->
          <el-tab-pane label="考核记录" name="exams">
            <el-card>
              <template #header>
                <div class="card-header">
                  <span>考核历史</span>
                  <el-button type="primary" size="small" @click="scheduleExam">
                    <el-icon><Calendar /></el-icon>
                    安排考核
                  </el-button>
                </div>
              </template>

              <el-table :data="examRecords" style="width: 100%">
                <el-table-column prop="skillName" label="技能名称" width="150" />
                <el-table-column prop="examDate" label="考试时间" width="120" />
                <el-table-column prop="examType" label="考试类型" width="100">
                  <template #default="{ row }">
                    <el-tag size="small" :type="row.examType === '认证考试' ? 'primary' : 'info'">
                      {{ row.examType }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="score" label="成绩" width="80">
                  <template #default="{ row }">
                    <span :class="row.score >= 80 ? 'score-pass' : 'score-fail'">
                      {{ row.score }}分
                    </span>
                  </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag size="small" :type="getExamStatusType(row.status)">
                      {{ row.status }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="examiner" label="考官" width="100" />
                <el-table-column label="操作" width="120">
                  <template #default="{ row }">
                    <el-button size="small" @click="viewExamDetail(row)">
                      查看详情
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-tab-pane>

          <!-- 工作记录 -->
          <el-tab-pane label="工作记录" name="work">
            <el-card>
              <template #header>
                <span>工作履历</span>
              </template>

              <el-timeline>
                <el-timeline-item
                  v-for="record in workRecords"
                  :key="record.id"
                  :timestamp="record.date"
                  placement="top"
                >
                  <el-card class="work-record-card">
                    <h4>{{ record.title }}</h4>
                    <p class="record-description">{{ record.description }}</p>
                    <div class="record-tags">
                      <el-tag
                        v-for="tag in record.tags"
                        :key="tag"
                        size="small"
                        class="record-tag"
                      >
                        {{ tag }}
                      </el-tag>
                    </div>
                  </el-card>
                </el-timeline-item>
              </el-timeline>
            </el-card>
          </el-tab-pane>

          <!-- 培训计划 -->
          <el-tab-pane label="培训计划" name="training">
            <el-card>
              <template #header>
                <div class="card-header">
                  <span>培训安排</span>
                  <el-button type="primary" size="small" @click="addTraining">
                    <el-icon><Plus /></el-icon>
                    添加培训
                  </el-button>
                </div>
              </template>

              <div class="training-list">
                <div
                  v-for="training in trainingPlans"
                  :key="training.id"
                  class="training-item"
                >
                  <div class="training-info">
                    <h4>{{ training.title }}</h4>
                    <p>{{ training.description }}</p>
                    <div class="training-meta">
                      <span class="training-date">{{ training.startDate }} - {{ training.endDate }}</span>
                      <el-tag size="small" :type="getTrainingStatusType(training.status)">
                        {{ training.status }}
                      </el-tag>
                    </div>
                  </div>
                  <div class="training-progress">
                    <el-progress 
                      :percentage="training.progress" 
                      :status="training.progress === 100 ? 'success' : null"
                    />
                  </div>
                </div>
              </div>
            </el-card>
          </el-tab-pane>
        </el-tabs>
      </el-col>
    </el-row>

    <!-- 技能添加对话框 -->
    <el-dialog v-model="showSkillDialog" title="添加技能" width="600px">
      <el-form :model="newSkill" label-width="100px">
        <el-form-item label="技能名称">
          <el-select v-model="newSkill.name" placeholder="请选择技能" filterable allow-create>
            <el-option
              v-for="skill in availableSkills"
              :key="skill"
              :label="skill"
              :value="skill"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="技能等级">
          <el-select v-model="newSkill.level" placeholder="请选择等级">
            <el-option label="初级" :value="1" />
            <el-option label="中级" :value="2" />
            <el-option label="高级" :value="3" />
            <el-option label="专家" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item label="掌握程度">
          <el-slider v-model="newSkill.proficiency" :max="100" show-input />
        </el-form-item>
        <el-form-item label="技能描述">
          <el-input v-model="newSkill.description" type="textarea" rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showSkillDialog = false">取消</el-button>
        <el-button type="primary" @click="addSkill">添加</el-button>
      </template>
    </el-dialog>

    <!-- 考试对话框 -->
    <el-dialog v-model="showExamDialog" title="技能考试" width="800px">
      <div v-if="currentExam" class="exam-content">
        <div class="exam-header">
          <h3>{{ currentExam.skillName }} 认证考试</h3>
          <div class="exam-info">
            <span>考试时间：{{ currentExam.duration }}分钟</span>
            <span>及格分数：80分</span>
            <span>题目数量：{{ currentExam.questions?.length }}题</span>
          </div>
        </div>

        <div class="exam-questions" v-if="!examCompleted">
          <div class="question-progress">
            <span>第 {{ currentQuestionIndex + 1 }} 题 / 共 {{ currentExam.questions?.length }} 题</span>
            <el-progress :percentage="((currentQuestionIndex + 1) / currentExam.questions?.length) * 100" />
          </div>

          <div class="question-content" v-if="currentQuestion">
            <h4>{{ currentQuestion.question }}</h4>
            <el-radio-group v-model="currentAnswer" class="question-options">
              <el-radio
                v-for="(option, index) in currentQuestion.options"
                :key="index"
                :label="index"
                class="question-option"
              >
                {{ option }}
              </el-radio>
            </el-radio-group>
          </div>

          <div class="exam-actions">
            <el-button @click="prevQuestion" :disabled="currentQuestionIndex === 0">
              上一题
            </el-button>
            <el-button 
              type="primary" 
              @click="nextQuestion"
              v-if="currentQuestionIndex < currentExam.questions?.length - 1"
            >
              下一题
            </el-button>
            <el-button 
              type="success" 
              @click="submitExam"
              v-else
            >
              提交考试
            </el-button>
          </div>
        </div>

        <div class="exam-result" v-else>
          <div class="result-header">
            <el-icon class="result-icon" :class="examResult.passed ? 'pass' : 'fail'">
              <component :is="examResult.passed ? 'CircleCheck' : 'CircleClose'" />
            </el-icon>
            <h3>考试{{ examResult.passed ? '通过' : '未通过' }}</h3>
          </div>
          <div class="result-details">
            <p>考试成绩：{{ examResult.score }}分</p>
            <p>正确率：{{ examResult.accuracy }}%</p>
            <p>用时：{{ examResult.timeUsed }}分钟</p>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="showExamDialog = false">关闭</el-button>
        <el-button v-if="examCompleted && examResult.passed" type="primary" @click="applyCertification">
          申请认证
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  User, Edit, Download, Message, Phone, Location, Plus, Medal, Clock,
  Calendar, CircleCheck, CircleClose, ArrowLeft
} from '@element-plus/icons-vue'

// 路由实例
const route = useRoute()
const router = useRouter()

// 获取工程师ID
const engineerId = computed(() => route.params.engineerId)

// 响应式数据
const activeTab = ref('skills')
const showSkillDialog = ref(false)
const showExamDialog = ref(false)
const examCompleted = ref(false)
const currentQuestionIndex = ref(0)
const currentAnswer = ref(null)
const examAnswers = ref([])

// 工程师信息
const engineerInfo = ref({
  id: '1',
  name: '张工程师',
  jobTitle: '高级运维工程师',
  department: '技术运维部',
  avatar: '',
  workYears: 5,
  completedTickets: 156,
  rating: 4.5,
  email: 'zhang.engineer@company.com',
  phone: '138-0000-0000',
  location: '北京市朝阳区'
})

// 工程师技能
const engineerSkills = ref([
  {
    id: '1',
    name: 'Linux系统管理',
    level: 3,
    proficiency: 85,
    certified: true,
    certDate: '2023-06-15',
    examTaken: true,
    examScore: 92
  },
  {
    id: '2',
    name: 'Docker容器技术',
    level: 2,
    proficiency: 75,
    certified: false,
    examTaken: true,
    examScore: 78
  },
  {
    id: '3',
    name: 'Kubernetes编排',
    level: 2,
    proficiency: 60,
    certified: false,
    examTaken: false,
    examScore: null
  }
])

// 可用技能列表
const availableSkills = ref([
  'Linux系统管理', 'Windows系统管理', 'Docker容器技术', 'Kubernetes编排',
  'MySQL数据库', 'PostgreSQL数据库', 'Redis缓存', 'Nginx配置',
  'Apache配置', '网络故障排查', '防火墙配置', 'VPN配置',
  'Java应用运维', 'Python应用运维', 'Node.js应用运维', 'PHP应用运维',
  '监控系统部署', '日志分析', '性能优化', '安全加固'
])

// 新技能表单
const newSkill = reactive({
  name: '',
  level: 1,
  proficiency: 50,
  description: ''
})

// 考核记录
const examRecords = ref([
  {
    id: '1',
    skillName: 'Linux系统管理',
    examDate: '2023-06-15',
    examType: '认证考试',
    score: 92,
    status: '通过',
    examiner: '李主管'
  },
  {
    id: '2',
    skillName: 'Docker容器技术',
    examDate: '2023-08-20',
    examType: '技能评估',
    score: 78,
    status: '未通过',
    examiner: '王专家'
  }
])

// 工作记录
const workRecords = ref([
  {
    id: '1',
    date: '2023-12-01',
    title: '完成生产环境Kubernetes集群升级',
    description: '成功将生产环境的Kubernetes集群从v1.25升级到v1.28，确保零停机时间',
    tags: ['Kubernetes', '集群升级', '生产环境']
  },
  {
    id: '2',
    date: '2023-11-15',
    title: '解决数据库性能瓶颈问题',
    description: '通过索引优化和查询调优，将数据库响应时间从2秒降低到200ms',
    tags: ['MySQL', '性能优化', '数据库调优']
  }
])

// 培训计划
const trainingPlans = ref([
  {
    id: '1',
    title: 'Kubernetes高级运维培训',
    description: '深入学习Kubernetes集群管理、故障排查和性能优化',
    startDate: '2024-01-15',
    endDate: '2024-02-15',
    status: '进行中',
    progress: 65
  },
  {
    id: '2',
    title: '云原生安全最佳实践',
    description: '学习容器安全、网络安全和数据保护的最佳实践',
    startDate: '2024-03-01',
    endDate: '2024-03-31',
    status: '计划中',
    progress: 0
  }
])

// 当前考试
const currentExam = ref(null)

// 计算属性
const certifiedSkills = computed(() => {
  return engineerSkills.value.filter(skill => skill.certified)
})

const currentQuestion = computed(() => {
  if (!currentExam.value?.questions) return null
  return currentExam.value.questions[currentQuestionIndex.value]
})

const examResult = ref({
  score: 0,
  accuracy: 0,
  timeUsed: 0,
  passed: false
})

// 方法
const getSkillLevelType = (level) => {
  const types = { 1: 'info', 2: 'warning', 3: 'success', 4: 'danger' }
  return types[level] || 'info'
}

const getSkillLevelText = (level) => {
  const texts = { 1: '初级', 2: '中级', 3: '高级', 4: '专家' }
  return texts[level] || '未知'
}

const getProgressColor = (percentage) => {
  if (percentage >= 80) return '#67c23a'
  if (percentage >= 60) return '#e6a23c'
  return '#f56c6c'
}

const getExamStatusType = (status) => {
  const types = { '通过': 'success', '未通过': 'danger', '待考试': 'warning' }
  return types[status] || 'info'
}

const getTrainingStatusType = (status) => {
  const types = { '已完成': 'success', '进行中': 'primary', '计划中': 'info' }
  return types[status] || 'info'
}

const editProfile = () => {
  ElMessage.info('编辑档案功能开发中...')
}

const exportProfile = () => {
  ElMessage.success('档案导出成功')
}

const addSkill = () => {
  if (!newSkill.name) {
    ElMessage.error('请选择技能名称')
    return
  }

  const skill = {
    id: Date.now().toString(),
    name: newSkill.name,
    level: newSkill.level,
    proficiency: newSkill.proficiency,
    certified: false,
    examTaken: false,
    examScore: null,
    description: newSkill.description
  }

  engineerSkills.value.push(skill)
  showSkillDialog.value = false
  
  // 重置表单
  Object.assign(newSkill, {
    name: '',
    level: 1,
    proficiency: 50,
    description: ''
  })
  
  ElMessage.success('技能添加成功')
}

const takeExam = (skill) => {
  // 模拟考试题目
  currentExam.value = {
    skillName: skill.name,
    duration: 60,
    questions: [
      {
        question: `关于${skill.name}，以下哪个说法是正确的？`,
        options: ['选项A', '选项B', '选项C', '选项D'],
        correct: 0
      },
      {
        question: `在${skill.name}实践中，最重要的是什么？`,
        options: ['安全性', '性能', '可维护性', '以上都是'],
        correct: 3
      },
      {
        question: `${skill.name}的最佳实践包括哪些？`,
        options: ['定期备份', '监控告警', '文档记录', '以上都是'],
        correct: 3
      }
    ]
  }
  
  examCompleted.value = false
  currentQuestionIndex.value = 0
  currentAnswer.value = null
  examAnswers.value = []
  showExamDialog.value = true
}

const nextQuestion = () => {
  examAnswers.value[currentQuestionIndex.value] = currentAnswer.value
  currentQuestionIndex.value++
  currentAnswer.value = examAnswers.value[currentQuestionIndex.value] || null
}

const prevQuestion = () => {
  examAnswers.value[currentQuestionIndex.value] = currentAnswer.value
  currentQuestionIndex.value--
  currentAnswer.value = examAnswers.value[currentQuestionIndex.value] || null
}

const submitExam = () => {
  examAnswers.value[currentQuestionIndex.value] = currentAnswer.value
  
  // 计算成绩
  let correctCount = 0
  currentExam.value.questions.forEach((question, index) => {
    if (examAnswers.value[index] === question.correct) {
      correctCount++
    }
  })
  
  const score = Math.round((correctCount / currentExam.value.questions.length) * 100)
  const accuracy = Math.round((correctCount / currentExam.value.questions.length) * 100)
  
  examResult.value = {
    score,
    accuracy,
    timeUsed: Math.floor(Math.random() * 45) + 15, // 模拟用时
    passed: score >= 80
  }
  
  examCompleted.value = true
  
  // 更新技能记录
  const skill = engineerSkills.value.find(s => s.name === currentExam.value.skillName)
  if (skill) {
    skill.examTaken = true
    skill.examScore = score
    if (score >= 80) {
      skill.certified = true
      skill.certDate = new Date().toLocaleDateString()
    }
  }
  
  // 添加考核记录
  examRecords.value.unshift({
    id: Date.now().toString(),
    skillName: currentExam.value.skillName,
    examDate: new Date().toLocaleDateString(),
    examType: '认证考试',
    score,
    status: score >= 80 ? '通过' : '未通过',
    examiner: '系统自动'
  })
}

const applyCertification = () => {
  ElMessage.success('认证申请已提交，等待审核')
  showExamDialog.value = false
}

const viewSkillDetail = (skill) => {
  ElMessage.info(`查看技能详情: ${skill.name}`)
}

const viewExamDetail = (exam) => {
  ElMessage.info(`查看考试详情: ${exam.skillName}`)
}

const scheduleExam = () => {
  ElMessage.info('安排考核功能开发中...')
}

const addTraining = () => {
  ElMessage.info('添加培训功能开发中...')
}

// 返回工程师管理页面
const goBackToManagement = () => {
  router.push({ name: 'PersonnelEngineers' })
}

// 根据工程师ID加载数据
const loadEngineerData = (id) => {
  // 模拟根据ID加载工程师数据
  const mockEngineers = {
    '1': {
      id: '1',
      name: '张工程师',
      jobTitle: '高级运维工程师',
      department: '技术运维部',
      avatar: '',
      workYears: 5,
      completedTickets: 156,
      rating: 4.5,
      email: 'zhang.engineer@company.com',
      phone: '138-0000-0000',
      location: '北京市朝阳区'
    },
    '2': {
      id: '2',
      name: '李工程师',
      jobTitle: '中级运维工程师',
      department: '网络运维部',
      avatar: '',
      workYears: 3,
      completedTickets: 89,
      rating: 4.2,
      email: 'li.engineer@company.com',
      phone: '138-1111-1111',
      location: '上海市浦东新区'
    },
    '3': {
      id: '3',
      name: '王工程师',
      jobTitle: '初级运维工程师',
      department: '应用运维部',
      avatar: '',
      workYears: 2,
      completedTickets: 45,
      rating: 3.8,
      email: 'wang.engineer@company.com',
      phone: '138-2222-2222',
      location: '深圳市南山区'
    }
  }

  const engineer = mockEngineers[id]
  if (engineer) {
    Object.assign(engineerInfo.value, engineer)
  } else {
    ElMessage.error('工程师信息不存在')
    goBackToManagement()
  }
}

onMounted(() => {
  // 根据路由参数加载工程师数据
  if (engineerId.value) {
    loadEngineerData(engineerId.value)
  } else {
    ElMessage.error('缺少工程师ID参数')
    goBackToManagement()
  }
})
</script>

<style scoped>
.engineer-profile {
  padding: 20px;
}

.breadcrumb {
  margin-bottom: 16px;
  padding: 12px 0;
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

.profile-card {
  height: fit-content;
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  margin-bottom: 20px;
}

.profile-info h3 {
  margin: 10px 0 5px 0;
  font-size: 20px;
  color: #303133;
}

.job-title {
  margin: 0 0 5px 0;
  color: #409eff;
  font-weight: 500;
}

.department {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.profile-stats {
  margin-bottom: 20px;
  padding: 15px 0;
  border-top: 1px solid #ebeef5;
  border-bottom: 1px solid #ebeef5;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.stat-label {
  color: #909399;
  font-size: 14px;
}

.stat-value {
  font-weight: 500;
  color: #303133;
}

.contact-info h4 {
  margin: 0 0 15px 0;
  color: #303133;
  font-size: 16px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  color: #606266;
  font-size: 14px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.skills-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.skill-card {
  padding: 20px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fafafa;
  transition: all 0.3s ease;
}

.skill-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.skill-card.certified {
  border-color: #67c23a;
  background: #f0f9ff;
}

.skill-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
}

.skill-header h4 {
  margin: 0;
  color: #303133;
  font-size: 16px;
}

.skill-actions {
  display: flex;
  gap: 8px;
}

.skill-level,
.skill-progress {
  margin-bottom: 10px;
  font-size: 14px;
}

.level-label,
.progress-label {
  color: #909399;
  margin-right: 8px;
}

.skill-certification {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #67c23a;
  font-size: 14px;
}

.cert-icon {
  color: #f7ba2a;
}

.cert-date {
  color: #909399;
  font-size: 12px;
}

.skill-exam {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.exam-status.pass {
  color: #67c23a;
}

.exam-status.fail {
  color: #f56c6c;
}

.score-pass {
  color: #67c23a;
  font-weight: 600;
}

.score-fail {
  color: #f56c6c;
  font-weight: 600;
}

.work-record-card {
  margin-bottom: 0;
}

.work-record-card h4 {
  margin: 0 0 8px 0;
  color: #303133;
}

.record-description {
  margin: 0 0 10px 0;
  color: #606266;
  line-height: 1.5;
}

.record-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.training-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.training-item {
  padding: 16px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  background: #fafafa;
}

.training-info h4 {
  margin: 0 0 8px 0;
  color: #303133;
}

.training-info p {
  margin: 0 0 10px 0;
  color: #606266;
}

.training-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.training-date {
  color: #909399;
  font-size: 14px;
}

.exam-content {
  padding: 20px 0;
}

.exam-header {
  text-align: center;
  margin-bottom: 30px;
}

.exam-header h3 {
  margin: 0 0 10px 0;
  color: #303133;
}

.exam-info {
  display: flex;
  justify-content: center;
  gap: 20px;
  color: #909399;
  font-size: 14px;
}

.question-progress {
  margin-bottom: 20px;
}

.question-content {
  margin-bottom: 30px;
}

.question-content h4 {
  margin: 0 0 20px 0;
  color: #303133;
  line-height: 1.6;
}

.question-options {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.question-option {
  padding: 12px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  background: #fafafa;
  margin: 0;
}

.exam-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
}

.exam-result {
  text-align: center;
  padding: 40px 0;
}

.result-header {
  margin-bottom: 30px;
}

.result-icon {
  font-size: 64px;
  margin-bottom: 16px;
}

.result-icon.pass {
  color: #67c23a;
}

.result-icon.fail {
  color: #f56c6c;
}

.result-header h3 {
  margin: 0;
  font-size: 24px;
  color: #303133;
}

.result-details {
  display: flex;
  flex-direction: column;
  gap: 8px;
  color: #606266;
}
</style>
