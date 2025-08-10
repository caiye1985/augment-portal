<template>
  <div class="user-guide">
    <!-- 引导遮罩 -->
    <div v-if="showGuide" class="guide-overlay" @click="skipGuide">
      <!-- 引导步骤 -->
      <div
        v-for="(step, index) in guideSteps"
        :key="index"
        v-show="currentStep === index"
        class="guide-step"
        :style="getStepPosition(step)"
      >
        <div class="guide-content">
          <div class="guide-header">
            <div class="step-indicator">
              <span class="step-number">{{ index + 1 }}</span>
              <span class="step-total">/ {{ guideSteps.length }}</span>
            </div>
            <el-button
              text
              size="small"
              @click="skipGuide"
              class="skip-btn"
            >
              跳过
            </el-button>
          </div>
          
          <div class="guide-body">
            <h3 class="guide-title">{{ step.title }}</h3>
            <p class="guide-description">{{ step.description }}</p>
            
            <!-- 功能演示 -->
            <div v-if="step.demo" class="guide-demo">
              <div class="demo-content" v-html="step.demo"></div>
            </div>
            
            <!-- 操作提示 -->
            <div v-if="step.action" class="guide-action">
              <el-button
                type="primary"
                size="small"
                @click="performAction(step.action)"
              >
                {{ step.actionText || '试试看' }}
              </el-button>
            </div>
          </div>
          
          <div class="guide-footer">
            <el-button
              v-if="index > 0"
              size="small"
              @click="previousStep"
            >
              上一步
            </el-button>
            <el-button
              v-if="index < guideSteps.length - 1"
              type="primary"
              size="small"
              @click="nextStep"
            >
              下一步
            </el-button>
            <el-button
              v-else
              type="primary"
              size="small"
              @click="finishGuide"
            >
              完成
            </el-button>
          </div>
        </div>
        
        <!-- 指向箭头 -->
        <div
          v-if="step.target"
          class="guide-arrow"
          :class="step.arrowDirection || 'bottom'"
        ></div>
      </div>
    </div>

    <!-- 引导触发按钮 -->
    <el-button
      v-if="!showGuide && showTrigger"
      circle
      size="small"
      class="guide-trigger"
      @click="startGuide"
      title="新手引导"
    >
      <el-icon><QuestionFilled /></el-icon>
    </el-button>

    <!-- 引导完成提示 -->
    <el-dialog
      v-model="showCompletionDialog"
      title="引导完成"
      width="400px"
      :close-on-click-modal="false"
      center
    >
      <div class="completion-content">
        <div class="completion-icon">
          <el-icon><SuccessFilled /></el-icon>
        </div>
        <h3>恭喜！您已完成新手引导</h3>
        <p>现在您可以开始使用IT运维门户系统了。如果需要帮助，可以随时点击右下角的帮助按钮。</p>
        
        <div class="completion-tips">
          <h4>快速提示：</h4>
          <ul>
            <li>使用 <kbd>Cmd+K</kbd> 快速搜索功能</li>
            <li>点击星标按钮收藏常用页面</li>
            <li>查看面包屑导航快速返回上级页面</li>
          </ul>
        </div>
      </div>
      
      <template #footer>
        <el-checkbox v-model="dontShowAgain">不再显示引导</el-checkbox>
        <el-button type="primary" @click="closeCompletionDialog">
          开始使用
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { QuestionFilled, SuccessFilled } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const props = defineProps({
  autoStart: {
    type: Boolean,
    default: false
  },
  showTrigger: {
    type: Boolean,
    default: true
  }
})

// 响应式数据
const showGuide = ref(false)
const currentStep = ref(0)
const showCompletionDialog = ref(false)
const dontShowAgain = ref(false)

// 引导步骤配置
const guideSteps = ref([
  {
    title: '欢迎使用IT运维门户系统',
    description: '这是一个功能强大的运维管理平台，让我们一起了解主要功能。',
    target: null,
    demo: `
      <div style="text-align: center; padding: 20px;">
        <div style="font-size: 48px; color: #409eff; margin-bottom: 16px;">🎉</div>
        <p>让我们开始探索这个系统的强大功能吧！</p>
      </div>
    `
  },
  {
    title: '全局搜索功能',
    description: '使用 Cmd+K 或点击搜索按钮，快速找到任何功能、工单或工程师信息。',
    target: '.global-search-container',
    arrowDirection: 'top',
    action: 'openSearch',
    actionText: '试试搜索'
  },
  {
    title: '收藏夹功能',
    description: '将常用页面添加到收藏夹，方便快速访问。点击星标按钮管理您的收藏。',
    target: '.favorites-container',
    arrowDirection: 'top',
    action: 'openFavorites',
    actionText: '查看收藏'
  },
  {
    title: '面包屑导航',
    description: '面包屑导航显示当前位置，点击可快速返回上级页面。还有刷新和收藏按钮。',
    target: '.breadcrumb-nav',
    arrowDirection: 'bottom'
  },
  {
    title: '主要功能模块',
    description: '顶部菜单包含了所有主要功能：工作台、工单服务、运维管理、人员管理等。',
    target: '.top-menu',
    arrowDirection: 'bottom'
  },
  {
    title: '侧边栏导航',
    description: '左侧菜单显示当前模块的子功能，点击可快速切换到不同的功能页面。',
    target: '.layout-aside',
    arrowDirection: 'right'
  },
  {
    title: '页面操作区',
    description: '每个页面都有相应的操作按钮，如新建、刷新、导出等，让您高效完成工作。',
    target: '.page-header .header-actions',
    arrowDirection: 'bottom'
  }
])

