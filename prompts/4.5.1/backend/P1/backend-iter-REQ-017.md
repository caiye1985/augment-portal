## 任务：生成 AI开发助手专用的后端技术实现规范

### 背景与目标
为AI开发助手生成结构化、标准化的后端技术实现规范文档。此文档专门设计为AI可解析的格式，包含完整的技术实现细节、代码生成指导和验证标准。采用迭代式处理，每次专注1-2个模块，确保AI能够基于此规范生成高质量的后端代码。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`docs/global-context.md`
   - 模块 PRD：`docs/prd/split/4.5.1/modules/REQ-017.md`
   - API 定义：`docs/api/4.5.1/global-api-index.yaml`
   - Mock 数据规范：`docs/prd/split/4.5.1/globals/05-mock-data-guidelines.md`
   - 技术栈规范：`docs/prd/split/4.5.1/appendix/03-technology-stack.md`
   - 架构设计：`docs/prd/split/4.5.1/appendix/05-architecture-diagrams.md`
   - 业务流程：`docs/prd/split/4.5.1/globals/04-business-processes.md`

2. **技术约束**：
   - Spring Boot 3.3.6 + Spring Security + Spring Data JPA
   - PostgreSQL 16.6 数据库
   - Redis 7.4.1 缓存
   - 多租户架构，所有业务实体包含tenant_id
   - RESTful API设计，统一异常处理
   - 代码覆盖率 ≥ 80%，接口响应时间 ≤ 500ms

### AI处理步骤

#### Step 1：结构化需求提取
1. **实体识别与映射**：
   - 从模块PRD中提取所有业务实体
   - 为每个实体生成标准化的YAML配置
   - 建立实体间的关系映射表

2. **API端点标准化**：
   - 将API定义转换为结构化的端点配置
   - 生成Controller方法的标准化定义
   - 建立API到Service方法的映射关系

3. **数据流程规范化**：
   - 定义标准的CRUD操作流程
   - 建立数据验证规则的配置化定义
   - 生成缓存策略的结构化配置

#### Step 2：技术规范生成
1. **架构配置标准化**：
   - 生成TECHNICAL_SPECIFICATIONS配置
   - 定义分层架构的标准化实现
   - 建立组件间的依赖关系配置

2. **安全配置规范化**：
   - 生成SECURITY_CONFIG_SPEC配置
   - 定义JWT认证的标准化实现
   - 建立RBAC权限控制的配置化定义

3. **性能配置标准化**：
   - 生成PERFORMANCE_CONFIG_SPEC配置
   - 定义缓存策略的标准化实现
   - 建立数据库优化的配置化定义

#### Step 3：数据模型规范化
1. **实体配置生成**：
   - 生成DATA_MODEL_SPEC配置
   - 定义JPA实体的标准化配置
   - 建立实体关系的配置化定义

2. **数据库配置标准化**：
   - 生成数据库表结构的YAML定义
   - 定义索引和约束的配置化规范
   - 建立数据完整性的验证规则

3. **Repository配置规范化**：
   - 生成Repository接口的标准化定义
   - 定义查询方法的配置化规范
   - 建立缓存策略的标准化配置

#### Step 4：业务逻辑规范化
1. **服务配置生成**：
   - 生成BUSINESS_LOGIC_SPEC配置
   - 定义Service方法的标准化配置
   - 建立事务管理的配置化定义

2. **集成配置标准化**：
   - 生成外部系统集成的配置化定义
   - 定义API调用的标准化配置
   - 建立错误处理的配置化规范

#### Step 5：代码生成规范化
1. **代码模板配置**：
   - 生成CODE_GENERATION_RULES配置
   - 定义命名约定的标准化规范
   - 建立代码模板的配置化定义

2. **测试配置标准化**：
   - 生成TEST_SPECIFICATIONS配置
   - 定义测试策略的标准化配置
   - 建立Mock配置的标准化定义

3. **验证规则配置**：
   - 生成AI_VALIDATION_CHECKPOINTS配置
   - 定义代码质量的验证规则
   - 建立自动化检查的配置化定义

### 输出要求
生成文件：`docs/ai_prd/4.5.1/backend/REQ-017-backend-prd.md`

**AI专用结构化文档格式**：

#### 1. 技术规范定义 (TECHNICAL_SPECIFICATIONS)
```yaml
module_id: REQ-017
technology_stack:
  framework: "Spring Boot 3.2.11"
  security: "Spring Security 6.2.1"
  data_access: "Spring Data JPA 3.2.x"
  database: "PostgreSQL 15.5"
  cache: "Redis 7.2.4"
architecture_pattern: "Layered Architecture"
multi_tenant: true
api_style: "RESTful"
```

#### 2. 数据模型规范 (DATA_MODEL_SPEC)
```yaml
entities:
  - name: "EntityName"
    table_name: "table_name"
    fields:
      - name: "fieldName"
        type: "DataType"
        constraints: ["NOT_NULL", "UNIQUE"]
        jpa_annotations: ["@Column(name=\"field_name\")"]
    relationships:
      - type: "OneToMany"
        target: "TargetEntity"
        mapping: "@OneToMany(mappedBy=\"fieldName\")"
    indexes:
      - fields: ["field1", "field2"]
        type: "BTREE"
```

