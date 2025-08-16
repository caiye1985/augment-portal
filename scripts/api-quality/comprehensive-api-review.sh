#!/bin/bash

# 综合 API 设计质量审查脚本
# 执行全面的 API 设计质量检验，包括规范验证、设计合理性、一致性检查等

set -e

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置
BASE_PATH="docs/api/4.5.1"
REPORTS_DIR="reports/api-review"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 创建报告目录
mkdir -p "$REPORTS_DIR"

echo -e "${CYAN}🚀 开始综合 API 设计质量审查${NC}"
echo -e "${CYAN}=================================================${NC}"
echo -e "📅 时间: $(date)"
echo -e "📁 基础路径: $BASE_PATH"
echo -e "📄 报告目录: $REPORTS_DIR"
echo ""

# 检查必要工具
check_tools() {
    echo -e "${BLUE}🔧 检查必要工具...${NC}"
    
    local missing_tools=()
    
    # 检查 Python
    if ! command -v python3 &> /dev/null; then
        missing_tools+=("python3")
    fi
    
    # 检查 swagger-cli
    if ! command -v swagger-cli &> /dev/null; then
        echo -e "${YELLOW}⚠️  swagger-cli 未安装，正在安装...${NC}"
        npm install -g @apidevtools/swagger-cli
    fi
    
    # 检查 PyYAML
    if ! python3 -c "import yaml" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  PyYAML 未安装，正在安装...${NC}"
        pip3 install PyYAML
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}❌ 缺少必要工具: ${missing_tools[*]}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ 所有必要工具已就绪${NC}"
}

