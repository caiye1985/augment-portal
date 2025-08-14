#!/bin/bash
set -e

PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"
CHECKPOINT_FILE="$OUTPUT_BASE/progress.json"
MODULE_LIST_FILE="module_list.txt"

# ===== 1. 获取最新版本 =====
LATEST_VERSION=$(ls -d $PRD_BASE/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
LATEST_PRD_DIR="$PRD_BASE/$LATEST_VERSION"
OUTPUT_VERSION_DIR="$OUTPUT_BASE/$LATEST_VERSION"

echo "📂 最新 PRD 版本: v$LATEST_VERSION"
echo "📁 PRD 路径: $LATEST_PRD_DIR"
mkdir -p "$OUTPUT_VERSION_DIR"

# ===== 2. 模块清单 =====
if [ ! -f "$MODULE_LIST_FILE" ]; then
    echo "🔍 生成模块清单..."
    grep -rhoE 'REQ-[0-9]{3,4}[A-Z]?[ ]+[^|]+' "$LATEST_PRD_DIR" \
        | sort -u > "$MODULE_LIST_FILE"
    echo "✅ 模块清单已生成: $MODULE_LIST_FILE"
fi

# ===== 3. Checkpoint 文件 =====
if [ ! -f "$CHECKPOINT_FILE" ]; then
    cat <<EOF > "$CHECKPOINT_FILE"
{
  "backend": "REQ-START",
  "frontend": "REQ-START",
  "mobile": "REQ-START",
  "api": "REQ-START"
}
EOF
    echo "✅ 已创建 $CHECKPOINT_FILE"
fi

# ===== 4. 通用公共部分 =====
COMMON_PART=$(cat <<'EOF'
## Step 0：读取 PRD 最新版本路径
- 使用 \$LATEST_PRD_DIR
- 从模块清单的 \$START_REQ 开始，按顺序补全剩余模块
- 必须覆盖原 PRD 中全部 REQ-ID，不得合并/删除模块

## Step 2：生成并行交接图（Mermaid 源码）
- 输出 handoff-diagram.mmd（Mermaid 格式源文件）
- 严格按模板配色和结构生成
- 便于团队后期手动渲染 PNG

## Step 3：统一规范
1. 删除冗余和重复描述
2. 首次缩写需加全称（中英文）
3. Markdown 结构统一
4. API / OpenAPI 字段命名一致
5. Mock 数据符合命名规范

## Step 4：输出文件清单
- backend-prd.md
- frontend-prd.md
- mobile-prd.md
- api-docs.md
- openapi.yaml
- execution-plan.md
- handoff-diagram.mmd
EOF
)

# ===== 5. 各端专属规则 =====
BACKEND_RULE=$(cat <<'EOF'
## Step 1（backend-prd.md）：
- 覆盖 PRD 中所有模块，即便主要由前端实现的模块也必须列出并标记“无后端交付项”
- 每模块包含：
  - 功能概述
  - 核心功能（详细功能点列表）
  - 实现要点（技术方案、架构、数据流、安全、性能要求）
  - 依赖与接口（相关 API、外部模块）
- 确保数据模型、接口安全性、性能约束等描述齐全
EOF
)

FRONTEND_RULE=$(cat <<'EOF'
## Step 1（frontend-prd.md）：
- 覆盖所有模块，即使原文无 UI 描述，也需根据功能、用户故事、交互流程**推导**界面需求
- 每模块必须包含：
  - 功能概述
  - 界面结构（页面布局、主要组件）
  - 用户交互逻辑（点击、提交、跳转、加载）
  - API 调用清单（引用 api-docs.md 中接口）
- 公共 API 必须引用 api-docs.md 保持一致
EOF
)

MOBILE_RULE=$(cat <<'EOF'
## Step 1（mobile-prd.md，Flutter）：
- 忽略任何非 Flutter 技术方案
- 覆盖所有模块，即使原文无 UI，也需根据功能、用户故事、交互流程**推导** Flutter 界面与组件
- Flutter 技术栈（Dart 3.x、Flutter 3.x、Riverpod、GoRouter、drift、Dio）
- 每模块包含：
  - 功能概述
  - 界面结构与组件（布局、主要 Widgets）
  - 用户操作流程
  - API 对接方案（引用 api-docs.md）
- 公共 API 必须与 frontend 一致
EOF
)

API_RULE=$(cat <<'EOF'
## Step 1（api-docs.md + openapi.yaml）：
- 按模块分组所有 API（原文接口 + 推导补齐接口）
- 每个 API 必须标注 REQ-ID
- 说明包括：
  - 路径/方法
  - 覆盖需求: REQ-ID 列表
  - 适用平台（Web/Mobile/Both）
  - 权限要求
  - 请求参数表
  - 响应结构
  - 错误码
  - Mock 示例
- 多模块交互 API 保持命名和数据结构一致
- 公共 API 前/移动端复用
- openapi.yaml 与 api-docs.md 保持完全一致
EOF
)

# ===== 6. 选择模式 =====
echo "请选择生成模式:"
select MODE in "single-end" "full-end"; do
    case $MODE in
        single-end|full-end) break;;
        *) echo "❌ 无效选择" ;;
    esac
done

# ===== 7. 如果是单端模式，选择端 & 读取断点 =====
if [ "$MODE" == "single-end" ]; then
    echo "请选择生成文档类型:"
    select DOC_TYPE in backend frontend mobile api; do
        case $DOC_TYPE in
            backend|frontend|mobile|api) break;;
            *) echo "❌ 无效选择" ;;
        esac
    done
    START_REQ=$(grep "\"$DOC_TYPE\"" "$CHECKPOINT_FILE" | sed -E 's/.*": ?"([^"]+)".*/\1/')
    echo "📌 当前 $DOC_TYPE 断点: $START_REQ"
    read -p "是否从断点继续？(y/n): " CONT
    if [ "$CONT" != "y" ]; then
        START_REQ="REQ-START"
    fi
fi

# ===== 8. 构建 Prompt =====
if [ "$MODE" == "full-end" ]; then
    PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$COMMON_PART
$BACKEND_RULE
$FRONTEND_RULE
$MOBILE_RULE
$API_RULE"
else
    case $DOC_TYPE in
        backend)  PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$COMMON_PART
$BACKEND_RULE";;
        frontend) PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$COMMON_PART
$FRONTEND_RULE";;
        mobile)   PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$COMMON_PART
$MOBILE_RULE";;
        api)      PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$COMMON_PART
$API_RULE";;
    esac
fi

# ===== 9. 复制 Prompt ====
if command -v pbcopy &>/dev/null; then
    echo "$PROMPT" | pbcopy
    echo "✅ Prompt 已复制到剪贴板（macOS）"
elif command -v xclip &>/dev/null; then
    echo "$PROMPT" | xclip -selection clipboard
    echo "✅ Prompt 已复制到剪贴板（Linux）"
elif command -v clip &>/dev/null; then
    echo "$PROMPT" | clip
    echo "✅ Prompt 已复制到剪贴板（Windows Git Bash）"
else
    echo "$PROMPT"
fi

# ===== 10. 单端模式更新断点 =====
if [ "$MODE" == "single-end" ]; then
    read -p "输入已生成完成的最后一个 REQ-ID（如 REQ-020）： " LAST_REQ
    tmp_file=$(mktemp)
    jq ".\"$DOC_TYPE\" = \"$LAST_REQ\"" "$CHECKPOINT_FILE" > "$tmp_file" && mv "$tmp_file" "$CHECKPOINT_FILE"
    echo "✅ 已更新断点记录: $CHECKPOINT_FILE"
fi
