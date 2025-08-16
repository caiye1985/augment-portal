## 任务：生成 AI开发助手专用的全栈技术实现PRD文档

### 背景与目标
基于现有的API文档和需求文档，生成专门为AI开发助手优化的全栈技术实现PRD文档。此文档整合了需求分析、技术规范、代码生成指导和验证机制，确保AI能够基于此PRD高效生成高质量的完整系统实现代码。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`$GLOBAL_FILE`
   - 当前模块 PRD：`$MODULE_FILE`
   - 当前模块 API 文档：`$API_MODULE_FILE`
   - Mock 数据规范：`$MOCK_GUIDE`
   - 技术栈规范：`docs/prd/split/$VERSION/appendix/03-technology-stack.md`
   - 架构设计：`docs/prd/split/$VERSION/appendix/05-architecture-diagrams.md`
   - 业务流程：`docs/prd/split/$VERSION/globals/04-business-processes.md`

2. **技术约束**：
   - 严格遵循 IT运维门户系统统一开发规则
   - 后端：Java 21 + Spring Boot 3.3.6 + Spring Security + Spring Data JPA
   - 前端：Vue.js 3.5.13 + Vite 6 + Element Plus 2.8.8
   - 数据库：PostgreSQL 16.6 + Redis 7.4.1
   - 支持多租户数据隔离，API 统一前缀 /api/v1，返回类型 Result<T>
   - 代码覆盖率 ≥ 80%，接口响应时间 ≤ 500ms

### AI处理步骤

#### Step 1：需求分析与实体识别
1. **业务需求提取**：
   - 从模块PRD中提取核心业务需求和功能点
   - 识别关键业务流程和数据流
   - 确定模块边界和依赖关系

2. **实体识别与映射**：
   - 从模块PRD中提取所有业务实体
   - 为每个实体生成标准化的YAML配置
   - 建立实体间的关系映射表

3. **API端点标准化**：
   - 将API定义转换为结构化的端点配置
   - 生成Controller方法的标准化定义
   - 建立API到Service方法的映射关系

#### Step 2：技术架构规范生成
1. **架构配置标准化**：
   - 生成TECHNICAL_SPECIFICATIONS配置
   - 定义分层架构的标准化实现
   - 建立组件间的依赖关系配置

2. **数据模型规范化**：
   - 生成DATA_MODEL_SPEC配置
   - 定义JPA实体的标准化配置
   - 建立实体关系的配置化定义

3. **API设计规范化**：
   - 生成API_ENDPOINTS_SPEC配置
   - 定义OpenAPI规范的标准化配置
   - 建立RESTful设计的配置化定义

#### Step 3：前端架构规范生成
1. **Vue组件架构设计**：
   - 生成FRONTEND_ARCHITECTURE_SPEC配置
   - 定义组件分层和状态管理
   - 建立路由和权限控制配置

2. **UI组件规范化**：
   - 生成UI_COMPONENT_SPEC配置
   - 定义Element Plus使用规范
   - 建立响应式设计配置

#### Step 4：移动端适配规范（如适用）
1. **移动端特性配置**：
   - 生成MOBILE_FEATURES_SPEC配置
   - 定义离线功能和推送通知
   - 建立移动端性能优化配置

#### Step 5：代码生成与验证规范
1. **代码模板配置**：
   - 生成CODE_GENERATION_RULES配置
   - 定义命名约定的标准化规范
   - 建立代码模板的配置化定义

2. **验证规则配置**：
   - 生成AI_VALIDATION_CHECKPOINTS配置
   - 定义代码质量的验证规则
   - 建立自动化检查的配置化定义

### 输出要求
生成文件：`docs/ai_prd/$VERSION/$MODULE_ID-fullstack-prd.md`

**AI专用结构化文档格式**：

