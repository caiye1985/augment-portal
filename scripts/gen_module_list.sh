#!/usr/bin/env bash
# gen_module_list.sh
# 自动生成模块编号列表文件，可按阶段生成多个列表
# 基于 docs/prd/split/4.5/modules 目录扫描
# 格式：<模块编号> <模块文档路径>

set -e

MODULES_DIR="docs/prd/split/4.5/modules"
OUTPUT_DIR="scripts"
mkdir -p "$OUTPUT_DIR"

# 定义不需要生成API的模块列表（与init_api_structure.sh保持一致）
API_EXCLUDE_MODULES=(
    "REQ-020"  # 移动端应用模块 - 复用其他业务域API
    "REQ-015"  # 用户体验增强系统 - 前端/交互优化
    "REQ-002"  # 工作台与仪表板模块 - 数据聚合展示
)

if [ ! -d "$MODULES_DIR" ]; then
    echo "[x] 模块目录不存在: $MODULES_DIR"
    exit 1
fi

# 定义各阶段模块编号（根据你的项目P0/P1/P2规划）
# 注意：REQ-002, REQ-015, REQ-020 已从列表中移除，因为它们不需要独立的API
P0_MODULES=(
  REQ-001 REQ-003 REQ-004 REQ-006A REQ-010 REQ-022
)
P1_MODULES=(
  REQ-005 REQ-006B REQ-007 REQ-011 REQ-012 REQ-016 REQ-017 REQ-018
)
P2_MODULES=(
  REQ-008 REQ-009 REQ-013 REQ-014 REQ-019 REQ-021 REQ-023
)

# 检查模块是否在排除列表中
is_module_excluded() {
    local mod="$1"
    for exclude_id in "${API_EXCLUDE_MODULES[@]}"; do
        if [[ "$mod" == "$exclude_id" ]]; then
            return 0  # 模块在排除列表中
        fi
    done
    return 1  # 模块不在排除列表中
}

gen_list() {
    local listname="$1"
    shift
    local modules=("$@")
    local outfile="$OUTPUT_DIR/module_list_${listname}.txt"
    > "$outfile"
    for mod in "${modules[@]}"; do
        # 检查是否为API模式且模块在排除列表中
        if [[ "$listname" =~ ^(P0|P1|P2|all)$ ]] && is_module_excluded "$mod"; then
            echo "[i] 跳过API排除模块: $mod" >&2
            continue
        fi

        local f="$MODULES_DIR/${mod}.md"
        if [ -f "$f" ]; then
            echo "$mod $f" >> "$outfile"
        else
            echo "[警告] 未找到模块文件: $f" >&2
        fi
    done
    echo "[√] 已生成: $outfile ($(wc -l < "$outfile") 条)"
}

echo "[*] 生成所有阶段模块列表..."

# 生成全部列表（按文件名自然排序），排除API排除模块
ALL_FILE="$OUTPUT_DIR/module_list_all.txt"
> "$ALL_FILE"
for file in $(ls "$MODULES_DIR"/REQ-*.md 2>/dev/null | sort -V); do
    mod=$(basename "$file" .md)
    # 检查模块是否在排除列表中
    if is_module_excluded "$mod"; then
        echo "[i] 跳过API排除模块: $mod" >&2
        continue
    fi
    echo "$mod $file" >> "$ALL_FILE"
done
echo "[√] 已生成: $ALL_FILE ($(wc -l < "$ALL_FILE") 条)"

# 生成各阶段列表
gen_list P0 "${P0_MODULES[@]}"
gen_list P1 "${P1_MODULES[@]}"
gen_list P2 "${P2_MODULES[@]}"

echo "[完成] 所有模块列表已生成到 $OUTPUT_DIR/"
