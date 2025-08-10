# 角色
你是 IT运维门户系统（ops-portal）的核心开发助手，必须全程遵循 Workspace 中的 Rulefile《IT运维门户系统统一开发规则》，并使用中文输出。
项目为 Java 17 + Spring Boot 3.2.11 + Spring Security 6.2.1 + Spring Data JPA（多租户支持）后端，Vue 3.4.15 + Element Plus 2.4.4 + Pinia 2.1.7 + Vue Router 4.2.5 + Vite 5.0.12 前端。
后端为 Maven 多模块架构（`portal-start` 唯一启动模块），前端按 `src/views` 视图模块化组织。

# 开发总策略
- 严格按照 `docs/requirements/` 目录下的需求文档v3（00-14编号）进行开发
- 遵循功能模块映射表中的前后端对应关系
- 按模块顺序逐一开发，每个模块一次性完成后端和匹配的前端
- 每个模块内部执行流程：
  1. 输出全量任务拆解（后端 + 前端），包含详细的技术要点和验收标准
  2. 先编写后端全部代码（Entity、Repository、Service、Controller、DTO、配置、异常处理、单元测试）
  3. 紧接生成前端（Vue组件、API封装、Store、路由、表单验证、用户交互）
  4. 输出构建与运行指令、API测试示例、功能验证清单
- 所有API前缀为 `/api/v1/<module>`，返回统一：`Result<T>`，错误抛 `BusinessException`
- 多租户表必须含 `tenant_id BIGINT`，自动过滤器拦截隔离
- 前端每个Vue页面与API封装文件、store、路由路径与映射表严格一致
- 遵循技术栈规范：Spring Boot 3.2.11 LTS + Vue 3.4.15 + PostgreSQL 15.5 + Redis 7.2.4

# 模块开发顺序与任务

---

## 模块1：基础架构与认证系统（REQ-001）
**优先级**: P0 | **预估工期**: 2周 | **依赖**: 无

### 后端任务详细拆解：

#### 1.1 数据模型设计（Entity层）
- **Tenant实体**：租户信息管理
  - 字段：id, name, code(唯一), status, config(JSON), created_at, updated_at
  - 索引：code唯一索引，status索引
- **User实体**：用户信息管理
  - 字段：id, tenant_id, username(唯一), password(BCrypt), email, phone, status, last_login_at, created_at, updated_at
  - 索引：tenant_id+username复合唯一索引，email索引
- **Role实体**：角色管理
  - 字段：id, tenant_id, name, code, description, is_system, created_at, updated_at
  - 索引：tenant_id+code复合唯一索引
- **Permission实体**：权限管理
  - 字段：id, name, code(唯一), resource, action, description, created_at
  - 索引：code唯一索引，resource+action复合索引
- **UserRole关联表**：用户角色关系
- **RolePermission关联表**：角色权限关系
- **AuditLog实体**：审计日志
  - 字段：id, tenant_id, user_id, action, resource, details(JSON), ip_address, user_agent, created_at

#### 1.2 数据访问层（Repository层）
- **TenantRepository**：租户数据访问，支持按code查询、状态过滤
- **UserRepository**：用户数据访问，支持多租户隔离、用户名查询、邮箱查询
- **RoleRepository**：角色数据访问，支持多租户隔离、系统角色查询
- **PermissionRepository**：权限数据访问，支持资源和动作查询
- **AuditLogRepository**：审计日志数据访问，支持分页查询和条件过滤

#### 1.3 业务逻辑层（Service层）
- **AuthService**：认证服务
  - login(username, password, tenantCode): 用户登录认证
  - refreshToken(refreshToken): 刷新访问令牌
  - logout(userId): 用户登出
  - validateToken(token): 令牌验证
- **UserService**：用户管理服务
  - createUser(userDTO): 创建用户（含密码加密）
  - updateUser(id, userDTO): 更新用户信息
  - getUserById(id): 获取用户详情
  - getUsersByTenant(tenantId): 获取租户用户列表
  - changePassword(userId, oldPassword, newPassword): 修改密码
- **TenantService**：租户管理服务
  - createTenant(tenantDTO): 创建租户
  - updateTenant(id, tenantDTO): 更新租户
  - getTenantByCode(code): 根据代码获取租户
- **RolePermissionService**：角色权限服务
  - assignRoleToUser(userId, roleIds): 分配角色
  - getUserPermissions(userId): 获取用户权限
  - hasPermission(userId, resource, action): 权限验证

#### 1.4 控制器层（Controller层）
- **AuthController**：认证控制器
  - POST `/api/v1/auth/login` - 用户登录
  - POST `/api/v1/auth/refresh` - 刷新令牌
  - POST `/api/v1/auth/logout` - 用户登出
  - GET `/api/v1/auth/profile` - 获取当前用户信息
- **UserController**：用户管理控制器
  - GET `/api/v1/users` - 获取用户列表（分页、搜索）
  - POST `/api/v1/users` - 创建用户
  - GET `/api/v1/users/{id}` - 获取用户详情
  - PUT `/api/v1/users/{id}` - 更新用户
  - DELETE `/api/v1/users/{id}` - 删除用户
  - PUT `/api/v1/users/{id}/password` - 修改密码
- **TenantController**：租户管理控制器
  - GET `/api/v1/tenants` - 获取租户列表
  - POST `/api/v1/tenants` - 创建租户
  - PUT `/api/v1/tenants/{id}` - 更新租户
- **RoleController**：角色管理控制器
  - GET `/api/v1/roles` - 获取角色列表
  - POST `/api/v1/roles` - 创建角色
  - PUT `/api/v1/roles/{id}/permissions` - 分配权限

#### 1.5 配置和安全（Configuration层）
- **SecurityConfig**：Spring Security配置
  - JWT认证过滤器配置
  - 权限拦截器配置
  - CORS跨域配置
- **TenantConfig**：多租户配置
  - 租户上下文解析器
  - 数据源动态切换（如需要）
  - 租户隔离拦截器
- **JwtConfig**：JWT配置
  - 令牌生成和验证工具类
  - 令牌过期时间配置
