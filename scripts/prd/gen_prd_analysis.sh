#!/usr/bin/env bash
# gen_prd_analysis.sh
# PRD文档质量分析与改进建议生成脚本
# 专门用于对PRD文档进行质量检查和改进建议生成

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
PROMPT_DIR="prompts/$VERSION/prd-analysis"
ANALYSIS_OUTPUT_DIR="docs/output/$VERSION/prd-improvements"
NEW_PRD_VERSION="${VERSION}.1"
NEW_PRD_DIR="docs/prd/split/$NEW_PRD_VERSION/modules"

# 导出VERSION变量供envsubst使用
export VERSION

# 进度管理函数
progress_file() { echo ".gen_prd_analysis_state_${1}"; }
read_progress() { local pf=$(progress_file "$1"); [ -f "$pf" ] && source "$pf" || current_index=0; }
save_progress() { local pf=$(progress_file "$1"); echo "current_index=$current_index" > "$pf"; }

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

# 生成PRD分析prompt
render_prd_analysis_prompt() {
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

    # 设置环境变量
    export GLOBAL_FILE MOCK_GUIDE MODULE_FILE="$path" MODULE_ID="$mid" MODULE_NAME="$module_name"
    export VERSION
    if [[ -f "$API_BUNDLE" ]]; then
        export API_BUNDLE
    else
        export API_BUNDLE="（文件不存在，跳过引用）"
    fi

    envsubst < "$template" | sed 's/DOLLAR_REF/$ref/g'
}

