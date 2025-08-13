# IT运维门户系统 API 文档 v4.5

## 文档信息
- **版本**: v4.5 Verified
- **创建日期**: 2025年8月13日
- **API版本**: v1
- **基础URL**: https://api.ops-portal.com/api/v1
- **认证方式**: Bearer Token (JWT)

## 全局说明

### 统一响应格式
所有API响应均采用统一的Result<T>格式：

```json
{
    "code": 200,
    "message": "操作成功",
    "data": {},
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "abc123def456"
}
```

### 错误码规范
- **200**: 成功
- **400**: 请求参数错误
- **401**: 未认证或认证失败
- **403**: 权限不足
- **404**: 资源不存在
- **429**: 请求频率超限
- **500**: 服务器内部错误

### 分页格式
```json
{
    "total": 100,
    "page": 1,
    "size": 20,
    "items": []
}
```

---

## REQ-001: 基础架构模块 API

### 1.1 用户认证 API

#### 1.1.1 用户登录
**REQ-ID**: REQ-001-002  
**路径**: `POST /auth/login`  
**适用平台**: Web端、移动端  
**权限要求**: 无需认证  

**请求参数**:
```json
{
    "tenant_code": "demo_company",
    "username": "admin",
    "password": "password123",
    "auth_type": "password",
    "remember_me": true,
    "captcha_code": "1234",
    "captcha_key": "captcha_key_123"
}
```

**响应结构**:
```json
{
    "code": 200,
    "message": "登录成功",
    "data": {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        "expires_in": 7200,
        "user_info": {
            "id": 1001,
            "username": "admin",
            "real_name": "系统管理员",
            "email": "admin@demo.com",
            "avatar_url": "https://cdn.example.com/avatar/admin.jpg",
            "tenant_id": 1,
            "tenant_name": "演示公司",
            "roles": ["admin", "user"],
            "permissions": ["user:read", "user:write", "system:config"]
        }
    }
}
```

**错误码**:
- **40001**: 用户名或密码错误
- **40002**: 账户已被锁定
- **40003**: 租户不存在或已停用
- **40004**: 验证码错误

#### 1.1.2 刷新令牌
**REQ-ID**: REQ-001-002  
**路径**: `POST /auth/refresh`  
**适用平台**: Web端、移动端  
**权限要求**: 需要有效的refresh_token  

**请求参数**:
```json
{
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### 1.1.3 用户登出
**REQ-ID**: REQ-001-002  
**路径**: `POST /auth/logout`  
**适用平台**: Web端、移动端  
**权限要求**: 需要认证  

**请求参数**: 无

**响应结构**:
```json
{
    "code": 200,
    "message": "登出成功",
    "data": null
}
```

#### 1.1.4 获取当前用户信息
**REQ-ID**: REQ-001-002  
**路径**: `GET /auth/me`  
**适用平台**: Web端、移动端  
**权限要求**: 需要认证  

### 1.2 租户管理 API

#### 1.2.1 查询租户列表
**REQ-ID**: REQ-001-001  
**路径**: `GET /admin/tenants`  
**适用平台**: Web端  
**权限要求**: system:tenant:read  

**请求参数**:
- `page`: 页码，默认1
- `size`: 每页大小，默认20
- `status`: 状态筛选，1-正常，2-停用，3-过期
- `keyword`: 搜索关键词

**响应结构**:
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "total": 156,
        "page": 1,
        "size": 20,
        "items": [
            {
                "id": 1,
                "tenant_code": "demo_company",
                "tenant_name": "演示公司",
                "domain": "demo.example.com",
                "status": 1,
                "max_users": 500,
                "current_users": 89,
                "expire_time": "2024-12-31T23:59:59Z",
                "created_at": "2024-01-01T00:00:00Z",
                "config": {
                    "theme": "default",
                    "logo_url": "https://cdn.example.com/logo.png"
                }
            }
        ]
    }
}
```

#### 1.2.2 创建租户
**REQ-ID**: REQ-001-001  
**路径**: `POST /admin/tenants`  
**适用平台**: Web端  
**权限要求**: system:tenant:create  

**请求参数**:
```json
{
    "tenant_code": "new_company",
    "tenant_name": "新公司",
    "domain": "new.example.com",
    "max_users": 100,
    "expire_time": "2025-12-31T23:59:59Z",
    "admin_username": "admin",
    "admin_password": "password123",
    "admin_email": "admin@new.com",
    "config": {
        "theme": "default"
    }
}
```

#### 1.2.3 更新租户信息
**REQ-ID**: REQ-001-001  
**路径**: `PUT /admin/tenants/{id}`  
**适用平台**: Web端  
**权限要求**: system:tenant:update  

#### 1.2.4 删除租户
**REQ-ID**: REQ-001-001  
**路径**: `DELETE /admin/tenants/{id}`  
**适用平台**: Web端  
**权限要求**: system:tenant:delete  

### 1.3 用户管理 API

#### 1.3.1 查询用户列表
**REQ-ID**: REQ-001-003  
**路径**: `GET /users`  
**适用平台**: Web端  
**权限要求**: user:read  

**请求参数**:
- `page`: 页码
- `size`: 每页大小
- `status`: 状态筛选
- `role_id`: 角色筛选
- `keyword`: 搜索关键词

#### 1.3.2 创建用户
**REQ-ID**: REQ-001-003  
**路径**: `POST /users`  
**适用平台**: Web端  
**权限要求**: user:create  

**请求参数**:
```json
{
    "username": "newuser",
    "email": "newuser@example.com",
    "phone": "13800138000",
    "real_name": "新用户",
    "password": "password123",
    "role_ids": [1, 2],
    "status": 1
}
```

#### 1.3.3 更新用户信息
**REQ-ID**: REQ-001-003  
**路径**: `PUT /users/{id}`  
**适用平台**: Web端  
**权限要求**: user:update  

#### 1.3.4 删除用户
**REQ-ID**: REQ-001-003  
**路径**: `DELETE /users/{id}`  
**适用平台**: Web端  
**权限要求**: user:delete  

#### 1.3.5 重置用户密码
**REQ-ID**: REQ-001-003  
**路径**: `POST /users/{id}/reset-password`  
**适用平台**: Web端  
**权限要求**: user:reset-password  

### 1.4 角色权限管理 API

#### 1.4.1 查询角色列表
**REQ-ID**: REQ-001-003  
**路径**: `GET /roles`  
**适用平台**: Web端  
**权限要求**: role:read  

#### 1.4.2 创建角色
**REQ-ID**: REQ-001-003  
**路径**: `POST /roles`  
**适用平台**: Web端  
**权限要求**: role:create  

**请求参数**:
```json
{
    "role_code": "engineer",
    "role_name": "运维工程师",
    "description": "负责日常运维工作",
    "permissions": ["ticket:read", "ticket:update", "knowledge:read"]
}
```

#### 1.4.3 查询权限列表
**REQ-ID**: REQ-001-003  
**路径**: `GET /permissions`  
**适用平台**: Web端  
**权限要求**: permission:read  

### 1.5 系统配置 API

#### 1.5.1 查询系统配置
**REQ-ID**: REQ-001-006  
**路径**: `GET /config/system`  
**适用平台**: Web端  
**权限要求**: config:read  

#### 1.5.2 更新系统配置
**REQ-ID**: REQ-001-006  
**路径**: `PUT /config/system`  
**适用平台**: Web端  
**权限要求**: config:update  

**请求参数**:
```json
{
    "site_name": "IT运维门户",
    "site_logo": "https://cdn.example.com/logo.png",
    "login_captcha_enabled": true,
    "password_policy": {
        "min_length": 8,
        "require_uppercase": true,
        "require_lowercase": true,
        "require_number": true,
        "require_special": true
    },
    "session_timeout": 7200
}
```

### 1.6 监控告警 API

#### 1.6.1 查询系统监控指标
**REQ-ID**: REQ-001-007  
**路径**: `GET /monitor/metrics`  
**适用平台**: Web端  
**权限要求**: monitor:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "system": {
            "cpu_usage": 45.6,
            "memory_usage": 67.8,
            "disk_usage": 34.2,
            "network_in": 1024000,
            "network_out": 2048000
        },
        "application": {
            "active_users": 1234,
            "api_qps": 567,
            "avg_response_time": 156,
            "error_rate": 0.02
        },
        "database": {
            "connections": 45,
            "slow_queries": 2,
            "cache_hit_rate": 95.6
        }
    }
}
```

#### 1.6.2 查询告警列表
**REQ-ID**: REQ-001-007  
**路径**: `GET /monitor/alerts`  
**适用平台**: Web端  
**权限要求**: monitor:read  

### 1.7 审计日志 API

#### 1.7.1 查询操作日志
**REQ-ID**: REQ-001-008  
**路径**: `GET /audit/logs`  
**适用平台**: Web端  
**权限要求**: audit:read  

**请求参数**:
- `start_time`: 开始时间
- `end_time`: 结束时间
- `user_id`: 用户ID
- `action`: 操作类型
- `resource`: 资源类型
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "total": 1000,
        "page": 1,
        "size": 20,
        "items": [
            {
                "id": 1,
                "user_id": 1001,
                "username": "admin",
                "action": "user:create",
                "resource": "user",
                "resource_id": "2001",
                "details": "创建用户：newuser",
                "ip_address": "192.168.1.100",
                "user_agent": "Mozilla/5.0...",
                "created_at": "2025-08-13T10:30:00Z"
            }
        ]
    }
}
```

---

## Mock 数据示例

### 用户登录成功响应
```json
{
    "code": 200,
    "message": "登录成功",
    "data": {
        "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMDAxIiwibmFtZSI6ImFkbWluIiwiaWF0IjoxNjI2MjQwMDAwLCJleHAiOjE2MjYyNDcyMDB9.signature",
        "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMDAxIiwidHlwZSI6InJlZnJlc2giLCJpYXQiOjE2MjYyNDAwMDAsImV4cCI6MTYyNjMyNjQwMH0.signature",
        "expires_in": 7200,
        "user_info": {
            "id": 1001,
            "username": "admin",
            "real_name": "系统管理员",
            "email": "admin@demo.com",
            "avatar_url": "https://cdn.example.com/avatar/admin.jpg",
            "tenant_id": 1,
            "tenant_name": "演示公司",
            "roles": ["admin", "user"],
            "permissions": [
                "user:read", "user:write", "user:delete",
                "role:read", "role:write", "role:delete",
                "system:config", "monitor:read", "audit:read"
            ]
        }
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "abc123def456"
}
```

### 租户列表响应
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "total": 3,
        "page": 1,
        "size": 20,
        "items": [
            {
                "id": 1,
                "tenant_code": "demo_company",
                "tenant_name": "演示公司",
                "domain": "demo.example.com",
                "status": 1,
                "max_users": 500,
                "current_users": 89,
                "expire_time": "2024-12-31T23:59:59Z",
                "created_at": "2024-01-01T00:00:00Z",
                "config": {
                    "theme": "default",
                    "logo_url": "https://cdn.example.com/logo.png"
                }
            },
            {
                "id": 2,
                "tenant_code": "tech_corp",
                "tenant_name": "科技公司",
                "domain": "tech.example.com",
                "status": 1,
                "max_users": 200,
                "current_users": 156,
                "expire_time": "2025-06-30T23:59:59Z",
                "created_at": "2024-03-15T00:00:00Z",
                "config": {
                    "theme": "blue",
                    "logo_url": "https://cdn.example.com/tech-logo.png"
                }
            }
        ]
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "def456ghi789"
}
```

### 系统监控指标响应
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "system": {
            "cpu_usage": 45.6,
            "memory_usage": 67.8,
            "disk_usage": 34.2,
            "network_in": 1024000,
            "network_out": 2048000,
            "load_average": [1.2, 1.5, 1.8]
        },
        "application": {
            "active_users": 1234,
            "api_qps": 567,
            "avg_response_time": 156,
            "error_rate": 0.02,
            "active_sessions": 890
        },
        "database": {
            "connections": 45,
            "max_connections": 100,
            "slow_queries": 2,
            "cache_hit_rate": 95.6,
            "query_per_second": 234
        }
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "ghi789jkl012"
}
```

---

## 错误处理示例

### 认证失败
```json
{
    "code": 40001,
    "message": "用户名或密码错误",
    "data": null,
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "error123"
}
```

### 权限不足
```json
{
    "code": 403,
    "message": "权限不足，无法访问该资源",
    "data": {
        "required_permission": "user:delete",
        "current_permissions": ["user:read", "user:update"]
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "error456"
}
```

### 参数验证失败
```json
{
    "code": 400,
    "message": "请求参数验证失败",
    "data": {
        "errors": [
            {
                "field": "username",
                "message": "用户名不能为空"
            },
            {
                "field": "email",
                "message": "邮箱格式不正确"
            }
        ]
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "error789"
}
```## REQ-002: 工作台与仪表板模块 API

