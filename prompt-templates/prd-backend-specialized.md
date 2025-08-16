## 任务：生成 AI开发助手专用的后端开发PRD文档

### 背景与目标
为后端开发专门优化的PRD模板，专注于Spring Boot应用架构、业务逻辑实现和数据库设计。此模板确保后端代码的标准化、可维护性和高性能，为分离式开发提供完整的后端实现指导。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`$GLOBAL_FILE`
   - 当前模块 PRD：`$MODULE_FILE`
   - API 规范文档：`$API_SPEC_FILE`
   - 技术栈规范：`docs/prd/split/$VERSION/appendix/03-technology-stack.md`
   - 数据库设计规范：`docs/architecture/database-design-guidelines.md`

2. **技术约束**：
   - Java 21 + Spring Boot 3.3.6
   - Spring Security 6.2.1 + Spring Data JPA 3.2.x
   - PostgreSQL 16.6 + Redis 7.4.1
   - 多租户架构，支持数据隔离
   - 微服务架构，支持分布式部署

### AI处理步骤

#### Step 1：架构设计分析
1. **分层架构设计**：
   - 定义Controller、Service、Repository分层结构
   - 确定DTO、Entity、VO的数据流转
   - 建立异常处理和事务管理机制

2. **业务逻辑分析**：
   - 从API规范中提取业务操作需求
   - 识别核心业务规则和验证逻辑
   - 确定跨模块集成和事件处理

#### Step 2：数据库设计
1. **实体关系设计**：
   - 基于API数据模型设计JPA实体
   - 定义实体间的关联关系和约束
   - 优化数据库索引和查询性能

2. **数据访问层设计**：
   - 设计Repository接口和自定义查询
   - 配置缓存策略和数据同步
   - 实现数据完整性和事务控制

### 输出要求
生成文件：`docs/ai_prd/$VERSION/backend/$MODULE_ID-backend-prd.md`

**后端专用结构化文档格式**：

#### 1. 后端架构配置 (BACKEND_ARCHITECTURE_SPEC)
```yaml
backend_architecture_spec:
  module_id: $MODULE_ID
  module_name: $MODULE_NAME
  architecture_pattern: "Layered Architecture"
  
  technology_stack:
    java_version: "21"
    spring_boot_version: "3.3.6"
    spring_security_version: "6.2.1"
    spring_data_jpa_version: "3.2.x"
    database: "PostgreSQL 16.6"
    cache: "Redis 7.4.1"
    build_tool: "Maven 3.9.6"
  
  package_structure:
    base_package: "com.fxtech.portal"
    module_package: "com.fxtech.portal.{module}"
    layers:
      - layer: "controller"
        package: "com.fxtech.portal.{module}.controller"
        description: "REST API控制器层"
      - layer: "service"
        package: "com.fxtech.portal.{module}.service"
        description: "业务逻辑服务层"
      - layer: "repository"
        package: "com.fxtech.portal.{module}.repository"
        description: "数据访问层"
      - layer: "entity"
        package: "com.fxtech.portal.{module}.entity"
        description: "JPA实体层"
      - layer: "dto"
        package: "com.fxtech.portal.{module}.dto"
        description: "数据传输对象"
      - layer: "config"
        package: "com.fxtech.portal.{module}.config"
        description: "模块配置类"
      - layer: "exception"
        package: "com.fxtech.portal.{module}.exception"
        description: "自定义异常类"
  
  design_patterns:
    - pattern: "Dependency Injection"
      implementation: "Spring IoC Container"
      usage: "所有组件通过@Autowired注入依赖"
    - pattern: "Repository Pattern"
      implementation: "Spring Data JPA"
      usage: "数据访问层统一接口"
    - pattern: "Service Layer Pattern"
      implementation: "Spring @Service"
      usage: "业务逻辑封装和事务管理"
    - pattern: "DTO Pattern"
      implementation: "MapStruct映射"
      usage: "Entity与DTO之间的数据转换"
```

