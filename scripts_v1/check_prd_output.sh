#!/bin/bash
set -e

# ====== 1. 找出最新版本 ======
OUTPUT_BASE="docs/output"
LATEST_VERSION=$(ls -d $OUTPUT_BASE/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
OUTPUT_DIR="$OUTPUT_BASE/$LATEST_VERSION"

echo "📂 检查版本: v$LATEST_VERSION"
echo "📁 输出目录: $OUTPUT_DIR"

# ====== 2. 检查必须文件 ======
REQUIRED_FILES=(
  backend-prd.md frontend-prd.md mobile-prd.md
  api-docs.md openapi.yaml execution-plan.md
  handoff-diagram.mmd README.md
)

echo "🔍 文件完整性检查..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$OUTPUT_DIR/$file" ]; then
        echo "❌ 缺失文件: $file"
        exit 1
    fi
done
echo "✅ 文件完整"

# ====== 3. OpenAPI 规范验证 ======
echo "🔍 OpenAPI 规范验证..."
if ! command -v swagger-cli &>/dev/null; then
    echo "⚠️ 未安装 swagger-cli，正在安装..."
    npm install -g @apidevtools/swagger-cli
fi

swagger-cli validate "$OUTPUT_DIR/openapi.yaml"
echo "✅ OpenAPI 文件通过校验"

# ====== 4. 提取需求 REQ-ID 列表 ======
echo "🔍 提取 PRD 中的 REQ-ID..."
REQ_FILE_LIST=("$OUTPUT_DIR/backend-prd.md" "$OUTPUT_DIR/frontend-prd.md" "$OUTPUT_DIR/mobile-prd.md")
REQ_IDS=$(grep -hoE 'REQ-[0-9]{3,4}[A-Z]?' "${REQ_FILE_LIST[@]}" | sort -u)

REQ_COUNT=$(echo "$REQ_IDS" | wc -l)
echo "📋 检测到 $REQ_COUNT 个 REQ-ID"

# ====== 5. 检查 API 覆盖 ======
echo "🔍 检查 API 覆盖..."
UNCOVERED=()

for req in $REQ_IDS; do
    # 搜索 API 文档和 OpenAPI 文件
    if ! grep -q "$req" "$OUTPUT_DIR/api-docs.md" && ! grep -q "$req" "$OUTPUT_DIR/openapi.yaml"; then
        UNCOVERED+=("$req")
    fi
done

if [ ${#UNCOVERED[@]} -ne 0 ]; then
    echo "⚠️ 以下 REQ-ID 在 API 文档中未找到覆盖:"
    for req in "${UNCOVERED[@]}"; do
        echo "   - $req"
    done
    echo "❌ API 覆盖不完整，需补充"
    exit 1
else
    echo "✅ 所有 REQ-ID 在 API 文档中都有覆盖"
fi

echo "🎯 文档完整性与 API 覆盖检查通过"