#### 1. 文档头部信息
```yaml
document_info:
  module_id: $MODULE_ID
  module_name: $MODULE_NAME
  version: $VERSION-AI-FULLSTACK-PRD
  generated_date: [当前日期]
  document_type: "AI开发助手专用全栈PRD"
  technology_stack:
    backend: "Java 21 + Spring Boot 3.3.6"
    frontend: "Vue.js 3.5.13 + Element Plus 2.8.8"
    database: "PostgreSQL 16.6 + Redis 7.4.1"
    mobile: "Flutter 3.x (如适用)"
```

#### 2. 模块概述 (MODULE_OVERVIEW)
```yaml
module_overview:
  business_value: "[简洁的业务价值描述，控制在100词内]"
  functional_scope:
    - "[核心功能1]"
    - "[核心功能2]"
    - "[核心功能3]"
  technical_positioning: "[在整体架构中的技术定位和关键依赖关系]"
  integration_points:
    - module: "[依赖模块名]"
      interface: "[集成接口]"
      type: "[依赖类型：API调用/事件订阅/数据共享]"
```

#### 3. 技术规范定义 (TECHNICAL_SPECIFICATIONS)
```yaml
technical_specifications:
  architecture_pattern: "Layered Architecture"
  multi_tenant: true
  api_style: "RESTful"
  security_model: "JWT + RBAC"
  caching_strategy: "Redis分层缓存"
  transaction_management: "Spring声明式事务"
  error_handling: "全局异常处理"
  logging_strategy: "结构化日志"
  monitoring: "Micrometer + Prometheus"
```

#### 4. 数据模型规范 (DATA_MODEL_SPEC)
```yaml
data_model_spec:
  entities:
    - name: "[EntityName]"
      table_name: "[table_name]"
      description: "[实体描述]"
      fields:
        - name: "id"
          type: "Long"
          constraints: ["PRIMARY_KEY", "AUTO_INCREMENT"]
          jpa_annotations: ["@Id", "@GeneratedValue(strategy = GenerationType.IDENTITY)"]
        - name: "tenantId"
          type: "Long"
          constraints: ["NOT_NULL", "INDEX"]
          jpa_annotations: ["@Column(name = \"tenant_id\", nullable = false)"]
        - name: "[fieldName]"
          type: "[DataType]"
          constraints: ["NOT_NULL", "UNIQUE"]
          jpa_annotations: ["@Column(name=\"[field_name]\")"]
          validation: ["@NotNull", "@Size(max=255)"]
      relationships:
        - type: "OneToMany"
          target: "[TargetEntity]"
          mapping: "@OneToMany(mappedBy=\"[fieldName]\", cascade = CascadeType.ALL)"
          fetch_type: "LAZY"
      indexes:
        - fields: ["tenantId", "createdAt"]
          type: "BTREE"
          name: "idx_[table_name]_tenant_created"
      audit_fields:
        - "createdAt"
        - "updatedAt"
        - "createdBy"
        - "updatedBy"
        - "version"
```