#### 2. 数据模型设计 (BACKEND_DATA_MODEL_SPEC)
```yaml
backend_data_model_spec:
  base_entity:
    class_name: "BaseEntity"
    package: "com.fxtech.portal.common.entity"
    fields:
      - name: "id"
        type: "Long"
        annotations: ["@Id", "@GeneratedValue(strategy = GenerationType.IDENTITY)"]
      - name: "tenantId"
        type: "Long"
        annotations: ["@Column(name = \"tenant_id\", nullable = false)"]
      - name: "createdAt"
        type: "LocalDateTime"
        annotations: ["@CreationTimestamp", "@Column(name = \"created_at\")"]
      - name: "updatedAt"
        type: "LocalDateTime"
        annotations: ["@UpdateTimestamp", "@Column(name = \"updated_at\")"]
      - name: "createdBy"
        type: "Long"
        annotations: ["@Column(name = \"created_by\")"]
      - name: "updatedBy"
        type: "Long"
        annotations: ["@Column(name = \"updated_by\")"]
      - name: "version"
        type: "Integer"
        annotations: ["@Version"]
      - name: "deleted"
        type: "Boolean"
        annotations: ["@Column(name = \"deleted\", nullable = false)"]
        default_value: "false"

  entities:
    - name: "[EntityName]Entity"
      table_name: "[table_name]"
      description: "[实体描述]"
      extends: "BaseEntity"
      
      fields:
        - name: "[fieldName]"
          type: "[JavaType]"
          column_name: "[column_name]"
          nullable: [true/false]
          unique: [true/false]
          length: [number]
          precision: [number]
          scale: [number]
          
          jpa_annotations:
            - "@Column(name = \"[column_name]\", nullable = [nullable], unique = [unique], length = [length])"
          
          validation_annotations:
            - "@NotNull(message = \"[字段]不能为空\")"
            - "@NotBlank(message = \"[字段]不能为空\")"
            - "@Size(min = [min], max = [max], message = \"[字段]长度必须在{min}-{max}之间\")"
            - "@Email(message = \"邮箱格式不正确\")"
            - "@Pattern(regexp = \"[regex]\", message = \"[字段]格式不正确\")"
          
          business_rules:
            - rule: "[业务规则描述]"
              validation: "[验证逻辑]"
      
      relationships:
        - type: "OneToMany"
          target_entity: "[TargetEntity]"
          mapped_by: "[fieldName]"
          cascade: "CascadeType.ALL"
          fetch: "FetchType.LAZY"
          annotations: ["@OneToMany(mappedBy = \"[fieldName]\", cascade = CascadeType.ALL, fetch = FetchType.LAZY)"]
        
        - type: "ManyToOne"
          target_entity: "[TargetEntity]"
          join_column: "[column_name]"
          fetch: "FetchType.LAZY"
          annotations: ["@ManyToOne(fetch = FetchType.LAZY)", "@JoinColumn(name = \"[column_name]\")"]
      
      indexes:
        - name: "idx_[table_name]_[field_names]"
          fields: ["[field1]", "[field2]"]
          type: "BTREE"
          unique: [true/false]
          annotation: "@Index(name = \"idx_[table_name]_[field_names]\", columnList = \"[field1], [field2]\")"
      
      constraints:
        - name: "uk_[table_name]_[field_names]"
          type: "UNIQUE"
          fields: ["[field1]", "[field2]"]
        - name: "chk_[table_name]_[field_name]"
          type: "CHECK"
          condition: "[field_name] IN ('[value1]', '[value2]')"

  enums:
    - name: "[EnumName]"
      description: "[枚举描述]"
      values:
        - name: "[VALUE_NAME]"
          description: "[值描述]"
          database_value: "[db_value]"
      
      annotations:
        - "@Enumerated(EnumType.STRING)"

  dto_mappings:
    - entity: "[EntityName]Entity"
      dtos:
        - name: "[EntityName]DTO"
          type: "response"
          description: "标准响应DTO"
          includes: ["基础字段", "业务字段"]
          excludes: ["敏感字段", "内部字段"]
        
        - name: "[EntityName]DetailDTO"
          type: "response"
          description: "详情响应DTO"
          includes: ["所有字段", "关联对象"]
          lazy_loading: true
        
        - name: "[EntityName]CreateRequest"
          type: "request"
          description: "创建请求DTO"
          required_fields: ["[field1]", "[field2]"]
          validation_groups: ["Create.class"]
        
        - name: "[EntityName]UpdateRequest"
          type: "request"
          description: "更新请求DTO"
          partial_update: true
          validation_groups: ["Update.class"]
```

