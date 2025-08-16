#!/bin/bash

# IT运维门户系统 Mock Server 启动脚本
# 基于 Prism CLI 启动 OpenAPI Mock Server
# 支持全局API索引和模块独立API文件

set -e

# 默认配置
DEFAULT_PORT=3000
DEFAULT_HOST="0.0.0.0"
API_DOCS_DIR="docs/api/4.5.1"
GLOBAL_API_FILE="$API_DOCS_DIR/global-api-index.yaml"
MODULES_DIR="$API_DOCS_DIR/modules"
DOMAINS_DIR="$API_DOCS_DIR/domains"

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

# 显示帮助信息
show_help() {
    cat << EOF
IT运维门户系统 Mock Server 启动脚本

用法: $0 [选项]

选项:
  -p, --port PORT           指定端口号 (默认: $DEFAULT_PORT)
  -h, --host HOST           指定主机地址 (默认: $DEFAULT_HOST)
  -m, --module MODULE       启动特定模块的Mock Server
  -d, --domain DOMAIN       启动特定业务域的Mock Server
  -g, --global              启动全局聚合API Mock Server (默认)
  -l, --list                列出所有可用的模块和域
  -v, --verbose             详细输出模式
  -w, --watch               启用文件监控和热重载
  --cors                    启用CORS支持 (默认启用)
  --no-cors                 禁用CORS支持
  --dynamic                 启用动态响应模式
  --errors                  启用错误模拟
  --help                    显示此帮助信息

示例:
  $0                                    # 启动全局API Mock Server
  $0 -p 3001                           # 在端口3001启动
  $0 -m REQ-016-客户关系管理模块        # 启动客户关系管理模块
  $0 -d auth                           # 启动认证业务域
  $0 -w --dynamic --errors             # 启用监控、动态响应和错误模拟

EOF
}

# 列出可用模块和域
list_available() {
    log_info "可用的业务模块:"
    if [ -d "$MODULES_DIR" ]; then
        find "$MODULES_DIR" -maxdepth 1 -type d -name "REQ-*" | sort | while read -r module; do
            module_name=$(basename "$module")
            echo "  - $module_name"
        done
    else
        log_warning "模块目录不存在: $MODULES_DIR"
    fi

    echo
    log_info "可用的业务域:"
    if [ -d "$DOMAINS_DIR" ]; then
        find "$DOMAINS_DIR" -name "*-domain.yaml" | sort | while read -r domain; do
            domain_name=$(basename "$domain" "-domain.yaml")
            echo "  - $domain_name"
        done
    else
        log_warning "域目录不存在: $DOMAINS_DIR"
    fi
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js 未安装，请先安装 Node.js"
        exit 1
    fi
    
    # 检查 npm
    if ! command -v npm &> /dev/null; then
        log_error "npm 未安装，请先安装 npm"
        exit 1
    fi
    
    # 检查 Prism CLI
    if ! command -v prism &> /dev/null; then
        log_warning "Prism CLI 未安装，正在安装..."
        npm install -g @stoplight/prism-cli
        if [ $? -ne 0 ]; then
            log_error "Prism CLI 安装失败"
            exit 1
        fi
        log_success "Prism CLI 安装成功"
    else
        log_success "Prism CLI 已安装: $(prism --version)"
    fi
}

# 验证API文件
validate_api_file() {
    local api_file="$1"
    
    if [ ! -f "$api_file" ]; then
        log_error "API文件不存在: $api_file"
        return 1
    fi
    
    log_info "验证API文件: $api_file"
    
    # 使用 Prism 验证 OpenAPI 文件
    if ! prism validate "$api_file" &> /dev/null; then
        log_warning "API文件验证失败，但将继续启动: $api_file"
        return 0
    fi
    
    log_success "API文件验证通过: $api_file"
    return 0
}

