import dayjs from 'dayjs'

// 生成随机数据的工具函数
const random = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min
const randomFloat = (min, max) => (Math.random() * (max - min) + min).toFixed(2)

// 模拟用户数据
export const mockUsers = [
  { id: 1, name: '张工程师', role: '运维工程师', status: '在线', avatar: null },
  { id: 2, name: '李管理员', role: '系统管理员', status: '忙碌', avatar: null },
  { id: 3, name: '王客户', role: '甲方用户', status: '离线', avatar: null },
  { id: 4, name: '赵主管', role: '甲方主管', status: '在线', avatar: null }
]

// 分类和子分类映射
const categorySubcategoryMap = {
  '硬件故障': ['服务器故障', 'CPU故障', '内存故障', '硬盘故障', '网卡故障', '电源故障'],
  '软件问题': ['系统崩溃', '应用异常', '服务停止', '配置错误', '版本冲突', '权限问题'],
  '网络问题': ['网络中断', '网速缓慢', 'DNS解析', '路由问题', '交换机故障', '防火墙问题'],
  '系统维护': ['系统升级', '补丁安装', '配置变更', '数据备份', '性能优化', '安全加固'],
  '安全事件': ['病毒感染', '恶意攻击', '数据泄露', '权限滥用', '安全漏洞', '异常访问'],
  '数据库问题': ['连接超时', '查询缓慢', '数据丢失', '备份失败', '同步异常', '锁表问题']
}

// 模拟工单数据
export const mockTickets = Array.from({ length: 50 }, (_, i) => {
  const categories = Object.keys(categorySubcategoryMap)
  const selectedCategory = categories[random(0, categories.length - 1)]
  const subcategories = categorySubcategoryMap[selectedCategory]
  const selectedSubcategory = subcategories[random(0, subcategories.length - 1)]

  return {
    id: `T${String(i + 1).padStart(6, '0')}`,
    title: [
      '服务器CPU使用率过高',
      '网络连接异常',
      '数据库查询缓慢',
      '应用程序崩溃',
      '磁盘空间不足',
      '邮件服务器故障',
      '防火墙配置问题',
      '备份任务失败'
    ][i % 8],
    description: '详细描述问题现象和影响范围...',
    priority: ['低', '中', '高', '紧急'][random(0, 3)],
    status: ['待分配', '处理中', '待验收', '已完成', '已关闭'][random(0, 4)],
    category: selectedCategory,
    subcategory: selectedSubcategory,
    assignee: mockUsers[random(0, 3)].name,
    reporter: mockUsers[random(0, 3)].name,
    createdAt: dayjs().subtract(random(0, 30), 'day').format('YYYY-MM-DD HH:mm'),
    updatedAt: dayjs().subtract(random(0, 5), 'day').format('YYYY-MM-DD HH:mm'),
    sla: random(2, 48) + '小时',
    tags: ['紧急', '重要', '常规'][random(0, 2)]
  }
})

// 模拟知识库数据
export const mockKnowledge = Array.from({ length: 30 }, (_, i) => ({
  id: i + 1,
  title: [
    'Linux服务器性能优化指南',
    'MySQL数据库备份最佳实践',
    'Docker容器部署手册',
    'Nginx配置优化技巧',
    '网络故障排查流程',
    'Redis缓存使用指南',
    'Jenkins CI/CD配置',
    'Kubernetes集群管理'
  ][i % 8],
  summary: '这是一篇关于技术实践的详细文档，包含了完整的操作步骤和注意事项...',
  category: ['系统运维', '数据库', '网络安全', '开发工具'][random(0, 3)],
  author: mockUsers[random(0, 3)].name,
  views: random(100, 2000),
  likes: random(10, 200),
  createdAt: dayjs().subtract(random(0, 90), 'day').format('YYYY-MM-DD'),
  tags: ['Linux', 'MySQL', 'Docker', 'Nginx', 'Redis'][random(0, 4)],
  status: '已发布'
}))

// 模拟绩效数据
export const mockPerformance = {
  overview: {
    totalTickets: 1248,
    resolvedTickets: 1156,
    avgResolutionTime: '4.2小时',
    slaCompliance: '96.8%'
  },
  engineers: mockUsers.filter(u => u.role === '运维工程师').map(user => ({
    ...user,
    ticketsResolved: random(50, 200),
    avgResolutionTime: randomFloat(2, 8) + '小时',
    slaCompliance: randomFloat(85, 99) + '%',
    customerRating: randomFloat(4.0, 5.0)
  })),
  trends: Array.from({ length: 12 }, (_, i) => ({
    month: dayjs().subtract(11 - i, 'month').format('YYYY-MM'),
    tickets: random(80, 150),
    resolved: random(75, 145),
    sla: randomFloat(90, 99)
  }))
}