#### 3. 业务逻辑设计 (BACKEND_BUSINESS_LOGIC_SPEC)
```yaml
backend_business_logic_spec:
  service_layer:
    - interface: "[EntityName]Service"
      implementation: "[EntityName]ServiceImpl"
      description: "[实体]业务逻辑服务"
      
      annotations:
        interface: []
        implementation: ["@Service", "@Transactional", "@Slf4j"]
      
      dependencies:
        - "[EntityName]Repository"
        - "[RelatedEntity]Service"
        - "CacheManager"
        - "ApplicationEventPublisher"
      
      methods:
        - name: "findAll"
          description: "分页查询[实体]列表"
          parameters:
            - name: "pageable"
              type: "Pageable"
              description: "分页参数"
            - name: "criteria"
              type: "[EntityName]SearchCriteria"
              description: "查询条件"
              required: false
          
          return_type: "Page<[EntityName]DTO>"
          transaction: "@Transactional(readOnly = true)"
          
          caching:
            enabled: true
            cache_name: "[entity_name]_list"
            key: "#pageable.pageNumber + '_' + #pageable.pageSize + '_' + #criteria?.hashCode()"
            ttl: "300" # 5分钟
          
          business_logic:
            - "应用租户隔离过滤"
            - "根据用户权限过滤数据"
            - "支持动态查询条件"
            - "应用软删除过滤"
          
          implementation_notes:
            - "使用Specification构建动态查询"
            - "应用@TenantFilter自动过滤"
            - "缓存查询结果提升性能"
          
          exception_handling:
            - exception: "IllegalArgumentException"
              condition: "分页参数无效"
              message: "分页参数不能为空且页码不能小于0"
        
        - name: "findById"
          description: "根据ID查询[实体]详情"
          parameters:
            - name: "id"
              type: "Long"
              description: "[实体]ID"
              validation: "@NotNull"
          
          return_type: "[EntityName]DetailDTO"
          transaction: "@Transactional(readOnly = true)"
          
          caching:
            enabled: true
            cache_name: "[entity_name]_detail"
            key: "#id"
            ttl: "600" # 10分钟
          
          business_logic:
            - "验证[实体]存在性"
            - "检查用户访问权限"
            - "加载关联数据"
            - "应用租户隔离"
          
          exception_handling:
            - exception: "[EntityName]NotFoundException"
              condition: "[实体]不存在"
              message: "[实体]不存在或已被删除"
            - exception: "AccessDeniedException"
              condition: "无访问权限"
              message: "您没有权限访问该[实体]"
        
        - name: "create"
          description: "创建新[实体]"
          parameters:
            - name: "request"
              type: "[EntityName]CreateRequest"
              description: "创建请求数据"
              validation: "@Valid"
          
          return_type: "[EntityName]DTO"
          transaction: "@Transactional"
          
          business_logic:
            - "验证业务规则"
            - "检查唯一性约束"
            - "设置默认值"
            - "设置审计字段"
            - "应用租户隔离"
          
          validation_rules:
            - "必填字段验证"
            - "数据格式验证"
            - "业务规则验证"
            - "唯一性验证"
          
          side_effects:
            - "发布[EntityName]CreatedEvent事件"
            - "清除相关缓存"
            - "记录操作日志"
          
          exception_handling:
            - exception: "ValidationException"
              condition: "数据验证失败"
              message: "请求数据不符合验证规则"
            - exception: "DuplicateKeyException"
              condition: "违反唯一性约束"
              message: "[实体]已存在，不能重复创建"
        
        - name: "update"
          description: "更新[实体]信息"
          parameters:
            - name: "id"
              type: "Long"
              description: "[实体]ID"
            - name: "request"
              type: "[EntityName]UpdateRequest"
              description: "更新请求数据"
              validation: "@Valid"
          
          return_type: "[EntityName]DTO"
          transaction: "@Transactional"
          
          business_logic:
            - "验证[实体]存在性"
            - "检查修改权限"
            - "应用业务规则"
            - "处理乐观锁"
            - "更新审计字段"
          
          optimistic_locking:
            enabled: true
            version_field: "version"
            exception: "OptimisticLockingFailureException"
          
          cache_eviction:
            - cache_name: "[entity_name]_detail"
              key: "#id"
            - cache_name: "[entity_name]_list"
              all_entries: true
          
          side_effects:
            - "发布[EntityName]UpdatedEvent事件"
            - "记录变更历史"
            - "通知相关系统"
        
        - name: "delete"
          description: "删除[实体]"
          parameters:
            - name: "id"
              type: "Long"
              description: "[实体]ID"
          
          return_type: "void"
          transaction: "@Transactional"
          
          deletion_strategy: "soft_delete" # 或 "hard_delete"
          
          business_logic:
            - "验证[实体]存在性"
            - "检查删除权限"
            - "检查关联数据"
            - "执行软删除"
            - "处理级联删除"
          
          cascade_rules:
            - "检查子实体依赖"
            - "处理外键约束"
            - "清理关联缓存"
          
          side_effects:
            - "发布[EntityName]DeletedEvent事件"
            - "清除所有相关缓存"
            - "记录删除日志"

  repository_layer:
    - interface: "[EntityName]Repository"
      extends: ["JpaRepository<[EntityName]Entity, Long>", "JpaSpecificationExecutor<[EntityName]Entity>"]
      description: "[实体]数据访问接口"
      
      custom_methods:
        - name: "findByTenantIdAndDeletedFalse"
          description: "查询租户下未删除的[实体]"
          parameters:
            - "tenantId: Long"
            - "pageable: Pageable"
          return_type: "Page<[EntityName]Entity>"
          query_type: "derived"
        
        - name: "findByTenantIdAndStatusIn"
          description: "根据状态查询[实体]"
          parameters:
            - "tenantId: Long"
            - "statuses: List<[Status]>"
          return_type: "List<[EntityName]Entity>"
          query_type: "derived"
        
        - name: "findActiveEntitiesByCustomCriteria"
          description: "自定义复杂查询"
          parameters:
            - "tenantId: Long"
            - "criteria: String"
          return_type: "List<[EntityName]Entity>"
          query_type: "custom"
          query: |
            @Query("SELECT e FROM [EntityName]Entity e WHERE e.tenantId = :tenantId 
                   AND e.deleted = false AND e.status = 'ACTIVE' 
                   AND (e.name LIKE %:criteria% OR e.description LIKE %:criteria%)")
        
        - name: "countByTenantIdAndStatus"
          description: "统计指定状态的[实体]数量"
          parameters:
            - "tenantId: Long"
            - "status: [Status]"
          return_type: "long"
          query_type: "derived"
      
      specifications:
        - name: "[EntityName]Specifications"
          description: "动态查询规范"
          methods:
            - name: "hasName"
              parameter: "String name"
              condition: "name字段模糊匹配"
            - name: "hasStatus"
              parameter: "[Status] status"
              condition: "status字段精确匹配"
            - name: "createdBetween"
              parameters: ["LocalDateTime start", "LocalDateTime end"]
              condition: "创建时间范围查询"
            - name: "belongsToTenant"
              parameter: "Long tenantId"
              condition: "租户隔离条件"

#### 4. 控制器层设计 (BACKEND_CONTROLLER_SPEC)
```yaml
backend_controller_spec:
  controllers:
    - class_name: "[EntityName]Controller"
      base_path: "/api/v1/[resource]"
      description: "[实体]REST API控制器"

      annotations:
        - "@RestController"
        - "@RequestMapping(\"/api/v1/[resource]\")"
        - "@Validated"
        - "@Slf4j"
        - "@Tag(name = \"[EntityName] Management\", description = \"[实体]管理接口\")"

      dependencies:
        - "[EntityName]Service"
        - "SecurityContextHolder"

      endpoints:
        - method: "GET"
          path: "/"
          method_name: "list"
          description: "分页查询[实体]列表"

          parameters:
            - name: "pageable"
              type: "Pageable"
              annotation: "@PageableDefault(size = 20, sort = \"createdAt\", direction = Sort.Direction.DESC)"
            - name: "criteria"
              type: "[EntityName]SearchCriteria"
              annotation: "@ModelAttribute"

          return_type: "ApiResponse<PagedResponse<[EntityName]DTO>>"

          security:
            - "@PreAuthorize(\"hasPermission('[RESOURCE]', 'READ')\")"

          implementation: |
            Page<[EntityName]DTO> result = [entityName]Service.findAll(pageable, criteria);
            return ApiResponse.success(PagedResponse.of(result));

          error_handling:
            - exception: "IllegalArgumentException"
              status: "400"
              message: "请求参数无效"

        - method: "GET"
          path: "/{id}"
          method_name: "getById"
          description: "根据ID查询[实体]详情"

          parameters:
            - name: "id"
              type: "Long"
              annotation: "@PathVariable @Min(1)"

          return_type: "ApiResponse<[EntityName]DetailDTO>"

          security:
            - "@PreAuthorize(\"hasPermission('[RESOURCE]', 'READ')\")"

          implementation: |
            [EntityName]DetailDTO result = [entityName]Service.findById(id);
            return ApiResponse.success(result);

          error_handling:
            - exception: "[EntityName]NotFoundException"
              status: "404"
              message: "[实体]不存在"

        - method: "POST"
          path: "/"
          method_name: "create"
          description: "创建新[实体]"

          parameters:
            - name: "request"
              type: "[EntityName]CreateRequest"
              annotation: "@Valid @RequestBody"

          return_type: "ApiResponse<[EntityName]DTO>"

          security:
            - "@PreAuthorize(\"hasPermission('[RESOURCE]', 'CREATE')\")"

          implementation: |
            [EntityName]DTO result = [entityName]Service.create(request);
            return ApiResponse.success(result);

          validation:
            - "请求体数据验证"
            - "业务规则验证"
            - "权限验证"

        - method: "PUT"
          path: "/{id}"
          method_name: "update"
          description: "更新[实体]信息"

          parameters:
            - name: "id"
              type: "Long"
              annotation: "@PathVariable @Min(1)"
            - name: "request"
              type: "[EntityName]UpdateRequest"
              annotation: "@Valid @RequestBody"

          return_type: "ApiResponse<[EntityName]DTO>"

          security:
            - "@PreAuthorize(\"hasPermission('[RESOURCE]', 'UPDATE')\")"

          implementation: |
            [EntityName]DTO result = [entityName]Service.update(id, request);
            return ApiResponse.success(result);

        - method: "DELETE"
          path: "/{id}"
          method_name: "delete"
          description: "删除[实体]"

          parameters:
            - name: "id"
              type: "Long"
              annotation: "@PathVariable @Min(1)"

          return_type: "ApiResponse<Void>"

          security:
            - "@PreAuthorize(\"hasPermission('[RESOURCE]', 'DELETE')\")"

          implementation: |
            [entityName]Service.delete(id);
            return ApiResponse.success();

  global_exception_handler:
    class_name: "GlobalExceptionHandler"
    annotations: ["@RestControllerAdvice", "@Slf4j"]

    exception_mappings:
      - exception: "ValidationException"
        status: "400"
        error_code: "VALIDATION_ERROR"
        handler_method: "handleValidationException"

      - exception: "[EntityName]NotFoundException"
        status: "404"
        error_code: "RESOURCE_NOT_FOUND"
        handler_method: "handleEntityNotFoundException"

      - exception: "AccessDeniedException"
        status: "403"
        error_code: "ACCESS_DENIED"
        handler_method: "handleAccessDeniedException"

      - exception: "OptimisticLockingFailureException"
        status: "409"
        error_code: "CONCURRENT_MODIFICATION"
        handler_method: "handleOptimisticLockingFailureException"
