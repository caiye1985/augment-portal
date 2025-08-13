#!/bin/bash
set -e

OUTPUT_BASE="docs/output"
LATEST_VERSION=$(ls -d $OUTPUT_BASE/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
OUTPUT_DIR="$OUTPUT_BASE/$LATEST_VERSION"

echo "📂 检查 PRD 输出版本: v$LATEST_VERSION"
echo "📁 输出目录: $OUTPUT_DIR"

# ===== 1. 文件完整性检查 =====
REQUIRED_FILES=(
  backend-prd.md frontend-prd.md mobile-prd.md
  api-docs.md openapi.yaml
  execution-plan.md
  handoff-diagram.mmd README.md
)

echo "🔍 检查必须文件..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$OUTPUT_DIR/$file" ]; then
        echo "❌ 缺失文件: $file"
        exit 1
    fi
done
echo "✅ 基础文件完整"

# ===== 2. OpenAPI 验证 =====
echo "🔍 校验 OpenAPI 规范..."
if ! command -v swagger-cli &>/dev/null; then
    echo "⚠️ 未安装 swagger-cli，正在自动安装..."
    npm install -g @apidevtools/swagger-cli
fi
swagger-cli validate "$OUTPUT_DIR/openapi.yaml"
echo "✅ OpenAPI 文件通过验证"

# ===== 3. 提取 REQ-ID 列表 =====
echo "🔍 提取 PRD 中的 REQ-ID..."
REQ_FILE_LIST=(
  "$OUTPUT_DIR/backend-prd.md"
  "$OUTPUT_DIR/frontend-prd.md"
  "$OUTPUT_DIR/mobile-prd.md"
)
TOTAL_REQ_IDS=$(grep -hoE 'REQ-[0-9]{3,4}[A-Z]?' "${REQ_FILE_LIST[@]}" | sort -u)
TOTAL_REQ_COUNT=$(echo "$TOTAL_REQ_IDS" | wc -l)

if [ "$TOTAL_REQ_COUNT" -eq 0 ]; then
    echo "⚠️ PRD 中未找到任何 REQ-ID，无法验证覆盖率"
    exit 1
fi
echo "📋 检测到 $TOTAL_REQ_COUNT 个唯一 REQ-ID"

# 检查 API 文档中平台标注
grep -E "Flutter|小程序" "$OUTPUT_DIR/api-docs.md" >/dev/null || {
  echo "❌ API 文档缺少平台标识"
  exit 1
}

# ===== 4. 提取 API 文档中的 REQ-ID =====
echo "🔍 提取 API 文档中的 REQ-ID..."
API_REQ_IDS=$(grep -hoE 'REQ-[0-9]{3,4}[A-Z]?' "$OUTPUT_DIR/api-docs.md" "$OUTPUT_DIR/openapi.yaml" | sort -u)
API_REQ_COUNT=$(echo "$API_REQ_IDS" | wc -l)

# ===== 5. 计算覆盖率并找出缺失 =====
COVERAGE_PERCENT=$(( 100 * API_REQ_COUNT / TOTAL_REQ_COUNT ))
echo "📊 API 需求覆盖率: $API_REQ_COUNT / $TOTAL_REQ_COUNT (${COVERAGE_PERCENT}%)"

MISSING_REQ_IDS=()
for req in $TOTAL_REQ_IDS; do
    if ! echo "$API_REQ_IDS" | grep -q "$req"; then
        MISSING_REQ_IDS+=("$req")
    fi
done

if [ "${#MISSING_REQ_IDS[@]}" -ne 0 ]; then
    echo "⚠️ 以下 REQ-ID 在 API 文档中未找到覆盖:"
    for miss in "${MISSING_REQ_IDS[@]}"; do
        echo "   - $miss"
    done
    echo "❌ 覆盖率不足，请补充缺失 API（当前覆盖率: ${COVERAGE_PERCENT}%）"
    exit 1
else
    echo "✅ API 覆盖率 100%，所有需求都有对应接口"
fi

echo "🎯 文档完整性与 API 覆盖率检查通过"
