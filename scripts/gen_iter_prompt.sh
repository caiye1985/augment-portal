#!/usr/bin/env bash
set -e

# 导入版本工具
source "$(dirname "$0")/version_utils.sh"

# 检测版本并设置路径
VERSION=$(detect_prd_version)
if [[ $? -ne 0 ]]; then
    echo "[错误] 无法检测PRD版本号" >&2
    exit 1
fi

# 设置版本化路径
GLOBAL_FILE="docs/global-context.md"
MOCK_GUIDE="docs/prd/split/$VERSION/globals/05-mock-data-guidelines.md"
API_BUNDLE="docs/api/$VERSION/global-api-index.yaml"
MAPPING_FILE="docs/prd/split/$VERSION/globals/06-api-domain-mapping.md"
PROMPT_DIR="prompts/$VERSION"

# 导出VERSION变量供envsubst使用
export VERSION

progress_file() { echo ".gen_iter_state_phase_${1}_${2}"; }
read_progress() { local pf=$(progress_file "$1" "$2"); [ -f "$pf" ] && source "$pf" || current_index=0; }
save_progress() { local pf=$(progress_file "$1" "$2"); echo "current_index=$current_index" > "$pf"; }

# 从映射表获取模块名称
get_module_name() {
    local module_id="$1"
    if [[ ! -f "$MAPPING_FILE" ]]; then
        echo "[警告] 映射文件不存在: $MAPPING_FILE"
        echo "未知模块"
        return
    fi

    # 从映射表中查找模块名称
    local module_name
    module_name=$(grep -E "\|[[:space:]]*${module_id}[[:space:]]*\|" "$MAPPING_FILE" | \
                  head -n1 | \
                  awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $5); print $5}')

    if [[ -n "$module_name" ]]; then
        echo "$module_name"
    else
        echo "未知模块"
    fi
}

save_and_copy_prompt() {
    local content="$1"
    local template_file="$2" # 模板路径 prompt-templates/api-iter.md
    local mid="$3"           # 模块编号，初始模式可以用占位 ALL

    # 根据模式确定子目录
    local template_base
    template_base=$(basename "$template_file" .md)
    local mode_subdir
    case "$template_base" in
        api-*) mode_subdir="api" ;;
        backend-*) mode_subdir="backend" ;;
        frontend-*) mode_subdir="frontend" ;;
        mobile-*) mode_subdir="mobile" ;;
        *) mode_subdir="api" ;;
    esac

    local prompt_mode_dir="$PROMPT_DIR/$mode_subdir"
    mkdir -p "$prompt_mode_dir"

    local file="$prompt_mode_dir/${template_base}-${mid}.md"
    echo "$content" > "$file"

    echo "[√] 已保存 Prompt: $file"

    # 复制到剪贴板（跨平台）
    if command -v pbcopy &>/dev/null; then
        cat "$file" | pbcopy && echo "[√] 已复制到剪贴板 (pbcopy)"
    elif command -v xclip &>/dev/null; then
        cat "$file" | xclip -selection clipboard && echo "[√] 已复制到剪贴板 (xclip)"
    elif command -v wl-copy &>/dev/null; then
        cat "$file" | wl-copy && echo "[√] 已复制到剪贴板 (wl-copy)"
    elif command -v clip &>/dev/null; then
        cat "$file" | clip && echo "[√] 已复制到剪贴板 (clip)"
    else
        echo "[!] 未检测到可用的剪贴板命令"
    fi
}




render_prompt() {
    local template="$1" mid="$2" path="$3"

    # 检查必需文件是否存在
    if [[ ! -f "$GLOBAL_FILE" ]]; then
        echo "[警告] 全局上下文文件不存在: $GLOBAL_FILE"
    fi
    if [[ ! -f "$MOCK_GUIDE" ]]; then
        echo "[警告] Mock数据规范文件不存在: $MOCK_GUIDE"
    fi
    if [[ ! -f "$path" ]]; then
        echo "[错误] 模块文件不存在: $path"
        return 1
    fi

    # 获取模块名称
    local module_name
    module_name=$(get_module_name "$mid")

    # 设置环境变量（API_BUNDLE可选）
    export GLOBAL_FILE MOCK_GUIDE MODULE_FILE="$path" MODULE_ID="$mid" MODULE_NAME="$module_name"
    export VERSION
    if [[ -f "$API_BUNDLE" ]]; then
        export API_BUNDLE
    else
        export API_BUNDLE="（文件不存在，跳过引用）"
    fi

    envsubst < "$template" | sed 's/DOLLAR_REF/$ref/g'
}

