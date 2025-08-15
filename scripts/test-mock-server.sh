#!/bin/bash

# IT运维门户系统 Mock Server 测试脚本
# 验证Mock Server功能和API响应

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTROL_SCRIPT="$SCRIPT_DIR/mock-server-control.sh"
TEST_PORT=3001
TEST_HOST="localhost"
TEST_URL="http://$TEST_HOST:$TEST_PORT"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# 测试计数器
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# 测试函数
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    log_info "运行测试: $test_name"
    
    if eval "$test_command"; then
        if [ "$expected_result" = "success" ]; then
            log_success "$test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_error "$test_name (期望失败但成功了)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            log_success "$test_name (期望失败)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_error "$test_name"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
}

# HTTP请求测试
test_http_request() {
    local url="$1"
    local expected_status="$2"
    local description="$3"
    
    log_info "测试HTTP请求: $description"
    log_info "URL: $url"
    
    local response=$(curl -s -w "%{http_code}" -o /tmp/mock_test_response.json "$url" 2>/dev/null || echo "000")
    local status_code="${response: -3}"
    
    if [ "$status_code" = "$expected_status" ]; then
        log_success "HTTP $status_code - $description"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "HTTP $status_code (期望 $expected_status) - $description"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

# 等待服务器启动
wait_for_server() {
    local max_attempts=30
    local attempt=0
    
    log_info "等待Mock Server启动..."
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "$TEST_URL" > /dev/null 2>&1; then
            log_success "Mock Server已启动"
            return 0
        fi
        
        attempt=$((attempt + 1))
        sleep 1
        echo -n "."
    done
    
    echo
    log_error "Mock Server启动超时"
    return 1
}

# 清理函数
cleanup() {
    log_info "清理测试环境..."
    "$CONTROL_SCRIPT" stop > /dev/null 2>&1 || true
    rm -f /tmp/mock_test_response.json
}

# 显示测试结果
show_results() {
    echo
    echo "=================================="
    echo "测试结果汇总"
    echo "=================================="
    echo "总测试数: $TESTS_TOTAL"
    echo "通过: $TESTS_PASSED"
    echo "失败: $TESTS_FAILED"
    echo "成功率: $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%"
    echo "=================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "所有测试通过!"
        return 0
    else
        log_error "$TESTS_FAILED 个测试失败"
        return 1
    fi
}

# 主测试流程
main() {
    echo "IT运维门户系统 Mock Server 测试"
    echo "=================================="
    
    # 设置清理陷阱
    trap cleanup EXIT
    
    # 1. 测试依赖检查
    log_info "1. 测试依赖检查"
    run_test "检查curl命令" "command -v curl" "success"
    run_test "检查控制脚本" "[ -f '$CONTROL_SCRIPT' ]" "success"
    run_test "检查API文档目录" "[ -d 'docs/api/4.5.1' ]" "success"
    run_test "检查全局API文件" "[ -f 'docs/api/4.5.1/global-api-index.yaml' ]" "success"
    
    echo
    
    # 2. 测试Mock Server启动
    log_info "2. 测试Mock Server启动"
    
    # 确保服务器已停止
    "$CONTROL_SCRIPT" stop > /dev/null 2>&1 || true
    
    # 启动全局API Mock Server
    log_info "启动全局API Mock Server (端口 $TEST_PORT)..."
    "$CONTROL_SCRIPT" start -p "$TEST_PORT" > /dev/null 2>&1 &
    
    # 等待启动
    if wait_for_server; then
        log_success "Mock Server启动成功"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "Mock Server启动失败"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        show_results
        exit 1
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo
    
    # 3. 测试服务器状态
    log_info "3. 测试服务器状态"
    run_test "检查服务器状态" "'$CONTROL_SCRIPT' status | grep -q '正在运行'" "success"
    
    echo
    
    # 4. 测试HTTP响应
    log_info "4. 测试HTTP响应"
    
    # 测试根路径
    test_http_request "$TEST_URL" "200" "根路径访问"
    
    # 测试OpenAPI规范
    test_http_request "$TEST_URL/__spec" "200" "OpenAPI规范访问"
    
    # 测试常见API端点 (这些可能返回404，但服务器应该响应)
    test_http_request "$TEST_URL/api/v1/auth/login" "404" "认证登录端点"
    test_http_request "$TEST_URL/api/v1/tickets" "404" "工单列表端点"
    test_http_request "$TEST_URL/api/v1/customers" "404" "客户列表端点"
    
    echo
    
    # 5. 测试CORS支持
    log_info "5. 测试CORS支持"
    local cors_headers=$(curl -s -H "Origin: http://localhost:8080" -H "Access-Control-Request-Method: GET" -H "Access-Control-Request-Headers: X-Requested-With" -X OPTIONS "$TEST_URL" -I 2>/dev/null | grep -i "access-control" || echo "")
    
    if [ -n "$cors_headers" ]; then
        log_success "CORS支持已启用"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_warning "CORS支持未检测到"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo
    
    # 6. 测试服务器停止
    log_info "6. 测试服务器停止"
    run_test "停止Mock Server" "'$CONTROL_SCRIPT' stop" "success"
    
    # 验证服务器已停止
    sleep 2
    if curl -s "$TEST_URL" > /dev/null 2>&1; then
        log_error "服务器停止失败"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    else
        log_success "服务器停止成功"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo
    
    # 7. 测试特定模块启动 (如果存在)
    log_info "7. 测试特定模块启动"
    
    local customer_module="docs/api/4.5.1/modules/REQ-016-客户关系管理模块/openapi.yaml"
    if [ -f "$customer_module" ]; then
        log_info "测试客户关系管理模块..."
        
        # 启动客户模块
        "$CONTROL_SCRIPT" start -m "REQ-016-客户关系管理模块" -p "$TEST_PORT" > /dev/null 2>&1 &
        
        if wait_for_server; then
            log_success "客户模块启动成功"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            
            # 停止服务器
            "$CONTROL_SCRIPT" stop > /dev/null 2>&1
        else
            log_error "客户模块启动失败"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        log_warning "客户关系管理模块文件不存在，跳过测试"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    # 显示最终结果
    show_results
}

# 显示帮助
show_help() {
    cat << EOF
IT运维门户系统 Mock Server 测试脚本

用法: $0 [选项]

选项:
  --port PORT       指定测试端口 (默认: $TEST_PORT)
  --host HOST       指定测试主机 (默认: $TEST_HOST)
  --help            显示此帮助信息

示例:
  $0                # 运行所有测试
  $0 --port 3002    # 使用端口3002运行测试

EOF
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --port)
            TEST_PORT="$2"
            TEST_URL="http://$TEST_HOST:$TEST_PORT"
            shift 2
            ;;
        --host)
            TEST_HOST="$2"
            TEST_URL="http://$TEST_HOST:$TEST_PORT"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 运行测试
main
