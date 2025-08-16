# PRD生成系统使用指南

## 文档信息
- **版本**：1.0.0
- **创建日期**：2025-08-16
- **文档类型**：使用指南
- **适用对象**：产品经理、技术负责人、AI开发助手用户

## 1. 系统概述

### 1.1 系统功能
PRD生成系统是为IT运维门户系统设计的自动化PRD生成工具，能够将API文档和需求文档转换为适合AI开发助手使用的高密度PRD文档。

### 1.2 核心特性
- **模块化生成**：支持按模块生成PRD，包括前后端和移动端
- **质量控制**：内置质量检查机制，确保PRD质量
- **AI友好**：专门优化的格式，便于AI开发助手理解和使用
- **批量处理**：支持批量生成所有模块的PRD

### 1.3 技术架构
```
输入文档 → 模板引擎 → PRD生成 → 质量检查 → 输出PRD
    ↓           ↓          ↓          ↓          ↓
API文档     prompt模板   生成脚本   质量验证    高质量PRD
需求文档    变量替换     envsubst   自动检查    AI可用
```

## 2. 快速开始

### 2.1 环境准备
确保系统已安装以下工具：
- Bash 3.2+
- envsubst（通常包含在gettext包中）
- 基本的Unix工具（grep、sed、awk等）

### 2.2 目录结构
```
augment-portal/
├── docs/
│   ├── api/4.5.1/              # API文档
│   ├── prd/split/4.5.1/        # 需求文档
│   └── global-context.md       # 全局上下文
├── scripts/                    # 生成脚本
│   ├── gen_iter_prompt.sh      # 主生成脚本
│   ├── gen_prd_complete.sh     # 完整生成脚本
│   └── simple_prd_quality_check.sh  # 质量检查脚本
├── prompt-templates/           # 模板文件
│   ├── prd-generation.md       # 通用PRD模板
│   ├── prd-mobile.md          # 移动端PRD模板
│   └── prd-quality-check.md   # 质量检查模板
└── prompts/4.5.1/             # 生成的prompt文件
```

### 2.3 第一次使用
```bash
# 1. 生成单个模块的PRD prompt
bash scripts/gen_iter_prompt.sh prd P0

# 2. 检查生成的prompt文件
ls prompts/4.5.1/api/prd-generation-*.md

# 3. 使用prompt生成PRD文档（手动或通过AI）
# 将prompt内容提供给AI开发助手

# 4. 验证生成的PRD质量
bash scripts/simple_prd_quality_check.sh docs/output/prd/4.5.1/your-prd.md
```

## 3. 详细使用说明

### 3.1 生成PRD Prompt

#### 基本语法
```bash
bash scripts/gen_iter_prompt.sh <模式> <阶段>
```

#### 模式说明
- **prd**：生成通用PRD模板（适用于前后端模块）
- **prd-mobile**：生成移动端PRD模板（仅适用于REQ-020）
- **prd-quality**：生成PRD质量检查模板

#### 阶段说明
- **P0**：核心模块（7个模块）
- **P1**：重要模块（7个模块）
- **P2**：扩展模块（8个模块）
- **all**：所有阶段

#### 使用示例
```bash
# 生成P0阶段所有模块的PRD prompt
bash scripts/gen_iter_prompt.sh prd P0

# 生成移动端模块的PRD prompt
bash scripts/gen_iter_prompt.sh prd-mobile P2

# 生成所有阶段的PRD prompt
bash scripts/gen_iter_prompt.sh prd all
```

### 3.2 批量生成PRD

#### 使用完整生成脚本
```bash
# 生成所有模块的PRD prompt
bash scripts/gen_prd_complete.sh

# 查看帮助信息
bash scripts/gen_prd_complete.sh --help
```

#### 输出目录结构
```
docs/output/prd/4.5.1/
├── modules/                    # 模块PRD目录
├── mobile/                     # 移动端PRD目录
├── quality/                    # 质量报告目录
└── generation-summary.md       # 生成汇总报告
```

### 3.3 质量检查

#### 单个文件检查
```bash
bash scripts/simple_prd_quality_check.sh path/to/prd-file.md
```

#### 批量质量检查
```bash
# 检查所有PRD文件
bash scripts/validate_prd_quality.sh

# 检查指定目录下的PRD文件
find docs/output/prd/4.5.1 -name "*.md" -exec bash scripts/simple_prd_quality_check.sh {} \;
```

## 4. 模板定制

