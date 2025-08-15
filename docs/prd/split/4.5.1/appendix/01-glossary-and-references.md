# 附录A：术语表与参考文档 v4.5.1

## 版本更新说明

**v4.5.1版本更新：**
- 新增工程师管理相关术语定义
- 更新模块整合后的术语说明
- 补充技术架构相关术语

## A.1 术语表

### A.1.1 基础术语

| 术语 | 英文全称 | 中文定义 | 备注 |
|------|----------|----------|------|
| SLA | Service Level Agreement | 服务水平协议 | 定义服务提供商与客户之间的服务质量标准 |
| MTTR | Mean Time To Repair | 平均修复时间 | 系统故障后恢复正常运行的平均时间 |
| MTTF | Mean Time To Failure | 平均故障时间 | 系统连续无故障运行的平均时间 |
| MTBF | Mean Time Between Failures | 平均故障间隔时间 | 两次故障之间的平均时间间隔 |
| KPI | Key Performance Indicator | 关键绩效指标 | 衡量业务目标达成情况的量化指标 |
| API | Application Programming Interface | 应用程序编程接口 | 不同软件组件间的通信协议 |
| RBAC | Role-Based Access Control | 基于角色的访问控制 | 根据用户角色分配系统访问权限的安全模型 |
| ABAC | Attribute-Based Access Control | 基于属性的访问控制 | 根据用户、资源、环境属性进行访问控制 |
| SSO | Single Sign-On | 单点登录 | 用户一次登录即可访问多个相关系统 |
| MFA | Multi-Factor Authentication | 多因素认证 | 使用两个或更多验证因素的身份认证方法 |
| CMDB | Configuration Management Database | 配置管理数据库 | 存储IT基础设施配置信息的数据库 |
| ITSM | IT Service Management | IT服务管理 | 管理IT服务全生命周期的方法论 |
| DevOps | Development and Operations | 开发运维一体化 | 软件开发与运维协作的文化和实践 |
| CI/CD | Continuous Integration/Continuous Deployment | 持续集成/持续部署 | 自动化软件交付流水线 |

### A.1.2 业务术语

| 术语 | 英文全称 | 中文定义 | 备注 |
|------|----------|----------|------|
| 租户 | Tenant | 租户 | 多租户系统中的独立业务实体 |
| 工单 | Ticket | 工单 | 记录和跟踪服务请求或问题的标准化表单 |
| 派单 | Dispatch | 派单 | 将工单分配给合适工程师的过程 |
| 智能派单 | Intelligent Dispatch | 智能派单 | 基于AI算法自动分配工单的技术 |
| 工程师 | Engineer | 工程师 | 负责处理IT运维任务的技术人员 |
| 技能匹配 | Skill Matching | 技能匹配 | 根据工程师技能与工单需求进行匹配的过程 |
| 排班 | Scheduling | 排班 | 安排工程师工作时间和任务的管理活动 |
| 绩效评估 | Performance Evaluation | 绩效评估 | 对工程师工作表现进行量化评价的过程 |
| 360度反馈 | 360-Degree Feedback | 360度反馈 | 从多个角度收集员工表现反馈的评估方法 |

### A.1.3 技术术语（v4.5.1新增）

| 术语 | 英文全称 | 中文定义 | 备注 |
|------|----------|----------|------|
| 微服务 | Microservices | 微服务 | 将应用程序构建为一组小型、独立服务的架构模式 |
| 容器化 | Containerization | 容器化 | 使用容器技术打包和部署应用程序的方法 |
| 负载均衡 | Load Balancing | 负载均衡 | 在多个服务器间分配工作负载的技术 |
| 缓存策略 | Caching Strategy | 缓存策略 | 提高系统性能的数据存储和访问优化方法 |
| 数据脱敏 | Data Masking | 数据脱敏 | 隐藏敏感数据真实值的安全技术 |
| 事件驱动 | Event-Driven | 事件驱动 | 基于事件产生和消费的系统架构模式 |
| 消息队列 | Message Queue | 消息队列 | 异步通信的中间件技术 |
| 分布式锁 | Distributed Lock | 分布式锁 | 在分布式系统中实现互斥访问的机制 |
| 熔断器 | Circuit Breaker | 熔断器 | 防止系统级联故障的保护机制 |
| 限流 | Rate Limiting | 限流 | 控制系统访问频率的保护机制 |

### A.1.4 业务指标术语

| 术语 | 英文全称 | 中文定义 | 备注 |
|------|----------|----------|------|
| CAC | Customer Acquisition Cost | 客户获取成本 | 获得一个新客户所需的平均成本 |
| LTV | Lifetime Value | 客户生命周期价值 | 客户在整个关系期间的总价值 |
| NPS | Net Promoter Score | 净推荐值 | 衡量客户忠诚度和满意度的指标 |
| ARPU | Average Revenue Per User | 用户平均收入 | 每个用户产生的平均收入 |
| MRR | Monthly Recurring Revenue | 月度经常性收入 | 每月可预期的重复收入 |
| ARR | Annual Recurring Revenue | 年度经常性收入 | 每年可预期的重复收入 |
| 流失率 | Churn Rate | 流失率 | 客户停止使用服务的比例 |
| 续约率 | Renewal Rate | 续约率 | 客户续签合同的比例 |

