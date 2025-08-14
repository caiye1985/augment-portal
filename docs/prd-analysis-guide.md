# PRD文档质量分析使用指南

## 概述

PRD文档质量分析是一个独立的工具，专门用于对所有PRD文档进行系统性的质量检查和改进建议生成。通过AI深度分析PRD文档的完整性、一致性和技术可行性，为技术实施团队提供具体的优化指导。

## 核心特性

### 1. 独立工具设计
- **专门脚本**：`scripts/gen_prd_analysis.sh`
- **简化复杂度**：不依赖其他prompt生成脚本
- **专注功能**：专门用于PRD质量分析

### 2. 全面覆盖分析
- **所有模块**：支持对所有21个PRD模块进行分析
- **分阶段处理**：支持按P0/P1/P2阶段分别处理
- **版本化管理**：与现有版本化结构完全集成

### 3. 智能分析维度
- **技术细节完整性**：数据模型、接口流程、性能要求、安全策略
- **业务逻辑一致性**：跨模块交互、状态流转、异常处理、权限控制
- **API设计支撑度**：CRUD覆盖、查询需求、批量操作、实时性要求
- **数据架构合理性**：实体关系、完整性约束、索引优化、分库分表

## 使用方法

### 基本命令

```bash
# 查看帮助信息
bash scripts/gen_prd_analysis.sh

# 生成所有PRD分析prompt（推荐）
bash scripts/gen_prd_analysis.sh all

# 生成指定阶段的PRD分析prompt
bash scripts/gen_prd_analysis.sh generate P0
bash scripts/gen_prd_analysis.sh generate P1
bash scripts/gen_prd_analysis.sh generate P2

# 查看当前进度
bash scripts/gen_prd_analysis.sh progress

# 清理进度，重新开始
bash scripts/gen_prd_analysis.sh clean-all
```

### 推荐工作流程

#### 1. 一次性生成所有分析prompt
```bash
# 生成所有21个模块的PRD分析prompt
bash scripts/gen_prd_analysis.sh all
```

#### 2. 分阶段处理（可选）
```bash
# 先处理核心模块
bash scripts/gen_prd_analysis.sh generate P0

# 再处理重要模块
bash scripts/gen_prd_analysis.sh generate P1

# 最后处理增强模块
bash scripts/gen_prd_analysis.sh generate P2
```

## 输出结构

### 1. Prompt文件位置
```
prompts/4.5/prd-analysis/
├── prd-analysis-REQ-001.md    # 基础架构模块分析
├── prd-analysis-REQ-003.md    # 工单管理系统分析
├── prd-analysis-REQ-004.md    # 知识库管理分析
├── ...
└── prd-analysis-REQ-023.md    # 移动端应用分析
```

### 2. 分析结果位置（AI处理后）
```
docs/output/4.5/prd-improvements/
├── REQ-001-prd-analysis.md    # 基础架构模块改进建议
├── REQ-003-prd-analysis.md    # 工单管理系统改进建议
├── ...
└── REQ-023-prd-analysis.md    # 移动端应用改进建议
```

## 分析内容详解

### 1. 分析输入
每个PRD分析prompt包含以下输入：
- **当前模块PRD**：`docs/prd/split/4.5/modules/REQ-XXX.md`
- **全局上下文**：`docs/global-context.md`
- **业务流程文档**：`docs/prd/split/4.5/globals/04-business-processes.md`
- **技术栈规范**：`docs/prd/split/4.5/appendix/03-technology-stack.md`

### 2. 分析维度
#### 技术细节完整性
- 数据模型定义的完整性
- 接口交互流程的技术可行性
- 性能要求的明确性和可测量性
- 安全要求的具体性和可实施性

#### 业务逻辑一致性
- 跨模块交互的依赖关系和数据流
- 业务状态变化的逻辑完整性
- 异常情况的覆盖度
- 权限模型的一致性

#### API设计支撑度
- 基础CRUD操作的完整性
- 查询条件和排序要求的明确性
- 批量处理业务场景的识别
- 实时数据更新需求的评估

#### 数据架构合理性
- 实体关系模型的合理性
- 业务规则在数据层的体现
- 基于查询模式的索引建议
- 大数据量场景的设计考虑

