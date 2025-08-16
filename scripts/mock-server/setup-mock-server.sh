#!/bin/bash

# IT运维门户系统 Mock Server 环境设置脚本
# 自动安装和配置Mock Server所需的依赖

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

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安装Node.js (如果未安装)
install_nodejs() {
    if command_exists node; then
        local node_version=$(node --version)
        log_success "Node.js 已安装: $node_version"
        
        # 检查版本是否满足要求 (>= 14.0.0)
        local major_version=$(echo "$node_version" | sed 's/v\([0-9]*\).*/\1/')
        if [ "$major_version" -ge 14 ]; then
            log_success "Node.js 版本满足要求"
            return 0
        else
            log_warning "Node.js 版本过低 ($node_version)，建议升级到 14.0.0 或更高版本"
        fi
    else
        log_info "Node.js 未安装，正在安装..."
        
        local os=$(detect_os)
        case $os in
            "macos")
                if command_exists brew; then
                    brew install node
                else
                    log_error "请先安装 Homebrew 或手动安装 Node.js"
                    log_info "访问: https://nodejs.org/"
                    return 1
                fi
                ;;
            "linux")
                if command_exists apt-get; then
                    sudo apt-get update
                    sudo apt-get install -y nodejs npm
                elif command_exists yum; then
                    sudo yum install -y nodejs npm
                elif command_exists dnf; then
                    sudo dnf install -y nodejs npm
                else
                    log_error "无法自动安装 Node.js，请手动安装"
                    log_info "访问: https://nodejs.org/"
                    return 1
                fi
                ;;
            *)
                log_error "无法自动安装 Node.js，请手动安装"
                log_info "访问: https://nodejs.org/"
                return 1
                ;;
        esac
        
        if command_exists node; then
            log_success "Node.js 安装成功: $(node --version)"
        else
            log_error "Node.js 安装失败"
            return 1
        fi
    fi
}

# 安装npm (如果未安装)
install_npm() {
    if command_exists npm; then
        local npm_version=$(npm --version)
        log_success "npm 已安装: $npm_version"
        return 0
    else
        log_error "npm 未安装，请重新安装 Node.js"
        return 1
    fi
}

# 安装Prism CLI
install_prism() {
    if command_exists prism; then
        local prism_version=$(prism --version)
        log_success "Prism CLI 已安装: $prism_version"
        return 0
    else
        log_info "安装 Prism CLI..."
        
        # 尝试全局安装
        if npm install -g @stoplight/prism-cli; then
            log_success "Prism CLI 安装成功"
            
            # 验证安装
            if command_exists prism; then
                local prism_version=$(prism --version)
                log_success "Prism CLI 版本: $prism_version"
            else
                log_warning "Prism CLI 安装成功但无法在PATH中找到"
                log_info "请检查npm全局安装路径配置"
            fi
        else
            log_error "Prism CLI 安装失败"
            log_info "请尝试手动安装: npm install -g @stoplight/prism-cli"
            return 1
        fi
    fi
}

# 验证API文档结构
validate_api_structure() {
    log_info "验证API文档结构..."
    
    local api_dir="docs/api/4.5.1"
    local global_file="$api_dir/global-api-index.yaml"
    local modules_dir="$api_dir/modules"
    local domains_dir="$api_dir/domains"
    
    if [ ! -d "$api_dir" ]; then
        log_error "API文档目录不存在: $api_dir"
        return 1
    fi
    
    if [ ! -f "$global_file" ]; then
        log_error "全局API文件不存在: $global_file"
        return 1
    fi
    
    if [ ! -d "$modules_dir" ]; then
        log_warning "模块目录不存在: $modules_dir"
    else
        local module_count=$(find "$modules_dir" -maxdepth 1 -type d -name "REQ-*" | wc -l)
        log_success "发现 $module_count 个API模块"
    fi
    
    if [ ! -d "$domains_dir" ]; then
        log_warning "域目录不存在: $domains_dir"
    else
        local domain_count=$(find "$domains_dir" -name "*-domain.yaml" | wc -l)
        log_success "发现 $domain_count 个业务域"
    fi
    
    log_success "API文档结构验证通过"
}

# 设置脚本权限
setup_permissions() {
    log_info "设置脚本执行权限..."
    
    local script_dir="scripts"
    local scripts=(
        "start-mock-server.sh"
        "mock-server-control.sh"
        "test-mock-server.sh"
        "setup-mock-server.sh"
    )
    
    for script in "${scripts[@]}"; do
        local script_path="$script_dir/$script"
        if [ -f "$script_path" ]; then
            chmod +x "$script_path"
            log_success "设置权限: $script_path"
        else
            log_warning "脚本不存在: $script_path"
        fi
    done
}