// 计算属性
const isFirstVisit = computed(() => {
  return !localStorage.getItem('user-guide-completed')
})

// 方法
const startGuide = () => {
  showGuide.value = true
  currentStep.value = 0
  document.body.style.overflow = 'hidden'
}

const nextStep = () => {
  if (currentStep.value < guideSteps.value.length - 1) {
    currentStep.value++
  }
}

const previousStep = () => {
  if (currentStep.value > 0) {
    currentStep.value--
  }
}

const skipGuide = () => {
  showGuide.value = false
  document.body.style.overflow = ''
  ElMessage.info('已跳过新手引导')
}

const finishGuide = () => {
  showGuide.value = false
  document.body.style.overflow = ''
  showCompletionDialog.value = true
}

const closeCompletionDialog = () => {
  showCompletionDialog.value = false
  
  if (dontShowAgain.value) {
    localStorage.setItem('user-guide-completed', 'true')
    localStorage.setItem('user-guide-dont-show', 'true')
  } else {
    localStorage.setItem('user-guide-completed', 'true')
  }
  
  ElMessage.success('欢迎使用IT运维门户系统！')
}

const getStepPosition = (step) => {
  if (!step.target) {
    return {
      position: 'fixed',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      zIndex: 3000
    }
  }

  // 获取目标元素位置
  const targetElement = document.querySelector(step.target)
  if (!targetElement) {
    return {
      position: 'fixed',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      zIndex: 3000
    }
  }

  const rect = targetElement.getBoundingClientRect()
  const arrowDirection = step.arrowDirection || 'bottom'
  
  let top, left, transform

  switch (arrowDirection) {
    case 'top':
      top = rect.bottom + 20
      left = rect.left + rect.width / 2
      transform = 'translateX(-50%)'
      break
    case 'bottom':
      top = rect.top - 20
      left = rect.left + rect.width / 2
      transform = 'translateX(-50%) translateY(-100%)'
      break
    case 'left':
      top = rect.top + rect.height / 2
      left = rect.right + 20
      transform = 'translateY(-50%)'
      break
    case 'right':
      top = rect.top + rect.height / 2
      left = rect.left - 20
      transform = 'translateY(-50%) translateX(-100%)'
      break
    default:
      top = rect.bottom + 20
      left = rect.left + rect.width / 2
      transform = 'translateX(-50%)'
  }

  return {
    position: 'fixed',
    top: `${top}px`,
    left: `${left}px`,
    transform,
    zIndex: 3000
  }
}

const performAction = (action) => {
  switch (action) {
    case 'openSearch':
      // 触发全局搜索
      const searchBtn = document.querySelector('.search-trigger-btn')
      if (searchBtn) {
        searchBtn.click()
      }
      break
    case 'openFavorites':
      // 触发收藏夹
      const favoritesBtn = document.querySelector('.favorites-trigger')
      if (favoritesBtn) {
        favoritesBtn.click()
      }
      break
    default:
      ElMessage.info(`执行操作: ${action}`)
  }
}

const checkShouldShowGuide = () => {
  const completed = localStorage.getItem('user-guide-completed')
  const dontShow = localStorage.getItem('user-guide-dont-show')
  
  if (!completed && !dontShow && (props.autoStart || isFirstVisit.value)) {
    // 延迟显示，等待页面完全加载
    setTimeout(() => {
      startGuide()
    }, 1000)
  }
}

// 生命周期
onMounted(() => {
  checkShouldShowGuide()
})

// 暴露方法给父组件
defineExpose({
  startGuide,
  skipGuide
})
</script>

<style scoped>
.user-guide {
  position: relative;
}

.guide-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 2999;
  backdrop-filter: blur(4px);
}

