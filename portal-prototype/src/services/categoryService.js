// 分类管理服务
import { mockTickets } from '@/data/mockData'

// 本地存储键名
const STORAGE_KEY = 'ticket_categories'

// 默认分类数据
const defaultCategories = [
  {
    id: 'cat-001',
    name: '硬件故障',
    level: 1,
    parentId: null,
    status: 'enabled',
    sort: 1,
    description: '服务器、网络设备等硬件相关故障',
    ticketCount: 0,
    createdAt: '2024-01-01 10:00:00',
    updatedAt: '2024-01-01 10:00:00',
    children: [
      {
        id: 'cat-001-001',
        name: '服务器故障',
        level: 2,
        parentId: 'cat-001',
        status: 'enabled',
        sort: 1,
        description: '服务器硬件故障',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-001-002',
        name: 'CPU故障',
        level: 2,
        parentId: 'cat-001',
        status: 'enabled',
        sort: 2,
        description: 'CPU相关故障',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-001-003',
        name: '内存故障',
        level: 2,
        parentId: 'cat-001',
        status: 'enabled',
        sort: 3,
        description: '内存相关故障',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-001-004',
        name: '硬盘故障',
        level: 2,
        parentId: 'cat-001',
        status: 'enabled',
        sort: 4,
        description: '硬盘相关故障',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-001-005',
        name: '网卡故障',
        level: 2,
        parentId: 'cat-001',
        status: 'enabled',
        sort: 5,
        description: '网卡相关故障',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-001-006',
        name: '电源故障',
        level: 2,
        parentId: 'cat-001',
        status: 'enabled',
        sort: 6,
        description: '电源相关故障',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      }
    ]
  },
  {
    id: 'cat-002',
    name: '软件问题',
    level: 1,
    parentId: null,
    status: 'enabled',
    sort: 2,
    description: '操作系统、应用软件相关问题',
    ticketCount: 0,
    createdAt: '2024-01-01 10:00:00',
    updatedAt: '2024-01-01 10:00:00',
    children: [
      {
        id: 'cat-002-001',
        name: '系统崩溃',
        level: 2,
        parentId: 'cat-002',
        status: 'enabled',
        sort: 1,
        description: '操作系统崩溃问题',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-002-002',
        name: '应用异常',
        level: 2,
        parentId: 'cat-002',
        status: 'enabled',
        sort: 2,
        description: '应用程序异常',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-002-003',
        name: '服务停止',
        level: 2,
        parentId: 'cat-002',
        status: 'enabled',
        sort: 3,
        description: '系统服务停止',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-002-004',
        name: '配置错误',
        level: 2,
        parentId: 'cat-002',
        status: 'enabled',
        sort: 4,
        description: '软件配置错误',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-002-005',
        name: '版本冲突',
        level: 2,
        parentId: 'cat-002',
        status: 'enabled',
        sort: 5,
        description: '软件版本冲突',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-002-006',
        name: '权限问题',
        level: 2,
        parentId: 'cat-002',
        status: 'enabled',
        sort: 6,
        description: '软件权限问题',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      }
    ]
  },
  {
    id: 'cat-003',
    name: '网络问题',
    level: 1,
    parentId: null,
    status: 'enabled',
    sort: 3,
    description: '网络连接、配置相关问题',
    ticketCount: 0,
    createdAt: '2024-01-01 10:00:00',
    updatedAt: '2024-01-01 10:00:00',
    children: [
      {
        id: 'cat-003-001',
        name: '网络中断',
        level: 2,
        parentId: 'cat-003',
        status: 'enabled',
        sort: 1,
        description: '网络连接中断',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-003-002',
        name: '网速缓慢',
        level: 2,
        parentId: 'cat-003',
        status: 'enabled',
        sort: 2,
        description: '网络速度缓慢',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-003-003',
        name: 'DNS解析',
        level: 2,
        parentId: 'cat-003',
        status: 'enabled',
        sort: 3,
        description: 'DNS解析问题',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-003-004',
        name: '路由问题',
        level: 2,
        parentId: 'cat-003',
        status: 'enabled',
        sort: 4,
        description: '网络路由问题',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-003-005',
        name: '交换机故障',
        level: 2,
        parentId: 'cat-003',
        status: 'enabled',
        sort: 5,
        description: '交换机设备故障',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-003-006',
        name: '防火墙问题',
        level: 2,
        parentId: 'cat-003',
        status: 'enabled',
        sort: 6,
        description: '防火墙配置问题',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      }
    ]
  },
  {
    id: 'cat-004',
    name: '系统维护',
    level: 1,
    parentId: null,
    status: 'enabled',
    sort: 4,
    description: '系统升级、维护相关工作',
    ticketCount: 0,
    createdAt: '2024-01-01 10:00:00',
    updatedAt: '2024-01-01 10:00:00',
    children: [
      {
        id: 'cat-004-001',
        name: '系统升级',
        level: 2,
        parentId: 'cat-004',
        status: 'enabled',
        sort: 1,
        description: '系统版本升级',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-004-002',
        name: '补丁安装',
        level: 2,
        parentId: 'cat-004',
        status: 'enabled',
        sort: 2,
        description: '系统补丁安装',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-004-003',
        name: '配置变更',
        level: 2,
        parentId: 'cat-004',
        status: 'enabled',
        sort: 3,
        description: '系统配置变更',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-004-004',
        name: '数据备份',
        level: 2,
        parentId: 'cat-004',
        status: 'enabled',
        sort: 4,
        description: '数据备份操作',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-004-005',
        name: '性能优化',
        level: 2,
        parentId: 'cat-004',
        status: 'enabled',
        sort: 5,
        description: '系统性能优化',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-004-006',
        name: '安全加固',
        level: 2,
        parentId: 'cat-004',
        status: 'enabled',
        sort: 6,
        description: '系统安全加固',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      }
    ]
  },
  {
    id: 'cat-005',
    name: '安全事件',
    level: 1,
    parentId: null,
    status: 'enabled',
    sort: 5,
    description: '安全相关事件和问题',
    ticketCount: 0,
    createdAt: '2024-01-01 10:00:00',
    updatedAt: '2024-01-01 10:00:00',
    children: [
      {
        id: 'cat-005-001',
        name: '病毒感染',
        level: 2,
        parentId: 'cat-005',
        status: 'enabled',
        sort: 1,
        description: '病毒感染事件',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-005-002',
        name: '恶意攻击',
        level: 2,
        parentId: 'cat-005',
        status: 'enabled',
        sort: 2,
        description: '恶意攻击事件',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-005-003',
        name: '数据泄露',
        level: 2,
        parentId: 'cat-005',
        status: 'enabled',
        sort: 3,
        description: '数据泄露事件',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-005-004',
        name: '权限滥用',
        level: 2,
        parentId: 'cat-005',
        status: 'enabled',
        sort: 4,
        description: '权限滥用事件',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-005-005',
        name: '安全漏洞',
        level: 2,
        parentId: 'cat-005',
        status: 'enabled',
        sort: 5,
        description: '安全漏洞发现',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-005-006',
        name: '异常访问',
        level: 2,
        parentId: 'cat-005',
        status: 'enabled',
        sort: 6,
        description: '异常访问行为',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      }
    ]
  },
  {
    id: 'cat-006',
    name: '数据库问题',
    level: 1,
    parentId: null,
    status: 'enabled',
    sort: 6,
    description: '数据库相关问题',
    ticketCount: 0,
    createdAt: '2024-01-01 10:00:00',
    updatedAt: '2024-01-01 10:00:00',
    children: [
      {
        id: 'cat-006-001',
        name: '连接超时',
        level: 2,
        parentId: 'cat-006',
        status: 'enabled',
        sort: 1,
        description: '数据库连接超时',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-006-002',
        name: '查询缓慢',
        level: 2,
        parentId: 'cat-006',
        status: 'enabled',
        sort: 2,
        description: '数据库查询缓慢',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-006-003',
        name: '数据丢失',
        level: 2,
        parentId: 'cat-006',
        status: 'enabled',
        sort: 3,
        description: '数据丢失问题',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-006-004',
        name: '备份失败',
        level: 2,
        parentId: 'cat-006',
        status: 'enabled',
        sort: 4,
        description: '数据库备份失败',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-006-005',
        name: '同步异常',
        level: 2,
        parentId: 'cat-006',
        status: 'enabled',
        sort: 5,
        description: '数据库同步异常',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      },
      {
        id: 'cat-006-006',
        name: '锁表问题',
        level: 2,
        parentId: 'cat-006',
        status: 'enabled',
        sort: 6,
        description: '数据库锁表问题',
        ticketCount: 0,
        createdAt: '2024-01-01 10:00:00',
        updatedAt: '2024-01-01 10:00:00'
      }
    ]
  }
]

