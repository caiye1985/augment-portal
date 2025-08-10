<template>
  <PageLayout
    title="用户手册"
    description="IT运维门户系统使用指南"
    icon="Document"
  >
    <!-- 操作按钮 -->
    <template #actions>
      <el-button @click="downloadPDF">
        <el-icon><Download /></el-icon>
        下载PDF
      </el-button>
      <el-button @click="printManual">
        <el-icon><Printer /></el-icon>
        打印
      </el-button>
      <el-button @click="refreshData">
        <el-icon><Refresh /></el-icon>
        刷新数据
      </el-button>
    </template>

    <!-- 统计数据展示 -->
    <template #stats>
      <el-row :gutter="20">
        <el-col :span="6" v-for="stat in manualStatsCards" :key="stat.label">
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
      <!-- 左侧目录 -->
      <el-col :span="6">
        <el-card class="toc-card">
          <template #header>
            <span>目录</span>
          </template>

          <el-tree
            :data="tocData"
            :props="{ children: 'children', label: 'title' }"
            @node-click="scrollToSection"
            class="manual-toc"
          />
        </el-card>
      </el-col>

      <!-- 右侧内容 -->
      <el-col :span="18">
        <div class="manual-content">
          <!-- 快速开始 -->
          <section id="quick-start" class="manual-section">
            <h2>快速开始</h2>
            <div class="section-content">
              <h3>系统概述</h3>
              <p>IT运维门户系统是一个企业级的运维管理平台，提供工单管理、工程师管理、排班管理、考核培训等核心功能。</p>

              <h3>登录系统</h3>
              <ol>
                <li>打开系统登录页面</li>
                <li>输入您的邮箱、手机号或租户编码</li>
                <li>系统会自动识别您的租户信息</li>
                <li>选择登录方式（密码、短信验证码、邮箱验证码）</li>
                <li>完成身份验证后即可进入系统</li>
              </ol>

              <div class="tip-box">
                <el-icon><InfoFilled /></el-icon>
                <span>提示：首次登录建议使用演示账号体验系统功能</span>
              </div>
            </div>
          </section>

          <!-- 工单管理 -->
          <section id="ticket-management" class="manual-section">
            <h2>工单管理</h2>
            <div class="section-content">
              <h3>创建工单</h3>
              <ol>
                <li>点击"创建工单"按钮</li>
                <li>填写工单基本信息（标题、描述、优先级、分类）</li>
                <li>配置智能派单参数（技能要求、地理位置等）</li>
                <li>选择分配方式（自动分配、手动分配、暂不分配）</li>
                <li>上传相关附件（可选）</li>
                <li>点击"创建工单"完成创建</li>
              </ol>

              <h3>工单处理流程</h3>
              <div class="process-flow">
                <div class="flow-step">
                  <div class="step-number">1</div>
                  <div class="step-content">
                    <h4>新建</h4>
                    <p>工单创建后的初始状态</p>
                  </div>
                </div>
                <div class="flow-arrow">→</div>
                <div class="flow-step">
                  <div class="step-number">2</div>
                  <div class="step-content">
                    <h4>已分配</h4>
                    <p>工单分配给具体工程师</p>
                  </div>
                </div>
                <div class="flow-arrow">→</div>
                <div class="flow-step">
                  <div class="step-number">3</div>
                  <div class="step-content">
                    <h4>处理中</h4>
                    <p>工程师开始处理工单</p>
                  </div>
                </div>
                <div class="flow-arrow">→</div>
                <div class="flow-step">
                  <div class="step-number">4</div>
                  <div class="step-content">
                    <h4>已完成</h4>
                    <p>工单处理完成</p>
                  </div>
                </div>
              </div>

              <h3>智能派单功能</h3>
              <p>系统支持基于以下因素的智能派单：</p>
              <ul>
                <li><strong>技能匹配</strong>：根据工单所需技能自动匹配合适的工程师</li>
                <li><strong>工作负载</strong>：优先分配给当前工作量较少的工程师</li>
                <li><strong>地理位置</strong>：就近分配，减少响应时间</li>
                <li><strong>历史表现</strong>：考虑工程师的历史处理效率和质量</li>
              </ul>
            </div>
          </section>

          <!-- 工程师管理 -->
          <section id="engineer-management" class="manual-section">
            <h2>工程师管理</h2>
            <div class="section-content">
              <h3>工程师档案</h3>
              <p>点击工程师列表中的"档案"按钮可以查看详细的工程师档案，包括：</p>
              <ul>
                <li>个人基本信息</li>
                <li>技能认证情况</li>
                <li>考核记录</li>
                <li>工作履历</li>
                <li>培训计划</li>
              </ul>

              <h3>技能认证</h3>
              <p>工程师可以通过在线考试获得技能认证：</p>
              <ol>
                <li>在技能管理页面添加需要认证的技能</li>
                <li>点击"参加考试"开始在线考试</li>
                <li>完成考试后系统自动评分</li>
                <li>达到80分及以上即可获得认证</li>
              </ol>
            </div>
          </section>

          <!-- 排班管理 -->
          <section id="schedule-management" class="manual-section">
            <h2>排班管理</h2>
            <div class="section-content">
              <h3>创建排班</h3>
              <ol>
                <li>点击"创建排班"按钮</li>
                <li>选择工程师和日期范围</li>
                <li>设置班次类型（白班、夜班、值班）</li>
                <li>填写值班地点和备注</li>
                <li>保存排班安排</li>
              </ol>

              <h3>排班视图</h3>
              <p>系统提供三种排班视图：</p>
              <ul>
                <li><strong>日历视图</strong>：以周为单位的网格视图，直观显示每个时间段的排班情况</li>
                <li><strong>表格视图</strong>：详细的排班列表，支持筛选和编辑</li>
                <li><strong>甘特图</strong>：以时间轴形式展示工程师的工作安排</li>
              </ul>
            </div>
          </section>

          <!-- 考核培训 -->
          <section id="training-exam" class="manual-section">
            <h2>考核培训</h2>
            <div class="section-content">
              <h3>考核管理</h3>
              <p>管理员可以安排技能考核：</p>
              <ol>
                <li>创建考试安排</li>
                <li>选择参考工程师和试卷</li>
                <li>设置考试时间和规则</li>
                <li>监控考试过程</li>
                <li>查看考试结果</li>
              </ol>

              <h3>培训管理</h3>
              <p>系统支持完整的培训管理流程：</p>
              <ul>
                <li>创建培训计划</li>
                <li>管理课程资源库</li>
                <li>跟踪学习进度</li>
                <li>培训效果评估</li>
              </ul>
            </div>
          </section>

          <!-- 系统配置 -->
          <section id="system-config" class="manual-section">
            <h2>系统配置</h2>
            <div class="section-content">
              <h3>基础配置</h3>
              <p>管理员可以配置系统的基本参数：</p>
              <ul>
                <li>系统名称和版本</li>
                <li>公司信息</li>
                <li>时区和语言设置</li>
                <li>系统Logo</li>
              </ul>

              <h3>安全配置</h3>
              <p>系统提供丰富的安全配置选项：</p>
              <ul>
                <li>密码策略设置</li>
                <li>登录安全控制</li>
                <li>会话管理</li>
                <li>IP白名单</li>
                <li>安全功能开关</li>
              </ul>

              <h3>集成配置</h3>
              <p>支持与第三方系统集成：</p>
              <ul>
                <li>LDAP认证</li>
                <li>钉钉集成</li>
                <li>企业微信集成</li>
                <li>邮件服务配置</li>
              </ul>
            </div>
          </section>

          <!-- 常见问题 -->
          <section id="faq" class="manual-section">
            <h2>常见问题</h2>
            <div class="section-content">
              <div class="faq-item">
                <h4>Q: 忘记密码怎么办？</h4>
                <p>A: 可以使用短信验证码或邮箱验证码登录，或联系管理员重置密码。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 如何修改个人信息？</h4>
                <p>A: 点击右上角头像，选择"个人设置"进行修改。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 工单分配规则是什么？</h4>
                <p>A: 系统根据技能匹配、工作负载、地理位置等因素智能分配工单。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 如何查看工单处理历史？</h4>
                <p>A: 在工单详情页面可以查看完整的处理历史和状态变更记录。</p>
              </div>

              <div class="faq-item">
                <h4>Q: 系统支持哪些浏览器？</h4>
                <p>A: 推荐使用Chrome、Firefox、Safari、Edge等现代浏览器的最新版本。</p>
              </div>
            </div>
          </section>

          <!-- 联系支持 -->
          <section id="support" class="manual-section">
            <h2>联系支持</h2>
            <div class="section-content">
              <p>如果您在使用过程中遇到问题，可以通过以下方式获得帮助：</p>

              <div class="contact-info">
                <div class="contact-item">
                  <el-icon><Message /></el-icon>
                  <div>
                    <h4>技术支持邮箱</h4>
                    <p>support@example.com</p>
                  </div>
                </div>

                <div class="contact-item">
                  <el-icon><Phone /></el-icon>
                  <div>
                    <h4>技术支持热线</h4>
                    <p>400-123-4567</p>
                  </div>
                </div>

                <div class="contact-item">
                  <el-icon><ChatDotRound /></el-icon>
                  <div>
                    <h4>在线客服</h4>
                    <p>工作日 9:00-18:00</p>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>
      </el-col>
    </el-row>
    </template>
  </PageLayout>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import {
  Document, Download, Printer, InfoFilled, Message, Phone, ChatDotRound, Refresh,
  Reading, QuestionFilled
} from '@element-plus/icons-vue'
import PageLayout from '@/components/PageLayout.vue'
import StatCard from '@/components/StatCard.vue'

