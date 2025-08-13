# IT运维门户系统 API 文档 v4.5

## 1. 文档概述

### 1.1 API 基本信息
- **基础URL**: `https://api.ops-portal.com/api/v1`
- **协议**: HTTPS
- **认证方式**: JWT Bearer Token
- **数据格式**: JSON
- **字符编码**: UTF-8

### 1.2 通用响应格式
所有API接口统一使用以下响应格式：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {},
  "timestamp": 1692000000000
}
```

### 1.3 错误码表
| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 200 | 成功 | - |
| 400 | 请求参数错误 | 检查请求参数格式和必填项 |
| 401 | 未授权 | 检查Token是否有效 |
| 403 | 权限不足 | 联系管理员分配权限 |
| 404 | 资源不存在 | 检查请求路径和资源ID |
| 500 | 服务器内部错误 | 联系技术支持 |

## 2. 认证授权模块

### 2.1 用户登录
**覆盖需求**: REQ-001, REQ-022

**接口信息**:
- **路径**: `POST /auth/login`
- **权限**: 无需认证
- **描述**: 用户登录获取访问令牌

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| username | string | 是 | 用户名 | admin |
| password | string | 是 | 密码 | password123 |
| tenantCode | string | 是 | 租户代码 | tenant001 |
| loginType | string | 否 | 登录类型 | PASSWORD |

**响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200,
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "roles": ["ADMIN"],
      "tenantId": 1
    }
  },
  "timestamp": 1692000000000
}
```

### 2.2 刷新令牌
**覆盖需求**: REQ-001

**接口信息**:
- **路径**: `POST /auth/refresh`
- **权限**: 需要有效的refreshToken
- **描述**: 使用刷新令牌获取新的访问令牌

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| refreshToken | string | 是 | 刷新令牌 | eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... |

**响应示例**:
```json
{
  "code": 200,
  "message": "令牌刷新成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200
  },
  "timestamp": 1692000000000
}
```

### 2.3 用户登出
**覆盖需求**: REQ-001

**接口信息**:
- **路径**: `POST /auth/logout`
- **权限**: 需要认证
- **描述**: 用户登出，使令牌失效

**请求参数**: 无

**响应示例**:
```json
{
  "code": 200,
  "message": "登出成功",
  "data": null,
  "timestamp": 1692000000000
}
```

## 3. 工单管理模块

### 3.1 创建工单
**覆盖需求**: REQ-003

**接口信息**:
- **路径**: `POST /tickets`
- **权限**: 需要认证，CREATE_TICKET权限
- **描述**: 创建新的工单

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| title | string | 是 | 工单标题 | 服务器无法访问 |
| description | string | 是 | 工单描述 | 服务器192.168.1.100无法ping通 |
| priority | string | 是 | 优先级 | HIGH |
| category | string | 是 | 工单分类 | NETWORK |
| customerId | long | 否 | 客户ID | 1001 |
| attachments | array | 否 | 附件列表 | ["file1.jpg", "file2.pdf"] |

**响应示例**:
```json
{
  "code": 200,
  "message": "工单创建成功",
  "data": {
    "id": 12345,
    "ticketNo": "TK202308130001",
    "title": "服务器无法访问",
    "description": "服务器192.168.1.100无法ping通",
    "priority": "HIGH",
    "status": "OPEN",
    "category": "NETWORK",
    "creatorId": 1,
    "creatorName": "张三",
    "customerId": 1001,
    "customerName": "ABC公司",
    "createdAt": "2023-08-13T10:30:00Z",
    "updatedAt": "2023-08-13T10:30:00Z"
  },
  "timestamp": 1692000000000
}
```

### 3.2 查询工单列表
**覆盖需求**: REQ-003