### 4.1 模板结构
PRD模板使用envsubst进行变量替换，支持以下变量：
- `$VERSION`：版本号（如4.5.1）
- `$MODULE_ID`：模块编号（如REQ-003）
- `$MODULE_NAME`：模块名称（如工单管理系统）
- `$MODULE_FILE`：模块PRD文件路径
- `$API_MODULE_FILE`：模块API文档路径
- `$GLOBAL_FILE`：全局上下文文件路径

### 4.2 自定义模板
1. **复制现有模板**：
   ```bash
   cp prompt-templates/prd-generation.md prompt-templates/my-custom-prd.md
   ```

2. **修改模板内容**：
   - 调整章节结构
   - 修改内容要求
   - 添加特定的技术要求

3. **更新生成脚本**：
   在`scripts/gen_iter_prompt.sh`中添加新的模式：
   ```bash
   my-custom) template_file="prompt-templates/my-custom-prd.md" ;;
   ```

### 4.3 模板最佳实践
- **明确的指导**：提供具体的内容要求和示例
- **结构化格式**：使用标准的Markdown格式
- **变量使用**：合理使用环境变量，避免硬编码
- **质量要求**：明确质量标准和验收条件

## 5. 常见问题

### 5.1 生成问题

**Q: 生成的prompt文件为空或不完整**
A: 检查以下几点：
- 确保所有输入文档存在且可读
- 检查环境变量是否正确设置
- 验证模板文件格式是否正确

**Q: 移动端模块没有生成prompt**
A: 确保使用正确的模式和阶段：
```bash
bash scripts/gen_iter_prompt.sh prd-mobile P2
```

### 5.2 质量问题

**Q: 质量检查评分过低**
A: 常见原因和解决方案：
- **内容不足**：增加详细的技术描述和示例
- **结构不完整**：确保包含所有必需的章节
- **技术关键词缺失**：补充相关的技术栈信息

**Q: 移动端PRD质量评分异常**
A: 移动端PRD使用不同的评估标准，关注以下方面：
- Flutter技术栈的完整性
- 移动端特有功能的描述
- 原生功能集成的详细程度

### 5.3 使用问题

**Q: 如何为新模块添加PRD生成支持**
A: 按以下步骤操作：
1. 在相应的模块列表文件中添加模块信息
2. 确保模块的PRD和API文档存在
3. 运行生成脚本测试

**Q: 如何自定义质量检查标准**
A: 修改`scripts/simple_prd_quality_check.sh`中的检查逻辑：
- 调整评分权重
- 修改检查项目
- 添加特定的验证规则

## 6. 高级功能

### 6.1 进度管理
生成脚本支持中断和恢复功能：
- 进度文件：`.gen_iter_state_phase_{阶段}_{模式}`
- 清除进度：`rm -f .gen_iter_state_*`
- 查看进度：检查进度文件内容

### 6.2 并行生成
对于大量模块，可以并行生成：
```bash
# 并行生成不同阶段
bash scripts/gen_iter_prompt.sh prd P0 &
bash scripts/gen_iter_prompt.sh prd P1 &
bash scripts/gen_iter_prompt.sh prd P2 &
wait
```

### 6.3 集成CI/CD
将PRD生成集成到CI/CD流程：
```yaml
# GitHub Actions示例
- name: Generate PRD
  run: |
    bash scripts/gen_prd_complete.sh
    bash scripts/validate_prd_quality.sh
```

## 7. 最佳实践

### 7.1 使用建议
1. **定期更新**：随着需求变化定期重新生成PRD
2. **质量优先**：确保PRD质量达到85分以上再使用
3. **版本管理**：为不同版本的PRD建立版本控制
4. **反馈收集**：收集AI使用反馈，持续改进模板

### 7.2 团队协作
1. **角色分工**：
   - 产品经理：维护需求文档
   - 技术负责人：维护API文档和模板
   - 开发工程师：使用PRD进行开发

2. **流程规范**：
   - PRD生成前确保输入文档最新
   - 质量检查通过后才能使用
   - 定期评估和优化模板

### 7.3 质量保证
1. **多级检查**：自动化检查 + 人工审核 + AI验证
2. **持续改进**：基于使用反馈不断优化
3. **标准化**：建立统一的质量标准和流程

## 8. 技术支持

### 8.1 故障排除
遇到问题时的排查步骤：
1. 检查错误日志和输出信息
2. 验证输入文档的完整性
3. 确认脚本权限和环境配置
4. 查看相关的GitHub Issues

### 8.2 联系方式
- **技术问题**：提交GitHub Issue
- **使用建议**：通过团队沟通渠道反馈
- **紧急问题**：联系技术负责人

### 8.3 更新说明
- **版本发布**：关注项目版本更新
- **功能增强**：定期查看更新日志
- **兼容性**：注意版本兼容性要求