// 统计卡片数据
const manualStatsCards = computed(() => [
  {
    label: '章节总数',
    value: tocData.value.length,
    icon: 'Document',
    color: 'var(--el-color-primary, #6366f1)',
    trend: 8.5
  },
  {
    label: '页面数量',
    value: 45,
    icon: 'Reading',
    color: 'var(--el-color-success, #10b981)',
    trend: 12.3
  },
  {
    label: '常见问题',
    value: 15,
    icon: 'QuestionFilled',
    color: 'var(--el-color-warning, #f59e0b)',
    trend: 5.7
  },
  {
    label: '更新版本',
    value: 'v2.1',
    icon: 'Refresh',
    color: 'var(--el-color-info, #3b82f6)',
    trend: 0
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

// 目录数据
const tocData = ref([
  {
    title: '快速开始',
    id: 'quick-start',
    children: [
      { title: '系统概述', id: 'quick-start' },
      { title: '登录系统', id: 'quick-start' }
    ]
  },
  {
    title: '工单管理',
    id: 'ticket-management',
    children: [
      { title: '创建工单', id: 'ticket-management' },
      { title: '工单处理流程', id: 'ticket-management' },
      { title: '智能派单功能', id: 'ticket-management' }
    ]
  },
  {
    title: '工程师管理',
    id: 'engineer-management',
    children: [
      { title: '工程师档案', id: 'engineer-management' },
      { title: '技能认证', id: 'engineer-management' }
    ]
  },
  {
    title: '排班管理',
    id: 'schedule-management',
    children: [
      { title: '创建排班', id: 'schedule-management' },
      { title: '排班视图', id: 'schedule-management' }
    ]
  },
  {
    title: '考核培训',
    id: 'training-exam',
    children: [
      { title: '考核管理', id: 'training-exam' },
      { title: '培训管理', id: 'training-exam' }
    ]
  },
  {
    title: '系统配置',
    id: 'system-config',
    children: [
      { title: '基础配置', id: 'system-config' },
      { title: '安全配置', id: 'system-config' },
      { title: '集成配置', id: 'system-config' }
    ]
  },
  {
    title: '常见问题',
    id: 'faq'
  },
  {
    title: '联系支持',
    id: 'support'
  }
])

// 方法
const scrollToSection = (data) => {
  const element = document.getElementById(data.id)
  if (element) {
    element.scrollIntoView({ behavior: 'smooth' })
  }
}

const downloadPDF = () => {
  ElMessage.success('PDF下载功能开发中...')
}

const printManual = () => {
  window.print()
}
</script>

<style scoped>
.user-manual {
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

.toc-card {
  position: sticky;
  top: 20px;
  max-height: calc(100vh - 40px);
  overflow-y: auto;
}

.manual-toc {
  border: none;
}

.manual-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 30px;
}

.manual-section {
  margin-bottom: 40px;
  scroll-margin-top: 20px;
}

.manual-section h2 {
  color: #303133;
  border-bottom: 2px solid #409eff;
  padding-bottom: 10px;
  margin-bottom: 20px;
}

.manual-section h3 {
  color: #606266;
  margin: 20px 0 10px 0;
}

.manual-section h4 {
  color: #909399;
  margin: 15px 0 8px 0;
}

.section-content {
  line-height: 1.6;
  color: #606266;
}

.section-content p {
  margin-bottom: 12px;
}

.section-content ol,
.section-content ul {
  margin-bottom: 16px;
  padding-left: 20px;
}

.section-content li {
  margin-bottom: 6px;
}

.tip-box {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #e6f7ff;
  border: 1px solid #91d5ff;
  border-radius: 6px;
  margin: 16px 0;
  color: #1890ff;
}

.process-flow {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 20px 0;
  flex-wrap: wrap;
  gap: 10px;
}

.flow-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  min-width: 120px;
}

.step-number {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #409eff;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  margin-bottom: 8px;
}

.step-content h4 {
  margin: 0 0 4px 0;
  color: #303133;
}

.step-content p {
  margin: 0;
  font-size: 12px;
  color: #909399;
}

.flow-arrow {
  font-size: 20px;
  color: #409eff;
  font-weight: bold;
}

.faq-item {
  margin-bottom: 20px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 6px;
  border-left: 4px solid #409eff;
}

.faq-item h4 {
  margin: 0 0 8px 0;
  color: #303133;
}

.faq-item p {
  margin: 0;
  color: #606266;
}

.contact-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
}

.contact-item .el-icon {
  font-size: 24px;
  color: #409eff;
}

.contact-item h4 {
  margin: 0 0 4px 0;
  color: #303133;
}

.contact-item p {
  margin: 0;
  color: #606266;
}

@media print {
  .page-header,
  .toc-card {
    display: none;
  }

  .manual-content {
    box-shadow: none;
    padding: 0;
  }
}
</style>