**接口信息**:
- **路径**: `GET /tickets`
- **权限**: 需要认证，VIEW_TICKET权限
- **描述**: 分页查询工单列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| page | int | 否 | 页码，从1开始 | 1 |
| size | int | 否 | 每页大小 | 20 |
| status | string | 否 | 工单状态 | OPEN |
| priority | string | 否 | 优先级 | HIGH |
| category | string | 否 | 分类 | NETWORK |
| assigneeId | long | 否 | 处理人ID | 2001 |
| customerId | long | 否 | 客户ID | 1001 |
| keyword | string | 否 | 关键词搜索 | 服务器 |
| startDate | string | 否 | 开始日期 | 2023-08-01 |
| endDate | string | 否 | 结束日期 | 2023-08-31 |

**响应示例**:
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "content": [
      {
        "id": 12345,
        "ticketNo": "TK202308130001",
        "title": "服务器无法访问",
        "priority": "HIGH",
        "status": "OPEN",
        "category": "NETWORK",
        "assigneeName": "李四",
        "customerName": "ABC公司",
        "createdAt": "2023-08-13T10:30:00Z",
        "slaDeadline": "2023-08-13T14:30:00Z"
      }
    ],
    "totalElements": 150,
    "totalPages": 8,
    "currentPage": 1,
    "pageSize": 20
  },
  "timestamp": 1692000000000
}
```

### 3.3 获取工单详情
**覆盖需求**: REQ-003

**接口信息**:
- **路径**: `GET /tickets/{id}`
- **权限**: 需要认证，VIEW_TICKET权限
- **描述**: 获取指定工单的详细信息

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| id | long | 是 | 工单ID | 12345 |

**响应示例**:
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "id": 12345,
    "ticketNo": "TK202308130001",
    "title": "服务器无法访问",
    "description": "服务器192.168.1.100无法ping通，影响业务正常运行",
    "priority": "HIGH",
    "status": "IN_PROGRESS",
    "category": "NETWORK",
    "creator": {
      "id": 1,
      "name": "张三",
      "email": "zhangsan@abc.com"
    },
    "assignee": {
      "id": 2001,
      "name": "李四",
      "email": "lisi@ops.com",
      "phone": "13800138000"
    },
    "customer": {
      "id": 1001,
      "name": "ABC公司",
      "contact": "王五",
      "phone": "13900139000"
    },
    "sla": {
      "responseTime": 30,
      "resolveTime": 240,
      "deadline": "2023-08-13T14:30:00Z",
      "remainingTime": 120
    },
    "attachments": [
      {
        "id": 1,
        "name": "error_screenshot.png",
        "url": "/files/attachments/error_screenshot.png",
        "size": 1024000
      }
    ],
    "logs": [
      {
        "id": 1,
        "action": "CREATE",
        "description": "工单创建",
        "operator": "张三",
        "createdAt": "2023-08-13T10:30:00Z"
      },
      {
        "id": 2,
        "action": "ASSIGN",
        "description": "工单已分配给李四",
        "operator": "系统",
        "createdAt": "2023-08-13T10:31:00Z"
      }
    ],
    "createdAt": "2023-08-13T10:30:00Z",
    "updatedAt": "2023-08-13T10:31:00Z"
  },
  "timestamp": 1692000000000
}
```

### 3.4 更新工单状态
**覆盖需求**: REQ-003

**接口信息**:
- **路径**: `PUT /tickets/{id}/status`
- **权限**: 需要认证，UPDATE_TICKET权限
- **描述**: 更新工单状态

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| id | long | 是 | 工单ID | 12345 |

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| status | string | 是 | 新状态 | RESOLVED |
| comment | string | 否 | 状态变更说明 | 问题已解决 |
| resolution | string | 否 | 解决方案 | 重启网络设备 |

**响应示例**:
```json
{
  "code": 200,
  "message": "状态更新成功",
  "data": {
    "id": 12345,
    "status": "RESOLVED",
    "updatedAt": "2023-08-13T12:30:00Z"
  },
  "timestamp": 1692000000000
}
```

## 4. 智能派单模块

### 4.1 智能派单
**覆盖需求**: REQ-004