#### 5. API端点规范 (API_ENDPOINTS_SPEC)
```yaml
api_endpoints_spec:
  base_path: "/api/v1/[resource]"
  controllers:
    - class_name: "[EntityName]Controller"
      endpoints:
        - method: "GET"
          path: "/"
          operation_id: "[resource]_list"
          summary: "查询[实体]列表"
          parameters:
            - name: "page"
              type: "Integer"
              default: 0
              description: "页码"
            - name: "size"
              type: "Integer"
              default: 20
              description: "每页大小"
            - name: "keyword"
              type: "String"
              required: false
              description: "搜索关键词"
          response_type: "PagedResponse<[EntityName]DTO>"
          service_method: "[entityName]Service.findAll(pageable, keyword)"
          cache_config:
            key: "[resource]_list"
            ttl_seconds: 300
          security: "@PreAuthorize(\"hasPermission('[RESOURCE]', 'READ')\")"
        
        - method: "GET"
          path: "/{id}"
          operation_id: "[resource]_get"
          summary: "查询[实体]详情"
          parameters:
            - name: "id"
              type: "Long"
              required: true
              description: "[实体]ID"
          response_type: "ApiResponse<[EntityName]DetailDTO>"
          service_method: "[entityName]Service.findById(id)"
          cache_config:
            key: "[resource]_detail_{id}"
            ttl_seconds: 600
          security: "@PreAuthorize(\"hasPermission('[RESOURCE]', 'READ')\")"
        
        - method: "POST"
          path: "/"
          operation_id: "[resource]_create"
          summary: "创建[实体]"
          request_body: "[EntityName]CreateRequest"
          response_type: "ApiResponse<[EntityName]DTO>"
          service_method: "[entityName]Service.create(request)"
          validation: "@Valid"
          security: "@PreAuthorize(\"hasPermission('[RESOURCE]', 'CREATE')\")"
        
        - method: "PUT"
          path: "/{id}"
          operation_id: "[resource]_update"
          summary: "更新[实体]"
          parameters:
            - name: "id"
              type: "Long"
              required: true
          request_body: "[EntityName]UpdateRequest"
          response_type: "ApiResponse<[EntityName]DTO>"
          service_method: "[entityName]Service.update(id, request)"
          validation: "@Valid"
          security: "@PreAuthorize(\"hasPermission('[RESOURCE]', 'UPDATE')\")"
        
        - method: "DELETE"
          path: "/{id}"
          operation_id: "[resource]_delete"
          summary: "删除[实体]"
          parameters:
            - name: "id"
              type: "Long"
              required: true
          response_type: "ApiResponse<Void>"
          service_method: "[entityName]Service.delete(id)"
          security: "@PreAuthorize(\"hasPermission('[RESOURCE]', 'DELETE')\")"

#### 6. 业务逻辑规范 (BUSINESS_LOGIC_SPEC)
```yaml
business_logic_spec:
  services:
    - class_name: "[EntityName]Service"
      interface: "[EntityName]Service"
      implementation: "[EntityName]ServiceImpl"
      methods:
        - name: "findAll"
          parameters:
            - name: "pageable"
              type: "Pageable"
            - name: "keyword"
              type: "String"
              required: false
          return_type: "Page<[EntityName]DTO>"
          transaction: "READ_ONLY"
          cache: "[resource]_list"
          business_rules:
            - "Filter by tenant_id automatically"
            - "Apply user permissions"
            - "Support keyword search in name/description fields"
          implementation_notes:
            - "Use Specification for dynamic queries"
            - "Apply tenant isolation filter"
            - "Cache results for 5 minutes"

        - name: "findById"
          parameters:
            - name: "id"
              type: "Long"
          return_type: "[EntityName]DetailDTO"
          transaction: "READ_ONLY"
          cache: "[resource]_detail_{id}"
          business_rules:
            - "Verify tenant access"
            - "Check read permissions"
          exception_handling:
            - "EntityNotFoundException if not found"
            - "AccessDeniedException if no permission"

        - name: "create"
          parameters:
            - name: "request"
              type: "[EntityName]CreateRequest"
          return_type: "[EntityName]DTO"
          transaction: "REQUIRED"
          business_rules:
            - "Validate business constraints"
            - "Set tenant_id from security context"
            - "Set audit fields (createdBy, createdAt)"
          validation:
            - "Check duplicate constraints"
            - "Validate foreign key references"
          events:
            - "[EntityName]CreatedEvent"

        - name: "update"
          parameters:
            - name: "id"
              type: "Long"
            - name: "request"
              type: "[EntityName]UpdateRequest"
          return_type: "[EntityName]DTO"
          transaction: "REQUIRED"
          business_rules:
            - "Verify entity exists and accessible"
            - "Validate business constraints"
            - "Update audit fields (updatedBy, updatedAt)"
            - "Handle optimistic locking"
          cache_eviction:
            - "[resource]_detail_{id}"
            - "[resource]_list"
          events:
            - "[EntityName]UpdatedEvent"

        - name: "delete"
          parameters:
            - name: "id"
              type: "Long"
          return_type: "void"
          transaction: "REQUIRED"
          business_rules:
            - "Verify entity exists and accessible"
            - "Check cascade delete constraints"
            - "Soft delete if configured"
          cache_eviction:
            - "[resource]_detail_{id}"
            - "[resource]_list"
          events:
            - "[EntityName]DeletedEvent"

  repositories:
    - interface: "[EntityName]Repository"
      extends: "JpaRepository<[EntityName]Entity, Long>, JpaSpecificationExecutor<[EntityName]Entity>"
      custom_methods:
        - name: "findByTenantIdAndNameContaining"
          parameters:
            - "tenantId: Long"
            - "name: String"
            - "pageable: Pageable"
          return_type: "Page<[EntityName]Entity>"
          query: "@Query(\"SELECT e FROM [EntityName]Entity e WHERE e.tenantId = :tenantId AND e.name LIKE %:name%\")"

        - name: "existsByTenantIdAndName"
          parameters:
            - "tenantId: Long"
            - "name: String"
          return_type: "boolean"
          query: "derived query method"
