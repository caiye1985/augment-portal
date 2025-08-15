## 任务：生成 AI开发助手专用的模块API规范文档

### 背景与目标
为AI开发助手生成结构化、标准化的OpenAPI规范文档。此文档专门设计为AI可解析的格式，包含完整的API定义、数据模型和验证规则。采用迭代式处理方式，每次专注1-2个模块，确保AI能够基于此规范生成高质量的API实现代码和Mock Server配置。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`docs/global-context.md`
   - Mock 数据规范：`docs/prd/split/4.5.1/globals/05-mock-data-guidelines.md`
   - 当前模块 PRD：`docs/prd/split/4.5.1/modules/REQ-008.md`
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
   - **引用路径规范**：使用正确的JSON Pointer语法，确保所有``引用的路径在目标文件中真实存在
   - **Mock Server兼容**：生成的API文档必须能够与Prism CLI等Mock工具正常启动

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
**路径**：`docs/api/4.5.1/modules/REQ-008-系统设置/openapi.yaml`

必须包含：
1. `info` 节点（title、version 与 `global-api-index.yaml` 一致）。
2. `tags` 节点（模块标签及描述）。
3. `paths`：
   - 所有路径以业务域前缀开头（例如 `/api/v1/tickets/...`、`/api/v1/customers/...`、`/api/v1/auth/...`）
   - 每个方法包含`summary`、`description`、`operationId`、`parameters`、`requestBody`、`responses`。
   - operationId 命名规则：`<domain>_<action>`（小写_分隔，动词用英文现在时）。
   - **路径命名规范**：使用具体的API路径，避免抽象的模块级路径（如`/基础架构模块`）
4. `components.schemas`：
   - 仅定义**模块独有**的 schema
   - 引用全局或域定义，使用 `: '../../global-api-index.yaml#/components/schemas/...'` 或 `: '../domains/{domain}.yaml#/components/schemas/...'`。
   - **引用路径验证**：确保所有引用的schema在目标文件中确实存在
5. 响应：
   - **成功响应**（`200`）引用全局 `ApiResponse` 或 `PagedResponse`。
   - **错误响应**（`400` / `401` / `403` / `404` / `409` / `500`）必须引用全局标准错误响应模型。

#### Step 3：数据与示例要求
1. 所有 schema 字段必须严格匹配类型要求。
2. 枚举完整列出所有值，每个值要有清晰意义描述。
3. 所有字段包含符合 Mock 数据规范的 `example` 值。
4. 所有时间字段统一 ISO8601 UTC 格式（例如 `2024-01-15T10:30:00Z`），便于数据库存储和国际化支持。前端可根据用户时区进行本地化显示。

#### Step 4：校验与质量控制
1. **OpenAPI规范验证**：
   - swagger-cli validate 必须通过
   - 使用 `prism validate` 进行额外验证（如可用）
2. **引用路径验证**：
   - 所有 `` 路径必须可解析且有效
   - 验证引用的目标schema/path在目标文件中确实存在
   - 检查JSON Pointer语法正确性（路径中的`/`应编码为`~1`）
3. **结构一致性检查**：
   - tag 分类正确（与 domain 文件一致）
   - API路径命名符合RESTful规范
   - 响应模型引用全局标准组件
4. **功能覆盖率检测**：确认 PRD 列出的功能接口均有定义。
5. **Mock Server兼容性验证**：
   - 确保生成的API文档能够与Prism CLI正常启动
   - 验证Mock响应数据格式正确
   - 测试API端点可访问性

#### Step 5：HTTP 方法语义约束
- `GET`：查询资源（列表/详情）
- `POST`：新增资源
- `PUT`：全量更新
- `PATCH`：部分更新
- `DELETE`：删除
- `OPTIONS`：跨域预检（如需）
- `HEAD`：获取元信息（如需）

### 引用路径规范与域文件指导

#### JSON Pointer 语法规范
1. **路径编码规则**：
   - 路径中的 `/` 必须编码为 `~1`
   - 路径中的 `~` 必须编码为 `~0`
   - 示例：`/api/v1/tickets/{id}` → `~1api~1v1~1tickets~1{id}`

