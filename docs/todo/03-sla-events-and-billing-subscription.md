# 任务：SLA事件流与财务订阅（高优先级）

## 目标
- 定义并实现 SLA 事件（达成/违约）与财务订阅机制

## 事件
- SLA_METRIC_ACHIEVED
- SLA_BREACH

## 交付物
- 事件总线主题定义与消息Schema
- 财务侧订阅与入账规则文档
- 演示用生产/消费脚本

## 验收标准
- 违约→财务生成赔偿记录全链路通过
- 事件可追溯（含traceId、timestamp、contractId）

## 时间
- 2个工作日