// 工具函数
const generateId = () => {
  return 'cat-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9)
}

const getCurrentTime = () => {
  return new Date().toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

// 本地存储操作
const saveToStorage = (categories) => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(categories))
}

const loadFromStorage = () => {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored) {
    try {
      return JSON.parse(stored)
    } catch (error) {
      console.error('解析分类数据失败:', error)
    }
  }
  return null
}

// 初始化数据
const initializeCategories = () => {
  const stored = loadFromStorage()
  if (!stored) {
    // 计算工单数量
    const categoriesWithCount = calculateTicketCounts(defaultCategories)
    saveToStorage(categoriesWithCount)
    return categoriesWithCount
  }
  return stored
}

// 计算工单数量
const calculateTicketCounts = (categories) => {
  const flatCategories = flattenCategories(categories)

  return categories.map(category => {
    const ticketCount = mockTickets.filter(ticket =>
      ticket.category === category.name
    ).length

    const children = category.children ? category.children.map(child => {
      const childTicketCount = mockTickets.filter(ticket =>
        ticket.category === category.name && ticket.subcategory === child.name
      ).length

      return {
        ...child,
        ticketCount: childTicketCount
      }
    }) : []

    return {
      ...category,
      ticketCount,
      children
    }
  })
}

// 扁平化分类数据
const flattenCategories = (categories) => {
  const result = []

  categories.forEach(category => {
    result.push(category)
    if (category.children) {
      result.push(...category.children)
    }
  })

  return result
}