**接口信息**:
- **路径**: `POST /dispatch/auto`
- **权限**: 需要认证，DISPATCH_TICKET权限
- **描述**: 基于AI算法自动派发工单

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| ticketId | long | 是 | 工单ID | 12345 |
| forceAssign | boolean | 否 | 强制分配 | false |

**响应示例**:
```json
{
  "code": 200,
  "message": "派单成功",
  "data": {
    "ticketId": 12345,
    "assigneeId": 2001,
    "assigneeName": "李四",
    "reason": "技能匹配度95%，当前工作负载60%",
    "confidence": 0.95,
    "alternatives": [
      {
        "engineerId": 2002,
        "engineerName": "王五",
        "score": 0.88,
        "reason": "技能匹配度90%，当前工作负载40%"
      }
    ],
    "assignedAt": "2023-08-13T10:31:00Z"
  },
  "timestamp": 1692000000000
}
```

### 4.2 手动派单
**覆盖需求**: REQ-004

**接口信息**:
- **路径**: `POST /dispatch/manual`
- **权限**: 需要认证，DISPATCH_TICKET权限
- **描述**: 手动指定工程师处理工单

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| ticketId | long | 是 | 工单ID | 12345 |
| assigneeId | long | 是 | 指定工程师ID | 2001 |
| reason | string | 否 | 派单原因 | 专业对口 |

**响应示例**:
```json
{
  "code": 200,
  "message": "派单成功",
  "data": {
    "ticketId": 12345,
    "assigneeId": 2001,
    "assigneeName": "李四",
    "assignedAt": "2023-08-13T10:31:00Z"
  },
  "timestamp": 1692000000000
}
```

### 4.3 获取可用工程师
**覆盖需求**: REQ-004, REQ-006A

**接口信息**:
- **路径**: `GET /dispatch/engineers/available`
- **权限**: 需要认证，VIEW_ENGINEER权限
- **描述**: 获取当前可用的工程师列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| skillTags | string | 否 | 技能标签，逗号分隔 | NETWORK,SERVER |
| maxWorkload | int | 否 | 最大工作负载百分比 | 80 |

**响应示例**:
```json
{
  "code": 200,
  "message": "查询成功",
  "data": [
    {
      "id": 2001,
      "name": "李四",
      "email": "lisi@ops.com",
      "phone": "13800138000",
      "status": "ONLINE",
      "workload": 60,
      "skillTags": ["NETWORK", "SERVER", "DATABASE"],
      "currentTickets": 3,
      "avgResponseTime": 15,
      "satisfaction": 4.8,
      "location": "北京"
    }
  ],
  "timestamp": 1692000000000
}
```

## 5. 知识库模块

### 5.1 搜索知识
**覆盖需求**: REQ-005

**接口信息**:
- **路径**: `GET /knowledge/search`
- **权限**: 需要认证，VIEW_KNOWLEDGE权限
- **描述**: 全文搜索知识库内容

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| keyword | string | 是 | 搜索关键词 | 网络故障 |
| category | string | 否 | 知识分类 | NETWORK |
| page | int | 否 | 页码 | 1 |
| size | int | 否 | 每页大小 | 10 |

**响应示例**:
```json
{
  "code": 200,
  "message": "搜索成功",
  "data": {
    "content": [
      {
        "id": 1001,
        "title": "网络故障排查指南",
        "summary": "详细介绍网络故障的常见原因和排查步骤...",
        "category": "NETWORK",
        "tags": ["网络", "故障", "排查"],
        "author": "技术专家",
        "viewCount": 1250,
        "likeCount": 89,
        "createdAt": "2023-08-01T09:00:00Z",
        "updatedAt": "2023-08-10T15:30:00Z"
      }
    ],
    "totalElements": 25,
    "totalPages": 3,
    "currentPage": 1,
    "pageSize": 10
  },
  "timestamp": 1692000000000
}
```

### 5.2 获取知识详情
**覆盖需求**: REQ-005

**接口信息**:
- **路径**: `GET /knowledge/{id}`
- **权限**: 需要认证，VIEW_KNOWLEDGE权限
- **描述**: 获取知识文档详细内容