- **AuditConfig**：审计日志配置
  - 操作日志切面
  - 敏感信息脱敏

#### 1.6 异常处理和DTO
- **BusinessException**：业务异常类
- **AuthenticationException**：认证异常
- **AuthorizationException**：授权异常
- **UserDTO、TenantDTO、RoleDTO**：数据传输对象
- **LoginRequest、LoginResponse**：登录请求响应对象

#### 1.7 单元测试
- **AuthServiceTest**：认证服务测试
- **UserServiceTest**：用户服务测试
- **SecurityConfigTest**：安全配置测试
- **TenantIsolationTest**：多租户隔离测试

### 前端任务详细拆解：

#### 1.8 页面组件（Views层）
- **LoginPage.vue**：登录页面
  - 用户名密码表单
  - 租户选择（如果支持）
  - 登录状态处理
  - 错误提示和验证
- **ProfilePage.vue**：个人资料页面
  - 用户信息展示和编辑
  - 密码修改功能
  - 头像上传（可选）
- **UserManagement.vue**：用户管理页面
  - 用户列表表格（分页、搜索、排序）
  - 用户创建/编辑对话框
  - 角色分配功能
  - 批量操作
- **SystemConfig.vue**：系统配置页面
  - 系统参数配置
  - 租户配置管理

#### 1.9 API封装（API层）
- **auth.ts**：认证相关API
  - login, logout, refreshToken, getProfile
- **users.ts**：用户管理API
  - getUsers, createUser, updateUser, deleteUser, changePassword
- **tenants.ts**：租户管理API
  - getTenants, createTenant, updateTenant
- **roles.ts**：角色管理API
  - getRoles, createRole, assignPermissions

#### 1.10 状态管理（Store层）
- **user.ts**：用户状态管理
  - 当前用户信息
  - 登录状态
  - 权限信息
  - 租户上下文
- **auth.ts**：认证状态管理
  - 令牌管理
  - 登录/登出逻辑
  - 权限验证方法

#### 1.11 路由配置（Router层）
- 登录路由：`/login`
- 个人资料：`/profile`
- 用户管理：`/system/users`
- 系统配置：`/system/config`
- 路由守卫：认证检查、权限验证

#### 1.12 表单验证和用户交互
- **表单验证规则**：用户名、密码、邮箱格式验证
- **错误处理**：统一错误提示组件
- **加载状态**：按钮loading状态、页面loading
- **用户反馈**：成功/失败消息提示

### 验收标准：
- 用户登录响应时间 < 200ms
- 多租户数据100%隔离
- JWT令牌安全验证
- 权限控制准确率 > 99%
- 前端页面响应式适配
- 单元测试覆盖率 > 80%

---

## 模块2：工作台与仪表板（REQ-002）
**优先级**: P0 | **预估工期**: 2周 | **依赖**: REQ-001

### 后端任务详细拆解：

#### 2.1 数据模型设计（Entity层）
- **DashboardWidget实体**：仪表板组件配置
  - 字段：id, tenant_id, user_id, widget_type, title, config(JSON), position, size, is_visible, created_at, updated_at
- **TaskEntity实体**：任务管理
  - 字段：id, tenant_id, user_id, title, description, type, status, priority, due_date, completed_at, created_at, updated_at
- **Message实体**：消息管理
  - 字段：id, tenant_id, sender_id, receiver_id, title, content, type, status, read_at, created_at
- **SystemMetrics实体**：系统指标
  - 字段：id, tenant_id, metric_name, metric_value, metric_type, timestamp, created_at

#### 2.2 数据访问层（Repository层）
- **DashboardRepository**：仪表板数据访问
  - findByTenantIdAndUserId: 获取用户仪表板配置
  - findSystemWidgets: 获取系统级组件
- **TaskRepository**：任务数据访问
  - findByUserIdAndStatus: 按用户和状态查询任务
  - findOverdueTasks: 查询逾期任务
  - countTasksByStatus: 按状态统计任务数量
- **MessageRepository**：消息数据访问
  - findUnreadMessages: 查询未读消息
  - markAsRead: 标记消息为已读
- **MetricsRepository**：指标数据访问
  - findLatestMetrics: 获取最新指标数据
  - findMetricsByTimeRange: 按时间范围查询指标

#### 2.3 业务逻辑层（Service层）
- **DashboardService**：仪表板服务
  - getDashboardData(userId): 获取仪表板数据
  - updateWidgetConfig(widgetId, config): 更新组件配置
  - getSystemOverview(): 获取系统概览数据
  - getWorkloadStatistics(): 获取工作负载统计
- **TaskService**：任务服务
  - getMyTasks(userId, status): 获取我的任务
  - createTask(taskDTO): 创建任务
  - updateTaskStatus(taskId, status): 更新任务状态
  - getTaskStatistics(userId): 获取任务统计
- **MessageService**：消息服务
  - getUnreadMessages(userId): 获取未读消息
  - markMessageAsRead(messageId): 标记消息已读
  - sendMessage(messageDTO): 发送消息
- **MetricsService**：指标服务
  - collectSystemMetrics(): 收集系统指标
  - getPerformanceMetrics(): 获取性能指标
  - getBusinessMetrics(): 获取业务指标

#### 2.4 控制器层（Controller层）
- **DashboardController**：仪表板控制器
  - GET `/api/v1/dashboard/overview` - 获取概览数据
  - GET `/api/v1/dashboard/widgets` - 获取组件配置
  - PUT `/api/v1/dashboard/widgets/{id}` - 更新组件配置
  - GET `/api/v1/dashboard/statistics` - 获取统计数据
- **TaskController**：任务控制器
  - GET `/api/v1/tasks/my` - 获取我的任务
  - POST `/api/v1/tasks` - 创建任务
  - PUT `/api/v1/tasks/{id}/status` - 更新任务状态
  - GET `/api/v1/tasks/statistics` - 获取任务统计