```

#### 5. 配置和安全 (BACKEND_CONFIG_SPEC)
```yaml
backend_config_spec:
  application_config:
    - class_name: "[ModuleName]Config"
      description: "模块配置类"
      annotations: ["@Configuration", "@EnableJpaRepositories", "@EnableCaching"]

      beans:
        - name: "[entityName]Mapper"
          type: "[EntityName]Mapper"
          description: "实体映射器"
          implementation: "MapStruct自动生成"

        - name: "cacheManager"
          type: "CacheManager"
          description: "缓存管理器"
          implementation: "RedisCacheManager"

        - name: "transactionManager"
          type: "PlatformTransactionManager"
          description: "事务管理器"
          implementation: "JpaTransactionManager"

  security_config:
    tenant_isolation:
      enabled: true
      filter_class: "TenantFilter"
      tenant_resolver: "HeaderTenantResolver"

    method_security:
      enabled: true
      pre_post_enabled: true
      secured_enabled: true

    permission_evaluator:
      class_name: "CustomPermissionEvaluator"
      rules:
        - resource: "[RESOURCE]"
          permissions: ["CREATE", "READ", "UPDATE", "DELETE"]
          roles: ["ADMIN", "USER", "VIEWER"]

  database_config:
    datasource:
      driver: "org.postgresql.Driver"
      url: "jdbc:postgresql://localhost:5432/portal"
      username: "${DB_USERNAME:portal}"
      password: "${DB_PASSWORD:portal123}"

    jpa:
      hibernate:
        ddl_auto: "validate"
        naming_strategy: "org.hibernate.boot.model.naming.CamelCaseToUnderscoresNamingStrategy"

      properties:
        hibernate:
          dialect: "org.hibernate.dialect.PostgreSQLDialect"
          format_sql: true
          show_sql: false

    connection_pool:
      type: "HikariCP"
      maximum_pool_size: 20
      minimum_idle: 5
      connection_timeout: 30000
      idle_timeout: 600000

  cache_config:
    redis:
      host: "localhost"
      port: 6379
      password: "${REDIS_PASSWORD:}"
      database: 0

    cache_configurations:
      - name: "[entity_name]_list"
        ttl: "PT5M" # 5分钟
        max_entries: 1000

      - name: "[entity_name]_detail"
        ttl: "PT10M" # 10分钟
        max_entries: 5000
