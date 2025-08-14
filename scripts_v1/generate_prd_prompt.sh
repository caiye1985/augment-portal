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

# 检查 global.md 存在
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

# Step0（全局引用）
STEP0=$(cat <<EOF
## Step 0：读取全局信息 + 指定模块
- 全局信息文件路径: $GLOBAL_FILE
- 全局信息包括：项目概述、技术架构、安全与性能要求、开发规范、部署要求，以及附录（术语表、开发优先级、技术栈与架构选型、模块映射与依赖、架构图表与业务价值分析、部署指南与运维手册）
- 必须读取并严格遵循该文件内容
- 必须覆盖 PRD 所有 REQ-ID
- 模块从 \$START_REQ 开始，按顺序补齐
EOF
)

# Step1 各端详细规则
BACKEND_STEP1=$(cat <<'EOF'
## Step 1（backend-prd.md）：
- 覆盖所有模块，即便无后端交付项也必须列出并说明原因
- 每模块必须包含：
  - 功能概述
  - 核心功能
  - 实现要点（技术方案、架构、数据流、安全、性能）
  - 依赖与接口（API 路径/方法/参数/响应 + 依赖模块）
- 必须遵守全局架构、安全、性能、监控与日志要求
EOF
)

FRONTEND_STEP1=$(cat <<'EOF'
## Step 1（frontend-prd.md）：
- 覆盖所有模块，无UI描述也需根据功能/交互/故事推导界面需求
- 每模块必须包含：
  - 功能概述
  - 界面结构
  - 用户交互逻辑
  - API调用清单（引用 api-docs.md）
- 公共 API 必须与 api-docs.md 一致
EOF
)

MOBILE_STEP1=$(cat <<'EOF'
## Step 1（mobile-prd.md，Flutter）：
- 忽略非 Flutter 技术方案
- 覆盖所有模块，无UI描述也需推导 Flutter 界面与组件
- Flutter 技术栈: Dart 3.1.0、Flutter 3.13.0、Material/Cupertino、Riverpod、GoRouter、drift、Dio
- 每模块必须包含：
  - 功能概述
  - 界面结构与组件
  - 用户操作流程
  - API对接方案（引用 api-docs.md）
- 公共 API 必须与 frontend 一致
EOF
)

API_STEP1=$(cat <<'EOF'
## Step 1（api-docs.md + openapi.yaml）：
- 按模块分组列出所有 API（原文 + 推导补齐）
- 每接口必须标注 REQ-ID
- API说明：
  - 路径/方法
  - 覆盖需求 REQ-ID 列表
  - 适用平台
  - 权限要求
  - 请求参数
  - 响应结构
  - 错误码
  - Mock示例
- api-docs.md 与 openapi.yaml 必须完全一致
EOF
)

# Step2（仅 backend/full-end）
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
- Markdown 格式统一
- API / OpenAPI 字段命名一致
- Mock 数据符合规范
EOF
)

# Step4 (带输出路径)
OUT_BACKEND="## Step 4：输出文件清单
所有文件必须保存到目录：$OUTPUT_VERSION_DIR
- backend-prd.md
- handoff-diagram.mmd"

OUT_FRONTEND="## Step 4：输出文件清单
所有文件必须保存到目录：$OUTPUT_VERSION_DIR
- frontend-prd.md"

OUT_MOBILE="## Step 4：输出文件清单
所有文件必须保存到目录：$OUTPUT_VERSION_DIR
- mobile-prd.md"

OUT_API="## Step 4：输出文件清单
所有文件必须保存到目录：$OUTPUT_VERSION_DIR
- api-docs.md
- openapi.yaml"

OUT_FULL="## Step 4：输出文件清单
所有文件必须保存到目录：$OUTPUT_VERSION_DIR
- backend-prd.md
- frontend-prd.md
- mobile-prd.md
- api-docs.md
- openapi.yaml
- execution-plan.md
- handoff-diagram.mmd"

# 选择模式
echo "请选择模式:"
select MODE in "single-end" "full-end"; do
    case $MODE in single-end|full-end) break;; esac
done

# 单端选择
if [ "$MODE" == "single-end" ]; then
    echo "请选择文档类型:"
    select DOC_TYPE in backend frontend mobile api; do
        case $DOC_TYPE in backend|frontend|mobile|api) break;; esac
    done
    START_REQ=$(grep "\"$DOC_TYPE\"" "$CHECKPOINT_FILE" | sed -E 's/.*": ?"([^"]+)".*/\1/')
    read -p "是否从断点继续？(y/n): " CONT
    [ "$CONT" != "y" ] && START_REQ="REQ-START"

    # ✅ 依赖检查
    if [[ "$DOC_TYPE" != "api" ]]; then
        if [ ! -f "$OUTPUT_VERSION_DIR/api-docs.md" ] || [ ! -f "$OUTPUT_VERSION_DIR/openapi.yaml" ]; then
            echo "❌ [$DOC_TYPE] 模式依赖 API 文档，请先生成 API 文档 (single-end: api) 或使用 full-end 模式！"
            exit 1
        fi
    fi
fi

# 拼 Prompt
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
