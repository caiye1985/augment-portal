#!/usr/bin/env bash
set -e

# 检查bash版本，确保支持关联数组
if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    echo "[错误] 需要 Bash 4.0 或更高版本来支持关联数组" >&2
    exit 1
fi

# PRD 质量验证脚本
# 用于验证生成的 PRD 文档质量

# 导入版本工具
source "$(dirname "$0")/version_utils.sh"

# 检测版本并设置路径
VERSION=$(detect_prd_version)
if [[ $? -ne 0 ]]; then
    echo "[错误] 无法检测PRD版本号" >&2
    exit 1
fi

# 设置路径
SCRIPT_DIR="$(dirname "$0")"
PRD_DIR="docs/output/prd/$VERSION"
QUALITY_DIR="$PRD_DIR/quality"

# 创建质量报告目录
mkdir -p "$QUALITY_DIR"

# 日志函数
log_info() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*"; }
log_warn() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" >&2; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; }

# 质量评估指标（使用普通变量替代关联数组）
content_completeness_score=0
technical_feasibility_score=0
document_standards_score=0
ai_parsability_score=0
implementation_guidance_score=0
total_score=0

# 问题列表
p0_issues=()
p1_issues=()
p2_issues=()

# 初始化质量评估
init_quality_assessment() {
    content_completeness_score=0
    technical_feasibility_score=0
    document_standards_score=0
    ai_parsability_score=0
    implementation_guidance_score=0
    total_score=0

    p0_issues=()
    p1_issues=()
    p2_issues=()
}