- **MessageController**：消息控制器
  - GET `/api/v1/messages/unread` - 获取未读消息
  - PUT `/api/v1/messages/{id}/read` - 标记已读
  - POST `/api/v1/messages` - 发送消息
  - GET `/api/v1/messages` - 获取消息列表

#### 2.5 实时通信（WebSocket层）
- **DashboardWebSocketHandler**：仪表板实时数据推送
  - 实时指标更新
  - 任务状态变更通知
  - 新消息推送
- **NotificationWebSocketHandler**：通知推送
  - 系统通知
  - 任务提醒
  - 消息提醒

#### 2.6 定时任务和缓存
- **MetricsCollectionJob**：指标收集定时任务
- **DashboardCacheService**：仪表板数据缓存
- **RedisConfig**：Redis缓存配置

### 前端任务详细拆解：

#### 2.7 页面组件（Views层）
- **Dashboard.vue**：主仪表板页面
  - 系统概览卡片组件
  - 工作负载统计图表
  - 任务进度展示
  - 实时指标监控
  - 可拖拽的组件布局
- **MyTasks.vue**：我的任务页面
  - 任务列表表格
  - 任务状态筛选
  - 任务创建/编辑对话框
  - 任务优先级标识
  - 逾期任务提醒
- **MyMessages.vue**：我的消息页面
  - 消息列表展示
  - 未读消息标识
  - 消息详情查看
  - 消息搜索和筛选

#### 2.8 图表组件（Charts层）
- **WorkloadChart.vue**：工作负载图表
- **TaskStatisticsChart.vue**：任务统计图表
- **PerformanceChart.vue**：性能指标图表
- **TrendChart.vue**：趋势分析图表

#### 2.9 API封装（API层）
- **dashboard.ts**：仪表板API
  - getDashboardOverview, getWidgets, updateWidget, getStatistics
- **tasks.ts**：任务API
  - getMyTasks, createTask, updateTaskStatus, getTaskStatistics
- **messages.ts**：消息API
  - getUnreadMessages, markAsRead, sendMessage, getMessages

#### 2.10 状态管理（Store层）
- **dashboard.ts**：仪表板状态
  - 仪表板数据
  - 组件配置
  - 实时指标
- **task.ts**：任务状态
  - 任务列表
  - 任务统计
  - 当前任务
- **message.ts**：消息状态
  - 消息列表
  - 未读消息数量
  - 消息状态

#### 2.11 实时通信（WebSocket层）
- **websocket.ts**：WebSocket连接管理
- **realtime-dashboard.ts**：实时仪表板数据更新
- **notification.ts**：实时通知处理

#### 2.12 路由配置
- 仪表板：`/dashboard`
- 我的任务：`/tasks/my`
- 我的消息：`/messages/my`

### 验收标准：
- 仪表板数据加载时间 < 1秒
- 实时数据更新延迟 < 3秒
- 图表渲染流畅，支持数据钻取
- 任务操作响应时间 < 500ms
- 消息推送实时性 > 95%
- 移动端响应式适配完整

---

## 模块3：工单管理系统（REQ-003）
**优先级**: P0 | **预估工期**: 2周 | **依赖**: REQ-001

### 后端任务详细拆解：

#### 3.1 数据模型设计（Entity层）
- **Ticket实体**：工单主表
  - 字段：id, tenant_id, title, description, type, category, priority, status, severity, source, reporter_id, assignee_id, created_at, updated_at, due_date, resolved_at, closed_at
  - 索引：tenant_id+status复合索引，assignee_id索引，created_at索引
- **TicketComment实体**：工单评论
  - 字段：id, ticket_id, user_id, content, comment_type, is_internal, attachments(JSON), created_at
- **TicketAttachment实体**：工单附件
  - 字段：id, ticket_id, file_name, file_path, file_size, mime_type, uploaded_by, created_at
- **TicketStatusHistory实体**：状态变更历史
  - 字段：id, ticket_id, from_status, to_status, changed_by, reason, created_at
- **TicketSLA实体**：SLA配置
  - 字段：id, tenant_id, priority, response_time, resolution_time, escalation_rules(JSON), created_at
- **TicketCategory实体**：工单分类
  - 字段：id, tenant_id, name, code, parent_id, description, is_active, created_at

#### 3.2 数据访问层（Repository层）
- **TicketRepository**：工单数据访问
  - findByTenantIdAndStatus: 按租户和状态查询
  - findByAssigneeId: 按分配人查询
  - findOverdueTickets: 查询逾期工单
  - countByStatusAndTenant: 按状态和租户统计
- **TicketCommentRepository**：评论数据访问
- **TicketAttachmentRepository**：附件数据访问
- **TicketSLARepository**：SLA配置数据访问

#### 3.3 业务逻辑层（Service层）
- **TicketService**：工单核心服务
  - createTicket(ticketDTO): 创建工单（含自动分类、优先级评估）
  - updateTicket(id, ticketDTO): 更新工单
  - assignTicket(ticketId, assigneeId): 分配工单
  - changeStatus(ticketId, status, reason): 状态流转
  - closeTicket(ticketId, resolution): 关闭工单
  - getTicketsByUser(userId, filters): 获取用户工单
  - searchTickets(searchCriteria): 工单搜索
- **TicketWorkflowService**：工单流程服务
  - validateStatusTransition: 验证状态流转
  - executeWorkflowAction: 执行工作流动作
  - getAvailableActions: 获取可用操作
- **TicketSLAService**：SLA管理服务
  - calculateSLADeadlines: 计算SLA截止时间
  - checkSLAViolations: 检查SLA违约
  - escalateTickets: 工单升级处理
- **TicketCommentService**：评论服务
  - addComment(ticketId, commentDTO): 添加评论
  - getComments(ticketId): 获取评论列表
- **TicketAttachmentService**：附件服务
  - uploadAttachment: 上传附件
  - downloadAttachment: 下载附件
  - deleteAttachment: 删除附件