```

#### 7. 前端架构规范 (FRONTEND_ARCHITECTURE_SPEC)
```yaml
frontend_architecture_spec:
  project_structure:
    - "src/views/[module]/"
    - "src/components/[module]/"
    - "src/api/[module].js"
    - "src/stores/[module].js"

  pages:
    - name: "[EntityName]List"
      path: "/[module]/[resource]"
      component: "views/[module]/[EntityName]List.vue"
      permissions: ["[RESOURCE]:READ"]
      features:
        - "数据表格展示"
        - "分页查询"
        - "关键词搜索"
        - "批量操作"
        - "导出功能"

    - name: "[EntityName]Detail"
      path: "/[module]/[resource]/:id"
      component: "views/[module]/[EntityName]Detail.vue"
      permissions: ["[RESOURCE]:READ"]
      features:
        - "详情信息展示"
        - "编辑操作"
        - "关联数据展示"
        - "操作历史"

    - name: "[EntityName]Form"
      path: "/[module]/[resource]/create"
      component: "views/[module]/[EntityName]Form.vue"
      permissions: ["[RESOURCE]:CREATE"]
      features:
        - "表单创建/编辑"
        - "数据验证"
        - "文件上传"
        - "关联数据选择"

  components:
    - name: "[EntityName]Table"
      type: "业务组件"
      props:
        - "data: [EntityName][]"
        - "loading: boolean"
        - "pagination: PaginationConfig"
      events:
        - "edit: (item: [EntityName]) => void"
        - "delete: (id: number) => void"
        - "view: (id: number) => void"
      features:
        - "表格数据展示"
        - "排序和筛选"
        - "行操作按钮"
        - "批量选择"

    - name: "[EntityName]Form"
      type: "表单组件"
      props:
        - "modelValue: [EntityName]FormData"
        - "mode: 'create' | 'edit'"
        - "loading: boolean"
      events:
        - "submit: (data: [EntityName]FormData) => void"
        - "cancel: () => void"
      validation:
        - "required fields validation"
        - "format validation"
        - "business rules validation"

  stores:
    - name: "[module]Store"
      state:
        - "[resource]List: [EntityName][]"
        - "[resource]Detail: [EntityName]Detail | null"
        - "loading: boolean"
        - "pagination: PaginationState"
        - "searchParams: SearchParams"
      actions:
        - "fetch[EntityName]List(params: SearchParams)"
        - "fetch[EntityName]Detail(id: number)"
        - "create[EntityName](data: [EntityName]CreateRequest)"
        - "update[EntityName](id: number, data: [EntityName]UpdateRequest)"
        - "delete[EntityName](id: number)"
      getters:
        - "filtered[EntityName]List"
        - "total[EntityName]Count"
