#!/bin/bash
set -e

PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"

LATEST_VERSION=$(ls -d "$PRD_BASE"/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
SRC_DIR="$PRD_BASE/$LATEST_VERSION"
OUT_DIR="$OUTPUT_BASE/$LATEST_VERSION"

mkdir -p "$OUT_DIR"

echo "📄 从 $SRC_DIR 生成四类文档骨架到 $OUT_DIR"

API_MD="$OUT_DIR/api-docs.md"
OPENAPI_YAML="$OUT_DIR/openapi.yaml"
BACKEND_MD="$OUT_DIR/backend-prd.md"
FRONTEND_MD="$OUT_DIR/frontend-prd.md"
MOBILE_MD="$OUT_DIR/mobile-prd.md"

# 开始写API文档头
echo "# API 文档 (版本: $LATEST_VERSION)" > "$API_MD"
echo "openapi: 3.0.3" > "$OPENAPI_YAML"
echo "info:" >> "$OPENAPI_YAML"
echo "  title: API Docs" >> "$OPENAPI_YAML"
echo "  version: \"$LATEST_VERSION\"" >> "$OPENAPI_YAML"
echo "paths:" >> "$OPENAPI_YAML"

# 初始化三端 PRD
echo "# Backend PRD (版本: $LATEST_VERSION)" > "$BACKEND_MD"
echo "# Frontend PRD (版本: $LATEST_VERSION)" > "$FRONTEND_MD"
echo "# Mobile PRD (版本: $LATEST_VERSION)" > "$MOBILE_MD"

# 遍历需求模块
for f in $(ls "$SRC_DIR/modules" | sort); do
  MOD_NAME="${f%.md}"
  MOD_FILE="$SRC_DIR/modules/$f"

  echo "  > 处理 $MOD_NAME"

  ## API文档 Markdown
  echo "" >> "$API_MD"
  echo "## $MOD_NAME" >> "$API_MD"
  echo "### 占位接口-1" >> "$API_MD"
  echo "- 方法 + 路径: [TODO]" >> "$API_MD"
  echo "- 权限: [TODO]" >> "$API_MD"
  echo "- 请求参数示例:" >> "$API_MD"
  echo "  \`\`\`json" >> "$API_MD"
  echo "  {}" >> "$API_MD"
  echo "  \`\`\`" >> "$API_MD"
  echo "- 响应示例:" >> "$API_MD"
  echo "  \`\`\`json" >> "$API_MD"
  echo "  {}" >> "$API_MD"
  echo "  \`\`\`" >> "$API_MD"

  ## API文档 OpenAPI
  API_PATH="/todo-path-for-${MOD_NAME}"
  echo "  $API_PATH:" >> "$OPENAPI_YAML"
  echo "    get:" >> "$OPENAPI_YAML"
  echo "      summary: 占位接口" >> "$OPENAPI_YAML"
  echo "      description: TODO - 来自 $MOD_NAME" >> "$OPENAPI_YAML"
  echo "      responses:" >> "$OPENAPI_YAML"
  echo "        '200':" >> "$OPENAPI_YAML"
  echo "          description: ok" >> "$OPENAPI_YAML"
  echo "          content:" >> "$OPENAPI_YAML"
  echo "            application/json:" >> "$OPENAPI_YAML"
  echo "              schema:" >> "$OPENAPI_YAML"
  echo "                type: object" >> "$OPENAPI_YAML"

  ## backend-prd
  echo "" >> "$BACKEND_MD"
  echo "## $MOD_NAME" >> "$BACKEND_MD"
  echo "[TODO] 补充后端需求细节" >> "$BACKEND_MD"

  ## frontend-prd
  echo "" >> "$FRONTEND_MD"
  echo "## $MOD_NAME" >> "$FRONTEND_MD"
  echo "[TODO] 补充前端需求细节" >> "$FRONTEND_MD"

  ## mobile-prd
  echo "" >> "$MOBILE_MD"
  echo "## $MOD_NAME" >> "$MOBILE_MD"
  echo "[TODO] 补充客户端需求细节" >> "$MOBILE_MD"

done

echo "✅ 骨架生成完成"
echo "- API 文档: $API_MD"
echo "- OpenAPI: $OPENAPI_YAML"
echo "- Backend: $BACKEND_MD"
echo "- Frontend: $FRONTEND_MD"
echo "- Mobile: $MOBILE_MD"
