## 任务：生成 AI开发助手专用的API规范PRD文档

### 背景与目标
为API开发专门优化的PRD模板，专注于OpenAPI规范定义、接口契约设计和Mock Server配置。此模板确保API设计的标准化和一致性，为前后端分离开发提供可靠的接口契约基础。

### 前置要求
1. **核心参考文档**：
   - 全局上下文：`$GLOBAL_FILE`
   - 当前模块 PRD：`$MODULE_FILE`
   - 技术栈规范：`docs/prd/split/$VERSION/appendix/03-technology-stack.md`
   - API设计规范：`docs/api/design-guidelines.md`

2. **技术约束**：
   - 严格遵循 OpenAPI 3.0.3 规范
   - RESTful API设计原则
   - 统一错误处理和响应格式
   - 支持Mock Server和API测试
   - API版本管理和向后兼容

### AI处理步骤

#### Step 1：API需求分析
1. **业务接口识别**：
   - 从模块PRD中提取所有业务功能点
   - 识别CRUD操作和业务流程接口
   - 确定批量操作和查询接口需求

2. **数据模型设计**：
   - 定义核心业务实体的数据结构
   - 设计请求和响应DTO模型
   - 建立实体间的关联关系

#### Step 2：OpenAPI规范生成
1. **接口定义标准化**：
   - 生成完整的OpenAPI YAML规范
   - 定义标准化的请求/响应格式
   - 建立统一的错误处理机制

2. **Mock数据配置**：
   - 为所有接口提供Mock响应数据
   - 配置Mock Server启动脚本
   - 生成API测试用例

### 输出要求
生成文件：`docs/ai_prd/$VERSION/api/$MODULE_ID-api-prd.md`

**API专用结构化文档格式**：

#### 1. API概述配置 (API_OVERVIEW_SPEC)
```yaml
api_overview_spec:
  module_id: $MODULE_ID
  module_name: $MODULE_NAME
  api_version: "v1"
  base_path: "/api/v1"
  description: "[API模块功能描述]"
  
  business_domains:
    - domain: "[业务域名称]"
      description: "[业务域描述]"
      resources: ["[资源1]", "[资源2]"]
  
  integration_contracts:
    - target_module: "[目标模块]"
      interface_type: "REST_API"
      endpoints: ["/api/v1/[resource]"]
      data_format: "JSON"
```

#### 2. 数据模型规范 (API_DATA_MODEL_SPEC)
```yaml
api_data_model_spec:
  entities:
    - name: "[EntityName]"
      description: "[实体描述]"
      properties:
        - name: "id"
          type: "integer"
          format: "int64"
          description: "[实体]唯一标识"
          example: 12345
          required: true
        - name: "tenantId"
          type: "integer"
          format: "int64"
          description: "租户ID"
          example: 1001
          required: true
        - name: "[fieldName]"
          type: "[dataType]"
          format: "[format]"
          description: "[字段描述]"
          example: "[示例值]"
          required: [true/false]
          validation:
            - rule: "[验证规则]"
            - message: "[错误信息]"
      
      relationships:
        - type: "reference"
          target: "[TargetEntity]"
          field: "[fieldName]"
          description: "[关联描述]"

  request_models:
    - name: "[EntityName]CreateRequest"
      description: "创建[实体]请求模型"
      required_fields: ["[field1]", "[field2]"]
      optional_fields: ["[field3]", "[field4]"]
      validation_rules:
        - field: "[fieldName]"
          rules: ["@NotNull", "@Size(max=255)"]
    
    - name: "[EntityName]UpdateRequest"
      description: "更新[实体]请求模型"
      partial_update: true
      version_control: true

  response_models:
    - name: "[EntityName]DTO"
      description: "[实体]响应模型"
      includes_audit_fields: true
      
    - name: "[EntityName]DetailDTO"
      description: "[实体]详情响应模型"
      includes_associations: true
      
    - name: "[EntityName]ListDTO"
      description: "[实体]列表响应模型"
      optimized_for_list: true

  common_models:
    - name: "ApiResponse"
      description: "标准API响应包装器"
      structure:
        - field: "success"
          type: "boolean"
          description: "操作是否成功"
        - field: "message"
          type: "string"
          description: "响应消息"
        - field: "data"
          type: "object"
          description: "响应数据"
        - field: "timestamp"
          type: "string"
          format: "date-time"
          description: "响应时间戳"
    
    - name: "PagedResponse"
      description: "分页响应模型"
      extends: "ApiResponse"
      additional_fields:
        - field: "pagination"
          type: "PaginationInfo"
          description: "分页信息"
    
    - name: "ErrorResponse"
      description: "错误响应模型"
      structure:
        - field: "error_code"
          type: "string"
          description: "错误代码"
        - field: "error_message"
          type: "string"
          description: "错误描述"
        - field: "field_errors"
          type: "array"
          description: "字段验证错误"
```