## A.2 工程师管理术语详解（v4.5.1新增）

### A.2.1 技能管理相关

| 术语 | 定义 | 应用场景 |
|------|------|----------|
| 技能认证 | 对工程师专业技能的正式确认和证明 | 技能评估、派单匹配 |
| 技能等级 | 工程师在特定技能领域的熟练程度分级 | 1-初级，2-中级，3-高级，4-专家，5-大师 |
| 技能图谱 | 展示工程师技能分布和发展路径的可视化图表 | 人才发展规划 |
| 技能匹配度 | 工程师技能与工单需求的符合程度 | 智能派单算法 |
| 技能差距分析 | 识别工程师当前技能与目标技能的差距 | 培训需求分析 |

### A.2.2 排班管理相关

| 术语 | 定义 | 应用场景 |
|------|------|----------|
| 班次类型 | 工作时间段的分类 | day-白班，night-夜班，standby-待命，oncall-值班 |
| 排班冲突 | 排班安排中出现的时间、资源或规则冲突 | 自动检测和解决 |
| 工作负载 | 工程师当前承担的工作量 | 负载均衡算法 |
| 排班覆盖率 | 时间段内有工程师值班的比例 | 服务质量保障 |
| 自动排班 | 基于算法自动生成排班计划的功能 | 提升排班效率 |

### A.2.3 绩效评估相关

| 术语 | 定义 | 应用场景 |
|------|------|----------|
| 工单完成率 | 工程师完成工单数量与分配工单数量的比例 | 效率评估 |
| 一次解决率 | 工单在首次处理时就得到解决的比例 | 技能水平评估 |
| 客户满意度 | 客户对工程师服务质量的评价分数 | 服务质量评估 |
| SLA达成率 | 工程师处理工单符合SLA要求的比例 | 合规性评估 |
| 绩效等级 | 基于综合评估的工程师表现分级 | 优秀、良好、合格、待改进 |

## A.3 参考文档

### A.3.1 技术文档

- IT运维门户系统技术架构文档 v4.5.1
- 数据库设计规范 v2.0
- API接口设计规范 v3.0
- 安全设计规范 v2.0
- 测试规范文档 v1.5
- 多租户架构设计指南 v1.2
- 微服务部署运维手册 v2.0

### A.3.2 业务文档

- IT运维门户系统产品需求文档 v4.5.1
- 工程师管理业务流程规范 v1.0
- 智能派单算法设计文档 v1.0
- 绩效评估体系设计文档 v1.0
- 客户服务标准操作手册 v2.0

### A.3.3 标准规范

- ISO/IEC 20000 IT服务管理标准
- ITIL v4 IT服务管理最佳实践
- COBIT 2019 企业IT治理框架
- ISO 27001 信息安全管理体系
- GDPR 通用数据保护条例
- 《个人信息保护法》合规指南

### A.3.4 开源项目参考

- Spring Boot 3.2.11 官方文档
- Vue.js 3.4.15 官方文档
- PostgreSQL 15.5 官方文档
- Redis 7.2.4 官方文档
- Elasticsearch 8.15.3 官方文档
- Docker 24.0.7 官方文档
- Kubernetes 1.28 官方文档

## A.4 缩略语对照表

| 缩略语 | 英文全称 | 中文名称 |
|--------|----------|----------|
| PRD | Product Requirements Document | 产品需求文档 |
| ERD | Entity Relationship Diagram | 实体关系图 |
| UML | Unified Modeling Language | 统一建模语言 |
| REST | Representational State Transfer | 表述性状态转移 |
| JSON | JavaScript Object Notation | JavaScript对象表示法 |
| XML | eXtensible Markup Language | 可扩展标记语言 |
| HTTP | HyperText Transfer Protocol | 超文本传输协议 |
| HTTPS | HTTP Secure | 安全超文本传输协议 |
| TLS | Transport Layer Security | 传输层安全协议 |
| JWT | JSON Web Token | JSON网络令牌 |
| CRUD | Create, Read, Update, Delete | 创建、读取、更新、删除 |
| ORM | Object-Relational Mapping | 对象关系映射 |
| MVC | Model-View-Controller | 模型-视图-控制器 |
| MVP | Model-View-Presenter | 模型-视图-展示器 |
| MVVM | Model-View-ViewModel | 模型-视图-视图模型 |

## A.5 版本历史

| 版本 | 日期 | 主要变更 | 变更人 |
|------|------|----------|--------|
| v4.5.1 | 2025-08-14 | 新增工程师管理术语，更新技术术语 | 产品团队 |
| v4.5 | 2025-01-01 | 初始版本，基础术语定义 | 产品团队 |

参考：详细的技术实现和业务流程见各模块PRD文档和技术架构文档。
