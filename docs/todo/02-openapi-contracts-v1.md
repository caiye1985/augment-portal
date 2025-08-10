# 任务：接口契约V1（OpenAPI 3.0）（高优先级）

## 目标
- 产出跨模块统一的接口契约V1，支撑并行开发

## 范围
- /crm/contracts, /crm/customers
- /sla/agreements, /sla/events
- /billing/rating, /billing/invoices
- /self-service/faq
- /dispatch/assign

## 交付物
- openapi/contracts-v1.yaml
- 错误码与鉴权规范（参考 API-Standards-v3.md）
- 字段命名遵循 camelCase（JSON）/ snake_case（DB）

## 验收标准
- 通过 OpenAPI 校验
- 至少含10个示例请求/响应（含异常场景）
- 与命名统一表一致（见 00_需求总览.md）

## 时间
- 2个工作日