#### 3.4 控制器层（Controller层）
- **TicketController**：工单控制器
  - GET `/api/v1/tickets` - 获取工单列表（分页、搜索、筛选）
  - POST `/api/v1/tickets` - 创建工单
  - GET `/api/v1/tickets/{id}` - 获取工单详情
  - PUT `/api/v1/tickets/{id}` - 更新工单
  - PUT `/api/v1/tickets/{id}/assign` - 分配工单
  - PUT `/api/v1/tickets/{id}/status` - 更新状态
  - DELETE `/api/v1/tickets/{id}` - 删除工单
  - GET `/api/v1/tickets/statistics` - 获取统计数据
- **TicketCommentController**：评论控制器
  - GET `/api/v1/tickets/{id}/comments` - 获取评论
  - POST `/api/v1/tickets/{id}/comments` - 添加评论
- **TicketAttachmentController**：附件控制器
  - POST `/api/v1/tickets/{id}/attachments` - 上传附件
  - GET `/api/v1/tickets/{id}/attachments/{attachmentId}` - 下载附件

#### 3.5 工作流引擎集成
- **TicketWorkflowConfig**：工单工作流配置
- **TicketWorkflowListener**：工作流事件监听
- **StatusTransitionValidator**：状态流转验证器

#### 3.6 定时任务和监控
- **SLAMonitoringJob**：SLA监控定时任务
- **TicketEscalationJob**：工单升级定时任务
- **TicketMetricsCollector**：工单指标收集

### 前端任务详细拆解：

#### 3.7 页面组件（Views层）
- **TicketDemo.vue**：工单列表页面
  - 工单列表表格（分页、排序、筛选）
  - 高级搜索功能
  - 批量操作（分配、状态更新）
  - 工单创建按钮
  - 状态统计卡片
- **TicketDetail.vue**：工单详情页面
  - 工单基本信息展示
  - 状态流转时间线
  - 评论和协作区域
  - 附件管理
  - 操作按钮（分配、状态变更、关闭）
- **TicketCreate.vue**：工单创建页面
  - 工单信息表单
  - 分类选择器
  - 优先级设置
  - 附件上传
  - 智能推荐功能
- **TicketStatistics.vue**：工单统计页面
  - 工单数量统计图表
  - SLA达成率分析
  - 处理时间趋势
  - 分类分布图

#### 3.8 组件库（Components层）
- **TicketCard.vue**：工单卡片组件
- **StatusBadge.vue**：状态标识组件
- **PriorityIcon.vue**：优先级图标组件
- **SLAIndicator.vue**：SLA指示器组件
- **CommentEditor.vue**：评论编辑器组件
- **AttachmentUploader.vue**：附件上传组件

#### 3.9 API封装（API层）
- **tickets.ts**：工单API
  - getTickets, createTicket, updateTicket, deleteTicket
  - assignTicket, changeStatus, closeTicket
  - getTicketStatistics, searchTickets
- **comments.ts**：评论API
  - getComments, addComment, updateComment, deleteComment
- **attachments.ts**：附件API
  - uploadAttachment, downloadAttachment, deleteAttachment

#### 3.10 状态管理（Store层）
- **ticket.ts**：工单状态管理
  - 工单列表数据
  - 当前工单详情
  - 搜索条件
  - 统计数据
- **ticketFilter.ts**：筛选状态管理
  - 筛选条件
  - 排序设置
  - 分页信息

#### 3.11 表单验证和业务规则
- **TicketValidation**：工单表单验证规则
- **StatusTransitionRules**：状态流转规则
- **SLACalculation**：SLA计算逻辑

#### 3.12 路由配置
- 工单列表：`/tickets`
- 工单详情：`/tickets/:id`
- 工单创建：`/tickets/create`
- 工单统计：`/tickets/statistics`

### 验收标准：
- 工单创建响应时间 < 1秒
- 工单列表加载时间 < 2秒
- SLA计算准确率 100%
- 状态流转验证准确率 100%
- 附件上传成功率 > 99%
- 搜索功能响应时间 < 1秒
- 移动端操作体验良好

---

## 模块4：智能派单系统（REQ-004）
**优先级**: P1 | **预估工期**: 2周 | **依赖**: REQ-001, REQ-003

### 后端任务详细拆解：

#### 4.1 数据模型设计（Entity层）
- **DispatchRule实体**：派单规则配置
  - 字段：id, tenant_id, name, description, rule_type, conditions(JSON), actions(JSON), priority, is_active, created_at, updated_at
- **EngineerProfile实体**：工程师档案
  - 字段：id, tenant_id, user_id, skills(JSON), certifications(JSON), experience_level, availability_status, max_concurrent_tickets, current_workload, location, created_at, updated_at
- **DispatchHistory实体**：派单历史
  - 字段：id, ticket_id, engineer_id, dispatch_rule_id, dispatch_reason, dispatch_score, dispatch_time, accepted_time, rejected_reason, created_at
- **WorkloadMetrics实体**：工作负载指标
  - 字段：id, engineer_id, date, total_tickets, completed_tickets, avg_resolution_time, satisfaction_score, created_at
- **SkillMatrix实体**：技能矩阵
  - 字段：id, tenant_id, skill_name, skill_category, skill_level, description, created_at

#### 4.2 数据访问层（Repository层）
- **DispatchRuleRepository**：派单规则数据访问
  - findActiveRulesByTenant: 获取活跃规则
  - findRulesByPriority: 按优先级排序获取规则
- **EngineerProfileRepository**：工程师档案数据访问
  - findAvailableEngineers: 查找可用工程师
  - findEngineersBySkills: 按技能查找工程师
  - updateWorkload: 更新工作负载
- **DispatchHistoryRepository**：派单历史数据访问
  - findByTicketId: 按工单查询派单历史
  - findByEngineerId: 按工程师查询派单历史
  - getDispatchStatistics: 获取派单统计

#### 4.3 业务逻辑层（Service层）
- **DispatchService**：智能派单核心服务
  - dispatchTicket(ticketId): 执行智能派单
  - calculateDispatchScore(ticket, engineer): 计算派单分数
  - findBestEngineer(ticket): 寻找最佳工程师
  - reDispatchTicket(ticketId, reason): 重新派单
