<template>
  <PageLayout
    title="技能管理"
    description="管理工程师技能分类和技能项目"
    icon="Medal"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>
        新增技能
      </el-button>
      <el-button @click="showCategoryDialog = true">
        <el-icon><FolderAdd /></el-icon>
        管理分类
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in skillStatsCards" :key="stat.label">
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

      <!-- 技能列表 -->
      <div class="skill-grid">
        <div class="skill-category" v-for="category in skillCategories" :key="category.id">
          <div class="category-header">
            <h3>{{ category.name }}</h3>
            <span class="skill-count">{{ category.skills.length }} 项技能</span>
          </div>

          <div class="skills-list">
            <div
              class="skill-card"
              v-for="skill in category.skills"
              :key="skill.id"
              @click="editSkill(skill)"
            >
              <div class="skill-header">
                <span class="skill-name">{{ skill.name }}</span>
                <el-tag :type="getDifficultyType(skill.difficulty)">
                  {{ getDifficultyText(skill.difficulty) }}
                </el-tag>
              </div>
              <div class="skill-description">{{ skill.description }}</div>
              <div class="skill-stats">
                <span class="engineer-count">
                  <el-icon><User /></el-icon>
                  {{ skill.engineerCount }} 人掌握
                </span>
                <span class="weight">权重: {{ skill.weight }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

    <!-- 新增/编辑技能对话框 -->
    <el-dialog
      v-model="showAddDialog"
      :title="editingSkill ? '编辑技能' : '新增技能'"
      width="600px"
    >
      <el-form :model="skillForm" :rules="skillRules" ref="skillFormRef" label-width="100px">
        <el-form-item label="技能名称" prop="name">
          <el-input v-model="skillForm.name" placeholder="请输入技能名称" />
        </el-form-item>

        <el-form-item label="技能分类" prop="categoryId">
          <el-select v-model="skillForm.categoryId" placeholder="请选择技能分类" style="width: 100%">
            <el-option
              v-for="category in skillCategories"
              :key="category.id"
              :label="category.name"
              :value="category.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="难度等级" prop="difficulty">
          <el-select v-model="skillForm.difficulty" placeholder="请选择难度等级" style="width: 100%">
            <el-option label="初级" :value="1" />
            <el-option label="中级" :value="2" />
            <el-option label="高级" :value="3" />
            <el-option label="专家" :value="4" />
          </el-select>
        </el-form-item>

        <el-form-item label="技能权重" prop="weight">
          <el-input-number
            v-model="skillForm.weight"
            :min="0.1"
            :max="5"
            :step="0.1"
            style="width: 100%"
          />
        </el-form-item>

        <el-form-item label="技能描述" prop="description">
          <el-input
            v-model="skillForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入技能描述"
          />
        </el-form-item>

        <el-form-item label="认证要求">
          <el-switch v-model="skillForm.certificationRequired" />
          <span style="margin-left: 10px; color: #666;">是否需要认证</span>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="saveSkill">保存</el-button>
      </template>
    </el-dialog>

    <!-- 分类管理对话框 -->
    <el-dialog v-model="showCategoryDialog" title="技能分类管理" width="500px">
      <div class="category-management">
        <div class="add-category">
          <el-input
            v-model="newCategoryName"
            placeholder="输入分类名称"
            style="width: 300px; margin-right: 10px;"
          />
          <el-button type="primary" @click="addCategory">添加分类</el-button>
        </div>

        <div class="category-list">
          <div
            class="category-item"
            v-for="category in skillCategories"
            :key="category.id"
          >
            <span>{{ category.name }}</span>
            <el-button
              type="danger"
              size="small"
              @click="deleteCategory(category.id)"
              :disabled="category.skills.length > 0"
            >
              删除
            </el-button>
          </div>
        </div>
      </div>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, FolderAdd, User, Refresh } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const showAddDialog = ref(false)
const showCategoryDialog = ref(false)
const editingSkill = ref(null)
const newCategoryName = ref('')
const skillFormRef = ref()

// 统计卡片数据
const skillStatsCards = computed(() => [
  {
    label: '技能分类',
    value: skillCategories.value.length,
    icon: 'FolderAdd',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '技能总数',
    value: skillCategories.value.reduce((total, cat) => total + cat.skills.length, 0),
    icon: 'Medal',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.3
  },
  {
    label: '认证技能',
    value: skillCategories.value.reduce((total, cat) =>
      total + cat.skills.filter(skill => skill.certificationRequired).length, 0),
    icon: 'Star',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 5.7
  },
  {
    label: '掌握工程师',
    value: skillCategories.value.reduce((total, cat) =>
      total + cat.skills.reduce((sum, skill) => sum + skill.engineerCount, 0), 0),
    icon: 'User',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 15.2
  }
])

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshData = () => {
  ElMessage.success('数据刷新成功')
}

