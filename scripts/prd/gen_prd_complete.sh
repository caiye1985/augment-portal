#!/usr/bin/env bash
set -e

# PRD 完整生成脚本
# 用于生成所有模块的 PRD 文档，包括前后端模块和移动端模块

# 导入版本工具
source "$(dirname "$0")/../utils/version_utils.sh"

# 检测版本并设置路径
VERSION=$(detect_prd_version)
if [[ $? -ne 0 ]]; then
    echo "[错误] 无法检测PRD版本号" >&2
    exit 1
fi

# 设置路径
SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="docs/output/prd/$VERSION"
QUALITY_DIR="$OUTPUT_DIR/quality"
MOBILE_DIR="$OUTPUT_DIR/mobile"
MODULES_DIR="$OUTPUT_DIR/modules"

# 创建输出目录
mkdir -p "$OUTPUT_DIR" "$QUALITY_DIR" "$MOBILE_DIR" "$MODULES_DIR"

# 日志函数
log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*"; }
log_warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" >&2; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; }

# 进度跟踪
TOTAL_MODULES=0
COMPLETED_MODULES=0
FAILED_MODULES=0

# 统计模块总数
count_modules() {
    local total=0
    for phase in P0 P1 P2; do
        local list_file="$SCRIPT_DIR/utils/module_list_${phase}.txt"
        if [[ -f "$list_file" ]]; then
            local count
            count=$(wc -l < "$list_file" | tr -d ' ')
            total=$((total + count))
        fi
    done
    echo "$total"
}

# 生成单个模块的 PRD
generate_module_prd() {
    local module_id="$1"
    local phase="$2"
    
    log_info "开始生成模块 $module_id 的 PRD..."
    
    # 检查是否为移动端模块
    if [[ "$module_id" == "REQ-020" ]]; then
        log_info "检测到移动端模块，使用移动端专用模板"
        if bash "$SCRIPT_DIR/prd/gen_iter_prompt.sh" prd-mobile "$phase"; then
            log_info "移动端模块 $module_id PRD 生成成功"
            return 0
        else
            log_error "移动端模块 $module_id PRD 生成失败"
            return 1
        fi
    else
        # 普通模块使用通用 PRD 模板
        if bash "$SCRIPT_DIR/prd/gen_iter_prompt.sh" prd "$phase"; then
            log_info "模块 $module_id PRD 生成成功"
            return 0
        else
            log_error "模块 $module_id PRD 生成失败"
            return 1
        fi
    fi
}

# 生成质量检查报告
generate_quality_report() {
    local phase="$1"
    
    log_info "开始生成阶段 $phase 的质量检查报告..."
    
    if bash "$SCRIPT_DIR/prd/gen_iter_prompt.sh" prd-quality "$phase"; then
        log_info "阶段 $phase 质量检查报告生成成功"
        return 0
    else
        log_error "阶段 $phase 质量检查报告生成失败"
        return 1
    fi
}

# 处理单个阶段
process_phase() {
    local phase="$1"
    local list_file="$SCRIPT_DIR/utils/module_list_${phase}.txt"
    
    if [[ ! -f "$list_file" ]]; then
        log_warn "模块列表文件不存在: $list_file，跳过阶段 $phase"
        return 0
    fi
    
    log_info "开始处理阶段: $phase"
    
    local phase_modules=0
    local phase_completed=0
    local phase_failed=0
    
    # 统计阶段模块数
    phase_modules=$(wc -l < "$list_file" | tr -d ' ')
    log_info "阶段 $phase 共有 $phase_modules 个模块"
    
    # 处理每个模块
    while IFS= read -r line; do
        local module_id path
        read module_id path <<< "$line"
        
        if [[ -n "$module_id" ]]; then
            if generate_module_prd "$module_id" "$phase"; then
                phase_completed=$((phase_completed + 1))
                COMPLETED_MODULES=$((COMPLETED_MODULES + 1))
            else
                phase_failed=$((phase_failed + 1))
                FAILED_MODULES=$((FAILED_MODULES + 1))
            fi
            
            # 显示进度
            local progress=$((COMPLETED_MODULES + FAILED_MODULES))
            log_info "总体进度: $progress/$TOTAL_MODULES (已完成: $COMPLETED_MODULES, 失败: $FAILED_MODULES)"
        fi
    done < "$list_file"
    
    log_info "阶段 $phase 处理完成: 成功 $phase_completed, 失败 $phase_failed"
    
    # 生成阶段质量检查报告
    if ! generate_quality_report "$phase"; then
        log_warn "阶段 $phase 质量检查报告生成失败"
    fi
}