### 2.1 工作台配置 API

#### 2.1.1 获取工作台配置
**REQ-ID**: REQ-002-001  
**路径**: `GET /dashboard/config`  
**适用平台**: Web端、移动端  
**权限要求**: dashboard:read  

**请求参数**:
- `user_id`: 用户ID（可选，默认当前用户）
- `config_name`: 配置名称（可选，默认获取默认配置）

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "config_id": 1,
        "config_name": "默认工作台",
        "layout_config": {
            "grid_size": 12,
            "row_height": 60,
            "margin": [10, 10],
            "layouts": [
                {
                    "i": "widget_1",
                    "x": 0,
                    "y": 0,
                    "w": 6,
                    "h": 4,
                    "minW": 2,
                    "minH": 2
                }
            ]
        },
        "widget_configs": [
            {
                "widget_id": "widget_1",
                "widget_code": "ticket_summary",
                "widget_name": "工单概览",
                "config": {
                    "show_chart": true,
                    "time_range": "7d",
                    "chart_type": "bar"
                }
            }
        ],
        "theme_config": {
            "primary_color": "#1890ff",
            "theme_mode": "light"
        }
    }
}
```

#### 2.1.2 保存工作台配置
**REQ-ID**: REQ-002-001  
**路径**: `POST /dashboard/config`  
**适用平台**: Web端  
**权限要求**: dashboard:write  

**请求参数**:
```json
{
    "config_name": "我的工作台",
    "layout_config": {
        "grid_size": 12,
        "row_height": 60,
        "margin": [10, 10],
        "layouts": [
            {
                "i": "widget_1",
                "x": 0,
                "y": 0,
                "w": 6,
                "h": 4
            }
        ]
    },
    "widget_configs": [
        {
            "widget_id": "widget_1",
            "widget_code": "ticket_summary",
            "config": {
                "show_chart": true,
                "time_range": "7d"
            }
        }
    ],
    "is_default": true
}
```

#### 2.1.3 删除工作台配置
**REQ-ID**: REQ-002-001  
**路径**: `DELETE /dashboard/config/{id}`  
**适用平台**: Web端  
**权限要求**: dashboard:delete  

### 2.2 仪表板数据 API

#### 2.2.1 获取仪表板统计数据
**REQ-ID**: REQ-002-002  
**路径**: `GET /dashboard/statistics`  
**适用平台**: Web端、移动端  
**权限要求**: dashboard:read  

**请求参数**:
- `time_range`: 时间范围（1d, 7d, 30d, 90d）
- `metrics`: 指标类型（可选，多个用逗号分隔）

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "overview": {
            "total_tickets": 1234,
            "pending_tickets": 56,
            "completed_tickets": 1178,
            "avg_response_time": 2.5,
            "customer_satisfaction": 4.6
        },
        "trends": {
            "ticket_trends": [
                {
                    "date": "2025-08-06",
                    "created": 45,
                    "completed": 42,
                    "pending": 3
                }
            ],
            "response_time_trends": [
                {
                    "date": "2025-08-06",
                    "avg_time": 2.3
                }
            ]
        },
        "distribution": {
            "ticket_by_priority": {
                "urgent": 12,
                "high": 34,
                "medium": 78,
                "low": 156
            },
            "ticket_by_category": {
                "hardware": 89,
                "software": 123,
                "network": 67
            }
        }
    }
}
```

#### 2.2.2 获取实时监控数据
**REQ-ID**: REQ-002-002  
**路径**: `GET /dashboard/realtime`  
**适用平台**: Web端、移动端  
**权限要求**: dashboard:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "system_status": {
            "status": "healthy",
            "cpu_usage": 45.6,
            "memory_usage": 67.8,
            "active_users": 234,
            "api_qps": 567
        },
        "alerts": [
            {
                "id": 1,
                "level": "warning",
                "message": "数据库连接数过高",
                "timestamp": "2025-08-13T10:25:00Z"
            }
        ],
        "recent_activities": [
            {
                "id": 1,
                "type": "ticket_created",
                "description": "新工单：服务器故障",
                "user": "张三",
                "timestamp": "2025-08-13T10:20:00Z"
            }
        ]
    }
}
```

### 2.3 任务中心 API

#### 2.3.1 获取待办任务
**REQ-ID**: REQ-002-003  
**路径**: `GET /dashboard/tasks`  
**适用平台**: Web端、移动端  
**权限要求**: task:read  

**请求参数**:
- `status`: 任务状态（pending, in_progress, completed）
- `priority`: 优先级筛选
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "summary": {
            "total": 45,
            "pending": 12,
            "in_progress": 8,
            "overdue": 3
        },
        "tasks": [
            {
                "id": 1001,
                "title": "服务器故障处理",
                "type": "ticket",
                "priority": "urgent",
                "status": "pending",
                "assigned_to": "张三",
                "due_time": "2025-08-13T14:00:00Z",
                "created_at": "2025-08-13T10:00:00Z",
                "description": "生产服务器CPU使用率过高"
            }
        ]
    }
}
```

#### 2.3.2 更新任务状态
**REQ-ID**: REQ-002-003  
**路径**: `PUT /dashboard/tasks/{id}/status`  
**适用平台**: Web端、移动端  
**权限要求**: task:update  

**请求参数**:
```json
{
    "status": "in_progress",
    "comment": "开始处理该问题"
}
```

### 2.4 快速导航 API

#### 2.4.1 获取导航菜单
**REQ-ID**: REQ-002-004  
**路径**: `GET /dashboard/navigation`  
**适用平台**: Web端、移动端  
**权限要求**: 需要认证  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "menus": [
            {
                "id": "tickets",
                "name": "工单管理",
                "icon": "ticket",
                "url": "/tickets",
                "children": [
                    {
                        "id": "my_tickets",
                        "name": "我的工单",
                        "url": "/tickets/my"
                    }
                ]
            }
        ],
        "quick_actions": [
            {
                "id": "create_ticket",
                "name": "创建工单",
                "icon": "plus",
                "url": "/tickets/create"
            }
        ],
        "recent_visits": [
            {
                "id": "ticket_1001",
                "name": "工单 #1001",
                "url": "/tickets/1001",
                "visited_at": "2025-08-13T09:30:00Z"
            }
        ]
    }
}
```

#### 2.4.2 全局搜索
**REQ-ID**: REQ-002-004  
**路径**: `GET /dashboard/search`  
**适用平台**: Web端、移动端  
**权限要求**: search:read  

**请求参数**:
- `q`: 搜索关键词
- `type`: 搜索类型（ticket, user, knowledge, all）
- `limit`: 结果数量限制

**响应结构**:
```json
{
    "code": 200,
    "message": "搜索成功",
    "data": {
        "total": 15,
        "results": [
            {
                "type": "ticket",
                "id": "1001",
                "title": "服务器故障处理",
                "highlight": "服务器<em>故障</em>处理",
                "url": "/tickets/1001",
                "score": 0.95
            },
            {
                "type": "knowledge",
                "id": "kb_001",
                "title": "服务器故障排查手册",
                "highlight": "服务器<em>故障</em>排查手册",
                "url": "/knowledge/kb_001",
                "score": 0.87
            }
        ]
    }
}
```

### 2.5 消息通知 API

#### 2.5.1 获取通知列表
**REQ-ID**: REQ-002-005  
**路径**: `GET /dashboard/notifications`  
**适用平台**: Web端、移动端  
**权限要求**: notification:read  

**请求参数**:
- `type`: 通知类型（system, ticket, alert, announcement）
- `status`: 状态（unread, read, all）
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "unread_count": 5,
        "notifications": [
            {
                "id": 1,
                "type": "ticket",
                "title": "新工单分配",
                "content": "您有一个新的紧急工单需要处理",
                "status": "unread",
                "priority": "high",
                "created_at": "2025-08-13T10:15:00Z",
                "action_url": "/tickets/1002"
            }
        ]
    }
}
```

#### 2.5.2 标记通知已读
**REQ-ID**: REQ-002-005  
**路径**: `PUT /dashboard/notifications/{id}/read`  
**适用平台**: Web端、移动端  
**权限要求**: notification:update  

#### 2.5.3 批量标记已读
**REQ-ID**: REQ-002-005  
**路径**: `PUT /dashboard/notifications/batch-read`  
**适用平台**: Web端、移动端  
**权限要求**: notification:update  

**请求参数**:
```json
{
    "notification_ids": [1, 2, 3, 4, 5]
}
```

### 2.6 组件管理 API

#### 2.6.1 获取可用组件列表
**REQ-ID**: REQ-002-001  
**路径**: `GET /dashboard/widgets`  
**适用平台**: Web端  
**权限要求**: dashboard:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "widget_code": "ticket_summary",
            "widget_name": "工单概览",
            "widget_type": "chart",
            "description": "显示工单统计信息和趋势图表",
            "config_schema": {
                "time_range": {
                    "type": "select",
                    "options": ["1d", "7d", "30d"],
                    "default": "7d"
                },
                "chart_type": {
                    "type": "select",
                    "options": ["bar", "line", "pie"],
                    "default": "bar"
                }
            },
            "min_width": 4,
            "min_height": 3,
            "preview_url": "/widgets/ticket_summary/preview.png"
        }
    ]
}
```

#### 2.6.2 获取组件数据
**REQ-ID**: REQ-002-002  
**路径**: `GET /dashboard/widgets/{widget_code}/data`  
**适用平台**: Web端、移动端  
**权限要求**: dashboard:read  

**请求参数**:
- `config`: 组件配置（JSON字符串）
- `time_range`: 时间范围

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "chart_data": {
            "labels": ["周一", "周二", "周三", "周四", "周五"],
            "datasets": [
                {
                    "label": "新建工单",
                    "data": [12, 19, 3, 5, 2],
                    "backgroundColor": "#1890ff"
                }
            ]
        },
        "summary": {
            "total": 41,
            "change": "+15%"
        }
    }
}
```

---

## REQ-003: 工单管理系统 API

### 3.1 工单基础管理 API

#### 3.1.1 创建工单
**REQ-ID**: REQ-003-001  
**路径**: `POST /tickets`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:create  

**请求参数**:
```json
{
    "title": "服务器故障处理",
    "description": "生产服务器CPU使用率过高，需要紧急处理",
    "category": "hardware",
    "priority": "urgent",
    "customer_id": 1001,
    "contact_name": "张三",
    "contact_phone": "13800138000",
    "contact_email": "zhangsan@example.com",
    "attachments": [
        {
            "filename": "error_log.txt",
            "file_url": "https://cdn.example.com/files/error_log.txt",
            "file_size": 1024
        }
    ],
    "custom_fields": {
        "server_ip": "192.168.1.100",
        "affected_services": ["web", "api"]
    }
}
```

**响应结构**:
```json
{
    "code": 200,
    "message": "工单创建成功",
    "data": {
        "ticket_id": "T202508130001",
        "id": 1001,
        "title": "服务器故障处理",
        "status": "pending",
        "priority": "urgent",
        "created_at": "2025-08-13T10:30:00Z",
        "estimated_resolve_time": "2025-08-13T12:30:00Z"
    }
}
```

#### 3.1.2 查询工单列表
**REQ-ID**: REQ-003-002  
**路径**: `GET /tickets`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:read  

**请求参数**:
- `status`: 状态筛选（pending, assigned, in_progress, resolved, closed）
- `priority`: 优先级筛选（urgent, high, medium, low）
- `category`: 分类筛选
- `assigned_to`: 指派人筛选
- `customer_id`: 客户筛选
- `created_start`: 创建时间开始
- `created_end`: 创建时间结束
- `keyword`: 关键词搜索
- `page`: 页码
- `size`: 每页大小
- `sort`: 排序字段
- `order`: 排序方向（asc, desc）