```

#### 6. 后端验证检查点 (BACKEND_VALIDATION_CHECKPOINTS)
```yaml
backend_validation_checkpoints:
  architecture_validation:
    - check: "分层架构合规性"
      rule: "Controller只调用Service，Service只调用Repository"
      error_message: "必须遵循分层架构原则"

    - check: "依赖注入正确性"
      rule: "所有依赖通过构造函数注入"
      error_message: "使用构造函数注入而非字段注入"

    - check: "实体继承规范"
      rule: "所有实体继承BaseEntity"
      error_message: "业务实体必须继承BaseEntity"

  data_access_validation:
    - check: "Repository接口规范"
      rule: "Repository接口继承JpaRepository和JpaSpecificationExecutor"
      error_message: "Repository必须继承标准接口"

    - check: "事务注解使用"
      rule: "Service方法使用@Transactional注解"
      error_message: "业务方法必须声明事务边界"

    - check: "查询性能优化"
      rule: "N+1查询问题检查"
      error_message: "避免N+1查询问题，使用JOIN FETCH"

  security_validation:
    - check: "权限控制完整性"
      rule: "所有Controller方法包含权限检查"
      error_message: "API端点必须包含权限控制"

    - check: "租户隔离实现"
      rule: "多租户查询包含tenantId过滤"
      error_message: "必须实现租户数据隔离"

    - check: "输入验证完整性"
      rule: "所有输入参数包含验证注解"
      error_message: "输入参数必须包含适当的验证"

  performance_validation:
    - check: "缓存策略配置"
      rule: "频繁查询的方法配置缓存"
      error_message: "高频查询方法应配置缓存"

    - check: "数据库索引优化"
      rule: "查询字段配置适当索引"
      error_message: "频繁查询的字段应建立索引"

    - check: "分页查询支持"
      rule: "列表查询方法支持分页"
      error_message: "列表查询必须支持分页"

  code_quality_validation:
    - check: "异常处理规范"
      rule: "使用统一的异常处理机制"
      error_message: "异常处理必须统一规范"

    - check: "日志记录规范"
      rule: "关键操作包含日志记录"
      error_message: "重要业务操作必须记录日志"

    - check: "代码注释完整性"
      rule: "公共方法包含JavaDoc注释"
      error_message: "公共API必须包含完整注释"
```

### AI处理指令
1. **严格遵循Spring Boot最佳实践**：确保代码符合Spring生态规范
2. **完整性检查**：所有层次的代码必须完整且可编译
3. **一致性验证**：使用BACKEND_VALIDATION_CHECKPOINTS进行自我验证
4. **性能优化**：应用缓存、索引、分页等性能优化策略
5. **安全合规**：实现完整的安全控制和数据隔离

### 质量控制要求
1. **架构规范性**：严格遵循分层架构和设计模式
2. **代码可维护性**：清晰的代码结构和完整的注释
3. **性能达标**：满足响应时间和并发性能要求
4. **安全合规**：完整的权限控制和数据保护
5. **测试覆盖**：单元测试覆盖率≥80%

### 并行开发协调
1. **API契约遵循**：严格按照API规范实现后端接口
2. **数据模型一致**：确保Entity与API数据模型的一致性
3. **错误处理统一**：与前端约定统一的错误响应格式
4. **集成测试支持**：提供完整的集成测试环境
```
