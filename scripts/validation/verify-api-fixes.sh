#!/bin/bash

# OpenAPI文档修复验证脚本
# 验证引用路径问题是否已解决

set -e

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

# 测试计数器
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
test_api_startup() {
    local api_type="$1"
    local api_file="$2"
    local port="$3"
    local test_name="$4"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_info "测试 $test_name 启动..."
    
    # 启动Mock Server
    if [ "$api_type" = "--global" ]; then
        ./scripts/start-mock-server.sh -p "$port" > /tmp/mock_test_$port.log 2>&1 &
    elif [ "$api_type" = "--domain" ]; then
        ./scripts/start-mock-server.sh -d "$api_file" -p "$port" > /tmp/mock_test_$port.log 2>&1 &
    elif [ "$api_type" = "--module" ]; then
        ./scripts/start-mock-server.sh -m "$api_file" -p "$port" > /tmp/mock_test_$port.log 2>&1 &
    fi
    local pid=$!
    
    # 等待启动
    local attempts=0
    local max_attempts=15
    
    while [ $attempts -lt $max_attempts ]; do
        if curl -s "http://localhost:$port" > /dev/null 2>&1; then
            log_success "$test_name 启动成功"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            
            # 测试API响应
            local response=$(curl -s "http://localhost:$port/api/v1/auth/login" -X POST -H "Content-Type: application/json" -d '{}' 2>/dev/null || echo "")
            if [ -n "$response" ]; then
                log_success "$test_name API响应正常"
            else
                log_warning "$test_name API响应异常"
            fi
            
            # 停止服务器
            kill $pid 2>/dev/null || true
            sleep 2
            return 0
        fi
        
        attempts=$((attempts + 1))
        sleep 1
    done
    
    log_error "$test_name 启动失败"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    kill $pid 2>/dev/null || true
    
    # 显示错误日志
    if [ -f "/tmp/mock_test_$port.log" ]; then
        log_error "错误日志:"
        tail -10 "/tmp/mock_test_$port.log"
    fi
    
    return 1
}

# 主测试流程
main() {
    echo "OpenAPI文档修复验证"
    echo "===================="
    
    log_info "验证修复后的API文档能否正常启动Mock Server"
    echo
    
    # 1. 测试全局API
    test_api_startup "--global" "" "3010" "全局API"
    echo
    
    # 2. 测试认证域
    test_api_startup "--domain" "auth" "3011" "认证业务域"
    echo
    
    # 3. 测试工单域
    test_api_startup "--domain" "ticket" "3012" "工单业务域"
    echo
    
    # 4. 测试客户域
    test_api_startup "--domain" "customer" "3013" "客户业务域"
    echo
    
    # 5. 测试客户关系管理模块
    test_api_startup "--module" "REQ-016-客户关系管理模块" "3014" "客户关系管理模块"
    echo
    
    # 显示结果
    echo "===================="
    echo "验证结果汇总"
    echo "===================="
    echo "总测试数: $TESTS_TOTAL"
    echo "通过: $TESTS_PASSED"
    echo "失败: $TESTS_FAILED"
    echo "成功率: $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%"
    echo "===================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "所有API文档修复验证通过!"
        echo
        log_info "修复内容总结:"
        echo "✅ 修复了域文件中的错误引用路径"
        echo "✅ 将模块级别引用改为具体API路径引用"
        echo "✅ 修复了全局API索引文件的路径聚合"
        echo "✅ 确保了OpenAPI 3.0.3规范的兼容性"
        echo "✅ 保持了公共组件的正确引用"
        echo
        log_info "现在可以正常使用Mock Server了:"
        echo "  ./scripts/start-mock-server.sh                    # 全局API"
        echo "  ./scripts/start-mock-server.sh -d auth            # 认证域"
        echo "  ./scripts/start-mock-server.sh -d ticket          # 工单域"
        echo "  ./scripts/start-mock-server.sh -d customer        # 客户域"
        echo "  ./scripts/start-mock-server.sh -m REQ-016-客户关系管理模块  # 特定模块"
        return 0
    else
        log_error "$TESTS_FAILED 个测试失败，需要进一步检查"
        return 1
    fi
}

# 清理函数
cleanup() {
    log_info "清理测试环境..."
    pkill -f "prism mock" 2>/dev/null || true
    rm -f /tmp/mock_test_*.log
}

# 设置清理陷阱
trap cleanup EXIT

# 运行测试
main
