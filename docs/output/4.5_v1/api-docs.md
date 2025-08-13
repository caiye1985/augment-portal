# IT运维门户系统 API 文档 v4.5

## 1. API 概述

### 1.1 基本信息
- **Base URL**: `https://api.ops-portal.com/api/v1`
- **认证方式**: JWT Bearer Token
- **数据格式**: JSON
- **字符编码**: UTF-8
- **API版本**: v1

### 1.2 通用响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2025-08-13T10:30:00Z",
  "traceId": "abc123def456"
}
```

### 1.3 错误码说明
| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 200 | 成功 | - |
| 400 | 请求参数错误 | 检查请求参数 |
| 401 | 未授权 | 重新登录获取Token |
| 403 | 权限不足 | 联系管理员分配权限 |
| 404 | 资源不存在 | 检查资源ID |
| 500 | 服务器内部错误 | 联系技术支持 |

## 2. 认证授权模块 (REQ-001, REQ-022)

### 2.1 用户登录
**接口路径**: `POST /auth/login`  
**覆盖需求**: REQ-001-002, REQ-022-001  
**适用平台**: Web / Mobile / Both  
**权限要求**: 无

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名或邮箱 |
| password | string | 是 | 密码 |
| tenantId | string | 否 | 租户ID |
| captcha | string | 否 | 验证码 |

**响应结构**:
```json
{
  "code": 200,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_string",
    "expiresIn": 7200,
    "userInfo": {
      "id": 1001,
      "username": "admin",
      "email": "admin@example.com",
      "roles": ["ADMIN"],
      "tenantId": "tenant_001"
    }
  }
}
```

### 2.2 获取用户信息
**接口路径**: `GET /auth/userinfo`  
**覆盖需求**: REQ-001-002, REQ-022-002  
**适用平台**: Both  
**权限要求**: 已登录用户

**响应结构**:
```json
{
  "code": 200,
  "data": {
    "id": 1001,
    "username": "admin",
    "email": "admin@example.com",
    "avatar": "https://cdn.example.com/avatar.jpg",
    "roles": ["ADMIN"],
    "permissions": ["ticket:read", "ticket:write"],
    "tenantId": "tenant_001"
  }
}
```

### 2.3 刷新Token
**接口路径**: `POST /auth/refresh`  
**覆盖需求**: REQ-001-002  
**适用平台**: Both  
**权限要求**: 有效的refreshToken

## 3. 工单管理模块 (REQ-003)

### 3.1 获取工单列表
**接口路径**: `GET /tickets`  
**覆盖需求**: REQ-003-006  
**适用平台**: Both  
**权限要求**: ticket:read

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page | integer | 否 | 页码，默认1 |
| size | integer | 否 | 每页大小，默认20 |
| status | string | 否 | 工单状态筛选 |
| priority | string | 否 | 优先级筛选 |
| assigneeId | integer | 否 | 处理人ID |
| keyword | string | 否 | 关键词搜索 |

**响应结构**:
```json
{
  "code": 200,
  "data": {
    "total": 150,
    "page": 1,
    "size": 20,
    "items": [
      {
        "id": 1001,
        "title": "服务器无法访问",
        "description": "生产环境服务器突然无法访问",
        "status": "OPEN",
        "priority": "HIGH",
        "category": "INFRASTRUCTURE",
        "assigneeId": 2001,
        "assigneeName": "张工程师",
        "reporterId": 3001,
        "reporterName": "李客户",
        "createdAt": "2025-08-13T09:00:00Z",
        "updatedAt": "2025-08-13T10:30:00Z",
        "slaDeadline": "2025-08-13T13:00:00Z"
      }
    ]
  }
}
```

### 3.2 获取工单详情
**接口路径**: `GET /tickets/{id}`  
**覆盖需求**: REQ-003-004  
**适用平台**: Both  
**权限要求**: ticket:read

**响应结构**:
```json
{
  "code": 200,
  "data": {
    "id": 1001,
    "title": "服务器无法访问",
    "description": "生产环境服务器突然无法访问，影响业务正常运行",
    "status": "IN_PROGRESS",
    "priority": "HIGH",
    "category": "INFRASTRUCTURE",
    "tags": ["服务器", "网络"],
    "assigneeId": 2001,
    "assigneeName": "张工程师",
    "reporterId": 3001,
    "reporterName": "李客户",
    "createdAt": "2025-08-13T09:00:00Z",
    "updatedAt": "2025-08-13T10:30:00Z",
    "slaDeadline": "2025-08-13T13:00:00Z",
    "attachments": [
      {
        "id": 5001,
        "name": "error_log.txt",
        "url": "https://cdn.example.com/files/error_log.txt",
        "size": 1024
      }
    ],
    "comments": [
      {
        "id": 6001,
        "content": "正在检查网络连接",
        "authorId": 2001,
        "authorName": "张工程师",
        "createdAt": "2025-08-13T10:15:00Z"
      }
    ]
  }
}
```

### 3.3 创建工单
**接口路径**: `POST /tickets`  
**覆盖需求**: REQ-003-001  
**适用平台**: Both  
**权限要求**: ticket:write

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| title | string | 是 | 工单标题 |
| description | string | 是 | 问题描述 |
| priority | string | 是 | 优先级：LOW/MEDIUM/HIGH/URGENT |
| category | string | 是 | 分类 |
| tags | array | 否 | 标签数组 |
| attachments | array | 否 | 附件ID数组 |

### 3.4 更新工单状态
**接口路径**: `PUT /tickets/{id}/status`  
**覆盖需求**: REQ-003-004  
**适用平台**: Both  
**权限要求**: ticket:write

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| status | string | 是 | 新状态 |
| comment | string | 否 | 状态变更说明 |

## 4. 智能派单模块 (REQ-004)

### 4.1 获取待派单列表
**接口路径**: `GET /dispatch/pending`  
**覆盖需求**: REQ-004-001  
**适用平台**: Web  
**权限要求**: dispatch:read

### 4.2 执行智能派单
**接口路径**: `POST /dispatch/auto`  
**覆盖需求**: REQ-004-002  
**适用平台**: Web  
**权限要求**: dispatch:execute

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| ticketIds | array | 是 | 工单ID数组 |
| algorithm | string | 否 | 派单算法：AUTO/LOAD_BALANCE/SKILL_MATCH |

### 4.3 接受派单
**接口路径**: `POST /dispatch/{id}/accept`  
**覆盖需求**: REQ-004-003  
**适用平台**: Mobile  
**权限要求**: engineer:self

## 5. 工程师管理模块 (REQ-006A, REQ-006B)

### 5.1 获取工程师列表
**接口路径**: `GET /engineers`  
**覆盖需求**: REQ-006A-001  
**适用平台**: Web  
**权限要求**: engineer:read

### 5.2 获取工程师详情
**接口路径**: `GET /engineers/{id}`  
**覆盖需求**: REQ-006A-002  
**适用平台**: Both  
**权限要求**: engineer:read

### 5.3 更新工程师状态
**接口路径**: `PUT /engineers/{id}/status`  
**覆盖需求**: REQ-006A-003  
**适用平台**: Mobile  
**权限要求**: engineer:self

### 5.4 获取工程师绩效
**接口路径**: `GET /engineers/{id}/performance`  
**覆盖需求**: REQ-006B-001  
**适用平台**: Web  
**权限要求**: performance:read

## 6. 知识库模块 (REQ-005)

### 6.1 搜索知识库
**接口路径**: `GET /knowledge/search`  
**覆盖需求**: REQ-005-003  
**适用平台**: Both  
**权限要求**: knowledge:read

**请求参数**:
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| q | string | 是 | 搜索关键词 |
| category | string | 否 | 分类筛选 |
| page | integer | 否 | 页码 |
| size | integer | 否 | 每页大小 |

### 6.2 获取知识文档
**接口路径**: `GET /knowledge/{id}`  
**覆盖需求**: REQ-005-001  
**适用平台**: Both  
**权限要求**: knowledge:read

## 7. 通知消息模块 (REQ-011)

### 7.1 获取通知列表
**接口路径**: `GET /notifications`  
**覆盖需求**: REQ-011-001  
**适用平台**: Both  
**权限要求**: notification:read

### 7.2 标记消息已读
**接口路径**: `PUT /notifications/{id}/read`  
**覆盖需求**: REQ-011-002  
**适用平台**: Both  
**权限要求**: notification:write

### 7.3 发送通知
**接口路径**: `POST /notifications/send`  
**覆盖需求**: REQ-011-003  
**适用平台**: Web  
**权限要求**: notification:send

## 8. 客户管理模块 (REQ-016)

### 8.1 获取客户列表
**接口路径**: `GET /customers`  
**覆盖需求**: REQ-016-001  
**适用平台**: Web  
**权限要求**: customer:read

### 8.2 获取客户详情
**接口路径**: `GET /customers/{id}`  
**覆盖需求**: REQ-016-002  
**适用平台**: Both  
**权限要求**: customer:read

## 9. SLA管理模块 (REQ-017)

### 9.1 获取SLA配置
**接口路径**: `GET /sla/config`  
**覆盖需求**: REQ-017-001  
**适用平台**: Web  
**权限要求**: sla:read

### 9.2 获取SLA统计
**接口路径**: `GET /sla/metrics`  
**覆盖需求**: REQ-017-003  
**适用平台**: Both  
**权限要求**: sla:read

## 10. 财务管理模块 (REQ-018)

### 10.1 获取计费配置
**接口路径**: `GET /billing/config`  
**覆盖需求**: REQ-018-001  
**适用平台**: Web  
**权限要求**: billing:read

### 10.2 生成账单
**接口路径**: `POST /billing/generate`  
**覆盖需求**: REQ-018-002  
**适用平台**: Web  
**权限要求**: billing:generate

## 11. 文件管理

### 11.1 上传文件
**接口路径**: `POST /files/upload`  
**覆盖需求**: REQ-003-001  
**适用平台**: Both  
**权限要求**: file:upload

**请求格式**: multipart/form-data

### 11.2 下载文件
**接口路径**: `GET /files/{id}/download`  
**覆盖需求**: REQ-003-004  
**适用平台**: Both  
**权限要求**: file:download

## 12. Mock 示例

### 12.1 工单列表 Mock
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 3,
    "items": [
      {
        "id": 1001,
        "title": "数据库连接异常",
        "status": "OPEN",
        "priority": "HIGH",
        "assigneeName": "张三",
        "createdAt": "2025-08-13T09:00:00Z"
      },
      {
        "id": 1002,
        "title": "网络延迟问题",
        "status": "IN_PROGRESS",
        "priority": "MEDIUM",
        "assigneeName": "李四",
        "createdAt": "2025-08-13T08:30:00Z"
      }
    ]
  }
}
```

