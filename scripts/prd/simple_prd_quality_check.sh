#!/usr/bin/env bash
set -e

# 简化版PRD质量检查脚本
# 专注于核心质量指标的快速评估

# 日志函数
log_info() { echo "[$(date '+%H:%M:%S')] [INFO] $*"; }
log_warn() { echo "[$(date '+%H:%M:%S')] [WARN] $*" >&2; }
log_error() { echo "[$(date '+%H:%M:%S')] [ERROR] $*" >&2; }

# 检查PRD文档质量
check_prd_quality() {
    local prd_file="$1"
    local module_id
    module_id=$(basename "$prd_file" .md | sed 's/.*REQ-\([0-9]\+\).*/REQ-\1/')
    
    if [[ ! -f "$prd_file" ]]; then
        log_error "PRD文件不存在: $prd_file"
        return 1
    fi
    
    log_info "开始检查PRD文档: $prd_file"
    
    local total_score=0
    local max_score=500  # 5个维度，每个100分
    
    # 1. 检查文档结构完整性 (100分)
    log_info "检查文档结构完整性..."
    local structure_score=0
    local required_sections=(
        "# REQ-[0-9]+ -"
        "## 文档信息"
        "## 1\. 模块概述"
        "## 2\. 功能需求"
        "## 3\. 技术架构设计"
        "## 4\. 实现指导"
        "## 5\. 质量要求"
        "## 6\. 验收标准"
    )
    
    local found_sections=0
    for section in "${required_sections[@]}"; do
        if grep -q "$section" "$prd_file"; then
            found_sections=$((found_sections + 1))
        else
            log_warn "缺失章节: $section"
        fi
    done
    structure_score=$(( found_sections * 100 / ${#required_sections[@]} ))
    log_info "文档结构评分: $structure_score/100"
    total_score=$((total_score + structure_score))
    
    # 2. 检查技术内容完整性 (100分)
    log_info "检查技术内容完整性..."
    local tech_score=0
    local tech_keywords=(
        "Spring Boot"
        "Vue\.js"
        "API"
        "数据模型"
        "接口设计"
        "多租户"
        "权限控制"
        "性能要求"
        "安全要求"
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
    log_info "技术内容评分: $tech_score/100"
    total_score=$((total_score + tech_score))
    
    # 3. 检查内容丰富度 (100分)
    log_info "检查内容丰富度..."
    local content_score=100
    local word_count
    word_count=$(wc -w < "$prd_file")
    
    if [[ $word_count -lt 1000 ]]; then
        content_score=30
        log_warn "内容过少: $word_count 词，建议至少1000词"
    elif [[ $word_count -lt 2000 ]]; then
        content_score=60
        log_warn "内容较少: $word_count 词，建议至少2000词"
    elif [[ $word_count -lt 3000 ]]; then
        content_score=80
        log_info "内容适中: $word_count 词"
    else
        content_score=100
        log_info "内容丰富: $word_count 词"
    fi
    total_score=$((total_score + content_score))
    
    # 4. 检查AI可解析性 (100分)
    log_info "检查AI可解析性..."
    local ai_score=100
    
    # 检查Markdown格式
    if ! grep -q "^#" "$prd_file"; then
        ai_score=$((ai_score - 20))
        log_warn "缺少标准的Markdown标题格式"
    fi
    
    # 检查列表格式
    if ! grep -q "^-\|^[0-9]\+\." "$prd_file"; then
        ai_score=$((ai_score - 15))
        log_warn "缺少列表格式，影响结构化解析"
    fi
    
    # 检查表格格式
    if ! grep -q "|" "$prd_file"; then
        ai_score=$((ai_score - 10))
        log_warn "建议使用表格格式展示结构化数据"
    fi
    
    # 检查代码块格式
    if grep -q '```' "$prd_file"; then
        log_info "包含代码块格式，有助于AI理解"
    else
        ai_score=$((ai_score - 10))
        log_warn "缺少代码块格式，建议添加示例代码"
    fi
    
    log_info "AI可解析性评分: $ai_score/100"
    total_score=$((total_score + ai_score))
    
    # 5. 检查实施指导性 (100分)
    log_info "检查实施指导性..."
    local guidance_score=0
    local guidance_keywords=(
        "开发指导\|实现指导\|开发步骤"
        "配置\|部署"
        "最佳实践\|注意事项\|建议"
        "异常\|错误\|异常处理"
        "测试\|验证"
    )
    
    local found_guidance=0
    for keyword in "${guidance_keywords[@]}"; do
        if grep -q "$keyword" "$prd_file"; then
            found_guidance=$((found_guidance + 1))
        fi
    done
    guidance_score=$(( found_guidance * 100 / ${#guidance_keywords[@]} ))
    log_info "实施指导性评分: $guidance_score/100"
    total_score=$((total_score + guidance_score))
    
    # 计算最终评分
    local final_score=$((total_score * 100 / max_score))
    
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
    echo "PRD质量评估报告 - $module_id"
    echo "=========================================="
    echo "文档路径: $prd_file"
    echo "评估时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "评分详情:"
    echo "  文档结构完整性: $structure_score/100"
    echo "  技术内容完整性: $tech_score/100"
    echo "  内容丰富度:     $content_score/100"
    echo "  AI可解析性:     $ai_score/100"
    echo "  实施指导性:     $guidance_score/100"
    echo ""
    echo "综合评分: $final_score/100"
    echo "质量等级: $quality_level"
    echo ""
    
    # 提供改进建议
    echo "改进建议:"
    if [[ $structure_score -lt 80 ]]; then
        echo "  - 补充缺失的文档章节，确保结构完整"
    fi
    if [[ $tech_score -lt 80 ]]; then
        echo "  - 增加技术细节描述，包括具体的技术栈和实现方案"
    fi
    if [[ $content_score -lt 80 ]]; then
        echo "  - 丰富文档内容，提供更详细的需求描述和技术规范"
    fi
    if [[ $ai_score -lt 80 ]]; then
        echo "  - 改进文档格式，使用更多结构化元素（表格、列表、代码块）"
    fi
    if [[ $guidance_score -lt 80 ]]; then
        echo "  - 增加实施指导内容，包括开发步骤、配置要求、测试方法"
    fi
    
    if [[ $final_score -ge 80 ]]; then
        echo "  - 文档质量良好，可以直接用于AI开发助手"
    else
        echo "  - 建议根据以上建议进行改进后再使用"
    fi
    
    echo "=========================================="
    
    return 0
}

# 主函数
main() {
    local target="$1"
    
    if [[ -z "$target" ]]; then
        echo "用法: $0 <PRD文件路径>"
        echo ""
        echo "示例:"
        echo "  $0 docs/output/prd/4.5.1/test-prd-REQ-003.md"
        exit 1
    fi
    
    if [[ ! -f "$target" ]]; then
        log_error "指定的PRD文件不存在: $target"
        exit 1
    fi
    
    check_prd_quality "$target"
}

# 执行主函数
main "$@"
