<template>
  <PageLayout
    title="分类管理"
    description="工单分类的层级管理，支持一级分类和二级分类的增删改查"
    icon="Menu"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新建分类
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
      <el-button @click="exportData">
        <el-icon><Download /></el-icon>
        导出数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in categoryStatsCards" :key="stat.label">
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
      <!-- 筛选和搜索 -->
      <el-card class="filter-card">
        <el-row :gutter="16">
          <el-col :span="6">
            <el-input
              v-model="searchText"
              placeholder="搜索分类名称"
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
              <el-option label="启用" value="enabled" />
              <el-option label="禁用" value="disabled" />
            </el-select>
          </el-col>
          <el-col :span="3">
            <el-select v-model="filterLevel" placeholder="层级筛选" clearable>
              <el-option label="全部" value="" />
              <el-option label="一级分类" value="1" />
              <el-option label="二级分类" value="2" />
            </el-select>
          </el-col>
          <el-col :span="3">
            <el-button @click="resetFilters">重置筛选</el-button>
          </el-col>
        </el-row>
      </el-card>

      <!-- 分类列表 -->
      <el-card class="list-card">
        <template #header>
          <div class="card-header">
            <span>分类列表</span>
            <div class="header-actions">
              <el-switch
                v-model="showTreeView"
                active-text="树形视图"
                inactive-text="表格视图"
              />
            </div>
          </div>
        </template>

        <!-- 树形视图 -->
        <div v-if="showTreeView">
          <el-tree
            :data="treeData"
            :props="treeProps"
            :expand-on-click-node="false"
            :default-expand-all="true"
            node-key="id"
            class="category-tree"
          >
            <template #default="{ node, data }">
              <div class="tree-node">
                <div class="node-content">
                  <el-icon v-if="data.level === 1" class="category-icon"><Folder /></el-icon>
                  <el-icon v-else class="category-icon"><Document /></el-icon>
                  <span class="node-label">{{ data.name }}</span>
                  <el-tag
                    :type="data.status === 'enabled' ? 'success' : 'danger'"
                    size="small"
                    class="status-tag"
                  >
                    {{ data.status === 'enabled' ? '启用' : '禁用' }}
                  </el-tag>
                  <span class="ticket-count">{{ data.ticketCount }}个工单</span>
                </div>
                <div class="node-actions">
                  <el-button size="small" @click.stop="editCategory(data)">编辑</el-button>
                  <el-button
                    v-if="data.level === 1"
                    size="small"
                    type="primary"
                    @click.stop="addSubCategory(data)"
                  >
                    添加子分类
                  </el-button>
                  <el-button
                    size="small"
                    type="danger"
                    @click.stop="deleteCategory(data)"
                    :disabled="data.ticketCount > 0"
                  >
                    删除
                  </el-button>
                </div>
              </div>
            </template>
          </el-tree>
        </div>

        <!-- 表格视图 -->
        <div v-else>
          <el-table
            :data="filteredCategories"
            style="width: 100%"
            row-key="id"
            :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
            stripe
          >
            <el-table-column prop="name" label="分类名称" min-width="200">
              <template #default="{ row }">
                <div class="category-name">
                  <el-icon v-if="row.level === 1" class="category-icon"><Folder /></el-icon>
                  <el-icon v-else class="category-icon"><Document /></el-icon>
                  <span>{{ row.name }}</span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="level" label="层级" width="100">
              <template #default="{ row }">
                <el-tag :type="row.level === 1 ? 'primary' : 'info'" size="small">
                  {{ row.level === 1 ? '一级' : '二级' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.status === 'enabled' ? 'success' : 'danger'" size="small">
                  {{ row.status === 'enabled' ? '启用' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="ticketCount" label="工单数量" width="120">
              <template #default="{ row }">
                <span class="ticket-count">{{ row.ticketCount }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="sort" label="排序" width="100" />
            <el-table-column prop="createdAt" label="创建时间" width="150" />
            <el-table-column label="操作" width="250" fixed="right">
              <template #default="{ row }">
                <el-button size="small" @click="editCategory(row)">编辑</el-button>
                <el-button
                  v-if="row.level === 1"
                  size="small"
                  type="primary"
                  @click="addSubCategory(row)"
                >
                  添加子分类
                </el-button>
                <el-button
                  size="small"
                  type="danger"
                  @click="deleteCategory(row)"
                  :disabled="row.ticketCount > 0"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-card>

      <!-- 创建/编辑分类对话框 -->
      <el-dialog
        v-model="showCreateDialog"
        :title="editingCategory ? '编辑分类' : '新建分类'"
        width="600px"
      >
        <el-form ref="categoryFormRef" :model="categoryForm" :rules="categoryRules" label-width="120px">
          <el-form-item label="分类名称" prop="name">
            <el-input
              v-model="categoryForm.name"
              placeholder="请输入分类名称"
              maxlength="50"
              show-word-limit
            />
          </el-form-item>

          <el-form-item label="分类层级" prop="level">
            <el-radio-group v-model="categoryForm.level" :disabled="editingCategory">
              <el-radio :label="1">一级分类</el-radio>
              <el-radio :label="2">二级分类</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item
            v-if="categoryForm.level === 2"
            label="上级分类"
            prop="parentId"
          >
            <el-select
              v-model="categoryForm.parentId"
              placeholder="请选择上级分类"
              style="width: 100%"
            >
              <el-option
                v-for="parent in parentCategories"
                :key="parent.id"
                :label="parent.name"
                :value="parent.id"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="categoryForm.status">
              <el-radio label="enabled">启用</el-radio>
              <el-radio label="disabled">禁用</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item label="排序" prop="sort">
            <el-input-number
              v-model="categoryForm.sort"
              :min="1"
              :max="999"
              placeholder="排序值"
              style="width: 100%"
            />
          </el-form-item>

          <el-form-item label="描述">
            <el-input
              v-model="categoryForm.description"
              type="textarea"
              :rows="3"
              placeholder="请输入分类描述（可选）"
              maxlength="200"
              show-word-limit
            />
          </el-form-item>
        </el-form>

        <template #footer>
          <div class="dialog-footer">
            <el-button @click="showCreateDialog = false">取消</el-button>
            <el-button type="primary" @click="saveCategory" :loading="saving">
              {{ saving ? '保存中...' : '保存' }}
            </el-button>
          </div>
        </template>
      </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus, Search, Refresh, Download, Menu, Folder, Document
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'
import { categoryService } from '@/services/categoryService'

// 响应式数据
const categories = ref([])
const searchText = ref('')
const filterStatus = ref('')
const filterLevel = ref('')
const showTreeView = ref(true)
const showCreateDialog = ref(false)
const editingCategory = ref(null)
const saving = ref(false)
const categoryFormRef = ref(null)

// 分类表单
const categoryForm = ref({
  name: '',
  level: 1,
  parentId: '',
  status: 'enabled',
  sort: 1,
  description: ''
})

// 表单验证规则
const categoryRules = {
  name: [
    { required: true, message: '请输入分类名称', trigger: 'blur' },
    { min: 2, max: 50, message: '分类名称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  level: [
    { required: true, message: '请选择分类层级', trigger: 'change' }
  ],
  parentId: [
    { required: true, message: '请选择上级分类', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ],
  sort: [
    { required: true, message: '请输入排序值', trigger: 'blur' }
  ]
}

// 树形组件配置
const treeProps = {
  children: 'children',
  label: 'name'
}

// 计算属性
const filteredCategories = computed(() => {
  let result = categories.value

  if (searchText.value) {
    result = result.filter(category =>
      category.name.includes(searchText.value) ||
      (category.children && category.children.some(child =>
        child.name.includes(searchText.value)
      ))
    )
  }

  if (filterStatus.value) {
    result = result.filter(category => category.status === filterStatus.value)
  }

  if (filterLevel.value) {
    const level = parseInt(filterLevel.value)
    if (level === 1) {
      result = result.filter(category => category.level === 1)
    } else {
      result = result.flatMap(category =>
        category.children ? category.children.filter(child => child.level === 2) : []
      )
    }
  }

  return result
})

const treeData = computed(() => {
  return categories.value.filter(category => category.level === 1)
})

const parentCategories = computed(() => {
  return categories.value.filter(category =>
    category.level === 1 && category.status === 'enabled'
  )
})

const categoryStats = computed(() => {
  const total = categories.value.length
  const enabled = categories.value.filter(c => c.status === 'enabled').length
  const level1 = categories.value.filter(c => c.level === 1).length
  const level2 = categories.value.filter(c => c.level === 2).length

  return { total, enabled, level1, level2 }
})

const categoryStatsCards = computed(() => [
  {
    label: '分类总数',
    value: categoryStats.value.total,
    icon: 'Menu',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 5.2
  },
  {
    label: '启用分类',
    value: categoryStats.value.enabled,
    icon: 'Folder',
    color: 'var(--el-color-success, #10b981)',
    trend: 2.1
  },
  {
    label: '一级分类',
    value: categoryStats.value.level1,
    icon: 'Document',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 0
  },
  {
    label: '二级分类',
    value: categoryStats.value.level2,
    icon: 'Document',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 8.3
  }
])

// 方法
const loadCategories = async () => {
  try {
    categories.value = await categoryService.getCategories()
  } catch (error) {
    ElMessage.error('加载分类数据失败')
  }
}

const resetFilters = () => {
  searchText.value = ''
  filterStatus.value = ''
  filterLevel.value = ''
}

const handleStatClick = (stat) => {
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const refreshData = () => {
  loadCategories()
  ElMessage.success('数据刷新成功')
}

const exportData = () => {
  ElMessage.success('数据导出成功')
}

const editCategory = (category) => {
  editingCategory.value = category
  categoryForm.value = {
    name: category.name,
    level: category.level,
    parentId: category.parentId || '',
    status: category.status,
    sort: category.sort,
    description: category.description || ''
  }
  showCreateDialog.value = true
}

const addSubCategory = (parentCategory) => {
  editingCategory.value = null
  categoryForm.value = {
    name: '',
    level: 2,
    parentId: parentCategory.id,
    status: 'enabled',
    sort: 1,
    description: ''
  }
  showCreateDialog.value = true
}

const deleteCategory = async (category) => {
  if (category.ticketCount > 0) {
    ElMessage.warning('该分类下有工单，无法删除')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除分类"${category.name}"吗？此操作不可恢复。`,
      '确认删除',
      { type: 'warning' }
    )

    await categoryService.deleteCategory(category.id)
    await loadCategories()
    ElMessage.success('删除成功')
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const saveCategory = async () => {
  if (!categoryFormRef.value) return

  try {
    await categoryFormRef.value.validate()
    saving.value = true

    const categoryData = { ...categoryForm.value }

    if (editingCategory.value) {
      await categoryService.updateCategory(editingCategory.value.id, categoryData)
      ElMessage.success('更新成功')
    } else {
      await categoryService.createCategory(categoryData)
      ElMessage.success('创建成功')
    }

    showCreateDialog.value = false
    await loadCategories()
    resetForm()
  } catch (error) {
    ElMessage.error(editingCategory.value ? '更新失败' : '创建失败')
  } finally {
    saving.value = false
  }
}

const resetForm = () => {
  editingCategory.value = null
  categoryForm.value = {
    name: '',
    level: 1,
    parentId: '',
    status: 'enabled',
    sort: 1,
    description: ''
  }
}

// 生命周期
onMounted(() => {
  loadCategories()
})
</script>

<style scoped>
.filter-card {
  margin-bottom: 20px;
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 8px 0 rgba(0, 0, 0, 0.06);
}

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

.category-tree {
  margin-top: 20px;
}

.tree-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 8px 0;
}

.node-content {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
}

.category-icon {
  color: #409eff;
}

.node-label {
  font-weight: 500;
}

.status-tag {
  margin-left: 8px;
}

.ticket-count {
  color: #909399;
  font-size: 12px;
  margin-left: 8px;
}

.node-actions {
  display: flex;
  gap: 8px;
}

.category-name {
  display: flex;
  align-items: center;
  gap: 8px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
</style>
