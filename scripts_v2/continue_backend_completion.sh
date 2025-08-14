#!/bin/bash
set -e

# -----------------------------
# 基础路径
# -----------------------------
PRD_BASE="docs/prd/split"
OUTPUT_BASE="docs/output"

# 获取最新版本号
LATEST_VERSION=$(ls -d "$PRD_BASE"/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
BACKEND_DIR="$PRD_BASE/$LATEST_VERSION"
OUTPUT_DIR="$OUTPUT_BASE/$LATEST_VERSION"

[ ! -d "$BACKEND_DIR" ] && { echo "❌ 找不到 Backend 目录: $BACKEND_DIR"; exit 1; }

echo "📄 检测到最新版本: $LATEST_VERSION"
echo "📂 Backend PRD 目录: $BACKEND_DIR"

# -----------------------------
# Step 1: 获取模块列表
# -----------------------------
MODULE_FILES=($(ls -1 "$BACKEND_DIR" | sort))
MODULES=()
for f in "${MODULE_FILES[@]}"; do
    MODULES+=("${f%.md}")
done

if [ ${#MODULES[@]} -eq 0 ]; then
    echo "❌ Backend 模块文件为空"
    exit 1
fi

echo
echo "📌 Backend 模块列表（来自 $BACKEND_DIR）："
for idx in "${!MODULES[@]}"; do
    printf "%2d. %s\n" $((idx+1)) "${MODULES[$idx]}"
done
echo

# -----------------------------
# Step 2: 用户选择模块
# -----------------------------
read -p "请输入要补全的模块编号或 REQ-ID（空格分隔，每次建议 1~2 个）: " -a SELECTED_ITEMS

TARGET_MODULES=()
for item in "${SELECTED_ITEMS[@]}"; do
    if [[ "$item" =~ ^[0-9]+$ ]] && [ "$item" -ge 1 ] && [ "$item" -le "${#MODULES[@]}" ]]; then
        TARGET_MODULES+=("${MODULES[$((item-1))]}")
    else
        for m in "${MODULES[@]}"; do
            if [[ "$m" == "$item"* ]]; then
                TARGET_MODULES+=("$m")
                break
            fi
        done
    fi
done

if [ ${#TARGET_MODULES[@]} -eq 0 ]; then
    echo "❌ 没有选择有效模块"
    exit 1
fi

echo
echo "本轮将处理 Backend 模块："
for m in "${TARGET_MODULES[@]}"; do
    echo " - $m"
done
echo

# -----------------------------
# Step 3: 生成结构摘要
# -----------------------------
SUMMARY_FILE="$OUTPUT_DIR/backend-summary.txt"
grep -h "^# " "$BACKEND_DIR"/*.md > "$SUMMARY_FILE"

# 从第一个有内容的模块取一个作参考示例
EXAMPLE_FILE=$(ls "$BACKEND_DIR" | sort | head -n 1)
EXAMPLE_CONTENT=$(cat "$BACKEND_DIR/$EXAMPLE_FILE")

# -----------------------------
# Step 4: 生成 Prompt 文件
# -----------------------------
PROMPT_FILE="$(pwd)/continue_backend_prompt.txt"
cat > "$PROMPT_FILE" <<EOF
你是高级系统架构师兼技术文档专家。

## 背景
- 系统版本: $LATEST_VERSION
- PRD 类型: Backend
- 当前已有 Backend 需求文档目录: $BACKEND_DIR

## 本轮目标模块
$(for m in "${TARGET_MODULES[@]}"; do echo "- $m"; done)

## 任务要求
1. 参考 Backend PRD 中已完成模块的写作风格（示例见下方）。
2. 为目标模块补全详细的功能需求描述，需覆盖该模块涉及的 **所有 REQ-ID**。
3. 每个功能需求应包含：
   - 功能概述
   - 适用场景
   - 功能流程（可附时序图/流程图描述）
   - 数据输入 / 输出
   - 与 API 接口的对应关系（引用 API 路径）
   - 权限及安全要求
   - 异常处理逻辑
4. 与 API 文档保持一致性，确保 API 路径、参数、字段命名对齐。
5. 输出完整的 Backend PRD 文本，保持原有 Markdown 结构。

## Backend 模块结构摘要
\`\`\`
$(cat "$SUMMARY_FILE")
\`\`\`

## 已完成模块示例（风格参考）
\`\`\`
$EXAMPLE_CONTENT
\`\`\`

请基于以上要求，输出更新后的目标模块文档内容。
EOF

echo "✅ Backend Prompt 已生成：$PROMPT_FILE"
echo "请手动复制内容到 augment 对话框执行补全。"