# 生成汇总报告
generate_summary_report() {
    local summary_file="$OUTPUT_DIR/generation-summary.md"
    
    log_info "生成汇总报告: $summary_file"
    
    cat > "$summary_file" << EOF
# PRD 生成汇总报告

## 生成信息
- **版本**: $VERSION
- **生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **生成脚本**: gen_prd_complete.sh

## 生成统计
- **总模块数**: $TOTAL_MODULES
- **成功生成**: $COMPLETED_MODULES
- **生成失败**: $FAILED_MODULES
- **成功率**: $(( COMPLETED_MODULES * 100 / TOTAL_MODULES ))%

## 输出目录
- **PRD 文档**: $MODULES_DIR
- **移动端 PRD**: $MOBILE_DIR
- **质量报告**: $QUALITY_DIR

## 生成详情
EOF

    # 添加各阶段详情
    for phase in P0 P1 P2; do
        local list_file="$SCRIPT_DIR/utils/module_list_${phase}.txt"
        if [[ -f "$list_file" ]]; then
            echo "" >> "$summary_file"
            echo "### 阶段 $phase" >> "$summary_file"
            while IFS= read -r line; do
                local module_id path
                read module_id path <<< "$line"
                if [[ -n "$module_id" ]]; then
                    echo "- $module_id" >> "$summary_file"
                fi
            done < "$list_file"
        fi
    done
    
    log_info "汇总报告生成完成"
}

# 主函数
main() {
    log_info "开始 PRD 完整生成流程"
    log_info "版本: $VERSION"
    log_info "输出目录: $OUTPUT_DIR"
    
    # 统计总模块数
    TOTAL_MODULES=$(count_modules)
    log_info "总共需要处理 $TOTAL_MODULES 个模块"
    
    # 检查模块列表文件
    if [[ ! -f "$SCRIPT_DIR/utils/module_list_P0.txt" ]]; then
        log_info "模块列表文件不存在，正在生成..."
        bash "$SCRIPT_DIR/gen_module_list.sh"
    fi
    
    # 处理各个阶段
    for phase in P0 P1 P2; do
        process_phase "$phase"
    done
    
    # 生成汇总报告
    generate_summary_report
    
    # 最终统计
    log_info "PRD 生成流程完成"
    log_info "总计: $TOTAL_MODULES 个模块, 成功: $COMPLETED_MODULES, 失败: $FAILED_MODULES"
    
    if [[ $FAILED_MODULES -gt 0 ]]; then
        log_warn "有 $FAILED_MODULES 个模块生成失败，请检查日志"
        exit 1
    else
        log_info "所有模块 PRD 生成成功！"
        exit 0
    fi
}

# 参数检查和帮助信息
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "PRD 完整生成脚本"
    echo ""
    echo "用法: $0"
    echo ""
    echo "功能:"
    echo "  - 生成所有前后端模块的 PRD 文档"
    echo "  - 特殊处理移动端模块 (REQ-020)"
    echo "  - 生成质量检查报告"
    echo "  - 生成汇总报告"
    echo ""
    echo "输出目录:"
    echo "  - docs/output/prd/$VERSION/modules/  # 模块 PRD"
    echo "  - docs/output/prd/$VERSION/mobile/   # 移动端 PRD"
    echo "  - docs/output/prd/$VERSION/quality/  # 质量报告"
    echo ""
    echo "注意:"
    echo "  - 脚本会自动检测版本号"
    echo "  - 支持中断和恢复"
    echo "  - 生成过程中会显示详细进度"
    exit 0
fi

# 执行主函数
main "$@"