// 模拟租户类型数据
export const mockTenantTypes = [
  {
    id: 1,
    name: '企业版',
    description: '大型企业客户，提供完整的功能和高级支持',
    features: ['无限用户', '高级分析', '24/7支持', '自定义集成'],
    maxUsers: -1, // -1表示无限制
    maxSites: -1,
    price: 9999,
    color: 'primary'
  },
  {
    id: 2,
    name: '专业版',
    description: '中型企业客户，提供专业功能和标准支持',
    features: ['500用户', '标准分析', '工作时间支持', '标准集成'],
    maxUsers: 500,
    maxSites: 50,
    price: 4999,
    color: 'success'
  },
  {
    id: 3,
    name: '基础版',
    description: '小型企业客户，提供基础功能和社区支持',
    features: ['100用户', '基础分析', '社区支持', '基础集成'],
    maxUsers: 100,
    maxSites: 10,
    price: 1999,
    color: 'info'
  },
  {
    id: 4,
    name: '试用版',
    description: '试用客户，提供有限功能和基础支持',
    features: ['10用户', '基础功能', '邮件支持'],
    maxUsers: 10,
    maxSites: 3,
    price: 0,
    color: 'warning'
  }
]

// 模拟租户数据
export const mockTenants = [
  {
    id: 'tenant-001',
    name: '北京科技有限公司',
    code: 'BJKJ',
    type: '企业版',
    status: 'active',
    contactPerson: '张经理',
    contactPhone: '13800138001',
    contactEmail: 'zhang@bjkj.com',
    address: '北京市海淀区中关村大街1号',
    region: '华北',
    createdAt: dayjs().subtract(180, 'day').format('YYYY-MM-DD'),
    siteCount: 8,
    engineerCount: 12
  },
  {
    id: 'tenant-002',
    name: '上海智能科技集团',
    code: 'SHZN',
    type: '企业版',
    status: 'active',
    contactPerson: '李总监',
    contactPhone: '13800138002',
    contactEmail: 'li@shzn.com',
    address: '上海市浦东新区陆家嘴金融中心',
    region: '华东',
    createdAt: dayjs().subtract(150, 'day').format('YYYY-MM-DD'),
    siteCount: 12,
    engineerCount: 18
  },
  {
    id: 'tenant-003',
    name: '深圳创新企业',
    code: 'SZCX',
    type: '专业版',
    status: 'active',
    contactPerson: '王主管',
    contactPhone: '13800138003',
    contactEmail: 'wang@szcx.com',
    address: '深圳市南山区科技园',
    region: '华南',
    createdAt: dayjs().subtract(120, 'day').format('YYYY-MM-DD'),
    siteCount: 6,
    engineerCount: 9
  },
  {
    id: 'tenant-004',
    name: '成都软件公司',
    code: 'CDRJ',
    type: '基础版',
    status: 'inactive',
    contactPerson: '赵经理',
    contactPhone: '13800138004',
    contactEmail: 'zhao@cdrj.com',
    address: '成都市高新区天府大道',
    region: '西南',
    createdAt: dayjs().subtract(90, 'day').format('YYYY-MM-DD'),
    siteCount: 4,
    engineerCount: 6
  }
]