// 验证分类名称唯一性
const validateCategoryName = (name, excludeId = null, parentId = null) => {
  const categories = loadFromStorage() || defaultCategories
  const flatCategories = flattenCategories(categories)

  return !flatCategories.some(category =>
    category.name === name &&
    category.id !== excludeId &&
    category.parentId === parentId
  )
}

// 分类服务对象
export const categoryService = {
  // 获取所有分类
  async getCategories() {
    return new Promise((resolve) => {
      setTimeout(() => {
        const categories = initializeCategories()
        resolve(categories)
      }, 300)
    })
  },

  // 获取扁平化分类列表
  async getFlatCategories() {
    const categories = await this.getCategories()
    return flattenCategories(categories)
  },

  // 获取一级分类
  async getParentCategories() {
    const categories = await this.getCategories()
    return categories.filter(category => category.level === 1 && category.status === 'enabled')
  },

  // 根据父分类获取子分类
  async getSubCategories(parentId) {
    const categories = await this.getCategories()
    const parent = categories.find(category => category.id === parentId)
    return parent ? parent.children || [] : []
  },

  // 创建分类
  async createCategory(categoryData) {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        try {
          // 验证名称唯一性
          if (!validateCategoryName(categoryData.name, null, categoryData.parentId)) {
            reject(new Error('分类名称已存在'))
            return
          }

          const categories = loadFromStorage() || defaultCategories
          const newCategory = {
            id: generateId(),
            ...categoryData,
            ticketCount: 0,
            createdAt: getCurrentTime(),
            updatedAt: getCurrentTime()
          }

          if (categoryData.level === 1) {
            // 一级分类
            newCategory.children = []
            categories.push(newCategory)
          } else {
            // 二级分类
            const parentIndex = categories.findIndex(cat => cat.id === categoryData.parentId)
            if (parentIndex === -1) {
              reject(new Error('父分类不存在'))
              return
            }

            if (!categories[parentIndex].children) {
              categories[parentIndex].children = []
            }
            categories[parentIndex].children.push(newCategory)
          }

          saveToStorage(categories)
          resolve(newCategory)
        } catch (error) {
          reject(error)
        }
      }, 500)
    })
  },

  // 更新分类
  async updateCategory(id, categoryData) {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        try {
          // 验证名称唯一性
          if (!validateCategoryName(categoryData.name, id, categoryData.parentId)) {
            reject(new Error('分类名称已存在'))
            return
          }

          const categories = loadFromStorage() || defaultCategories
          let updated = false

          // 查找并更新分类
          for (let i = 0; i < categories.length; i++) {
            if (categories[i].id === id) {
              categories[i] = {
                ...categories[i],
                ...categoryData,
                updatedAt: getCurrentTime()
              }
              updated = true
              break
            }

            if (categories[i].children) {
              for (let j = 0; j < categories[i].children.length; j++) {
                if (categories[i].children[j].id === id) {
                  categories[i].children[j] = {
                    ...categories[i].children[j],
                    ...categoryData,
                    updatedAt: getCurrentTime()
                  }
                  updated = true
                  break
                }
              }
            }

            if (updated) break
          }

          if (!updated) {
            reject(new Error('分类不存在'))
            return
          }

          saveToStorage(categories)
          resolve(true)
        } catch (error) {
          reject(error)
        }
      }, 500)
    })
  },

  // 删除分类
  async deleteCategory(id) {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        try {
          const categories = loadFromStorage() || defaultCategories
          let deleted = false

          // 查找并删除分类
          for (let i = 0; i < categories.length; i++) {
            if (categories[i].id === id) {
              // 检查是否有子分类
              if (categories[i].children && categories[i].children.length > 0) {
                reject(new Error('该分类下有子分类，无法删除'))
                return
              }

              // 检查是否有工单
              if (categories[i].ticketCount > 0) {
                reject(new Error('该分类下有工单，无法删除'))
                return
              }

              categories.splice(i, 1)
              deleted = true
              break
            }

            if (categories[i].children) {
              for (let j = 0; j < categories[i].children.length; j++) {
                if (categories[i].children[j].id === id) {
                  // 检查是否有工单
                  if (categories[i].children[j].ticketCount > 0) {
                    reject(new Error('该分类下有工单，无法删除'))
                    return
                  }

                  categories[i].children.splice(j, 1)
                  deleted = true
                  break
                }
              }
            }

            if (deleted) break
          }

          if (!deleted) {
            reject(new Error('分类不存在'))
            return
          }

          saveToStorage(categories)
          resolve(true)
        } catch (error) {
          reject(error)
        }
      }, 500)
    })
  },

  // 更新工单数量统计
  async updateTicketCounts() {
    const categories = loadFromStorage() || defaultCategories
    const updatedCategories = calculateTicketCounts(categories)
    saveToStorage(updatedCategories)
    return updatedCategories
  },

  // 重置为默认分类
  async resetToDefault() {
    const categoriesWithCount = calculateTicketCounts(defaultCategories)
    saveToStorage(categoriesWithCount)
    return categoriesWithCount
  }
}