#### 3. API端点规范 (API_ENDPOINTS_SPEC)
```yaml
api_endpoints_spec:
  base_configuration:
    base_url: "http://localhost:8080"
    api_prefix: "/api/v1"
    content_type: "application/json"
    authentication: "Bearer Token"
    
  endpoint_groups:
    - group: "[resource]"
      description: "[资源]管理接口"
      base_path: "/[resource]"
      
      endpoints:
        - method: "GET"
          path: "/"
          operation_id: "[resource]_list"
          summary: "查询[资源]列表"
          description: "分页查询[资源]列表，支持筛选和排序"
          
          parameters:
            - name: "page"
              in: "query"
              type: "integer"
              default: 0
              description: "页码（从0开始）"
              example: 0
            - name: "size"
              in: "query"
              type: "integer"
              default: 20
              minimum: 1
              maximum: 100
              description: "每页大小"
              example: 20
            - name: "[filterField]"
              in: "query"
              type: "[fieldType]"
              required: false
              description: "[筛选字段描述]"
              example: "[示例值]"
          
          responses:
            "200":
              description: "查询成功"
              content_type: "application/json"
              schema: "PagedResponse<[EntityName]DTO>"
              example: |
                {
                  "success": true,
                  "message": "查询成功",
                  "data": {
                    "content": [
                      {
                        "id": 1,
                        "name": "示例数据",
                        "createdAt": "2024-01-15T10:30:00Z"
                      }
                    ],
                    "pagination": {
                      "page": 0,
                      "size": 20,
                      "total": 1,
                      "totalPages": 1
                    }
                  },
                  "timestamp": "2024-01-15T10:30:00Z"
                }
            "400":
              description: "请求参数错误"
              schema: "ErrorResponse"
            "401":
              description: "未授权访问"
              schema: "ErrorResponse"
            "403":
              description: "权限不足"
              schema: "ErrorResponse"
            "500":
              description: "服务器内部错误"
              schema: "ErrorResponse"
          
          caching:
            enabled: true
            ttl_seconds: 300
            cache_key: "[resource]_list_{params_hash}"
          
          rate_limiting:
            requests_per_minute: 100
            burst_limit: 20
        
        - method: "GET"
          path: "/{id}"
          operation_id: "[resource]_get"
          summary: "查询[资源]详情"
          description: "根据ID查询[资源]详细信息"
          
          parameters:
            - name: "id"
              in: "path"
              type: "integer"
              format: "int64"
              required: true
              description: "[资源]唯一标识"
              example: 12345
          
          responses:
            "200":
              description: "查询成功"
              schema: "ApiResponse<[EntityName]DetailDTO>"
            "404":
              description: "[资源]不存在"
              schema: "ErrorResponse"
          
          caching:
            enabled: true
            ttl_seconds: 600
            cache_key: "[resource]_detail_{id}"
        
        - method: "POST"
          path: "/"
          operation_id: "[resource]_create"
          summary: "创建[资源]"
          description: "创建新的[资源]记录"
          
          request_body:
            required: true
            content_type: "application/json"
            schema: "[EntityName]CreateRequest"
            example: |
              {
                "name": "新[资源]名称",
                "description": "[资源]描述",
                "category": "[分类]"
              }
          
          responses:
            "200":
              description: "创建成功"
              schema: "ApiResponse<[EntityName]DTO>"
            "400":
              description: "请求数据验证失败"
              schema: "ErrorResponse"
          
          validation:
            - "请求体必须包含所有必填字段"
            - "字段格式必须符合定义规范"
            - "业务规则验证必须通过"
        
        - method: "PUT"
          path: "/{id}"
          operation_id: "[resource]_update"
          summary: "更新[资源]"
          description: "更新指定[资源]的信息"
          
          parameters:
            - name: "id"
              in: "path"
              type: "integer"
              format: "int64"
              required: true
              description: "[资源]唯一标识"
          
          request_body:
            required: true
            content_type: "application/json"
            schema: "[EntityName]UpdateRequest"
          
          responses:
            "200":
              description: "更新成功"
              schema: "ApiResponse<[EntityName]DTO>"
            "404":
              description: "[资源]不存在"
              schema: "ErrorResponse"
            "409":
              description: "版本冲突"
              schema: "ErrorResponse"
          
          cache_invalidation:
            - "[resource]_detail_{id}"
            - "[resource]_list"
        
        - method: "DELETE"
          path: "/{id}"
          operation_id: "[resource]_delete"
          summary: "删除[资源]"
          description: "删除指定的[资源]记录"
          
          parameters:
            - name: "id"
              in: "path"
              type: "integer"
              format: "int64"
              required: true
              description: "[资源]唯一标识"
          
          responses:
            "200":
              description: "删除成功"
              schema: "ApiResponse<Void>"
            "404":
              description: "[资源]不存在"
              schema: "ErrorResponse"
            "409":
              description: "存在关联数据，无法删除"
              schema: "ErrorResponse"
          
          cache_invalidation:
            - "[resource]_detail_{id}"
            - "[resource]_list"

#### 4. Mock Server配置 (MOCK_SERVER_SPEC)
```yaml
mock_server_spec:
  configuration:
    port: 3000
    host: "localhost"
    base_path: "/api/v1"
    cors_enabled: true

  mock_data:
    - endpoint: "GET /[resource]"
      scenarios:
        - name: "success_with_data"
          response_code: 200
          response_body: |
            {
              "success": true,
              "message": "查询成功",
              "data": {
                "content": [
                  {
                    "id": 1,
                    "name": "示例[资源]1",
                    "status": "ACTIVE",
                    "createdAt": "2024-01-15T10:30:00Z"
                  }
                ],
                "pagination": {
                  "page": 0,
                  "size": 20,
                  "total": 1,
                  "totalPages": 1
                }
              },
              "timestamp": "2024-01-15T10:30:00Z"
            }

  startup_script: |
    #!/bin/bash
    echo "启动Mock Server..."
    prism mock docs/api/$VERSION/modules/$MODULE_ID/openapi.yaml --port 3000 --host localhost
    echo "Mock Server已启动: http://localhost:3000"
