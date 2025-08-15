## 任务：生成 AI开发助手专用的模块API规范文档

### 背景与目标
为AI开发助手生成结构化、标准化的OpenAPI规范文档。此文档专门设计为AI可解析的格式，包含完整的API定义、数据模型和验证规则。采用迭代式处理方式，每次专注1-2个模块，确保AI能够基于此规范生成高质量的API实现代码和Mock Server配置。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`docs/global-context.md`
   - Mock 数据规范：`docs/prd/split/4.5.1/globals/05-mock-data-guidelines.md`
   - 当前模块 PRD：`docs/prd/split/4.5.1/modules/REQ-003.md`
   - API 初始化合并文件：`docs/api/4.5.1/global-api-index.yaml`
   - 技术栈规范：`docs/prd/split/4.5.1/appendix/03-technology-stack.md`
   - 业务流程文档：`docs/prd/split/4.5.1/globals/04-business-processes.md`
   - 术语表：`docs/prd/split/4.5.1/appendix/01-glossary-and-references.md`

2. **技术约束**：
   - 严格遵循 OpenAPI 3.0.3 规范
   - swagger-cli validate 必须通过
   - 遵循三级分离引用，不重复定义全局/域已有内容
   - 技术栈契合：Spring Boot 3.3.6 + Spring Security + Spring Data JPA
   - 支持多租户数据隔离
   - 符合RESTful设计原则

### 实现步骤

#### Step 1：深度需求分析与API设计
1. **显性功能提取**：
   - 仔细分析模块PRD中的功能需求表
   - 提取每个功能点对应的API操作
   - 识别数据模型和业务实体

2. **隐性接口推导**：
   - **查询接口**：列表查询、详情查询、条件筛选、模糊搜索
   - **批量操作**：批量创建、批量更新、批量删除、批量状态变更
   - **导出功能**：Excel导出、PDF报告、数据备份
   - **状态流转**：工作流状态变更、审批流程、状态回滚
   - **统计分析**：数据统计、趋势分析、报表生成
   - **关联操作**：关联查询、级联更新、依赖检查

3. **业务流程映射**：
   - 结合全局业务流程文档，识别跨模块交互点
   - 设计流程中的关键节点API
   - 考虑异常处理和补偿机制

4. **端点清单设计**：
   创建详细的API端点清单表，包含：
   - HTTP方法和路径
   - 功能简述和业务价值
   - 请求参数（路径参数、查询参数、请求体）
   - 响应模型和状态码
   - 业务域标签分组
   - 权限要求和安全级别

#### Step 2：编写 OpenAPI 模块文件
**路径**：`docs/api/4.5.1/modules/REQ-003-工单管理系统/openapi.yaml`

必须包含：
1. `info` 节点（title、version 与 `global-api-index.yaml` 一致）。
2. `tags` 节点（模块标签及描述）。
3. `paths`：  
   - 所有路径以业务域前缀开头（例如 `/api/v1/tickets/...`）  
   - 每个方法包含`summary`、`description`、`operationId`、`parameters`、`requestBody`、`responses`。  
   - operationId 命名规则：`<domain>_<action>`（小写_分隔，动词用英文现在时）。
4. `components.schemas`：  
   - 仅定义**模块独有**的 schema
   - 引用全局或域定义，使用 `$ref: '../global-api-index.yaml#/components/schemas/...'` 或 `$ref: '../domains/{domain}.yaml#/components/schemas/...'`。
5. 响应：
   - **成功响应**（`200`）引用全局 `ApiResponse` 或 `PagedResponse`。
   - **错误响应**（`400` / `401` / `403` / `404` / `409` / `500`）必须引用全局标准错误响应模型。

#### Step 3：数据与示例要求
1. 所有 schema 字段必须严格匹配类型要求。
2. 枚举完整列出所有值，每个值要有清晰意义描述。
3. 所有字段包含符合 Mock 数据规范的 `example` 值。
4. 所有时间字段统一 ISO8601 UTC 格式（例如 `2024-01-15T10:30:00Z`），便于数据库存储和国际化支持。前端可根据用户时区进行本地化显示。

#### Step 4：校验与质量控制
1. swagger-cli validate 必须通过。
2. 所有 `$ref` 路径必须可解析且有效。
3. tag 分类正确（与 domain 文件一致）。
4. 覆盖率检测：确认 PRD 列出的功能接口均有定义。
5. 确保 Mock Server 可直接运行。

#### Step 5：HTTP 方法语义约束
- `GET`：查询资源（列表/详情）
- `POST`：新增资源
- `PUT`：全量更新
- `PATCH`：部分更新
- `DELETE`：删除
- `OPTIONS`：跨域预检（如需）
- `HEAD`：获取元信息（如需）

### 输出要求
1. 输出完整的 `docs/api/4.5.1/modules/REQ-003-工单管理系统/openapi.yaml` 文件内容。
2. 不包含全局/域级 schema 的重复定义。
3. 所有示例数据必须符合 Mock 数据规范，贴合 IT运维业务语境。
4. 文件可独立通过 swagger-cli validate。

### 验证命令
```bash
swagger-cli validate docs/api/4.5.1/modules/REQ-003-工单管理系统/openapi.yaml