# 检查文档结构完整性
check_document_structure() {
    local prd_file="$1"
    local score=0
    local issues=()
    
    log_info "检查文档结构: $(basename "$prd_file")"
    
    # 检查必需章节
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
            issues+=("缺失必需章节: $section")
        fi
    done
    
    # 计算结构完整性得分
    score=$(( found_sections * 100 / ${#required_sections[@]} ))
    
    # 检查内容充实度
    local word_count
    word_count=$(wc -w < "$prd_file")
    if [[ $word_count -lt 2000 ]]; then
        issues+=("文档内容过少: $word_count 词，建议至少 2000 词")
        score=$((score - 10))
    fi
    
    document_standards_score=$score

    # 记录问题
    for issue in "${issues[@]}"; do
        if [[ $score -lt 70 ]]; then
            p0_issues+=("$issue")
        elif [[ $score -lt 85 ]]; then
            p1_issues+=("$issue")
        else
            p2_issues+=("$issue")
        fi
    done
    
    log_info "文档结构评分: $score/100"
}

# 检查技术内容完整性
check_technical_content() {
    local prd_file="$1"
    local score=0
    local issues=()
    
    log_info "检查技术内容完整性"
    
    # 检查技术关键词
    local technical_keywords=(
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
    for keyword in "${technical_keywords[@]}"; do
        if grep -q "$keyword" "$prd_file"; then
            found_keywords=$((found_keywords + 1))
        else
            issues+=("缺失技术关键词: $keyword")
        fi
    done
    
    score=$(( found_keywords * 100 / ${#technical_keywords[@]} ))
    
    # 检查代码示例
    if ! grep -q '```' "$prd_file"; then
        issues+=("缺少代码示例或配置示例")
        score=$((score - 15))
    fi
    
    # 检查API接口定义
    if ! grep -q "/api/v1" "$prd_file"; then
        issues+=("缺少API接口路径定义")
        score=$((score - 10))
    fi
    
    quality_scores[technical_feasibility]=$score
    
    # 记录问题
    for issue in "${issues[@]}"; do
        if [[ $score -lt 70 ]]; then
            quality_issues[p0]+=("$issue")
        elif [[ $score -lt 85 ]]; then
            quality_issues[p1]+=("$issue")
        else
            quality_issues[p2]+=("$issue")
        fi
    done
    
    log_info "技术内容评分: $score/100"
}

# 检查内容完整性
check_content_completeness() {
    local prd_file="$1"
    local score=0
    local issues=()
    
    log_info "检查内容完整性"
    
    # 检查功能需求表
    if grep -q "功能需求表" "$prd_file" || grep -q "功能需求规格" "$prd_file"; then
        score=$((score + 20))
    else
        issues+=("缺少功能需求表或功能需求规格")
    fi
    
    # 检查数据模型
    if grep -q "数据模型" "$prd_file" || grep -q "实体关系" "$prd_file"; then
        score=$((score + 20))
    else
        issues+=("缺少数据模型定义")
    fi
    
    # 检查业务流程
    if grep -q "业务流程" "$prd_file" || grep -q "工作流程" "$prd_file"; then
        score=$((score + 15))
    else
        issues+=("缺少业务流程描述")
    fi
    
    # 检查验收标准
    if grep -q "验收标准" "$prd_file" || grep -q "测试场景" "$prd_file"; then
        score=$((score + 15))
    else
        issues+=("缺少验收标准定义")
    fi
    
    # 检查性能指标
    if grep -q "性能" "$prd_file" && grep -q "指标" "$prd_file"; then
        score=$((score + 15))
    else
        issues+=("缺少具体的性能指标")
    fi
    
    # 检查安全要求
    if grep -q "安全" "$prd_file" && grep -q "权限" "$prd_file"; then
        score=$((score + 15))
    else
        issues+=("缺少安全要求描述")
    fi
    
    quality_scores[content_completeness]=$score
    
    # 记录问题
    for issue in "${issues[@]}"; do
        if [[ $score -lt 70 ]]; then
            quality_issues[p0]+=("$issue")
        elif [[ $score -lt 85 ]]; then
            quality_issues[p1]+=("$issue")
        else
            quality_issues[p2]+=("$issue")
        fi
    done
    
    log_info "内容完整性评分: $score/100"
}

# 检查AI可解析性
check_ai_parsability() {
    local prd_file="$1"
    local score=100
    local issues=()
    
    log_info "检查AI可解析性"
    
    # 检查Markdown格式规范
    if ! grep -q "^#" "$prd_file"; then
        issues+=("缺少标准的Markdown标题格式")
        score=$((score - 20))
    fi
    
    # 检查列表格式
    if ! grep -q "^-\|^[0-9]\+\." "$prd_file"; then
        issues+=("缺少列表格式，影响结构化解析")
        score=$((score - 15))
    fi
    
    # 检查表格格式
    if ! grep -q "|" "$prd_file"; then
        issues+=("建议使用表格格式展示结构化数据")
        score=$((score - 10))
    fi
    
    # 检查代码块格式
    if grep -q '```' "$prd_file"; then
        score=$((score + 5))  # 奖励分
    else
        issues+=("缺少代码块格式，建议添加示例代码")
        score=$((score - 10))
    fi
    
    quality_scores[ai_parsability]=$score
    
    # 记录问题
    for issue in "${issues[@]}"; do
        if [[ $score -lt 70 ]]; then
            quality_issues[p0]+=("$issue")
        elif [[ $score -lt 85 ]]; then
            quality_issues[p1]+=("$issue")
        else
            quality_issues[p2]+=("$issue")
        fi
    done
    
    log_info "AI可解析性评分: $score/100"
}

# 检查实施指导性
check_implementation_guidance() {
    local prd_file="$1"
    local score=0
    local issues=()
    
    log_info "检查实施指导性"
    
    # 检查开发指导
    if grep -q "开发指导\|实现指导\|开发步骤" "$prd_file"; then
        score=$((score + 25))
    else
        issues+=("缺少开发指导或实现指导")
    fi
    
    # 检查配置要求
    if grep -q "配置\|部署" "$prd_file"; then
        score=$((score + 20))
    else
        issues+=("缺少配置或部署要求")
    fi
    
    # 检查最佳实践
    if grep -q "最佳实践\|注意事项\|建议" "$prd_file"; then
        score=$((score + 20))
    else
        issues+=("缺少最佳实践指导")
    fi
    
    # 检查错误处理
    if grep -q "异常\|错误\|异常处理" "$prd_file"; then
        score=$((score + 20))
    else
        issues+=("缺少异常处理指导")
    fi
    
    # 检查测试指导
    if grep -q "测试\|验证" "$prd_file"; then
        score=$((score + 15))
    else
        issues+=("缺少测试指导")
    fi
    
    quality_scores[implementation_guidance]=$score
    
    # 记录问题
    for issue in "${issues[@]}"; do
        if [[ $score -lt 70 ]]; then
            quality_issues[p0]+=("$issue")
        elif [[ $score -lt 85 ]]; then
            quality_issues[p1]+=("$issue")
        else
            quality_issues[p2]+=("$issue")
        fi
    done
    
    log_info "实施指导性评分: $score/100"
}

# 计算总体评分
calculate_total_score() {
    local total=0
    local weights=(30 25 20 15 10)  # 对应各维度权重
    local scores=(
        ${quality_scores[content_completeness]}
        ${quality_scores[technical_feasibility]}
        ${quality_scores[document_standards]}
        ${quality_scores[ai_parsability]}
        ${quality_scores[implementation_guidance]}
    )
    
    for i in "${!scores[@]}"; do
        total=$((total + scores[i] * weights[i] / 100))
    done
    
    quality_scores[total]=$total
    
    log_info "总体评分: $total/100"
}

# 生成质量报告
generate_quality_report() {
    local prd_file="$1"
    local module_id="$2"
    local report_file="$QUALITY_DIR/quality-report-$module_id.md"
    
    log_info "生成质量报告: $report_file"
    
    # 确定质量等级
    local quality_level
    local total_score=${quality_scores[total]}
    if [[ $total_score -ge 90 ]]; then
        quality_level="优秀"
    elif [[ $total_score -ge 80 ]]; then
        quality_level="良好"
    elif [[ $total_score -ge 70 ]]; then
        quality_level="一般"
    elif [[ $total_score -ge 60 ]]; then
        quality_level="需改进"
    else
        quality_level="不合格"
    fi
    
    cat > "$report_file" << EOF
# PRD质量评估报告

## 文档信息
- **评估文档**: $module_id
- **评估版本**: $VERSION
- **评估日期**: $(date '+%Y-%m-%d %H:%M:%S')
- **评估类型**: PRD质量评估

## 1. 综合评分

### 1.1 总体评分
- **综合得分**: ${quality_scores[total]}/100
- **质量等级**: $quality_level

### 1.2 分维度评分
- **内容完整性**: ${quality_scores[content_completeness]}/100 (权重30%)
- **技术可行性**: ${quality_scores[technical_feasibility]}/100 (权重25%)
- **文档规范性**: ${quality_scores[document_standards]}/100 (权重20%)
- **AI可解析性**: ${quality_scores[ai_parsability]}/100 (权重15%)
- **实施指导性**: ${quality_scores[implementation_guidance]}/100 (权重10%)

## 2. 质量问题分析

### 2.1 P0级问题（必须修复）
EOF

    # 添加P0问题
    if [[ ${#quality_issues[p0][@]} -gt 0 ]]; then
        for issue in "${quality_issues[p0][@]}"; do
            echo "- $issue" >> "$report_file"
        done
    else
        echo "无P0级问题" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

### 2.2 P1级问题（重要改进）
EOF

    # 添加P1问题
    if [[ ${#quality_issues[p1][@]} -gt 0 ]]; then
        for issue in "${quality_issues[p1][@]}"; do
            echo "- $issue" >> "$report_file"
        done
    else
        echo "无P1级问题" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

### 2.3 P2级问题（优化建议）
EOF

    # 添加P2问题
    if [[ ${#quality_issues[p2][@]} -gt 0 ]]; then
        for issue in "${quality_issues[p2][@]}"; do
            echo "- $issue" >> "$report_file"
        done
    else
        echo "无P2级问题" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## 3. 改进建议

### 3.1 内容完整性改进
- 补充缺失的功能需求和技术规范
- 完善业务流程和数据模型描述
- 添加详细的验收标准和测试场景

### 3.2 技术可行性改进
- 确保技术方案与系统架构一致
- 补充具体的实现方案和配置要求
- 添加性能和安全的具体指标

### 3.3 文档规范性改进
- 统一文档格式和术语使用
- 完善章节结构和内容组织
- 添加必要的图表和示例

### 3.4 AI可解析性改进
- 使用标准化的Markdown格式
- 增加结构化的表格和列表
- 添加代码示例和配置示例

## 4. 质量控制建议

### 4.1 文档编写建议
- 遵循PRD文档编写规范
- 确保内容的完整性和准确性
- 注重技术细节的可实施性

### 4.2 质量检查建议
- 建立定期的质量检查机制
- 使用自动化工具进行格式检查
- 进行同行评审和专家评审

## 5. 总结

本次评估发现的主要问题集中在[根据实际情况总结]。建议优先处理P0级问题，然后逐步改进P1和P2级问题，以提升PRD文档的整体质量。
EOF

    log_info "质量报告生成完成"
}

# 验证单个PRD文件
validate_prd_file() {
    local prd_file="$1"
    local module_id
    module_id=$(basename "$prd_file" .md | sed 's/.*-\(REQ-[0-9]\+\).*/\1/')
    
    if [[ ! -f "$prd_file" ]]; then
        log_error "PRD文件不存在: $prd_file"
        return 1
    fi
    
    log_info "开始验证PRD文件: $prd_file"
    
    # 初始化质量评估
    init_quality_assessment
    
    # 执行各项检查
    check_document_structure "$prd_file"
    check_technical_content "$prd_file"
    check_content_completeness "$prd_file"
    check_ai_parsability "$prd_file"
    check_implementation_guidance "$prd_file"
    
    # 计算总体评分
    calculate_total_score
    
    # 生成质量报告
    generate_quality_report "$prd_file" "$module_id"
    
    log_info "PRD文件验证完成: ${quality_scores[total]}/100"
    
    return 0
}

# 主函数
main() {
    local target="$1"
    
    log_info "开始PRD质量验证"
    log_info "版本: $VERSION"
    log_info "质量报告目录: $QUALITY_DIR"
    
    if [[ -n "$target" ]]; then
        # 验证指定文件
        if [[ -f "$target" ]]; then
            validate_prd_file "$target"
        else
            log_error "指定的PRD文件不存在: $target"
            exit 1
        fi
    else
        # 验证所有PRD文件
        local prd_files
        mapfile -t prd_files < <(find "$PRD_DIR" -name "*.md" -type f | grep -E "REQ-[0-9]+" | sort)
        
        if [[ ${#prd_files[@]} -eq 0 ]]; then
            log_warn "未找到PRD文件，请先运行 gen_prd_complete.sh 生成PRD文档"
            exit 1
        fi
        
        log_info "找到 ${#prd_files[@]} 个PRD文件"
        
        local total_score=0
        local file_count=0
        
        for prd_file in "${prd_files[@]}"; do
            validate_prd_file "$prd_file"
            total_score=$((total_score + quality_scores[total]))
            file_count=$((file_count + 1))
        done
        
        # 计算平均分
        local average_score=$((total_score / file_count))
        log_info "所有PRD文件验证完成，平均分: $average_score/100"
        
        # 生成汇总报告
        local summary_file="$QUALITY_DIR/quality-summary.md"
        cat > "$summary_file" << EOF
# PRD质量验证汇总报告

## 验证信息
- **版本**: $VERSION
- **验证时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **验证文件数**: $file_count
- **平均得分**: $average_score/100

## 验证结果
$(find "$QUALITY_DIR" -name "quality-report-*.md" | sort | while read -r report; do
    module_id=$(basename "$report" | sed 's/quality-report-\(.*\)\.md/\1/')
    score=$(grep "综合得分" "$report" | sed 's/.*\([0-9]\+\)\/100.*/\1/')
    echo "- $module_id: $score/100"
done)

## 建议
- 重点关注得分低于70分的模块
- 优先处理P0级问题
- 建立持续的质量改进机制
EOF
        
        log_info "汇总报告生成完成: $summary_file"
    fi
    
    log_info "PRD质量验证完成"
}

# 参数检查和帮助信息
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "PRD质量验证脚本"
    echo ""
    echo "用法: $0 [PRD文件路径]"
    echo ""
    echo "功能:"
    echo "  - 验证PRD文档的质量"
    echo "  - 生成详细的质量报告"
    echo "  - 提供具体的改进建议"
    echo ""
    echo "参数:"
    echo "  PRD文件路径  可选，指定要验证的PRD文件"
    echo "              如果不指定，则验证所有PRD文件"
    echo ""
    echo "输出:"
    echo "  - 质量报告: docs/output/prd/$VERSION/quality/"
    echo ""
    exit 0
fi

# 执行主函数
main "$@"