**路径参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| id | long | 是 | 知识ID | 1001 |

**响应示例**:
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "id": 1001,
    "title": "网络故障排查指南",
    "content": "# 网络故障排查指南\n\n## 1. 基础检查\n...",
    "category": "NETWORK",
    "tags": ["网络", "故障", "排查"],
    "author": {
      "id": 3001,
      "name": "技术专家",
      "avatar": "/avatars/expert.jpg"
    },
    "status": "PUBLISHED",
    "viewCount": 1251,
    "likeCount": 89,
    "attachments": [
      {
        "id": 1,
        "name": "network_diagram.png",
        "url": "/files/knowledge/network_diagram.png"
      }
    ],
    "relatedKnowledge": [
      {
        "id": 1002,
        "title": "路由器配置指南",
        "similarity": 0.85
      }
    ],
    "createdAt": "2023-08-01T09:00:00Z",
    "updatedAt": "2023-08-10T15:30:00Z"
  },
  "timestamp": 1692000000000
}
```

### 5.3 智能推荐知识
**覆盖需求**: REQ-005

**接口信息**:
- **路径**: `GET /knowledge/recommend`
- **权限**: 需要认证，VIEW_KNOWLEDGE权限
- **描述**: 基于工单内容推荐相关知识

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| ticketId | long | 否 | 工单ID | 12345 |
| content | string | 否 | 文本内容 | 服务器无法访问 |
| limit | int | 否 | 推荐数量 | 5 |

**响应示例**:
```json
{
  "code": 200,
  "message": "推荐成功",
  "data": [
    {
      "id": 1001,
      "title": "网络故障排查指南",
      "summary": "详细介绍网络故障的常见原因和排查步骤",
      "relevance": 0.92,
      "reason": "内容匹配度高，包含关键词'网络'、'故障'"
    },
    {
      "id": 1003,
      "title": "服务器连接问题解决方案",
      "summary": "服务器无法访问的常见解决方案",
      "relevance": 0.88,
      "reason": "标题匹配度高，解决类似问题"
    }
  ],
  "timestamp": 1692000000000
}
```

## 6. 用户管理模块

### 6.1 获取用户列表
**覆盖需求**: REQ-022

**接口信息**:
- **路径**: `GET /users`
- **权限**: 需要认证，VIEW_USER权限
- **描述**: 分页查询用户列表

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| page | int | 否 | 页码 | 1 |
| size | int | 否 | 每页大小 | 20 |
| keyword | string | 否 | 搜索关键词 | 张三 |
| status | string | 否 | 用户状态 | ACTIVE |
| roleId | long | 否 | 角色ID | 1 |

**响应示例**:
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "content": [
      {
        "id": 1,
        "username": "zhangsan",
        "email": "zhangsan@example.com",
        "realName": "张三",
        "phone": "13800138000",
        "status": "ACTIVE",
        "roles": [
          {
            "id": 1,
            "name": "管理员",
            "code": "ADMIN"
          }
        ],
        "lastLoginAt": "2023-08-13T09:30:00Z",
        "createdAt": "2023-08-01T10:00:00Z"
      }
    ],
    "totalElements": 50,
    "totalPages": 3,
    "currentPage": 1,
    "pageSize": 20
  },
  "timestamp": 1692000000000
}
```

### 6.2 创建用户
**覆盖需求**: REQ-022

**接口信息**:
- **路径**: `POST /users`
- **权限**: 需要认证，CREATE_USER权限
- **描述**: 创建新用户

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| username | string | 是 | 用户名 | lisi |
| email | string | 是 | 邮箱 | lisi@example.com |
| realName | string | 是 | 真实姓名 | 李四 |
| phone | string | 否 | 手机号 | 13900139000 |
| password | string | 是 | 密码 | password123 |
| roleIds | array | 是 | 角色ID列表 | [2, 3] |

