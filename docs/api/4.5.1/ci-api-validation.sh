#!/bin/bash
# CI/CD API文档质量保证脚本
# 用于在持续集成流程中自动检查API文档的完整性和一致性

set -e  # 遇到错误立即退出

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DOC_DIR="${SCRIPT_DIR}"
REPORT_DIR="${API_DOC_DIR}/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORT_DIR}/api_validation_${TIMESTAMP}.json"
SUMMARY_FILE="${REPORT_DIR}/validation_summary.txt"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 创建报告目录
create_report_dir() {
    if [ ! -d "$REPORT_DIR" ]; then
        mkdir -p "$REPORT_DIR"
        log_info "创建报告目录: $REPORT_DIR"
    fi
}

# 检查Python环境
check_python_env() {
    log_info "检查Python环境..."
    
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装"
        exit 1
    fi
    
    # 检查必需的Python包
    python3 -c "import yaml, json" 2>/dev/null || {
        log_error "缺少必需的Python包: pyyaml"
        log_info "请运行: pip install pyyaml"
        exit 1
    }
    
    log_success "Python环境检查通过"
}

# 运行基础验证
run_basic_validation() {
    log_info "运行基础API文档验证..."
    
    cd "$API_DOC_DIR"
    
    if [ -f "validate-api.py" ]; then
        if python3 validate-api.py; then
            log_success "基础验证通过"
            return 0
        else
            log_error "基础验证失败"
            return 1
        fi
    else
        log_warning "基础验证脚本不存在，跳过基础验证"
        return 0
    fi
}

# 运行增强验证
run_enhanced_validation() {
    log_info "运行三级API文档质量保证验证..."
    
    cd "$API_DOC_DIR"
    
    if [ ! -f "enhanced-api-validator.py" ]; then
        log_error "增强验证脚本不存在: enhanced-api-validator.py"
        return 1
    fi
    
    # 运行增强验证并生成报告
    if python3 enhanced-api-validator.py --output "$REPORT_FILE"; then
        log_success "增强验证通过"
        
        # 生成简要摘要
        generate_summary_report
        return 0
    else
        log_error "增强验证失败"
        
        # 即使失败也生成报告用于分析
        python3 enhanced-api-validator.py --output "$REPORT_FILE" || true
        generate_summary_report
        return 1
    fi
}

# 生成摘要报告
generate_summary_report() {
    log_info "生成验证摘要报告..."
    
    if [ ! -f "$REPORT_FILE" ]; then
        log_warning "报告文件不存在，无法生成摘要"
        return 1
    fi
    
    # 使用Python解析JSON报告并生成摘要
    python3 << EOF > "$SUMMARY_FILE"
import json
import sys

try:
    with open('$REPORT_FILE', 'r', encoding='utf-8') as f:
        report = json.load(f)
    
    print("=" * 60)
    print("API文档质量保证验证摘要报告")
    print("=" * 60)
    print(f"验证时间: $TIMESTAMP")
    print()
    
    # 基本统计
    summary = report.get('summary', {})
    print("📊 基本统计:")
    print(f"   模块文件数量: {summary.get('total_modules', 0)}")
    print(f"   业务域文件数量: {summary.get('total_domains', 0)}")
    print(f"   全局索引API数量: {summary.get('total_global_apis', 0)}")
    print(f"   映射覆盖率: {summary.get('mapping_coverage_rate', 0):.1%}")
    print()
    
    # 验证结果
    validation_results = report.get('validation_results', [])
    if validation_results:
        print("🔍 验证结果:")
        for i, result in enumerate(validation_results, 1):
            status = "✅" if result['success'] else "❌"
            print(f"   {i}. {status} {result['message']}")
        print()
    
    # 问题统计
    total_issues = sum(len(result.get('details', [])) for result in validation_results if not result['success'])
    if total_issues > 0:
        print(f"⚠️  发现 {total_issues} 个问题需要修复")
    else:
        print("🎉 所有检查通过，API文档架构完整！")
    
    print("=" * 60)
    
except Exception as e:
    print(f"生成摘要报告失败: {e}", file=sys.stderr)
    sys.exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        log_success "摘要报告生成完成: $SUMMARY_FILE"
        
        # 显示摘要内容
        echo
        cat "$SUMMARY_FILE"
        echo
    else
        log_error "摘要报告生成失败"
        return 1
    fi
}

# 检查Git变更
check_git_changes() {
    log_info "检查API文档相关的Git变更..."
    
    if ! command -v git &> /dev/null; then
        log_warning "Git未安装，跳过变更检查"
        return 0
    fi
    
    # 检查是否在Git仓库中
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_warning "不在Git仓库中，跳过变更检查"
        return 0
    fi
    
    # 检查API文档相关文件的变更
    changed_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -E '\.(yaml|yml)$' | grep -E '(modules|domains|global-api-index)' || true)
    
    if [ -n "$changed_files" ]; then
        log_info "检测到API文档文件变更:"
        echo "$changed_files" | while read -r file; do
            echo "   - $file"
        done
        echo
        return 0
    else
        log_info "未检测到API文档文件变更"
        return 0
    fi
}

# 清理旧报告
cleanup_old_reports() {
    log_info "清理7天前的旧报告..."
    
    if [ -d "$REPORT_DIR" ]; then
        find "$REPORT_DIR" -name "api_validation_*.json" -mtime +7 -delete 2>/dev/null || true
        find "$REPORT_DIR" -name "validation_summary_*.txt" -mtime +7 -delete 2>/dev/null || true
        log_success "旧报告清理完成"
    fi
}

# 主函数
main() {
    log_info "开始CI/CD API文档质量保证检查..."
    echo
    
    # 创建必要目录
    create_report_dir
    
    # 检查环境
    check_python_env
    
    # 检查Git变更（可选）
    check_git_changes
    
    # 清理旧报告
    cleanup_old_reports
    
    # 运行验证
    basic_success=true
    enhanced_success=true
    
    # 基础验证
    if ! run_basic_validation; then
        basic_success=false
    fi
    
    echo
    
    # 增强验证
    if ! run_enhanced_validation; then
        enhanced_success=false
    fi
    
    echo
    
    # 最终结果
    if [ "$basic_success" = true ] && [ "$enhanced_success" = true ]; then
        log_success "所有API文档质量检查通过！"
        echo
        log_info "报告文件: $REPORT_FILE"
        log_info "摘要文件: $SUMMARY_FILE"
        exit 0
    else
        log_error "API文档质量检查失败！"
        echo
        log_info "详细报告: $REPORT_FILE"
        log_info "摘要报告: $SUMMARY_FILE"
        echo
        log_error "请修复上述问题后重新提交"
        exit 1
    fi
}

# 脚本入口
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
