#!/usr/bin/env bash
set -e

# AI专用PRD质量检查脚本
# 专门为AI开发助手优化的PRD文档质量评估

# 日志函数
log_info() { echo "[$(date '+%H:%M:%S')] [INFO] $*"; }
log_warn() { echo "[$(date '+%H:%M:%S')] [WARN] $*" >&2; }
log_error() { echo "[$(date '+%H:%M:%S')] [ERROR] $*" >&2; }

# 检查AI专用PRD文档质量
check_ai_prd_quality() {
    local prd_file="$1"
    local module_id
    module_id=$(basename "$prd_file" .md | sed 's/.*REQ-\([0-9]\+\).*/REQ-\1/')
    
    if [[ ! -f "$prd_file" ]]; then
        log_error "PRD文件不存在: $prd_file"
        return 1
    fi
    
    log_info "开始检查AI专用PRD文档: $prd_file"
    
    local total_score=0
    local max_score=500  # 5个维度，每个100分
    
    # 1. 检查技术内容完整性 (40%权重，100分)
    log_info "检查技术内容完整性..."
    local tech_score=0
    local tech_keywords=(
        "Spring Boot"
        "Vue\.js"
        "@Entity"
        "@RestController"
        "API"
        "数据模型"
        "接口设计"
        "多租户"
        "tenant_id"
    )
    
    local found_keywords=0
    for keyword in "${tech_keywords[@]}"; do
        if grep -q "$keyword" "$prd_file"; then
            found_keywords=$((found_keywords + 1))
        else
            log_warn "缺失技术关键词: $keyword"
        fi
    done
    tech_score=$(( found_keywords * 100 / ${#tech_keywords[@]} ))
    log_info "技术内容完整性评分: $tech_score/100"
    total_score=$((total_score + tech_score * 40 / 100))
    
    # 2. 检查AI可解析性 (30%权重，100分)
    log_info "检查AI可解析性..."
    local ai_score=100
    
    # 检查代码块数量
    local code_blocks
    code_blocks=$(grep -c '```' "$prd_file" || echo 0)
    if [[ $code_blocks -lt 6 ]]; then
        ai_score=$((ai_score - 20))
        log_warn "代码块数量不足: $code_blocks 个，建议至少6个"
    else
        log_info "代码块数量充足: $code_blocks 个"
    fi
    
    # 检查表格格式
    local table_count
    table_count=$(grep -c "|" "$prd_file" || echo 0)
    if [[ $table_count -lt 10 ]]; then
        ai_score=$((ai_score - 15))
        log_warn "表格使用不足，建议增加结构化表格"
    fi
    
    # 检查API接口定义
    if ! grep -q "/api/v1" "$prd_file"; then
        ai_score=$((ai_score - 15))
        log_warn "缺少API接口路径定义"
    fi
    
    # 检查实体类定义
    if ! grep -q "@Entity" "$prd_file"; then
        ai_score=$((ai_score - 10))
        log_warn "缺少JPA实体类定义"
    fi
    
    log_info "AI可解析性评分: $ai_score/100"
    total_score=$((total_score + ai_score * 30 / 100))
    
    # 3. 检查实施指导性 (20%权重，100分)
    log_info "检查实施指导性..."
    local guidance_score=0
    local guidance_keywords=(
        "开发步骤"
        "代码规范"
        "配置要求"
        "数据库设计"
        "CREATE TABLE"
    )
    
    local found_guidance=0
    for keyword in "${guidance_keywords[@]}"; do
        if grep -q "$keyword" "$prd_file"; then
            found_guidance=$((found_guidance + 1))
        fi
    done
    guidance_score=$(( found_guidance * 100 / ${#guidance_keywords[@]} ))
    log_info "实施指导性评分: $guidance_score/100"
    total_score=$((total_score + guidance_score * 20 / 100))
    
    # 4. 检查内容精简度 (10%权重，100分)
    log_info "检查内容精简度..."
    local concise_score=100
    local word_count
    word_count=$(wc -w < "$prd_file")
    
    # 检查是否包含非技术章节
    if grep -q "部署和运维\|风险控制\|验收标准" "$prd_file"; then
        concise_score=$((concise_score - 30))
        log_warn "包含非技术章节，建议移除"
    fi
    
    # 检查字数是否在合理范围
    if [[ $word_count -gt 3000 ]]; then
        concise_score=$((concise_score - 20))
        log_warn "内容过多: $word_count 词，建议控制在2500词内"
    elif [[ $word_count -lt 1500 ]]; then
        concise_score=$((concise_score - 10))
        log_warn "内容较少: $word_count 词，建议至少1500词"
    else
        log_info "内容长度适中: $word_count 词"
    fi
    
    log_info "内容精简度评分: $concise_score/100"
    total_score=$((total_score + concise_score * 10 / 100))
    
    # 计算最终评分
    local final_score=$total_score
    
    # 确定质量等级
    local quality_level
    if [[ $final_score -ge 90 ]]; then
        quality_level="优秀"
    elif [[ $final_score -ge 80 ]]; then
        quality_level="良好"
    elif [[ $final_score -ge 70 ]]; then
        quality_level="一般"
    elif [[ $final_score -ge 60 ]]; then
        quality_level="需改进"
    else
        quality_level="不合格"
    fi
    
    # 输出评估结果
    echo ""
    echo "=========================================="
    echo "AI专用PRD质量评估报告 - $module_id"
    echo "=========================================="
    echo "文档路径: $prd_file"
    echo "评估时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "文档字数: $word_count 词"
    echo ""
    echo "评分详情（AI专用标准）:"
    echo "  技术内容完整性: $tech_score/100 (权重40%)"
    echo "  AI可解析性:     $ai_score/100 (权重30%)"
    echo "  实施指导性:     $guidance_score/100 (权重20%)"
    echo "  内容精简度:     $concise_score/100 (权重10%)"
    echo ""
    echo "综合评分: $final_score/100"
    echo "质量等级: $quality_level"
    echo ""
    
    # 提供AI专用改进建议
    echo "AI开发助手适用性分析:"
    if [[ $tech_score -ge 80 && $ai_score -ge 80 ]]; then
        echo "  ✅ 技术内容完整，AI可直接使用"
    else
        echo "  ❌ 技术内容不足，需要补充"
    fi
    
    if [[ $code_blocks -ge 6 ]]; then
        echo "  ✅ 代码示例丰富，便于AI理解"
    else
        echo "  ❌ 代码示例不足，影响AI生成效果"
    fi
    
    if [[ $word_count -le 2500 ]]; then
        echo "  ✅ 内容精简，信息密度高"
    else
        echo "  ❌ 内容冗长，建议精简"
    fi
    
    echo ""
    echo "改进建议:"
    if [[ $tech_score -lt 80 ]]; then
        echo "  - 补充技术关键词：Spring Boot、Vue.js、@Entity、@RestController等"
        echo "  - 增加具体的技术实现细节和配置示例"
    fi
    if [[ $ai_score -lt 80 ]]; then
        echo "  - 增加代码块数量，提供更多实现示例"
        echo "  - 使用表格格式展示结构化信息"
        echo "  - 补充API接口和数据模型定义"
    fi
    if [[ $guidance_score -lt 80 ]]; then
        echo "  - 增加具体的开发步骤和实施指导"
        echo "  - 提供完整的数据库设计和配置要求"
    fi
    if [[ $concise_score -lt 80 ]]; then
        echo "  - 移除非技术章节（部署运维、风险控制等）"
        echo "  - 精简内容，专注技术实现"
    fi
    
    if [[ $final_score -ge 80 ]]; then
        echo "  ✅ 文档质量良好，可直接用于AI开发助手"
        echo "  ✅ 建议配合具体的开发任务使用"
    else
        echo "  ❌ 建议根据以上建议进行改进后再使用"
        echo "  ❌ 重点关注技术内容完整性和代码示例"
    fi
    
    echo "=========================================="
    
    return 0
}

# 主函数
main() {
    local target="$1"
    
    if [[ -z "$target" ]]; then
        echo "AI专用PRD质量检查脚本"
        echo ""
        echo "用法: $0 <PRD文件路径>"
        echo ""
        echo "功能:"
        echo "  - 专门评估AI开发助手使用的PRD文档质量"
        echo "  - 重点关注技术内容完整性和AI可解析性"
        echo "  - 提供针对性的改进建议"
        echo ""
        echo "评估标准:"
        echo "  - 技术内容完整性 (40%): Spring Boot、Vue.js、API设计等"
        echo "  - AI可解析性 (30%): 代码块、表格、结构化程度"
        echo "  - 实施指导性 (20%): 开发步骤、配置要求、数据库设计"
        echo "  - 内容精简度 (10%): 专注技术实现，避免冗余内容"
        echo ""
        echo "示例:"
        echo "  $0 docs/output/prd/4.5.1/test-prd-REQ-003-ai-focused.md"
        exit 1
    fi
    
    if [[ ! -f "$target" ]]; then
        log_error "指定的PRD文件不存在: $target"
        exit 1
    fi
    
    check_ai_prd_quality "$target"
}

# 执行主函数
main "$@"
