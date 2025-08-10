<template>
  <div class="theme-demo">
    <div class="demo-header">
      <h1>主题演示页面</h1>
      <p>测试深色/浅色模式和主题色切换功能</p>
    </div>

    <!-- 主题控制面板 -->
    <div class="theme-controls-panel">
      <el-card class="control-card">
        <template #header>
          <div class="card-header">
            <span>主题控制</span>
          </div>
        </template>
        
        <div class="control-group">
          <label>主题模式：</label>
          <el-switch
            v-model="themeStore.isDark"
            @change="themeStore.toggleMode"
            active-text="深色"
            inactive-text="浅色"
            :active-icon="Moon"
            :inactive-icon="Sunny"
          />
        </div>

        <div class="control-group">
          <label>主题色：</label>
          <div class="color-grid">
            <div
              v-for="(colorConfig, colorKey) in themeStore.themeColors"
              :key="colorKey"
              class="color-item"
              :class="{ active: themeStore.color === colorKey }"
              @click="themeStore.setColor(colorKey)"
            >
              <div
                class="color-preview"
                :style="{ backgroundColor: colorConfig.primary }"
              ></div>
              <span>{{ colorConfig.name }}</span>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 组件演示 -->
    <div class="demo-content">
      <div class="demo-row">
        <el-card class="demo-card">
          <template #header>
            <div class="card-header">
              <span>按钮组件</span>
            </div>
          </template>
          <div class="button-group">
            <el-button type="primary">主要按钮</el-button>
            <el-button type="success">成功按钮</el-button>
            <el-button type="warning">警告按钮</el-button>
            <el-button type="danger">危险按钮</el-button>
            <el-button type="info">信息按钮</el-button>
          </div>
        </el-card>

        <el-card class="demo-card">
          <template #header>
            <div class="card-header">
              <span>表单组件</span>
            </div>
          </template>
          <el-form :model="demoForm" label-width="80px">
            <el-form-item label="用户名">
              <el-input v-model="demoForm.username" placeholder="请输入用户名" />
            </el-form-item>
            <el-form-item label="密码">
              <el-input v-model="demoForm.password" type="password" placeholder="请输入密码" />
            </el-form-item>
            <el-form-item label="选择器">
              <el-select v-model="demoForm.select" placeholder="请选择">
                <el-option label="选项1" value="1" />
                <el-option label="选项2" value="2" />
                <el-option label="选项3" value="3" />
              </el-select>
            </el-form-item>
          </el-form>
        </el-card>
      </div>

      <div class="demo-row">
        <el-card class="demo-card">
          <template #header>
            <div class="card-header">
              <span>数据展示</span>
            </div>
          </template>
          <el-table :data="tableData" style="width: 100%">
            <el-table-column prop="name" label="姓名" width="120" />
            <el-table-column prop="age" label="年龄" width="80" />
            <el-table-column prop="address" label="地址" />
          </el-table>
        </el-card>

        <el-card class="demo-card">
          <template #header>
            <div class="card-header">
              <span>导航菜单</span>
            </div>
          </template>
          <el-menu default-active="1" mode="vertical">
            <el-menu-item index="1">
              <el-icon><House /></el-icon>
              <span>首页</span>
            </el-menu-item>
            <el-menu-item index="2">
              <el-icon><User /></el-icon>
              <span>用户管理</span>
            </el-menu-item>
            <el-menu-item index="3">
              <el-icon><Setting /></el-icon>
              <span>系统设置</span>
            </el-menu-item>
          </el-menu>
        </el-card>
      </div>
    </div>

    <!-- 返回登录 -->
    <div class="demo-footer">
      <el-button @click="$router.push('/login')" type="primary">
        <el-icon><ArrowLeft /></el-icon>
        返回登录页面
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useThemeStore } from '@/stores/theme'
import { 
  Moon, Sunny, House, User, Setting, ArrowLeft 
} from '@element-plus/icons-vue'

const themeStore = useThemeStore()

// 演示表单数据
const demoForm = reactive({
  username: '',
  password: '',
  select: ''
})

// 演示表格数据
const tableData = ref([
  { name: '张三', age: 25, address: '北京市朝阳区' },
  { name: '李四', age: 30, address: '上海市浦东新区' },
  { name: '王五', age: 28, address: '广州市天河区' }
])
</script>

<style scoped>
.theme-demo {
  min-height: 100vh;
  padding: 20px;
  background: var(--bg-primary);
}

.demo-header {
  text-align: center;
  margin-bottom: 30px;
}

.demo-header h1 {
  color: var(--text-primary);
  margin-bottom: 10px;
}

.demo-header p {
  color: var(--text-secondary);
}

.theme-controls-panel {
  margin-bottom: 30px;
}

.control-card {
  max-width: 600px;
  margin: 0 auto;
}

.control-group {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.control-group label {
  width: 100px;
  color: var(--text-primary);
}

.color-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 10px;
  flex: 1;
}

.color-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.color-item:hover {
  background: var(--bg-secondary);
}

.color-item.active {
  border-color: var(--primary-color);
  background: var(--bg-secondary);
}

.color-preview {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  margin-bottom: 5px;
}

.color-item span {
  font-size: 12px;
  color: var(--text-secondary);
}

.demo-content {
  max-width: 1200px;
  margin: 0 auto;
}

.demo-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.demo-card {
  min-height: 300px;
}

.button-group {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.demo-footer {
  text-align: center;
  margin-top: 40px;
}

@media (max-width: 768px) {
  .demo-row {
    grid-template-columns: 1fr;
  }
  
  .color-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}
</style>
