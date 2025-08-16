<template>
  <div class="ticket-list">
    <!-- 搜索和筛选区域 -->
    <el-card class="search-card" shadow="never">
      <el-form :model="searchParams" inline>
        <el-form-item label="关键词">
          <el-input
            v-model="searchParams.keyword"
            placeholder="搜索工单标题或描述"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchParams.status" placeholder="选择状态" clearable>
            <el-option
              v-for="status in statusOptions"
              :key="status.value"
              :label="status.label"
              :value="status.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级">
          <el-select v-model="searchParams.priority" placeholder="选择优先级" clearable>
            <el-option
              v-for="priority in priorityOptions"
              :key="priority.value"
              :label="priority.label"
              :value="priority.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作按钮区域 -->
    <el-card class="action-card" shadow="never">
      <el-row justify="space-between">
        <el-col :span="12">
          <el-button type="primary" @click="handleCreate">
            <el-icon><Plus /></el-icon>
            创建工单
          </el-button>
          <el-button 
            type="warning" 
            :disabled="!hasSelection"
            @click="handleBatchUpdate"
          >
            批量更新
          </el-button>
        </el-col>
        <el-col :span="12" class="text-right">
          <el-button @click="handleExport">导出</el-button>
          <el-button @click="handleRefresh">
            <el-icon><Refresh /></el-icon>
            刷新
          </el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 数据表格 -->
    <el-card shadow="never">
      <TicketTable
        :data="ticketList"
        :loading="loading"
        :pagination="pagination"
        @edit="handleEdit"
        @view="handleView"
        @delete="handleDelete"
        @assign="handleAssign"
        @update-status="handleUpdateStatus"
        @selection-change="handleSelectionChange"
        @page-change="handlePageChange"
        @sort-change="handleSortChange"
      />
    </el-card>

    <!-- 状态更新对话框 -->
    <el-dialog
      v-model="statusDialogVisible"
      title="更新工单状态"
      width="500px"
    >
      <el-form :model="statusForm" label-width="100px">
        <el-form-item label="新状态" required>
          <el-select v-model="statusForm.toStatus" placeholder="选择新状态">
            <el-option
              v-for="status in allowedStatusTransitions"
              :key="status.value"
              :label="status.label"
              :value="status.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="变更原因">
          <el-input
            v-model="statusForm.reason"
            type="textarea"
            :rows="3"
            placeholder="请输入状态变更原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="statusDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmStatusUpdate">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh } from '@element-plus/icons-vue'
import TicketTable from '@/components/ticket/TicketTable.vue'
import { useTicketStore } from '@/stores/ticket'

// 基于AI增强PRD模板生成的Vue组件

const router = useRouter()
const ticketStore = useTicketStore()

// 响应式数据
const loading = ref(false)
const statusDialogVisible = ref(false)
const selectedTickets = ref([])
const currentTicketId = ref(null)

// 搜索参数
const searchParams = reactive({
  keyword: '',
  status: '',
  priority: '',
  assignedTo: '',
  page: 0,
  size: 20
})

// 状态更新表单
const statusForm = reactive({
  toStatus: '',
  reason: ''
})

// 计算属性
const ticketList = computed(() => ticketStore.ticketList)
const pagination = computed(() => ticketStore.pagination)
const statusOptions = computed(() => ticketStore.statusOptions)
const priorityOptions = computed(() => ticketStore.priorityOptions)
const hasSelection = computed(() => selectedTickets.value.length > 0)
const allowedStatusTransitions = computed(() => {
  // 根据当前工单状态返回允许的状态转换
  return statusOptions.value.filter(status => 
    status.value !== searchParams.status
  )
})

// 方法
const handleSearch = async () => {
  loading.value = true
  try {
    await ticketStore.fetchTicketList(searchParams)
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  Object.assign(searchParams, {
    keyword: '',
    status: '',
    priority: '',
    assignedTo: '',
    page: 0,
    size: 20
  })
  handleSearch()
}

const handleCreate = () => {
  router.push('/ticket/create')
}

const handleEdit = (ticket) => {
  router.push(`/ticket/${ticket.id}/edit`)
}

const handleView = (ticket) => {
  router.push(`/ticket/${ticket.id}`)
}

const handleDelete = async (ticket) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除工单 ${ticket.ticketNo} 吗？`,
      '确认删除',
      { type: 'warning' }
    )
    
    await ticketStore.deleteTicket(ticket.id)
    ElMessage.success('删除成功')
    handleSearch()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleAssign = (ticket) => {
  // 打开分配对话框或跳转到分配页面
  router.push(`/ticket/${ticket.id}/assign`)
}

const handleUpdateStatus = (ticket) => {
  currentTicketId.value = ticket.id
  statusForm.toStatus = ''
  statusForm.reason = ''
  statusDialogVisible.value = true
}

const confirmStatusUpdate = async () => {
  try {
    await ticketStore.updateTicketStatus(currentTicketId.value, statusForm)
    ElMessage.success('状态更新成功')
    statusDialogVisible.value = false
    handleSearch()
  } catch (error) {
    ElMessage.error('状态更新失败')
  }
}

const handleSelectionChange = (selection) => {
  selectedTickets.value = selection
}

const handleBatchUpdate = () => {
  // 实现批量更新逻辑
  console.log('批量更新', selectedTickets.value)
}

const handleExport = () => {
  // 实现导出逻辑
  console.log('导出工单')
}

const handleRefresh = () => {
  handleSearch()
}

const handlePageChange = (page) => {
  searchParams.page = page - 1
  handleSearch()
}

const handleSortChange = ({ prop, order }) => {
  searchParams.sortBy = prop
  searchParams.sortOrder = order
  handleSearch()
}

// 生命周期
onMounted(() => {
  handleSearch()
})
</script>

<style scoped>
.ticket-list {
  padding: 20px;
}

.search-card,
.action-card {
  margin-bottom: 20px;
}

.text-right {
  text-align: right;
}
</style>
