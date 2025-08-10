# IT运维门户系统

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://openjdk.java.net/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.11-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Vue](https://img.shields.io/badge/Vue-3.4.15-4FC08D.svg)](https://vuejs.org/)
[![Colima](https://img.shields.io/badge/Colima-Ready-blue.svg)](https://github.com/abiosoft/colima)

基于Spring Boot 3 + Vue 3的现代化IT运维门户系统，支持多租户架构、智能派单算法和完整的工单生命周期管理。

## 🎯 项目概述

IT运维门户系统是一个面向企业的多租户运维服务平台，旨在提高IT运维效率，优化资源配置，提升客户满意度。系统采用现代化的技术架构，提供智能化的工单管理、自动化的派单算法和完整的运维流程支持。

### 📊 当前项目状态 (2025年7月)



### 核心特性

- 🏢 **多租户架构**: 支持多个客户独立使用，数据安全隔离
- 🔐 **二段式登录**: 身份识别 → 身份验证，支持多种登录方式
- 🤖 **智能派单算法**: 基于多因素权重的自动派单系统
- 📋 **完整工单管理**: 从创建到关闭的全生命周期管理
- 🏷️ **分类管理系统**: 支持层级分类管理，工单分类自动化
- 👥 **协作系统**: 评论、内部备注、工时跟踪
- 📊 **数据分析**: 实时统计、SLA监控、绩效分析
- 🔐 **权限控制**: 基于RBAC的细粒度权限管理
- 📱 **响应式设计**: 支持PC、平板、手机多端访问
- 🔧 **集成能力**: 支持监控系统、资产管理系统集成

## 📋 开发规范

### 🏗️ 架构规范
本项目严格遵循统一的架构规范和编码约束，确保代码质量和系统一致性：

- **📖 架构规范文档**: [Portal项目架构规范与编码约束]
- **🔒 强制性要求**: 所有代码提交必须符合规范要求
- **🤖 自动化检查**: 通过Maven Enforcer、Checkstyle、Git Hooks等工具自动验证
- **👥 代码审查**: 每个PR都需要通过架构规范检查清单

### 核心规范要点
- **数据库**: 支持PostgreSQL、MySQL
- **数据访问**: 统一使用Spring Data JPA，禁止MyBatis
- **响应格式**: 统一使用`Result<T>`，禁止`R`、`AjaxResult`
- **异常处理**: 统一使用`BusinessException`体系
- **数据类型**: `tenantId`和`userId`必须使用`Long`类型
- **时间处理**: 统一使用`LocalDateTime`

## 🏗️ 项目架构

### 模块化架构
项目采用Maven多模块架构，按业务功能划分为13个Maven子模块和1个独立前端项目、1个前端模型项目：

```
ops-portal/
├── portal-common/       # 公共模块 (工具类、实体类、配置)
├── portal-auth/         # 认证与权限系统 (JWT、OIDC、用户管理)
├── portal-tenant/       # 租户管理系统 (租户管理、租户类型、授权管理、IT站点管理、公司自定义配置）
├── portal-system/       # 系统管理模块 (用户、部门、权限管理)
├── portal-dispatch/     # 智能派单系统 (派单算法、工程师匹配)
├── portal-ticket/       # 工单管理系统 (工单CRUD、状态流转、转知识库)
├── portal-integration/  # 系统集成模块 (第三方系统集成)
├── portal-knowledge/    # 知识库管理系统 (文档、FAQ)
├── portal-client/       # 甲方管理与报表系统 (客户管理、报表)
├── portal-performance/  # 运维考核与绩效管理 (KPI、考核)
├── portal-notification/ # 通知与消息系统 (邮件、短信、推送)
├── portal-ai/           # 智能分析与AI功能 (AI分析、预测)
├── portal-start/        # 🎯 Web应用启动模块 (Spring Boot主应用)
├── portal-frontend/     # 前端应用 (Vue3独立项目)
└── portal-prototype/    # 前端原型 (功能演示)
```

### ⚠️ 重要说明：模块职责划分

#### 🎯 主应用模块 (portal-start)
- **作用**: Spring Boot主应用，包含主启动类和应用配置
- **职责**:
  - 应用程序入口点 (`@SpringBootApplication`)
  - 全局配置和Bean定义
  - 依赖其他业务模块
  - 提供统一的Web服务端点
- **启动方式**: `cd portal-start && mvn spring-boot:run`

#### 📦 业务模块 (portal-*)
- **作用**: 独立的业务功能模块，不包含主应用代码
- **职责**:
  - 提供特定业务功能的Controller、Service、Repository
  - 定义业务实体和DTO
  - 实现业务逻辑和数据访问
  - 被portal-start模块依赖和集成
- **注意**: ⚠️ 业务模块不应包含`@SpringBootApplication`主启动类

#### 🔧 公共模块 (portal-common)
- **作用**: 提供通用工具类、配置和基础组件
- **职责**:
  - 通用工具类和常量定义
  - 基础实体类和DTO
  - 通用配置类和注解
  - 异常处理和响应格式定义

### 后端技术栈
- **框架**: Spring Boot 3.2.11 (LTS)
- **安全**: Spring Security 6.2.1 + JWT + OIDC Provider
- **数据库**: PostgreSQL 15.5 + Spring Data JPA
- **缓存**: Redis 7.2.4
- **消息队列**: RabbitMQ 3.12.10
- **搜索引擎**: Elasticsearch 8.15.3
- **文件存储**: MinIO
- **文档**: Swagger/OpenAPI 3
- **构建**: Maven 3.9.6
- **JDK**: OpenJDK 17 LTS

### 前端技术栈
- **框架**: Vue 3.4.15 + JavaScript
- **构建**: Vite 5.0.12
- **UI库**: Element Plus 2.4.4
- **状态管理**: Pinia 2.1.7
- **路由**: Vue Router 4.2.5
- **图表**: ECharts 5.4.3 + Vue-ECharts 6.6.0
- **HTTP**: Axios 1.6.2

### 基础设施
- **容器化**: Colima + Docker CLI (推荐) / Podman (备选)
- **反向代理**: Nginx
- **监控**: Prometheus + Grafana
- **CI/CD**: GitHub Actions
- **部署**: Docker Compose

## 🚀 快速开始

### 环境要求
- Java 17+ (OpenJDK 17 LTS推荐)
- Maven 3.9.6+
- Node.js 20+ (LTS版本)
- Colima + Docker CLI (推荐) 或 Podman
- PostgreSQL 15.5+ (可选，容器提供)
- Redis 7.2+ (可选，容器提供)

### 🆕 登录界面更新
本项目已完成登录界面的重大更新，实现了二段式登录流程：

#### 新增功能
- **二段式登录**：身份识别 → 身份验证
- **多种登录方式**：密码、短信验证码、邮箱验证码
- **租户发现**：自动识别用户可访问的租户
- **图形验证码**：增强安全性
- **安全增强**：登录失败锁定、IP白名单、设备指纹

#### 演示账号
- **系统管理员**：admin / 123456
- **租户管理员**：alibaba_admin / 123456
- **甲方用户**：client_user / 123456
- **运维工程师**：engineer1 / 123456

#### 访问地址
- **前端界面**：http://localhost:3001/login
- **API文档**：http://localhost:8080/swagger-ui.html

### 一键启动开发环境

```bash
# 克隆项目
git clone https://github.com/caiye1985/new-portal.git
cd new-portal

# 🚀 自动化开发计划执行
./start-development.sh

# 选择执行模式：
# 1. 仅编译修复 (1-2小时)
# 2. 完整6周开发计划 (自动化执行)
# 3. Git自动化提交和PR创建
# 4. 查看项目状态
# 5. 环境检查

# 或传统方式启动开发环境
./scripts/dev-start.sh
```

## 🤖 自动化开发脚本

基于系统性功能验收与开发规划，我们提供了完整的自动化开发脚本：

### 核心脚本
- **`./start-development.sh`** - 主入口脚本，提供5种执行模式
- **`./scripts/setup-and-compile.sh`** - 编译修复和环境设置
- **`./scripts/git-automation.sh`** - 自动提交代码和创建PR
- **`./scripts/auto-execute-plan.sh`** - 执行完整6周开发计划

### 自动化能力
- ✅ **编译修复**: 自动修复已知的编译错误
- ✅ **环境设置**: 自动安装Java、Maven等依赖
- ✅ **代码提交**: 自动创建分支、提交代码、创建PR
- ✅ **功能开发**: 按6周计划自动实现功能模块
- ✅ **进度跟踪**: 实时跟踪开发进度和完成度

### 手动启动

#### 1. 启动基础设施服务
```bash
docker-compose up -d postgres redis elasticsearch rabbitmq minio
```

#### 2. 构建项目
```bash
./scripts/build.sh
```

#### 3. 启动后端 (⚠️ 重要：只能从portal-start启动)
```bash
# 正确的启动方式 - 从主应用模块启动
cd portal-start
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# ❌ 错误的启动方式 - 不要从业务模块启动
# cd portal-auth && mvn spring-boot:run    # 错误！
# cd portal-system && mvn spring-boot:run  # 错误！
# cd portal-ticket && mvn spring-boot:run  # 错误！
```

**说明**:
- ✅ portal-start是唯一的主应用模块，包含`@SpringBootApplication`启动类
- ❌ 其他portal-*模块都是业务模块，不能独立启动
- 🔧 所有业务模块通过portal-start的依赖管理自动加载

#### 4. 启动前端
```bash
cd portal-frontend
pnpm install
pnpm run dev
```

#### 5. 访问应用
- **前端应用**: http://localhost:3000
- **后端API**: http://localhost:8080
- **API文档**: http://localhost:8080/swagger-ui.html
- **数据库**: localhost:5432 (portal/portal123)
- **Redis**: localhost:6379
- **Elasticsearch**: http://localhost:9200
- **RabbitMQ管理**: http://localhost:15672 (portal/portal123)
- **MinIO管理**: http://localhost:9001 (portal/portal123)

### Docker部署

#### 一键部署
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

#### 手动部署
```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

详细部署说明请参考 [DEPLOYMENT.md](DEPLOYMENT.md)

## 📚 功能模块

### 1. 认证与用户管理
- **二段式登录**: 身份识别 → 身份验证的安全登录流程
- **多种登录方式**: 密码登录、短信验证码、邮箱验证码
- **租户发现**: 自动识别用户可访问的租户
- **多角色支持**: 超级管理员、系统管理员、运维管理员、运维工程师、甲方用户
- **权限控制**: 基于RBAC的细粒度权限管理
- **工程师管理**: 技能标签、等级、工作负载、地理位置配置
- **安全增强**: 图形验证码、登录状态记忆、设备指纹识别

### 2. 工单管理
- **工单创建**: 支持多种工单类型和优先级
- **状态流转**: open → assigned → in_progress → resolved → closed
- **智能派单**: 基于技能、负载、位置的自动分配算法
- **协作功能**: 评论、内部备注、解决方案记录
- **SLA监控**: 响应时间、解决时间跟踪

### 3. 智能派单
- **多因素算法**: 技能匹配(40%) + 工作负载(30%) + 地理位置(20%) + 技能等级(10%)
- **候选推荐**: 智能推荐最合适的工程师
- **负载均衡**: 自动平衡工程师工作负载
- **手动分配**: 支持管理员手动指定工程师

### 4. 租户管理
- **多租户隔离**: 数据安全隔离，权限独立管理
- **SLA配置**: 个性化的服务等级协议
- **集成配置**: 监控系统、资产管理系统集成

### 5. 报表分析
- **实时统计**: 工单数量、状态分布、处理效率
- **SLA报表**: 响应时间、解决时间、达成率分析
- **绩效分析**: 工程师工作量、客户满意度统计
- **趋势分析**: 运维趋势、问题分类分析

## 🏗️ 架构设计详解

### Maven模块依赖关系

```
portal-start (主应用)
├── portal-common (公共模块)
├── portal-auth (认证模块)
├── portal-system (系统管理)
├── portal-ticket (工单管理)
├── portal-dispatch (智能派单)
├── portal-integration (系统集成)
├── portal-knowledge (知识库)
├── portal-client (甲方管理)
├── portal-performance (绩效管理)
├── portal-notification (通知系统)
└── portal-ai (AI功能)
```

### 模块启动规则

| 模块类型 | 启动方式 | 说明 |
|---------|---------|------|
| **portal-start** | ✅ `mvn spring-boot:run` | 主应用，唯一可启动的模块 |
| **portal-common** | ❌ 不可启动 | 公共依赖库，被其他模块引用 |
| **portal-auth** | ❌ 不可启动 | 业务模块，通过portal-start加载 |
| **portal-system** | ❌ 不可启动 | 业务模块，通过portal-start加载 |
| **portal-ticket** | ❌ 不可启动 | 业务模块，通过portal-start加载 |
| **portal-dispatch** | ❌ 不可启动 | 业务模块，通过portal-start加载 |
| **其他业务模块** | ❌ 不可启动 | 业务模块，通过portal-start加载 |

### 开发和调试指南

#### ✅ 正确的开发流程
1. **修改业务模块代码** (如portal-auth、portal-ticket等)
2. **从portal-start启动应用** (`cd portal-start && mvn spring-boot:run`)
3. **测试功能** (访问http://localhost:8080)

#### ❌ 常见错误
- 尝试从业务模块启动应用
- 在业务模块中添加`@SpringBootApplication`注解
- 在业务模块中配置主应用相关的配置

#### 🔧 模块开发规范
- **业务模块**: 只包含Controller、Service、Repository、Entity等业务代码
- **主应用模块**: 只包含启动类、全局配置、依赖管理
- **公共模块**: 只包含工具类、通用配置、基础组件

## 🔧 开发指南

### 项目结构
```
new-portal/
├── src/main/java/com/portal/          # 后端源码
│   ├── auth/                          # 认证模块
│   ├── user/                          # 用户管理
│   ├── ticket/                        # 工单管理
│   ├── tenant/                        # 租户管理
│   └── common/                        # 公共组件
├── frontend/                          # 前端源码
│   ├── src/
│   │   ├── api/                       # API接口
│   │   ├── components/                # 公共组件
│   │   ├── views/                     # 页面组件
│   │   ├── stores/                    # 状态管理
│   │   └── utils/                     # 工具函数
├── scripts/                           # 脚本文件
├── docker/                            # Docker配置
└── docs/                              # 文档
```

### 开发规范
- **后端**: 遵循Spring Boot最佳实践，使用分层架构
- **前端**: 使用Vue 3 Composition API，组件化开发
- **数据库**: 遵循数据库设计规范，合理使用索引
- **API**: RESTful设计，统一响应格式
- **代码**: 遵循阿里巴巴Java开发手册

### 贡献指南
1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 📊 性能指标

### 系统性能
- **响应时间**: API平均响应时间 < 200ms
- **并发支持**: 支持1000+并发用户
- **数据处理**: 支持百万级工单数据
- **可用性**: 99.9%系统可用性

### 业务指标
- **派单准确率**: 智能派单准确率 > 90%
- **处理效率**: 工单平均处理时间减少30%
- **客户满意度**: 客户满意度 > 95%
- **资源利用率**: 工程师资源利用率提升25%

## 🔒 安全特性

- **认证授权**: JWT Token + RBAC权限控制
- **数据加密**: 敏感数据加密存储
- **SQL注入防护**: 使用参数化查询
- **XSS防护**: 输入输出过滤和转义
- **CSRF防护**: CSRF Token验证
- **审计日志**: 完整的操作审计跟踪

## 部署说明

### 开发环境
使用Docker Compose一键启动所有依赖服务：
```bash
docker-compose -f docker-compose.dev.yml up -d
```

### 测试环境
```bash
# 构建应用镜像
mvn clean package -Dmaven.test.skip=true
docker build -t portal:latest .

# 部署到测试环境
docker-compose -f docker-compose.test.yml up -d
```

### 生产环境
```bash
# 使用生产配置
mvn clean package -Pprod
docker build -t portal:prod .

# 部署到生产环境（需要配置生产环境参数）
docker-compose -f docker-compose.prod.yml up -d
```

## 📈 开发路线图

### 📊 当前状态 (v1.0 - 85%完成)
基于系统性功能验收，当前项目状态：
- ✅ **P0核心功能**: 92%完成 (认证、工单、仪表板、工程师管理)
- 🔄 **P1重要功能**: 81%完成 (系统管理、通知、集成)
- 🔄 **P2扩展功能**: 50%完成 (AI分析、工作流)

### 📋 详细验收文档
- 📊 **[系统性功能验收与开发规划报告](Portal项目系统性功能验收与开发规划报告.md)**
- 📅 **[开发任务清单与时间规划](Portal项目开发任务清单与时间规划.md)**
- ✅ **[功能验收检查清单](Portal项目功能验收检查清单.md)**

### 🎯 近期里程碑 (6周计划)

#### 第1-2周: 编译修复与P0完善
- [ ] 修复portal-dispatch、portal-start编译问题
- [ ] 完善智能派单算法和知识库审核流程
- [ ] 目标: P0功能完整度达到98%

#### 第3-4周: P1功能开发
- [ ] 通知系统前端集成和消息中心
- [ ] 工作流可视化设计器
- [ ] 系统集成监控功能
- [ ] 目标: P1功能完整度达到95%

#### 第5-6周: AI功能与优化
- [ ] AI分析独立模块和智能问答
- [ ] 性能优化和安全加固
- [ ] 生产环境部署准备
- [ ] 目标: 整体功能完整度达到96%

### v1.1.0 (2025年Q4)
- [ ] 移动端应用
- [ ] 微信/钉钉集成
- [ ] 高级报表功能
- [ ] 多语言支持

### v2.0.0 (2026年Q1)
- [ ] 云原生部署
- [ ] 大数据分析
- [ ] IoT设备管理
- [ ] 边缘计算支持

## 🤝 社区

- **GitHub**: [https://github.com/caiye1985/new-portal](https://github.com/caiye1985/new-portal)
- **Issues**: [提交问题和建议](https://github.com/caiye1985/new-portal/issues)
- **Discussions**: [参与讨论](https://github.com/caiye1985/new-portal/discussions)

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者和用户。

---

**注意**: 这是一个开源项目，仅供学习和研究使用。在生产环境中使用前，请确保进行充分的测试和安全评估。
