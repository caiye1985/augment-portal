import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  // 状态
  const user = ref(null)
  const token = ref(localStorage.getItem('token') || null)
  const currentTenant = ref(localStorage.getItem('currentTenant') || null)
  const availableTenants = ref([])

  // 开发模式：自动登录绕过验证
  const DEV_AUTO_LOGIN = true // 设置为true来绕过登录验证

  // 用户角色定义
  const USER_ROLES = {
    SYSTEM_ADMIN: 'system_admin',      // 系统管理员 - 可以查看所有租户
    TENANT_ADMIN: 'tenant_admin',      // 租户管理员 - 只能查看自己的租户
    CLIENT_USER: 'client_user',        // 甲方用户 - 只能查看自己的租户
    ENGINEER: 'engineer'               // 运维工程师 - 可以查看负责的租户
  }

  // 模拟用户数据
  const mockUsers = [
    {
      id: '1',
      username: 'admin',
      name: '系统管理员',
      email: 'admin@system.com',
      role: USER_ROLES.SYSTEM_ADMIN,
      avatar: '',
      // 系统管理员可以访问所有租户
      accessibleTenants: ['1', '2', '3']
    },
    {
      id: '2',
      username: 'alibaba_admin',
      name: '阿里巴巴管理员',
      email: 'admin@alibaba.com',
      role: USER_ROLES.TENANT_ADMIN,
      avatar: '',
      // 租户管理员只能访问自己的租户
      accessibleTenants: ['1']
    },
    {
      id: '3',
      username: 'client_user',
      name: '甲方用户',
      email: 'user@client.com',
      role: USER_ROLES.CLIENT_USER,
      avatar: '',
      // 甲方用户只能访问自己的租户
      accessibleTenants: ['2']
    },
    {
      id: '4',
      username: 'engineer1',
      name: '张工程师',
      email: 'zhang@engineer.com',
      role: USER_ROLES.ENGINEER,
      avatar: '',
      // 运维工程师可以访问负责的租户
      accessibleTenants: ['1', '2']
    },
    {
      id: '5',
      username: 'engineer2',
      name: '李工程师',
      email: 'li@engineer.com',
      role: USER_ROLES.ENGINEER,
      avatar: '',
      // 运维工程师可以访问负责的租户
      accessibleTenants: ['2', '3']
    }
  ]

  // 租户数据
  const tenants = ref([
    { id: '1', name: '阿里巴巴集团', code: 'ALIBABA' },
    { id: '2', name: '腾讯科技', code: 'TENCENT' },
    { id: '3', name: '字节跳动', code: 'BYTEDANCE' }
  ])

  // 计算属性
  const isLoggedIn = computed(() => {
    // 开发模式：自动登录
    if (DEV_AUTO_LOGIN) {
      // 如果没有用户信息，自动设置默认用户
      if (!user.value) {
        autoLogin()
      }
      return true
    }
    return !!token.value && !!user.value
  })

  const userRole = computed(() => user.value?.role)

  const isSystemAdmin = computed(() => userRole.value === USER_ROLES.SYSTEM_ADMIN)

  const isTenantAdmin = computed(() => userRole.value === USER_ROLES.TENANT_ADMIN)

  const isClientUser = computed(() => userRole.value === USER_ROLES.CLIENT_USER)

  const isEngineer = computed(() => userRole.value === USER_ROLES.ENGINEER)

  // 获取用户可访问的租户列表
  const getUserAccessibleTenants = computed(() => {
    if (!user.value) return []

    return tenants.value.filter(tenant =>
      user.value.accessibleTenants.includes(tenant.id)
    )
  })

  // 检查用户是否可以访问指定租户
  const canAccessTenant = (tenantId) => {
    if (!user.value) return false
    return user.value.accessibleTenants.includes(tenantId)
  }

  // 获取当前租户信息
  const getCurrentTenant = computed(() => {
    if (!currentTenant.value) return null
    return tenants.value.find(t => t.id === currentTenant.value)
  })

  // Actions
  // 开发模式自动登录函数
  const autoLogin = () => {
    if (!DEV_AUTO_LOGIN) return

    // 使用admin@system.com用户自动登录
    const defaultUser = mockUsers.find(u => u.email === 'admin@system.com')
    if (defaultUser) {
      user.value = defaultUser
      token.value = 'dev-auto-login-token-' + defaultUser.id
      currentTenant.value = '1' // ALIBABA租户
      availableTenants.value = getUserAccessibleTenants.value

      // 保存到localStorage
      localStorage.setItem('token', token.value)
      localStorage.setItem('currentTenant', currentTenant.value)
      localStorage.setItem('user', JSON.stringify(user.value))

      console.log('🔑 开发模式自动登录成功:', defaultUser.name)
    }
  }

  const login = async (credentials) => {
    try {
      // 模拟登录API调用
      const { username, password, tenantId } = credentials

      // 查找用户
      const foundUser = mockUsers.find(u => u.username === username)
      if (!foundUser || password !== 'password') {
        throw new Error('用户名或密码错误')
      }

      // 检查用户是否可以访问指定租户
      if (tenantId && !foundUser.accessibleTenants.includes(tenantId)) {
        throw new Error('您没有权限访问该租户')
      }

      // 设置用户信息
      user.value = foundUser
      token.value = 'mock-jwt-token-' + foundUser.id

      // 设置当前租户
      if (tenantId) {
        currentTenant.value = tenantId
      } else {
        // 如果没有指定租户，使用用户可访问的第一个租户
        currentTenant.value = foundUser.accessibleTenants[0]
      }

      // 设置可访问的租户列表
      availableTenants.value = getUserAccessibleTenants.value

      // 保存到localStorage
      localStorage.setItem('token', token.value)
      localStorage.setItem('currentTenant', currentTenant.value)
      localStorage.setItem('user', JSON.stringify(user.value))

      return { success: true, user: user.value }
    } catch (error) {
      throw new Error(error.message)
    }
  }

  const logout = () => {
    user.value = null
    token.value = null
    currentTenant.value = null
    availableTenants.value = []

    localStorage.removeItem('token')
    localStorage.removeItem('currentTenant')
    localStorage.removeItem('user')
  }

  const switchTenant = async (tenantId) => {
    if (!user.value) {
      throw new Error('用户未登录')
    }

    if (!canAccessTenant(tenantId)) {
      throw new Error('您没有权限访问该租户')
    }

    currentTenant.value = tenantId
    localStorage.setItem('currentTenant', tenantId)

    return { success: true, tenant: getCurrentTenant.value }
  }

  const switchRole = async (newRole) => {
    // 模拟角色切换（实际应用中需要后端验证）
    if (!user.value) {
      throw new Error('用户未登录')
    }

    // 检查用户是否有权限切换到指定角色
    const allowedRoles = getAllowedRoles()
    if (!allowedRoles.includes(newRole)) {
      throw new Error('您没有权限切换到该角色')
    }

    user.value.role = newRole
    localStorage.setItem('user', JSON.stringify(user.value))

    return { success: true, role: newRole }
  }

  const getAllowedRoles = () => {
    if (!user.value) return []

    // 根据用户的基础角色返回可切换的角色列表
    switch (user.value.role) {
      case USER_ROLES.SYSTEM_ADMIN:
        return [USER_ROLES.SYSTEM_ADMIN, USER_ROLES.TENANT_ADMIN, USER_ROLES.ENGINEER]
      case USER_ROLES.TENANT_ADMIN:
        return [USER_ROLES.TENANT_ADMIN]
      case USER_ROLES.CLIENT_USER:
        return [USER_ROLES.CLIENT_USER]
      case USER_ROLES.ENGINEER:
        return [USER_ROLES.ENGINEER]
      default:
        return []
    }
  }

  // 初始化用户状态
  const initializeAuth = () => {
    const savedUser = localStorage.getItem('user')
    const savedToken = localStorage.getItem('token')
    const savedTenant = localStorage.getItem('currentTenant')

    if (savedUser && savedToken) {
      user.value = JSON.parse(savedUser)
      token.value = savedToken
      currentTenant.value = savedTenant
      availableTenants.value = getUserAccessibleTenants.value
    }
  }

  // 获取工程师负责的租户
  const getEngineerTenants = (engineerId) => {
    const engineer = mockUsers.find(u => u.id === engineerId && u.role === USER_ROLES.ENGINEER)
    if (!engineer) return []

    return tenants.value.filter(tenant =>
      engineer.accessibleTenants.includes(tenant.id)
    )
  }

  // 设置工程师负责的租户
  const setEngineerTenants = (engineerId, tenantIds) => {
    const engineer = mockUsers.find(u => u.id === engineerId && u.role === USER_ROLES.ENGINEER)
    if (engineer) {
      engineer.accessibleTenants = tenantIds
      // 如果是当前用户，更新状态
      if (user.value && user.value.id === engineerId) {
        user.value.accessibleTenants = tenantIds
        availableTenants.value = getUserAccessibleTenants.value
        localStorage.setItem('user', JSON.stringify(user.value))
      }
    }
  }

  return {
    // 状态
    user,
    token,
    currentTenant,
    availableTenants,
    tenants,
    USER_ROLES,

    // 计算属性
    isLoggedIn,
    userRole,
    isSystemAdmin,
    isTenantAdmin,
    isClientUser,
    isEngineer,
    getUserAccessibleTenants,
    getCurrentTenant,

    // 方法
    autoLogin,
    login,
    logout,
    switchTenant,
    switchRole,
    canAccessTenant,
    getAllowedRoles,
    initializeAuth,
    getEngineerTenants,
    setEngineerTenants
  }
})
