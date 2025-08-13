#!/bin/bash
set -e
PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"

LATEST_VERSION=$(ls -d "$PRD_BASE"/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
GLOBAL_FILE="$PRD_BASE/$LATEST_VERSION/global.md"
OUTPUT_DIR="$OUTPUT_BASE/$LATEST_VERSION"

[ ! -f "$GLOBAL_FILE" ] && { echo "❌ 先运行 scripts/extract_global.sh"; exit 1; }
[ ! -f "$OUTPUT_DIR/api-docs.md" ] || [ ! -f "$OUTPUT_DIR/openapi.yaml" ] && { echo "❌ Backend 依赖 API 文档，请先生成 API"; exit 1; }
mkdir -p "$OUTPUT_DIR"

STEP0=$(cat <<EOF
## Step 0：读取全局信息
- 全局信息文件路径: $GLOBAL_FILE
- 必须覆盖 PRD 全部模块
EOF
)
STEP1=$(cat <<'EOF'
## Step 1（backend-prd.md）：
- 覆盖所有模块，即便无后端交付项也要列出
- 每模块包含：
  - 功能概述
  - 核心功能
  - 实现要点（技术方案、架构、数据流、安全、性能）
  - 依赖与接口（引用 api-docs.md 中 API）
EOF
)
STEP2="## Step 2：生成交接图（Mermaid）\n- 输出 handoff-diagram.mmd"
STEP3="## Step 3：统一规范\n- 删除冗余\n- 缩写加全称\n- Markdown 一致\n- API 命名统一\n- Mock 数据规范"
STEP4="## Step 4：输出文件清单\n所有文件必须保存到目录：$OUTPUT_DIR\n- backend-prd.md\n- handoff-diagram.mmd"

PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$STEP1\n$STEP2\n$STEP3\n$STEP4"

if command -v pbcopy &>/dev/null; then
    echo -e "$PROMPT" | pbcopy
    echo "✅ API Prompt 已复制到剪贴板"
else
    echo -e "$PROMPT"
fi