```

#### 8. UI组件规范 (UI_COMPONENT_SPEC)
```yaml
ui_component_spec:
  element_plus_usage:
    table:
      component: "el-table"
      features:
        - "stripe: true"
        - "border: true"
        - "size: 'default'"
        - "empty-text: '暂无数据'"
      columns:
        - "selection column for batch operations"
        - "index column with custom formatter"
        - "data columns with custom renderers"
        - "action column with operation buttons"

    form:
      component: "el-form"
      config:
        - "label-width: '120px'"
        - "label-position: 'right'"
        - "size: 'default'"
        - "validate-on-rule-change: false"
      validation:
        - "real-time validation on blur"
        - "submit validation before API call"
        - "error message display"

    pagination:
      component: "el-pagination"
      config:
        - "background: true"
        - "layout: 'total, sizes, prev, pager, next, jumper'"
        - "page-sizes: [10, 20, 50, 100]"
        - "small: false"

    dialog:
      component: "el-dialog"
      config:
        - "width: '600px'"
        - "center: true"
        - "close-on-click-modal: false"
        - "destroy-on-close: true"

  responsive_design:
    breakpoints:
      - "xs: <768px (mobile)"
      - "sm: ≥768px (tablet)"
      - "md: ≥992px (desktop)"
      - "lg: ≥1200px (large desktop)"

    layout_rules:
      - "Mobile: single column layout"
      - "Tablet: two column layout"
      - "Desktop: multi-column layout with sidebar"

    component_adaptation:
      - "Table: horizontal scroll on mobile"
      - "Form: vertical layout on mobile"
      - "Dialog: full screen on mobile"

#### 9. 移动端特性规范 (MOBILE_FEATURES_SPEC) - 如适用
```yaml
mobile_features_spec:
  platform_support:
    - "iOS 12+"
    - "Android 8.0+"

  core_features:
    offline_capability:
      - "Local SQLite database for data caching"
      - "Operation queue for offline actions"
      - "Automatic sync when network available"
      - "Conflict resolution strategy"

    push_notifications:
      - "Firebase Cloud Messaging integration"
      - "APNs for iOS devices"
      - "Local notifications for reminders"
      - "Deep linking to specific screens"

    device_integration:
      - "Camera for photo capture"
      - "GPS for location tracking"
      - "File system access"
      - "Biometric authentication"

    performance_targets:
      - "App startup time: ≤3 seconds"
      - "Screen transition: ≤2 seconds"
      - "Frame rate: ≥60fps"
      - "Memory usage: <200MB"

  flutter_architecture:
    state_management: "BLoC pattern"
    dependency_injection: "GetIt service locator"
    routing: "GoRouter for navigation"
    local_storage: "Hive for local database"
    network: "Dio for HTTP requests"
```

#### 10. 安全配置规范 (SECURITY_CONFIG_SPEC)
```yaml
security_config_spec:
  authentication:
    type: "JWT"
    token_header: "Authorization"
    token_prefix: "Bearer "
    token_expiry: "24 hours"
    refresh_token_expiry: "30 days"

  authorization:
    method: "RBAC"
    permissions:
      - resource: "[RESOURCE]"
        actions: ["CREATE", "READ", "UPDATE", "DELETE"]
        roles: ["ADMIN", "USER", "VIEWER"]

  data_filtering:
    tenant_isolation: true
    row_level_security: true
    field_level_security: ["sensitive_field"]

  api_security:
    rate_limiting: "100 requests per minute per user"
    cors_policy: "restricted to allowed origins"
    csrf_protection: true
    sql_injection_prevention: "parameterized queries"
    xss_protection: "input sanitization"
```

