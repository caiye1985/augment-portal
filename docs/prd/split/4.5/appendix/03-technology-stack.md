# 附录C：技术栈与架构选型

## C.1 技术选型原则

| 原则 | 说明 | 权重 |
|------|------|------|
| 技术成熟度 | 选择经过生产环境验证的稳定技术 | 高 |
| 社区活跃度 | 优先选择社区活跃、文档完善的技术 | 高 |
| 团队熟悉度 | 考虑团队现有技术栈和学习成本 | 中 |
| 性能表现 | 满足系统性能和扩展性要求 | 高 |
| 维护成本 | 考虑长期维护和升级的便利性 | 中 |

## C.2 核心技术栈

### 后端技术栈
| 技术组件 | 版本 | 选择理由 | 备注 |
|----------|------|----------|------|
| **开发语言** | Java 17 | LTS版本，性能优异，生态成熟 | 支持最新语言特性 |
| **应用框架** | Spring Boot 3.2.11 | 企业级框架，开发效率高 | 内置多种starter |
| **安全框架** | Spring Security 6.x | 与Spring Boot深度集成 | 支持OAuth2、JWT |
| **数据访问** | Spring Data JPA 3.x | 简化数据库操作，支持多租户 | 配合Hibernate使用 |
| **主数据库** | PostgreSQL 15+ | 开源关系型数据库，支持JSON | 支持分区表、并行查询 |
| **缓存数据库** | Redis 7+ | 高性能内存数据库 | 支持集群模式 |
| **搜索引擎** | Elasticsearch 8.x | 全文搜索和日志分析 | 支持分布式部署 |
| **消息队列** | RabbitMQ 3.12+ | 可靠的消息传递 | 支持多种消息模式 |
| **文件存储** | MinIO | 兼容S3 API的对象存储 | 支持分布式部署 |

### 前端技术栈

| 技术组件 | 版本 | 选择理由 | 备注 |
|----------|------|----------|------|
| **开发框架** | Vue 3.4.15 | 组合式API，性能优异 | 支持TypeScript |
| **构建工具** | Vite 5.x | 快速的开发构建工具 | 支持热更新 |
| **UI组件库** | Element Plus 2.10.7 | 企业级UI组件库 | 与Vue 3兼容 |
| **状态管理** | Pinia 2.x | Vue 3官方推荐状态管理 | 替代Vuex |
| **路由管理** | Vue Router 4.x | Vue官方路由解决方案 | 支持动态路由 |
| **HTTP客户端** | Axios 1.x | 功能完善的HTTP库 | 支持拦截器 |


### Flutter 客户端完整技术栈要求（扩展版）

| 技术组件 | 版本 | 选择理由 | 备注 |
|----------|------|----------|------|
| **开发框架** | Flutter 3.19.x | 一套代码多端运行（iOS / Android / Web / Desktop），性能接近原生 | 基于 Dart 语言 |
| **语言版本** | Dart 3.x | 空安全（null safety）、现代化语法 | 官方长期支持 |
| **状态管理** | Riverpod 2.x | 灵活、类型安全，支持全局与局部状态管理 | 替代 Provider |
| **路由管理** | go_router 12.x | 声明式路由，支持深链接、路由守卫 | 官方推荐 |
| **网络请求** | Dio 5.x | 支持拦截器、FormData 上传、超时重试 | 主流 HTTP 库 |
| **本地持久化** | Hive 2.x | 轻量化、跨平台、支持数据加密 | 无需原生依赖 |
| **数据库** | Drift 2.x | 类型安全的 SQLite ORM 封装 | 支持 SQL 编译检查 |
| **依赖注入** | get_it 7.x | 简单高效的 IoC 容器 | 常用于解耦业务逻辑 |
| **UI扩展** | flutter_hooks / google_fonts / Lottie | 增强 UI 表现力，提升用户体验 | 可选 |
| **国际化** | flutter_localizations / intl 0.19.x | 官方国际化支持 | 支持多语言 |
| **状态机/流程控制** | flutter_bloc 8.x | 事件驱动 + 可预测状态流 | 适合复杂交互 |
| **测试框架** | flutter_test / mockito / integration_test | 单元测试、UI自动化测试 | 提高稳定性 |
| **代码规范** | dart_code_metrics | 统一代码风格，静态代码检查 | CI 阶段执行 |
| **构建与打包** | Flutter build / Fastlane | 自动化构建、签名、上传应用市场 | 支持多平台 |
| **热更新** | Flutter Hot Reload（开发期） / OTA（codepush 替代方案） | 缩短调试迭代时间 | 生产环境需遵守商店规则 |
| **持续集成** | GitHub Actions  / Codemagic | 自动化构建、测试、发布流程 | 支持多环境配置 |
| **调试与性能分析** | Flutter DevTools | 内存、帧率、网络、耗时分析 | 集成在 IDE 或浏览器 |
| **崩溃与日志监控** | Sentry | 实时错误上报与日志收集 | 多平台支持 |
| **数据统计** | Firebase Analytics / 埋点 SDK | 用户行为与事件追踪 | 支持可视化分析 |
| **接口文档管理** | swagger-codegen / OpenAPI | 统一管理接口，生成Dart API代码 | 提高开发效率 |

### 基础设施与运维

| 技术组件 | 版本 | 选择理由 | 备注 |
|----------|------|----------|------|
| **容器化** | Docker + Docker Compose | 标准化部署环境 | 开发环境使用Compose |
| **编排平台** | Kubernetes | 生产级容器编排 | 支持自动扩缩容 |
| **监控系统** | Prometheus + Grafana | 开源监控解决方案 | 支持自定义指标 |
| **日志系统** | ELK Stack | 集中化日志管理 | Elasticsearch + Logstash + Kibana |
| **API网关** | Spring Cloud Gateway | 统一API入口 | 支持限流、熔断 |
| **服务发现** | Consul | 服务注册与发现 | 支持健康检查 |

## C.3 开发与部署工具

### 开发工具
- **IDE**: IntelliJ IDEA / VS Code
- **版本控制**: Git + GitLab
- **构建工具**: Maven 3.9+ (后端), npm/pnpm (前端)
- **代码质量**: SonarQube + Checkstyle
- **API文档**: Swagger/OpenAPI 3.0

### CI/CD工具
- **持续集成**: GitLab CI / Jenkins
- **镜像仓库**: Harbor / GitLab Registry
- **部署工具**: Helm Charts + ArgoCD
- **测试工具**: JUnit 5 + Testcontainers

## C.4 技术架构说明

### 微服务架构
- 采用领域驱动设计（DDD）进行服务拆分
- 每个服务独立数据库，避免数据耦合
- 通过API网关统一对外提供服务

### 多租户架构
- 数据库级别的租户隔离
- 基于租户ID的数据访问控制
- 支持租户级别的配置定制

### 安全架构
- JWT令牌认证 + RBAC权限控制
- API级别的访问控制
- 数据传输加密（HTTPS/TLS）

参考：详细架构图见附录E《架构图表》