generate_all_modules() {
    local mode="$1" phase="$2"
    local list_file="scripts/module_list_${phase}.txt"
    [ ! -f "$list_file" ] && ./scripts/gen_module_list.sh
    read_progress "$phase" "$mode"
    local total
    total=$(wc -l < "$list_file" | tr -d ' ')

    if (( current_index >= total )); then
        echo "[√] 阶段 $phase 已完成，共 $total 个模块"
        return
    fi

    local template_file=""
    case "$mode" in
      api-init) template_file="prompt-templates/api-init.md" ;;
      api) template_file="prompt-templates/api-iter.md" ;;
      backend-init) template_file="prompt-templates/backend-init.md" ;;
      backend) template_file="prompt-templates/backend-iter.md" ;;
      frontend-init) template_file="prompt-templates/frontend-init.md" ;;
      frontend) template_file="prompt-templates/frontend-iter.md" ;;
      mobile-init) template_file="prompt-templates/mobile-init.md" ;;
      mobile) template_file="prompt-templates/mobile-iter.md" ;;
      *) echo "[x] 未知模式: $mode" && exit 1 ;;
    esac

    echo "[i] 开始生成阶段 $phase 的 $mode prompt 文件..."
    echo "[i] 版本: $VERSION"
    echo "[i] 进度: $current_index/$total"

    for idx in $(seq "$current_index" "$((total - 1))"); do
        local line; line=$(sed -n "$((idx+1))p" "$list_file")
        local mid path; read mid path <<< "$line"
        echo "[i] 正在处理模块 $((idx+1))/$total: $mid"

        # 生成prompt
        local prompt; prompt=$(render_prompt "$template_file" "$mid" "$path")
        save_and_copy_prompt "$prompt" "$template_file" "$mid"
    done

    current_index=$total
    save_progress "$phase" "$mode"
    echo "[√] 阶段 $phase 完成，共生成 $total 个 $mode prompt 文件"
}

# 处理所有阶段的函数
generate_all_phases() {
    local mode="$1"
    echo "[i] 开始生成所有阶段的 $mode prompt 文件..."

    for phase in P0 P1 P2; do
        echo ""
        echo "[i] === 处理阶段: $phase ==="
        generate_all_modules "$mode" "$phase"
    done

    echo ""
    echo "[√] 所有阶段完成"
}

# 参数检查和帮助信息
if [ $# -lt 2 ]; then
    echo "用法: $0 <模式> <阶段>"
    echo ""
    echo "参数说明:"
    echo "  <模式>   : api-init, api, backend-init, backend, frontend-init, frontend, mobile-init, mobile"
    echo "  <阶段>   : P0, P1, P2, all"
    echo ""
    echo "示例用法:"
    echo "  $0 api P0        # 生成P0阶段所有模块的API prompt"
    echo "  $0 api P1        # 生成P1阶段所有模块的API prompt"
    echo "  $0 api P2        # 生成P2阶段所有模块的API prompt"
    echo "  $0 api all       # 生成所有阶段的API prompt"
    echo "  $0 backend P0    # 生成P0阶段所有模块的后端 prompt"
    echo ""
    echo "注意: 每个模块都会生成独立的prompt文件，支持中断和恢复"
    echo ""
    echo "PRD分析功能:"
    echo "  使用独立的PRD分析脚本: bash scripts/gen_prd_analysis.sh"
    exit 1
fi

mode="$1"
phase="$2"

# 向后兼容性：如果提供了第3个参数则忽略它并给出提示
if [ $# -gt 2 ]; then
    echo "[i] 注意: 批量数参数已被移除，每个模块都会生成独立的prompt文件"
    echo "[i] 如需PRD分析功能，请使用: bash scripts/gen_prd_analysis.sh"
fi

# 执行生成
if [ "$phase" = "all" ]; then
    generate_all_phases "$mode"
else
    generate_all_modules "$mode" "$phase"
fi