.guide-step {
  position: fixed;
  z-index: 3000;
  animation: fadeInScale 0.3s ease-out;
}

.guide-content {
  background: var(--el-bg-color);
  border-radius: 12px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
  border: 1px solid var(--el-border-color-light);
  overflow: hidden;
  min-width: 300px;
  max-width: 400px;
}

.guide-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: var(--el-color-primary);
  color: white;
}

.step-indicator {
  font-size: 14px;
  font-weight: 600;
}

.step-number {
  font-size: 18px;
}

.step-total {
  opacity: 0.8;
}

.skip-btn {
  color: rgba(255, 255, 255, 0.8) !important;
  font-size: 12px;
}

.skip-btn:hover {
  color: white !important;
}

.guide-body {
  padding: 20px;
}

.guide-title {
  margin: 0 0 12px 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.guide-description {
  margin: 0 0 16px 0;
  color: var(--el-text-color-regular);
  line-height: 1.6;
}

.guide-demo {
  margin: 16px 0;
  padding: 16px;
  background: var(--el-fill-color-lighter);
  border-radius: 8px;
  border: 1px solid var(--el-border-color-lighter);
}

.guide-action {
  margin-top: 16px;
  text-align: center;
}

.guide-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px 20px;
  background: var(--el-fill-color-lighter);
  border-top: 1px solid var(--el-border-color-lighter);
}

.guide-arrow {
  position: absolute;
  width: 0;
  height: 0;
  border: 10px solid transparent;
}

.guide-arrow.top {
  top: -20px;
  left: 50%;
  transform: translateX(-50%);
  border-bottom-color: var(--el-bg-color);
}

.guide-arrow.bottom {
  bottom: -20px;
  left: 50%;
  transform: translateX(-50%);
  border-top-color: var(--el-bg-color);
}

.guide-arrow.left {
  left: -20px;
  top: 50%;
  transform: translateY(-50%);
  border-right-color: var(--el-bg-color);
}

.guide-arrow.right {
  right: -20px;
  top: 50%;
  transform: translateY(-50%);
  border-left-color: var(--el-bg-color);
}

.guide-trigger {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 1000;
  background: var(--el-color-primary) !important;
  border-color: var(--el-color-primary) !important;
  color: white !important;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
  animation: pulse 2s infinite;
}

.guide-trigger:hover {
  transform: scale(1.1);
}

.completion-content {
  text-align: center;
  padding: 20px 0;
}

.completion-icon {
  font-size: 64px;
  color: var(--el-color-success);
  margin-bottom: 20px;
}

.completion-content h3 {
  margin: 0 0 16px 0;
  color: var(--el-text-color-primary);
}

.completion-content p {
  margin: 0 0 20px 0;
  color: var(--el-text-color-regular);
  line-height: 1.6;
}

.completion-tips {
  text-align: left;
  background: var(--el-fill-color-lighter);
  padding: 16px;
  border-radius: 8px;
  margin-top: 20px;
}

.completion-tips h4 {
  margin: 0 0 12px 0;
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.completion-tips ul {
  margin: 0;
  padding-left: 20px;
}

.completion-tips li {
  margin-bottom: 8px;
  color: var(--el-text-color-regular);
  font-size: 13px;
  line-height: 1.5;
}

kbd {
  display: inline-block;
  padding: 2px 6px;
  font-size: 11px;
  line-height: 1;
  color: var(--el-text-color-regular);
  background: var(--el-fill-color);
  border: 1px solid var(--el-border-color);
  border-radius: 3px;
  font-family: monospace;
}

/* 动画效果 */
@keyframes fadeInScale {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

@keyframes pulse {
  0% {
    transform: scale(1);
    box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
  }
  50% {
    transform: scale(1.05);
    box-shadow: 0 6px 16px rgba(64, 158, 255, 0.4);
  }
  100% {
    transform: scale(1);
    box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .guide-content {
    min-width: 280px;
    max-width: 90vw;
  }
  
  .guide-body {
    padding: 16px;
  }
  
  .guide-title {
    font-size: 16px;
  }
  
  .guide-trigger {
    bottom: 80px;
    right: 16px;
  }
}

/* 深色模式适配 */
[data-theme="dark"] .guide-content {
  background: var(--el-bg-color);
  border-color: var(--el-border-color);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
}

[data-theme="dark"] .guide-arrow.top {
  border-bottom-color: var(--el-bg-color);
}

[data-theme="dark"] .guide-arrow.bottom {
  border-top-color: var(--el-bg-color);
}

[data-theme="dark"] .guide-arrow.left {
  border-right-color: var(--el-bg-color);
}

[data-theme="dark"] .guide-arrow.right {
  border-left-color: var(--el-bg-color);
}
</style>