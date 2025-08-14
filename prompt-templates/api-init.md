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
    sort:
      name: "sort"
      in: "query"
      schema:
        type: "string"
        example: "createdAt,desc"
  tenant:
    tenant_id_header:
      name: "X-Tenant-ID"
      in: "header"
      required: true
      schema:
        type: "string"
        format: "uuid"

global_schemas:
  base_entity:
    type: "object"
    properties:
      id:
        type: "string"
        format: "uuid"
        description: "主键ID"
      tenant_id:
        type: "string"
        format: "uuid"
        description: "租户ID"
      created_at:
        type: "string"
        format: "date-time"
        description: "创建时间"
      updated_at:
        type: "string"
        format: "date-time"
        description: "更新时间"
    required: ["id", "tenant_id", "created_at", "updated_at"]

global_tags:
  - name: "auth"
    description: "认证授权相关接口"
  - name: "ticket"
    description: "工单管理相关接口"
  - name: "engineer"
    description: "工程师管理相关接口"
  - name: "knowledge"
    description: "知识库管理相关接口"
  - name: "customer"
    description: "客户管理相关接口"
  - name: "system"
    description: "系统管理相关接口"
```

#### 2. 业务域配置规范 (DOMAIN_CONFIG_SPEC)
```yaml
domain_mappings:
  auth:
    description: "认证授权业务域"
    path_prefix: "/api/v1/auth"
    modules: ["REQ-006A", "REQ-006B"]
  ticket:
    description: "工单管理业务域"
    path_prefix: "/api/v1/tickets"
    modules: ["REQ-003", "REQ-011"]
  engineer:
    description: "工程师管理业务域"
    path_prefix: "/api/v1/engineers"
    modules: ["REQ-004", "REQ-012"]
```

#### 3. API生成规范 (API_GENERATION_RULES)
```yaml
naming_conventions:
  api_paths:
    pattern: "/api/v1/{resource}"
    resource_naming: "kebab-case-plural"
  schema_naming:
    entities: "PascalCase"
    dtos: "{EntityName}{Operation}DTO"

http_methods:
  GET:
    purpose: "查询资源（幂等）"
    status_codes: [200, 404]
  POST:
    purpose: "创建资源或执行操作"
    status_codes: [201, 400, 409]
```

#### 4. AI验证检查点 (AI_VALIDATION_CHECKPOINTS)
```yaml
openapi_validation:
  - check: "OpenAPI 3.0.3 compliance"
    rule: "swagger-cli validate must pass"
architecture_validation:
  - check: "Three-tier separation"
    rule: "Global/Domain/Module hierarchy maintained"
tenant_validation:
  - check: "Multi-tenant support"
    rule: "All business entities include tenant_id"
```

### AI处理指令
1. **严格遵循YAML格式**：所有配置必须使用标准YAML格式
2. **完整性检查**：确保所有必需的配置项都有明确的值
3. **架构一致性**：严格遵循三级分离设计原则
4. **标准化命名**：按照naming_conventions生成所有API和Schema名称