// 模拟站点数据
export const mockSites = [
  // 北京科技有限公司的站点
  {
    id: 'site-001',
    tenantId: 'tenant-001',
    tenantName: '北京科技有限公司',
    name: '北京总部数据中心',
    code: 'BJZB-DC01',
    address: '北京市海淀区中关村大街1号A座',
    latitude: 39.9042,
    longitude: 116.4074,
    region: '华北',
    province: '北京市',
    city: '北京市',
    status: 'active',
    type: '数据中心',
    capacity: '500台服务器',
    createdAt: dayjs().subtract(180, 'day').format('YYYY-MM-DD'),
    syncStatus: 'synced',
    lastSyncAt: dayjs().subtract(10, 'minute').format('YYYY-MM-DD HH:mm'),
    netboxId: 'nb-site-001',
    description: '北京总部主要数据中心，承载核心业务系统'
  },
  {
    id: 'site-002',
    tenantId: 'tenant-001',
    tenantName: '北京科技有限公司',
    name: '北京分部办公室',
    code: 'BJFB-OF01',
    address: '北京市朝阳区建国门外大街2号',
    latitude: 39.9097,
    longitude: 116.4344,
    region: '华北',
    province: '北京市',
    city: '北京市',
    status: 'active',
    type: '办公室',
    capacity: '200个工位',
    createdAt: dayjs().subtract(160, 'day').format('YYYY-MM-DD'),
    syncStatus: 'synced',
    lastSyncAt: dayjs().subtract(15, 'minute').format('YYYY-MM-DD HH:mm'),
    netboxId: 'nb-site-002',
    description: '北京分部办公区域'
  },
  // 上海智能科技集团的站点
  {
    id: 'site-003',
    tenantId: 'tenant-002',
    tenantName: '上海智能科技集团',
    name: '上海浦东数据中心',
    code: 'SHPD-DC01',
    address: '上海市浦东新区陆家嘴金融中心B座',
    latitude: 31.2304,
    longitude: 121.4737,
    region: '华东',
    province: '上海市',
    city: '上海市',
    status: 'active',
    type: '数据中心',
    capacity: '800台服务器',
    createdAt: dayjs().subtract(150, 'day').format('YYYY-MM-DD'),
    syncStatus: 'synced',
    lastSyncAt: dayjs().subtract(5, 'minute').format('YYYY-MM-DD HH:mm'),
    netboxId: 'nb-site-003',
    description: '上海主要数据中心，支持金融业务'
  },
  {
    id: 'site-004',
    tenantId: 'tenant-002',
    tenantName: '上海智能科技集团',
    name: '上海张江研发中心',
    code: 'SHZJ-RD01',
    address: '上海市浦东新区张江高科技园区',
    latitude: 31.2065,
    longitude: 121.6058,
    region: '华东',
    province: '上海市',
    city: '上海市',
    status: 'active',
    type: '研发中心',
    capacity: '300个工位',
    createdAt: dayjs().subtract(140, 'day').format('YYYY-MM-DD'),
    syncStatus: 'pending',
    lastSyncAt: dayjs().subtract(2, 'hour').format('YYYY-MM-DD HH:mm'),
    netboxId: 'nb-site-004',
    description: '研发团队办公区域'
  },
  // 深圳创新企业的站点
  {
    id: 'site-005',
    tenantId: 'tenant-003',
    tenantName: '深圳创新企业',
    name: '深圳南山科技园',
    code: 'SZNS-TP01',
    address: '深圳市南山区科技园南区',
    latitude: 22.5431,
    longitude: 113.9344,
    region: '华南',
    province: '广东省',
    city: '深圳市',
    status: 'active',
    type: '科技园区',
    capacity: '400个工位',
    createdAt: dayjs().subtract(120, 'day').format('YYYY-MM-DD'),
    syncStatus: 'failed',
    lastSyncAt: dayjs().subtract(1, 'day').format('YYYY-MM-DD HH:mm'),
    netboxId: 'nb-site-005',
    description: '深圳主要办公和研发基地'
  },
  {
    id: 'site-006',
    tenantId: 'tenant-003',
    tenantName: '深圳创新企业',
    name: '深圳宝安数据中心',
    code: 'SZBA-DC01',
    address: '深圳市宝安区新安街道',
    latitude: 22.5560,
    longitude: 113.8838,
    region: '华南',
    province: '广东省',
    city: '深圳市',
    status: 'maintenance',
    type: '数据中心',
    capacity: '300台服务器',
    createdAt: dayjs().subtract(100, 'day').format('YYYY-MM-DD'),
    syncStatus: 'synced',
    lastSyncAt: dayjs().subtract(30, 'minute').format('YYYY-MM-DD HH:mm'),
    netboxId: 'nb-site-006',
    description: '深圳备用数据中心'
  }
]

// 模拟系统集成数据
export const mockIntegrations = [
  {
    id: 1,
    name: 'NetBox DCIM',
    type: '资产管理',
    status: '已连接',
    lastSync: dayjs().subtract(10, 'minute').format('YYYY-MM-DD HH:mm'),
    health: '正常',
    url: 'https://netbox.example.com'
  },
  {
    id: 2,
    name: 'Zabbix监控',
    type: '监控系统',
    status: '已连接',
    lastSync: dayjs().subtract(5, 'minute').format('YYYY-MM-DD HH:mm'),
    health: '正常',
    url: 'https://zabbix.example.com'
  },
  {
    id: 3,
    name: 'LDAP认证',
    type: '身份认证',
    status: '连接中断',
    lastSync: dayjs().subtract(2, 'hour').format('YYYY-MM-DD HH:mm'),
    health: '异常',
    url: 'ldap://ldap.example.com'
  }
]

// 模拟仪表板统计数据
export const mockDashboardStats = {
  tickets: {
    total: 1248,
    pending: 23,
    inProgress: 45,
    resolved: 1156,
    closed: 24
  },
  performance: {
    slaCompliance: 96.8,
    avgResolutionTime: 4.2,
    customerSatisfaction: 4.6,
    engineerUtilization: 78.5
  },
  trends: {
    ticketTrends: Array.from({ length: 7 }, (_, i) => ({
      date: dayjs().subtract(6 - i, 'day').format('MM-DD'),
      created: random(10, 30),
      resolved: random(8, 28)
    })),
    categoryDistribution: [
      { name: '硬件故障', value: 35 },
      { name: '软件问题', value: 28 },
      { name: '网络故障', value: 22 },
      { name: '安全事件', value: 15 }
    ]
  }
}

