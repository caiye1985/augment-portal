## 任务：初始化 IT运维门户系统后端开发PRD文档

### 背景与目标
为IT运维门户系统的所有模块创建标准化的后端开发PRD文档框架。这些文档将作为后端开发的详细指导，确保所有模块在技术架构、代码规范、数据设计等方面保持一致性。

### 前置要求
1. **参考文档**：
   - 全局上下文：`$GLOBAL_FILE`
   - 技术栈规范：`docs/prd/split/$VERSION/appendix/03-technology-stack.md`
   - 架构设计：`docs/prd/split/$VERSION/appendix/05-architecture-diagrams.md`
   - 开发优先级：`docs/prd/split/$VERSION/appendix/02-development-priorities.md`

2. **技术约束**：
   - Spring Boot 3.3.6 + Spring Security + Spring Data JPA
   - PostgreSQL 16.6 数据库
   - Redis 7.4.1 缓存
   - 多租户架构支持
   - 微服务架构模式

### 实现步骤

#### Step 1：创建标准化PRD框架
为每个需要后端开发的模块生成 `docs/ai_prd/$VERSION/backend/{MODULE_ID}-backend-prd.md`，包含以下标准结构：

1. **模块概述**
   - 业务价值和技术目标
   - 在整体架构中的定位
   - 与其他模块的关系

2. **技术架构设计**
   - 分层架构（Controller/Service/Repository）
   - 核心业务逻辑设计
   - 数据访问层设计
   - 缓存策略

3. **数据模型设计**
   - 实体类设计（JPA Entity）
   - 数据库表结构
   - 索引设计
   - 多租户数据隔离

4. **API接口设计**
   - RESTful API端点
   - 请求/响应模型（DTO）
   - 参数验证规则
   - 异常处理机制

5. **安全与权限**
   - 认证授权机制
   - 数据权限控制
   - 敏感数据处理
   - 审计日志

6. **性能与优化**
   - 查询优化策略
   - 缓存使用方案
   - 异步处理设计
   - 监控指标

7. **测试策略**
   - 单元测试覆盖
   - 集成测试方案
   - 性能测试要求
   - Mock数据准备

#### Step 2：统一技术规范
- 严格遵循Spring Boot最佳实践
- 统一异常处理和日志记录
- 标准化的代码结构和命名规范
- 一致的配置管理和环境隔离

#### Step 3：质量标准
- 代码覆盖率要求 ≥ 80%
- 接口响应时间 ≤ 500ms
- 支持并发用户数 ≥ 1000
- 数据一致性和事务完整性

### 输出要求
1. **文档结构**：
   - 使用统一的Markdown模板
   - 按模块ID命名：`{MODULE_ID}-backend-prd.md`
   - 包含完整的占位符和示例

2. **内容质量**：
   - 技术方案具体可执行
   - 包含必要的代码示例
   - 明确的验收标准
   - 详细的实施步骤
