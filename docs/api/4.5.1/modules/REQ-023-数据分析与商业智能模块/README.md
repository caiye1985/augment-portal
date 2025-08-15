# REQ-023 数据分析与商业智能模块 API 规范

## 概述

本文档描述了 REQ-023 数据分析与商业智能模块的 OpenAPI 3.0.3 规范，提供完整的数据分析、智能预测、实时监控和商业智能功能。

## 文件结构

```
docs/api/4.5.1/modules/REQ-023-数据分析与商业智能模块/
├── openapi.yaml          # 模块完整 API 规范
└── README.md             # 本说明文档
```

## API 功能概览

### 核心功能模块

1. **分析任务管理** (`/api/v1/analytics/tasks`)
   - 创建、查询、更新、删除分析任务
   - 执行、暂停、恢复任务
   - 获取执行状态和日志

2. **分析结果管理** (`/api/v1/analytics/results`)
   - 查询分析结果列表和详情
   - 导出结果为多种格式
   - 结果分享和缓存管理

3. **模型管理** (`/api/v1/analytics/models`)
   - 创建和管理机器学习模型
   - 模型训练、部署、下线
   - 模型预测和版本管理

4. **数据源管理** (`/api/v1/analytics/datasets`)
   - 数据源连接配置
   - 数据同步和质量监控
   - 数据预览和统计分析

## 主要 API 端点

### 分析任务管理
- `POST /api/v1/analytics/tasks` - 创建分析任务
- `GET /api/v1/analytics/tasks` - 获取任务列表
- `GET /api/v1/analytics/tasks/{id}` - 获取任务详情
- `PUT /api/v1/analytics/tasks/{id}` - 更新任务配置
- `DELETE /api/v1/analytics/tasks/{id}` - 删除任务
- `POST /api/v1/analytics/tasks/{id}/execute` - 执行任务
- `POST /api/v1/analytics/tasks/{id}/pause` - 暂停任务
- `POST /api/v1/analytics/tasks/{id}/resume` - 恢复任务
- `GET /api/v1/analytics/tasks/{id}/status` - 获取执行状态
- `GET /api/v1/analytics/tasks/{id}/logs` - 获取执行日志

### 分析结果管理
- `GET /api/v1/analytics/results` - 获取结果列表
- `GET /api/v1/analytics/results/{id}` - 获取结果详情
- `POST /api/v1/analytics/results/{id}/export` - 导出结果

### 模型管理
- `POST /api/v1/analytics/models` - 创建模型
- `GET /api/v1/analytics/models` - 获取模型列表
- `POST /api/v1/analytics/models/{id}/train` - 训练模型
- `POST /api/v1/analytics/models/{id}/predict` - 模型预测

### 数据源管理
- `POST /api/v1/analytics/datasets` - 创建数据源
- `GET /api/v1/analytics/datasets` - 获取数据源列表

## 数据模型

### 核心枚举类型
- `TaskType`: operational_analysis, predictive_analysis, real_time_monitoring, custom_report
- `TaskStatus`: pending, running, completed, failed, paused
- `ModelType`: regression, classification, clustering, time_series, anomaly_detection
- `ModelStatus`: training, deployed, offline, failed
- `DatasetType`: structured, unstructured, streaming
- `ResultType`: chart, table, metric, prediction, dashboard, report

### 主要 Schema
- `AnalysisTaskInfo` - 分析任务基本信息
- `AnalysisTaskDetailInfo` - 分析任务详细信息
- `AnalysisResultInfo` - 分析结果基本信息
- `AnalysisResultDetailInfo` - 分析结果详细信息
- `AnalysisModelInfo` - 分析模型信息
- `AnalysisDatasetInfo` - 数据集信息
- `AnalysisInsightInfo` - 智能洞察信息

## Mock 数据示例

所有 API 响应都包含符合 IT 运维业务语境的真实感 Mock 数据：

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "id": 12345,
    "task_name": "月度运营效率分析",
    "task_type": "operational_analysis",
    "status": "completed",
    "confidence_score": 95.6,
    "created_at": "2024-08-01T09:00:00Z"
  },
  "timestamp": "2024-08-14T14:30:00Z"
}
```

## 技术特性

### 多租户支持
- 所有数据模型包含 `tenant_id` 字段
- 严格的租户数据隔离

### 时间格式标准
- 统一使用 ISO8601 UTC 格式
- 示例: `"2024-08-14T14:30:00Z"`

### 错误处理
- 标准 HTTP 状态码
- 统一错误响应格式
- 详细错误信息和处理建议

### 引用规范
- 正确的 JSON Pointer 语法
- 相对路径引用全局组件
- 三级分离引用架构

## 验证和测试

### OpenAPI 规范验证
```bash
swagger-cli validate docs/api/4.5.1/modules/REQ-023-数据分析与商业智能模块/openapi.yaml
```

### Mock Server 启动
```bash
# 模块级 Mock Server
prism mock docs/api/4.5.1/modules/REQ-023-数据分析与商业智能模块/openapi.yaml

# 全局 Mock Server
prism mock docs/api/4.5.1/global-api-index.yaml
```

### 自动化验证脚本
```bash
./scripts/validate-req023-api.sh
```

## 集成说明

### 域文件集成
API 路径已集成到 `docs/api/4.5.1/domains/analytics-domain.yaml`，与现有 AI 功能共存。

### 全局 API 索引
所有路径已添加到 `docs/api/4.5.1/global-api-index.yaml`，支持统一的 API 访问。

### 引用路径示例
```yaml
/api/v1/analytics/tasks:
  $ref: '../modules/REQ-023-数据分析与商业智能模块/openapi.yaml#/paths/~1api~1v1~1analytics~1tasks'
```

## 业务价值

1. **数据驱动决策**: 提供多维度数据分析和智能洞察
2. **实时监控**: 支持实时数据流处理和监控大屏
3. **预测分析**: 基于机器学习的趋势预测和异常检测
4. **自动化报表**: 灵活的报表模板和自动化生成
5. **协作分析**: 支持团队协作的分析工作空间

## 版本信息

- **API 版本**: 1.0.0
- **OpenAPI 规范**: 3.0.3
- **创建日期**: 2024-08-15
- **最后更新**: 2024-08-15
