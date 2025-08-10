<template>
  <PageLayout
    title="部门管理与组织架构"
    description="树形结构管理，权限继承，组织架构可视化"
    icon="OfficeBuilding"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新增部门
      </el-button>
      <el-button @click="toggleOrgChart">
        <el-icon><View /></el-icon>
        {{ showChart ? '列表视图' : '架构图' }}
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in departmentStats" :key="stat.label">
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

    <el-row :gutter="20">
      <!-- 左侧部门树 -->
      <el-col :span="8">
        <el-card shadow="never" class="tree-card">
          <template #header>
            <div class="card-header">
              <span>部门树</span>
              <el-button size="small" text @click="expandAll">
                {{ allExpanded ? '收起' : '展开' }}全部
              </el-button>
            </div>
          </template>

          <el-tree
            ref="deptTree"
            :data="departmentTree"
            :props="treeProps"
            node-key="id"
            :default-expand-all="false"
            :expand-on-click-node="false"
            draggable
            @node-click="selectDepartment"
            @node-drop="handleDrop"
            class="department-tree"
          >
            <template #default="{ node, data }">
              <div class="tree-node">
                <el-icon class="node-icon">
                  <component :is="getDeptIcon(data.level)" />
                </el-icon>
                <span class="node-label">{{ data.name }}</span>
                <span class="node-count">({{ data.memberCount }})</span>
                <div class="node-actions">
                  <el-button size="small" text @click.stop="addSubDept(data)">
                    <el-icon><Plus /></el-icon>
                  </el-button>
                  <el-button size="small" text @click.stop="editDept(data)">
                    <el-icon><Edit /></el-icon>
                  </el-button>
                </div>
              </div>
            </template>
          </el-tree>
        </el-card>
      </el-col>

      <!-- 右侧内容区 -->
      <el-col :span="16">
        <!-- 组织架构图 -->
        <el-card v-if="showChart" shadow="never" class="chart-card">
          <template #header>
            <span>组织架构图</span>
          </template>
          <div ref="orgChart" class="org-chart"></div>
        </el-card>

        <!-- 部门详情 -->
        <el-card v-else shadow="never" class="detail-card">
          <template #header>
            <div class="detail-header">
              <span>{{ selectedDept.name || '请选择部门' }}</span>
              <el-tag v-if="selectedDept.level" :type="getLevelColor(selectedDept.level)">
                {{ selectedDept.level }}级部门
              </el-tag>
            </div>
          </template>

          <div v-if="selectedDept.id" class="dept-detail">
            <!-- 基本信息 -->
            <div class="info-section">
              <h3>基本信息</h3>
              <el-descriptions :column="2" border>
                <el-descriptions-item label="部门名称">{{ selectedDept.name }}</el-descriptions-item>
                <el-descriptions-item label="部门代码">{{ selectedDept.code }}</el-descriptions-item>
                <el-descriptions-item label="部门负责人">{{ selectedDept.manager }}</el-descriptions-item>
                <el-descriptions-item label="联系电话">{{ selectedDept.phone }}</el-descriptions-item>
                <el-descriptions-item label="成员数量">{{ selectedDept.memberCount }}</el-descriptions-item>
                <el-descriptions-item label="创建时间">{{ selectedDept.createdTime }}</el-descriptions-item>
              </el-descriptions>
            </div>

            <!-- 权限配置 -->
            <div class="permission-section">
              <h3>权限配置</h3>
              <el-table :data="selectedDept.permissions" size="small">
                <el-table-column prop="module" label="功能模块" width="150" />
                <el-table-column prop="permission" label="权限" width="120">
                  <template #default="{ row }">
                    <el-tag :type="getPermissionColor(row.permission)">
                      {{ row.permission }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="inherited" label="继承来源" width="150">
                  <template #default="{ row }">
                    <span v-if="row.inherited">{{ row.inheritedFrom }}</span>
                    <el-tag v-else type="success" size="small">直接授权</el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作">
                  <template #default="{ row }">
                    <el-button size="small" text @click="editPermission(row)">编辑</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </div>

            <!-- 成员列表 -->
            <div class="member-section">
              <h3>部门成员</h3>
              <el-table :data="selectedDept.members" size="small">
                <el-table-column prop="name" label="姓名" width="120" />
                <el-table-column prop="position" label="职位" width="150" />
                <el-table-column prop="role" label="角色" width="120">
                  <template #default="{ row }">
                    <el-tag size="small">{{ row.role }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="joinTime" label="加入时间" width="150" />
                <el-table-column label="操作">
                  <template #default="{ row }">
                    <el-button size="small" text @click="viewMember(row)">查看</el-button>
                    <el-button size="small" text type="danger" @click="removeMember(row)">移除</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </div>

          <div v-else class="empty-state">
            <el-empty description="请从左侧选择部门查看详情" />
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 创建部门对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建部门" width="600px">
      <el-form :model="newDept" :rules="deptRules" ref="deptForm" label-width="100px">
        <el-form-item label="上级部门" prop="parentId">
          <el-tree-select
            v-model="newDept.parentId"
            :data="departmentTree"
            :props="treeProps"
            placeholder="请选择上级部门"
            check-strictly
          />
        </el-form-item>
        <el-form-item label="部门名称" prop="name">
          <el-input v-model="newDept.name" placeholder="请输入部门名称" />
        </el-form-item>
        <el-form-item label="部门代码" prop="code">
          <el-input v-model="newDept.code" placeholder="请输入部门代码" />
        </el-form-item>
        <el-form-item label="部门负责人" prop="manager">
          <el-select v-model="newDept.manager" placeholder="请选择负责人">
            <el-option label="张三" value="张三" />
            <el-option label="李四" value="李四" />
            <el-option label="王五" value="王五" />
          </el-select>
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="newDept.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="部门描述" prop="description">
          <el-input v-model="newDept.description" type="textarea" rows="3" placeholder="请输入部门描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="createDept">确定</el-button>
      </template>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { OfficeBuilding, Plus, View, Edit, User, UserFilled, Avatar } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const showCreateDialog = ref(false)
const showChart = ref(false)
const allExpanded = ref(false)
const deptTree = ref(null)
const orgChart = ref(null)
const selectedDept = ref({})

// 部门统计数据
const departmentStats = computed(() => [
  {
    label: '部门总数',
    value: departmentTree.value.length + 10,
    icon: 'OfficeBuilding',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 5.2
  },
  {
    label: '员工总数',
    value: '156',
    icon: 'User',
    color: 'var(--el-color-success, #10b981)',
    trend: 8.7
  },
  {
    label: '管理层级',
    value: '4',
    icon: 'Avatar',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 0
  },
  {
    label: '活跃部门',
    value: '12',
    icon: 'CircleCheck',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 3.1
  }
])

const navItems = ref([
  { name: 'tree', label: '部门树' },
  { name: 'chart', label: '组织架构图' },
  { name: 'settings', label: '部门设置' }
])

// 标签页切换处理
const handleTabChange = (tabName) => {
  if (tabName === 'chart') {
    showChart.value = true
  } else {
    showChart.value = false
  }
}

// 树形组件配置
const treeProps = {
  children: 'children',
  label: 'name'
}

// 部门树数据
const departmentTree = ref([
  {
    id: '1',
    name: '阿里巴巴集团',
    code: 'ALIBABA',
    level: 1,
    manager: '马云',
    phone: '010-12345678',
    memberCount: 15,
    createdTime: '2024-01-01',
    permissions: [
      { module: '系统管理', permission: '完全控制', inherited: false },
      { module: '用户管理', permission: '完全控制', inherited: false }
    ],
    members: [
      { name: '马云', position: '董事长', role: '系统管理员', joinTime: '2024-01-01' },
      { name: '张勇', position: 'CEO', role: '租户管理员', joinTime: '2024-01-01' }
    ],
    children: [
      {
        id: '2',
        name: '技术部',
        code: 'TECH',
        level: 2,
        manager: '张三',
        phone: '010-12345679',
        memberCount: 50,
        createdTime: '2024-01-02',
        permissions: [
          { module: '系统集成', permission: '读写', inherited: true, inheritedFrom: '阿里巴巴集团' },
          { module: '工单管理', permission: '读写', inherited: false }
        ],
        members: [
          { name: '张三', position: '技术总监', role: '高级工程师', joinTime: '2024-01-02' },
          { name: '李四', position: '架构师', role: '高级工程师', joinTime: '2024-01-03' }
        ],
        children: [
          {
            id: '3',
            name: '前端开发组',
            code: 'FE',
            level: 3,
            manager: '李四',
            phone: '010-12345680',
            memberCount: 12,
            createdTime: '2024-01-03',
            permissions: [
              { module: '前端开发', permission: '读写', inherited: false },
              { module: '工单管理', permission: '只读', inherited: true, inheritedFrom: '技术部' }
            ],
            members: [
              { name: '李四', position: '前端负责人', role: '高级工程师', joinTime: '2024-01-03' },
              { name: '王五', position: '前端工程师', role: '运维工程师', joinTime: '2024-01-04' }
            ]
          },
          {
            id: '4',
            name: '后端开发组',
            code: 'BE',
            level: 3,
            manager: '王五',
            phone: '010-12345681',
            memberCount: 18,
            createdTime: '2024-01-04',
            permissions: [
              { module: '后端开发', permission: '读写', inherited: false },
              { module: '数据库管理', permission: '读写', inherited: false }
            ],
            members: [
              { name: '王五', position: '后端负责人', role: '高级工程师', joinTime: '2024-01-04' },
              { name: '赵六', position: '后端工程师', role: '运维工程师', joinTime: '2024-01-05' }
            ]
          }
        ]
      },
      {
        id: '5',
        name: '运维部',
        code: 'OPS',
        level: 2,
        manager: '赵六',
        phone: '010-12345682',
        memberCount: 25,
        createdTime: '2024-01-05',
        permissions: [
          { module: '系统监控', permission: '读写', inherited: false },
          { module: '故障处理', permission: '读写', inherited: false }
        ],
        members: [
          { name: '赵六', position: '运维总监', role: '高级工程师', joinTime: '2024-01-05' },
          { name: '孙七', position: '运维工程师', role: '运维工程师', joinTime: '2024-01-06' }
        ]
      }
    ]
  }
])

// 新部门表单数据
const newDept = reactive({
  parentId: '',
  name: '',
  code: '',
  manager: '',
  phone: '',
  description: ''
})

// 表单验证规则
const deptRules = {
  name: [{ required: true, message: '请输入部门名称', trigger: 'blur' }],
  code: [{ required: true, message: '请输入部门代码', trigger: 'blur' }],
  manager: [{ required: true, message: '请选择负责人', trigger: 'change' }]
}

// 方法
const handleStatClick = (stat) => {
  console.log('统计卡片点击:', stat)
  ElMessage.info(`点击了统计项：${stat.label}`)
}

const getDeptIcon = (level) => {
  const icons = {
    1: OfficeBuilding,
    2: UserFilled,
    3: User
  }
  return icons[level] || User
}

const getLevelColor = (level) => {
  const colors = {
    1: 'danger',
    2: 'warning',
    3: 'success'
  }
  return colors[level] || 'info'
}

const getPermissionColor = (permission) => {
  const colors = {
    '完全控制': 'danger',
    '读写': 'success',
    '只读': 'info'
  }
  return colors[permission] || 'info'
}

const selectDepartment = (data) => {
  selectedDept.value = data
}

const expandAll = () => {
  if (deptTree.value) {
    if (allExpanded.value) {
      deptTree.value.store._getAllNodes().forEach(node => {
        node.expanded = false
      })
    } else {
      deptTree.value.store._getAllNodes().forEach(node => {
        node.expanded = true
      })
    }
    allExpanded.value = !allExpanded.value
  }
}

const toggleOrgChart = () => {
  showChart.value = !showChart.value
  if (showChart.value) {
    nextTick(() => {
      initOrgChart()
    })
  }
}

const handleDrop = (draggingNode, dropNode, dropType) => {
  ElMessage.success(`已将 ${draggingNode.data.name} 移动到 ${dropNode.data.name} ${dropType}`)
}

const addSubDept = (data) => {
  newDept.parentId = data.id
  showCreateDialog.value = true
}

const editDept = (data) => {
  ElMessage.info(`编辑部门：${data.name}`)
}

const createDept = () => {
  ElMessage.success('部门创建成功')
  showCreateDialog.value = false
}

const editPermission = (row) => {
  ElMessage.info(`编辑权限：${row.module}`)
}

const viewMember = (row) => {
  ElMessage.info(`查看成员：${row.name}`)
}

const removeMember = (row) => {
  ElMessageBox.confirm(
    `确定要将 ${row.name} 从部门中移除吗？`,
    '确认移除',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('移除成功')
  })
}

// 初始化组织架构图
const initOrgChart = () => {
  if (!orgChart.value) return

  const chart = echarts.init(orgChart.value)
  const option = {
    tooltip: {
      trigger: 'item',
      triggerOn: 'mousemove'
    },
    series: [
      {
        type: 'tree',
        data: [departmentTree.value[0]],
        top: '1%',
        left: '7%',
        bottom: '1%',
        right: '20%',
        symbolSize: 7,
        label: {
          position: 'left',
          verticalAlign: 'middle',
          align: 'right',
          fontSize: 12
        },
        leaves: {
          label: {
            position: 'right',
            verticalAlign: 'middle',
            align: 'left'
          }
        },
        emphasis: {
          focus: 'descendant'
        },
        expandAndCollapse: true,
        animationDuration: 550,
        animationDurationUpdate: 750
      }
    ]
  }
  chart.setOption(option)
}

onMounted(() => {
  // 默认选择第一个部门
  if (departmentTree.value.length > 0) {
    selectedDept.value = departmentTree.value[0]
  }
})
</script>

<style scoped>
.department-management-demo {
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

.tree-card {
  height: calc(100vh - 200px);
  overflow: auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.department-tree {
  max-height: calc(100vh - 280px);
  overflow: auto;
}

.tree-node {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
}

.node-icon {
  color: #409eff;
}

.node-label {
  flex: 1;
  font-weight: 500;
}

.node-count {
  color: #909399;
  font-size: 12px;
}

.node-actions {
  display: none;
}

.tree-node:hover .node-actions {
  display: flex;
}

.chart-card,
.detail-card {
  height: calc(100vh - 200px);
  overflow: auto;
}

.org-chart {
  height: calc(100vh - 280px);
  width: 100%;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dept-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.info-section h3,
.permission-section h3,
.member-section h3 {
  margin: 0 0 15px 0;
  color: #303133;
  font-size: 16px;
  font-weight: 600;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 300px;
}
</style>