**响应结构**:
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "total": 1234,
        "page": 1,
        "size": 20,
        "items": [
            {
                "id": 1001,
                "ticket_id": "T202508130001",
                "title": "服务器故障处理",
                "description": "生产服务器CPU使用率过高",
                "status": "in_progress",
                "priority": "urgent",
                "category": "hardware",
                "customer_id": 1001,
                "customer_name": "演示公司",
                "contact_name": "张三",
                "assigned_to": 2001,
                "assigned_name": "李工程师",
                "created_at": "2025-08-13T10:30:00Z",
                "updated_at": "2025-08-13T11:00:00Z",
                "due_time": "2025-08-13T12:30:00Z",
                "tags": ["urgent", "server"]
            }
        ]
    }
}
```

#### 3.1.3 获取工单详情
**REQ-ID**: REQ-003-002  
**路径**: `GET /tickets/{id}`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "id": 1001,
        "ticket_id": "T202508130001",
        "title": "服务器故障处理",
        "description": "生产服务器CPU使用率过高，需要紧急处理",
        "status": "in_progress",
        "priority": "urgent",
        "category": "hardware",
        "customer_info": {
            "id": 1001,
            "name": "演示公司",
            "contact_name": "张三",
            "contact_phone": "13800138000",
            "contact_email": "zhangsan@example.com"
        },
        "assigned_info": {
            "id": 2001,
            "name": "李工程师",
            "email": "engineer@example.com",
            "phone": "13900139000"
        },
        "time_info": {
            "created_at": "2025-08-13T10:30:00Z",
            "assigned_at": "2025-08-13T10:35:00Z",
            "first_response_at": "2025-08-13T10:40:00Z",
            "due_time": "2025-08-13T12:30:00Z",
            "resolved_at": null
        },
        "attachments": [
            {
                "id": 1,
                "filename": "error_log.txt",
                "file_url": "https://cdn.example.com/files/error_log.txt",
                "file_size": 1024,
                "uploaded_by": "张三",
                "uploaded_at": "2025-08-13T10:30:00Z"
            }
        ],
        "custom_fields": {
            "server_ip": "192.168.1.100",
            "affected_services": ["web", "api"]
        },
        "tags": ["urgent", "server"],
        "sla_info": {
            "response_sla": 30,
            "resolve_sla": 120,
            "response_remaining": 0,
            "resolve_remaining": 90
        }
    }
}
```

#### 3.1.4 更新工单信息
**REQ-ID**: REQ-003-003  
**路径**: `PUT /tickets/{id}`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:update  

#### 3.1.5 删除工单
**REQ-ID**: REQ-003-004  
**路径**: `DELETE /tickets/{id}`  
**适用平台**: Web端  
**权限要求**: ticket:delete  

### 3.2 工单状态管理 API

#### 3.2.1 分配工单
**REQ-ID**: REQ-003-005  
**路径**: `POST /tickets/{id}/assign`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:assign  

**请求参数**:
```json
{
    "assigned_to": 2001,
    "comment": "分配给李工程师处理",
    "priority": "urgent"
}
```

#### 3.2.2 接受工单
**REQ-ID**: REQ-003-006  
**路径**: `POST /tickets/{id}/accept`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:accept  

#### 3.2.3 拒绝工单
**REQ-ID**: REQ-003-006  
**路径**: `POST /tickets/{id}/reject`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:reject  

**请求参数**:
```json
{
    "reason": "当前工作负载过重，无法及时处理",
    "suggest_assignee": 2002
}
```

#### 3.2.4 开始处理工单
**REQ-ID**: REQ-003-007  
**路径**: `POST /tickets/{id}/start`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:process  

#### 3.2.5 暂停工单处理
**REQ-ID**: REQ-003-007  
**路径**: `POST /tickets/{id}/pause`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:process  

#### 3.2.6 解决工单
**REQ-ID**: REQ-003-008  
**路径**: `POST /tickets/{id}/resolve`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:resolve  

**请求参数**:
```json
{
    "solution": "重启服务器并优化配置，问题已解决",
    "resolution_type": "solved",
    "time_spent": 120,
    "attachments": [
        {
            "filename": "solution_report.pdf",
            "file_url": "https://cdn.example.com/files/solution_report.pdf"
        }
    ]
}
```

#### 3.2.7 关闭工单
**REQ-ID**: REQ-003-009  
**路径**: `POST /tickets/{id}/close`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:close  

### 3.3 工单评论与沟通 API

#### 3.3.1 添加工单评论
**REQ-ID**: REQ-003-010  
**路径**: `POST /tickets/{id}/comments`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:comment  

**请求参数**:
```json
{
    "content": "已经开始排查问题，预计30分钟内给出初步结果",
    "type": "internal",
    "attachments": [
        {
            "filename": "debug_log.txt",
            "file_url": "https://cdn.example.com/files/debug_log.txt"
        }
    ],
    "notify_customer": false
}
```

#### 3.3.2 获取工单评论列表
**REQ-ID**: REQ-003-010  
**路径**: `GET /tickets/{id}/comments`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "id": 1,
            "content": "已经开始排查问题，预计30分钟内给出初步结果",
            "type": "internal",
            "author": {
                "id": 2001,
                "name": "李工程师",
                "avatar": "https://cdn.example.com/avatar/engineer.jpg"
            },
            "created_at": "2025-08-13T10:45:00Z",
            "attachments": [
                {
                    "filename": "debug_log.txt",
                    "file_url": "https://cdn.example.com/files/debug_log.txt"
                }
            ]
        }
    ]
}
```

### 3.4 工单附件管理 API

#### 3.4.1 上传工单附件
**REQ-ID**: REQ-003-011  
**路径**: `POST /tickets/{id}/attachments`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:upload  

**请求参数**: multipart/form-data
- `file`: 文件内容
- `description`: 文件描述

#### 3.4.2 下载工单附件
**REQ-ID**: REQ-003-011  
**路径**: `GET /tickets/{id}/attachments/{attachment_id}/download`  
**适用平台**: Web端、移动端  
**权限要求**: ticket:read  

#### 3.4.3 删除工单附件
**REQ-ID**: REQ-003-011  
**路径**: `DELETE /tickets/{id}/attachments/{attachment_id}`  
**适用平台**: Web端  
**权限要求**: ticket:delete  

### 3.5 工单统计分析 API

#### 3.5.1 获取工单统计概览
**REQ-ID**: REQ-003-012  
**路径**: `GET /tickets/statistics/overview`  
**适用平台**: Web端  
**权限要求**: ticket:statistics  

**请求参数**:
- `time_range`: 时间范围（1d, 7d, 30d, 90d）
- `group_by`: 分组维度（status, priority, category, assignee）

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "summary": {
            "total": 1234,
            "pending": 56,
            "in_progress": 89,
            "resolved": 1089,
            "avg_response_time": 25.6,
            "avg_resolve_time": 145.8,
            "satisfaction_rate": 4.6
        },
        "trends": [
            {
                "date": "2025-08-06",
                "created": 45,
                "resolved": 42,
                "avg_response_time": 23.5
            }
        ],
        "distribution": {
            "by_priority": {
                "urgent": 12,
                "high": 34,
                "medium": 78,
                "low": 156
            },
            "by_category": {
                "hardware": 89,
                "software": 123,
                "network": 67,
                "other": 45
            }
        }
    }
}
```

---
## REQ-004: 智能派单系统 API

### 4.1 智能派单核心 API

#### 4.1.1 执行智能派单
**REQ-ID**: REQ-004-001  
**路径**: `POST /dispatch/intelligent`  
**适用平台**: Web端  
**权限要求**: dispatch:execute  

**请求参数**:
```json
{
    "ticket_id": 1001,
    "strategy": "best_match",
    "constraints": {
        "skill_required": ["linux", "database"],
        "min_skill_level": 2,
        "location_preference": "same_city",
        "exclude_engineers": [2001, 2002]
    },
    "force_dispatch": false
}
```

**响应结构**:
```json
{
    "code": 200,
    "message": "派单成功",
    "data": {
        "dispatch_id": 10001,
        "ticket_id": 1001,
        "selected_engineer": {
            "id": 2003,
            "name": "王工程师",
            "email": "wang@example.com",
            "phone": "13700137000",
            "skills": ["linux", "database", "network"],
            "current_workload": 3,
            "location": "北京市"
        },
        "match_details": {
            "total_score": 92.5,
            "skill_match_score": 95.0,
            "workload_score": 88.0,
            "location_score": 95.0,
            "performance_score": 92.0
        },
        "dispatch_reason": "技能匹配度最高，工作负载适中，地理位置就近",
        "estimated_response_time": "2025-08-13T11:00:00Z",
        "alternatives": [
            {
                "engineer_id": 2004,
                "engineer_name": "李工程师",
                "total_score": 88.5,
                "reason": "备选方案"
            }
        ]
    }
}
```

#### 4.1.2 获取派单建议
**REQ-ID**: REQ-004-001  
**路径**: `GET /dispatch/suggestions/{ticket_id}`  
**适用平台**: Web端  
**权限要求**: dispatch:read  

**请求参数**:
- `limit`: 建议数量限制，默认5
- `strategy`: 派单策略

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "ticket_info": {
            "id": 1001,
            "title": "服务器故障处理",
            "priority": "urgent",
            "required_skills": ["linux", "database"]
        },
        "suggestions": [
            {
                "rank": 1,
                "engineer": {
                    "id": 2003,
                    "name": "王工程师",
                    "avatar": "https://cdn.example.com/avatar/wang.jpg",
                    "current_workload": 3,
                    "location": "北京市",
                    "online_status": "online"
                },
                "match_score": 92.5,
                "score_breakdown": {
                    "skill_match": 95.0,
                    "workload": 88.0,
                    "location": 95.0,
                    "performance": 92.0
                },
                "estimated_response": "15分钟",
                "confidence": "高"
            }
        ]
    }
}
```

#### 4.1.3 批量派单
**REQ-ID**: REQ-004-001  
**路径**: `POST /dispatch/batch`  
**适用平台**: Web端  
**权限要求**: dispatch:batch  

**请求参数**:
```json
{
    "ticket_ids": [1001, 1002, 1003],
    "strategy": "load_balance",
    "constraints": {
        "max_tickets_per_engineer": 5,
        "skill_match_threshold": 80
    }
}
```

### 4.2 派单策略管理 API

#### 4.2.1 获取派单策略列表
**REQ-ID**: REQ-004-005  
**路径**: `GET /dispatch/strategies`  
**适用平台**: Web端  
**权限要求**: dispatch:config  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "strategy_code": "best_match",
            "strategy_name": "最佳匹配",
            "description": "综合技能、负载、位置等因素选择最佳工程师",
            "weight_config": {
                "skill_weight": 40,
                "workload_weight": 25,
                "location_weight": 20,
                "performance_weight": 15
            },
            "is_default": true,
            "is_active": true
        },
        {
            "strategy_code": "load_balance",
            "strategy_name": "负载均衡",
            "description": "优先考虑工作负载，实现工程师间负载均衡",
            "weight_config": {
                "skill_weight": 30,
                "workload_weight": 50,
                "location_weight": 10,
                "performance_weight": 10
            },
            "is_default": false,
            "is_active": true
        }
    ]
}
```

#### 4.2.2 创建派单策略
**REQ-ID**: REQ-004-005  
**路径**: `POST /dispatch/strategies`  
**适用平台**: Web端  
**权限要求**: dispatch:config  

**请求参数**:
```json
{
    "strategy_code": "skill_priority",
    "strategy_name": "技能优先",
    "description": "优先考虑技能匹配度",
    "weight_config": {
        "skill_weight": 60,
        "workload_weight": 20,
        "location_weight": 10,
        "performance_weight": 10
    },
    "constraints": {
        "min_skill_match": 85,
        "max_workload": 8
    }
}
```

#### 4.2.3 更新派单策略
**REQ-ID**: REQ-004-005  
**路径**: `PUT /dispatch/strategies/{strategy_code}`  
**适用平台**: Web端  
**权限要求**: dispatch:config  

### 4.3 派单规则管理 API

#### 4.3.1 获取派单规则列表
**REQ-ID**: REQ-004-004  
**路径**: `GET /dispatch/rules`  
**适用平台**: Web端  
**权限要求**: dispatch:config  

**请求参数**:
- `rule_type`: 规则类型筛选
- `status`: 状态筛选
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 15,
        "items": [
            {
                "id": 1,
                "rule_name": "紧急工单优先派单",
                "rule_type": "priority",
                "conditions": {
                    "ticket_priority": "urgent",
                    "response_time_limit": 15
                },
                "actions": {
                    "boost_score": 20,
                    "notify_immediately": true,
                    "escalate_if_no_response": 10
                },
                "priority": 100,
                "is_active": true,
                "created_at": "2025-08-01T00:00:00Z"
            }
        ]
    }
}
```

#### 4.3.2 创建派单规则
**REQ-ID**: REQ-004-004  
**路径**: `POST /dispatch/rules`  
**适用平台**: Web端  
**权限要求**: dispatch:config  

**请求参数**:
```json
{
    "rule_name": "VIP客户优先处理",
    "rule_type": "customer",
    "description": "VIP客户的工单优先分配给高级工程师",
    "conditions": {
        "customer_level": "vip",
        "ticket_category": ["hardware", "software"]
    },
    "actions": {
        "require_skill_level": 3,
        "boost_score": 15,
        "max_response_time": 30
    },
    "priority": 90,
    "is_active": true
}
```

#### 4.3.3 更新派单规则
**REQ-ID**: REQ-004-004  
**路径**: `PUT /dispatch/rules/{id}`  
**适用平台**: Web端  
**权限要求**: dispatch:config  

#### 4.3.4 删除派单规则
**REQ-ID**: REQ-004-004  
**路径**: `DELETE /dispatch/rules/{id}`  
**适用平台**: Web端  
**权限要求**: dispatch:config  

### 4.4 工程师技能管理 API

#### 4.4.1 获取工程师技能列表
**REQ-ID**: REQ-004-002  
**路径**: `GET /engineers/{engineer_id}/skills`  
**适用平台**: Web端  
**权限要求**: engineer:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "id": 1,
            "skill_code": "linux",
            "skill_name": "Linux系统管理",
            "skill_level": 3,
            "proficiency_score": 92.5,
            "certification": "RHCE认证",
            "experience_years": 5.5,
            "last_used_time": "2025-08-10T14:30:00Z",
            "skill_category": "操作系统"
        }
    ]
}
```