### 3. 输出格式
```markdown
# REQ-XXX PRD质量分析报告

## 分析概要
- 分析时间、PRD版本、分析模块

## 关键发现
### P0级问题（关键缺失）
### P1级问题（重要补充）
### P2级问题（优化建议）

## 详细分析
### 1. 技术细节完整性
### 2. 业务逻辑一致性
### 3. API设计支撑度
### 4. 数据架构合理性

## 改进建议
### 立即处理（P0）
### 近期优化（P1）
### 长期改进（P2）

## 技术实现指导
```

## 进度管理

### 1. 自动进度保存
脚本会自动保存每个阶段的处理进度：
```
.gen_prd_analysis_state_P0    # P0阶段进度
.gen_prd_analysis_state_P1    # P1阶段进度
.gen_prd_analysis_state_P2    # P2阶段进度
```

### 2. 中断和恢复
```bash
# 如果生成过程被中断，再次运行会从上次停止的地方继续
bash scripts/gen_prd_analysis.sh generate P1

# 查看当前进度
bash scripts/gen_prd_analysis.sh progress
```

### 3. 重新开始
```bash
# 清理所有进度，重新开始
bash scripts/gen_prd_analysis.sh clean-all

# 清理特定阶段的进度
bash scripts/gen_prd_analysis.sh clean P0
```

## 质量控制

### 1. 分析标准
- **客观性**：基于技术标准和最佳实践进行分析
- **具体性**：提供可操作的具体建议，避免泛泛而谈
- **优先级**：明确区分问题的严重程度和处理优先级
- **可行性**：确保建议在当前技术栈下可实现

### 2. 优先级分类
- **P0-关键缺失**：影响核心功能实现的关键信息缺失
- **P1-重要补充**：提升实现质量的重要细节补充
- **P2-优化建议**：改善用户体验和系统性能的建议

### 3. 人工审核流程
1. **自动分析**：AI生成PRD改进建议
2. **技术审核**：技术负责人评估建议价值
3. **业务审核**：产品负责人评估业务影响
4. **优先级排序**：确定改进实施顺序
5. **PRD更新**：根据审核结果更新PRD

## 最佳实践

### 1. 分析策略
```bash
# 推荐：一次性生成所有分析
bash scripts/gen_prd_analysis.sh all

# 或者按优先级分批处理
bash scripts/gen_prd_analysis.sh generate P0  # 核心功能优先
bash scripts/gen_prd_analysis.sh generate P1  # 重要功能其次
bash scripts/gen_prd_analysis.sh generate P2  # 增强功能最后
```

### 2. 处理建议
1. **快速扫描**：先查看所有P0级问题
2. **详细评估**：评估P1级问题的价值和实施成本
3. **长期规划**：将P2级问题纳入长期改进计划
4. **分批实施**：避免一次性修改过多内容

### 3. 版本管理
- **小步迭代**：每次只处理少量高优先级问题
- **版本标记**：清晰标记每个版本的改进内容
- **影响评估**：评估PRD修改对API设计的影响

## 与其他工具的集成

### 1. 与API设计的关系
```bash
# 先生成PRD分析
bash scripts/gen_prd_analysis.sh all

# 基于分析结果改进PRD后，再生成API设计
bash scripts/gen_iter_prompt.sh api P0
```

### 2. 版本化管理
- **PRD分析结果**：`docs/output/4.5/prd-improvements/`
- **API设计prompt**：`prompts/4.5/api/`
- **版本追踪**：支持PRD版本迭代（4.5 → 4.5.1 → 4.5.2）

## 故障排除

### 常见问题

1. **模块列表文件不存在**
   ```bash
   # 重新生成模块列表
   bash scripts/gen_module_list.sh
   ```

2. **版本检测失败**
   ```bash
   # 检查PRD目录结构
   ls -la docs/prd/split/
   ```

3. **进度文件损坏**
   ```bash
   # 清理进度文件
   bash scripts/gen_prd_analysis.sh clean-all
   ```

### 调试命令
```bash
# 查看版本信息
bash scripts/version_utils.sh detect

# 查看当前进度
bash scripts/gen_prd_analysis.sh progress

# 检查输出目录
ls -la prompts/4.5/prd-analysis/
```

## 总结

独立的PRD分析工具提供了：

- ✅ **简化的复杂度**：专门的脚本，不影响其他功能
- ✅ **全面的覆盖**：支持所有21个PRD模块的分析
- ✅ **智能的分析**：四个维度的深度质量分析
- ✅ **标准化的输出**：P0/P1/P2三级优先级分类
- ✅ **完善的管理**：进度保存、中断恢复、版本化存储

通过这个工具，可以系统性地提升PRD文档的质量，为后续的API设计和系统实现奠定坚实的基础。