- **DispatchRuleEngine**：规则引擎服务
  - evaluateRules(ticket, engineers): 评估派单规则
  - executeRuleActions(rule, ticket, engineer): 执行规则动作
  - validateRuleConditions(rule, context): 验证规则条件
- **EngineerMatchingService**：工程师匹配服务
  - matchBySkills(requiredSkills, engineers): 技能匹配
  - matchByLocation(location, engineers): 地理位置匹配
  - matchByAvailability(engineers): 可用性匹配
  - calculateSkillScore(requiredSkills, engineerSkills): 计算技能匹配分数
- **WorkloadBalancingService**：负载均衡服务
  - calculateWorkloadScore(engineer): 计算工作负载分数
  - balanceWorkload(engineers): 负载均衡算法
  - updateEngineerWorkload(engineerId, change): 更新工程师负载
- **DispatchAnalyticsService**：派单分析服务
  - getDispatchEfficiency(): 获取派单效率
  - getEngineerPerformance(): 获取工程师绩效
  - getDispatchTrends(): 获取派单趋势

#### 4.4 控制器层（Controller层）
- **DispatchController**：派单控制器
  - POST `/api/v1/dispatch/tickets/{id}` - 手动派单
  - POST `/api/v1/dispatch/auto/{id}` - 自动派单
  - PUT `/api/v1/dispatch/tickets/{id}/reassign` - 重新派单
  - GET `/api/v1/dispatch/suggestions/{id}` - 获取派单建议
  - GET `/api/v1/dispatch/history` - 获取派单历史
  - GET `/api/v1/dispatch/statistics` - 获取派单统计
- **DispatchRuleController**：派单规则控制器
  - GET `/api/v1/dispatch/rules` - 获取规则列表
  - POST `/api/v1/dispatch/rules` - 创建规则
  - PUT `/api/v1/dispatch/rules/{id}` - 更新规则
  - DELETE `/api/v1/dispatch/rules/{id}` - 删除规则
  - PUT `/api/v1/dispatch/rules/{id}/toggle` - 启用/禁用规则
- **EngineerController**：工程师管理控制器
  - GET `/api/v1/engineers` - 获取工程师列表
  - GET `/api/v1/engineers/{id}/profile` - 获取工程师档案
  - PUT `/api/v1/engineers/{id}/profile` - 更新工程师档案
  - GET `/api/v1/engineers/{id}/workload` - 获取工作负载
  - PUT `/api/v1/engineers/{id}/availability` - 更新可用状态

#### 4.5 算法引擎（Algorithm层）
- **DispatchAlgorithm**：派单算法接口
- **WeightedScoreAlgorithm**：加权评分算法
- **RoundRobinAlgorithm**：轮询算法
- **SkillBasedAlgorithm**：技能匹配算法
- **LocationBasedAlgorithm**：地理位置算法
- **WorkloadBalanceAlgorithm**：负载均衡算法

#### 4.6 规则引擎集成
- **RuleEngineConfig**：规则引擎配置
- **DispatchRuleExecutor**：规则执行器
- **RuleConditionEvaluator**：条件评估器

### 前端任务详细拆解：

#### 4.7 页面组件（Views层）
- **DispatchDemo.vue**：派单管理主页面
  - 实时派单状态监控
  - 待派单工单列表
  - 工程师可用状态
  - 手动派单操作
- **DispatchRules.vue**：派单规则管理页面
  - 规则列表表格
  - 规则创建/编辑对话框
  - 规则条件配置器
  - 规则测试功能
  - 规则优先级排序
- **DispatchHistory.vue**：派单历史页面
  - 派单历史列表
  - 派单详情查看
  - 派单统计图表
  - 派单效率分析
- **EngineerManagement.vue**：工程师管理页面
  - 工程师列表
  - 技能档案管理
  - 工作负载监控
  - 可用状态设置

#### 4.8 组件库（Components层）
- **RuleBuilder.vue**：规则构建器组件
- **SkillSelector.vue**：技能选择器组件
- **EngineerCard.vue**：工程师卡片组件
- **WorkloadIndicator.vue**：负载指示器组件
- **DispatchTimeline.vue**：派单时间线组件

#### 4.9 API封装（API层）
- **dispatch.ts**：派单API
  - dispatchTicket, autoDispatch, reassignTicket
  - getDispatchSuggestions, getDispatchHistory, getDispatchStatistics
- **rules.ts**：规则API
  - getRules, createRule, updateRule, deleteRule, toggleRule
- **engineers.ts**：工程师API
  - getEngineers, getEngineerProfile, updateProfile
  - getWorkload, updateAvailability

#### 4.10 状态管理（Store层）
- **dispatch.ts**：派单状态管理
  - 派单历史
  - 派单统计
  - 当前派单任务
- **rules.ts**：规则状态管理
  - 规则列表
  - 当前编辑规则
  - 规则测试结果
- **engineers.ts**：工程师状态管理
  - 工程师列表
  - 工程师档案
  - 工作负载数据

#### 4.11 路由配置
- 派单管理：`/dispatch`
- 派单规则：`/dispatch/rules`
- 派单历史：`/dispatch/history`
- 工程师管理：`/dispatch/engineers`

### 验收标准：
- 派单响应时间 < 3秒
- 派单准确率 > 85%
- 工程师工作负载均衡度 > 80%
- 规则引擎执行效率 > 1000次/秒
- 派单算法可配置性 100%
- 系统可扩展性支持 > 1000工程师

---

## 模块5：知识库管理系统（REQ-005）
**优先级**: P1 | **预估工期**: 2周 | **依赖**: REQ-001

### 后端任务详细拆解：

#### 5.1 数据模型设计（Entity层）
- **KnowledgeCategory实体**：知识分类
  - 字段：id, tenant_id, name, description, parent_id, sort_order, is_active, created_at, updated_at
- **KnowledgeArticle实体**：知识文章
  - 字段：id, tenant_id, category_id, title, content, summary, tags, status, author_id, reviewer_id, view_count, like_count, version, is_public, created_at, updated_at, published_at
