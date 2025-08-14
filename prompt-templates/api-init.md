## 任务：生成 AI开发助手专用的OpenAPI架构初始化规范

### 背景与目标
为AI开发助手生成结构化、标准化的OpenAPI架构初始化规范文档。此文档专门设计为AI可解析的格式，建立完整的三级分离API架构（全局/业务域/模块），为AI工具链的后续API生成提供标准化基础配置。

### AI处理配置
1. **输入文档源**：
   - 全局上下文：`$GLOBAL_FILE`
   - Mock 数据规范：`$MOCK_GUIDE`
   - 技术栈规范：`docs/prd/split/4.5/appendix/03-technology-stack.md`
   - 架构图表：`docs/prd/split/4.5/appendix/05-architecture-diagrams.md`
   - 业务域映射：`docs/prd/split/4.5/globals/06-api-domain-mapping.md`

2. **技术约束配置**：
   - OpenAPI版本：3.0.3
   - 验证工具：swagger-cli validate
   - 后端技术栈：Spring Boot 3.2.11 + Spring Security + Spring Data JPA
   - 架构模式：多租户 + RESTful + 三级分离
   - 数据隔离：tenant_id强制要求

### AI处理步骤

#### Step 1：全局API架构配置生成
生成结构化的全局API架构配置，为AI后续处理提供标准化基础。

#### Step 2：业务域配置标准化
基于业务域映射表，生成标准化的域级API配置。

#### Step 3：模块占位配置创建
为所有模块创建标准化的占位配置，建立完整的三级架构。

### 输出要求
生成文件：`docs/api/ai-api-architecture-config.yaml`

**AI专用API架构配置格式**：

#### 1. 全局API规范配置 (GLOBAL_API_SPEC)
```yaml
openapi_config:
  version: "3.0.3"
  info:
    title: "IT运维门户系统 API"
    version: "1.0.0"
    description: "企业级IT运维门户系统统一API接口"
  servers:
    - url: "https://api-dev.fxtech.com"
      description: "开发环境"
    - url: "https://api-test.fxtech.com"
      description: "测试环境"
    - url: "https://api.fxtech.com"
      description: "生产环境"

security_schemes:
  bearer_auth:
    type: "http"
    scheme: "bearer"
    bearer_format: "JWT"
    description: "JWT Bearer Token认证"
  api_key_auth:
    type: "apiKey"
    in: "header"
    name: "X-API-Key"
    description: "API Key认证（系统间调用）"

global_parameters:
  pagination:
    page:
      name: "page"
      in: "query"
      schema:
        type: "integer"
        minimum: 0
        default: 0
    size:
      name: "size"
      in: "query"
      schema:
        type: "integer"
        minimum: 1
        maximum: 100
        default: 20

#### Step 2：创建业务域文件
**路径**：`docs/api/domains/{domain}.yaml`

**每个域文件包含**：
1. 域路径前缀（tags / description）
2. 域特有 schema
3. `DOLLAR_REF: '../_global.yaml#/components/schemas/...'` 引用全局通用组件
4. 不得直接引用其他域，跨域复用必须走全局

#### Step 3：创建模块占位文件
**路径**：`docs/api/modules/{MODULE}.yaml`

**占位文件内容**：
1. `info`（title="{模块名} API"，version 与全局一致）
2. `paths`：至少一个占位 endpoint（确保验证通过）
3. `components.schemas`：空，后续迭代填充
4. 引用全局/域模板的 `DOLLAR_REF` 示例

#### Step 4：数据规范与命名约定
1. **字段示例数据**：
   - 所有字段 example 必须符合 `$MOCK_GUIDE` 规范
   - 使用真实的IT运维业务场景数据（工单号、设备名称、IP地址等）
   - 时间字段统一使用 ISO8601 格式：`2024-01-15T10:30:00Z`

2. **API路径命名**：
   - 全小写，单词用连字符分隔：`/api/v1/work-orders`
   - 资源使用复数形式：`/tickets`, `/engineers`, `/customers`
   - 嵌套资源体现层级关系：`/tickets/{id}/comments`

3. **Schema命名规范**：
   - 实体类：PascalCase，如 `WorkOrder`, `Engineer`
   - DTO类：添加后缀，如 `WorkOrderCreateDTO`, `EngineerListVO`
   - 枚举类：PascalCase + Enum后缀，如 `TicketStatusEnum`

4. **多租户支持**：
   - 所有业务实体必须包含 `tenantId` 字段
   - API响应中自动过滤租户数据
   - 全局参数包含租户标识

#### Step 5：HTTP 方法语义与状态码
1. **HTTP方法**：
   - `GET`：查询资源（幂等）
   - `POST`：创建资源或执行操作
   - `PUT`：全量更新资源（幂等）
   - `PATCH`：部分更新资源
   - `DELETE`：删除资源（幂等）

2. **状态码标准**：
   - `200`：成功（GET/PUT/PATCH）
   - `201`：创建成功（POST）
   - `204`：成功无内容（DELETE）
   - `400`：请求参数错误
   - `401`：未认证
   - `403`：无权限
   - `404`：资源不存在
   - `409`：资源冲突
   - `500`：服务器内部错误

### 输出要求
1. **文件质量**：
   - 每个YAML文件必须独立且语法正确
   - 所有 `DOLLAR_REF` 引用路径必须有效
   - 示例数据贴合IT运维业务场景

2. **架构一致性**：
   - 严格遵循三级分离设计
   - 全局/域/模块层级清晰
   - 避免循环引用和重复定义

3. **业务完整性**：
   - 覆盖所有核心业务域
   - 支持完整的CRUD操作
   - 包含必要的业务流程API

### 验证与测试
```bash
# 语法验证
swagger-cli validate docs/api/_global.yaml
swagger-cli validate docs/api/domains/*.yaml
swagger-cli validate docs/api/modules/*.yaml

# Mock Server测试
swagger-codegen generate -i docs/api/_global.yaml -l nodejs-server -o mock-server
cd mock-server && npm install && npm start
