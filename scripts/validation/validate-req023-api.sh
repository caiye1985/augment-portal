#!/bin/bash

# REQ-023 数据分析与商业智能模块 API 验证脚本
# 用于验证OpenAPI规范的正确性和Mock Server兼容性

set -e

echo "🔍 开始验证 REQ-023 数据分析与商业智能模块 API..."

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 验证函数
validate_file() {
    local file_path=$1
    local description=$2
    
    echo -e "\n📋 验证 ${description}..."
    echo "文件路径: ${file_path}"
    
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}❌ 文件不存在: ${file_path}${NC}"
        return 1
    fi
    
    # 使用 swagger-cli 验证
    if swagger-cli validate "$file_path" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OpenAPI 规范验证通过${NC}"
    else
        echo -e "${RED}❌ OpenAPI 规范验证失败${NC}"
        swagger-cli validate "$file_path"
        return 1
    fi
    
    return 0
}

# 检查必要工具
check_tools() {
    echo "🔧 检查必要工具..."
    
    if ! command -v swagger-cli &> /dev/null; then
        echo -e "${YELLOW}⚠️  swagger-cli 未安装，正在安装...${NC}"
        npm install -g @apidevtools/swagger-cli
    else
        echo -e "${GREEN}✅ swagger-cli 已安装${NC}"
    fi
}

# 主验证流程
main() {
    echo "=================================================="
    echo "REQ-023 数据分析与商业智能模块 API 验证"
    echo "=================================================="
    
    # 检查工具
    check_tools
    
    # 验证模块 OpenAPI 文件
    validate_file "docs/api/4.5.1/modules/REQ-023-数据分析与商业智能模块/openapi.yaml" "模块 OpenAPI 规范"
    
    # 验证域文件
    validate_file "docs/api/4.5.1/domains/analytics-domain.yaml" "分析域聚合文件"
    
    # 验证全局API索引
    validate_file "docs/api/4.5.1/global-api-index.yaml" "全局 API 索引"
    
    echo -e "\n🎉 ${GREEN}所有验证通过！${NC}"
    echo ""
    echo "📊 API 统计信息:"
    echo "- 模块: REQ-023 数据分析与商业智能模块"
    echo "- API 路径前缀: /api/v1/analytics/*"
    echo "- 主要功能: 分析任务管理、结果管理、模型管理、数据源管理"
    echo "- 引用规范: 使用相对路径引用全局组件"
    echo "- Mock 数据: 符合 IT 运维业务语境"
    echo ""
    echo "🚀 可以使用以下命令启动 Mock Server 进行测试:"
    echo "   prism mock docs/api/4.5.1/modules/REQ-023-数据分析与商业智能模块/openapi.yaml"
    echo "   或"
    echo "   prism mock docs/api/4.5.1/global-api-index.yaml"
}

# 执行主函数
main "$@"