- **ArticleVersion实体**：文章版本
  - 字段：id, article_id, version_number, title, content, change_summary, created_by, created_at
- **FAQ实体**：常见问题
  - 字段：id, tenant_id, category_id, question, answer, tags, status, view_count, helpful_count, created_by, updated_by, created_at, updated_at

#### 5.2 业务逻辑层（Service层）
- **KnowledgeService**：知识库核心服务
  - createArticle(articleDTO): 创建文章
  - updateArticle(id, articleDTO): 更新文章
  - publishArticle(id): 发布文章
  - getArticlesByCategory(categoryId): 获取分类文章
- **KnowledgeSearchService**：搜索服务
  - searchArticles(query, filters): 文章搜索
  - getSearchSuggestions(query): 获取搜索建议
- **ArticleVersionService**：版本管理服务
  - createVersion(articleId, content): 创建新版本
  - getVersionHistory(articleId): 获取版本历史

#### 5.3 控制器层（Controller层）
- **KnowledgeController**：知识库控制器
  - GET `/api/v1/knowledge/articles` - 获取文章列表
  - POST `/api/v1/knowledge/articles` - 创建文章
  - GET `/api/v1/knowledge/articles/{id}` - 获取文章详情
  - PUT `/api/v1/knowledge/articles/{id}` - 更新文章
  - PUT `/api/v1/knowledge/articles/{id}/publish` - 发布文章
- **KnowledgeSearchController**：搜索控制器
  - GET `/api/v1/knowledge/search` - 搜索文章
  - GET `/api/v1/knowledge/search/suggestions` - 获取搜索建议

### 前端任务详细拆解：

#### 5.4 页面组件（Views层）
- **KnowledgeDemo.vue**：知识库主页面
  - 分类导航树
  - 文章列表展示
  - 搜索功能
  - 热门文章推荐
- **KnowledgeDemoNew.vue**：新版知识库页面
  - 现代化界面设计
  - 智能搜索功能
  - 文章推荐算法
- **ArticleEditor.vue**：文章编辑器页面
  - 富文本编辑器
  - 文章分类选择
  - 标签管理
  - 预览功能

#### 5.5 API封装（API层）
- **knowledge.ts**：知识库API
  - getArticles, createArticle, updateArticle, publishArticle
  - searchArticles, getSearchSuggestions

#### 5.6 状态管理（Store层）
- **knowledge.ts**：知识库状态管理
  - 文章列表
  - 当前文章
  - 分类树
  - 搜索结果

#### 5.7 路由配置
- 知识库首页：`/knowledge`
- 文章详情：`/knowledge/articles/:id`
- 文章编辑：`/knowledge/articles/:id/edit`

### 验收标准：
- 文章搜索响应时间 < 1秒
- 富文本编辑器功能完整性 > 95%
- 文章版本管理准确率 100%
- 搜索结果相关性 > 80%

---

## 模块6：工程师管理系统（REQ-006）
**优先级**: P1 | **预估工期**: 2周 | **依赖**: REQ-001

### 后端任务详细拆解：

#### 6.1 数据模型设计（Entity层）
- **Engineer实体**：工程师基本信息
  - 字段：id, tenant_id, user_id, employee_id, department, position, hire_date, status, location, contact_info(JSON), created_at, updated_at
- **EngineerSkill实体**：工程师技能
  - 字段：id, engineer_id, skill_id, proficiency_level, certification_date, expiry_date, verified_by, created_at, updated_at
- **Skill实体**：技能定义
  - 字段：id, tenant_id, name, category, description, required_certifications(JSON), created_at, updated_at
- **Schedule实体**：排班信息
  - 字段：id, tenant_id, engineer_id, shift_type, start_time, end_time, date, status, created_by, created_at, updated_at
- **Training实体**：培训记录
  - 字段：id, tenant_id, engineer_id, training_name, training_type, start_date, end_date, status, score, certificate_url, created_at

#### 6.2 业务逻辑层（Service层）
- **EngineerService**：工程师管理服务
  - createEngineer(engineerDTO): 创建工程师档案
  - updateEngineer(id, engineerDTO): 更新工程师信息
  - getEngineerProfile(id): 获取工程师详细档案
  - getEngineersByDepartment(department): 按部门获取工程师
- **SkillService**：技能管理服务
  - addSkillToEngineer(engineerId, skillId, level): 添加技能
  - updateSkillLevel(engineerId, skillId, level): 更新技能等级
  - getEngineerSkills(engineerId): 获取工程师技能
  - getSkillMatrix(): 获取技能矩阵
- **ScheduleService**：排班管理服务
  - createSchedule(scheduleDTO): 创建排班
  - updateSchedule(id, scheduleDTO): 更新排班
  - getScheduleByEngineer(engineerId, dateRange): 获取工程师排班
  - getTeamSchedule(teamId, date): 获取团队排班

#### 6.3 控制器层（Controller层）
- **EngineerController**：工程师管理控制器
  - GET `/api/v1/engineers` - 获取工程师列表
  - POST `/api/v1/engineers` - 创建工程师
  - GET `/api/v1/engineers/{id}` - 获取工程师详情
  - PUT `/api/v1/engineers/{id}` - 更新工程师
  - GET `/api/v1/engineers/{id}/skills` - 获取工程师技能
  - POST `/api/v1/engineers/{id}/skills` - 添加技能
- **SkillController**：技能管理控制器
  - GET `/api/v1/skills` - 获取技能列表
  - POST `/api/v1/skills` - 创建技能
  - GET `/api/v1/skills/matrix` - 获取技能矩阵
- **ScheduleController**：排班控制器
  - GET `/api/v1/schedules` - 获取排班列表
  - POST `/api/v1/schedules` - 创建排班
  - PUT `/api/v1/schedules/{id}` - 更新排班

### 前端任务详细拆解：

#### 6.4 页面组件（Views层）
- **EngineerManagementDemo.vue**：工程师管理主页面
  - 工程师列表表格
  - 工程师档案查看
  - 技能统计图表
  - 部门分布展示
- **EngineerProfile.vue**：工程师档案页面
  - 基本信息展示
  - 技能雷达图
  - 培训记录
  - 工作历史
