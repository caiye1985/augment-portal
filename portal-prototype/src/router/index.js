import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  // 登录页面
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginPage.vue'),
    meta: { title: '登录', hideInMenu: true }
  },

  // 个人设置页面
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/views/ProfilePage.vue'),
    meta: { title: '个人设置', hideInMenu: true }
  },

  // 主题演示页面
  {
    path: '/theme-demo',
    name: 'ThemeDemo',
    component: () => import('@/views/ThemeDemo.vue'),
    meta: { title: '主题演示', hideInMenu: true }
  },

  // IframeContainer组件测试页面
  {
    path: '/iframe-test',
    name: 'IframeTest',
    component: () => import('@/views/IframeTest.vue'),
    meta: { title: 'Iframe测试', hideInMenu: true }
  },

  {
    path: '/',
    redirect: '/workspace'
  },
  {
    path: '/',
    component: () => import('@/layouts/DemoLayout.vue'),
    children: [
      // 工作台 - 新增一级菜单
      {
        path: 'workspace',
        name: 'Workspace',
        redirect: '/workspace/dashboard',
        meta: {
          title: '工作台',
          icon: 'Monitor',
          topMenu: true
        },
        children: [
          // 概览中心
          {
            path: 'dashboard',
            name: 'Dashboard',
            component: () => import('@/views/Dashboard.vue'),
            meta: { title: '运维仪表板', icon: 'Monitor', parent: 'Overview' }
          },
          {
            path: 'tasks',
            name: 'MyTasks',
            component: () => import('@/views/MyTasks.vue'),
            meta: { title: '我的任务', icon: 'List', parent: 'Workspace' }
          },
          {
            path: 'messages',
            name: 'MyMessages',
            component: () => import('@/views/MyMessages.vue'),
            meta: { title: '我的消息', icon: 'ChatDotRound', parent: 'Workspace' }
          },
          {
            path: 'ui-demo',
            name: 'UIDemo',
            component: () => import('@/views/UIDemo.vue'),
            meta: { title: 'UI结构演示', icon: 'Cpu', parent: 'Workspace' }
          }
        ]
      },
      // 工单服务
      {
        path: 'tickets',
        name: 'TicketService',
        redirect: '/tickets/management',
        meta: {
          title: '工单服务',
          icon: 'Tickets',
          topMenu: true
        },
        children: [
          {
            path: 'management',
            name: 'TicketManagement',
            component: () => import('@/views/TicketDemo.vue'),
            meta: { title: '工单管理', icon: 'Tickets', parent: 'TicketService' }
          },
          {
            path: 'dispatch',
            name: 'TicketDispatch',
            component: () => import('@/views/DispatchDemo.vue'),
            meta: { title: '智能派单', icon: 'Connection', parent: 'TicketService' }
          },
          {
            path: 'knowledge',
            name: 'Knowledge',
            component: () => import('@/views/KnowledgeDemo.vue'),
            meta: { title: '知识库', icon: 'Document', parent: 'TicketService' }
          },
          {
            path: 'categories',
            name: 'CategoryManagement',
            component: () => import('@/views/CategoryManagement.vue'),
            meta: { title: '分类管理', icon: 'Menu', parent: 'TicketService' }
          }
        ]
      },

      // 运维管理
      {
        path: 'operations',
        name: 'Operations',
        redirect: '/operations/assets',
        meta: {
          title: '运维管理',
          icon: 'Setting',
          topMenu: true
        },
        children: [
          {
            path: 'assets',
            name: 'AssetManagement',
            component: () => import('@/views/AssetManagement.vue'),
            meta: { title: '资产管理', icon: 'Box', parent: 'Operations' }
          },
          {
            path: 'monitoring',
            name: 'MonitoringSystem',
            component: () => import('@/views/MonitoringSystem.vue'),
            meta: { title: '监控系统', icon: 'Monitor', parent: 'Operations' }
          },
          {
            path: 'automation',
            name: 'AutomationPlatform',
            component: () => import('@/views/AutomationPlatform.vue'),
            meta: { title: '自动化平台', icon: 'Setting', parent: 'Operations' }
          },
          {
            path: 'integration',
            name: 'Integration',
            component: () => import('@/views/IntegrationDemo.vue'),
            meta: { title: '任务日志', icon: 'Document', parent: 'Operations' }
          }
        ]
      },

      // 智能分析
      {
        path: 'ai',
        name: 'AI',
        redirect: '/ai/analysis',
        meta: {
          title: '智能分析',
          icon: 'ChatDotRound',
          topMenu: true
        },
        children: [
          {
            path: 'analysis',
            name: 'AIAnalysis',
            component: () => import('@/views/AIAnalysisDemo.vue'),
            meta: { title: 'AI智能分析', icon: 'ChatDotRound', parent: 'AI' }
          }
        ]
      },
      // 甲方服务
      {
        path: 'client',
        name: 'Client',
        redirect: '/client/management',
        meta: {
          title: '甲方服务',
          icon: 'UserFilled',
          topMenu: true
        },
        children: [
          {
            path: 'management',
            name: 'ClientManagement',
            component: () => import('@/views/ClientManagementDemo.vue'),
            meta: { title: '甲方管理', icon: 'OfficeBuilding', parent: 'Client' }
          }
        ]
      },

      // 人员管理 - 新增一级菜单
      {
        path: 'personnel',
        name: 'Personnel',
        redirect: '/personnel/engineers',
        meta: {
          title: '人员管理',
          icon: 'UserFilled',
          topMenu: true
        },
        children: [
          {
            path: 'engineers',
            name: 'PersonnelEngineers',
            component: () => import('@/views/EngineerManagementDemo.vue'),
            meta: { title: '工程师管理', icon: 'Avatar', parent: 'Personnel' }
          },
          {
            path: 'engineer-profile/:engineerId',
            name: 'PersonnelEngineerProfile',
            component: () => import('@/views/EngineerProfile.vue'),
            meta: { title: '工程师档案', icon: 'UserFilled', parent: 'Personnel', hidden: true }
          },
          {
            path: 'engineer-sites',
            name: 'PersonnelEngineerSites',
            component: () => import('@/views/EngineerSiteManagement.vue'),
            meta: { title: '工程师站点管理', icon: 'Connection', parent: 'Personnel' }
          },
          {
            path: 'engineer-sites-demo',
            name: 'PersonnelEngineerSitesDemo',
            component: () => import('@/views/EngineerSiteManagementDemo.vue'),
            meta: { title: '站点管理演示', icon: 'View', parent: 'Personnel', hidden: true }
          },
          {
            path: 'skills',
            name: 'SkillManagement',
            component: () => import('@/views/SkillManagement.vue'),
            meta: { title: '技能管理', icon: 'Medal', parent: 'Personnel' }
          },
          {
            path: 'training',
            name: 'PersonnelTraining',
            component: () => import('@/views/TrainingManagement.vue'),
            meta: { title: '培训管理', icon: 'Reading', parent: 'Personnel' }
          },
          {
            path: 'schedule',
            name: 'PersonnelSchedule',
            component: () => import('@/views/ScheduleManagement.vue'),
            meta: { title: '排班管理', icon: 'Calendar', parent: 'Personnel' }
          },
          {
            path: 'performance',
            name: 'Performance',
            component: () => import('@/views/PerformanceDemo.vue'),
            meta: { title: '绩效管理', icon: 'TrendCharts', parent: 'Operations' }
          }
        ]
      },


      // 系统管理 - 精简后的系统管理
      {
        path: 'system',
        name: 'System',
        redirect: '/system/tenants',
        meta: {
          title: '系统管理',
          icon: 'Tools',
          topMenu: true
        },
        children: [
          {
            path: 'tenants',
            name: 'Tenants',
            component: () => import('@/views/TenantManagementDemo.vue'),
            meta: { title: '租户管理', icon: 'OfficeBuilding', parent: 'System' }
          },
          // 站点总览 - 独立主导航菜单
          {
            path: 'sites',
            name: 'SiteOverview',
            component: () => import('@/views/SiteOverview.vue'),
            meta: {
              title: '站点总览',
              icon: 'OfficeBuilding',parent: 'System'
            }
          },
          {
            path: 'departments',
            name: 'Departments',
            component: () => import('@/views/DepartmentManagementDemo.vue'),
            meta: { title: '部门管理', icon: 'Coordinate', parent: 'System' }
          },
          {
            path: 'users',
            name: 'Users',
            component: () => import('@/views/UserManagement.vue'),
            meta: { title: '用户管理', icon: 'User', parent: 'System' }
          },
          {
            path: 'exam-management',
            name: 'ExamManagement',
            component: () => import('@/views/ExamManagement.vue'),
            meta: { title: '考核管理', icon: 'Document', parent: 'System' }
          },
          {
            path: 'workflow',
            name: 'WorkspaceWorkflow',
            component: () => import('@/views/WorkflowDemo.vue'),
            meta: { title: '工作流', icon: 'Share', parent: 'Workspace' }
          },
          {
            path: 'notifications',
            name: 'WorkspaceNotifications',
            component: () => import('@/views/NotificationDemo.vue'),
            meta: { title: '通知系统', icon: 'Bell', parent: 'Workspace' }
          },
          {
            path: 'system-config',
            name: 'SystemConfig',
            component: () => import('@/views/SystemConfig.vue'),
            meta: { title: '系统配置', icon: 'Setting', parent: 'System' }
          },
          {
            path: 'user-manual',
            name: 'UserManual',
            component: () => import('@/views/UserManual.vue'),
            meta: { title: '用户手册', icon: 'Document', parent: 'System' }
          }
        ]
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // 检查是否需要认证
  const requiresAuth = !to.meta?.hideInMenu && to.path !== '/login'

  // 开发模式：直接允许访问（绕过认证检查）
  const DEV_BYPASS_AUTH = true

  if (DEV_BYPASS_AUTH) {
    // 开发模式下直接放行，同时设置认证状态
    if (requiresAuth) {
      // 确保localStorage中有认证信息
      if (!localStorage.getItem('token')) {
        localStorage.setItem('token', 'dev-auto-login-token')
        localStorage.setItem('currentTenant', '1')
        localStorage.setItem('user', JSON.stringify({
          id: '1',
          username: 'admin',
          name: '系统管理员',
          email: 'admin@system.com',
          role: 'system_admin'
        }))
      }
    }
    next()
    return
  }

  // 原始认证逻辑（开发模式下不会执行）
  const token = localStorage.getItem('token')
  const isLoggedIn = !!token

  if (requiresAuth && !isLoggedIn) {
    next('/login')
  } else if (to.path === '/login' && isLoggedIn) {
    next('/')
  } else {
    next()
  }
})

export default router