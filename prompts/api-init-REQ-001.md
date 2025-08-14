## 任务：初始化 IT运维门户系统 OpenAPI 规范文档

### 背景与目标
基于项目全局上下文和 Mock 数据规范，为 IT运维门户系统建立统一的 API 文档基础架构，采用三级分离设计（全局/业务域/模块），为后续迭代开发提供标准化基础。

### 前置要求
1. **参考文档**：
   - 全局上下文：`docs/global-context.md`
   - Mock 数据规范：`docs/prd/split/4.5/globals/05-mock-data-guidelines.md`
2. **技术约束**：
   - 遵循 OpenAPI 3.0.3 规范
   - 所有生成 YAML 文件必须通过 `swagger-cli validate` 验证
   - 符合项目后端技术栈：Spring Boot 3.2.11 + Spring Security

### 实现步骤

#### Step 1：创建全局 API 规范文件
**路径**：`docs/api/_global.yaml`

**必须包含**：
1. 基础信息
   - `openapi: 3.0.3`
   - `info`（title、version、description）
   - `x-api-version` 自定义字段（全局版本号，模块需保持一致）
2. 安全认证方案（components.securitySchemes）
   - Bearer JWT
   - OAuth2（如适用）
   - SSO（如适用）
3. 全局通用参数（components.parameters）
   - 分页（page, size）、排序（sort）、国际化（locale）
4. 标准响应结构（components.schemas.ApiResponse）
5. 错误响应模型（components.responses + components.schemas.ErrorResponseXXX）
6. 分页响应模型（PagedResponse）
7. 全局 tags 定义（模块标签）

#### Step 2：创建业务域文件
**路径**：`docs/api/domains/{domain}.yaml`

**每个域文件包含**：
1. 域路径前缀（tags / description）
2. 域特有 schema
3. `$ref: '../_global.yaml#/components/schemas/...'` 引用全局通用组件
4. 不得直接引用其他域，跨域复用必须走全局

#### Step 3：创建模块占位文件
**路径**：`docs/api/modules/{MODULE}.yaml`

**占位文件内容**：
1. `info`（title="{模块名} API"，version 与全局一致）
2. `paths`：至少一个占位 endpoint（确保验证通过）
3. `components.schemas`：空，后续迭代填充
4. 引用全局/域模板的 `$ref` 示例

#### Step 4：数据规范要求
- 所有字段 example 必须符合 `docs/prd/split/4.5/globals/05-mock-data-guidelines.md`
- 时间统一 ISO8601
- API 路径全小写，单词用 `-`，资源复数形式
- schema 名 PascalCase，DTO/VO/ID 后缀规范

#### Step 5：HTTP 方法语义
- GET/POST/PUT/PATCH/DELETE
- OPTIONS：跨域预检（如需）
- HEAD：获取元数据（如需）

### 输出要求
- 每个文件独立、合法可验
- 文件间引用有效
- 示例数据符合 IT 运维业务特征

### 验证命令
```bash
swagger-cli validate docs/api/_global.yaml
swagger-cli validate docs/api/domains/*.yaml
swagger-cli validate docs/api/modules/*.yaml