2. **正确的引用格式**：
   ```yaml
   # ✅ 正确：引用具体的API路径
   /api/v1/tickets:
     : '../modules/REQ-003-工单管理系统/openapi.yaml#/paths/~1api~1v1~1tickets'

   # ❌ 错误：引用不存在的模块级路径
   /工单管理系统:
     : '../modules/REQ-003-工单管理系统/openapi.yaml#/paths/~1工单管理系统'
   ```

3. **引用验证原则**：
   - 引用前必须确认目标路径在源文件中确实存在
   - 使用具体的API路径而非抽象的模块名称
   - 保持引用路径与实际文件结构一致

#### 域文件生成指导
当需要生成或更新域文件时，应遵循以下规范：

1. **域文件结构**：
   ```yaml
   openapi: 3.0.3
   info:
     title: <业务域名称> 业务域 API 聚合
     version: 1.0.0
     description: <业务域描述>，包括<具体功能列表>

   paths:
     # 引用模块中的具体API路径
     /api/v1/<resource>:
       : '../modules/<MODULE_ID>/openapi.yaml#/paths/~1api~1v1~1<resource>'
     /api/v1/<resource>/{id}:
       : '../modules/<MODULE_ID>/openapi.yaml#/paths/~1api~1v1~1<resource>~1{id}'

   components:
     # 引用全局通用组件
     schemas:
       ApiResponse:
         : '../../global-api-index.yaml#/components/schemas/ApiResponse'
       PagedResponse:
         : '../../global-api-index.yaml#/components/schemas/PagedResponse'
       ErrorResponse:
         : '../../global-api-index.yaml#/components/schemas/ErrorResponse'
   ```

2. **域文件路径映射示例**：
   - **认证域** (`auth-domain.yaml`)：
     - `/api/v1/auth/login` → 基础架构模块
     - `/api/v1/users` → 用户与权限管理模块
     - `/api/v1/roles` → 用户与权限管理模块

   - **工单域** (`ticket-domain.yaml`)：
     - `/api/v1/tickets` → 工单管理系统模块
     - `/api/v1/tickets/{id}/assign` → 智能派单系统模块

   - **客户域** (`customer-domain.yaml`)：
     - `/api/v1/customers` → 客户关系管理模块
     - `/api/v1/customers/{id}/health-score` → 客户关系管理模块

3. **全局API索引更新**：
   当生成新模块后，需要更新 `global-api-index.yaml`：
   ```yaml
   paths:
     # 从域文件聚合API路径
     /api/v1/auth/login:
       : '../domains/auth-domain.yaml#/paths/~1api~1v1~1auth~1login'
     /api/v1/tickets:
       : '../domains/ticket-domain.yaml#/paths/~1api~1v1~1tickets'
     /api/v1/customers:
       : '../domains/customer-domain.yaml#/paths/~1api~1v1~1customers'
   ```

#### 常见引用错误排查
1. **错误类型**：`token "xxx" does not exist`
   - **原因**：引用的路径在目标文件中不存在
   - **解决**：检查目标文件的实际路径结构，使用存在的路径

2. **错误类型**：`EMISSINGPOINTER`
   - **原因**：JSON Pointer语法错误或路径编码问题
   - **解决**：确保路径中的`/`编码为`~1`，`{}`参数正确编码

3. **错误类型**：Mock Server启动失败
   - **原因**：引用链断裂或循环引用
   - **解决**：验证完整的引用链，确保所有依赖文件存在且格式正确

### 输出要求
1. **主要输出**：输出完整的 `docs/api/4.5.1/modules/REQ-008-系统设置/openapi.yaml` 文件内容。

2. **引用规范要求**：
   - 不包含全局/域级 schema 的重复定义
   - 所有 `` 引用使用正确的JSON Pointer语法
   - 确保引用的路径在目标文件中真实存在
   - 使用相对路径引用（`../../global-api-index.yaml#/...`）

3. **数据质量要求**：
   - 所有示例数据必须符合 Mock 数据规范，贴合 IT运维业务语境
   - API路径使用具体的业务路径（如`/api/v1/tickets`），避免抽象路径
   - 响应模型正确引用全局标准组件（ApiResponse、PagedResponse、ErrorResponse）

