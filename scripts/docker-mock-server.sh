#!/bin/bash

# IT运维门户系统 Docker Mock Server 管理脚本

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.mock-server.yml"
PROJECT_NAME="ops-portal-mock"

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
IT运维门户系统 Docker Mock Server 管理脚本

用法: $0 <命令> [选项]

命令:
  build                     构建Mock Server镜像
  up [服务名]               启动Mock Server服务
  down                      停止并删除所有服务
  start [服务名]            启动已存在的服务
  stop [服务名]             停止服务
  restart [服务名]          重启服务
  logs [服务名]             查看服务日志
  status                    查看服务状态
  clean                     清理所有容器和镜像
  shell <服务名>            进入服务容器

可用服务:
  mock-server-global        全局API Mock Server (端口: 3000)
  mock-server-auth          认证域Mock Server (端口: 3001)
  mock-server-ticket        工单域Mock Server (端口: 3002)
  mock-server-customer      客户模块Mock Server (端口: 3003)
  nginx-proxy               Nginx反向代理 (端口: 8080)

示例:
  $0 build                              # 构建镜像
  $0 up                                 # 启动所有服务
  $0 up mock-server-global              # 只启动全局API服务
  $0 logs mock-server-auth              # 查看认证服务日志
  $0 restart mock-server-customer       # 重启客户服务
  $0 status                             # 查看所有服务状态

访问地址:
  http://localhost:3000                 # 全局API
  http://localhost:3001                 # 认证域API
  http://localhost:3002                 # 工单域API
  http://localhost:3003                 # 客户模块API
  http://localhost:8080                 # Nginx代理 (统一入口)

EOF
}

# 检查Docker环境
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    # 检查Docker是否运行
    if ! docker info &> /dev/null; then
        log_error "Docker 服务未运行，请启动 Docker"
        exit 1
    fi
    
    log_success "Docker 环境检查通过"
}

# 获取docker-compose命令
get_compose_cmd() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        echo "docker compose"
    fi
}

# 构建镜像
build_images() {
    log_info "构建 Mock Server 镜像..."
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" build
    
    if [ $? -eq 0 ]; then
        log_success "镜像构建完成"
    else
        log_error "镜像构建失败"
        exit 1
    fi
}

# 启动服务
start_services() {
    local service="$1"
    
    log_info "启动 Mock Server 服务..."
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    
    if [ -n "$service" ]; then
        log_info "启动服务: $service"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d "$service"
    else
        log_info "启动所有服务"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d
    fi
    
    if [ $? -eq 0 ]; then
        log_success "服务启动完成"
        show_access_info
    else
        log_error "服务启动失败"
        exit 1
    fi
}

# 停止服务
stop_services() {
    local service="$1"
    
    log_info "停止 Mock Server 服务..."
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    
    if [ -n "$service" ]; then
        log_info "停止服务: $service"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" stop "$service"
    else
        log_info "停止所有服务"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" down
    fi
    
    if [ $? -eq 0 ]; then
        log_success "服务停止完成"
    else
        log_error "服务停止失败"
        exit 1
    fi
}

# 重启服务
restart_services() {
    local service="$1"
    
    log_info "重启 Mock Server 服务..."
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    
    if [ -n "$service" ]; then
        log_info "重启服务: $service"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" restart "$service"
    else
        log_info "重启所有服务"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" restart
    fi
    
    if [ $? -eq 0 ]; then
        log_success "服务重启完成"
    else
        log_error "服务重启失败"
        exit 1
    fi
}

# 查看日志
show_logs() {
    local service="$1"
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    
    if [ -n "$service" ]; then
        log_info "查看服务日志: $service"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" logs -f "$service"
    else
        log_info "查看所有服务日志"
        $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" logs -f
    fi
}

# 查看状态
show_status() {
    log_info "Mock Server 服务状态:"
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" ps
    
    echo
    log_info "端口占用情况:"
    echo "端口 3000: $(lsof -ti:3000 &>/dev/null && echo '已占用' || echo '空闲')"
    echo "端口 3001: $(lsof -ti:3001 &>/dev/null && echo '已占用' || echo '空闲')"
    echo "端口 3002: $(lsof -ti:3002 &>/dev/null && echo '已占用' || echo '空闲')"
    echo "端口 3003: $(lsof -ti:3003 &>/dev/null && echo '已占用' || echo '空闲')"
    echo "端口 8080: $(lsof -ti:8080 &>/dev/null && echo '已占用' || echo '空闲')"
}

# 清理环境
clean_environment() {
    log_warning "这将删除所有 Mock Server 容器和镜像"
    read -p "确认继续? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "操作已取消"
        return 0
    fi
    
    log_info "清理 Mock Server 环境..."
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    
    # 停止并删除容器
    $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" down --rmi all --volumes --remove-orphans
    
    # 清理悬空镜像
    docker image prune -f
    
    log_success "环境清理完成"
}

# 进入容器
enter_container() {
    local service="$1"
    
    if [ -z "$service" ]; then
        log_error "请指定服务名称"
        exit 1
    fi
    
    log_info "进入容器: $service"
    
    local compose_cmd=$(get_compose_cmd)
    
    cd "$SCRIPT_DIR/.."
    $compose_cmd -f "$COMPOSE_FILE" -p "$PROJECT_NAME" exec "$service" /bin/sh
}

# 显示访问信息
show_access_info() {
    cat << EOF

🌐 Mock Server 访问地址:
  全局API:     http://localhost:3000
  认证域API:   http://localhost:3001
  工单域API:   http://localhost:3002
  客户模块API: http://localhost:3003
  统一入口:    http://localhost:8080

📋 API文档:
  全局API文档: http://localhost:3000/__spec
  认证域文档:  http://localhost:3001/__spec
  工单域文档:  http://localhost:3002/__spec
  客户模块文档: http://localhost:3003/__spec

🔧 管理命令:
  查看状态:    $0 status
  查看日志:    $0 logs [服务名]
  重启服务:    $0 restart [服务名]
  停止服务:    $0 down

EOF
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    # 检查Docker环境
    check_docker
    
    local command="$1"
    local service="$2"
    
    case "$command" in
        build)
            build_images
            ;;
        up)
            start_services "$service"
            ;;
        down)
            stop_services
            ;;
        start)
            start_services "$service"
            ;;
        stop)
            stop_services "$service"
            ;;
        restart)
            restart_services "$service"
            ;;
        logs)
            show_logs "$service"
            ;;
        status)
            show_status
            ;;
        clean)
            clean_environment
            ;;
        shell)
            enter_container "$service"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $command"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
main "$@"
