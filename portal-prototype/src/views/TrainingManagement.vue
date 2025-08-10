<template>
  <div class="training-management">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title">
          <el-icon><Reading /></el-icon>
          培训管理
        </h1>
        <p class="page-description">工程师技能培训计划、课程管理、学习进度跟踪</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="showCreateDialog = true">
          <el-icon><Plus /></el-icon>
          创建培训
        </el-button>
        <el-button @click="importCourses">
          <el-icon><Upload /></el-icon>
          导入课程
        </el-button>
        <el-button @click="exportReport">
          <el-icon><Download /></el-icon>
          导出报告
        </el-button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-container">
      <div class="stats-header">
        <h3 class="stats-title">培训统计</h3>
        <div class="stats-controls">
          <el-date-picker
            v-model="selectedQuarter"
            type="month"
            placeholder="选择季度"
            @change="onQuarterChange"
            size="small"
          />
        </div>
      </div>
      
      <el-collapse-transition>
        <el-row :gutter="16" class="stats-row">
          <el-col :span="6">
            <el-card class="stat-card compact">
              <div class="stat-content">
                <div class="stat-icon total">
                  <el-icon><Reading /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ trainingStats.totalCourses }}</div>
                  <div class="stat-label">总课程数</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card class="stat-card compact">
              <div class="stat-content">
                <div class="stat-icon active">
                  <el-icon><VideoPlay /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ trainingStats.activeCourses }}</div>
                  <div class="stat-label">进行中</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card class="stat-card compact">
              <div class="stat-content">
                <div class="stat-icon completion">
                  <el-icon><CircleCheck /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ trainingStats.completionRate }}%</div>
                  <div class="stat-label">完成率</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card class="stat-card compact">
              <div class="stat-content">
                <div class="stat-icon satisfaction">
                  <el-icon><Star /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-number">{{ trainingStats.satisfaction }}</div>
                  <div class="stat-label">满意度</div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </el-collapse-transition>
    </div>

    <!-- 主要内容区域 -->
    <el-tabs v-model="activeTab" class="training-tabs">
      <!-- 培训计划 -->
      <el-tab-pane label="培训计划" name="plans">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>培训计划列表</span>
              <div class="header-filters">
                <el-select v-model="filterStatus" placeholder="状态筛选" size="small" style="width: 120px;">
                  <el-option label="全部" value="" />
                  <el-option label="计划中" value="planned" />
                  <el-option label="进行中" value="ongoing" />
                  <el-option label="已完成" value="completed" />
                  <el-option label="已暂停" value="paused" />
                </el-select>
                <el-select v-model="filterDepartment" placeholder="部门筛选" size="small" style="width: 120px;">
                  <el-option label="全部" value="" />
                  <el-option label="系统运维" value="系统运维" />
                  <el-option label="网络运维" value="网络运维" />
                  <el-option label="应用运维" value="应用运维" />
                </el-select>
              </div>
            </div>
          </template>

          <el-table :data="filteredTrainings" style="width: 100%">
            <el-table-column prop="title" label="培训名称" width="200" />
            <el-table-column prop="category" label="类别" width="120" />
            <el-table-column prop="instructor" label="讲师" width="100" />
            <el-table-column prop="startDate" label="开始时间" width="120" />
            <el-table-column prop="duration" label="时长" width="80">
              <template #default="{ row }">
                {{ row.duration }}小时
              </template>
            </el-table-column>
            <el-table-column prop="participants" label="参与人数" width="100">
              <template #default="{ row }">
                {{ row.enrolledCount }}/{{ row.maxParticipants }}
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)" size="small">
                  {{ getStatusText(row.status) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="progress" label="进度" width="120">
              <template #default="{ row }">
                <el-progress 
                  :percentage="row.progress" 
                  :stroke-width="6"
                  :show-text="false"
                />
                <span class="progress-text">{{ row.progress }}%</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200">
              <template #default="{ row }">
                <el-button size="small" @click="viewTraining(row)">查看</el-button>
                <el-button size="small" @click="editTraining(row)">编辑</el-button>
                <el-button v-if="row.status === 'planned'" size="small" type="primary" @click="startTraining(row)">
                  开始
                </el-button>
                <el-button v-if="row.status === 'ongoing'" size="small" type="warning" @click="pauseTraining(row)">
                  暂停
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 课程库 -->
      <el-tab-pane label="课程库" name="courses">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>课程资源库</span>
              <el-button type="primary" size="small" @click="showCourseDialog = true">
                <el-icon><Plus /></el-icon>
                添加课程
              </el-button>
            </div>
          </template>

          <div class="course-grid">
            <div 
              v-for="course in courses" 
              :key="course.id"
              class="course-card"
            >
              <div class="course-cover">
                <img :src="course.cover || '/default-course.jpg'" :alt="course.title" />
                <div class="course-overlay">
                  <el-button size="small" @click="previewCourse(course)">预览</el-button>
                  <el-button size="small" @click="editCourse(course)">编辑</el-button>
                </div>
              </div>
              <div class="course-info">
                <h4 class="course-title">{{ course.title }}</h4>
                <p class="course-description">{{ course.description }}</p>
                <div class="course-meta">
                  <span class="course-duration">{{ course.duration }}小时</span>
                  <span class="course-level">{{ course.level }}</span>
                  <el-rate v-model="course.rating" disabled size="small" />
                </div>
                <div class="course-tags">
                  <el-tag 
                    v-for="tag in course.tags" 
                    :key="tag"
                    size="small"
                    class="course-tag"
                  >
                    {{ tag }}
                  </el-tag>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-tab-pane>

      <!-- 学习进度 -->
      <el-tab-pane label="学习进度" name="progress">
        <el-row :gutter="20">
          <el-col :span="16">
            <el-card>
              <template #header>
                <span>学员进度跟踪</span>
              </template>

              <el-table :data="learningProgress" style="width: 100%">
                <el-table-column prop="engineerName" label="学员" width="120" />
                <el-table-column prop="courseName" label="课程" width="200" />
                <el-table-column prop="startDate" label="开始时间" width="120" />
                <el-table-column prop="lastAccess" label="最后访问" width="120" />
                <el-table-column prop="progress" label="进度" width="120">
                  <template #default="{ row }">
                    <el-progress 
                      :percentage="row.progress" 
                      :stroke-width="6"
                      :status="row.progress === 100 ? 'success' : null"
                    />
                  </template>
                </el-table-column>
                <el-table-column prop="score" label="成绩" width="80">
                  <template #default="{ row }">
                    <span v-if="row.score !== null" :class="row.score >= 80 ? 'score-pass' : 'score-fail'">
                      {{ row.score }}分
                    </span>
                    <span v-else class="score-pending">学习中</span>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="120">
                  <template #default="{ row }">
                    <el-button size="small" @click="viewProgress(row)">详情</el-button>
                    <el-button size="small" @click="sendReminder(row)">提醒</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-col>

          <el-col :span="8">
            <el-card class="chart-card">
              <template #header>
                <span>完成率统计</span>
              </template>
              <div ref="progressChart" style="height: 200px;"></div>
            </el-card>

            <el-card class="chart-card" style="margin-top: 20px;">
              <template #header>
                <span>学习时长排行</span>
              </template>
              <div class="learning-ranking">
                <div 
                  v-for="(item, index) in learningRanking" 
                  :key="item.id"
                  class="ranking-item"
                >
                  <div class="ranking-number" :class="`rank-${index + 1}`">{{ index + 1 }}</div>
                  <div class="ranking-info">
                    <div class="engineer-name">{{ item.name }}</div>
                    <div class="learning-hours">{{ item.hours }}小时</div>
                  </div>
                  <div class="ranking-badge">
                    <el-icon v-if="index === 0"><Trophy /></el-icon>
                    <el-icon v-else-if="index === 1"><Medal /></el-icon>
                    <el-icon v-else-if="index === 2"><Star /></el-icon>
                  </div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </el-tab-pane>

      <!-- 培训评估 -->
      <el-tab-pane label="培训评估" name="evaluation">
        <el-card>
          <template #header>
            <span>培训效果评估</span>
          </template>

          <el-row :gutter="20">
            <el-col :span="12">
              <div class="evaluation-chart">
                <h4>满意度评分</h4>
                <div ref="satisfactionChart" style="height: 300px;"></div>
              </div>
            </el-col>
            <el-col :span="12">
              <div class="evaluation-chart">
                <h4>技能提升效果</h4>
                <div ref="skillImprovementChart" style="height: 300px;"></div>
              </div>
            </el-col>
          </el-row>

          <div class="evaluation-feedback">
            <h4>学员反馈</h4>
            <div class="feedback-list">
              <div 
                v-for="feedback in trainingFeedback" 
                :key="feedback.id"
                class="feedback-item"
              >
                <div class="feedback-header">
                  <span class="feedback-author">{{ feedback.author }}</span>
                  <span class="feedback-course">{{ feedback.course }}</span>
                  <el-rate v-model="feedback.rating" disabled size="small" />
                </div>
                <p class="feedback-content">{{ feedback.content }}</p>
                <div class="feedback-meta">
                  <span class="feedback-date">{{ feedback.date }}</span>
                  <el-tag v-if="feedback.helpful" type="success" size="small">有帮助</el-tag>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <!-- 创建培训对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建培训计划" width="800px">
      <el-form :model="createForm" label-width="120px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="培训名称">
              <el-input v-model="createForm.title" placeholder="请输入培训名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="培训类别">
              <el-select v-model="createForm.category" placeholder="请选择类别">
                <el-option label="技术培训" value="技术培训" />
                <el-option label="安全培训" value="安全培训" />
                <el-option label="管理培训" value="管理培训" />
                <el-option label="认证培训" value="认证培训" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="开始时间">
              <el-date-picker
                v-model="createForm.startDate"
                type="datetime"
                placeholder="选择开始时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="培训时长">
              <el-input-number
                v-model="createForm.duration"
                :min="1"
                :max="200"
                placeholder="小时"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="讲师">
              <el-input v-model="createForm.instructor" placeholder="请输入讲师姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="最大人数">
              <el-input-number
                v-model="createForm.maxParticipants"
                :min="1"
                :max="100"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="参与人员">
          <el-select
            v-model="createForm.participants"
            multiple
            filterable
            placeholder="请选择参与人员"
            style="width: 100%"
          >
            <el-option
              v-for="engineer in availableEngineers"
              :key="engineer.id"
              :label="`${engineer.name} (${engineer.department})`"
              :value="engineer.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="培训内容">
          <el-input
            v-model="createForm.description"
            type="textarea"
            :rows="4"
            placeholder="请描述培训内容和目标"
          />
        </el-form-item>

        <el-form-item label="培训方式">
          <el-checkbox-group v-model="createForm.methods">
            <el-checkbox label="线上直播">线上直播</el-checkbox>
            <el-checkbox label="线下面授">线下面授</el-checkbox>
            <el-checkbox label="录播视频">录播视频</el-checkbox>
            <el-checkbox label="实操练习">实操练习</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createTraining">创建培训</el-button>
      </template>
    </el-dialog>

    <!-- 课程详情对话框 -->
    <el-dialog v-model="showCourseDialog" title="添加课程" width="600px">
      <el-form :model="courseForm" label-width="100px">
        <el-form-item label="课程名称">
          <el-input v-model="courseForm.title" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="课程描述">
          <el-input v-model="courseForm.description" type="textarea" rows="3" />
        </el-form-item>
        <el-form-item label="课程时长">
          <el-input-number v-model="courseForm.duration" :min="0.5" :step="0.5" />
          <span style="margin-left: 8px;">小时</span>
        </el-form-item>
        <el-form-item label="难度等级">
          <el-select v-model="courseForm.level" placeholder="请选择难度">
            <el-option label="初级" value="初级" />
            <el-option label="中级" value="中级" />
            <el-option label="高级" value="高级" />
          </el-select>
        </el-form-item>
        <el-form-item label="课程标签">
          <el-input v-model="courseForm.tagsInput" placeholder="用逗号分隔多个标签" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showCourseDialog = false">取消</el-button>
        <el-button type="primary" @click="addCourse">添加课程</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Reading, Plus, Upload, Download, VideoPlay, CircleCheck, Star,
  Trophy, Medal
} from '@element-plus/icons-vue'
import * as echarts from 'echarts'

// 响应式数据
const activeTab = ref('plans')
const selectedQuarter = ref(new Date())
const filterStatus = ref('')
const filterDepartment = ref('')
const showCreateDialog = ref(false)
const showCourseDialog = ref(false)

// 图表引用
const progressChart = ref(null)
const satisfactionChart = ref(null)
const skillImprovementChart = ref(null)

// 统计数据
const trainingStats = ref({
  totalCourses: 28,
  activeCourses: 12,
  completionRate: 85.6,
  satisfaction: 4.3
})

// 创建培训表单
const createForm = reactive({
  title: '',
  category: '',
  startDate: null,
  duration: 8,
  instructor: '',
  maxParticipants: 20,
  participants: [],
  description: '',
  methods: []
})

// 课程表单
const courseForm = reactive({
  title: '',
  description: '',
  duration: 2,
  level: '',
  tagsInput: ''
})

// 培训数据
const trainings = ref([
  {
    id: '1',
    title: 'Kubernetes高级运维培训',
    category: '技术培训',
    instructor: '李专家',
    startDate: '2024-01-15',
    duration: 40,
    enrolledCount: 15,
    maxParticipants: 20,
    status: 'ongoing',
    progress: 65,
    department: '系统运维'
  },
  {
    id: '2',
    title: '网络安全防护培训',
    category: '安全培训',
    instructor: '王老师',
    startDate: '2024-02-01',
    duration: 24,
    enrolledCount: 12,
    maxParticipants: 15,
    status: 'planned',
    progress: 0,
    department: '网络运维'
  },
  {
    id: '3',
    title: 'DevOps最佳实践',
    category: '技术培训',
    instructor: '张工程师',
    startDate: '2024-01-01',
    duration: 32,
    enrolledCount: 18,
    maxParticipants: 20,
    status: 'completed',
    progress: 100,
    department: '应用运维'
  }
])

// 课程数据
const courses = ref([
  {
    id: '1',
    title: 'Linux系统管理基础',
    description: '从零开始学习Linux系统管理，包括文件系统、用户管理、网络配置等',
    duration: 16,
    level: '初级',
    rating: 4.5,
    tags: ['Linux', '系统管理', '基础'],
    cover: null
  },
  {
    id: '2',
    title: 'Docker容器技术实战',
    description: '深入学习Docker容器技术，包括镜像制作、容器编排、网络配置等',
    duration: 20,
    level: '中级',
    rating: 4.7,
    tags: ['Docker', '容器', '实战'],
    cover: null
  },
  {
    id: '3',
    title: 'Kubernetes集群管理',
    description: 'Kubernetes集群的部署、管理、监控和故障排查',
    duration: 32,
    level: '高级',
    rating: 4.8,
    tags: ['Kubernetes', '集群', '高级'],
    cover: null
  }
])

// 学习进度数据
const learningProgress = ref([
  {
    id: '1',
    engineerName: '张工程师',
    courseName: 'Kubernetes高级运维培训',
    startDate: '2024-01-15',
    lastAccess: '2024-01-20',
    progress: 75,
    score: null
  },
  {
    id: '2',
    engineerName: '李工程师',
    courseName: 'Docker容器技术实战',
    startDate: '2024-01-10',
    lastAccess: '2024-01-19',
    progress: 100,
    score: 88
  },
  {
    id: '3',
    engineerName: '王工程师',
    courseName: 'Linux系统管理基础',
    startDate: '2024-01-05',
    lastAccess: '2024-01-18',
    progress: 45,
    score: null
  }
])

// 学习时长排行
const learningRanking = ref([
  { id: '1', name: '张工程师', hours: 156 },
  { id: '2', name: '李工程师', hours: 142 },
  { id: '3', name: '王工程师', hours: 128 },
  { id: '4', name: '赵工程师', hours: 115 },
  { id: '5', name: '刘工程师', hours: 98 }
])

// 培训反馈
const trainingFeedback = ref([
  {
    id: '1',
    author: '张工程师',
    course: 'Kubernetes高级运维培训',
    rating: 5,
    content: '课程内容非常实用，讲师经验丰富，实操环节设计得很好。',
    date: '2024-01-18',
    helpful: true
  },
  {
    id: '2',
    author: '李工程师',
    course: 'Docker容器技术实战',
    rating: 4,
    content: '整体不错，但希望能增加更多实际案例分析。',
    date: '2024-01-17',
    helpful: true
  }
])

// 可用工程师
const availableEngineers = ref([
  { id: '1', name: '张工程师', department: '系统运维部' },
  { id: '2', name: '李工程师', department: '网络运维部' },
  { id: '3', name: '王工程师', department: '应用运维部' },
  { id: '4', name: '赵工程师', department: '系统运维部' }
])

// 计算属性
const filteredTrainings = computed(() => {
  let result = trainings.value
  
  if (filterStatus.value) {
    result = result.filter(training => training.status === filterStatus.value)
  }
  
  if (filterDepartment.value) {
    result = result.filter(training => training.department === filterDepartment.value)
  }
  
  return result
})

// 方法
const getStatusType = (status) => {
  const types = {
    planned: 'info',
    ongoing: 'primary',
    completed: 'success',
    paused: 'warning'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    planned: '计划中',
    ongoing: '进行中',
    completed: '已完成',
    paused: '已暂停'
  }
  return texts[status] || '未知'
}

const onQuarterChange = () => {
  ElMessage.info('季度已更新，重新加载统计数据')
}

const viewTraining = (training) => {
  ElMessage.info(`查看培训: ${training.title}`)
}

const editTraining = (training) => {
  ElMessage.info(`编辑培训: ${training.title}`)
}

const startTraining = (training) => {
  training.status = 'ongoing'
  ElMessage.success('培训已开始')
}

const pauseTraining = (training) => {
  training.status = 'paused'
  ElMessage.warning('培训已暂停')
}

const createTraining = () => {
  if (!createForm.title || !createForm.category || !createForm.startDate) {
    ElMessage.error('请填写必填字段')
    return
  }
  
  const newTraining = {
    id: Date.now().toString(),
    title: createForm.title,
    category: createForm.category,
    instructor: createForm.instructor,
    startDate: new Date(createForm.startDate).toLocaleDateString(),
    duration: createForm.duration,
    enrolledCount: createForm.participants.length,
    maxParticipants: createForm.maxParticipants,
    status: 'planned',
    progress: 0,
    department: '系统运维'
  }
  
  trainings.value.unshift(newTraining)
  showCreateDialog.value = false
  ElMessage.success('培训计划创建成功')
  
  // 重置表单
  Object.assign(createForm, {
    title: '',
    category: '',
    startDate: null,
    duration: 8,
    instructor: '',
    maxParticipants: 20,
    participants: [],
    description: '',
    methods: []
  })
}

const addCourse = () => {
  if (!courseForm.title || !courseForm.description) {
    ElMessage.error('请填写必填字段')
    return
  }
  
  const newCourse = {
    id: Date.now().toString(),
    title: courseForm.title,
    description: courseForm.description,
    duration: courseForm.duration,
    level: courseForm.level,
    rating: 0,
    tags: courseForm.tagsInput.split(',').map(tag => tag.trim()).filter(tag => tag),
    cover: null
  }
  
  courses.value.unshift(newCourse)
  showCourseDialog.value = false
  ElMessage.success('课程添加成功')
  
  // 重置表单
  Object.assign(courseForm, {
    title: '',
    description: '',
    duration: 2,
    level: '',
    tagsInput: ''
  })
}

const previewCourse = (course) => {
  ElMessage.info(`预览课程: ${course.title}`)
}

const editCourse = (course) => {
  ElMessage.info(`编辑课程: ${course.title}`)
}

const viewProgress = (progress) => {
  ElMessage.info(`查看 ${progress.engineerName} 的学习详情`)
}

const sendReminder = (progress) => {
  ElMessage.success(`已向 ${progress.engineerName} 发送学习提醒`)
}

const importCourses = () => {
  ElMessage.info('导入课程功能开发中...')
}

const exportReport = () => {
  ElMessage.success('培训报告导出成功')
}

// 初始化图表
const initCharts = () => {
  nextTick(() => {
    // 完成率统计图
    if (progressChart.value) {
      const progressChartInstance = echarts.init(progressChart.value)
      progressChartInstance.setOption({
        tooltip: { trigger: 'item' },
        series: [{
          type: 'pie',
          radius: '70%',
          data: [
            { value: 65, name: '已完成' },
            { value: 25, name: '进行中' },
            { value: 10, name: '未开始' }
          ]
        }]
      })
    }
    
    // 满意度评分图
    if (satisfactionChart.value) {
      const satisfactionChartInstance = echarts.init(satisfactionChart.value)
      satisfactionChartInstance.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: {
          type: 'category',
          data: ['技术培训', '安全培训', '管理培训', '认证培训']
        },
        yAxis: { type: 'value', max: 5 },
        series: [{
          type: 'bar',
          data: [4.5, 4.2, 4.0, 4.7]
        }]
      })
    }
    
    // 技能提升效果图
    if (skillImprovementChart.value) {
      const skillImprovementChartInstance = echarts.init(skillImprovementChart.value)
      skillImprovementChartInstance.setOption({
        tooltip: { trigger: 'axis' },
        xAxis: {
          type: 'category',
          data: ['培训前', '培训后']
        },
        yAxis: { type: 'value' },
        series: [
          {
            name: '技能水平',
            type: 'line',
            data: [65, 85]
          },
          {
            name: '工作效率',
            type: 'line',
            data: [70, 88]
          }
        ]
      })
    }
  })
}