// 模拟工程师数据
export const mockEngineers = [
  {
    id: 'eng-001',
    name: '张工程师',
    employeeId: 'EMP001',
    email: 'zhang.engineer@company.com',
    phone: '13800138001',
    level: '高级工程师',
    department: '运维部',
    skills: ['Linux', 'Docker', 'Kubernetes', 'MySQL'],
    status: 'active',
    workStatus: 'online',
    maxConcurrentTickets: 15,
    currentTickets: 8,
    hourlyRate: 120,
    location: '北京市',
    joinDate: dayjs().subtract(800, 'day').format('YYYY-MM-DD'),
    lastActiveAt: dayjs().subtract(5, 'minute').format('YYYY-MM-DD HH:mm'),
    rating: 4.8,
    completedTickets: 245
  },
  {
    id: 'eng-002',
    name: '李工程师',
    employeeId: 'EMP002',
    email: 'li.engineer@company.com',
    phone: '13800138002',
    level: '中级工程师',
    department: '运维部',
    skills: ['Python', 'Redis', 'Nginx', 'PostgreSQL'],
    status: 'active',
    workStatus: 'busy',
    maxConcurrentTickets: 10,
    currentTickets: 12,
    hourlyRate: 80,
    location: '上海市',
    joinDate: dayjs().subtract(600, 'day').format('YYYY-MM-DD'),
    lastActiveAt: dayjs().subtract(15, 'minute').format('YYYY-MM-DD HH:mm'),
    rating: 4.6,
    completedTickets: 189
  },
  {
    id: 'eng-003',
    name: '王工程师',
    employeeId: 'EMP003',
    email: 'wang.engineer@company.com',
    phone: '13800138003',
    level: '专家工程师',
    department: '运维部',
    skills: ['Java', 'Spring Boot', 'Elasticsearch', 'RabbitMQ'],
    status: 'active',
    workStatus: 'online',
    maxConcurrentTickets: 20,
    currentTickets: 5,
    hourlyRate: 180,
    location: '深圳市',
    joinDate: dayjs().subtract(1200, 'day').format('YYYY-MM-DD'),
    lastActiveAt: dayjs().subtract(2, 'minute').format('YYYY-MM-DD HH:mm'),
    rating: 4.9,
    completedTickets: 356
  },
  {
    id: 'eng-004',
    name: '赵工程师',
    employeeId: 'EMP004',
    email: 'zhao.engineer@company.com',
    phone: '13800138004',
    level: '初级工程师',
    department: '运维部',
    skills: ['HTML', 'CSS', 'JavaScript', 'Vue.js'],
    status: 'active',
    workStatus: 'rest',
    maxConcurrentTickets: 5,
    currentTickets: 3,
    hourlyRate: 50,
    location: '成都市',
    joinDate: dayjs().subtract(200, 'day').format('YYYY-MM-DD'),
    lastActiveAt: dayjs().subtract(1, 'hour').format('YYYY-MM-DD HH:mm'),
    rating: 4.3,
    completedTickets: 67
  }
]