#### 11. 性能配置规范 (PERFORMANCE_CONFIG_SPEC)
```yaml
performance_config_spec:
  response_targets:
    api_response_time: "≤500ms"
    page_load_time: "≤2s"
    first_contentful_paint: "≤1s"

  caching_strategy:
    redis_cache:
      - key: "[resource]_list"
        ttl_seconds: 300
        eviction_policy: "LRU"
      - key: "[resource]_detail_{id}"
        ttl_seconds: 600
        eviction_policy: "LRU"

    browser_cache:
      - static_assets: "1 year"
      - api_responses: "5 minutes"
      - user_preferences: "1 day"

  database_optimization:
    connection_pool:
      initial_size: 5
      max_size: 20
      min_idle: 5

    query_optimization:
      - "Use indexes for frequent queries"
      - "Implement pagination for large datasets"
      - "Use lazy loading for associations"
      - "Optimize N+1 query problems"

    monitoring:
      - "Query execution time logging"
      - "Slow query detection (>1s)"
      - "Connection pool monitoring"
```

#### 12. 代码生成规范 (CODE_GENERATION_RULES)
```yaml
code_generation_rules:
  naming_conventions:
    backend:
      entity: "{EntityName}Entity"
      dto: "{EntityName}DTO"
      create_request: "{EntityName}CreateRequest"
      update_request: "{EntityName}UpdateRequest"
      detail_dto: "{EntityName}DetailDTO"
      service: "{EntityName}Service"
      service_impl: "{EntityName}ServiceImpl"
      controller: "{EntityName}Controller"
      repository: "{EntityName}Repository"

    frontend:
      page_component: "{EntityName}List.vue"
      detail_component: "{EntityName}Detail.vue"
      form_component: "{EntityName}Form.vue"
      table_component: "{EntityName}Table.vue"
      api_service: "{module}Api.js"
      store: "{module}Store.js"

    database:
      table_name: "{entity_name}"
      column_name: "{field_name}"
      index_name: "idx_{table_name}_{column_names}"
      constraint_name: "fk_{table_name}_{referenced_table}"

  package_structure:
    backend:
      base: "com.fxtech.portal"
      entity: "com.fxtech.portal.{module}.entity"
      dto: "com.fxtech.portal.{module}.dto"
      service: "com.fxtech.portal.{module}.service"
      controller: "com.fxtech.portal.{module}.controller"
      repository: "com.fxtech.portal.{module}.repository"
      config: "com.fxtech.portal.{module}.config"

    frontend:
      views: "src/views/{module}/"
      components: "src/components/{module}/"
      api: "src/api/"
      stores: "src/stores/"
      utils: "src/utils/{module}/"

  code_templates:
    entity_template: |
      @Entity
      @Table(name = "{table_name}")
      @Data
      @NoArgsConstructor
      @AllArgsConstructor
      @EqualsAndHashCode(callSuper = true)
      public class {EntityName}Entity extends BaseEntity {
          // Generated fields
      }

    controller_template: |
      @RestController
      @RequestMapping("/api/v1/{resource}")
      @Validated
      @Slf4j
      @Tag(name = "{EntityName} Management", description = "{EntityName} CRUD operations")
      public class {EntityName}Controller {
          // Generated methods
      }

    service_template: |
      @Service
      @Transactional
      @Slf4j
      public class {EntityName}ServiceImpl implements {EntityName}Service {
          // Generated methods
      }

    vue_page_template: |
      <template>
        <div class="{entity-name}-list">
          <!-- Generated template -->
        </div>
      </template>

      <script setup>
      // Generated script
      </script>

      <style scoped>
      /* Generated styles */
      </style>

  validation_annotations:
    - "@NotNull"
    - "@NotBlank"
    - "@Size(min=1, max=255)"
    - "@Email"
    - "@Pattern(regexp=\"...\")"
    - "@Valid"

#### 13. 测试规范 (TEST_SPECIFICATIONS)
```yaml
test_specifications:
  backend_testing:
    unit_tests:
      coverage_target: 80
      test_classes:
        - "{EntityName}ServiceTest"
        - "{EntityName}ControllerTest"
        - "{EntityName}RepositoryTest"

      test_scenarios:
        service_tests:
          - "Create {entity} with valid data"
          - "Create {entity} with invalid data should throw exception"
          - "Update existing {entity}"
          - "Update non-existent {entity} should throw exception"
          - "Delete {entity} with dependencies should handle cascade"
          - "Find {entity} by ID with tenant isolation"
          - "List {entities} with pagination and search"

        controller_tests:
          - "POST /{resource} returns 200 with valid data"
          - "POST /{resource} returns 400 with invalid data"
          - "GET /{resource}/{id} returns 200 with existing ID"
          - "GET /{resource}/{id} returns 404 with non-existent ID"
          - "PUT /{resource}/{id} returns 200 with valid update"
          - "DELETE /{resource}/{id} returns 200 with successful deletion"
          - "Security: unauthorized access returns 401"
          - "Security: insufficient permissions return 403"

        repository_tests:
          - "Save and find {entity}"
          - "Custom query methods work correctly"
          - "Tenant isolation in queries"
          - "Cascade operations work as expected"

    integration_tests:
      - name: "{EntityName}APITest"
        test_scenarios:
          - "End-to-end CRUD operations"
          - "Transaction rollback on errors"
          - "Cache behavior verification"
          - "Event publishing verification"

      - name: "{EntityName}SecurityTest"
        test_scenarios:
          - "Tenant isolation enforcement"
          - "Permission-based access control"
          - "JWT token validation"

  frontend_testing:
    unit_tests:
      framework: "Vitest + Vue Test Utils"
      test_files:
        - "{EntityName}List.spec.js"
        - "{EntityName}Form.spec.js"
        - "{EntityName}Table.spec.js"
        - "{module}Store.spec.js"

      test_scenarios:
        component_tests:
          - "Component renders correctly with props"
          - "User interactions trigger correct events"
          - "Form validation works as expected"
          - "Loading states display correctly"
          - "Error states handle gracefully"

        store_tests:
          - "Actions call correct API endpoints"
          - "State updates correctly after actions"
          - "Getters return expected computed values"
          - "Error handling in async actions"

    e2e_tests:
      framework: "Playwright"
      test_scenarios:
        - "User can create new {entity}"
        - "User can view {entity} list with pagination"
        - "User can edit existing {entity}"
        - "User can delete {entity} with confirmation"
        - "Search and filter functionality works"
        - "Permission-based UI elements visibility"

  mock_configurations:
    backend_mocks:
      - service: "External{Service}Client"
        mock_responses:
          - method: "getData"
            return: "mock_data.json"
            scenarios: ["success", "timeout", "error"]

    frontend_mocks:
      - api: "{module}Api"
        endpoints:
          - "GET /api/v1/{resource}"
          - "POST /api/v1/{resource}"
          - "PUT /api/v1/{resource}/{id}"
          - "DELETE /api/v1/{resource}/{id}"
        mock_data: "src/mocks/{module}MockData.js"