// 技能分类数据
const skillCategories = ref([
  {
    id: 1,
    name: '编程语言',
    skills: [
      {
        id: 1,
        name: 'Java',
        description: 'Java编程语言，企业级应用开发',
        difficulty: 3,
        weight: 1.5,
        engineerCount: 15,
        certificationRequired: true
      },
      {
        id: 2,
        name: 'Python',
        description: 'Python编程语言，数据分析和自动化',
        difficulty: 2,
        weight: 1.3,
        engineerCount: 12,
        certificationRequired: false
      }
    ]
  },
  {
    id: 2,
    name: '数据库',
    skills: [
      {
        id: 3,
        name: 'MySQL',
        description: 'MySQL数据库管理和优化',
        difficulty: 2,
        weight: 1.2,
        engineerCount: 18,
        certificationRequired: false
      },
      {
        id: 4,
        name: 'Oracle',
        description: 'Oracle数据库管理',
        difficulty: 4,
        weight: 2.0,
        engineerCount: 8,
        certificationRequired: true
      }
    ]
  },
  {
    id: 3,
    name: '运维工具',
    skills: [
      {
        id: 5,
        name: 'Docker',
        description: '容器化技术',
        difficulty: 3,
        weight: 1.4,
        engineerCount: 10,
        certificationRequired: false
      }
    ]
  }
])

// 表单数据
const skillForm = reactive({
  name: '',
  categoryId: '',
  difficulty: 1,
  weight: 1.0,
  description: '',
  certificationRequired: false
})

// 表单验证规则
const skillRules = {
  name: [
    { required: true, message: '请输入技能名称', trigger: 'blur' }
  ],
  categoryId: [
    { required: true, message: '请选择技能分类', trigger: 'change' }
  ],
  difficulty: [
    { required: true, message: '请选择难度等级', trigger: 'change' }
  ]
}

// 方法
const getDifficultyType = (difficulty) => {
  const types = { 1: 'success', 2: 'info', 3: 'warning', 4: 'danger' }
  return types[difficulty] || 'info'
}

const getDifficultyText = (difficulty) => {
  const texts = { 1: '初级', 2: '中级', 3: '高级', 4: '专家' }
  return texts[difficulty] || '未知'
}

const editSkill = (skill) => {
  editingSkill.value = skill
  Object.assign(skillForm, skill)
  showAddDialog.value = true
}

const saveSkill = async () => {
  try {
    await skillFormRef.value.validate()

    if (editingSkill.value) {
      // 编辑技能
      Object.assign(editingSkill.value, skillForm)
      ElMessage.success('技能更新成功')
    } else {
      // 新增技能
      const category = skillCategories.value.find(c => c.id === skillForm.categoryId)
      if (category) {
        const newSkill = {
          id: Date.now(),
          ...skillForm,
          engineerCount: 0
        }
        category.skills.push(newSkill)
        ElMessage.success('技能添加成功')
      }
    }

    showAddDialog.value = false
    resetForm()
  } catch (error) {
    console.error('保存技能失败:', error)
  }
}

const addCategory = () => {
  if (!newCategoryName.value.trim()) {
    ElMessage.warning('请输入分类名称')
    return
  }

  skillCategories.value.push({
    id: Date.now(),
    name: newCategoryName.value,
    skills: []
  })

  newCategoryName.value = ''
  ElMessage.success('分类添加成功')
}

const deleteCategory = async (categoryId) => {
  try {
    await ElMessageBox.confirm('确定要删除这个分类吗？', '确认删除', {
      type: 'warning'
    })

    const index = skillCategories.value.findIndex(c => c.id === categoryId)
    if (index > -1) {
      skillCategories.value.splice(index, 1)
      ElMessage.success('分类删除成功')
    }
  } catch (error) {
    // 用户取消删除
  }
}

const resetForm = () => {
  Object.assign(skillForm, {
    name: '',
    categoryId: '',
    difficulty: 1,
    weight: 1.0,
    description: '',
    certificationRequired: false
  })
  editingSkill.value = null
}

onMounted(() => {
  // 组件挂载时的初始化逻辑
})
</script>

<style scoped>
.skill-management {
  padding: 20px;
  background: var(--bg-primary);
  color: var(--text-primary);
  min-height: 100vh;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0 0 8px 0;
  color: var(--text-primary);
}

.page-header p {
  margin: 0;
  color: var(--text-secondary);
}

.toolbar {
  margin-bottom: 20px;
}

.skill-grid {
  display: grid;
  gap: 24px;
}

.skill-category {
  background: var(--bg-card);
  border-radius: 8px;
  padding: 20px;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--border-color);
}

.category-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #e5e7eb;
}

.category-header h3 {
  margin: 0;
  color: var(--text-primary);
}

.skill-count {
  color: var(--text-secondary);
  font-size: 14px;
}

.skills-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}

.skill-card {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.2s;
}

.skill-card:hover {
  border-color: #3b82f6;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.1);
}

.skill-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.skill-name {
  font-weight: 500;
  color: #1f2937;
}

.skill-description {
  color: #6b7280;
  font-size: 14px;
  margin-bottom: 12px;
}

.skill-stats {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #6b7280;
}

.engineer-count {
  display: flex;
  align-items: center;
  gap: 4px;
}

.category-management {
  padding: 10px 0;
}

.add-category {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.category-list {
  max-height: 300px;
  overflow-y: auto;
}

.category-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #f3f4f6;
}

.category-item:last-child {
  border-bottom: none;
}

/* 主题适配通过CSS变量统一管理，无需额外的深色模式样式 */
</style>