# 创建快捷启动脚本
create_shortcuts() {
    log_info "创建快捷启动脚本..."
    
    # 创建全局启动脚本
    cat > scripts/start-global-mock.sh << 'EOF'
#!/bin/bash
# 快捷启动全局API Mock Server
cd "$(dirname "$0")/.."
./scripts/start-mock-server.sh --global --watch --dynamic --cors
EOF
    
    # 创建客户模块启动脚本
    cat > scripts/start-customer-mock.sh << 'EOF'
#!/bin/bash
# 快捷启动客户关系管理模块 Mock Server
cd "$(dirname "$0")/.."
./scripts/start-mock-server.sh -m REQ-016-客户关系管理模块 --watch --dynamic --cors
EOF
    
    # 创建认证域启动脚本
    cat > scripts/start-auth-mock.sh << 'EOF'
#!/bin/bash
# 快捷启动认证业务域 Mock Server
cd "$(dirname "$0")/.."
./scripts/start-mock-server.sh -d auth --watch --dynamic --cors
EOF
    
    chmod +x scripts/start-*-mock.sh
    
    log_success "快捷启动脚本创建完成"
    log_info "  - scripts/start-global-mock.sh   (全局API)"
    log_info "  - scripts/start-customer-mock.sh (客户模块)"
    log_info "  - scripts/start-auth-mock.sh     (认证域)"
}

# 运行基本测试
run_basic_test() {
    log_info "运行基本功能测试..."
    
    # 测试脚本帮助信息
    if ./scripts/start-mock-server.sh --help > /dev/null 2>&1; then
        log_success "启动脚本测试通过"
    else
        log_error "启动脚本测试失败"
        return 1
    fi
    
    # 测试模块列表
    if ./scripts/start-mock-server.sh -l > /dev/null 2>&1; then
        log_success "模块列表测试通过"
    else
        log_error "模块列表测试失败"
        return 1
    fi
    
    # 测试控制脚本
    if ./scripts/mock-server-control.sh help > /dev/null 2>&1; then
        log_success "控制脚本测试通过"
    else
        log_error "控制脚本测试失败"
        return 1
    fi
    
    log_success "基本功能测试通过"
}

# 显示使用说明
show_usage() {
    cat << EOF

🎉 Mock Server 环境设置完成！

📋 快速开始:
  # 启动全局API Mock Server
  ./scripts/start-mock-server.sh

  # 启动特定模块
  ./scripts/start-mock-server.sh -m REQ-016-客户关系管理模块

  # 启动特定业务域
  ./scripts/start-mock-server.sh -d auth

  # 后台运行
  ./scripts/mock-server-control.sh start

🚀 快捷脚本:
  ./scripts/start-global-mock.sh      # 全局API (推荐)
  ./scripts/start-customer-mock.sh    # 客户模块
  ./scripts/start-auth-mock.sh        # 认证域

🔧 管理命令:
  ./scripts/mock-server-control.sh status    # 查看状态
  ./scripts/mock-server-control.sh logs      # 查看日志
  ./scripts/mock-server-control.sh stop      # 停止服务

🧪 测试命令:
  ./scripts/test-mock-server.sh              # 运行完整测试

📚 更多信息:
  查看 scripts/README-mock-server.md

EOF
}

# 主函数
main() {
    echo "IT运维门户系统 Mock Server 环境设置"
    echo "===================================="
    
    # 1. 检查和安装Node.js
    log_info "1. 检查Node.js环境"
    install_nodejs || exit 1
    
    # 2. 检查和安装npm
    log_info "2. 检查npm环境"
    install_npm || exit 1
    
    # 3. 安装Prism CLI
    log_info "3. 安装Prism CLI"
    install_prism || exit 1
    
    # 4. 验证API文档结构
    log_info "4. 验证API文档结构"
    validate_api_structure || exit 1
    
    # 5. 设置脚本权限
    log_info "5. 设置脚本权限"
    setup_permissions
    
    # 6. 创建快捷启动脚本
    log_info "6. 创建快捷启动脚本"
    create_shortcuts
    
    # 7. 运行基本测试
    log_info "7. 运行基本测试"
    run_basic_test || exit 1
    
    # 8. 显示使用说明
    show_usage
    
    log_success "环境设置完成！"
}

# 显示帮助
show_help() {
    cat << EOF
IT运维门户系统 Mock Server 环境设置脚本

用法: $0 [选项]

选项:
  --help            显示此帮助信息

功能:
  - 检查和安装Node.js环境
  - 安装Prism CLI工具
  - 验证API文档结构
  - 设置脚本执行权限
  - 创建快捷启动脚本
  - 运行基本功能测试

EOF
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
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

# 运行主函数
main