```

#### 14. AI验证检查点 (AI_VALIDATION_CHECKPOINTS)
```yaml
ai_validation_checkpoints:
  architecture_validation:
    - check: "All entities extend BaseEntity"
      rule: "class {EntityName}Entity extends BaseEntity"
      error_message: "Entity must extend BaseEntity for audit fields"

    - check: "All services use @Transactional"
      rule: "@Transactional annotation present on service class"
      error_message: "Service classes must be annotated with @Transactional"

    - check: "All controllers use @RestController"
      rule: "@RestController annotation present"
      error_message: "Controller classes must use @RestController"

    - check: "Repository extends correct interfaces"
      rule: "extends JpaRepository<Entity, Long>, JpaSpecificationExecutor<Entity>"
      error_message: "Repository must extend JpaRepository and JpaSpecificationExecutor"

  security_validation:
    - check: "Tenant isolation in queries"
      rule: "All queries include tenant_id filter or use @TenantFilter"
      error_message: "Queries must enforce tenant isolation"

    - check: "Permission checks in controllers"
      rule: "@PreAuthorize annotation on sensitive endpoints"
      error_message: "Controller methods must have permission checks"

    - check: "Input validation on DTOs"
      rule: "Request DTOs have validation annotations"
      error_message: "All input DTOs must have proper validation"

    - check: "SQL injection prevention"
      rule: "Use parameterized queries or JPA methods"
      error_message: "Avoid string concatenation in queries"

  performance_validation:
    - check: "Pagination for list operations"
      rule: "List methods use Pageable parameter"
      error_message: "List endpoints must support pagination"

    - check: "Caching for read operations"
      rule: "@Cacheable annotation on read methods"
      error_message: "Frequently accessed data should be cached"

    - check: "Lazy loading for associations"
      rule: "JPA associations use FetchType.LAZY"
      error_message: "Use lazy loading to avoid N+1 problems"

    - check: "Database indexes on query fields"
      rule: "Indexes defined for frequently queried fields"
      error_message: "Add indexes for performance optimization"

  api_validation:
    - check: "OpenAPI compliance"
      rule: "All endpoints match OpenAPI specification"
      error_message: "API implementation must match specification"

    - check: "Error handling consistency"
      rule: "All exceptions use GlobalExceptionHandler"
      error_message: "Use consistent error response format"

    - check: "Response format standardization"
      rule: "All responses use Result<T> wrapper"
      error_message: "API responses must use standard Result format"

    - check: "HTTP status codes correctness"
      rule: "Appropriate HTTP status codes for different scenarios"
      error_message: "Use correct HTTP status codes"

  frontend_validation:
    - check: "Component prop validation"
      rule: "All props have type definitions and validation"
      error_message: "Components must validate props properly"

    - check: "Error boundary implementation"
      rule: "Error handling in async operations"
      error_message: "Implement proper error handling"

    - check: "Accessibility compliance"
      rule: "ARIA labels and keyboard navigation support"
      error_message: "Components must be accessible"

    - check: "Performance optimization"
      rule: "Use v-memo, computed properties, and lazy loading"
      error_message: "Optimize component performance"

  code_quality_validation:
    - check: "Naming convention compliance"
      rule: "Follow established naming conventions"
      error_message: "Code must follow naming standards"

    - check: "Code documentation"
      rule: "Public methods have JavaDoc/JSDoc comments"
      error_message: "Document public APIs properly"

    - check: "Test coverage"
      rule: "Minimum 80% test coverage"
      error_message: "Maintain adequate test coverage"

    - check: "No code duplication"
      rule: "Extract common functionality to utilities"
      error_message: "Avoid code duplication"
