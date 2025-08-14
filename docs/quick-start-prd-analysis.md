# PRD文档改进快速开始指南

## 5分钟快速上手

### 1. 生成所有PRD改进prompt
```bash
# 一键生成所有21个模块的PRD改进prompt
bash scripts/gen_prd_analysis.sh all
```

**输出**：
- 21个PRD改进prompt文件，位于 `prompts/4.5/prd-analysis/`
- 自动创建新版本目录 `docs/prd/split/4.5.1/modules/`

### 2. 查看生成结果
```bash
# 查看生成的文件
ls prompts/4.5/prd-analysis/

# 查看某个具体的改进prompt
cat prompts/4.5/prd-analysis/prd-analysis-REQ-001.md
```

### 3. 使用AI处理prompt文件
选择任意一个prompt文件，使用AI工具（如Claude、GPT等）处理：

1. 复制prompt文件内容
2. 粘贴到AI工具中
3. 获得完整的改进后PRD文档（版本4.5.1）
4. 保存结果到 `docs/prd/split/4.5.1/modules/REQ-XXX.md`

## 常用命令

```bash
# 查看帮助
bash scripts/gen_prd_analysis.sh

# 生成所有分析（推荐）
bash scripts/gen_prd_analysis.sh all

# 分阶段生成
bash scripts/gen_prd_analysis.sh generate P0  # 核心模块
bash scripts/gen_prd_analysis.sh generate P1  # 重要模块
bash scripts/gen_prd_analysis.sh generate P2  # 增强模块

# 查看进度
bash scripts/gen_prd_analysis.sh progress

# 重新开始
bash scripts/gen_prd_analysis.sh clean-all
```

## 输出文件说明

### Prompt文件（AI输入）
```
prompts/4.5/prd-analysis/
├── prd-analysis-REQ-001.md    # 基础架构模块分析prompt
├── prd-analysis-REQ-003.md    # 工单管理系统分析prompt
├── prd-analysis-REQ-004.md    # 知识库管理分析prompt
└── ...                        # 其他18个模块
```

### 改进后PRD文档（AI输出）
```
docs/prd/split/4.5.1/modules/
├── REQ-001.md                 # 改进后的基础架构模块PRD
├── REQ-003.md                 # 改进后的工单管理系统PRD
├── REQ-004.md                 # 改进后的知识库管理PRD
└── ...                        # 其他18个模块的改进PRD
```

## 改进内容概览

每个PRD改进包含：

### 改进维度
- **技术细节完整性**：补充数据模型、接口流程、性能要求
- **业务逻辑一致性**：优化跨模块交互、状态流转、异常处理
- **API设计支撑度**：完善CRUD覆盖、查询需求、批量操作
- **数据架构合理性**：优化实体关系、完整性约束、索引策略

### 版本升级特性
- **自动版本升级**：4.5 → 4.5.1
- **直接可用**：生成完整的PRD文档，无需二次处理
- **结构一致**：保持与原PRD的结构一致性

## 最佳实践

### 1. 推荐处理顺序
```bash
# 1. 生成所有分析prompt
bash scripts/gen_prd_analysis.sh all

# 2. 优先处理核心模块（P0阶段）
# 使用AI处理：prompts/4.5/prd-analysis/prd-analysis-REQ-001.md
# 使用AI处理：prompts/4.5/prd-analysis/prd-analysis-REQ-003.md
# 使用AI处理：prompts/4.5/prd-analysis/prd-analysis-REQ-004.md
# 使用AI处理：prompts/4.5/prd-analysis/prd-analysis-REQ-006A.md
# 使用AI处理：prompts/4.5/prd-analysis/prd-analysis-REQ-010.md
# 使用AI处理：prompts/4.5/prd-analysis/prd-analysis-REQ-022.md

# 3. 再处理重要模块（P1阶段）
# 4. 最后处理增强模块（P2阶段）
```

### 2. 结果处理建议
1. **快速扫描**：先查看所有P0级问题
2. **详细评估**：评估P1级问题的价值
3. **长期规划**：将P2级问题纳入长期计划
4. **分批实施**：避免一次性修改过多

## 故障排除

### 常见问题
```bash
# 问题：模块列表文件不存在
# 解决：重新生成模块列表
bash scripts/gen_module_list.sh

# 问题：版本检测失败
# 解决：检查PRD目录结构
ls -la docs/prd/split/

# 问题：进度文件损坏
# 解决：清理进度文件
bash scripts/gen_prd_analysis.sh clean-all
```

## 与API设计的配合

```bash
# 1. 先进行PRD分析
bash scripts/gen_prd_analysis.sh all

# 2. 根据分析结果改进PRD文档
# （人工审核和修改PRD）

# 3. 基于改进后的PRD生成API设计
bash scripts/gen_iter_prompt.sh api P0
```

## 总结

PRD质量分析工具帮助您：
- ✅ 系统性检查所有21个PRD模块
- ✅ 识别技术实施中的潜在问题
- ✅ 提供具体的改进建议和优先级
- ✅ 为高质量的API设计奠定基础

立即开始：`bash scripts/gen_prd_analysis.sh all`