# 构建Prism命令
build_prism_command() {
    local api_file="$1"
    local port="$2"
    local host="$3"
    local enable_cors="$4"
    local enable_dynamic="$5"
    local enable_errors="$6"
    local enable_watch="$7"
    local verbose="$8"
    
    local cmd="prism mock"
    
    # API文件
    cmd="$cmd \"$api_file\""
    
    # 端口和主机
    cmd="$cmd --port $port --host $host"
    
    # CORS支持
    if [ "$enable_cors" = "true" ]; then
        cmd="$cmd --cors"
    fi
    
    # 动态响应
    if [ "$enable_dynamic" = "true" ]; then
        cmd="$cmd --dynamic"
    fi
    
    # 错误模拟
    if [ "$enable_errors" = "true" ]; then
        cmd="$cmd --errors"
    fi
    
    # 文件监控
    if [ "$enable_watch" = "true" ]; then
        cmd="$cmd --watch"
    fi
    
    # 详细输出
    if [ "$verbose" = "true" ]; then
        cmd="$cmd --verbose"
    fi
    
    echo "$cmd"
}

# 启动Mock Server
start_mock_server() {
    local api_file="$1"
    local port="$2"
    local host="$3"
    local enable_cors="$4"
    local enable_dynamic="$5"
    local enable_errors="$6"
    local enable_watch="$7"
    local verbose="$8"
    local server_name="$9"
    
    log_info "启动 $server_name Mock Server..."
    log_info "API文件: $api_file"
    log_info "地址: http://$host:$port"
    
    # 验证API文件
    validate_api_file "$api_file"
    
    # 构建并执行命令
    local cmd=$(build_prism_command "$api_file" "$port" "$host" "$enable_cors" "$enable_dynamic" "$enable_errors" "$enable_watch" "$verbose")
    
    log_info "执行命令: $cmd"
    echo
    log_success "Mock Server 启动成功!"
    log_info "访问地址: http://$host:$port"
    log_info "按 Ctrl+C 停止服务器"
    echo
    
    # 执行命令
    eval "$cmd"
}

# 主函数
main() {
    local port="$DEFAULT_PORT"
    local host="$DEFAULT_HOST"
    local module=""
    local domain=""
    local use_global="true"
    local enable_cors="true"
    local enable_dynamic="false"
    local enable_errors="false"
    local enable_watch="false"
    local verbose="false"
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--port)
                port="$2"
                shift 2
                ;;
            -h|--host)
                host="$2"
                shift 2
                ;;
            -m|--module)
                module="$2"
                use_global="false"
                shift 2
                ;;
            -d|--domain)
                domain="$2"
                use_global="false"
                shift 2
                ;;
            -g|--global)
                use_global="true"
                shift
                ;;
            -l|--list)
                list_available
                exit 0
                ;;
            -v|--verbose)
                verbose="true"
                shift
                ;;
            -w|--watch)
                enable_watch="true"
                shift
                ;;
            --cors)
                enable_cors="true"
                shift
                ;;
            --no-cors)
                enable_cors="false"
                shift
                ;;
            --dynamic)
                enable_dynamic="true"
                shift
                ;;
            --errors)
                enable_errors="true"
                shift
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
    
    # 检查依赖
    check_dependencies
    
    # 确定API文件和服务器名称
    local api_file=""
    local server_name=""
    
    if [ "$use_global" = "true" ]; then
        api_file="$GLOBAL_API_FILE"
        server_name="全局API"
    elif [ -n "$module" ]; then
        api_file="$MODULES_DIR/$module/openapi.yaml"
        server_name="模块 $module"
    elif [ -n "$domain" ]; then
        api_file="$DOMAINS_DIR/$domain-domain.yaml"
        server_name="业务域 $domain"
    else
        log_error "必须指定全局API、模块或业务域"
        show_help
        exit 1
    fi
    
    # 启动Mock Server
    start_mock_server "$api_file" "$port" "$host" "$enable_cors" "$enable_dynamic" "$enable_errors" "$enable_watch" "$verbose" "$server_name"
}

# 脚本入口
main "$@"