# 保存PRD分析prompt
save_prd_analysis_prompt() {
    local content="$1"
    local mid="$2"
    
    mkdir -p "$PROMPT_DIR"
    local file="$PROMPT_DIR/prd-analysis-${mid}.md"
    echo "$content" > "$file"

    echo "[√] 已保存 PRD分析Prompt: $file"
    
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

# 生成指定阶段的PRD分析
generate_prd_analysis_phase() {
    local phase="$1"
    local list_file="scripts/module_list_${phase}.txt"
    
    # 检查模块列表文件
    [ ! -f "$list_file" ] && ./scripts/gen_module_list.sh
    
    read_progress "$phase"
    local total
    total=$(wc -l < "$list_file" | tr -d ' ')
    
    if (( current_index >= total )); then
        echo "[√] 阶段 $phase 已完成，共 $total 个模块"
        return
    fi

    local template_file="prompt-templates/prd-analysis.md"
    if [[ ! -f "$template_file" ]]; then
        echo "[错误] PRD分析模板不存在: $template_file"
        exit 1
    fi

    echo "[i] 开始生成阶段 $phase 的PRD分析prompt文件..."
    echo "[i] 版本: $VERSION"
    echo "[i] 进度: $current_index/$total"
    echo "[i] Prompt输出目录: $PROMPT_DIR"
    echo "[i] 改进PRD保存目录: $NEW_PRD_DIR"

    for idx in $(seq "$current_index" "$((total - 1))"); do
        local line; line=$(sed -n "$((idx+1))p" "$list_file")
        local mid path; read mid path <<< "$line"
        echo "[i] 正在处理模块 $((idx+1))/$total: $mid"
        
        local prompt; prompt=$(render_prd_analysis_prompt "$template_file" "$mid" "$path")
        save_prd_analysis_prompt "$prompt" "$mid"
    done
    
    current_index=$total
    save_progress "$phase"
    echo "[√] 阶段 $phase 完成，共生成 $total 个PRD分析prompt文件"
}

# 生成所有阶段的PRD分析
generate_all_phases() {
    echo "[i] 开始生成所有阶段的PRD分析prompt文件..."
    echo "[i] 版本: $VERSION"
    
    for phase in P0 P1 P2; do
        echo ""
        echo "[i] === 处理阶段: $phase ==="
        generate_prd_analysis_phase "$phase"
    done
    
    echo ""
    echo "[√] 所有阶段完成"
    
    # 统计生成的文件
    local total_files
    total_files=$(find "$PROMPT_DIR" -name "prd-analysis-*.md" | wc -l | tr -d ' ')
    echo "[i] 总共生成了 $total_files 个PRD分析prompt文件"
    echo "[i] 文件位置: $PROMPT_DIR"
}

# 清理指定阶段的进度
clean_progress() {
    local phase="$1"
    local pf=$(progress_file "$phase")
    if [[ -f "$pf" ]]; then
        rm "$pf"
        echo "[√] 已清理阶段 $phase 的进度文件"
    fi
}

# 清理所有进度
clean_all_progress() {
    for phase in P0 P1 P2; do
        clean_progress "$phase"
    done
    echo "[√] 已清理所有进度文件"
}

# 显示当前进度
show_progress() {
    echo "[i] 当前PRD分析生成进度："
    echo "[i] 版本: $VERSION"
    
    for phase in P0 P1 P2; do
        local list_file="scripts/module_list_${phase}.txt"
        if [[ -f "$list_file" ]]; then
            local total
            total=$(wc -l < "$list_file" | tr -d ' ')
            read_progress "$phase"
            echo "[i] 阶段 $phase: $current_index/$total"
        else
            echo "[i] 阶段 $phase: 模块列表文件不存在"
        fi
    done
    
    # 统计已生成的文件
    if [[ -d "$PROMPT_DIR" ]]; then
        local generated_files
        generated_files=$(find "$PROMPT_DIR" -name "prd-analysis-*.md" | wc -l | tr -d ' ')
        echo "[i] 已生成文件: $generated_files 个"
        echo "[i] 输出目录: $PROMPT_DIR"
    else
        echo "[i] 输出目录尚未创建: $PROMPT_DIR"
    fi
}

# 参数检查和帮助信息
if [ $# -lt 1 ]; then
    echo "用法: $0 <命令> [阶段]"
    echo ""
    echo "命令说明:"
    echo "  generate <阶段>  - 生成指定阶段的PRD分析prompt"
    echo "  all             - 生成所有阶段的PRD分析prompt"
    echo "  progress        - 显示当前生成进度"
    echo "  clean <阶段>    - 清理指定阶段的进度"
    echo "  clean-all       - 清理所有阶段的进度"
    echo ""
    echo "阶段参数: P0, P1, P2"
    echo ""
    echo "示例用法:"
    echo "  $0 generate P0      # 生成P0阶段的PRD分析prompt"
    echo "  $0 all              # 生成所有阶段的PRD分析prompt"
    echo "  $0 progress         # 查看当前进度"
    echo "  $0 clean-all        # 清理所有进度，重新开始"
    echo ""
    echo "输出位置:"
    echo "  Prompt文件: prompts/$VERSION/prd-analysis/"
    echo "  改进后PRD: docs/prd/split/$NEW_PRD_VERSION/modules/"
    echo "  分析结果: docs/output/$VERSION/prd-improvements/"
    echo ""
    echo "注意: 每个模块都会生成独立的PRD分析prompt文件，支持中断和恢复"
    exit 1
fi

command="$1"
phase="$2"

# 确保版本化目录存在
create_versioned_directories "$VERSION"

# 创建新PRD版本目录
create_new_prd_version "$NEW_PRD_VERSION"

# 执行命令
case "$command" in
    "generate")
        if [[ -z "$phase" ]]; then
            echo "[错误] generate命令需要指定阶段参数 (P0, P1, P2)"
            exit 1
        fi
        if [[ ! "$phase" =~ ^P[0-2]$ ]]; then
            echo "[错误] 无效的阶段参数: $phase，应为 P0, P1, P2"
            exit 1
        fi
        generate_prd_analysis_phase "$phase"
        ;;
    "all")
        generate_all_phases
        ;;
    "progress")
        show_progress
        ;;
    "clean")
        if [[ -z "$phase" ]]; then
            echo "[错误] clean命令需要指定阶段参数 (P0, P1, P2)"
            exit 1
        fi
        clean_progress "$phase"
        ;;
    "clean-all")
        clean_all_progress
        ;;
    *)
        echo "[错误] 未知命令: $command"
        echo "使用 '$0' 查看帮助信息"
        exit 1
        ;;
esac
