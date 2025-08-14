#!/bin/bash
set -e

PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"
CHECKPOINT_FILE="$OUTPUT_BASE/progress.json"
MODULE_LIST_FILE="module_list.txt"

# 1 获取最新 PRD
LATEST_VERSION=$(ls -d $PRD_BASE/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
LATEST_PRD_DIR="$PRD_BASE/$LATEST_VERSION"
OUTPUT_VERSION_DIR="$OUTPUT_BASE/$LATEST_VERSION"

echo "📂 最新 PRD 版本: v$LATEST_VERSION"
mkdir -p "$OUTPUT_VERSION_DIR"

# 2 模块清单
if [ ! -f "$MODULE_LIST_FILE" ]; then
    grep -rhoE 'REQ-[0-9]{3,4}[A-Z]?[ ]+[^|]+' "$LATEST_PRD_DIR" | sort -u > "$MODULE_LIST_FILE"
    echo "✅ 模块清单已生成: $MODULE_LIST_FILE"
fi

# 3 Checkpoint
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

# 公共 Step0
STEP0=$(cat <<EOF
## Step 0：读取 PRD 最新版本路径
- 使用 $LATEST_PRD_DIR
- 从模块清单的 \$START_REQ 开始，按顺序补全剩余模块
- 覆盖原 PRD 全部 REQ-ID，不得合并/丢失模块
EOF
)

# 各端 Step1
BACKEND_STEP1=$(cat <<'EOF'
## Step 1（backend-prd.md）
- 覆盖所有模块，即便主要由前端实现的模块也必须列出并标记“无后端交付项”
- 每模块包含：
  - 功能概述
  - 核心功能
  - 实现要点（技术、架构、数据流、安全、性能要求）
  - 依赖与接口
EOF
)

FRONTEND_STEP1=$(cat <<'EOF'
## Step 1（frontend-prd.md）
- 覆盖所有模块，即使无 UI 描述也要基于功能、用户故事、交互流程**推导**界面需求
- 每模块包含：
  - 功能概述
  - 界面结构
  - 用户交互逻辑
  - API 调用清单（引用 api-docs.md）
EOF
)

MOBILE_STEP1=$(cat <<'EOF'
## Step 1（mobile-prd.md，Flutter）
- 忽略非 Flutter 技术方案
- 覆盖所有模块，即使无 UI 描述也**推导** Flutter 界面
- 每模块包含：
  - 功能概述
  - 界面结构与组件
  - 用户操作流程
  - API 对接方案（引用 api-docs.md）
EOF
)

API_STEP1=$(cat <<'EOF'
## Step 1（api-docs.md + openapi.yaml）
- 列出所有 API（原文 + 推导补齐），标注 REQ-ID
- 每接口：
  - 路径/方法
  - REQ-ID 列表
  - 适用平台
  - 权限
  - 请求参数
  - 响应结构
  - 错误码
  - Mock 示例
- 多模块交互 API 保持一致
- openapi.yaml 与 api-docs.md 完全一致
EOF
)

# Step2（交接图）
STEP2=$(cat <<'EOF'
## Step 2：生成并行交接图（Mermaid 源码）
- 输出 handoff-diagram.mmd（Mermaid 源）
- 严格按模板配色和结构生成
EOF
)

# Step3（统一规范）
STEP3=$(cat <<'EOF'
## Step 3：统一规范
1. 删除冗余
2. 缩写首次加全称
3. Markdown 格式一致
4. API / OpenAPI 字段命名一致
5. Mock 数据规范
EOF
)

# Step4（输出清单）按端动态
BACKEND_OUT=$(cat <<'EOF'
## Step 4：输出文件清单
- backend-prd.md
- handoff-diagram.mmd
EOF
)

FRONTEND_OUT=$(cat <<'EOF'
## Step 4：输出文件清单
- frontend-prd.md
EOF
)

MOBILE_OUT=$(cat <<'EOF'
## Step 4：输出文件清单
- mobile-prd.md
EOF
)

API_OUT=$(cat <<'EOF'
## Step 4：输出文件清单
- api-docs.md
- openapi.yaml
EOF
)

FULL_OUT=$(cat <<'EOF'
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

# 选择模式
echo "请选择模式:"
select MODE in "single-end" "full-end"; do
    case $MODE in
        single-end|full-end) break;;
    esac
done

# 单端模式选端
if [ "$MODE" == "single-end" ]; then
    echo "请选择端类型:"
    select DOC_TYPE in backend frontend mobile api; do
        case $DOC_TYPE in
            backend|frontend|mobile|api) break;;
        esac
    done
    START_REQ=$(grep "\"$DOC_TYPE\"" "$CHECKPOINT_FILE" | sed -E 's/.*": ?"([^"]+)".*/\1/')
    [ "$START_REQ" == "" ] && START_REQ="REQ-START"
    read -p "是否从断点继续？(y/n): " CONT
    if [ "$CONT" != "y" ]; then START_REQ="REQ-START"; fi
fi

# 拼接 Prompt
if [ "$MODE" == "full-end" ]; then
    PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$STEP0
$BACKEND_STEP1
$FRONTEND_STEP1
$MOBILE_STEP1
$API_STEP1
$STEP2
$STEP3
$FULL_OUT"
else
    case $DOC_TYPE in
        backend)
            PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$STEP0
$BACKEND_STEP1
$STEP2
$STEP3
$BACKEND_OUT";;
        frontend)
            PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$STEP0
$FRONTEND_STEP1
$STEP3
$FRONTEND_OUT";;
        mobile)
            PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$STEP0
$MOBILE_STEP1
$STEP3
$MOBILE_OUT";;
        api)
            PROMPT="你现在是资深系统架构师兼 AI 产品经理。
$STEP0
$API_STEP1
$STEP3
$API_OUT";;
    esac
fi

# 输出到剪贴板
if command -v pbcopy &>/dev/null; then
    echo "$PROMPT" | pbcopy
    echo "✅ Prompt 已复制到剪贴板（macOS）"
elif command -v xclip &>/dev/null; then
    echo "$PROMPT" | xclip -selection clipboard
    echo "✅ Prompt 已复制到剪贴板（Linux）"
else
    echo "$PROMPT"
fi

# 更新断点
if [ "$MODE" == "single-end" ]; then
    read -p "输入已生成完成的最后一个 REQ-ID: " LAST_REQ
    tmp_file=$(mktemp)
    jq ".\"$DOC_TYPE\" = \"$LAST_REQ\"" "$CHECKPOINT_FILE" > "$tmp_file" && mv "$tmp_file" "$CHECKPOINT_FILE"
fi
```