#### 4.4.2 添加工程师技能
**REQ-ID**: REQ-004-002  
**路径**: `POST /engineers/{engineer_id}/skills`  
**适用平台**: Web端  
**权限要求**: engineer:update  

**请求参数**:
```json
{
    "skill_code": "kubernetes",
    "skill_name": "Kubernetes容器编排",
    "skill_level": 2,
    "proficiency_score": 78.0,
    "certification": "CKA认证",
    "experience_years": 2.0
}
```

#### 4.4.3 更新工程师技能
**REQ-ID**: REQ-004-002  
**路径**: `PUT /engineers/{engineer_id}/skills/{skill_id}`  
**适用平台**: Web端  
**权限要求**: engineer:update  

#### 4.4.4 删除工程师技能
**REQ-ID**: REQ-004-002  
**路径**: `DELETE /engineers/{engineer_id}/skills/{skill_id}`  
**适用平台**: Web端  
**权限要求**: engineer:update  

### 4.5 工作负载管理 API

#### 4.5.1 获取工程师工作负载
**REQ-ID**: REQ-004-003  
**路径**: `GET /dispatch/workload`  
**适用平台**: Web端  
**权限要求**: dispatch:read  

**请求参数**:
- `engineer_ids`: 工程师ID列表（可选）
- `include_details`: 是否包含详细信息

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "summary": {
            "total_engineers": 25,
            "avg_workload": 4.2,
            "max_workload": 8,
            "min_workload": 1,
            "workload_variance": 15.6
        },
        "engineers": [
            {
                "engineer_id": 2001,
                "engineer_name": "张工程师",
                "current_tickets": 5,
                "pending_tickets": 2,
                "in_progress_tickets": 3,
                "workload_score": 75.0,
                "capacity_utilization": "75%",
                "estimated_available_time": "2025-08-13T16:00:00Z",
                "status": "online"
            }
        ]
    }
}
```

#### 4.5.2 获取负载均衡建议
**REQ-ID**: REQ-004-003  
**路径**: `GET /dispatch/load-balance-suggestions`  
**适用平台**: Web端  
**权限要求**: dispatch:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "balance_score": 82.5,
        "suggestions": [
            {
                "type": "redistribute",
                "description": "建议将张工程师的2个低优先级工单重新分配",
                "affected_tickets": [1005, 1006],
                "target_engineers": [2003, 2004],
                "expected_improvement": 15.2
            }
        ],
        "overloaded_engineers": [
            {
                "engineer_id": 2001,
                "engineer_name": "张工程师",
                "current_load": 8,
                "recommended_load": 5,
                "excess_tickets": 3
            }
        ],
        "underloaded_engineers": [
            {
                "engineer_id": 2005,
                "engineer_name": "赵工程师",
                "current_load": 2,
                "capacity": 6,
                "available_capacity": 4
            }
        ]
    }
}
```

### 4.6 派单监控与统计 API

#### 4.6.1 获取派单统计概览
**REQ-ID**: REQ-004-008  
**路径**: `GET /dispatch/statistics/overview`  
**适用平台**: Web端  
**权限要求**: dispatch:statistics  

**请求参数**:
- `time_range`: 时间范围（1d, 7d, 30d）
- `group_by`: 分组维度（strategy, engineer, priority）

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "summary": {
            "total_dispatches": 1234,
            "intelligent_dispatches": 1111,
            "manual_dispatches": 123,
            "success_rate": 95.2,
            "avg_match_score": 87.5,
            "avg_response_time": 18.5
        },
        "by_strategy": {
            "best_match": {
                "count": 800,
                "success_rate": 96.5,
                "avg_score": 89.2
            },
            "load_balance": {
                "count": 311,
                "success_rate": 92.8,
                "avg_score": 84.1
            }
        },
        "trends": [
            {
                "date": "2025-08-06",
                "total": 45,
                "success": 43,
                "avg_score": 88.5
            }
        ]
    }
}
```

#### 4.6.2 获取派单效果分析
**REQ-ID**: REQ-004-008  
**路径**: `GET /dispatch/analytics/effectiveness`  
**适用平台**: Web端  
**权限要求**: dispatch:statistics  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "accuracy_metrics": {
            "skill_match_accuracy": 89.5,
            "workload_balance_score": 85.2,
            "customer_satisfaction": 4.6,
            "sla_compliance_rate": 94.8
        },
        "performance_metrics": {
            "avg_dispatch_time": 2.3,
            "avg_acceptance_rate": 92.1,
            "avg_completion_rate": 96.8,
            "rework_rate": 3.2
        },
        "improvement_suggestions": [
            {
                "area": "技能匹配",
                "current_score": 89.5,
                "target_score": 92.0,
                "suggestions": [
                    "更新工程师技能档案",
                    "优化技能匹配算法权重"
                ]
            }
        ]
    }
}
```

### 4.7 手动派单 API

#### 4.7.1 执行手动派单
**REQ-ID**: REQ-004-007  
**路径**: `POST /dispatch/manual`  
**适用平台**: Web端  
**权限要求**: dispatch:manual  

**请求参数**:
```json
{
    "ticket_id": 1001,
    "engineer_id": 2003,
    "reason": "客户指定工程师",
    "override_constraints": true,
    "notify_engineer": true,
    "priority_boost": 10
}
```

**响应结构**:
```json
{
    "code": 200,
    "message": "手动派单成功",
    "data": {
        "dispatch_id": 10002,
        "ticket_id": 1001,
        "engineer_id": 2003,
        "dispatch_type": "manual",
        "warnings": [
            "目标工程师当前工作负载较高",
            "技能匹配度低于建议阈值"
        ],
        "dispatch_time": "2025-08-13T11:30:00Z"
    }
}
```

#### 4.7.2 撤销派单
**REQ-ID**: REQ-004-007  
**路径**: `POST /dispatch/{dispatch_id}/revoke`  
**适用平台**: Web端  
**权限要求**: dispatch:revoke  

**请求参数**:
```json
{
    "reason": "工程师临时有紧急任务",
    "reassign": true,
    "reassign_strategy": "best_match"
}
```

### 4.8 地理位置匹配 API

#### 4.8.1 获取工程师位置信息
**REQ-ID**: REQ-004-009  
**路径**: `GET /dispatch/locations`  
**适用平台**: Web端  
**权限要求**: dispatch:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "engineer_id": 2001,
            "engineer_name": "张工程师",
            "current_location": {
                "city": "北京市",
                "district": "朝阳区",
                "address": "建国门外大街1号",
                "latitude": 39.9042,
                "longitude": 116.4074
            },
            "service_areas": ["北京市", "天津市"],
            "last_updated": "2025-08-13T10:00:00Z"
        }
    ]
}
```

#### 4.8.2 计算距离匹配
**REQ-ID**: REQ-004-009  
**路径**: `POST /dispatch/distance-match`  
**适用平台**: Web端  
**权限要求**: dispatch:read  

**请求参数**:
```json
{
    "ticket_location": {
        "city": "北京市",
        "district": "海淀区",
        "latitude": 39.9889,
        "longitude": 116.3056
    },
    "engineer_ids": [2001, 2002, 2003],
    "max_distance": 50
}
```

---

## Mock 数据示例

### 智能派单响应示例
```json
{
    "code": 200,
    "message": "派单成功",
    "data": {
        "dispatch_id": 10001,
        "ticket_id": 1001,
        "selected_engineer": {
            "id": 2003,
            "name": "王工程师",
            "email": "wang@example.com",
            "phone": "13700137000",
            "avatar": "https://cdn.example.com/avatar/wang.jpg",
            "skills": [
                {
                    "code": "linux",
                    "name": "Linux系统管理",
                    "level": 3,
                    "proficiency": 92.5
                },
                {
                    "code": "database",
                    "name": "数据库管理",
                    "level": 2,
                    "proficiency": 85.0
                }
            ],
            "current_workload": 3,
            "location": {
                "city": "北京市",
                "district": "朝阳区"
            },
            "online_status": "online",
            "response_rate": 96.5
        },
        "match_details": {
            "total_score": 92.5,
            "skill_match_score": 95.0,
            "workload_score": 88.0,
            "location_score": 95.0,
            "performance_score": 92.0,
            "calculation_details": {
                "skill_weight": 40,
                "workload_weight": 25,
                "location_weight": 20,
                "performance_weight": 15
            }
        },
        "dispatch_reason": "技能匹配度最高(95%)，工作负载适中(3/8)，地理位置就近(5km)，历史表现优秀(92%)",
        "estimated_response_time": "2025-08-13T11:00:00Z",
        "confidence_level": "高",
        "alternatives": [
            {
                "engineer_id": 2004,
                "engineer_name": "李工程师",
                "total_score": 88.5,
                "reason": "技能匹配良好，但工作负载较高"
            },
            {
                "engineer_id": 2005,
                "engineer_name": "赵工程师",
                "total_score": 85.2,
                "reason": "工作负载低，但技能匹配度一般"
            }
        ]
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "dispatch_abc123"
}
```

### 工作负载统计示例
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "summary": {
            "total_engineers": 25,
            "online_engineers": 22,
            "avg_workload": 4.2,
            "max_workload": 8,
            "min_workload": 1,
            "workload_variance": 15.6,
            "balance_score": 82.5
        },
        "engineers": [
            {
                "engineer_id": 2001,
                "engineer_name": "张工程师",
                "avatar": "https://cdn.example.com/avatar/zhang.jpg",
                "current_tickets": 5,
                "pending_tickets": 2,
                "in_progress_tickets": 3,
                "completed_today": 2,
                "workload_score": 75.0,
                "capacity_utilization": "75%",
                "estimated_available_time": "2025-08-13T16:00:00Z",
                "status": "online",
                "location": "北京市朝阳区",
                "skills_summary": ["Linux", "数据库", "网络"],
                "performance_rating": 4.6
            }
        ],
        "workload_distribution": {
            "0-2": 3,
            "3-4": 8,
            "5-6": 10,
            "7-8": 4,
            "9+": 0
        }
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "workload_def456"
}
```

---## REQ-005: 知识库管理系统 API

### 5.1 知识文档管理 API

#### 5.1.1 创建知识文档
**REQ-ID**: REQ-005-001  
**路径**: `POST /knowledge/documents`  
**适用平台**: Web端  
**权限要求**: knowledge:create  

**请求参数**:
```json
{
    "title": "Linux服务器故障排查指南",
    "content": "# Linux服务器故障排查指南\n\n## 1. CPU使用率过高\n...",
    "content_type": "markdown",
    "category_id": 1,
    "tags": ["linux", "故障排查", "服务器"],
    "keywords": ["CPU", "内存", "磁盘", "网络"],
    "template_id": 1,
    "attachments": [
        {
            "filename": "cpu_monitor.png",
            "file_url": "https://cdn.example.com/files/cpu_monitor.png",
            "file_size": 2048
        }
    ],
    "is_public": true,
    "difficulty_level": "intermediate",
    "estimated_read_time": 15
}
```

**响应结构**:
```json
{
    "code": 200,
    "message": "知识文档创建成功",
    "data": {
        "id": 1001,
        "title": "Linux服务器故障排查指南",
        "slug": "linux-server-troubleshooting-guide",
        "status": "draft",
        "version": "1.0",
        "created_at": "2025-08-13T10:30:00Z",
        "author": {
            "id": 2001,
            "name": "张工程师",
            "avatar": "https://cdn.example.com/avatar/zhang.jpg"
        }
    }
}
```

#### 5.1.2 查询知识文档列表
**REQ-ID**: REQ-005-002  
**路径**: `GET /knowledge/documents`  
**适用平台**: Web端、移动端  
**权限要求**: knowledge:read  

**请求参数**:
- `category_id`: 分类ID筛选
- `tags`: 标签筛选（多个用逗号分隔）
- `status`: 状态筛选（draft, published, archived）
- `author_id`: 作者筛选
- `difficulty_level`: 难度等级筛选
- `keyword`: 关键词搜索
- `sort`: 排序字段（created_at, updated_at, view_count, rating）
- `order`: 排序方向（asc, desc）
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "total": 256,
        "page": 1,
        "size": 20,
        "items": [
            {
                "id": 1001,
                "title": "Linux服务器故障排查指南",
                "slug": "linux-server-troubleshooting-guide",
                "summary": "详细介绍Linux服务器常见故障的排查方法和解决方案",
                "category": {
                    "id": 1,
                    "name": "故障排查",
                    "icon": "bug"
                },
                "tags": ["linux", "故障排查", "服务器"],
                "author": {
                    "id": 2001,
                    "name": "张工程师",
                    "avatar": "https://cdn.example.com/avatar/zhang.jpg"
                },
                "status": "published",
                "version": "1.2",
                "difficulty_level": "intermediate",
                "estimated_read_time": 15,
                "view_count": 1234,
                "like_count": 89,
                "rating": 4.6,
                "created_at": "2025-08-01T10:30:00Z",
                "updated_at": "2025-08-10T14:20:00Z",
                "last_viewed_at": "2025-08-13T09:15:00Z"
            }
        ]
    }
}
```

#### 5.1.3 获取知识文档详情
**REQ-ID**: REQ-005-001  
**路径**: `GET /knowledge/documents/{id}`  
**适用平台**: Web端、移动端  
**权限要求**: knowledge:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "id": 1001,
        "title": "Linux服务器故障排查指南",
        "slug": "linux-server-troubleshooting-guide",
        "content": "# Linux服务器故障排查指南\n\n## 1. CPU使用率过高\n...",
        "content_type": "markdown",
        "summary": "详细介绍Linux服务器常见故障的排查方法",
        "category": {
            "id": 1,
            "name": "故障排查",
            "path": "技术文档/故障排查"
        },
        "tags": ["linux", "故障排查", "服务器"],
        "keywords": ["CPU", "内存", "磁盘", "网络"],
        "author": {
            "id": 2001,
            "name": "张工程师",
            "email": "zhang@example.com",
            "avatar": "https://cdn.example.com/avatar/zhang.jpg"
        },
        "status": "published",
        "version": "1.2",
        "difficulty_level": "intermediate",
        "estimated_read_time": 15,
        "attachments": [
            {
                "id": 1,
                "filename": "cpu_monitor.png",
                "file_url": "https://cdn.example.com/files/cpu_monitor.png",
                "file_size": 2048,
                "file_type": "image/png"
            }
        ],
        "statistics": {
            "view_count": 1234,
            "like_count": 89,
            "comment_count": 23,
            "share_count": 45,
            "rating": 4.6,
            "rating_count": 67
        },
        "related_documents": [
            {
                "id": 1002,
                "title": "服务器性能监控最佳实践",
                "similarity": 0.85
            }
        ],
        "version_info": {
            "current_version": "1.2",
            "total_versions": 3,
            "last_updated_by": "李工程师",
            "change_summary": "更新了网络故障排查部分"
        },
        "created_at": "2025-08-01T10:30:00Z",
        "updated_at": "2025-08-10T14:20:00Z"
    }
}
```

