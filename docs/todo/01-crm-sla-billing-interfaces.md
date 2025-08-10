# 任务：CRM→SLA→财务接口链路（高优先级）

## 背景
- 断点：REQ-016(新增) → REQ-017(新增) → REQ-018(新增) 三段关键商业化链路未落地
- 参考：<mcfile name="00_需求总览.md" path="/Users/caiye/Projects/ops/ops-portal/docs/prd/full/00_需求总览.md"></mcfile> 依赖说明；<mcfile name="20250810.md" path="/Users/caiye/Projects/ops/ops-portal/docs/business/20250810.md"></mcfile> 风险/缺口

## 目标
- 定义并实现最小可用接口（接口先行+模拟数据），打通 CRM→SLA→财务数据链

## 范围
- CRM: /crm/contracts, /crm/customers
- SLA: /sla/agreements, /sla/events
- Billing: /billing/rating, /billing/invoices

## 交付物
- OpenAPI 3.0 契约（YAML）
- Mock Server 可运行
- 集成用 Postman 集合/测试

## 验收标准
- 从创建合同行为到开具发票的 E2E 流程在 Mock 环境成功
- 核心字段完整：contractId, plan, terms, slaMetrics, penaltyRule, ratingRule, invoiceItems

## 依赖
- 02-openapi-contracts-v1
- 03-sla-events-and-billing-subscription

## 时间
- 3个工作日（并行可拆）