onMounted(() => {
  initCharts()
})
</script>

<style scoped>
.training-management {
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

.stats-row {
  padding: 16px;
  background: #fafafa;
  margin-bottom: 0;
}

.stat-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  height: 100%;
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

.stat-icon.active {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-icon.completion {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-icon.satisfaction {
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

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-filters {
  display: flex;
  gap: 12px;
}

.progress-text {
  margin-left: 8px;
  font-size: 12px;
  color: #606266;
}

.course-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.course-card {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s ease;
}

.course-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.course-cover {
  position: relative;
  height: 160px;
  background: #f5f7fa;
  overflow: hidden;
}

.course-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.course-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.course-card:hover .course-overlay {
  opacity: 1;
}

.course-info {
  padding: 16px;
}

.course-title {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.course-description {
  margin: 0 0 12px 0;
  color: #606266;
  font-size: 14px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.course-meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  font-size: 12px;
  color: #909399;
}

.course-tags {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.course-tag {
  margin: 0;
}

.score-pass {
  color: #67c23a;
  font-weight: 600;
}

.score-fail {
  color: #f56c6c;
  font-weight: 600;
}

.score-pending {
  color: #909399;
}

.chart-card {
  margin-bottom: 20px;
}

.learning-ranking {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 6px;
}

.ranking-number {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: white;
}

.ranking-number.rank-1 {
  background: #f7ba2a;
}

.ranking-number.rank-2 {
  background: #c0c4cc;
}

.ranking-number.rank-3 {
  background: #cd7f32;
}

.ranking-number:not(.rank-1):not(.rank-2):not(.rank-3) {
  background: #909399;
}

.ranking-info {
  flex: 1;
}

.engineer-name {
  font-weight: 500;
  color: #303133;
}

.learning-hours {
  font-size: 12px;
  color: #606266;
}

.ranking-badge {
  color: #f7ba2a;
  font-size: 18px;
}

.evaluation-chart {
  margin-bottom: 30px;
}

.evaluation-chart h4 {
  margin: 0 0 15px 0;
  color: #303133;
}

.evaluation-feedback {
  margin-top: 30px;
}

.evaluation-feedback h4 {
  margin: 0 0 20px 0;
  color: #303133;
}

.feedback-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.feedback-item {
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
  border-left: 4px solid #409eff;
}

.feedback-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.feedback-author {
  font-weight: 500;
  color: #303133;
}

.feedback-course {
  color: #606266;
  font-size: 14px;
}

.feedback-content {
  margin: 0 0 8px 0;
  color: #606266;
  line-height: 1.5;
}

.feedback-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #909399;
}
</style>