#### 5.1.4 更新知识文档
**REQ-ID**: REQ-005-001  
**路径**: `PUT /knowledge/documents/{id}`  
**适用平台**: Web端  
**权限要求**: knowledge:update  

#### 5.1.5 删除知识文档
**REQ-ID**: REQ-005-001  
**路径**: `DELETE /knowledge/documents/{id}`  
**适用平台**: Web端  
**权限要求**: knowledge:delete  

### 5.2 知识搜索 API

#### 5.2.1 全文搜索
**REQ-ID**: REQ-005-003  
**路径**: `GET /knowledge/search`  
**适用平台**: Web端、移动端  
**权限要求**: knowledge:read  

**请求参数**:
- `q`: 搜索关键词（必填）
- `category_ids`: 分类ID列表
- `tags`: 标签列表
- `difficulty_level`: 难度等级
- `content_type`: 内容类型
- `date_range`: 时间范围（7d, 30d, 90d, 1y）
- `sort`: 排序方式（relevance, date, popularity, rating）
- `highlight`: 是否高亮关键词
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "搜索成功",
    "data": {
        "query": "Linux CPU 故障",
        "total": 45,
        "took": 156,
        "page": 1,
        "size": 10,
        "suggestions": ["Linux CPU 监控", "CPU 使用率过高", "系统负载分析"],
        "facets": {
            "categories": [
                {
                    "id": 1,
                    "name": "故障排查",
                    "count": 23
                }
            ],
            "tags": [
                {
                    "name": "linux",
                    "count": 34
                },
                {
                    "name": "cpu",
                    "count": 28
                }
            ]
        },
        "items": [
            {
                "id": 1001,
                "title": "Linux服务器<em>CPU</em>使用率过高<em>故障</em>排查",
                "summary": "详细介绍<em>Linux</em>服务器<em>CPU</em>使用率过高的原因分析和解决方案...",
                "category": {
                    "id": 1,
                    "name": "故障排查"
                },
                "tags": ["linux", "cpu", "故障排查"],
                "author": {
                    "name": "张工程师",
                    "avatar": "https://cdn.example.com/avatar/zhang.jpg"
                },
                "score": 0.95,
                "rating": 4.6,
                "view_count": 1234,
                "updated_at": "2025-08-10T14:20:00Z",
                "highlight": {
                    "title": "Linux服务器<em>CPU</em>使用率过高<em>故障</em>排查",
                    "content": "当<em>Linux</em>服务器出现<em>CPU</em>使用率过高的<em>故障</em>时..."
                }
            }
        ]
    }
}
```

#### 5.2.2 智能推荐
**REQ-ID**: REQ-005-004  
**路径**: `GET /knowledge/recommendations`  
**适用平台**: Web端、移动端  
**权限要求**: knowledge:read  

**请求参数**:
- `context`: 推荐上下文（ticket, category, user_behavior）
- `ticket_id`: 工单ID（当context为ticket时）
- `category_id`: 分类ID（当context为category时）
- `limit`: 推荐数量限制

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "context": "ticket",
        "context_info": {
            "ticket_id": 1001,
            "ticket_title": "服务器CPU使用率过高",
            "ticket_category": "hardware"
        },
        "recommendations": [
            {
                "id": 1001,
                "title": "Linux服务器CPU故障排查指南",
                "summary": "详细的CPU故障排查步骤和解决方案",
                "category": {
                    "name": "故障排查"
                },
                "relevance_score": 0.92,
                "reason": "与当前工单问题高度相关",
                "estimated_read_time": 15,
                "rating": 4.6,
                "view_count": 1234
            }
        ],
        "related_searches": [
            "CPU使用率监控",
            "系统负载分析",
            "进程管理"
        ]
    }
}
```

### 5.3 知识分类管理 API

#### 5.3.1 获取分类树
**REQ-ID**: REQ-005-002  
**路径**: `GET /knowledge/categories`  
**适用平台**: Web端、移动端  
**权限要求**: knowledge:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "id": 1,
            "name": "技术文档",
            "description": "技术相关的文档资料",
            "icon": "book",
            "sort_order": 1,
            "document_count": 156,
            "children": [
                {
                    "id": 11,
                    "name": "故障排查",
                    "description": "系统故障排查指南",
                    "icon": "bug",
                    "sort_order": 1,
                    "document_count": 45,
                    "children": []
                },
                {
                    "id": 12,
                    "name": "操作手册",
                    "description": "系统操作指导手册",
                    "icon": "manual",
                    "sort_order": 2,
                    "document_count": 67,
                    "children": []
                }
            ]
        }
    ]
}
```

#### 5.3.2 创建分类
**REQ-ID**: REQ-005-002  
**路径**: `POST /knowledge/categories`  
**适用平台**: Web端  
**权限要求**: knowledge:category:create  

**请求参数**:
```json
{
    "name": "网络配置",
    "description": "网络设备配置相关文档",
    "parent_id": 1,
    "icon": "network",
    "sort_order": 3
}
```

### 5.4 知识版本管理 API

#### 5.4.1 获取文档版本历史
**REQ-ID**: REQ-005-005  
**路径**: `GET /knowledge/documents/{id}/versions`  
**适用平台**: Web端  
**权限要求**: knowledge:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "version": "1.2",
            "title": "Linux服务器故障排查指南",
            "author": {
                "id": 2002,
                "name": "李工程师"
            },
            "change_summary": "更新了网络故障排查部分",
            "change_type": "major",
            "created_at": "2025-08-10T14:20:00Z",
            "is_current": true
        },
        {
            "version": "1.1",
            "title": "Linux服务器故障排查指南",
            "author": {
                "id": 2001,
                "name": "张工程师"
            },
            "change_summary": "修复了部分错误描述",
            "change_type": "minor",
            "created_at": "2025-08-05T09:15:00Z",
            "is_current": false
        }
    ]
}
```

#### 5.4.2 获取指定版本内容
**REQ-ID**: REQ-005-005  
**路径**: `GET /knowledge/documents/{id}/versions/{version}`  
**适用平台**: Web端  
**权限要求**: knowledge:read  

#### 5.4.3 版本回滚
**REQ-ID**: REQ-005-005  
**路径**: `POST /knowledge/documents/{id}/versions/{version}/rollback`  
**适用平台**: Web端  
**权限要求**: knowledge:update  

### 5.5 知识评价与统计 API

#### 5.5.1 评价知识文档
**REQ-ID**: REQ-005-007  
**路径**: `POST /knowledge/documents/{id}/rating`  
**适用平台**: Web端、移动端  
**权限要求**: knowledge:rate  

**请求参数**:
```json
{
    "rating": 5,
    "comment": "内容详细，解决了我的问题",
    "helpful": true,
    "tags": ["实用", "详细"]
}
```

#### 5.5.2 获取知识统计
**REQ-ID**: REQ-005-010  
**路径**: `GET /knowledge/statistics`  
**适用平台**: Web端  
**权限要求**: knowledge:statistics  

**请求参数**:
- `time_range`: 时间范围（7d, 30d, 90d）
- `group_by`: 分组维度（category, author, tag）

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "overview": {
            "total_documents": 1256,
            "published_documents": 1089,
            "total_views": 45678,
            "total_likes": 3456,
            "avg_rating": 4.3,
            "active_authors": 89
        },
        "trends": [
            {
                "date": "2025-08-06",
                "views": 567,
                "new_documents": 12,
                "ratings": 45
            }
        ],
        "top_documents": [
            {
                "id": 1001,
                "title": "Linux服务器故障排查指南",
                "views": 1234,
                "rating": 4.6,
                "category": "故障排查"
            }
        ],
        "category_distribution": {
            "故障排查": 234,
            "操作手册": 189,
            "最佳实践": 156
        }
    }
}
```

### 5.6 知识审核流程 API

#### 5.6.1 提交审核
**REQ-ID**: REQ-005-009  
**路径**: `POST /knowledge/documents/{id}/submit-review`  
**适用平台**: Web端  
**权限要求**: knowledge:submit-review  

**请求参数**:
```json
{
    "review_type": "publish",
    "comment": "请审核发布该文档",
    "urgency": "normal"
}
```

#### 5.6.2 审核知识文档
**REQ-ID**: REQ-005-009  
**路径**: `POST /knowledge/documents/{id}/review`  
**适用平台**: Web端  
**权限要求**: knowledge:review  

**请求参数**:
```json
{
    "action": "approve",
    "comment": "内容准确，可以发布",
    "suggestions": [
        "建议增加更多示例",
        "可以添加相关链接"
    ]
}
```

#### 5.6.3 获取待审核列表
**REQ-ID**: REQ-005-009  
**路径**: `GET /knowledge/reviews/pending`  
**适用平台**: Web端  
**权限要求**: knowledge:review  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 23,
        "items": [
            {
                "id": 1001,
                "title": "新的故障排查指南",
                "author": {
                    "name": "张工程师"
                },
                "review_type": "publish",
                "submitted_at": "2025-08-13T09:00:00Z",
                "urgency": "normal",
                "category": "故障排查",
                "estimated_read_time": 10
            }
        ]
    }
}
```

---

## REQ-006A: 工程师基础管理 API

### 6A.1 工程师档案管理 API

#### 6A.1.1 查询工程师列表
**REQ-ID**: REQ-006A-001  
**路径**: `GET /engineers`  
**适用平台**: Web端  
**权限要求**: engineer:read  

