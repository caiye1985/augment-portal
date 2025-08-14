## 任务：完善 IT运维门户系统某模块 API 规范文档

### 背景与目标
基于已完成的全局 API 初始化成果，按模块完善 `docs/api/modules/{MODULE_ID}.yaml` 文件，确保符合三级分离规范（全局/业务域/模块），并且所有设计均可落地，可通过自动化校验，方便 Mock Server 和代码生成工具直接使用。

### 前置要求
1. **参考文档**：
   - 全局上下文：`docs/global-context.md`
   - Mock 数据规范：`docs/prd/split/4.5/globals/05-mock-data-guidelines.md`
   - 当前模块 PRD：`docs/prd/split/4.5/modules/REQ-003.md`
   - API 初始化合并文件：`（文件不存在，跳过引用）`
2. **技术约束**：
   - OpenAPI 3.0.3 规范
   - swagger-cli validate 必须通过
   - 遵循三级分离引用，不重复定义全局/域已有内容
   - 技术栈契合：Spring Boot 3.2.11 + Spring Security

### 实现步骤

#### Step 1：需求分析与端点映射
1. 从模块 PRD 中提炼显性功能点。
2. 结合全局上下文和业务流程，推导隐性接口（如：查询、导出、批量操作、状态流转等）。
3. 列出**端点清单表**（含路径、方法、简述、输入/输出模型引用）。
4. 将端点按业务域正确分组（tags 对应 domain）。

#### Step 2：编写 OpenAPI 模块文件
**路径**：`docs/api/modules/{MODULE_ID}.yaml`

必须包含：
1. `info` 节点（title、version 与 `_global.yaml` 一致）。
2. `tags` 节点（模块标签及描述）。
3. `paths`：  
   - 所有路径以业务域前缀开头（例如 `/api/v1/tickets/...`）  
   - 每个方法包含`summary`、`description`、`operationId`、`parameters`、`requestBody`、`responses`。  
   - operationId 命名规则：`<domain>_<action>`（小写_分隔，动词用英文现在时）。
4. `components.schemas`：  
   - 仅定义**模块独有**的 schema
   - 引用全局或域定义，使用 `$ref: '../_global.yaml#/components/schemas/...'` 或 `$ref: '../domains/{domain}.yaml#/components/schemas/...'`。
5. 响应：
   - **成功响应**（`200`）引用全局 `ApiResponse` 或 `PagedResponse`。
   - **错误响应**（`400` / `401` / `403` / `404` / `409` / `500`）必须引用全局标准错误响应模型。

#### Step 3：数据与示例要求
1. 所有 schema 字段必须严格匹配类型要求。
2. 枚举完整列出所有值，每个值要有清晰意义描述。
3. 所有字段包含符合 Mock 数据规范的 `example` 值。
4. 所有时间字段统一 ISO8601 格式（例如 `2024-01-15T10:30:00Z`）。

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
1. 输出完整的 `docs/api/modules/{MODULE_ID}.yaml` 文件内容。
2. 不包含全局/域级 schema 的重复定义。
3. 所有示例数据必须符合 Mock 数据规范，贴合 IT运维业务语境。
4. 文件可独立通过 swagger-cli validate。

### 验证命令
```bash
swagger-cli validate docs/api/modules/{MODULE_ID}.yaml