// 模拟工程师站点分配关系
export const mockEngineerSiteAssignments = [
  {
    id: 'assign-001',
    engineerId: 'eng-001',
    engineerName: '张工程师',
    tenantId: 'tenant-001',
    tenantName: '北京科技有限公司',
    siteId: 'site-001',
    siteName: '北京总部数据中心',
    assignedAt: dayjs().subtract(30, 'day').format('YYYY-MM-DD'),
    assignedBy: 'admin',
    status: 'active',
    priority: 'primary'
  },
  {
    id: 'assign-002',
    engineerId: 'eng-001',
    engineerName: '张工程师',
    tenantId: 'tenant-001',
    tenantName: '北京科技有限公司',
    siteId: 'site-002',
    siteName: '北京分部办公室',
    assignedAt: dayjs().subtract(25, 'day').format('YYYY-MM-DD'),
    assignedBy: 'admin',
    status: 'active',
    priority: 'secondary'
  },
  {
    id: 'assign-003',
    engineerId: 'eng-002',
    engineerName: '李工程师',
    tenantId: 'tenant-002',
    tenantName: '上海智能科技集团',
    siteId: 'site-003',
    siteName: '上海浦东数据中心',
    assignedAt: dayjs().subtract(20, 'day').format('YYYY-MM-DD'),
    assignedBy: 'admin',
    status: 'active',
    priority: 'primary'
  },
  {
    id: 'assign-004',
    engineerId: 'eng-002',
    engineerName: '李工程师',
    tenantId: 'tenant-002',
    tenantName: '上海智能科技集团',
    siteId: 'site-004',
    siteName: '上海张江研发中心',
    assignedAt: dayjs().subtract(18, 'day').format('YYYY-MM-DD'),
    assignedBy: 'admin',
    status: 'active',
    priority: 'secondary'
  },
  {
    id: 'assign-005',
    engineerId: 'eng-003',
    engineerName: '王工程师',
    tenantId: 'tenant-003',
    tenantName: '深圳创新企业',
    siteId: 'site-005',
    siteName: '深圳南山科技园',
    assignedAt: dayjs().subtract(15, 'day').format('YYYY-MM-DD'),
    assignedBy: 'admin',
    status: 'active',
    priority: 'primary'
  },
  {
    id: 'assign-006',
    engineerId: 'eng-003',
    engineerName: '王工程师',
    tenantId: 'tenant-003',
    tenantName: '深圳创新企业',
    siteId: 'site-006',
    siteName: '深圳宝安数据中心',
    assignedAt: dayjs().subtract(12, 'day').format('YYYY-MM-DD'),
    assignedBy: 'admin',
    status: 'inactive',
    priority: 'secondary'
  }
]

// 模拟Netbox同步日志
export const mockNetboxSyncLogs = [
  {
    id: 'log-001',
    syncId: 'sync-' + dayjs().format('YYYYMMDDHHmmss'),
    startTime: dayjs().subtract(10, 'minute').format('YYYY-MM-DD HH:mm:ss'),
    endTime: dayjs().subtract(8, 'minute').format('YYYY-MM-DD HH:mm:ss'),
    status: 'success',
    totalSites: 6,
    syncedSites: 6,
    failedSites: 0,
    newSites: 0,
    updatedSites: 2,
    deletedSites: 0,
    message: '同步完成，更新了2个站点信息',
    details: [
      { siteId: 'site-003', action: 'updated', message: '更新了容量信息' },
      { siteId: 'site-004', action: 'updated', message: '更新了地址信息' }
    ]
  },
  {
    id: 'log-002',
    syncId: 'sync-' + dayjs().subtract(2, 'hour').format('YYYYMMDDHHmmss'),
    startTime: dayjs().subtract(2, 'hour').format('YYYY-MM-DD HH:mm:ss'),
    endTime: dayjs().subtract(2, 'hour').add(3, 'minute').format('YYYY-MM-DD HH:mm:ss'),
    status: 'partial_success',
    totalSites: 6,
    syncedSites: 5,
    failedSites: 1,
    newSites: 0,
    updatedSites: 1,
    deletedSites: 0,
    message: '部分同步成功，1个站点同步失败',
    details: [
      { siteId: 'site-005', action: 'failed', message: 'Netbox连接超时' },
      { siteId: 'site-001', action: 'updated', message: '更新了状态信息' }
    ]
  }
]

// 模拟站点统计数据
export const mockSiteStats = {
  total: mockSites.length,
  active: mockSites.filter(s => s.status === 'active').length,
  inactive: mockSites.filter(s => s.status === 'inactive').length,
  maintenance: mockSites.filter(s => s.status === 'maintenance').length,
  byRegion: {
    '华北': mockSites.filter(s => s.region === '华北').length,
    '华东': mockSites.filter(s => s.region === '华东').length,
    '华南': mockSites.filter(s => s.region === '华南').length,
    '西南': mockSites.filter(s => s.region === '西南').length
  },
  byType: {
    '数据中心': mockSites.filter(s => s.type === '数据中心').length,
    '办公室': mockSites.filter(s => s.type === '办公室').length,
    '研发中心': mockSites.filter(s => s.type === '研发中心').length,
    '科技园区': mockSites.filter(s => s.type === '科技园区').length
  },
  syncStatus: {
    synced: mockSites.filter(s => s.syncStatus === 'synced').length,
    pending: mockSites.filter(s => s.syncStatus === 'pending').length,
    failed: mockSites.filter(s => s.syncStatus === 'failed').length
  }
}