```

### AI处理指令
1. **严格遵循YAML格式**：所有技术规范必须使用标准YAML格式，便于AI解析
2. **完整性检查**：确保所有必需的配置项都有明确的值
3. **一致性验证**：使用AI_VALIDATION_CHECKPOINTS进行自我验证
4. **模板应用**：严格按照CODE_GENERATION_RULES生成代码结构
5. **标准化输出**：所有生成的代码必须符合项目编码规范和命名约定
6. **迭代处理**：每次专注1-2个模块，确保质量和一致性
7. **技术栈对齐**：确保所有技术方案在当前技术栈下可实现

### 质量控制要求
1. **技术准确性**：确保所有技术方案在当前技术栈下可实现
2. **代码可用性**：提供的代码示例应该是可直接使用的
3. **配置完整性**：配置示例应该包含所有必要的参数
4. **集成一致性**：确保与其他模块的集成接口一致
5. **性能达标**：生成的代码应满足性能要求
6. **安全合规**：确保安全配置和权限控制正确实现

### 重要提示
- **直接输出完整PRD文档**，不要输出分析报告格式
- **专注技术实现**：包含完整的技术规范、代码模板和验证规则
- **保持精简高效**：信息密度最大化，避免冗余内容
- **AI可直接使用**：生成的PRD文档应能直接用于AI开发助手的代码生成
- **全栈覆盖**：确保后端、前端、API、移动端的完整技术指导
- **验证机制完整**：包含完整的质量控制和自我验证规则
```
```
```
