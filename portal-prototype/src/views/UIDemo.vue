<template>
  <div class="ui-demo">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>UI结构API演示</span>
          <el-button type="primary" @click="fetchUIStructure">获取UI结构</el-button>
        </div>
      </template>

      <div class="demo-content">
        <el-row :gutter="20">
          <el-col :span="12">
            <div class="demo-component">
              <h3>示例组件</h3>
              <el-form :model="form" label-width="120px">
                <el-form-item label="用户名">
                  <el-input v-model="form.username" />
                </el-form-item>
                <el-form-item label="密码">
                  <el-input v-model="form.password" type="password" />
                </el-form-item>
                <el-form-item label="记住我">
                  <el-switch v-model="form.remember" />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" @click="submitForm">提交</el-button>
                  <el-button @click="resetForm">重置</el-button>
                </el-form-item>
              </el-form>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="json-viewer">
              <h3>UI结构数据</h3>
              <pre>{{ JSON.stringify(uiStructure, null, 2) }}</pre>
            </div>
          </el-col>
        </el-row>
      </div>
    </el-card>
  </div>
</template>

<script>
import { fetchUIStructure } from '@/services/uiApi'

export default {
  name: 'UIDemo',
  data() {
    return {
      form: {
        username: '',
        password: '',
        remember: false
      },
      uiStructure: null
    }
  },
  methods: {
    fetchUIStructure() {
      fetchUIStructure(this).then(response => {
        this.uiStructure = response.data
        this.$message.success('UI结构获取成功')
      }).catch(error => {
        console.error('获取UI结构失败:', error)
        this.$message.error('获取UI结构失败')
      })
    },
    submitForm() {
      this.$message.success('表单提交成功')
    },
    resetForm() {
      this.form = {
        username: '',
        password: '',
        remember: false
      }
    }
  }
}
</script>

<style scoped>
.ui-demo {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.demo-content {
  margin-top: 20px;
}

.demo-component {
  padding: 20px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
}

.json-viewer {
  padding: 20px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  background-color: #f5f7fa;
  max-height: 600px;
  overflow: auto;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>