// 站点管理相关的工具函数
export const siteManagementUtils = {
  // 根据租户ID获取站点列表
  getSitesByTenant: (tenantId) => {
    return mockSites.filter(site => site.tenantId === tenantId)
  },

  // 根据工程师ID获取分配的站点
  getSitesByEngineer: (engineerId) => {
    const assignments = mockEngineerSiteAssignments.filter(
      assign => assign.engineerId === engineerId && assign.status === 'active'
    )
    return assignments.map(assign => {
      const site = mockSites.find(site => site.id === assign.siteId)
      return {
        ...site,
        assignmentId: assign.id,
        priority: assign.priority,
        assignedAt: assign.assignedAt
      }
    })
  },

  // 根据站点ID获取分配的工程师
  getEngineersBySite: (siteId) => {
    const assignments = mockEngineerSiteAssignments.filter(
      assign => assign.siteId === siteId && assign.status === 'active'
    )
    return assignments.map(assign => {
      const engineer = mockEngineers.find(eng => eng.id === assign.engineerId)
      return {
        ...engineer,
        assignmentId: assign.id,
        priority: assign.priority,
        assignedAt: assign.assignedAt
      }
    })
  },

  // 模拟Netbox同步API
  simulateNetboxSync: () => {
    return new Promise((resolve) => {
      setTimeout(() => {
        const syncLog = {
          id: 'log-' + Date.now(),
          syncId: 'sync-' + dayjs().format('YYYYMMDDHHmmss'),
          startTime: dayjs().format('YYYY-MM-DD HH:mm:ss'),
          endTime: dayjs().add(2, 'minute').format('YYYY-MM-DD HH:mm:ss'),
          status: 'success',
          totalSites: mockSites.length,
          syncedSites: mockSites.length,
          failedSites: 0,
          newSites: random(0, 2),
          updatedSites: random(1, 3),
          deletedSites: 0,
          message: '同步完成，所有站点信息已更新',
          details: mockSites.slice(0, random(2, 4)).map(site => ({
            siteId: site.id,
            action: 'updated',
            message: '更新了基础信息'
          }))
        }

        // 更新站点的同步状态
        mockSites.forEach(site => {
          site.syncStatus = 'synced'
          site.lastSyncAt = dayjs().format('YYYY-MM-DD HH:mm')
        })

        resolve(syncLog)
      }, 2000) // 模拟2秒的同步时间
    })
  },

  // 搜索站点
  searchSites: (query, filters = {}) => {
    let results = [...mockSites]

    // 文本搜索
    if (query) {
      const searchTerm = query.toLowerCase()
      results = results.filter(site =>
        site.name.toLowerCase().includes(searchTerm) ||
        site.address.toLowerCase().includes(searchTerm) ||
        site.code.toLowerCase().includes(searchTerm) ||
        site.tenantName.toLowerCase().includes(searchTerm)
      )
    }

    // 状态筛选
    if (filters.status) {
      results = results.filter(site => site.status === filters.status)
    }

    // 租户筛选
    if (filters.tenantId) {
      results = results.filter(site => site.tenantId === filters.tenantId)
    }

    // 区域筛选
    if (filters.region) {
      results = results.filter(site => site.region === filters.region)
    }

    // 类型筛选
    if (filters.type) {
      results = results.filter(site => site.type === filters.type)
    }

    // 同步状态筛选
    if (filters.syncStatus) {
      results = results.filter(site => site.syncStatus === filters.syncStatus)
    }

    return results
  },

  // 获取站点地图数据
  getSiteMapData: () => {
    return mockSites.map(site => ({
      id: site.id,
      name: site.name,
      tenantName: site.tenantName,
      coordinates: [site.longitude, site.latitude],
      status: site.status,
      type: site.type,
      region: site.region,
      address: site.address
    }))
  }
}

// 模拟实时数据更新
export const createMockDataStream = (callback, interval = 5000) => {
  const updateData = () => {
    // 模拟实时数据变化
    const newData = {
      timestamp: dayjs().format('HH:mm:ss'),
      activeUsers: random(50, 200),
      systemLoad: randomFloat(0.1, 2.0),
      memoryUsage: random(30, 90),
      networkTraffic: random(100, 1000)
    }
    callback(newData)
  }

  const timer = setInterval(updateData, interval)
  updateData() // 立即执行一次

  return () => clearInterval(timer)
}