**请求参数**:
- `status`: 状态筛选（active, inactive, busy, offline）
- `skill_codes`: 技能筛选（多个用逗号分隔）
- `location`: 地理位置筛选
- `team_id`: 团队筛选
- `keyword`: 关键词搜索
- `sort`: 排序字段（name, join_date, rating, workload）
- `order`: 排序方向
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "total": 89,
        "page": 1,
        "size": 20,
        "items": [
            {
                "id": 2001,
                "employee_id": "ENG001",
                "name": "张工程师",
                "email": "zhang@example.com",
                "phone": "13800138000",
                "avatar": "https://cdn.example.com/avatar/zhang.jpg",
                "title": "高级运维工程师",
                "level": "senior",
                "team": {
                    "id": 1,
                    "name": "基础设施团队"
                },
                "location": {
                    "city": "北京市",
                    "district": "朝阳区"
                },
                "status": "active",
                "online_status": "online",
                "current_workload": 5,
                "max_workload": 8,
                "skills": [
                    {
                        "code": "linux",
                        "name": "Linux系统管理",
                        "level": 3
                    }
                ],
                "rating": 4.6,
                "join_date": "2023-01-15",
                "last_active": "2025-08-13T10:25:00Z"
            }
        ]
    }
}
```

#### 6A.1.2 获取工程师详情
**REQ-ID**: REQ-006A-001  
**路径**: `GET /engineers/{id}`  
**适用平台**: Web端、移动端  
**权限要求**: engineer:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "id": 2001,
        "employee_id": "ENG001",
        "name": "张工程师",
        "email": "zhang@example.com",
        "phone": "13800138000",
        "avatar": "https://cdn.example.com/avatar/zhang.jpg",
        "title": "高级运维工程师",
        "level": "senior",
        "department": "技术部",
        "team": {
            "id": 1,
            "name": "基础设施团队",
            "leader": "李经理"
        },
        "location": {
            "city": "北京市",
            "district": "朝阳区",
            "address": "建国门外大街1号",
            "latitude": 39.9042,
            "longitude": 116.4074
        },
        "contact_info": {
            "work_phone": "010-12345678",
            "emergency_contact": "13900139000",
            "wechat": "zhang_engineer"
        },
        "employment_info": {
            "join_date": "2023-01-15",
            "contract_type": "full_time",
            "employment_status": "active"
        },
        "skills": [
            {
                "id": 1,
                "code": "linux",
                "name": "Linux系统管理",
                "level": 3,
                "proficiency_score": 92.5,
                "certification": "RHCE认证",
                "experience_years": 5.5,
                "last_used": "2025-08-10T14:30:00Z"
            }
        ],
        "certifications": [
            {
                "name": "Red Hat Certified Engineer",
                "code": "RHCE",
                "issued_date": "2022-06-15",
                "expiry_date": "2025-06-15",
                "issuer": "Red Hat"
            }
        ],
        "work_schedule": {
            "timezone": "Asia/Shanghai",
            "work_hours": {
                "start": "09:00",
                "end": "18:00"
            },
            "work_days": ["monday", "tuesday", "wednesday", "thursday", "friday"]
        },
        "performance": {
            "rating": 4.6,
            "total_tickets": 234,
            "completed_tickets": 228,
            "avg_resolution_time": 145.6,
            "customer_satisfaction": 4.7,
            "knowledge_contributions": 23
        },
        "current_status": {
            "status": "active",
            "online_status": "online",
            "current_workload": 5,
            "max_workload": 8,
            "availability": "available",
            "last_active": "2025-08-13T10:25:00Z"
        }
    }
}
```

#### 6A.1.3 创建工程师档案
**REQ-ID**: REQ-006A-001  
**路径**: `POST /engineers`  
**适用平台**: Web端  
**权限要求**: engineer:create  

**请求参数**:
```json
{
    "employee_id": "ENG002",
    "name": "李工程师",
    "email": "li@example.com",
    "phone": "13700137000",
    "title": "运维工程师",
    "level": "intermediate",
    "team_id": 1,
    "location": {
        "city": "北京市",
        "district": "海淀区"
    },
    "skills": [
        {
            "skill_code": "docker",
            "skill_level": 2,
            "experience_years": 2.0
        }
    ],
    "work_schedule": {
        "timezone": "Asia/Shanghai",
        "work_hours": {
            "start": "09:00",
            "end": "18:00"
        }
    }
}
```

#### 6A.1.4 更新工程师信息
**REQ-ID**: REQ-006A-002  
**路径**: `PUT /engineers/{id}`  
**适用平台**: Web端  
**权限要求**: engineer:update  

### 6A.2 工程师技能管理 API

#### 6A.2.1 获取技能库
**REQ-ID**: REQ-006A-003  
**路径**: `GET /skills`  
**适用平台**: Web端  
**权限要求**: skill:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "code": "linux",
            "name": "Linux系统管理",
            "category": "操作系统",
            "description": "Linux服务器管理和维护",
            "levels": [
                {
                    "level": 1,
                    "name": "初级",
                    "description": "基本的Linux命令和操作"
                },
                {
                    "level": 2,
                    "name": "中级",
                    "description": "系统配置和服务管理"
                },
                {
                    "level": 3,
                    "name": "高级",
                    "description": "性能调优和故障排查"
                },
                {
                    "level": 4,
                    "name": "专家",
                    "description": "架构设计和团队指导"
                }
            ],
            "related_skills": ["shell", "docker", "kubernetes"],
            "certifications": ["RHCE", "LPIC"],
            "is_active": true
        }
    ]
}
```

#### 6A.2.2 技能评估
**REQ-ID**: REQ-006A-003  
**路径**: `POST /engineers/{id}/skills/assessment`  
**适用平台**: Web端  
**权限要求**: engineer:assess  

**请求参数**:
```json
{
    "skill_code": "linux",
    "assessment_type": "self",
    "questions": [
        {
            "question_id": 1,
            "answer": "A"
        }
    ],
    "practical_score": 85.0,
    "assessor_comment": "技能水平良好，建议加强性能调优方面的学习"
}
```

### 6A.3 工程师状态管理 API

#### 6A.3.1 更新在线状态
**REQ-ID**: REQ-006A-004  
**路径**: `PUT /engineers/{id}/status`  
**适用平台**: Web端、移动端  
**权限要求**: engineer:update-status  

**请求参数**:
```json
{
    "online_status": "online",
    "availability": "available",
    "location": {
        "latitude": 39.9042,
        "longitude": 116.4074
    },
    "status_message": "正在处理紧急工单"
}
```

#### 6A.3.2 获取工程师工作负载
**REQ-ID**: REQ-006A-005  
**路径**: `GET /engineers/{id}/workload`  
**适用平台**: Web端  
**权限要求**: engineer:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "engineer_id": 2001,
        "current_workload": 5,
        "max_workload": 8,
        "utilization_rate": 62.5,
        "tickets": {
            "pending": 2,
            "in_progress": 3,
            "total": 5
        },
        "estimated_completion": "2025-08-13T16:00:00Z",
        "workload_trend": [
            {
                "date": "2025-08-06",
                "workload": 4
            },
            {
                "date": "2025-08-07",
                "workload": 6
            }
        ],
        "capacity_forecast": {
            "next_available": "2025-08-13T14:00:00Z",
            "can_take_urgent": true,
            "recommended_max_new": 2
        }
    }
}
```

---

## Mock 数据示例

### 知识文档搜索响应示例
```json
{
    "code": 200,
    "message": "搜索成功",
    "data": {
        "query": "Linux CPU 故障",
        "total": 45,
        "took": 156,
        "page": 1,
        "size": 10,
        "suggestions": ["Linux CPU 监控", "CPU 使用率过高", "系统负载分析"],
        "facets": {
            "categories": [
                {
                    "id": 1,
                    "name": "故障排查",
                    "count": 23
                },
                {
                    "id": 2,
                    "name": "操作手册",
                    "count": 15
                }
            ],
            "tags": [
                {
                    "name": "linux",
                    "count": 34
                },
                {
                    "name": "cpu",
                    "count": 28
                },
                {
                    "name": "监控",
                    "count": 19
                }
            ],
            "difficulty_levels": [
                {
                    "level": "beginner",
                    "count": 12
                },
                {
                    "level": "intermediate",
                    "count": 25
                },
                {
                    "level": "advanced",
                    "count": 8
                }
            ]
        },
        "items": [
            {
                "id": 1001,
                "title": "Linux服务器<em>CPU</em>使用率过高<em>故障</em>排查指南",
                "summary": "详细介绍<em>Linux</em>服务器<em>CPU</em>使用率过高的原因分析和解决方案，包括top、htop、sar等监控工具的使用方法...",
                "category": {
                    "id": 1,
                    "name": "故障排查",
                    "icon": "bug"
                },
                "tags": ["linux", "cpu", "故障排查", "性能监控"],
                "author": {
                    "id": 2001,
                    "name": "张工程师",
                    "avatar": "https://cdn.example.com/avatar/zhang.jpg",
                    "title": "高级运维工程师"
                },
                "score": 0.95,
                "rating": 4.6,
                "rating_count": 67,
                "view_count": 1234,
                "like_count": 89,
                "difficulty_level": "intermediate",
                "estimated_read_time": 15,
                "updated_at": "2025-08-10T14:20:00Z",
                "highlight": {
                    "title": "Linux服务器<em>CPU</em>使用率过高<em>故障</em>排查指南",
                    "content": "当<em>Linux</em>服务器出现<em>CPU</em>使用率过高的<em>故障</em>时，首先需要使用top命令查看进程列表..."
                }
            }
        ]
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "search_abc123"
}
```

### 工程师详情响应示例
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "id": 2001,
        "employee_id": "ENG001",
        "name": "张工程师",
        "email": "zhang@example.com",
        "phone": "13800138000",
        "avatar": "https://cdn.example.com/avatar/zhang.jpg",
        "title": "高级运维工程师",
        "level": "senior",
        "department": "技术部",
        "team": {
            "id": 1,
            "name": "基础设施团队",
            "leader": "李经理",
            "member_count": 8
        },
        "location": {
            "city": "北京市",
            "district": "朝阳区",
            "address": "建国门外大街1号",
            "latitude": 39.9042,
            "longitude": 116.4074,
            "timezone": "Asia/Shanghai"
        },
        "contact_info": {
            "work_phone": "010-12345678",
            "emergency_contact": "13900139000",
            "wechat": "zhang_engineer",
            "preferred_contact": "phone"
        },
        "employment_info": {
            "join_date": "2023-01-15",
            "contract_type": "full_time",
            "employment_status": "active",
            "probation_end": "2023-04-15",
            "next_review": "2025-12-31"
        },
        "skills": [
            {
                "id": 1,
                "code": "linux",
                "name": "Linux系统管理",
                "category": "操作系统",
                "level": 3,
                "level_name": "高级",
                "proficiency_score": 92.5,
                "certification": "RHCE认证",
                "experience_years": 5.5,
                "last_used": "2025-08-10T14:30:00Z",
                "verified": true
            },
            {
                "id": 2,
                "code": "docker",
                "name": "Docker容器技术",
                "category": "容器化",
                "level": 2,
                "level_name": "中级",
                "proficiency_score": 78.0,
                "experience_years": 3.0,
                "last_used": "2025-08-12T09:15:00Z",
                "verified": false
            }
        ],
        "certifications": [
            {
                "id": 1,
                "name": "Red Hat Certified Engineer",
                "code": "RHCE",
                "issued_date": "2022-06-15",
                "expiry_date": "2025-06-15",
                "issuer": "Red Hat",
                "status": "active",
                "verification_url": "https://rhtapps.redhat.com/verify"
            }
        ],
        "work_schedule": {
            "timezone": "Asia/Shanghai",
            "work_hours": {
                "start": "09:00",
                "end": "18:00"
            },
            "work_days": ["monday", "tuesday", "wednesday", "thursday", "friday"],
            "break_time": {
                "start": "12:00",
                "end": "13:00"
            },
            "flexible_hours": true
        },
        "performance": {
            "rating": 4.6,
            "total_tickets": 234,
            "completed_tickets": 228,
            "success_rate": 97.4,
            "avg_resolution_time": 145.6,
            "customer_satisfaction": 4.7,
            "knowledge_contributions": 23,
            "mentoring_sessions": 12,
            "last_evaluation": "2025-06-30"
        },
        "current_status": {
            "status": "active",
            "online_status": "online",
            "current_workload": 5,
            "max_workload": 8,
            "availability": "available",
            "last_active": "2025-08-13T10:25:00Z",
            "status_message": "正在处理紧急工单",
            "estimated_free_time": "2025-08-13T14:00:00Z"
        }
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "engineer_def456"
}
```

---## REQ-010: 系统管理模块 API

### 10.1 系统配置管理 API

#### 10.1.1 获取系统配置列表
**REQ-ID**: REQ-010-004  
**路径**: `GET /admin/system/configs`  
**适用平台**: Web端  
**权限要求**: system:config:read  

**请求参数**:
- `config_level`: 配置级别筛选（global, tenant）
- `category`: 配置分类筛选
- `keyword`: 关键词搜索
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 45,
        "page": 1,
        "size": 20,
        "items": [
            {
                "config_id": 1,
                "config_key": "system.login.max_attempts",
                "config_value": "5",
                "config_level": "global",
                "category": "security",
                "description": "登录最大尝试次数",
                "data_type": "integer",
                "validation_rule": "min:1,max:10",
                "is_sensitive": false,
                "updated_by": {
                    "id": 1001,
                    "name": "系统管理员"
                },
                "updated_at": "2025-08-10T14:20:00Z"
            }
        ]
    }
}
```