```

#### 5. API验证检查点 (API_VALIDATION_CHECKPOINTS)
```yaml
api_validation_checkpoints:
  openapi_compliance:
    - check: "OpenAPI 3.0.3规范合规性"
      rule: "所有API定义符合OpenAPI 3.0.3标准"
      validation_command: "swagger-cli validate openapi.yaml"

    - check: "响应模型一致性"
      rule: "所有响应使用标准ApiResponse包装器"
      error_message: "API响应必须使用统一的响应格式"

  data_model_validation:
    - check: "数据模型完整性"
      rule: "所有实体包含必要的审计字段"
      required_fields: ["id", "tenantId", "createdAt", "updatedAt"]

    - check: "字段验证规则"
      rule: "所有输入字段包含适当的验证规则"
      error_message: "输入字段必须包含验证注解"

  security_validation:
    - check: "认证机制"
      rule: "所有敏感接口包含认证要求"
      error_message: "敏感接口必须要求身份认证"

    - check: "权限控制"
      rule: "所有接口定义权限要求"
      error_message: "接口必须定义访问权限要求"

  performance_validation:
    - check: "分页支持"
      rule: "列表查询接口支持分页"
      error_message: "列表接口必须支持分页查询"

    - check: "缓存策略"
      rule: "频繁访问的接口配置缓存"
      error_message: "高频接口应配置适当的缓存策略"

  mock_server_validation:
    - check: "Mock数据完整性"
      rule: "所有接口提供Mock响应数据"
      error_message: "每个接口都必须提供Mock数据"

    - check: "Mock Server可启动性"
      rule: "Mock Server配置正确且可正常启动"
      validation_command: "prism mock openapi.yaml --port 3000"
```

### AI处理指令
1. **严格遵循OpenAPI 3.0.3规范**：确保生成的API文档符合标准
2. **完整性检查**：所有接口必须包含完整的请求/响应定义
3. **一致性验证**：使用API_VALIDATION_CHECKPOINTS进行自我验证
4. **Mock数据质量**：提供真实可用的Mock响应数据
5. **测试用例完整**：覆盖功能、安全、性能等各个方面

### 质量控制要求
1. **API设计规范性**：符合RESTful设计原则和项目API规范
2. **数据模型准确性**：数据结构定义准确，验证规则完整
3. **Mock Server可用性**：Mock配置正确，可直接启动使用
4. **文档可读性**：API文档清晰易懂，便于前后端开发人员理解

### 并行开发协调
1. **接口契约优先**：API规范作为前后端开发的契约基础
2. **Mock Server支持**：为前端开发提供可用的Mock服务
3. **版本管理**：API版本变更的向后兼容性保证
4. **集成测试**：提供完整的API集成测试方案
```
