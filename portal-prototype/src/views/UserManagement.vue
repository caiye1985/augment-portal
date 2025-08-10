<template>
  <PageLayout
    title="用户管理"
    description="管理系统用户、角色和权限配置"
    icon="User"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button type="primary" @click="showCreateDialog = true">
        <el-icon><Plus /></el-icon>
        新增用户
      </el-button>
      <el-button @click="showRoleDialog = true">
        <el-icon><Key /></el-icon>
        角色管理
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in userStatsCards" :key="stat.label">
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
      <!-- 用户管理 -->
      <el-tab-pane label="用户管理" name="users">
        <div class="tab-content">
          <!-- 搜索和操作栏 -->
          <div class="toolbar">
            <div class="search-bar">
              <el-input
                v-model="userSearch"
                placeholder="搜索用户名、邮箱或姓名"
                style="width: 300px"
                clearable
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
              <el-select v-model="userStatusFilter" placeholder="状态筛选" style="width: 120px" clearable>
                <el-option label="启用" value="active" />
                <el-option label="禁用" value="inactive" />
              </el-select>
              <el-select v-model="departmentFilter" placeholder="部门筛选" style="width: 150px" clearable>
                <el-option
                  v-for="dept in departments"
                  :key="dept.id"
                  :label="dept.name"
                  :value="dept.id"
                />
              </el-select>
              <el-select v-model="roleFilter" placeholder="角色筛选" style="width: 150px" clearable>
                <el-option
                  v-for="role in roles"
                  :key="role.name"
                  :label="role.name"
                  :value="role.name"
                />
              </el-select>
            </div>
            <div class="actions">
              <el-button type="primary" @click="showUserDialog = true">
                <el-icon><Plus /></el-icon>
                添加用户
              </el-button>
              <el-button @click="exportUsers">
                <el-icon><Download /></el-icon>
                导出
              </el-button>
            </div>
          </div>

          <!-- 用户列表 -->
          <el-table :data="filteredUsers" stripe style="width: 100%">
            <el-table-column prop="avatar" label="头像" width="80">
              <template #default="{ row }">
                <el-avatar :size="40" :src="row.avatar">{{ row.name.charAt(0) }}</el-avatar>
              </template>
            </el-table-column>
            <el-table-column prop="username" label="用户名" width="120" />
            <el-table-column prop="name" label="姓名" width="100" />
            <el-table-column prop="email" label="邮箱" width="180" />
            <el-table-column prop="tenant" label="租户" width="120">
              <template #default="{ row }">
                <el-tag size="small" type="primary">{{ row.tenant }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="department" label="部门" width="120">
              <template #default="{ row }">
                <span>{{ row.department }}</span>
                <el-tooltip v-if="row.departmentPath" :content="row.departmentPath" placement="top">
                  <el-icon class="department-path-icon"><InfoFilled /></el-icon>
                </el-tooltip>
              </template>
            </el-table-column>
            <el-table-column prop="roles" label="角色" width="150">
              <template #default="{ row }">
                <el-tag
                  v-for="role in row.roles"
                  :key="role"
                  size="small"
                  style="margin-right: 5px"
                >
                  {{ role }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.status === 'active' ? 'success' : 'danger'">
                  {{ row.status === 'active' ? '启用' : '禁用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="lastLogin" label="最后登录" width="160" />
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button size="small" @click="editUser(row)">编辑</el-button>
                <el-button size="small" @click="resetPassword(row)">重置密码</el-button>
                <el-button
                  size="small"
                  :type="row.status === 'active' ? 'danger' : 'success'"
                  @click="toggleUserStatus(row)"
                >
                  {{ row.status === 'active' ? '禁用' : '启用' }}
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <!-- 分页 -->
          <div class="pagination">
            <el-pagination
              v-model:current-page="userCurrentPage"
              v-model:page-size="userPageSize"
              :page-sizes="[10, 20, 50, 100]"
              :total="users.length"
              layout="total, sizes, prev, pager, next, jumper"
            />
          </div>
        </div>
      </el-tab-pane>

      <!-- 角色管理 -->
      <el-tab-pane label="角色管理" name="roles">
        <div class="tab-content">
          <!-- 角色操作栏 -->
          <div class="toolbar">
            <div class="search-bar">
              <el-input
                v-model="roleSearch"
                placeholder="搜索角色名称或描述"
                style="width: 300px"
                clearable
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
            </div>
            <div class="actions">
              <el-button type="primary" @click="showRoleDialog = true">
                <el-icon><Plus /></el-icon>
                添加角色
              </el-button>
            </div>
          </div>

          <!-- 角色列表 -->
          <el-table :data="filteredRoles" stripe style="width: 100%">
            <el-table-column prop="name" label="角色名称" width="150" />
            <el-table-column prop="description" label="描述" min-width="200" />
            <el-table-column prop="userCount" label="用户数量" width="100" />
            <el-table-column prop="permissions" label="权限数量" width="100">
              <template #default="{ row }">
                {{ row.permissions.length }}
              </template>
            </el-table-column>
            <el-table-column prop="createdTime" label="创建时间" width="160" />
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button size="small" @click="editRole(row)">编辑</el-button>
                <el-button size="small" @click="configPermissions(row)">配置权限</el-button>
                <el-button size="small" type="danger" @click="deleteRole(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <!-- 权限管理 -->
      <el-tab-pane label="权限管理" name="permissions">
        <div class="tab-content">
          <!-- 权限树 -->
          <div class="permission-tree">
            <h3>系统权限配置</h3>
            <el-tree
              :data="permissionTree"
              show-checkbox
              node-key="id"
              :default-expanded-keys="[1, 2, 3]"
              :default-checked-keys="[]"
              :props="{ children: 'children', label: 'label' }"
            >
              <template #default="{ node, data }">
                <span class="permission-node">
                  <el-icon v-if="data.icon"><component :is="data.icon" /></el-icon>
                  <span>{{ data.label }}</span>
                  <el-tag v-if="data.code" size="small" type="info">{{ data.code }}</el-tag>
                </span>
              </template>
            </el-tree>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>

    <!-- 用户编辑对话框 -->
    <el-dialog v-model="showUserDialog" title="用户信息" width="600px">
      <el-form :model="currentUser" label-width="80px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名">
              <el-input v-model="currentUser.username" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名">
              <el-input v-model="currentUser.name" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="邮箱">
              <el-input v-model="currentUser.email" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机">
              <el-input v-model="currentUser.phone" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="部门">
          <el-select v-model="currentUser.department" style="width: 100%">
            <el-option label="技术部" value="技术部" />
            <el-option label="运维部" value="运维部" />
            <el-option label="产品部" value="产品部" />
            <el-option label="市场部" value="市场部" />
          </el-select>
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="currentUser.roles" multiple style="width: 100%">
            <el-option
              v-for="role in roles"
              :key="role.name"
              :label="role.name"
              :value="role.name"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="currentUser.status">
            <el-radio label="active">启用</el-radio>
            <el-radio label="inactive">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showUserDialog = false">取消</el-button>
        <el-button type="primary" @click="saveUser">保存</el-button>
      </template>
    </el-dialog>

    <!-- 角色编辑对话框 -->
    <el-dialog v-model="showRoleDialog" title="角色信息" width="500px">
      <el-form :model="currentRole" label-width="80px">
        <el-form-item label="角色名称">
          <el-input v-model="currentRole.name" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="currentRole.description" type="textarea" :rows="3" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showRoleDialog = false">取消</el-button>
        <el-button type="primary" @click="saveRole">保存</el-button>
      </template>
    </el-dialog>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Lock, InfoFilled, Plus, Key, Refresh } from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 响应式数据
const activeTab = ref('users')
const userSearch = ref('')
const userStatusFilter = ref('')
const departmentFilter = ref('')
const roleFilter = ref('')
const roleSearch = ref('')
const userCurrentPage = ref(1)
const userPageSize = ref(10)
const showUserDialog = ref(false)
const showRoleDialog = ref(false)
const showCreateDialog = ref(false)
const currentTenant = ref('1')

// 统计卡片数据
const userStatsCards = computed(() => [
  {
    label: '用户总数',
    value: users.value.length,
    icon: 'User',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '活跃用户',
    value: users.value.filter(u => u.status === '正常').length,
    icon: 'CircleCheck',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.3
  },
  {
    label: '角色数量',
    value: roles.value.length,
    icon: 'Key',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 5.7
  },
  {
    label: '在线用户',
    value: Math.floor(users.value.length * 0.3),
    icon: 'Connection',
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

// 当前编辑的用户和角色
const currentUser = ref({
  id: null,
  username: '',
  name: '',
  email: '',
  phone: '',
  department: '',
  roles: [],
  status: 'active'
})

const currentRole = ref({
  id: null,
  name: '',
  description: ''
})

// 租户数据
const tenants = ref([
  { id: '1', name: '阿里巴巴集团', code: 'ALIBABA' },
  { id: '2', name: '腾讯科技', code: 'TENCENT' },
  { id: '3', name: '字节跳动', code: 'BYTEDANCE' }
])

// 部门数据
const departments = ref([
  { id: '1', name: '技术部', path: '阿里巴巴集团/技术部' },
  { id: '2', name: '运维部', path: '阿里巴巴集团/运维部' },
  { id: '3', name: '前端开发组', path: '阿里巴巴集团/技术部/前端开发组' },
  { id: '4', name: '后端开发组', path: '阿里巴巴集团/技术部/后端开发组' },
  { id: '5', name: '甲方', path: '外部客户' }
])

// 演示数据
const users = ref([
  {
    id: 1,
    username: 'admin',
    name: '系统管理员',
    email: 'admin@example.com',
    phone: '13800138000',
    tenant: '阿里巴巴集团',
    department: '技术部',
    departmentPath: '阿里巴巴集团/技术部',
    roles: ['系统管理员'],
    status: 'active',
    lastLogin: '2024-01-15 10:30:00',
    avatar: ''
  },
  {
    id: 2,
    username: 'engineer1',
    name: '张工程师',
    email: 'zhang@example.com',
    phone: '13800138001',
    tenant: '阿里巴巴集团',
    department: '运维部',
    departmentPath: '阿里巴巴集团/运维部',
    roles: ['运维工程师'],
    status: 'active',
    lastLogin: '2024-01-15 09:15:00',
    avatar: ''
  },
  {
    id: 3,
    username: 'manager1',
    name: '李经理',
    email: 'li@example.com',
    phone: '13800138002',
    tenant: '阿里巴巴集团',
    department: '运维部',
    departmentPath: '阿里巴巴集团/运维部',
    roles: ['租户管理员'],
    status: 'active',
    lastLogin: '2024-01-14 16:45:00',
    avatar: ''
  },
  {
    id: 4,
    username: 'client1',
    name: '王客户',
    email: 'wang@client.com',
    phone: '13800138003',
    tenant: '腾讯科技',
    department: '甲方',
    departmentPath: '外部客户',
    roles: ['甲方用户'],
    status: 'active',
    lastLogin: '2024-01-15 08:20:00',
    avatar: ''
  },
  {
    id: 5,
    username: 'engineer2',
    name: '赵工程师',
    email: 'zhao@example.com',
    phone: '13800138004',
    tenant: '阿里巴巴集团',
    department: '运维部',
    departmentPath: '阿里巴巴集团/运维部',
    roles: ['运维工程师'],
    status: 'inactive',
    lastLogin: '2024-01-10 14:30:00',
    avatar: ''
  }
])

const roles = ref([
  {
    id: 1,
    name: '系统管理员',
    description: '拥有系统所有权限，可以管理租户、用户和系统配置',
    userCount: 1,
    permissions: ['SYSTEM_ADMIN', 'USER_MANAGE', 'TENANT_MANAGE'],
    createdTime: '2024-01-01 00:00:00'
  },
  {
    id: 2,
    name: '租户管理员',
    description: '租户内的管理员，可以管理租户内的用户、工单和配置',
    userCount: 1,
    permissions: ['TENANT_ADMIN', 'USER_MANAGE', 'TICKET_MANAGE'],
    createdTime: '2024-01-01 00:00:00'
  },
  {
    id: 3,
    name: '运维工程师',
    description: '处理工单、维护知识库的技术人员',
    userCount: 2,
    permissions: ['TICKET_HANDLE', 'KNOWLEDGE_EDIT'],
    createdTime: '2024-01-01 00:00:00'
  },
  {
    id: 4,
    name: '甲方用户',
    description: '客户方用户，可以提交工单和查看报表',
    userCount: 1,
    permissions: ['TICKET_CREATE', 'REPORT_VIEW'],
    createdTime: '2024-01-01 00:00:00'
  }
])

const permissionTree = ref([
  {
    id: 1,
    label: '系统管理',
    icon: 'Setting',
    children: [
      { id: 11, label: '用户管理', code: 'USER_MANAGE' },
      { id: 12, label: '角色管理', code: 'ROLE_MANAGE' },
      { id: 13, label: '租户管理', code: 'TENANT_MANAGE' },
      { id: 14, label: '系统配置', code: 'SYSTEM_CONFIG' }
    ]
  },
  {
    id: 2,
    label: '工单管理',
    icon: 'Tickets',
    children: [
      { id: 21, label: '工单查看', code: 'TICKET_VIEW' },
      { id: 22, label: '工单创建', code: 'TICKET_CREATE' },
      { id: 23, label: '工单处理', code: 'TICKET_HANDLE' },
      { id: 24, label: '工单管理', code: 'TICKET_MANAGE' }
    ]
  },
  {
    id: 3,
    label: '知识库',
    icon: 'Document',
    children: [
      { id: 31, label: '知识查看', code: 'KNOWLEDGE_VIEW' },
      { id: 32, label: '知识编辑', code: 'KNOWLEDGE_EDIT' },
      { id: 33, label: '知识审核', code: 'KNOWLEDGE_AUDIT' }
    ]
  },
  {
    id: 4,
    label: '报表分析',
    icon: 'DataAnalysis',
    children: [
      { id: 41, label: '报表查看', code: 'REPORT_VIEW' },
      { id: 42, label: '报表导出', code: 'REPORT_EXPORT' },
      { id: 43, label: '数据分析', code: 'DATA_ANALYSIS' }
    ]
  }
])

// 计算属性
const filteredUsers = computed(() => {
  let filtered = users.value

  // 根据当前租户筛选用户（多租户数据隔离）
  const currentTenantName = tenants.value.find(t => t.id === currentTenant.value)?.name
  if (currentTenantName) {
    filtered = filtered.filter(user => user.tenant === currentTenantName)
  }

  if (userSearch.value) {
    const search = userSearch.value.toLowerCase()
    filtered = filtered.filter(user =>
      user.username.toLowerCase().includes(search) ||
      user.name.toLowerCase().includes(search) ||
      user.email.toLowerCase().includes(search)
    )
  }

  if (userStatusFilter.value) {
    filtered = filtered.filter(user => user.status === userStatusFilter.value)
  }

  if (departmentFilter.value) {
    const deptName = departments.value.find(d => d.id === departmentFilter.value)?.name
    filtered = filtered.filter(user => user.department === deptName)
  }

  if (roleFilter.value) {
    filtered = filtered.filter(user => user.roles.includes(roleFilter.value))
  }

  return filtered
})

const filteredRoles = computed(() => {
  if (!roleSearch.value) return roles.value

  const search = roleSearch.value.toLowerCase()
  return roles.value.filter(role =>
    role.name.toLowerCase().includes(search) ||
    role.description.toLowerCase().includes(search)
  )
})

// 方法
const editUser = (user) => {
  currentUser.value = { ...user }
  showUserDialog.value = true
}

const saveUser = () => {
  if (currentUser.value.id) {
    // 更新用户
    const index = users.value.findIndex(u => u.id === currentUser.value.id)
    if (index !== -1) {
      users.value[index] = { ...currentUser.value }
    }
    ElMessage.success('用户信息更新成功')
  } else {
    // 新增用户
    currentUser.value.id = Date.now()
    currentUser.value.lastLogin = '从未登录'
    users.value.push({ ...currentUser.value })
    ElMessage.success('用户创建成功')
  }

  showUserDialog.value = false
  resetCurrentUser()
}

const resetPassword = (user) => {
  ElMessageBox.confirm(
    `确定要重置用户 ${user.name} 的密码吗？`,
    '重置密码',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    ElMessage.success('密码重置成功，新密码已发送到用户邮箱')
  })
}

const toggleUserStatus = (user) => {
  const action = user.status === 'active' ? '禁用' : '启用'
  ElMessageBox.confirm(
    `确定要${action}用户 ${user.name} 吗？`,
    `${action}用户`,
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    user.status = user.status === 'active' ? 'inactive' : 'active'
    ElMessage.success(`用户${action}成功`)
  })
}

const exportUsers = () => {
  ElMessage.success('用户数据导出成功')
}

const editRole = (role) => {
  currentRole.value = { ...role }
  showRoleDialog.value = true
}

const saveRole = () => {
  if (currentRole.value.id) {
    // 更新角色
    const index = roles.value.findIndex(r => r.id === currentRole.value.id)
    if (index !== -1) {
      roles.value[index] = { ...roles.value[index], ...currentRole.value }
    }
    ElMessage.success('角色信息更新成功')
  } else {
    // 新增角色
    currentRole.value.id = Date.now()
    currentRole.value.userCount = 0
    currentRole.value.permissions = []
    currentRole.value.createdTime = new Date().toLocaleString()
    roles.value.push({ ...currentRole.value })
    ElMessage.success('角色创建成功')
  }

  showRoleDialog.value = false
  resetCurrentRole()
}

const configPermissions = (role) => {
  ElMessage.info('权限配置功能开发中...')
}

const deleteRole = (role) => {
  ElMessageBox.confirm(
    `确定要删除角色 ${role.name} 吗？`,
    '删除角色',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    const index = roles.value.findIndex(r => r.id === role.id)
    if (index !== -1) {
      roles.value.splice(index, 1)
    }
    ElMessage.success('角色删除成功')
  })
}

const resetCurrentUser = () => {
  currentUser.value = {
    id: null,
    username: '',
    name: '',
    email: '',
    phone: '',
    department: '',
    roles: [],
    status: 'active'
  }
}

const resetCurrentRole = () => {
  currentRole.value = {
    id: null,
    name: '',
    description: ''
  }
}

onMounted(() => {
  console.log('用户管理模块已加载')
})
</script>

<style scoped>
.user-management {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-content {
  text-align: left;
}

.page-header h1 {
  margin: 0 0 8px 0;
  color: white;
  font-size: 24px;
}

.page-header p {
  margin: 0;
  color: rgba(255, 255, 255, 0.9);
  font-size: 14px;
}

.header-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
  align-items: flex-end;
}

.tenant-switcher {
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.1);
  padding: 8px 12px;
  border-radius: 6px;
}

.switcher-label {
  font-size: 14px;
  opacity: 0.9;
}

.isolation-indicator {
  display: flex;
  align-items: center;
  gap: 5px;
}

.department-path-icon {
  margin-left: 5px;
  color: #909399;
  cursor: help;
}

.demo-tabs {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.tab-content {
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 16px;
}

.search-bar {
  display: flex;
  gap: 12px;
  align-items: center;
}

.actions {
  display: flex;
  gap: 12px;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.permission-tree {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
}

.permission-tree h3 {
  margin: 0 0 16px 0;
  color: #303133;
}

.permission-node {
  display: flex;
  align-items: center;
  gap: 8px;
}

.permission-node .el-tag {
  margin-left: auto;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .user-management {
    padding: 10px;
  }

  .toolbar {
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

/* 对话框样式 */
.el-dialog {
  border-radius: 8px;
}

.el-dialog__header {
  background: #f8f9fa;
  border-bottom: 1px solid #e4e7ed;
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

/* 卡片样式 */
.el-card {
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

/* 按钮样式 */
.el-button {
  border-radius: 6px;
}

.el-button + .el-button {
  margin-left: 8px;
}

/* 输入框样式 */
.el-input, .el-select {
  border-radius: 6px;
}

/* 树形控件样式 */
.el-tree {
  background: transparent;
}

.el-tree-node__content {
  height: 36px;
  border-radius: 6px;
  margin-bottom: 4px;
}

.el-tree-node__content:hover {
  background: #f0f2f5;
}
</style>
