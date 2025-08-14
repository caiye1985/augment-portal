#!/bin/bash
set -e
PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"

LATEST_VERSION=$(ls -d "$PRD_BASE"/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
GLOBAL_FILE="$PRD_BASE/$LATEST_VERSION/global.md"
OUTPUT_DIR="$OUTPUT_BASE/$LATEST_VERSION"

[ ! -f "$GLOBAL_FILE" ] && { echo "❌ 请先运行 scripts/extract_global.sh"; exit 1; }
[ ! -f "$OUTPUT_DIR/api-docs.md" ] || [ ! -f "$OUTPUT_DIR/openapi.yaml" ] \
  && { echo "❌ Mobile 依赖 API 文档，请先生成 API"; exit 1; }
mkdir -p "$OUTPUT_DIR"

STEP0=$(cat <<EOF
## Step 0：读取全局信息
- 全局信息文件路径: $GLOBAL_FILE
- 必须覆盖 PRD 全部 REQ-ID（P0、P1、P2）
- 即便模块暂无移动端需求，也必须生成占位说明（标注“待实现”），结构如下：
  - 功能概述: 占位说明
  - 界面结构与组件: 占位元素
  - 用户操作流程: 占位描述
  - API 对接方案: 引用占位 API
EOF
)

STEP1=$(cat <<'EOF'
## Step 1（mobile-prd.md，Flutter）：
- 覆盖所有模块
- Flutter 技术栈要求明确
- 每模块包含：
  - 功能概述
  - 界面结构与组件
  - 用户操作流程
  - API 对接方案（引用 api-docs.md）
EOF
)
STEP3="## Step 3：统一规范\n- 删除冗余\n- 缩写加全称\n- Markdown 一致\n- API 命名统一\n- Mock 数据规范"
STEP4="## Step 4：输出文件清单\n所有文件必须保存到目录：$OUTPUT_DIR\n- mobile-prd.md"

PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$STEP1\n$STEP3\n$STEP4"
if command -v pbcopy &>/dev/null; then
    echo -e "$PROMPT" | pbcopy
    echo "✅ API Prompt 已复制到剪贴板"
else
    echo -e "$PROMPT"
fi