4. **验证要求**：
   - 文件可独立通过 swagger-cli validate
   - 生成的API文档能够与Mock Server脚本兼容
   - 支持Prism CLI等Mock工具正常启动

5. **域文件更新**（如需要）：
   - 如果模块涉及新的业务域或需要更新现有域文件，同时输出相应的域文件内容
   - 域文件必须正确引用模块中的具体API路径
   - 确保域文件与全局API索引的引用链完整

### 验证命令
```bash
# OpenAPI规范验证
swagger-cli validate docs/api/4.5.1/modules/REQ-008-系统设置/openapi.yaml

# Mock Server启动测试
./scripts/start-mock-server.sh -m REQ-008-系统设置 -p 3000

# 域文件Mock Server测试（如适用）
./scripts/start-mock-server.sh -d <domain_name> -p 3001

# 全局API聚合测试
./scripts/start-mock-server.sh -p 3002
```

### 实际示例参考

#### 模块文件示例（基于修复经验）
```yaml
# docs/api/4.5.1/modules/REQ-003-工单管理系统/openapi.yaml
openapi: 3.0.3
info:
  title: 工单管理系统 API
  version: 1.0.0
  description: REQ-003 工单管理系统 API 规范

paths:
  /api/v1/tickets:
    post:
      summary: 创建工单
      operationId: ticket_create
      responses:
        '200':
          description: 创建成功
          content:
            application/json:
              schema:
                allOf:
                  - : '../../global-api-index.yaml#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        : '#/components/schemas/TicketInfo'

  /api/v1/tickets/{id}:
    get:
      summary: 查询工单详情
      operationId: ticket_get
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: 查询成功
          content:
            application/json:
              schema:
                allOf:
                  - : '../../global-api-index.yaml#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        : '#/components/schemas/TicketDetailInfo'

components:
  schemas:
    TicketInfo:
      type: object
      properties:
        id:
          type: integer
          description: 工单ID
          example: 12345
        ticket_no:
          type: string
          description: 工单编号
          example: "TK-20240814-0001"
```

#### 域文件示例（基于修复经验）
```yaml
# docs/api/4.5.1/domains/ticket-domain.yaml
openapi: 3.0.3
info:
  title: 工单业务域 API 聚合
  version: 1.0.0
  description: 工单相关的API聚合，包括工单管理、智能派单等功能

paths:
  # ✅ 正确：引用模块中的具体API路径
  /api/v1/tickets:
    : '../modules/REQ-003-工单管理系统/openapi.yaml#/paths/~1api~1v1~1tickets'
  /api/v1/tickets/{id}:
    : '../modules/REQ-003-工单管理系统/openapi.yaml#/paths/~1api~1v1~1tickets~1{id}'
  /api/v1/tickets/{id}/status:
    : '../modules/REQ-003-工单管理系统/openapi.yaml#/paths/~1api~1v1~1tickets~1{id}~1status'

components:
  schemas:
    ApiResponse:
      : '../global-api-index.yaml#/components/schemas/ApiResponse'
    PagedResponse:
      : '../global-api-index.yaml#/components/schemas/PagedResponse'
    ErrorResponse:
      : '../global-api-index.yaml#/components/schemas/ErrorResponse'
```

#### 全局API索引示例（基于修复经验）
```yaml
# docs/api/4.5.1/global-api-index.yaml
openapi: 3.0.3
info:
  title: IT运维门户系统 API
  version: 1.0.0
  description: 全局 API 入口文档（聚合所有业务域）

paths:
  # ✅ 正确：从域文件聚合API路径
  /api/v1/tickets:
    : './domains/ticket-domain.yaml#/paths/~1api~1v1~1tickets'
  /api/v1/tickets/{id}:
    : './domains/ticket-domain.yaml#/paths/~1api~1v1~1tickets~1{id}'
  /api/v1/auth/login:
    : './domains/auth-domain.yaml#/paths/~1api~1v1~1auth~1login'
  /api/v1/customers:
    : './domains/customer-domain.yaml#/paths/~1api~1v1~1customers'
```

**注意**：以上示例基于实际修复OpenAPI引用错误的成功经验，确保生成的API文档能够与Mock Server脚本完美兼容。
