# API接口规范与数据模型技术增强 v3.0

## 1. 全局API规范标准

### 1.1 统一响应格式
```json
{
  "code": 200,
  "message": "success", 
  "data": {},
  "timestamp": "2025-01-15T10:30:00Z",
  "request_id": "uuid-v4",
  "pagination": {
    "page": 1,
    "size": 20,
    "total": 1000,
    "total_pages": 50
  }
}
```

### 1.2 错误码标准
- **2xx**: 成功响应
  - 200: 操作成功
  - 201: 创建成功  
  - 204: 删除成功
- **4xx**: 客户端错误
  - 400: 参数错误
  - 401: 未认证
  - 403: 权限不足
  - 404: 资源不存在
  - 409: 数据冲突
  - 422: 数据验证失败
- **5xx**: 服务端错误
  - 500: 内部错误
  - 502: 网关错误
  - 503: 服务不可用

### 1.3 数据类型标准
- **bigint**: 主键ID、外键ID（支持大数据量）
- **varchar(n)**: 固定长度字符串，明确最大长度
- **text**: 不限长度文本内容
- **timestamp**: 时间戳，带时区信息
- **enum**: 枚举类型，明确可选值
- **json/jsonb**: 结构化数据，PostgreSQL优化

### 1.4 命名规范
- **URL路径**: 小写+连字符，如 `/api/v1/ticket-categories`
- **参数名**: snake_case，如 `user_id`、`created_at`
- **枚举值**: UPPER_SNAKE_CASE，如 `IN_PROGRESS`、`COMPLETED`

## 2. 数据库设计增强规范

### 2.1 主键设计标准
```sql
-- 统一主键设计：bigint自增，支持海量数据
id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,

-- 租户隔离：所有业务表必须包含租户ID
tenant_id BIGINT NOT NULL REFERENCES tenants(id),

-- 审计字段：标准创建、更新时间
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
```

### 2.2 索引设计标准
```sql
-- 复合索引：租户+业务主键（支持多租户查询优化）
CREATE INDEX idx_tickets_tenant_status ON tickets(tenant_id, status);
CREATE INDEX idx_tickets_tenant_assignee ON tickets(tenant_id, assignee_id);
CREATE INDEX idx_tickets_created_at ON tickets(created_at DESC);

-- 全文搜索索引（PostgreSQL + 中文分词）
CREATE INDEX idx_tickets_fts ON tickets USING gin(to_tsvector('chinese', title || ' ' || description));
```

### 2.3 约束设计标准
```sql
-- 状态约束：使用CHECK约束限制枚举值
ALTER TABLE tickets ADD CONSTRAINT chk_ticket_status 
CHECK (status IN ('PENDING', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'));

-- 外键约束：带级联更新
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_assignee 
FOREIGN KEY (assignee_id) REFERENCES users(id) ON UPDATE CASCADE;

-- 唯一约束：业务唯一性保证
ALTER TABLE users ADD CONSTRAINT uk_users_tenant_username 
UNIQUE (tenant_id, username);
```

## 3. KPI量化公式与采集方法

### 3.1 工单管理KPI
| KPI指标 | 计算公式 | 数据来源 | 采集频率 |
|---------|----------|----------|----------|
| 工单解决率 | (已解决工单数 / 总工单数) × 100% | tickets表status字段 | 实时计算 |
| 平均响应时间 | SUM(first_response_at - created_at) / COUNT(*) | ticket_records表 | 每小时聚合 |
| SLA达成率 | (SLA内完成工单数 / 总工单数) × 100% | ticket_sla表 | 每日计算 |
| 工程师工作负载 | 当前分配工单数 / 工程师总数 | tickets.assignee_id分组统计 | 实时监控 |

### 3.2 系统性能KPI
| KPI指标 | 计算公式 | 数据来源 | 采集频率 |
|---------|----------|----------|----------|
| API响应时间 | 95分位数响应时间 | 应用日志 + APM | 每分钟 |
| 系统可用性 | (总时间 - 故障时间) / 总时间 × 100% | 监控系统 | 每分钟 |
| 并发用户数 | 活跃Session计数 | Redis会话统计 | 实时 |
| 错误率 | 错误请求数 / 总请求数 × 100% | 日志聚合 | 每分钟 |

### 3.3 业务流程KPI
| KPI指标 | 计算公式 | 数据来源 | 采集频率 |
|---------|----------|----------|----------|
| 智能派单准确率 | 正确派单数 / 总派单数 × 100% | dispatch_records表 | 每日 |
| 知识库搜索成功率 | 有效搜索次数 / 总搜索次数 × 100% | search_logs表 | 每小时 |
| 用户满意度 | 评分总和 / 评分次数 | feedback表 | 每周 |

## 4. 业务规则可执行化改进

