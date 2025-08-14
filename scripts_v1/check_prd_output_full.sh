#!/bin/bash
set -e

PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"

# 检测最新版本
LATEST_VERSION=$(ls -d $OUTPUT_BASE/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
OUTPUT_VERSION_DIR="$OUTPUT_BASE/$LATEST_VERSION"

echo "🔍 检查 PRD 输出版本: v$LATEST_VERSION"
MODULE_LIST_FILE="module_list.txt"

if [ ! -f "$MODULE_LIST_FILE" ]; then
    echo "❌ 缺少模块清单 ($MODULE_LIST_FILE)，请先运行生成脚本"
    exit 1
fi

ALL_REQ=$(grep -oE 'REQ-[0-9]{3,4}[A-Z]?' "$MODULE_LIST_FILE" | sort -u)

# ========== 1. 模块完整性检测 ==========
DOC_FILES=("backend-prd.md" "frontend-prd.md" "mobile-prd.md" "api-docs.md")
for file in "${DOC_FILES[@]}"; do
    path="$OUTPUT_VERSION_DIR/$file"
    echo "📄 检查模块覆盖率: $file"
    if [ ! -f "$path" ]; then
        echo "❌ 缺少文件: $file"
        exit 1
    fi
    DOC_REQ=$(grep -oE 'REQ-[0-9]{3,4}[A-Z]?' "$path" | sort -u)
    MISSING=$(comm -23 <(echo "$ALL_REQ") <(echo "$DOC_REQ") || true)
    if [ -n "$MISSING" ]; then
        echo "❌ $file 缺少模块:"
        echo "$MISSING"
        exit 1
    else
        echo "✅ $file 覆盖率 100%"
    fi
done

# ========== 2. API 一致性检测 ==========
API_DOC="$OUTPUT_VERSION_DIR/api-docs.md"
OPENAPI="$OUTPUT_VERSION_DIR/openapi.yaml"

echo "🔍 检查 api-docs 与 openapi.yaml 一致性..."
if [ ! -f "$API_DOC" ] || [ ! -f "$OPENAPI" ]; then
    echo "❌ 缺少 API 文档或 OpenAPI 文件"
    exit 1
fi

# 从 api-docs 提取 "方法 路径"
API_LIST_MD=$(grep -E '^### (GET|POST|PUT|DELETE) ' "$API_DOC" | sed 's/^### //' | sort -u)
# 从 openapi.yaml 提取 "方法 路径"
API_LIST_YAML=$(grep -E '^\s{2}(get|post|put|delete):' -B1 "$OPENAPI" | \
    grep -v '^\-\-' | sed 'N;s/\n/ /' | awk '{print toupper($2) " " $1}' | sort -u)

# 比对缺失
MISSING_IN_YAML=$(comm -23 <(echo "$API_LIST_MD") <(echo "$API_LIST_YAML") || true)
MISSING_IN_MD=$(comm -23 <(echo "$API_LIST_YAML") <(echo "$API_LIST_MD") || true)

if [ -n "$MISSING_IN_YAML" ]; then
    echo "❌ openapi.yaml 缺少以下 API（api-docs 有定义）:"
    echo "$MISSING_IN_YAML"
    exit 1
fi

if [ -n "$MISSING_IN_MD" ]; then
    echo "❌ api-docs.md 缺少以下 API（openapi.yaml 有定义）:"
    echo "$MISSING_IN_MD"
    exit 1
fi

echo "✅ api-docs.md 与 openapi.yaml API 列表一致"

# 检查 REQ-ID 一致性
REQ_MD=$(grep -oE 'REQ-[0-9]{3,4}[A-Z]?' "$API_DOC" | sort -u)
REQ_YAML=$(grep -oE 'REQ-[0-9]{3,4}[A-Z]?' "$OPENAPI" | sort -u)
REQ_DIFF=$(comm -3 <(echo "$REQ_MD") <(echo "$REQ_YAML") || true)
if [ -n "$REQ_DIFF" ]; then
    echo "❌ API 文档与 OpenAPI 的 REQ-ID 不一致:"
    echo "$REQ_DIFF"
    exit 1
else
    echo "✅ API 文档与 OpenAPI 的 REQ-ID 完全一致"
fi

# ========== 3. 前端/移动端引用 API 检查 ==========
for fe_file in "frontend-prd.md" "mobile-prd.md"; do
    fe_path="$OUTPUT_VERSION_DIR/$fe_file"
    echo "🔍 检查 $fe_file 引用 API 是否存在于 api-docs.md..."
    FE_APIS=$(grep -E '/api/v[0-9]+' "$fe_path" | sort -u)
    for api in $FE_APIS; do
        if ! grep -q "$api" "$API_DOC"; then
            echo "❌ $fe_file 引用了 api-docs.md 中未定义的 API: $api"
            exit 1
        fi
    done
done
echo "✅ 前端和移动端引用的 API 均在 API 文档中定义"

echo "🎯 检查完成：全部通过"