#### 3. API端点规范 (API_ENDPOINTS_SPEC)
```yaml
controllers:
  - class_name: "EntityController"
    base_path: "/api/v1/entities"
    endpoints:
      - method: "GET"
        path: "/"
        operation_id: "listEntities"
        parameters:
          - name: "page"
            type: "Integer"
            default: 0
        response_type: "PagedResponse<EntityDTO>"
        service_method: "entityService.findAll(pageable)"
```

#### 4. 业务逻辑规范 (BUSINESS_LOGIC_SPEC)
```yaml
services:
  - class_name: "EntityService"
    methods:
      - name: "findAll"
        parameters:
          - name: "pageable"
            type: "Pageable"
        return_type: "Page<EntityDTO>"
        transaction: "READ_ONLY"
        cache: "entities_list"
        business_rules:
          - "Filter by tenant_id"
          - "Apply user permissions"
```

#### 5. 安全配置规范 (SECURITY_CONFIG_SPEC)
```yaml
authentication:
  type: "JWT"
  token_header: "Authorization"
  token_prefix: "Bearer "
authorization:
  method: "RBAC"
  permissions:
    - resource: "Entity"
      actions: ["CREATE", "READ", "UPDATE", "DELETE"]
      roles: ["ADMIN", "USER"]
data_filtering:
  tenant_isolation: true
  field_level_security: ["sensitive_field"]
```

#### 6. 性能配置规范 (PERFORMANCE_CONFIG_SPEC)
```yaml
performance_targets:
  response_time_ms: 500
  concurrent_users: 1000
  throughput_rps: 100
caching:
  - key: "entities_list"
    ttl_seconds: 300
    eviction_policy: "LRU"
database_optimization:
  connection_pool_size: 20
  query_timeout_seconds: 30
  indexes:
    - table: "entities"
      fields: ["tenant_id", "created_at"]
```

#### 7. 测试规范 (TEST_SPECIFICATIONS)
```yaml
unit_tests:
  coverage_target: 80
  test_classes:
    - "EntityServiceTest"
    - "EntityControllerTest"
    - "EntityRepositoryTest"
integration_tests:
  - name: "EntityAPITest"
    test_scenarios:
      - "Create entity with valid data"
      - "List entities with pagination"
      - "Update entity with partial data"
mock_configurations:
  - service: "ExternalService"
    mock_responses:
      - method: "getData"
        return: "mock_data.json"
```

#### 8. 代码生成规范 (CODE_GENERATION_RULES)
```yaml
naming_conventions:
  classes:
    entity: "{EntityName}Entity"
    dto: "{EntityName}DTO"
    service: "{EntityName}Service"
    controller: "{EntityName}Controller"
    repository: "{EntityName}Repository"
  methods:
    crud_operations:
      create: "create{EntityName}"
      read: "find{EntityName}ById"
      update: "update{EntityName}"
      delete: "delete{EntityName}"
      list: "find{EntityName}s"
  packages:
    base: "com.fxtech.portal"
    entity: "com.fxtech.portal.{module}.entity"
    dto: "com.fxtech.portal.{module}.dto"
    service: "com.fxtech.portal.{module}.service"
    controller: "com.fxtech.portal.{module}.controller"
    repository: "com.fxtech.portal.{module}.repository"

code_templates:
  entity_annotations:
    - "@Entity"
    - "@Table(name=\"{table_name}\")"
    - "@Data"
    - "@NoArgsConstructor"
    - "@AllArgsConstructor"
  service_annotations:
    - "@Service"
    - "@Transactional"
    - "@Slf4j"
  controller_annotations:
    - "@RestController"
    - "@RequestMapping(\"/api/v1/{resource}\")"
    - "@Validated"
    - "@Slf4j"

validation_rules:
  required_fields: ["id", "tenantId", "createdAt", "updatedAt"]
  audit_fields: ["createdBy", "updatedBy", "version"]
  tenant_isolation: "WHERE tenant_id = :tenantId"
```

#### 9. AI验证检查点 (AI_VALIDATION_CHECKPOINTS)
```yaml
architecture_validation:
  - check: "All entities extend BaseEntity"
    rule: "class {EntityName}Entity extends BaseEntity"
  - check: "All services use @Transactional"
    rule: "@Transactional annotation present"
  - check: "All controllers use @RestController"
    rule: "@RestController annotation present"

security_validation:
  - check: "Tenant isolation in queries"
    rule: "All queries include tenant_id filter"
  - check: "Permission checks in services"
    rule: "@PreAuthorize annotation on sensitive methods"

performance_validation:
  - check: "Pagination for list operations"
    rule: "List methods use Pageable parameter"
  - check: "Caching for read operations"
    rule: "@Cacheable annotation on read methods"

api_validation:
  - check: "OpenAPI compliance"
    rule: "All endpoints match OpenAPI specification"
  - check: "Error handling consistency"
    rule: "All exceptions use GlobalExceptionHandler"
```

### AI处理指令
1. **严格遵循YAML格式**：所有技术规范必须使用标准YAML格式，便于AI解析
2. **完整性检查**：确保所有必需的配置项都有明确的值
3. **一致性验证**：使用AI_VALIDATION_CHECKPOINTS进行自我验证
4. **模板应用**：严格按照CODE_GENERATION_RULES生成代码结构
5. **标准化输出**：所有生成的代码必须符合项目编码规范和命名约定
