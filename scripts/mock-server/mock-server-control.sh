#!/bin/bash

# IT运维门户系统 Mock Server 控制脚本
# 提供启动、停止、重启、状态查询功能

set -e

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOCK_SERVER_SCRIPT="$SCRIPT_DIR/start-mock-server.sh"
PID_FILE="/tmp/ops-portal-mock-server.pid"
LOG_FILE="/tmp/ops-portal-mock-server.log"

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
IT运维门户系统 Mock Server 控制脚本

用法: $0 <命令> [选项]

命令:
  start [选项]              启动Mock Server
  stop                      停止Mock Server
  restart [选项]            重启Mock Server
  status                    查看Mock Server状态
  logs                      查看Mock Server日志
  clean                     清理日志和PID文件

启动选项 (传递给start-mock-server.sh):
  -p, --port PORT           指定端口号
  -m, --module MODULE       启动特定模块
  -d, --domain DOMAIN       启动特定业务域
  -g, --global              启动全局API (默认)
  -w, --watch               启用文件监控
  --dynamic                 启用动态响应
  --errors                  启用错误模拟
  --verbose                 详细输出

示例:
  $0 start                              # 启动全局API Mock Server
  $0 start -p 3001 -w --dynamic         # 在端口3001启动，启用监控和动态响应
  $0 start -m REQ-016-客户关系管理模块   # 启动客户关系管理模块
  $0 stop                               # 停止Mock Server
  $0 restart -d auth                    # 重启认证域Mock Server
  $0 status                             # 查看状态
  $0 logs                               # 查看日志

EOF
}

# 检查Mock Server是否运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            # PID文件存在但进程不存在，清理PID文件
            rm -f "$PID_FILE"
            return 1
        fi
    else
        return 1
    fi
}

# 获取Mock Server进程信息
get_process_info() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "PID: $pid"
            echo "命令: $(ps -p "$pid" -o command= 2>/dev/null || echo '未知')"
            echo "启动时间: $(ps -p "$pid" -o lstart= 2>/dev/null || echo '未知')"
            echo "CPU使用率: $(ps -p "$pid" -o %cpu= 2>/dev/null || echo '未知')%"
            echo "内存使用率: $(ps -p "$pid" -o %mem= 2>/dev/null || echo '未知')%"
            return 0
        fi
    fi
    return 1
}

# 启动Mock Server
start_server() {
    if is_running; then
        log_warning "Mock Server 已经在运行中"
        show_status
        return 0
    fi
    
    log_info "启动 Mock Server..."
    
    # 检查启动脚本是否存在
    if [ ! -f "$MOCK_SERVER_SCRIPT" ]; then
        log_error "启动脚本不存在: $MOCK_SERVER_SCRIPT"
        return 1
    fi
    
    # 确保脚本可执行
    chmod +x "$MOCK_SERVER_SCRIPT"
    
    # 启动Mock Server (后台运行)
    nohup "$MOCK_SERVER_SCRIPT" "$@" > "$LOG_FILE" 2>&1 &
    local pid=$!
    
    # 保存PID
    echo "$pid" > "$PID_FILE"
    
    # 等待一下确保启动成功
    sleep 2
    
    if is_running; then
        log_success "Mock Server 启动成功 (PID: $pid)"
        log_info "日志文件: $LOG_FILE"
        return 0
    else
        log_error "Mock Server 启动失败"
        if [ -f "$LOG_FILE" ]; then
            log_info "错误日志:"
            tail -10 "$LOG_FILE"
        fi
        return 1
    fi
}

# 停止Mock Server
stop_server() {
    if ! is_running; then
        log_warning "Mock Server 未运行"
        return 0
    fi
    
    local pid=$(cat "$PID_FILE")
    log_info "停止 Mock Server (PID: $pid)..."
    
    # 发送TERM信号
    kill -TERM "$pid" 2>/dev/null || true
    
    # 等待进程结束
    local count=0
    while [ $count -lt 10 ] && ps -p "$pid" > /dev/null 2>&1; do
        sleep 1
        count=$((count + 1))
    done
    
    # 如果进程仍在运行，强制杀死
    if ps -p "$pid" > /dev/null 2>&1; then
        log_warning "进程未响应TERM信号，强制终止..."
        kill -KILL "$pid" 2>/dev/null || true
        sleep 1
    fi
    
    # 清理PID文件
    rm -f "$PID_FILE"
    
    if ! ps -p "$pid" > /dev/null 2>&1; then
        log_success "Mock Server 已停止"
        return 0
    else
        log_error "无法停止 Mock Server"
        return 1
    fi
}

# 重启Mock Server
restart_server() {
    log_info "重启 Mock Server..."
    stop_server
    sleep 1
    start_server "$@"
}

# 显示状态
show_status() {
    if is_running; then
        log_success "Mock Server 正在运行"
        get_process_info
        
        # 尝试检测端口
        local pid=$(cat "$PID_FILE")
        local port=$(lsof -p "$pid" -a -i TCP -s TCP:LISTEN 2>/dev/null | awk 'NR>1 {print $9}' | cut -d':' -f2 | head -1)
        if [ -n "$port" ]; then
            echo "监听端口: $port"
            echo "访问地址: http://localhost:$port"
        fi
    else
        log_warning "Mock Server 未运行"
    fi
}

# 显示日志
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        log_info "Mock Server 日志 (最近50行):"
        echo "----------------------------------------"
        tail -50 "$LOG_FILE"
        echo "----------------------------------------"
        log_info "完整日志文件: $LOG_FILE"
    else
        log_warning "日志文件不存在: $LOG_FILE"
    fi
}

# 清理文件
clean_files() {
    log_info "清理临时文件..."
    
    if is_running; then
        log_warning "Mock Server 正在运行，请先停止"
        return 1
    fi
    
    rm -f "$PID_FILE" "$LOG_FILE"
    log_success "清理完成"
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        start)
            start_server "$@"
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server "$@"
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        clean)
            clean_files
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