#### 10.1.2 更新系统配置
**REQ-ID**: REQ-010-004  
**路径**: `PUT /admin/system/configs/{config_key}`  
**适用平台**: Web端  
**权限要求**: system:config:update  

**请求参数**:
```json
{
    "config_value": "3",
    "description": "登录最大尝试次数（修改为3次）",
    "change_reason": "根据安全策略调整"
}
```

#### 10.1.3 批量更新配置
**REQ-ID**: REQ-010-004  
**路径**: `PUT /admin/system/configs/batch`  
**适用平台**: Web端  
**权限要求**: system:config:update  

**请求参数**:
```json
{
    "configs": [
        {
            "config_key": "system.login.max_attempts",
            "config_value": "3"
        },
        {
            "config_key": "system.session.timeout",
            "config_value": "7200"
        }
    ],
    "change_reason": "安全策略统一调整"
}
```

### 10.2 模块管理 API

#### 10.2.1 获取模块状态列表
**REQ-ID**: REQ-010-009  
**路径**: `GET /admin/system/modules`  
**适用平台**: Web端  
**权限要求**: system:module:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "module_code": "ticket_management",
            "module_name": "工单管理",
            "module_version": "1.2.0",
            "status": "enabled",
            "tenant_id": null,
            "description": "工单全生命周期管理功能",
            "dependencies": ["user_management", "notification"],
            "config_options": {
                "auto_assign": true,
                "sla_enabled": true
            },
            "last_updated": "2025-08-10T14:20:00Z",
            "updated_by": "系统管理员"
        }
    ]
}
```

#### 10.2.2 切换模块状态
**REQ-ID**: REQ-010-009  
**路径**: `PUT /admin/system/modules/{module_code}/status`  
**适用平台**: Web端  
**权限要求**: system:module:update  

**请求参数**:
```json
{
    "status": "enabled",
    "tenant_id": 1,
    "reason": "启用工单管理功能",
    "config_options": {
        "auto_assign": true,
        "sla_enabled": false
    }
}
```

### 10.3 系统公告管理 API

#### 10.3.1 获取系统公告列表
**REQ-ID**: REQ-010-010  
**路径**: `GET /admin/system/announcements`  
**适用平台**: Web端  
**权限要求**: system:announcement:read  

**请求参数**:
- `status`: 状态筛选（draft, published, expired）
- `type`: 公告类型（system, maintenance, feature）
- `target_audience`: 目标受众（all, tenant, role）

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 12,
        "items": [
            {
                "id": 1,
                "title": "系统维护通知",
                "content": "系统将于2025年8月15日凌晨2:00-4:00进行维护升级",
                "type": "maintenance",
                "priority": "high",
                "status": "published",
                "target_audience": "all",
                "target_tenants": [],
                "target_roles": [],
                "publish_time": "2025-08-13T10:00:00Z",
                "expire_time": "2025-08-15T06:00:00Z",
                "created_by": {
                    "id": 1001,
                    "name": "系统管理员"
                },
                "created_at": "2025-08-13T09:30:00Z"
            }
        ]
    }
}
```

#### 10.3.2 创建系统公告
**REQ-ID**: REQ-010-010  
**路径**: `POST /admin/system/announcements`  
**适用平台**: Web端  
**权限要求**: system:announcement:create  

**请求参数**:
```json
{
    "title": "新功能发布通知",
    "content": "智能派单功能已正式上线，欢迎体验使用",
    "type": "feature",
    "priority": "medium",
    "target_audience": "all",
    "target_tenants": [],
    "target_roles": [],
    "publish_time": "2025-08-13T12:00:00Z",
    "expire_time": "2025-08-20T23:59:59Z",
    "is_popup": true,
    "is_email_notify": false
}
```

### 10.4 维护模式管理 API

#### 10.4.1 获取维护模式状态
**REQ-ID**: REQ-010-010  
**路径**: `GET /admin/system/maintenance`  
**适用平台**: Web端  
**权限要求**: system:maintenance:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "is_maintenance": false,
        "maintenance_message": "系统正在维护中，预计2小时后恢复",
        "start_time": null,
        "end_time": null,
        "allowed_ips": ["192.168.1.100", "10.0.0.1"],
        "allowed_users": [1001, 1002],
        "bypass_roles": ["admin", "super_admin"],
        "last_updated": "2025-08-13T10:00:00Z"
    }
}
```

#### 10.4.2 设置维护模式
**REQ-ID**: REQ-010-010  
**路径**: `PUT /admin/system/maintenance`  
**适用平台**: Web端  
**权限要求**: system:maintenance:update  

**请求参数**:
```json
{
    "is_maintenance": true,
    "maintenance_message": "系统正在进行重要升级，预计2小时后恢复正常",
    "start_time": "2025-08-15T02:00:00Z",
    "end_time": "2025-08-15T04:00:00Z",
    "allowed_ips": ["192.168.1.100"],
    "allowed_users": [1001],
    "bypass_roles": ["admin"],
    "notify_users": true
}
```

### 10.5 任务调度管理 API

#### 10.5.1 获取定时任务列表
**REQ-ID**: REQ-010-011  
**路径**: `GET /admin/system/scheduled-tasks`  
**适用平台**: Web端  
**权限要求**: system:task:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "task_id": 1,
            "task_name": "数据备份任务",
            "task_type": "backup",
            "cron_expression": "0 2 * * *",
            "status": "running",
            "last_run_time": "2025-08-13T02:00:00Z",
            "next_run_time": "2025-08-14T02:00:00Z",
            "last_run_status": "success",
            "last_run_duration": 1800,
            "run_count": 365,
            "success_count": 364,
            "failure_count": 1,
            "config": {
                "backup_type": "full",
                "retention_days": 30
            },
            "created_at": "2025-01-01T00:00:00Z"
        }
    ]
}
```

#### 10.5.2 创建定时任务
**REQ-ID**: REQ-010-011  
**路径**: `POST /admin/system/scheduled-tasks`  
**适用平台**: Web端  
**权限要求**: system:task:create  

**请求参数**:
```json
{
    "task_name": "日志清理任务",
    "task_type": "cleanup",
    "cron_expression": "0 3 * * 0",
    "description": "每周日凌晨3点清理过期日志",
    "config": {
        "log_types": ["access", "error"],
        "retention_days": 90
    },
    "is_enabled": true
}
```

#### 10.5.3 手动执行任务
**REQ-ID**: REQ-010-011  
**路径**: `POST /admin/system/scheduled-tasks/{task_id}/execute`  
**适用平台**: Web端  
**权限要求**: system:task:execute  

### 10.6 系统监控 API

#### 10.6.1 获取系统状态概览
**REQ-ID**: REQ-010-007  
**路径**: `GET /admin/system/status`  
**适用平台**: Web端  
**权限要求**: system:monitor:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "system_health": "healthy",
        "uptime": 2592000,
        "version": "1.2.0",
        "environment": "production",
        "services": [
            {
                "service_name": "database",
                "status": "healthy",
                "response_time": 15.6,
                "last_check": "2025-08-13T10:29:00Z"
            },
            {
                "service_name": "redis",
                "status": "healthy",
                "response_time": 2.3,
                "last_check": "2025-08-13T10:29:00Z"
            }
        ],
        "metrics": {
            "cpu_usage": 45.6,
            "memory_usage": 67.8,
            "disk_usage": 34.2,
            "active_users": 234,
            "api_requests_per_minute": 567
        },
        "alerts": [
            {
                "level": "warning",
                "message": "数据库连接数接近上限",
                "timestamp": "2025-08-13T10:25:00Z"
            }
        ]
    }
}
```

### 10.7 操作审计 API

#### 10.7.1 获取操作审计日志
**REQ-ID**: REQ-010-014  
**路径**: `GET /admin/system/audit-logs`  
**适用平台**: Web端  
**权限要求**: system:audit:read  

**请求参数**:
- `start_time`: 开始时间
- `end_time`: 结束时间
- `user_id`: 用户ID筛选
- `action_type`: 操作类型筛选
- `resource_type`: 资源类型筛选
- `result`: 操作结果筛选（success, failure）
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 1000,
        "page": 1,
        "size": 20,
        "items": [
            {
                "log_id": 1,
                "user_id": 1001,
                "username": "admin",
                "tenant_id": 1,
                "action_type": "config_update",
                "resource_type": "system_config",
                "resource_id": "system.login.max_attempts",
                "action_description": "更新系统配置：登录最大尝试次数",
                "old_value": "5",
                "new_value": "3",
                "result": "success",
                "ip_address": "192.168.1.100",
                "user_agent": "Mozilla/5.0...",
                "request_id": "req_abc123",
                "created_at": "2025-08-13T10:30:00Z"
            }
        ]
    }
}
```

---

## REQ-022: 用户与权限管理模块 API

### 22.1 用户生命周期管理 API

#### 22.1.1 查询用户列表
**REQ-ID**: REQ-022-001  
**路径**: `GET /admin/users`  
**适用平台**: Web端  
**权限要求**: user:read  

**请求参数**:
- `status`: 状态筛选（active, inactive, locked, pending）
- `role_ids`: 角色筛选（多个用逗号分隔）
- `department_id`: 部门筛选
- `user_type`: 用户类型筛选（internal, external, service）
- `last_login_start`: 最后登录时间开始
- `last_login_end`: 最后登录时间结束
- `keyword`: 关键词搜索
- `sort`: 排序字段
- `order`: 排序方向
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "查询成功",
    "data": {
        "total": 156,
        "page": 1,
        "size": 20,
        "items": [
            {
                "user_id": 1001,
                "username": "zhangsan",
                "real_name": "张三",
                "email": "zhangsan@example.com",
                "phone": "13800138000",
                "avatar": "https://cdn.example.com/avatar/zhangsan.jpg",
                "user_type": "internal",
                "status": "active",
                "tenant_id": 1,
                "tenant_name": "演示公司",
                "department": {
                    "id": 1,
                    "name": "技术部",
                    "path": "公司/技术部"
                },
                "roles": [
                    {
                        "id": 1,
                        "name": "运维工程师",
                        "code": "engineer"
                    }
                ],
                "last_login_time": "2025-08-13T09:30:00Z",
                "login_count": 1234,
                "created_at": "2024-01-15T10:00:00Z",
                "is_online": true,
                "session_count": 2
            }
        ]
    }
}
```

#### 22.1.2 获取用户详情
**REQ-ID**: REQ-022-001  
**路径**: `GET /admin/users/{user_id}`  
**适用平台**: Web端  
**权限要求**: user:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "user_id": 1001,
        "username": "zhangsan",
        "real_name": "张三",
        "email": "zhangsan@example.com",
        "phone": "13800138000",
        "avatar": "https://cdn.example.com/avatar/zhangsan.jpg",
        "user_type": "internal",
        "status": "active",
        "tenant_id": 1,
        "tenant_name": "演示公司",
        "department": {
            "id": 1,
            "name": "技术部",
            "path": "公司/技术部",
            "manager": "李经理"
        },
        "roles": [
            {
                "id": 1,
                "name": "运维工程师",
                "code": "engineer",
                "description": "负责系统运维工作",
                "assigned_at": "2024-01-15T10:00:00Z"
            }
        ],
        "permissions": [
            "ticket:read",
            "ticket:create",
            "ticket:update",
            "knowledge:read"
        ],
        "profile": {
            "job_title": "高级运维工程师",
            "employee_id": "EMP001",
            "hire_date": "2024-01-15",
            "manager_id": 1002,
            "work_location": "北京市朝阳区",
            "timezone": "Asia/Shanghai"
        },
        "security": {
            "password_last_changed": "2025-07-15T10:00:00Z",
            "mfa_enabled": true,
            "mfa_methods": ["totp", "sms"],
            "login_attempts": 0,
            "locked_until": null,
            "last_password_reset": "2025-07-15T10:00:00Z"
        },
        "activity": {
            "last_login_time": "2025-08-13T09:30:00Z",
            "last_login_ip": "192.168.1.100",
            "login_count": 1234,
            "current_sessions": 2,
            "last_activity": "2025-08-13T10:25:00Z"
        },
        "created_at": "2024-01-15T10:00:00Z",
        "updated_at": "2025-08-10T14:20:00Z"
    }
}
```

#### 22.1.3 创建用户
**REQ-ID**: REQ-022-001  
**路径**: `POST /admin/users`  
**适用平台**: Web端  
**权限要求**: user:create  

