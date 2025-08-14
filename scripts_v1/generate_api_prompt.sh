#!/bin/bash
set -e
PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"

LATEST_VERSION=$(ls -d "$PRD_BASE"/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
GLOBAL_FILE="$PRD_BASE/$LATEST_VERSION/global.md"
OUTPUT_DIR="$OUTPUT_BASE/$LATEST_VERSION"

[ ! -f "$GLOBAL_FILE" ] && { echo "❌ 先运行 scripts/extract_global.sh"; exit 1; }
mkdir -p "$OUTPUT_DIR"

STEP0=$(cat <<EOF
## Step 0：读取全局信息
- 全局信息文件路径: $GLOBAL_FILE
- 必须覆盖 PRD 所有 REQ-ID（P0、P1、P2），不得遗漏
- 即便模块暂未开发，也必须生成占位接口（标注“待实现”）
- 占位接口需要包含规范化的结构（见下方格式示例），以保证未来能无缝补全：
  - 路径: /api/v1/<placeholder>
  - 方法: GET
  - 描述: 占位接口 - 待实现
  - 请求参数: 无
  - 响应结构: 空对象 { }
  - Mock 示例: {}
- 不得因为开发优先级跳过任何模块
EOF
)

STEP1=$(cat <<'EOF'
## Step 1（api-docs.md + openapi.yaml）：
- 按模块分组列出全部 API（原文 + 推导补齐 + 占位接口）
- 每接口标注 REQ-ID
- API 说明：
  - 路径 / 方法
  - 覆盖需求 REQ-ID 列表
  - 适用平台
  - 权限要求
  - 请求参数
  - 响应结构
  - 错误码
  - Mock 示例
- 保持 api-docs.md 与 openapi.yaml 内容完全一致
EOF
)

STEP3="## Step 3：统一规范\n- 删除冗余\n- 首次缩写加全称\n- Markdown 格式统一\n- API / OpenAPI 字段命名一致\n- Mock 数据符合规范"
STEP4="## Step 4：输出文件清单\n所有文件必须保存到目录：$OUTPUT_DIR\n- api-docs.md\n- openapi.yaml"

PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$STEP1\n$STEP3\n$STEP4"

if command -v pbcopy &>/dev/null; then
    echo -e "$PROMPT" | pbcopy
    echo "✅ API Prompt 已复制到剪贴板"
else
    echo -e "$PROMPT"
fi
