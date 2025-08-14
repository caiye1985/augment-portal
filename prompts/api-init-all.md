## Step 0：全局初始化 API
- 全局上下文：<file://docs/global-context.md>
- Mock 数据规范：<file://docs/prd/split/4.5/globals/05-mock-data-guidelines.md>
- 本次为初始生成，需为后续迭代建立统一基础结构

## Step 1：生成文件
1. **docs/api/_global.yaml**：必须包含
   - `openapi`、`info`（title、version、description）
   - **安全方案**：Bearer JWT / OAuth2 / SSO 配置
   - **全局参数**：分页参数（`page`、`size`）、排序、语言(locale)
   - **标准响应结构**：
     ```yaml
ApiResponse:
       type: object
       properties:
         code:
           type: integer
           example: 200
         message:
           type: string
           example: OK
         data:
           type: object
```
   - **错误响应 schema**（400/401/403/404/409/500）
   - **分页结果 schema**，可复用于所有列表接口
2. **docs/api/domains/{domain}.yaml**：
   - 当前业务域公共 paths 前缀（/tickets, /users …）
   - 业务域专用 schema（复用全局schema，通过 `` 引用）
3. **docs/api/modules/{MODULE}.yaml**（占位）：
   - `info`：title={模块名}，version同步全局
   - `paths`：空对象或示例路径
   - `components.schemas`：空对象，用 `` 引用全局/域模型

## Step 2：字段与示例
- 所有 schema 字段必须有符合 Mock 数据规范的 example
- 统一时间格式为 ISO8601 `date-time`

## Step 3：统一规范
- 三级分离（全局/域/模块）
- API路径命名：全部小写，单词用`-`分隔，资源名用复数
- HTTP方法：GET=查询、POST=新建、PUT=全量更新、PATCH=部分更新、DELETE=删除

## Step 4：输出要求
- 输出的 YAML 可被 `swagger-cli validate` 验证无误
- 每个文件单独输出，不要合并