**请求参数**:
```json
{
    "username": "lisi",
    "real_name": "李四",
    "email": "lisi@example.com",
    "phone": "13700137000",
    "user_type": "internal",
    "department_id": 1,
    "role_ids": [1, 2],
    "password": "TempPassword123!",
    "require_password_change": true,
    "profile": {
        "job_title": "运维工程师",
        "employee_id": "EMP002",
        "hire_date": "2025-08-13",
        "manager_id": 1002,
        "work_location": "北京市海淀区"
    },
    "send_welcome_email": true
}
```

#### 22.1.4 更新用户信息
**REQ-ID**: REQ-022-001  
**路径**: `PUT /admin/users/{user_id}`  
**适用平台**: Web端  
**权限要求**: user:update  

#### 22.1.5 禁用/启用用户
**REQ-ID**: REQ-022-001  
**路径**: `PUT /admin/users/{user_id}/status`  
**适用平台**: Web端  
**权限要求**: user:update  

**请求参数**:
```json
{
    "status": "inactive",
    "reason": "员工离职",
    "effective_time": "2025-08-15T18:00:00Z"
}
```

### 22.2 身份认证 API

#### 22.2.1 用户登录
**REQ-ID**: REQ-022-002  
**路径**: `POST /auth/login`  
**适用平台**: Web端、移动端  
**权限要求**: 无需认证  

**请求参数**:
```json
{
    "tenant_code": "demo_company",
    "username": "zhangsan",
    "password": "password123",
    "auth_type": "password",
    "remember_me": true,
    "captcha_code": "1234",
    "captcha_key": "captcha_key_123",
    "device_info": {
        "device_id": "device_123",
        "device_name": "Chrome浏览器",
        "os": "Windows 10",
        "ip": "192.168.1.100"
    }
}
```

#### 22.2.2 多因素认证验证
**REQ-ID**: REQ-022-007  
**路径**: `POST /auth/mfa/verify`  
**适用平台**: Web端、移动端  
**权限要求**: 需要预认证  

**请求参数**:
```json
{
    "mfa_token": "temp_token_123",
    "mfa_type": "totp",
    "code": "123456",
    "device_trust": true
}
```

#### 22.2.3 重置密码
**REQ-ID**: REQ-022-002  
**路径**: `POST /auth/password/reset`  
**适用平台**: Web端  
**权限要求**: 无需认证  

**请求参数**:
```json
{
    "tenant_code": "demo_company",
    "email": "zhangsan@example.com",
    "reset_type": "email",
    "captcha_code": "1234",
    "captcha_key": "captcha_key_123"
}
```

### 22.3 角色权限管理 API

#### 22.3.1 获取角色列表
**REQ-ID**: REQ-022-003  
**路径**: `GET /admin/roles`  
**适用平台**: Web端  
**权限要求**: role:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "role_id": 1,
            "role_code": "engineer",
            "role_name": "运维工程师",
            "description": "负责系统运维和故障处理",
            "role_type": "business",
            "is_system": false,
            "is_active": true,
            "user_count": 25,
            "permissions": [
                {
                    "permission_code": "ticket:read",
                    "permission_name": "查看工单",
                    "resource_type": "ticket"
                }
            ],
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2025-08-10T14:20:00Z"
        }
    ]
}
```

#### 22.3.2 创建角色
**REQ-ID**: REQ-022-003  
**路径**: `POST /admin/roles`  
**适用平台**: Web端  
**权限要求**: role:create  

**请求参数**:
```json
{
    "role_code": "senior_engineer",
    "role_name": "高级运维工程师",
    "description": "负责复杂系统运维和技术指导",
    "role_type": "business",
    "permission_codes": [
        "ticket:read",
        "ticket:create",
        "ticket:update",
        "ticket:assign",
        "knowledge:read",
        "knowledge:create"
    ],
    "parent_role_id": 1
}
```

#### 22.3.3 获取权限列表
**REQ-ID**: REQ-022-003  
**路径**: `GET /admin/permissions`  
**适用平台**: Web端  
**权限要求**: permission:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "permission_code": "ticket:read",
            "permission_name": "查看工单",
            "description": "可以查看工单列表和详情",
            "resource_type": "ticket",
            "action_type": "read",
            "module": "工单管理",
            "is_system": false,
            "created_at": "2024-01-01T00:00:00Z"
        }
    ]
}
```

### 22.4 组织架构管理 API

#### 22.4.1 获取组织架构树
**REQ-ID**: REQ-022-004  
**路径**: `GET /admin/departments`  
**适用平台**: Web端  
**权限要求**: department:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "department_id": 1,
            "department_code": "tech",
            "department_name": "技术部",
            "description": "负责技术研发和运维",
            "parent_id": null,
            "level": 1,
            "sort_order": 1,
            "manager_id": 1002,
            "manager_name": "李经理",
            "user_count": 25,
            "is_active": true,
            "children": [
                {
                    "department_id": 11,
                    "department_code": "ops",
                    "department_name": "运维组",
                    "parent_id": 1,
                    "level": 2,
                    "manager_id": 1003,
                    "manager_name": "王组长",
                    "user_count": 8,
                    "children": []
                }
            ],
            "created_at": "2024-01-01T00:00:00Z"
        }
    ]
}
```

#### 22.4.2 创建部门
**REQ-ID**: REQ-022-004  
**路径**: `POST /admin/departments`  
**适用平台**: Web端  
**权限要求**: department:create  

**请求参数**:
```json
{
    "department_code": "security",
    "department_name": "安全部",
    "description": "负责信息安全管理",
    "parent_id": null,
    "manager_id": 1004,
    "sort_order": 2
}
```

### 22.5 会话管理 API

#### 22.5.1 获取用户会话列表
**REQ-ID**: REQ-022-009  
**路径**: `GET /admin/users/{user_id}/sessions`  
**适用平台**: Web端  
**权限要求**: session:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": [
        {
            "session_id": "sess_abc123",
            "user_id": 1001,
            "device_info": {
                "device_id": "device_123",
                "device_name": "Chrome浏览器",
                "os": "Windows 10",
                "browser": "Chrome 91.0"
            },
            "ip_address": "192.168.1.100",
            "location": "北京市朝阳区",
            "login_time": "2025-08-13T09:30:00Z",
            "last_activity": "2025-08-13T10:25:00Z",
            "expires_at": "2025-08-13T17:30:00Z",
            "is_current": true,
            "status": "active"
        }
    ]
}
```

#### 22.5.2 强制下线用户会话
**REQ-ID**: REQ-022-009  
**路径**: `DELETE /admin/sessions/{session_id}`  
**适用平台**: Web端  
**权限要求**: session:delete  

### 22.6 访问审计 API

#### 22.6.1 获取登录日志
**REQ-ID**: REQ-022-008  
**路径**: `GET /admin/audit/login-logs`  
**适用平台**: Web端  
**权限要求**: audit:read  

**请求参数**:
- `user_id`: 用户ID筛选
- `result`: 登录结果筛选（success, failure）
- `start_time`: 开始时间
- `end_time`: 结束时间
- `ip_address`: IP地址筛选
- `page`: 页码
- `size`: 每页大小

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 500,
        "page": 1,
        "size": 20,
        "items": [
            {
                "log_id": 1,
                "user_id": 1001,
                "username": "zhangsan",
                "tenant_id": 1,
                "login_type": "password",
                "result": "success",
                "ip_address": "192.168.1.100",
                "user_agent": "Mozilla/5.0...",
                "device_info": {
                    "device_id": "device_123",
                    "device_name": "Chrome浏览器",
                    "os": "Windows 10"
                },
                "location": "北京市朝阳区",
                "failure_reason": null,
                "session_id": "sess_abc123",
                "login_time": "2025-08-13T09:30:00Z"
            }
        ]
    }
}
```

#### 22.6.2 获取权限变更日志
**REQ-ID**: REQ-022-008  
**路径**: `GET /admin/audit/permission-logs`  
**适用平台**: Web端  
**权限要求**: audit:read  

**响应结构**:
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 100,
        "items": [
            {
                "log_id": 1,
                "target_user_id": 1001,
                "target_username": "zhangsan",
                "operator_id": 1002,
                "operator_name": "admin",
                "operation_type": "role_assign",
                "operation_description": "分配角色：运维工程师",
                "old_value": null,
                "new_value": "engineer",
                "ip_address": "192.168.1.100",
                "created_at": "2025-08-13T10:30:00Z"
            }
        ]
    }
}
```

---

## Mock 数据示例

### 系统配置列表响应示例
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "total": 45,
        "page": 1,
        "size": 20,
        "items": [
            {
                "config_id": 1,
                "config_key": "system.login.max_attempts",
                "config_value": "5",
                "config_level": "global",
                "category": "security",
                "description": "登录最大尝试次数",
                "data_type": "integer",
                "validation_rule": "min:1,max:10",
                "is_sensitive": false,
                "updated_by": {
                    "id": 1001,
                    "name": "系统管理员",
                    "avatar": "https://cdn.example.com/avatar/admin.jpg"
                },
                "updated_at": "2025-08-10T14:20:00Z"
            },
            {
                "config_id": 2,
                "config_key": "system.session.timeout",
                "config_value": "7200",
                "config_level": "global",
                "category": "security",
                "description": "会话超时时间（秒）",
                "data_type": "integer",
                "validation_rule": "min:300,max:86400",
                "is_sensitive": false,
                "updated_by": {
                    "id": 1001,
                    "name": "系统管理员",
                    "avatar": "https://cdn.example.com/avatar/admin.jpg"
                },
                "updated_at": "2025-08-08T16:30:00Z"
            },
            {
                "config_id": 3,
                "config_key": "notification.email.smtp_host",
                "config_value": "smtp.example.com",
                "config_level": "tenant",
                "category": "notification",
                "description": "邮件SMTP服务器地址",
                "data_type": "string",
                "validation_rule": "required|string",
                "is_sensitive": false,
                "updated_by": {
                    "id": 1002,
                    "name": "租户管理员",
                    "avatar": "https://cdn.example.com/avatar/tenant_admin.jpg"
                },
                "updated_at": "2025-08-05T11:45:00Z"
            }
        ]
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "config_abc123"
}
```

### 用户详情响应示例
```json
{
    "code": 200,
    "message": "获取成功",
    "data": {
        "user_id": 1001,
        "username": "zhangsan",
        "real_name": "张三",
        "email": "zhangsan@example.com",
        "phone": "13800138000",
        "avatar": "https://cdn.example.com/avatar/zhangsan.jpg",
        "user_type": "internal",
        "status": "active",
        "tenant_id": 1,
        "tenant_name": "演示公司",
        "department": {
            "id": 1,
            "name": "技术部",
            "path": "公司/技术部",
            "manager": "李经理",
            "manager_id": 1002
        },
        "roles": [
            {
                "id": 1,
                "name": "运维工程师",
                "code": "engineer",
                "description": "负责系统运维工作",
                "assigned_at": "2024-01-15T10:00:00Z",
                "assigned_by": "系统管理员"
            },
            {
                "id": 2,
                "name": "知识管理员",
                "code": "knowledge_admin",
                "description": "负责知识库管理",
                "assigned_at": "2024-06-01T10:00:00Z",
                "assigned_by": "部门经理"
            }
        ],
        "permissions": [
            "ticket:read",
            "ticket:create",
            "ticket:update",
            "knowledge:read",
            "knowledge:create",
            "knowledge:update"
        ],
        "profile": {
            "job_title": "高级运维工程师",
            "employee_id": "EMP001",
            "hire_date": "2024-01-15",
            "manager_id": 1002,
            "manager_name": "李经理",
            "work_location": "北京市朝阳区",
            "timezone": "Asia/Shanghai",
            "work_phone": "010-12345678",
            "emergency_contact": "13900139000"
        },
        "security": {
            "password_last_changed": "2025-07-15T10:00:00Z",
            "password_expires_at": "2025-10-15T10:00:00Z",
            "mfa_enabled": true,
            "mfa_methods": ["totp", "sms"],
            "trusted_devices": 2,
            "login_attempts": 0,
            "locked_until": null,
            "last_password_reset": "2025-07-15T10:00:00Z",
            "security_questions_set": true
        },
        "activity": {
            "last_login_time": "2025-08-13T09:30:00Z",
            "last_login_ip": "192.168.1.100",
            "last_login_location": "北京市朝阳区",
            "login_count": 1234,
            "current_sessions": 2,
            "last_activity": "2025-08-13T10:25:00Z",
            "total_online_time": 876543,
            "avg_daily_online": 8.5
        },
        "statistics": {
            "tickets_created": 89,
            "tickets_resolved": 156,
            "knowledge_contributed": 23,
            "avg_resolution_time": 145.6,
            "customer_satisfaction": 4.7
        },
        "created_at": "2024-01-15T10:00:00Z",
        "updated_at": "2025-08-10T14:20:00Z",
        "created_by": "系统管理员",
        "last_updated_by": "HR管理员"
    },
    "timestamp": "2025-08-13T10:30:00Z",
    "trace_id": "user_def456"
}
```

---