# Mock 数据编写规范 v4.5.1

本规范适用于 `openapi.yaml` 及 API Markdown 文档 (`api-docs.md`) 中 **所有字段** 的 `example` 编写规则。  
目标：生成的 Mock 数据可以直接供 Prism Mock Server、Swagger UI、Postman、前端/移动端程序调试，确保类型正确、值合理，模拟接近真实场景的接口返回。

**v4.5.1版本更新说明：**
- 新增工程师管理模块（REQ-006）相关的Mock数据规范
- 统一工程师基础管理和高级管理的数据格式
- 完善技能管理、排班管理、绩效评估的示例数据

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

## 3. 工程师管理模块Mock数据规范（v4.5.1新增）

### 3.1 工程师档案数据

```json
{
  "engineer_id": 1001,
  "employee_no": "ENG001",
  "real_name": "张三",
  "gender": 1,
  "birth_date": "1990-05-15",
  "phone": "13800138000",
  "email": "zhangsan@company.com",
  "department_id": 101,
  "department_name": "运维部",
  "position": "高级运维工程师",
  "level": 3,
  "hire_date": "2022-08-01",
  "status": 1,
  "work_location": "北京总部",
  "current_workload": 3,
  "online_status": "online",
  "last_active_time": "2025-08-14T14:30:00Z",
  "created_at": "2022-08-01T09:00:00Z",
  "updated_at": "2025-08-14T14:30:00Z"
}
```

### 3.2 技能管理数据

```json
{
  "skill_id": 2001,
  "engineer_id": 1001,
  "skill_code": "linux",
  "skill_name": "Linux系统管理",
  "skill_level": 3,
  "experience_years": 3.5,
  "certification_status": 2,
  "certification_date": "2024-06-15",
  "certification_expiry": "2026-06-15",
  "certification_authority": "Red Hat",
  "proficiency_score": 85.5,
  "last_used_date": "2025-08-14",
  "created_at": "2022-08-01T09:00:00Z",
  "updated_at": "2025-08-14T14:30:00Z"
}
```

### 3.3 排班管理数据

```json
{
  "schedule_id": 3001,
  "engineer_id": 1001,
  "engineer_name": "张三",
  "schedule_date": "2025-08-15",
  "shift_type": "day",
  "start_time": "09:00",
  "end_time": "17:00",
  "work_location": "北京总部",
  "priority_level": 2,
  "required_skills": ["linux", "docker", "kubernetes"],
  "status": 2,
  "conflict_status": 0,
  "auto_assigned": true,
  "assignment_reason": "技能匹配度95%，工作负载适中",
  "created_at": "2025-08-14T14:30:00Z",
  "updated_at": "2025-08-14T14:30:00Z"
}
```

### 3.4 绩效评估数据

```json
{
  "evaluation_id": 4001,
  "engineer_id": 1001,
  "engineer_name": "张三",
  "evaluation_period": "2024Q3",
  "evaluation_type": 2,
  "ticket_completion_rate": 97.5,
  "ticket_quality_score": 88.5,
  "customer_satisfaction": 4.7,
  "sla_compliance_rate": 95.2,
  "avg_resolution_time": 3.2,
  "first_call_resolution_rate": 85.0,
  "skill_improvement_score": 90.0,
  "teamwork_score": 88.0,
  "final_score": 91.8,
  "performance_level": "优秀",
  "ranking_percentile": 85.0,
  "status": 3,
  "created_at": "2024-10-01T09:00:00Z",
  "updated_at": "2024-10-15T17:00:00Z"
}
```

---

## 4. 业务域数据规范

### 4.1 工单管理域

```json
{
  "ticket_id": "TCK-20250814-0001",
  "title": "服务器CPU使用率过高",
  "description": "生产服务器CPU使用率持续超过90%，影响业务正常运行",
  "priority": "high",
  "status": "processing",
  "customer_id": 5001,
  "customer_name": "ABC科技有限公司",
  "assigned_engineer_id": 1001,
  "assigned_engineer_name": "张三",
  "created_at": "2025-08-14T10:00:00Z",
  "updated_at": "2025-08-14T14:30:00Z",
  "due_date": "2025-08-14T18:00:00Z"
}
```

### 4.2 客户管理域

```json
{
  "customer_id": 5001,
  "company_name": "ABC科技有限公司",
  "contact_person": "李经理",
  "contact_phone": "13900139000",
  "contact_email": "li.manager@abc-tech.com",
  "industry": "互联网",
  "company_size": "中型企业",
  "service_level": "专业版",
  "contract_start_date": "2024-01-01",
  "contract_end_date": "2024-12-31",
  "status": "active",
  "created_at": "2024-01-01T09:00:00Z",
  "updated_at": "2025-08-14T14:30:00Z"
}
```

### 4.3 财务管理域

```json
{
  "invoice_id": "INV-20250814-0001",
  "customer_id": 5001,
  "customer_name": "ABC科技有限公司",
  "billing_period": "2025-08",
  "service_fee": 6000.00,
  "additional_fee": 500.00,
  "total_amount": 6500.00,
  "tax_amount": 390.00,
  "final_amount": 6890.00,
  "status": "pending",
  "due_date": "2025-09-14",
  "created_at": "2025-08-14T14:30:00Z",
  "updated_at": "2025-08-14T14:30:00Z"
}
```

---

## 5. Mock 示例生成约定（API文档中）

在 `api-docs.md` 每个接口的响应示例后 **额外增加一个 "Mock 数据示例" 区块**：

```markdown
#### Mock 数据示例
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "engineer_id": 1001,
    "real_name": "张三",
    "status": 1,
    "online_status": "online",
    "current_workload": 3,
    "skills": [
      {
        "skill_code": "linux",
        "skill_name": "Linux系统管理",
        "skill_level": 3,
        "certification_status": 2
      }
    ]
  },
  "timestamp": "2025-08-14T14:30:00Z",
  "request_id": "req_123456789"
}
```

---

## 6. 数据一致性要求

1. **ID关联一致性**  
   - 同一实体的ID在不同接口中保持一致
   - 外键关联正确，如 `engineer_id` 在技能、排班、绩效数据中保持一致

2. **时间逻辑一致性**  
   - `created_at` ≤ `updated_at`
   - 业务时间逻辑合理，如入职日期早于技能认证日期

3. **状态枚举一致性**  
   - 所有状态字段使用统一的枚举值
   - 状态转换逻辑符合业务规则

4. **数据格式统一**  
   - 同类型字段格式保持一致
   - 如手机号、邮箱、日期时间格式统一

---

## 7. 测试数据集建议

为便于开发和测试，建议准备以下测试数据集：

1. **基础数据集**：包含10个工程师、5个客户、20个工单的基础数据
2. **边界数据集**：包含各种边界情况和异常数据
3. **性能数据集**：包含大量数据用于性能测试
4. **多租户数据集**：包含多个租户的隔离数据

参考：详细的API接口定义见各模块PRD文档和API业务域映射文档。
