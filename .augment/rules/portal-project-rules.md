---
name: "IT运维门户系统统一开发规则"
version: "v2.0"
description: "IT运维门户系统（ops-portal）架构、编码、质量保证统一标准，包含强制执行规则与示例"
owner: "架构与DevOps团队"
last_updated: "2025-08-09"
next_review: "2025-10-09"
applies_to:
  branches:
    - main
    - dev
    - feature/*
categories:
  - architecture
  - coding
  - qa
severity:
  default: error
tags:
  - Spring Boot 3.2.11
  - Vue 3.4.15
  - Multi-tenant
type: "always_apply"
---
# 📜 IT运维门户系统统一开发规则

本规则文件用于 **augment 工具** 自动校验开发提交，确保技术栈、架构、代码风格、质量约束的一致性。

---

## 1. 技术架构规则  

### 1.1 技术栈标准化（强制）  
必须使用以下版本（构建阶段会阻断不符合的情况）：  

| 类别 | 组件 | 版本 |
|------|------|------|
| **后端** | JDK | OpenJDK 17 LTS |
|  | Maven | 3.9.6 |
|  | Spring Boot | 3.2.11 |
|  | Spring Security | 6.2.1 |
|  | Spring Data JPA | 3.2.x |
| **数据库与中间件** | PostgreSQL | 15.5 |
|  | Redis | 7.2.4 |
|  | Elasticsearch | 8.15.3 |
|  | RabbitMQ | 3.12.10 |
|  | MinIO | RELEASE.2024-01-01T16-36-33Z |
| **前端** | Vue.js | 3.4.15 |
|  | Vite | 5.0.12 |
|  | Element Plus | 2.4.4 |
|  | Pinia | 2.1.7 |
|  | Vue Router | 4.2.5 |
|  | Axios | 1.6.2 |
| **基础设施** | Docker CLI | 24.0.7 |
|  | Docker Compose | 2.23.3 |
|  | Colima | 0.6.6 |
|  | Nginx | 1.25.3 |

---

### 1.2 模块架构规范  

- `portal-start` 为唯一启动模块（含 `@SpringBootApplication`）  
- 所有业务模块（`portal-auth`、`portal-ticket` 等）**禁止**添加主启动类  
- 公共功能（工具类、常量、异常处理等）统一放 `portal-common`  
- **依赖规则**：
  - 所有模块必须依赖 `portal-common`
  - 业务模块之间禁止直接引用对方内部实现
  - Repository 调用必须通过 Service 层

✅ **示例**  
```java
package com.company.portal.ticket.service;

public interface TicketService { ... }
```
❌ 反例：包结构错误

```java
package com.company.ticket.service;
```

### 1.3 API 设计规范
API 统一前缀 /api/v{version}（当前为 v1）
符合 RESTful HTTP 方法
返回类型统一为 Result<T>
异常统一使用 BusinessException
✅ 示例

java
@GetMapping("/{id}")
public Result<TicketDTO> getTicket(@PathVariable Long id) { ... }
❌ 反例

java
return new AjaxResult().success(data); // 禁止
### 1.4 数据库设计规范
表名：lower_snake_case（例：ticket_comment）
主键：id BIGINT（Java Long）
外键：<表名>_id
所有租户相关表必须含 tenant_id BIGINT
高频查询字段必须建立 B-Tree 索引
### 1.5 安全架构规范
认证：JWT + Spring Security
密码存储：BCrypt
传输加密：TLS 1.3（生产强制）
数据加密：AES-256
权限模式：RBAC + 行级安全
API 安全：限流、CSRF Token、XSS 防护

## 2. 设计规范规则
### 2.1 代码规范
Java
常量：UPPER_SNAKE_CASE
类：PascalCase
方法、变量：camelCase
禁止拼音命名（业务专有词除外）
✅ 示例

```java
private static final int MAX_RETRY = 3;
public Ticket findTicketById(Long id) { ... }
```
❌ 反例

```java
int maxretry = 3;
public Ticket find_ticket(Long uid) { ... }
```

Vue 使用 
```
<script setup> + Composition API
ESLint 规则：eslint:recommended + plugin:vue/vue3-recommended
```

### 2.2 项目结构规范
后端目录结构：

src/main/java/com/fxtech/portal/<module>/
  controller/
  service/
  repository/
  entity/
  dto/
前端目录结构：

src/
  api/
  components/
  views/
  stores/
  utils/
### 2.3 开发流程规范
Git 分支：
main → 生产
dev → 开发集成
feature/* → 新功能
PR 需满足：
Maven + Checkstyle 通过
单元测试通过
至少一次 Code Review
### 2.4 文档标准
API 文档：OpenAPI 3 + Swagger
架构文档位置：docs/architecture/
变更记录：CHANGELOG.md（语义化版本）
## 3. 质量保证机制
### 3.1 自动化检查
后端

Maven Enforcer 检查 Java/Maven/Spring Boot 版本
Checkstyle 检查 Java 代码风格
前端

ESLint 检查 Vue/JS 代码风格
任何错误均终止构建

### 3.2 架构合规检查
禁止业务模块相互直接依赖
API 返回必须统一封装
所有租户数据表必须包含 tenant_id

### 3.3 团队协作规范
PR 检查清单：

 模块包命名符合规范
 API 返回格式符合规范
 未引入未经审批依赖
 已添加单元测试
### 3.4 架构决策记录（ADR）模板
# 决策ID: ADR-YYYYMMDD-XX
## 背景
## 决策
## 影响
## 替代方案