# 1. OpenAPI 规范验证
validate_openapi_specs() {
    echo -e "\n${PURPLE}📋 1. OpenAPI 规范验证${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    local validation_report="$REPORTS_DIR/openapi_validation_$TIMESTAMP.txt"
    local failed_files=()
    
    # 验证模块文件
    echo "🔍 验证模块文件..."
    for module_dir in "$BASE_PATH/modules"/*; do
        if [ -d "$module_dir" ]; then
            openapi_file="$module_dir/openapi.yaml"
            if [ -f "$openapi_file" ]; then
                echo "  📄 验证: $openapi_file"
                if swagger-cli validate "$openapi_file" >> "$validation_report" 2>&1; then
                    echo -e "    ${GREEN}✅ 通过${NC}"
                else
                    echo -e "    ${RED}❌ 失败${NC}"
                    failed_files+=("$openapi_file")
                fi
            fi
        fi
    done
    
    # 验证域文件
    echo "🔍 验证域文件..."
    for domain_file in "$BASE_PATH/domains"/*.yaml; do
        if [ -f "$domain_file" ]; then
            echo "  📄 验证: $domain_file"
            if swagger-cli validate "$domain_file" >> "$validation_report" 2>&1; then
                echo -e "    ${GREEN}✅ 通过${NC}"
            else
                echo -e "    ${RED}❌ 失败${NC}"
                failed_files+=("$domain_file")
            fi
        fi
    done
    
    # 验证全局文件
    echo "🔍 验证全局文件..."
    global_file="$BASE_PATH/global-api-index.yaml"
    if [ -f "$global_file" ]; then
        echo "  📄 验证: $global_file"
        if swagger-cli validate "$global_file" >> "$validation_report" 2>&1; then
            echo -e "    ${GREEN}✅ 通过${NC}"
        else
            echo -e "    ${RED}❌ 失败${NC}"
            failed_files+=("$global_file")
        fi
    fi
    
    # 输出验证结果
    if [ ${#failed_files[@]} -eq 0 ]; then
        echo -e "${GREEN}🎉 所有 OpenAPI 规范验证通过！${NC}"
    else
        echo -e "${RED}❌ 发现 ${#failed_files[@]} 个文件验证失败:${NC}"
        for file in "${failed_files[@]}"; do
            echo -e "  ${RED}- $file${NC}"
        done
    fi
    
    echo "📄 详细验证报告: $validation_report"
}

# 2. 引用路径验证
validate_reference_paths() {
    echo -e "\n${PURPLE}📎 2. 引用路径验证${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    local ref_report="$REPORTS_DIR/reference_validation_$TIMESTAMP.json"
    
    echo "🔍 执行引用路径验证..."
    if python3 scripts/reference-path-validator.py \
        --base-path "$BASE_PATH" \
        --output "$ref_report" \
        --format json; then
        echo -e "${GREEN}✅ 引用路径验证完成${NC}"
    else
        echo -e "${RED}❌ 引用路径验证发现问题${NC}"
    fi
    
    echo "📄 引用路径验证报告: $ref_report"
}

# 3. API 设计质量检验
check_api_design_quality() {
    echo -e "\n${PURPLE}🎯 3. API 设计质量检验${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    local quality_report="$REPORTS_DIR/api_quality_$TIMESTAMP.json"
    
    echo "🔍 执行 API 设计质量检验..."
    if python3 scripts/api-quality-checker.py \
        --base-path "$BASE_PATH" \
        --output "$quality_report" \
        --format json; then
        echo -e "${GREEN}✅ API 设计质量检验完成${NC}"
    else
        echo -e "${YELLOW}⚠️  API 设计质量检验发现问题${NC}"
    fi
    
    echo "📄 API 设计质量报告: $quality_report"
}

# 4. Mock Server 兼容性测试
test_mock_server_compatibility() {
    echo -e "\n${PURPLE}🖥️  4. Mock Server 兼容性测试${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    local mock_report="$REPORTS_DIR/mock_server_test_$TIMESTAMP.txt"
    
    # 检查 prism 是否安装
    if ! command -v prism &> /dev/null; then
        echo -e "${YELLOW}⚠️  Prism CLI 未安装，跳过 Mock Server 测试${NC}"
        echo "💡 安装命令: npm install -g @stoplight/prism-cli"
        return 0
    fi
    
    echo "🔍 测试 Mock Server 兼容性..."
    
    # 测试模块文件
    echo "  📄 测试模块文件..."
    for module_dir in "$BASE_PATH/modules"/*; do
        if [ -d "$module_dir" ]; then
            openapi_file="$module_dir/openapi.yaml"
            if [ -f "$openapi_file" ]; then
                echo "    🧪 测试: $openapi_file"
                if timeout 10s prism mock "$openapi_file" --port 0 >> "$mock_report" 2>&1; then
                    echo -e "      ${GREEN}✅ 兼容${NC}"
                else
                    echo -e "      ${RED}❌ 不兼容${NC}"
                fi
            fi
        fi
    done
    
    # 测试全局文件
    echo "  📄 测试全局文件..."
    global_file="$BASE_PATH/global-api-index.yaml"
    if [ -f "$global_file" ]; then
        echo "    🧪 测试: $global_file"
        if timeout 10s prism mock "$global_file" --port 0 >> "$mock_report" 2>&1; then
            echo -e "      ${GREEN}✅ 兼容${NC}"
        else
            echo -e "      ${RED}❌ 不兼容${NC}"
        fi
    fi
    
    echo "📄 Mock Server 测试报告: $mock_report"
}

# 5. 生成综合报告
generate_comprehensive_report() {
    echo -e "\n${PURPLE}📊 5. 生成综合报告${NC}"
    echo -e "${PURPLE}================================${NC}"
    
    local comprehensive_report="$REPORTS_DIR/comprehensive_report_$TIMESTAMP.md"
    
    cat > "$comprehensive_report" << EOF
# API 设计质量审查综合报告

**审查时间**: $(date)  
**审查范围**: $BASE_PATH  
**报告生成**: $TIMESTAMP  

## 审查概览

本次审查涵盖以下几个方面：

1. **OpenAPI 规范验证** - 验证所有 API 文档是否符合 OpenAPI 3.0.3 规范
2. **引用路径验证** - 检查所有 \$ref 引用路径是否正确可解析
3. **API 设计质量检验** - 评估 RESTful 设计、命名一致性、响应格式等
4. **Mock Server 兼容性测试** - 验证 API 文档与 Mock Server 的兼容性

## 审查结果

### 1. OpenAPI 规范验证
EOF

    # 添加 OpenAPI 验证结果
    if [ -f "$REPORTS_DIR/openapi_validation_$TIMESTAMP.txt" ]; then
        echo "详见: [OpenAPI 验证报告](openapi_validation_$TIMESTAMP.txt)" >> "$comprehensive_report"
    fi

    cat >> "$comprehensive_report" << EOF

### 2. 引用路径验证
EOF

    # 添加引用路径验证结果
    if [ -f "$REPORTS_DIR/reference_validation_$TIMESTAMP.json" ]; then
        echo "详见: [引用路径验证报告](reference_validation_$TIMESTAMP.json)" >> "$comprehensive_report"
    fi

    cat >> "$comprehensive_report" << EOF

### 3. API 设计质量检验
EOF

    # 添加质量检验结果
    if [ -f "$REPORTS_DIR/api_quality_$TIMESTAMP.json" ]; then
        echo "详见: [API 设计质量报告](api_quality_$TIMESTAMP.json)" >> "$comprehensive_report"
    fi

    cat >> "$comprehensive_report" << EOF

### 4. Mock Server 兼容性测试
EOF

    # 添加 Mock Server 测试结果
    if [ -f "$REPORTS_DIR/mock_server_test_$TIMESTAMP.txt" ]; then
        echo "详见: [Mock Server 测试报告](mock_server_test_$TIMESTAMP.txt)" >> "$comprehensive_report"
    fi

    cat >> "$comprehensive_report" << EOF

## 建议和后续行动

基于本次审查结果，建议：

1. **优先修复错误级别问题** - 确保所有 API 规范验证通过
2. **解决引用路径问题** - 修复所有无效的 \$ref 引用
3. **改进设计一致性** - 统一命名规范和响应格式
4. **优化 Mock 数据质量** - 使用更真实的业务示例数据

## 工具和命令

### 重新运行审查
\`\`\`bash
./scripts/comprehensive-api-review.sh
\`\`\`

### 单独运行各项检查
\`\`\`bash
# OpenAPI 规范验证
swagger-cli validate docs/api/4.5.1/modules/*/openapi.yaml

# 引用路径验证
python3 scripts/reference-path-validator.py --base-path docs/api/4.5.1

# API 设计质量检验
python3 scripts/api-quality-checker.py --base-path docs/api/4.5.1

# Mock Server 测试
prism mock docs/api/4.5.1/global-api-index.yaml
\`\`\`

---
*报告生成时间: $(date)*
EOF

    echo -e "${GREEN}📄 综合报告已生成: $comprehensive_report${NC}"
}

# 主执行流程
main() {
    # 检查工具
    check_tools
    
    # 执行各项检查
    validate_openapi_specs
    validate_reference_paths
    check_api_design_quality
    test_mock_server_compatibility
    
    # 生成综合报告
    generate_comprehensive_report
    
    echo -e "\n${CYAN}🎉 API 设计质量审查完成！${NC}"
    echo -e "${CYAN}=================================================${NC}"
    echo -e "📁 所有报告保存在: $REPORTS_DIR"
    echo -e "📊 查看综合报告: $REPORTS_DIR/comprehensive_report_$TIMESTAMP.md"
    echo ""
    echo -e "${BLUE}💡 后续建议:${NC}"
    echo -e "1. 查看各项检查报告，优先修复错误级别问题"
    echo -e "2. 改进警告级别问题，提升 API 设计质量"
    echo -e "3. 定期运行此审查脚本，确保 API 质量"
    echo ""
}

# 执行主函数
main "$@"