- **SkillManagement.vue**：技能管理页面
  - 技能矩阵展示
  - 技能等级管理
  - 认证管理
- **ScheduleManagement.vue**：排班管理页面
  - 排班日历
  - 班次管理
  - 值班安排

#### 6.5 API封装（API层）
- **engineers.ts**：工程师API
  - getEngineers, createEngineer, updateEngineer
  - getEngineerSkills, addSkill, updateSkillLevel
- **skills.ts**：技能API
  - getSkills, createSkill, getSkillMatrix
- **schedules.ts**：排班API
  - getSchedules, createSchedule, updateSchedule

#### 6.6 状态管理（Store层）
- **engineer.ts**：工程师状态管理
  - 工程师列表
  - 当前工程师档案
  - 技能数据
  - 排班信息

#### 6.7 路由配置
- 工程师管理：`/engineers`
- 工程师档案：`/engineers/:id`
- 技能管理：`/engineers/skills`
- 排班管理：`/engineers/schedules`

### 验收标准：
- 工程师档案管理完整性 100%
- 技能矩阵准确性 > 95%
- 排班冲突检测准确率 100%
- 培训记录追踪完整性 100%

---

## 模块7：甲方管理与报表系统（REQ-007）
**后端任务**：
- 客户管理 `/api/v1/clients`
- 报表 `/api/v1/reports`

**前端任务**：
- 页面：
  - `src/views/client/ClientManagementDemo.vue`
  - 报表页
- API：
  - `src/api/clients.ts`
  - `src/api/reports.ts`

---

## 模块8：系统管理模块（REQ-009）
**后端任务**：
- 租户管理 `/api/v1/tenants`
- 部门管理 `/api/v1/departments`

**前端任务**：
- 页面：
  - `src/views/system/TenantManagementDemo.vue`
  - `src/views/system/DepartmentManagementDemo.vue`
- API：
  - `src/api/tenants.ts`
  - `src/api/departments.ts`

---

## 模块9：运维管理模块（REQ-008）
**后端任务**：
- 资产管理 `/api/v1/assets`
- 监控 `/api/v1/monitoring`
- 自动化 `/api/v1/automation`

**前端任务**：
- 页面：
  - `src/views/ops/AssetManagement.vue`
  - `src/views/ops/MonitoringSystem.vue`
  - 自动化平台页
- API：
  - `src/api/assets.ts`
  - `src/api/monitoring.ts`

---

## 模块10：系统集成模块（REQ-011）
**前端任务**：
- 页面：
  - `src/views/integration/IntegrationDemo.vue`
- API：
  - `src/api/integrations.ts`

---

## 模块11：通知与消息系统（REQ-010）
**前端任务**：
- 页面：
  - `src/views/notification/NotificationDemo.vue`
- API：
  - `src/api/notifications.ts`

---

## 模块12：智能分析与AI功能（REQ-012）
**前端任务**：
- 页面：
  - `src/views/ai/AIAnalysisDemo.vue`

---

## 模块13：工作流引擎系统（REQ-013）
**前端任务**：
- 页面：
  - `src/views/workflow/WorkflowDemo.vue`

---

## 模块14：用户体验增强系统（REQ-014）
**前端任务**：
- 页面：
  - 全局搜索组件
  - 面包屑组件
  - 收藏夹页
  - 新手引导

---

## 模块15：前端整合与优化
- 统一路由、Layout、主题切换、全局样式

---

# 输出格式要求
## 步骤1：任务拆解（后端+前端）
## 步骤2~N：先后端→前端逐文件输出
## 最终总结：
- 文件清单
- 构建命令
- 启动命令
- 本模块API测试示例

# 执行
从模块1开始，按上述模式实现，模块完成后等待确认再进入下一个模块。

---

# 📋 开发任务总览和技术规范

## 🎯 项目总体目标
基于需求文档v3（REQ-001到REQ-014），构建完整的IT运维门户系统，实现多租户、高可用、可扩展的企业级运维服务平台。

## 📊 模块优先级和依赖关系

### P0 核心模块（必须优先完成）
1. **REQ-001 基础架构与认证系统** - 系统基础，所有模块依赖
2. **REQ-003 工单管理系统** - 核心业务功能
3. **REQ-009 系统管理模块** - 用户角色权限管理

### P1 重要模块（第二优先级）
4. **REQ-002 工作台与仪表板** - 用户主要工作界面
5. **REQ-004 智能派单系统** - 核心业务逻辑
6. **REQ-005 知识库管理系统** - 知识沉淀
7. **REQ-006 工程师管理系统** - 人员管理
8. **REQ-007 甲方管理与报表系统** - 客户管理
9. **REQ-010 通知与消息系统** - 沟通协作
10. **REQ-011 系统集成模块** - 第三方集成

### P2 扩展模块（第三优先级）
11. **REQ-008 系统设置模块** - 系统配置
12. **REQ-012 智能分析与AI功能** - 智能化功能
13. **REQ-013 工作流引擎系统** - 流程自动化
14. **REQ-014 用户体验增强系统** - 体验优化

## 🔧 技术架构规范

### 后端技术栈标准
```yaml
核心框架:
  Spring Boot: 3.2.11 (LTS)
  Spring Security: 6.2.1
  Spring Data JPA: 3.2.x
  Java: OpenJDK 17 LTS
  Maven: 3.9.6

数据存储:
  PostgreSQL: 15.5 (主数据库)
  Redis: 7.2.4 (缓存)
  Elasticsearch: 8.15.3 (搜索)
  RabbitMQ: 3.12.10 (消息队列)
  MinIO: 对象存储

架构模式:
  多模块Maven项目
  portal-start: 唯一启动模块
  portal-common: 公共组件
  portal-*: 业务模块
```

### 前端技术栈标准
```yaml
核心框架:
  Vue.js: 3.4.15
  Vite: 5.0.12
  TypeScript: 5.x (推荐)

UI组件:
  Element Plus: 2.4.4
  ECharts: 5.4.3
  Vue-ECharts: 6.6.0

状态管理:
  Pinia: 2.1.7
  Vue Router: 4.2.5

HTTP客户端:
  Axios: 1.6.2
```