### 4.1 工单状态流转规则
```typescript
// 状态流转矩阵：当前状态 -> 允许的下一状态
const TICKET_STATUS_TRANSITIONS = {
  'PENDING': ['IN_PROGRESS', 'CANCELLED'],
  'IN_PROGRESS': ['RESOLVED', 'PENDING', 'CANCELLED'], 
  'RESOLVED': ['CLOSED', 'IN_PROGRESS'],
  'CLOSED': [], // 终态
  'CANCELLED': [] // 终态
} as const;

// 状态变更权限控制
const STATUS_CHANGE_PERMISSIONS = {
  'PENDING->IN_PROGRESS': ['ENGINEER', 'ADMIN'],
  'IN_PROGRESS->RESOLVED': ['ENGINEER', 'ADMIN'],
  'RESOLVED->CLOSED': ['CUSTOMER', 'ADMIN'],
  '*->CANCELLED': ['ADMIN'] // 管理员可以取消任何状态的工单
} as const;
```

### 4.2 智能派单规则
```typescript
// 派单权重计算公式
interface DispatchWeight {
  skillMatch: number;      // 技能匹配度 (0-1)
  workload: number;        // 工作负载 (0-1，值越小越优先)
  location: number;        // 地理位置 (0-1)
  history: number;         // 历史处理情况 (0-1)
}

const calculateDispatchScore = (engineer: Engineer, ticket: Ticket): number => {
  const weights = { skill: 0.4, workload: 0.3, location: 0.2, history: 0.1 };
  
  return (
    engineer.skillMatch * weights.skill +
    (1 - engineer.workload) * weights.workload + 
    engineer.locationScore * weights.location +
    engineer.historyScore * weights.history
  );
};
```

### 4.3 SLA计算规则
```typescript
// SLA等级定义
const SLA_LEVELS = {
  'CRITICAL': { responseHours: 0.5, resolveHours: 4 },   // 紧急
  'HIGH': { responseHours: 2, resolveHours: 24 },        // 高
  'MEDIUM': { responseHours: 8, resolveHours: 72 },      // 中  
  'LOW': { responseHours: 24, resolveHours: 168 }        // 低
} as const;

// 工作时间计算（排除节假日和非工作时间）
const calculateWorkingHours = (start: Date, end: Date): number => {
  // 实现工作时间计算逻辑，排除周末和节假日
  // 返回实际工作小时数
};
```

## 5. 跨模块数据一致性规范

### 5.1 状态枚举统一标准
```typescript
// 全局状态枚举定义
export const COMMON_STATUS = {
  ACTIVE: 'ACTIVE',
  INACTIVE: 'INACTIVE', 
  PENDING: 'PENDING',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED'
} as const;

// 工单特定状态
export const TICKET_STATUS = {
  ...COMMON_STATUS,
  IN_PROGRESS: 'IN_PROGRESS',
  RESOLVED: 'RESOLVED',
  CLOSED: 'CLOSED'
} as const;
```

### 5.2 权限模型统一规范
```typescript
// RBAC权限模型
interface Permission {
  resource: string;    // 资源类型：tickets, users, reports
  action: string;      // 操作类型：create, read, update, delete
  scope: string;       // 作用域：own, team, tenant, all
}

// 预定义角色权限
const ROLE_PERMISSIONS = {
  'SUPER_ADMIN': ['*:*:all'],
  'TENANT_ADMIN': ['*:*:tenant'], 
  'TEAM_LEAD': ['tickets:*:team', 'users:read:team'],
  'ENGINEER': ['tickets:read,update:own', 'knowledge:read:all']
} as const;
```

## 6. 数据迁移与版本控制规范

### 6.1 数据库迁移脚本标准
```sql
-- 迁移脚本命名：V{版本号}__{描述}.sql
-- V001__create_base_tables.sql

-- 必须包含回滚脚本和数据备份
BEGIN;

-- 创建新表
CREATE TABLE IF NOT EXISTS tickets (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tenant_id BIGINT NOT NULL,
    -- 其他字段...
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tickets_tenant_status 
ON tickets(tenant_id, status);

-- 数据迁移（如果需要）
-- INSERT INTO new_table SELECT ... FROM old_table;

COMMIT;
```

### 6.2 API版本控制规范
```typescript
// API版本控制策略
const API_VERSIONS = {
  v1: {
    deprecated: false,
    sunset: null,
    features: ['basic_crud', 'search', 'filters']
  },
  v2: {
    deprecated: false, 
    sunset: null,
    features: ['advanced_search', 'batch_operations', 'webhooks']
  }
} as const;

// 向后兼容性保证
interface APIResponse<T> {
  version: string;
  data: T;
  _links?: {
    self: string;
    upgrade?: string; // 提示升级到新版本
  };
}
```