// 站点分配历史记录
export const mockSiteAssignmentHistory = [
  {
    id: 'history-001',
    timestamp: '2024-01-15 14:30:00',
    engineerId: 'eng-001',
    engineerName: '张工程师',
    action: 'assign',
    siteId: 'site-001',
    siteName: '阿里巴巴杭州数据中心',
    tenantId: 'tenant-001',
    tenantName: '阿里巴巴集团',
    operator: '系统管理员',
    reason: '新工程师入职，分配主要负责站点'
  },
  {
    id: 'history-002',
    timestamp: '2024-01-16 09:15:00',
    engineerId: 'eng-001',
    engineerName: '张工程师',
    action: 'assign',
    siteId: 'site-002',
    siteName: '阿里巴巴上海办公室',
    tenantId: 'tenant-001',
    tenantName: '阿里巴巴集团',
    operator: '系统管理员',
    reason: '扩展负责区域，增加上海站点'
  },
  {
    id: 'history-003',
    timestamp: '2024-01-18 16:45:00',
    engineerId: 'eng-002',
    engineerName: '李工程师',
    action: 'batch_assign',
    siteId: 'site-003,site-004',
    siteName: '腾讯深圳总部,腾讯北京研发中心',
    tenantId: 'tenant-002',
    tenantName: '腾讯科技',
    operator: '部门主管',
    reason: '批量分配腾讯相关站点'
  },
  {
    id: 'history-004',
    timestamp: '2024-01-20 11:20:00',
    engineerId: 'eng-003',
    engineerName: '王工程师',
    action: 'assign',
    siteId: 'site-005',
    siteName: '字节跳动北京总部',
    tenantId: 'tenant-003',
    tenantName: '字节跳动',
    operator: '系统管理员',
    reason: '专项负责字节跳动北京站点运维'
  },
  {
    id: 'history-005',
    timestamp: '2024-01-22 13:30:00',
    engineerId: 'eng-002',
    engineerName: '李工程师',
    action: 'remove',
    siteId: 'site-004',
    siteName: '腾讯北京研发中心',
    tenantId: 'tenant-002',
    tenantName: '腾讯科技',
    operator: '部门主管',
    reason: '工作调整，移除北京站点分配'
  },
  {
    id: 'history-006',
    timestamp: '2024-01-25 10:15:00',
    engineerId: 'eng-004',
    engineerName: '赵工程师',
    action: 'assign',
    siteId: 'site-006',
    siteName: '美团北京科技园',
    tenantId: 'tenant-004',
    tenantName: '美团科技',
    operator: '系统管理员',
    reason: '初级工程师培训分配，负责美团站点'
  }
]

// 模拟绩效评估数据
export const mockPerformanceEvaluations = [
  {
    id: 1,
    name: '2024年第一季度绩效评估',
    period: 'quarterly',
    startDate: '2024-01-01',
    endDate: '2024-03-31',
    status: 'completed',
    participants: [1, 2, 3, 4],
    participantCount: 4,
    completionRate: 100,
    createdAt: '2024-01-01T00:00:00Z',
    createdBy: '系统管理员',
    description: '第一季度工程师绩效评估，重点关注SLA达成率和客户满意度',
    metrics: [
      { id: 1, category: '工作质量', metric: '工单解决质量', weight: 25, enabled: true },
      { id: 2, category: '工作效率', metric: '响应时间', weight: 20, enabled: true },
      { id: 3, category: '工作效率', metric: '解决时间', weight: 20, enabled: true },
      { id: 4, category: '客户服务', metric: '客户满意度', weight: 15, enabled: true },
      { id: 5, category: '团队协作', metric: '知识分享', weight: 10, enabled: true },
      { id: 6, category: '专业发展', metric: '技能提升', weight: 10, enabled: true }
    ]
  },
  {
    id: 2,
    name: '2024年第二季度绩效评估',
    period: 'quarterly',
    startDate: '2024-04-01',
    endDate: '2024-06-30',
    status: 'in_progress',
    participants: [1, 2, 3, 4],
    participantCount: 4,
    completionRate: 75,
    createdAt: '2024-04-01T00:00:00Z',
    createdBy: '系统管理员',
    description: '第二季度工程师绩效评估，新增知识贡献度考核',
    metrics: [
      { id: 1, category: '工作质量', metric: '工单解决质量', weight: 25, enabled: true },
      { id: 2, category: '工作效率', metric: '响应时间', weight: 20, enabled: true },
      { id: 3, category: '工作效率', metric: '解决时间', weight: 20, enabled: true },
      { id: 4, category: '客户服务', metric: '客户满意度', weight: 15, enabled: true },
      { id: 5, category: '团队协作', metric: '知识分享', weight: 10, enabled: true },
      { id: 6, category: '专业发展', metric: '技能提升', weight: 10, enabled: true }
    ]
  }
]

// 模拟资产管理配置数据
export const mockAssetManagementConfig = {
  netbox: {
    server: 'netbox.example.com',
    port: 443,
    token: 'your-api-token-here',
    useHttps: true,
    autoSync: true,
    syncInterval: '6h',
    syncScope: ['sites', 'devices', 'ips', 'locations'],
    lastSync: '2024-01-15 14:30:00',
    status: 'connected'
  },
  stats: {
    totalSites: 15,
    activeSites: 14,
    totalDevices: 256,
    onlineDevices: 238,
    totalIPs: 1024,
    assignedIPs: 756
  },
  syncHistory: [
    {
      syncTime: '2024-01-15 14:30:00',
      syncType: '全量同步',
      recordCount: 256,
      status: 'success',
      duration: '2分30秒',
      message: '同步完成'
    },
    {
      syncTime: '2024-01-15 08:30:00',
      syncType: '增量同步',
      recordCount: 12,
      status: 'success',
      duration: '15秒',
      message: '同步完成'
    },
    {
      syncTime: '2024-01-14 20:30:00',
      syncType: '增量同步',
      recordCount: 0,
      status: 'failed',
      duration: '5秒',
      message: 'API连接超时'
    }
  ]
}

