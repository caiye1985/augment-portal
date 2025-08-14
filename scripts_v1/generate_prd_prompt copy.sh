#!/bin/bash
set -e

PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"
CHECKPOINT_FILE="$OUTPUT_BASE/progress.json"
MODULE_LIST_FILE="module_list.txt"

# 最新版本
LATEST_VERSION=$(ls -d "$PRD_BASE"/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
LATEST_PRD_DIR="$PRD_BASE/$LATEST_VERSION"
GLOBAL_FILE="$LATEST_PRD_DIR/global.md"
OUTPUT_VERSION_DIR="$OUTPUT_BASE/$LATEST_VERSION"

echo "📂 最新 PRD 版本: v$LATEST_VERSION"
mkdir -p "$OUTPUT_VERSION_DIR"

# 全局文件检查
[ ! -f "$GLOBAL_FILE" ] && { echo "❌ 缺少 $GLOBAL_FILE，请先运行 scripts/extract_global.sh"; exit 1; }

# 模块清单
if [ ! -f "$MODULE_LIST_FILE" ]; then
    grep -rhoE 'REQ-[0-9]{3,4}[A-Z]?[ ]+[^|]+' "$LATEST_PRD_DIR/modules" \
      | sort -u > "$MODULE_LIST_FILE"
    echo "✅ 模块清单已生成: $MODULE_LIST_FILE"
fi

# checkpoint
if [ ! -f "$CHECKPOINT_FILE" ]; then
    cat <<EOF > "$CHECKPOINT_FILE"
{
  "backend": "REQ-START",
  "frontend": "REQ-START",
  "mobile": "REQ-START",
  "api": "REQ-START"
}
EOF
fi

# Step0 — 不嵌全文，引用文件路径
STEP0=$(cat <<EOF
## Step 0：读取全局信息 + 指定模块
- 全局信息文件路径: `$GLOBAL_FILE`
- 全局信息包括：项目概述、技术架构、安全与性能要求、开发规范、部署要求，以及所有附录（术语表、开发优先级与实施计划、技术栈与架构选型、模块映射与依赖关系、架构图表与业务价值分析、部署指南与运维手册）
- 在生成时，必须读取并严格遵循该文件的全部内容
- 必须覆盖 PRD 全部模块 REQ-ID
- 模块从 \$START_REQ 开始，按顺序补齐剩余模块
EOF
)

# Step1 各端详细规则
BACKEND_STEP1=$(cat <<'EOF'
## Step 1（backend-prd.md）：
- 覆盖 PRD 中所有模块，即便主要由前端实现也必须列出，并标注“无后端交付项”并解释原因
- 每模块必须包含：
  - 功能概述
  - 核心功能列表
  - 实现要点（技术方案、架构、数据流、安全控制、性能优化）
  - 依赖与接口（API 路径/方法/参数/响应，以及依赖模块）
- 必须遵循全局技术架构、安全、性能、监控与日志规范
EOF
)

FRONTEND_STEP1=$(cat <<'EOF'
## Step 1（frontend-prd.md）：
- 覆盖全部模块，即使无 UI 描述，也要基于功能、用户故事、交互流程推导界面需求
- 每模块必须包含：
  - 功能概述
  - 界面结构
  - 用户交互逻辑
  - API 调用清单（引用 api-docs.md，保持一致）
EOF
)

MOBILE_STEP1=$(cat <<'EOF'
## Step 1（mobile-prd.md，Flutter）：
- 忽略任何非 Flutter 技术方案
- 覆盖全部模块，即便无 UI 描述，也要推导 Flutter 界面与组件
- 使用 Dart 3.1.0、Flutter 3.13.0、Material/Cupertino、自定义主题、Riverpod、GoRouter、drift、Dio
- 每模块必须包含：
  - 功能概述
  - 界面结构与组件
  - 用户操作流程
  - API 对接方案（引用 api-docs.md）
EOF
)

API_STEP1=$(cat <<'EOF'
## Step 1（api-docs.md + openapi.yaml）：
- 按模块分组列出所有 API（原有 + 推导补齐）
- 每接口标注 REQ-ID
- 说明包括：
  - 路径 / 方法
  - 覆盖需求 REQ-ID 列表
  - 适用平台
  - 权限要求
  - 请求参数
  - 响应结构
  - 错误码
  - Mock 示例
- api-docs.md 与 openapi.yaml 必须完全对应
EOF
)

# Step2
STEP2=$(cat <<'EOF'
## Step 2：生成并行交接图（Mermaid 源）
- 输出 handoff-diagram.mmd（Mermaid 格式）
EOF
)

# Step3
STEP3=$(cat <<'EOF'
## Step 3：统一规范
- 删除冗余
- 缩写首次加全称
- Markdown 统一格式
- API / OpenAPI 字段命名一致
- Mock 数据规范
EOF
)

# Step4 输出清单
OUT_BACKEND="## Step 4：输出文件清单\n- backend-prd.md\n- handoff-diagram.mmd"
OUT_FRONTEND="## Step 4：输出文件清单\n- frontend-prd.md"
OUT_MOBILE="## Step 4：输出文件清单\n- mobile-prd.md"
OUT_API="## Step 4：输出文件清单\n- api-docs.md\n- openapi.yaml"
OUT_FULL="## Step 4：输出文件清单\n- backend-prd.md\n- frontend-prd.md\n- mobile-prd.md\n- api-docs.md\n- openapi.yaml\n- execution-plan.md\n- handoff-diagram.mmd"

# 选择模式
echo "请选择模式:"
select MODE in "single-end" "full-end"; do
  case $MODE in single-end|full-end) break;; esac
done

if [ "$MODE" == "single-end" ]; then
  echo "请选择文档类型:"
  select DOC_TYPE in backend frontend mobile api; do
    case $DOC_TYPE in backend|frontend|mobile|api) break;; esac
  done
  START_REQ=$(grep "\"$DOC_TYPE\"" "$CHECKPOINT_FILE" | sed -E 's/.*": ?"([^"]+)".*/\1/')
  read -p "是否从断点继续？(y/n): " CONT
  [ "$CONT" != "y" ] && START_REQ="REQ-START"
fi

# 拼接 Prompt
if [ "$MODE" == "full-end" ]; then
  PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$BACKEND_STEP1\n$FRONTEND_STEP1\n$MOBILE_STEP1\n$API_STEP1\n$STEP2\n$STEP3\n$OUT_FULL"
else
  case $DOC_TYPE in
    backend) PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$BACKEND_STEP1\n$STEP2\n$STEP3\n$OUT_BACKEND";;
    frontend) PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$FRONTEND_STEP1\n$STEP3\n$OUT_FRONTEND";;
    mobile) PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$MOBILE_STEP1\n$STEP3\n$OUT_MOBILE";;
    api) PROMPT="你是资深系统架构师兼 AI 产品经理。\n$STEP0\n$API_STEP1\n$STEP3\n$OUT_API";;
  esac
fi

# 输出 Prompt
if command -v pbcopy &>/dev/null; then
  echo -e "$PROMPT" | pbcopy
  echo "✅ Prompt 已复制到剪贴板"
else
  echo -e "$PROMPT"
fi
