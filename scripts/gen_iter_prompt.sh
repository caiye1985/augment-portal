#!/usr/bin/env bash
set -e

GLOBAL_FILE="docs/global-context.md"
MOCK_GUIDE="docs/prd/split/4.5/globals/05-mock-data-guidelines.md"
API_BUNDLE="openapi.bundle.yaml"
PROMPT_DIR="prompts"

progress_file() { echo ".gen_iter_state_phase_${1}_${2}"; }
read_progress() { local pf=$(progress_file "$1" "$2"); [ -f "$pf" ] && source "$pf" || current_index=0; }
save_progress() { local pf=$(progress_file "$1" "$2"); echo "current_index=$current_index" > "$pf"; }

save_and_copy_prompt() {
    local content="$1"
    local template_file="$2" # 模板路径 prompt-templates/api-iter.md
    local mid="$3"           # 模块编号，初始模式可以用占位 ALL

    mkdir -p "$PROMPT_DIR"
    local template_base
    template_base=$(basename "$template_file" .md)
    local file="$PROMPT_DIR/${template_base}-${mid}.md"
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

    # 设置环境变量（API_BUNDLE可选）
    export GLOBAL_FILE MOCK_GUIDE MODULE_FILE="$path" MODULE_ID="$mid"
    if [[ -f "$API_BUNDLE" ]]; then
        export API_BUNDLE
    else
        export API_BUNDLE="（文件不存在，跳过引用）"
    fi

    envsubst < "$template" | sed 's/DOLLAR_REF/$ref/g'
}

generate_batch() {
    local mode="$1" phase="$2" batch="$3"
    local list_file="scripts/module_list_${phase}.txt"
    [ ! -f "$list_file" ] && ./scripts/gen_module_list.sh
    read_progress "$phase" "$mode"
    local total=$(wc -l < "$list_file")
    (( current_index >= total )) && { echo "[√] 阶段 $phase 已完成"; return; }
    local end=$((current_index + batch - 1)); (( end >= total )) && end=$((total - 1))

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

    for idx in $(seq "$current_index" "$end"); do
        local line; line=$(sed -n "$((idx+1))p" "$list_file")
        local mid path; read mid path <<< "$line"
        local prompt; prompt=$(render_prompt "$template_file" "$mid" "$path")
        echo "$prompt"
        save_and_copy_prompt "$prompt" "$template_file" "$mid"
    done
    current_index=$((end+1)); save_progress "$phase" "$mode"
}

if [ $# -lt 2 ]; then
    echo "用法: $0 <模式> <阶段:P0|P1|P2|all> [批量数,默认1]"
    exit 1
fi

mode="$1"; phase="$2"; batch="${3:-1}"
generate_batch "$mode" "$phase" "$batch"