// 模拟监控系统配置数据
export const mockMonitoringSystemConfig = {
  servers: [
    {
      id: 1,
      name: '主监控服务器',
      host: 'monitor1.example.com',
      port: 8080,
      username: 'admin',
      password: 'encrypted-password',
      status: 'online',
      version: 'v5.2.1',
      lastCheck: '2024-01-15 14:30:00',
      description: '主要监控服务器'
    },
    {
      id: 2,
      name: '备用监控服务器',
      host: 'monitor2.example.com',
      port: 8080,
      username: 'admin',
      password: 'encrypted-password',
      status: 'offline',
      version: 'v5.2.0',
      lastCheck: '2024-01-15 12:15:00',
      description: '备用监控服务器'
    }
  ],
  alertRules: [
    {
      id: 1,
      name: 'CPU使用率告警',
      metric: 'cpu_usage',
      threshold: '80%',
      enabled: true
    },
    {
      id: 2,
      name: '内存使用率告警',
      metric: 'memory_usage',
      threshold: '85%',
      enabled: true
    },
    {
      id: 3,
      name: '磁盘使用率告警',
      metric: 'disk_usage',
      threshold: '90%',
      enabled: false
    }
  ],
  notificationConfig: {
    email: true,
    sms: false,
    dingtalk: true,
    wechat: false
  }
}

// 模拟自动化平台配置数据
export const mockAutomationPlatformConfig = {
  servers: [
    {
      id: 1,
      name: 'Orion-Ops主服务器',
      host: 'orion.example.com',
      port: 8080,
      username: 'admin',
      password: 'encrypted-password',
      apiToken: 'your-api-token',
      status: 'online',
      version: 'v2.1.0',
      machineCount: 45,
      lastSync: '2024-01-15 14:30:00',
      description: '主要自动化服务器'
    },
    {
      id: 2,
      name: 'Orion-Ops备用服务器',
      host: 'orion-backup.example.com',
      port: 8080,
      username: 'admin',
      password: 'encrypted-password',
      apiToken: 'your-backup-token',
      status: 'offline',
      version: 'v2.0.8',
      machineCount: 23,
      lastSync: '2024-01-14 18:20:00',
      description: '备用自动化服务器'
    }
  ],
  tasks: [
    {
      id: 1,
      name: '系统更新任务',
      type: '批量执行',
      server: 'Orion-Ops主服务器',
      status: 'completed',
      progress: 100,
      createTime: '2024-01-15 10:00:00'
    },
    {
      id: 2,
      name: '日志清理任务',
      type: '定时任务',
      server: 'Orion-Ops主服务器',
      status: 'running',
      progress: 65,
      createTime: '2024-01-15 14:00:00'
    },
    {
      id: 3,
      name: '配置部署任务',
      type: '应用发布',
      server: 'Orion-Ops备用服务器',
      status: 'pending',
      progress: 0,
      createTime: '2024-01-15 15:00:00'
    }
  ],
  machines: [
    { id: 1, name: 'web-server-01', ip: '192.168.1.10', status: 'online', os: 'CentOS 7' },
    { id: 2, name: 'web-server-02', ip: '192.168.1.11', status: 'online', os: 'CentOS 7' },
    { id: 3, name: 'db-server-01', ip: '192.168.1.20', status: 'offline', os: 'Ubuntu 20.04' },
    { id: 4, name: 'cache-server-01', ip: '192.168.1.30', status: 'online', os: 'CentOS 8' },
    { id: 5, name: 'monitor-server-01', ip: '192.168.1.40', status: 'online', os: 'Ubuntu 18.04' }
  ],
  scripts: [
    {
      id: 1,
      name: '系统监控脚本',
      type: 'Shell',
      description: '监控系统资源使用情况',
      createTime: '2024-01-10 09:00:00'
    },
    {
      id: 2,
      name: '日志清理脚本',
      type: 'Python',
      description: '清理过期日志文件',
      createTime: '2024-01-12 14:30:00'
    },
    {
      id: 3,
      name: '备份脚本',
      type: 'Shell',
      description: '数据库备份脚本',
      createTime: '2024-01-14 16:00:00'
    }
  ]
}