## 📝 开发规范要求

### API设计规范
```yaml
URL规范:
  - 统一前缀: /api/v1/{module}
  - RESTful风格: GET/POST/PUT/DELETE
  - 资源命名: 复数形式 (users, tickets, engineers)

响应格式:
  - 统一返回: Result<T>
  - 成功: {success: true, data: T, message: ""}
  - 失败: {success: false, data: null, message: "错误信息"}

异常处理:
  - 业务异常: BusinessException
  - 认证异常: AuthenticationException
  - 授权异常: AuthorizationException
```

### 数据库设计规范
```yaml
命名规范:
  - 表名: lower_snake_case (ticket_comment)
  - 字段名: lower_snake_case (created_at)
  - 主键: id BIGINT
  - 外键: {table_name}_id

多租户支持:
  - 所有业务表必须包含: tenant_id BIGINT
  - 建立复合索引: (tenant_id, other_fields)
  - 自动过滤器拦截数据隔离

审计字段:
  - created_at TIMESTAMP
  - updated_at TIMESTAMP
  - created_by BIGINT (可选)
  - updated_by BIGINT (可选)
```

### 前端组件规范
```yaml
目录结构:
  src/views/{module}/: 页面组件
  src/components/: 公共组件
  src/api/: API封装
  src/stores/: 状态管理
  src/utils/: 工具函数

命名规范:
  - 组件: PascalCase (UserManagement.vue)
  - 文件: kebab-case (user-management.vue)
  - API文件: camelCase (userApi.ts)
  - Store文件: camelCase (userStore.ts)

Vue 3规范:
  - 使用Composition API
  - <script setup>语法
  - TypeScript类型定义
  - Props和Emits类型化
```

## 🧪 测试和验证规范

### 单元测试要求
```yaml
后端测试:
  - Service层测试覆盖率 > 80%
  - Repository层测试覆盖率 > 70%
  - Controller层集成测试
  - 使用@SpringBootTest和@MockBean

前端测试:
  - 组件单元测试 (Vue Test Utils)
  - API调用测试 (Mock)
  - 状态管理测试 (Pinia)
  - E2E测试 (Playwright/Cypress)
```

### 性能要求
```yaml
响应时间:
  - API响应时间 < 200ms (P95)
  - 页面加载时间 < 2秒
  - 搜索响应时间 < 1秒
  - 实时通知延迟 < 3秒

并发性能:
  - 支持1000并发用户
  - 数据库连接池优化
  - Redis缓存命中率 > 80%
  - 静态资源CDN加速
```

## 🔒 安全规范要求

### 认证授权
```yaml
认证机制:
  - JWT Token认证
  - Token过期时间: 24小时
  - Refresh Token: 7天
  - 多设备登录控制

权限控制:
  - RBAC权限模型
  - 资源级权限控制
  - API级权限验证
  - 前端路由权限守卫

数据安全:
  - 敏感数据加密存储
  - 传输层TLS 1.3加密
  - SQL注入防护
  - XSS攻击防护
```

## 📦 部署和运维规范

### 容器化部署
```yaml
开发环境:
  - Colima + Docker CLI
  - Docker Compose编排
  - 本地开发环境一键启动

生产环境:
  - Kubernetes部署
  - Helm Charts管理
  - 服务网格(Istio)可选
  - 自动扩缩容配置
```

### 监控和日志
```yaml
应用监控:
  - Spring Boot Actuator
  - Prometheus指标收集
  - Grafana可视化
  - 告警规则配置

日志管理:
  - 结构化日志(JSON格式)
  - ELK Stack日志分析
  - 分布式链路追踪
  - 审计日志记录
```

## 🚀 开发流程规范

### 代码提交规范
```yaml
分支策略:
  - main: 生产分支
  - develop: 开发集成分支
  - feature/*: 功能开发分支
  - hotfix/*: 紧急修复分支

提交信息:
  - feat: 新功能
  - fix: 修复bug
  - docs: 文档更新
  - style: 代码格式
  - refactor: 重构
  - test: 测试相关
```

### 质量保证
```yaml
代码审查:
  - 所有代码必须经过PR审查
  - 至少一名高级开发者审批
  - 自动化测试通过
  - 代码覆盖率检查

持续集成:
  - GitHub Actions自动构建
  - 单元测试自动执行
  - 代码质量检查(SonarQube)
  - 安全漏洞扫描
```

## 📈 项目里程碑

### 第一阶段（4周）- 基础平台
- ✅ REQ-001 基础架构与认证系统
- ✅ REQ-003 工单管理系统
- ✅ REQ-009 系统管理模块
- ✅ REQ-002 工作台与仪表板

### 第二阶段（4周）- 核心功能
- ✅ REQ-004 智能派单系统
- ✅ REQ-005 知识库管理系统
- ✅ REQ-006 工程师管理系统
- ✅ REQ-007 甲方管理与报表系统

### 第三阶段（3周）- 集成和增强
- ✅ REQ-010 通知与消息系统
- ✅ REQ-011 系统集成模块
- ✅ REQ-008 系统设置模块

### 第四阶段（3周）- 智能化和优化
- ✅ REQ-012 智能分析与AI功能
- ✅ REQ-013 工作流引擎系统
- ✅ REQ-014 用户体验增强系统

## 🎯 最终交付物

### 代码交付
- 完整的后端代码（Maven多模块项目）
- 完整的前端代码（Vue 3 + TypeScript）
- 数据库脚本（DDL + 初始化数据）
- 配置文件模板
- Docker部署文件

### 文档交付
- API文档（OpenAPI 3.0）
- 部署指南
- 用户操作手册
- 开发者文档
- 系统架构文档

### 测试交付
- 单元测试代码
- 集成测试用例
- 性能测试报告
- 安全测试报告
- 用户验收测试用例

---

**开发团队准备就绪，请确认从REQ-001基础架构与认证系统开始实施！**