**响应示例**:
```json
{
  "code": 200,
  "message": "用户创建成功",
  "data": {
    "id": 2,
    "username": "lisi",
    "email": "lisi@example.com",
    "realName": "李四",
    "phone": "13900139000",
    "status": "ACTIVE",
    "createdAt": "2023-08-13T10:30:00Z"
  },
  "timestamp": 1692000000000
}
```

## 7. 系统管理模块

### 7.1 获取系统配置
**覆盖需求**: REQ-010

**接口信息**:
- **路径**: `GET /system/config`
- **权限**: 需要认证，VIEW_SYSTEM_CONFIG权限
- **描述**: 获取系统配置信息

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| category | string | 否 | 配置分类 | SYSTEM |

**响应示例**:
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "SYSTEM": {
      "systemName": "IT运维门户系统",
      "version": "v4.5",
      "maxFileSize": 10485760,
      "sessionTimeout": 7200
    },
    "NOTIFICATION": {
      "emailEnabled": true,
      "smsEnabled": true,
      "pushEnabled": true
    }
  },
  "timestamp": 1692000000000
}
```

### 7.2 更新系统配置
**覆盖需求**: REQ-010

**接口信息**:
- **路径**: `PUT /system/config`
- **权限**: 需要认证，UPDATE_SYSTEM_CONFIG权限
- **描述**: 更新系统配置

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| category | string | 是 | 配置分类 | SYSTEM |
| configs | object | 是 | 配置项 | {"maxFileSize": 20971520} |

**响应示例**:
```json
{
  "code": 200,
  "message": "配置更新成功",
  "data": {
    "category": "SYSTEM",
    "updatedConfigs": {
      "maxFileSize": 20971520
    },
    "updatedAt": "2023-08-13T10:30:00Z"
  },
  "timestamp": 1692000000000
}
```

## 8. 文件上传模块

### 8.1 上传文件
**覆盖需求**: REQ-001

**接口信息**:
- **路径**: `POST /files/upload`
- **权限**: 需要认证
- **描述**: 上传文件到服务器
- **Content-Type**: multipart/form-data

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| file | file | 是 | 上传的文件 | - |
| category | string | 否 | 文件分类 | TICKET_ATTACHMENT |

**响应示例**:
```json
{
  "code": 200,
  "message": "文件上传成功",
  "data": {
    "id": 1001,
    "originalName": "screenshot.png",
    "fileName": "20230813_103000_screenshot.png",
    "filePath": "/files/uploads/20230813_103000_screenshot.png",
    "fileSize": 1024000,
    "mimeType": "image/png",
    "uploadedAt": "2023-08-13T10:30:00Z"
  },
  "timestamp": 1692000000000
}
```

## 9. 统计报表模块

### 9.1 工单统计
**覆盖需求**: REQ-007

**接口信息**:
- **路径**: `GET /reports/tickets/statistics`
- **权限**: 需要认证，VIEW_REPORT权限
- **描述**: 获取工单统计数据

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| startDate | string | 是 | 开始日期 | 2023-08-01 |
| endDate | string | 是 | 结束日期 | 2023-08-31 |
| groupBy | string | 否 | 分组方式 | DAY |
| customerId | long | 否 | 客户ID | 1001 |

**响应示例**:
```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "summary": {
      "totalTickets": 150,
      "openTickets": 25,
      "inProgressTickets": 30,
      "resolvedTickets": 95,
      "avgResponseTime": 28,
      "avgResolveTime": 180,
      "slaAchievementRate": 0.96
    },
    "trends": [
      {
        "date": "2023-08-01",
        "created": 8,
        "resolved": 6,
        "avgResponseTime": 25
      },
      {
        "date": "2023-08-02",
        "created": 12,
        "resolved": 10,
        "avgResponseTime": 30
      }
    ],
    "categoryDistribution": [
      {
        "category": "NETWORK",
        "count": 45,
        "percentage": 0.30
      },
      {
        "category": "SERVER",
        "count": 38,
        "percentage": 0.25
      }
    ]
  },
  "timestamp": 1692000000000
}
```

---

**文档版本**: v4.5  
**最后更新**: 2025年8月13日  
**维护团队**: API开发团队