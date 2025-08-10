import { createApp } from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './styles/global.css'
import './styles/dark-mode-fix.css'
import { initDarkModeForcer } from './utils/darkModeForcer.js'

const app = createApp(App)
const pinia = createPinia()
// 注册Element Plus图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(ElementPlus, { locale: zhCn })
app.use(router)
app.use(pinia)

// 挂载应用
app.mount('#app')

// 初始化深色模式强制修复工具
initDarkModeForcer()