# Mock 数据编写规范

本规范适用于 `openapi.yaml` 及 API Markdown 文档 (`api-docs.md`) 中 **所有字段** 的 `example` 编写规则。  
目标：生成的 Mock 数据可以直接供 Prism Mock Server、Swagger UI、Postman、前端/移动端程序调试，确保类型正确、值合理，模拟接近真实场景的接口返回。

---

## 1. 编写原则

1. **类型匹配**  
   - `string` → 用符合业务含义的字符串（如订单号、姓名、状态描述）
   - `integer` → 用符合范围的整数
   - `number` → 用带小数的数值，保留 1~2 位小数
   - `boolean` → `true` 或 `false`
   - `date` / `date-time` → 使用符合 ISO 8601 标准的时间（UTC 推荐）
   - `email` → 合法邮箱格式
   - `uri` / `url` → 合法 URL（http/https）

2. **语义化命名**  
   - 避免使用 `"string"`, `"test"`, `123` 这类无意义示例
   - 根据业务语义给出真实感数据，如 `"张三"`, `"ORD-20250301-0001"`

3. **枚举值**  
   - 枚举类字段在 `enum` 中列出所有可能值
   - `example` 设置为最常见或默认值
   - 示例：
     ```yaml
status:
       type: string
       enum: [pending, processing, completed, failed]
       example: "pending"
```

4. **ID / 编号类字段**  
   - 规则：大写字母前缀 + 年月日 + 自增序号
   - 示例：`"TCK-20250301-0001"`

5. **金额 / 数量**  
   - `number` 类型，保留两位小数
   - 示例：`99.99`

6. **描述类字段（description/remark）**  
   - 提供符合业务背景的简短描述
   - 示例：`"客户反馈系统响应缓慢"`

---

## 2. 特殊字段规范

| 字段类型    | 示例数据 | 说明 |
|------------|----------|------|
| 手机号      | `"13800138000"` | 国内手机号格式 |
| 邮箱        | `"user@example.com"` | 合法邮箱地址 |
| URL        | `"https://cdn.example.com/image.png"` | 静态资源链接 |
| 时间戳（秒） | `1709452800` | Unix 时间戳 |
| 日期        | `"2025-03-02"` | RFC3339 |
| 日期时间    | `"2025-03-02T12:00:00Z"` | UTC 时间 |

---

## 3. Mock 示例生成约定（API文档中）

在 `api-docs.md` 每个接口的响应示例后 **额外增加一个 "Mock 数据示例" 区块**：
```markdown
#### Mock 数据示例
```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "ticket_id": "TCK-20250301-0001",
    "status": "pending",
    "priority": "high",
    "created_at": "2025-03-01T08:00:00Z"
  }
}
# Mock 数据编写规范

本规范适用于 `openapi.yaml` 及 API Markdown 文档 (`api-docs.md`) 中 **所有字段** 的 `example` 编写规则。  
目标：生成的 Mock 数据可以直接供 Prism Mock Server、Swagger UI、Postman、前端/移动端程序调试，确保类型正确、值合理，模拟接近真实场景的接口返回。

---

## 1. 编写原则

1. **类型匹配**  
   - `string` → 用符合业务含义的字符串（如订单号、姓名、状态描述）
   - `integer` → 用符合范围的整数
   - `number` → 用带小数的数值，保留 1~2 位小数
   - `boolean` → `true` 或 `false`
   - `date` / `date-time` → 使用符合 ISO 8601 标准的时间（UTC 推荐）
   - `email` → 合法邮箱格式
   - `uri` / `url` → 合法 URL（http/https）

2. **语义化命名**  
   - 避免使用 `"string"`, `"test"`, `123` 这类无意义示例
   - 根据业务语义给出真实感数据，如 `"张三"`, `"ORD-20250301-0001"`

3. **枚举值**  
   - 枚举类字段在 `enum` 中列出所有可能值
   - `example` 设置为最常见或默认值
   - 示例：
     ```yaml
     status:
       type: string
       enum: [pending, processing, completed, failed]
       example: "pending"
     ```

4. **ID / 编号类字段**  
   - 规则：大写字母前缀 + 年月日 + 自增序号
   - 示例：`"TCK-20250301-0001"`

5. **金额 / 数量**  
   - `number` 类型，保留两位小数
   - 示例：`99.99`

6. **描述类字段（description/remark）**  
   - 提供符合业务背景的简短描述
   - 示例：`"客户反馈系统响应缓慢"`

---

## 2. 特殊字段规范

| 字段类型    | 示例数据 | 说明 |
|------------|----------|------|
| 手机号      | `"13800138000"` | 国内手机号格式 |
| 邮箱        | `"user@example.com"` | 合法邮箱地址 |
| URL        | `"https://cdn.example.com/image.png"` | 静态资源链接 |
| 时间戳（秒） | `1709452800` | Unix 时间戳 |
| 日期        | `"2025-03-02"` | RFC3339 |
| 日期时间    | `"2025-03-02T12:00:00Z"` | UTC 时间 |

---

## 3. Mock 示例生成约定（API文档中）

在 `api-docs.md` 每个接口的响应示例后 **额外增加一个 "Mock 数据示例" 区块**：
```markdown
#### Mock 数据示例
```json
{
  "code": 200,
  "message": "OK",
  "data": {
    "ticket_id": "TCK-20250301-0001",
    "status": "pending",
    "priority": "high",
    "created_at": "2025-03-01T08:00:00Z"
  }
}