### 12.2 用户信息 Mock
```json
{
  "code": 200,
  "data": {
    "id": 1001,
    "username": "admin",
    "email": "admin@example.com",
    "roles": ["ADMIN"],
    "permissions": ["*"],
    "tenantId": "tenant_001"
  }
}
```

## 13. 系统管理模块 (REQ-010)

### 13.1 获取系统配置
**接口路径**: `GET /system/config`
**覆盖需求**: REQ-010-001
**适用平台**: Web
**权限要求**: system:read

### 13.2 更新系统配置
**接口路径**: `PUT /system/config`
**覆盖需求**: REQ-010-002
**适用平台**: Web
**权限要求**: system:write

### 13.3 获取审计日志
**接口路径**: `GET /system/audit`
**覆盖需求**: REQ-010-003
**适用平台**: Web
**权限要求**: audit:read

## 14. 仪表板模块 (REQ-002)

### 14.1 获取仪表板数据
**接口路径**: `GET /dashboard/data`
**覆盖需求**: REQ-002-001
**适用平台**: Both
**权限要求**: dashboard:read

### 14.2 获取实时数据
**接口路径**: `GET /dashboard/realtime`
**覆盖需求**: REQ-002-002
**适用平台**: Both
**权限要求**: dashboard:read

### 14.3 保存仪表板配置
**接口路径**: `PUT /dashboard/config`
**覆盖需求**: REQ-002-003
**适用平台**: Web
**权限要求**: dashboard:write

## 15. 报表模块 (REQ-007)

### 15.1 生成服务报表
**接口路径**: `POST /reports/service`
**覆盖需求**: REQ-007-002
**适用平台**: Web
**权限要求**: report:generate

### 15.2 获取报表列表
**接口路径**: `GET /reports`
**覆盖需求**: REQ-007-001
**适用平台**: Web
**权限要求**: report:read

### 15.3 下载报表
**接口路径**: `GET /reports/{id}/download`
**覆盖需求**: REQ-007-003
**适用平台**: Web
**权限要求**: report:download

---

**文档版本**: v4.5
**最后更新**: 2025年8月13日
**维护团队**: API开发团队
