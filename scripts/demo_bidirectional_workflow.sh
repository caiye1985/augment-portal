#!/usr/bin/env bash
# demo_bidirectional_workflow.sh
# 双向优化工作流程演示脚本

set -e

echo "=========================================="
echo "双向优化工作流程演示"
echo "=========================================="
echo ""

# 导入版本工具
source "$(dirname "$0")/version_utils.sh"

# 检测版本
VERSION=$(detect_prd_version)
echo "[i] 当前PRD版本: $VERSION"
echo ""

# 显示当前目录结构
echo "1. 当前版本化目录结构："
echo "   PRD文档: docs/prd/split/$VERSION/"
echo "   API文档: docs/api/$VERSION/"
echo "   Prompt文件: prompts/$VERSION/"
echo "   输出目录: docs/output/$VERSION/"
echo ""

# 演示传统单向流程
echo "2. 传统单向流程演示："
echo "   生成API设计prompt（仅API设计）"
echo "   命令: bash scripts/gen_iter_prompt.sh api P0"
echo ""

read -p "按回车键继续演示传统流程..." 

# 清理之前的状态
rm -f .gen_iter_state_phase_P0_api

# 生成传统API prompt（仅处理第一个模块作为演示）
echo "current_index=0" > .gen_iter_state_phase_P0_api
bash scripts/gen_iter_prompt.sh api P0 >/dev/null 2>&1 || true

echo "[√] 传统流程完成，生成了API设计prompt"
echo "   输出位置: prompts/$VERSION/api/api-iter-REQ-001.md"
echo ""

# 演示双向分析流程
echo "3. 双向分析流程演示："
echo "   同时生成API设计prompt和PRD分析prompt"
echo "   命令: ENABLE_PRD_ANALYSIS=true bash scripts/gen_iter_prompt.sh api P0"
echo ""

read -p "按回车键继续演示双向分析流程..."

# 清理之前的状态
rm -f .gen_iter_state_phase_P0_api

# 生成双向分析prompt（仅处理第一个模块作为演示）
echo "current_index=0" > .gen_iter_state_phase_P0_api
ENABLE_PRD_ANALYSIS=true bash scripts/gen_iter_prompt.sh api P0 >/dev/null 2>&1 || true

echo "[√] 双向分析流程完成"
echo "   API设计prompt: prompts/$VERSION/api/api-iter-REQ-001.md"
echo "   PRD分析prompt: prompts/$VERSION/api/prd-analysis-REQ-001.md"
echo ""

# 显示输出文件统计
echo "4. 输出文件统计："
api_count=$(find prompts/$VERSION/api -name "api-iter-*.md" | wc -l)
prd_count=$(find prompts/$VERSION/api -name "prd-analysis-*.md" | wc -l)
echo "   API设计prompt文件: $api_count 个"
echo "   PRD分析prompt文件: $prd_count 个"
echo ""

# 显示PRD分析prompt的内容预览
echo "5. PRD分析prompt内容预览："
echo "   文件: prompts/$VERSION/api/prd-analysis-REQ-001.md"
echo "   内容摘要:"
echo "   ├── 任务：PRD文档质量分析与改进建议"
echo "   ├── 分析维度：技术细节完整性、业务逻辑一致性、API设计支撑度、数据架构合理性"
echo "   ├── 分析输入：当前模块PRD、全局上下文、业务流程文档、技术栈规范"
echo "   └── 输出要求：分类改进建议（P0/P1/P2）、技术实现指导"
echo ""

# 显示工作流程建议
echo "6. 建议的工作流程："
echo "   第一步：生成双向分析prompt"
echo "   └── ENABLE_PRD_ANALYSIS=true bash scripts/gen_iter_prompt.sh api P0"
echo ""
echo "   第二步：使用AI处理prompt文件"
echo "   ├── 处理API设计prompt → 生成OpenAPI规范"
echo "   └── 处理PRD分析prompt → 生成PRD改进建议"
echo ""
echo "   第三步：人工审核和PRD优化"
echo "   ├── 审核PRD改进建议的价值"
echo "   ├── 根据建议更新PRD文档"
echo "   └── 创建PRD新版本（如4.5.1）"
echo ""
echo "   第四步：基于改进后的PRD重新生成API"
echo "   └── 使用新版本PRD重新生成API设计"
echo ""

# 显示质量控制要点
echo "7. 质量控制要点："
echo "   ✓ 分离式设计：API设计和PRD分析使用不同prompt"
echo "   ✓ 可选功能：默认关闭，按需启用"
echo "   ✓ 版本化管理：所有输出都版本化存储"
echo "   ✓ 优先级分类：P0/P1/P2三级优先级"
echo "   ✓ 人工审核：AI建议需要人工评估"
echo ""

# 显示风险控制措施
echo "8. 风险控制措施："
echo "   ✓ 不影响现有流程：传统模式仍然可用"
echo "   ✓ 渐进式实施：可以先在小范围测试"
echo "   ✓ 版本回滚：保留所有历史版本"
echo "   ✓ 质量保证：专门的分析模板和标准"
echo ""

# 显示下一步建议
echo "9. 下一步建议："
echo "   1. 选择1-2个核心模块进行双向分析测试"
echo "   2. 使用AI处理生成的prompt文件"
echo "   3. 评估PRD改进建议的质量和价值"
echo "   4. 根据测试结果调整分析模板"
echo "   5. 逐步扩展到更多模块"
echo ""

echo "=========================================="
echo "演示完成！"
echo ""
echo "要启用双向分析，请使用："
echo "ENABLE_PRD_ANALYSIS=true bash scripts/gen_iter_prompt.sh api P0"
echo ""
echo "更多信息请参考："
echo "- docs/bidirectional-workflow-guide.md"
echo "- docs/versioned-structure-guide.md"
echo "=========================================="
