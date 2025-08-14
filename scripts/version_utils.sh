#!/usr/bin/env bash
# version_utils.sh - 版本检测和目录管理工具

set -e

# 全局变量
PRD_BASE_DIR="docs/prd/split"
API_BASE_DIR="docs/api"
OUTPUT_BASE_DIR="docs/output"
PROMPT_BASE_DIR="prompts"

# 检测当前PRD版本号
detect_prd_version() {
    if [[ ! -d "$PRD_BASE_DIR" ]]; then
        echo "[错误] PRD基础目录不存在: $PRD_BASE_DIR" >&2
        return 1
    fi
    
    # 查找最新版本号（按版本号排序）
    local latest_version
    latest_version=$(ls -d "$PRD_BASE_DIR"/*/ 2>/dev/null | \
                    grep -oE '[0-9]+\.[0-9]+' | \
                    sort -V | \
                    tail -n1)
    
    if [[ -z "$latest_version" ]]; then
        echo "[错误] 未找到有效的PRD版本目录" >&2
        return 1
    fi
    
    echo "$latest_version"
}

# 获取版本化的目录路径
get_versioned_path() {
    local base_dir="$1"
    local version="$2"
    echo "${base_dir}/${version}"
}

# 创建版本化目录结构
create_versioned_directories() {
    local version="$1"

    if [[ -z "$version" ]]; then
        echo "[错误] 版本号不能为空" >&2
        return 1
    fi

    local api_version_dir=$(get_versioned_path "$API_BASE_DIR" "$version")
    local output_version_dir=$(get_versioned_path "$OUTPUT_BASE_DIR" "$version")
    local prompt_version_dir=$(get_versioned_path "$PROMPT_BASE_DIR" "$version")

    echo "[i] 创建版本化目录结构 (版本: $version)..."

    # 创建API版本目录
    mkdir -p "$api_version_dir"/{domains,modules}
    echo "[i] 创建目录: $api_version_dir"

    # 创建输出版本目录
    mkdir -p "$output_version_dir"/{api-docs,backend,frontend,mobile,architecture,prd-improvements}
    echo "[i] 创建目录: $output_version_dir"

    # 创建prompt版本目录
    mkdir -p "$prompt_version_dir"/{api,backend,frontend,mobile,prd-analysis}
    echo "[i] 创建目录: $prompt_version_dir"

    echo "[√] 版本化目录结构创建完成"
}

# 创建新PRD版本目录结构
create_new_prd_version() {
    local new_version="$1"

    if [[ -z "$new_version" ]]; then
        echo "[错误] 新版本号不能为空" >&2
        return 1
    fi

    local new_prd_dir="$PRD_BASE_DIR/$new_version"

    echo "[i] 创建新PRD版本目录结构 (版本: $new_version)..."

    # 创建新PRD版本目录
    mkdir -p "$new_prd_dir"/{modules,globals,appendix}
    echo "[i] 创建目录: $new_prd_dir"

    echo "[√] 新PRD版本目录结构创建完成"
}

# 获取PRD相关路径
get_prd_paths() {
    local version="$1"
    local prd_version_dir=$(get_versioned_path "$PRD_BASE_DIR" "$version")
    
    cat <<EOF
PRD_VERSION_DIR="$prd_version_dir"
PRD_MODULES_DIR="$prd_version_dir/modules"
PRD_GLOBALS_DIR="$prd_version_dir/globals"
PRD_APPENDIX_DIR="$prd_version_dir/appendix"
GLOBAL_CONTEXT_FILE="docs/global-context.md"
MOCK_GUIDE_FILE="$prd_version_dir/globals/05-mock-data-guidelines.md"
MAPPING_FILE="$prd_version_dir/globals/06-api-domain-mapping.md"
TECH_STACK_FILE="$prd_version_dir/appendix/03-technology-stack.md"
BUSINESS_PROCESS_FILE="$prd_version_dir/globals/04-business-processes.md"
GLOSSARY_FILE="$prd_version_dir/appendix/01-glossary-and-references.md"
EOF
}

# 获取输出相关路径
get_output_paths() {
    local version="$1"
    local api_version_dir=$(get_versioned_path "$API_BASE_DIR" "$version")
    local output_version_dir=$(get_versioned_path "$OUTPUT_BASE_DIR" "$version")
    local prompt_version_dir=$(get_versioned_path "$PROMPT_BASE_DIR" "$version")
    
    cat <<EOF
API_VERSION_DIR="$api_version_dir"
API_DOMAINS_DIR="$api_version_dir/domains"
API_MODULES_DIR="$api_version_dir/modules"
API_GLOBAL_INDEX="$api_version_dir/global-api-index.yaml"
OUTPUT_VERSION_DIR="$output_version_dir"
PROMPT_VERSION_DIR="$prompt_version_dir"
EOF
}

# 检查版本目录是否存在
check_version_directories() {
    local version="$1"
    local prd_version_dir=$(get_versioned_path "$PRD_BASE_DIR" "$version")
    
    if [[ ! -d "$prd_version_dir" ]]; then
        echo "[错误] PRD版本目录不存在: $prd_version_dir" >&2
        return 1
    fi
    
    echo "[√] PRD版本目录存在: $prd_version_dir"
    return 0
}

# 迁移现有文件到版本化目录
migrate_existing_files() {
    local version="$1"
    
    echo "[i] 开始迁移现有文件到版本化目录..."
    
    # 迁移API文件
    if [[ -d "$API_BASE_DIR" && ! -d "$API_BASE_DIR/$version" ]]; then
        local api_version_dir=$(get_versioned_path "$API_BASE_DIR" "$version")
        
        # 备份现有API目录
        if [[ -d "$API_BASE_DIR/domains" || -d "$API_BASE_DIR/modules" || -f "$API_BASE_DIR/global-api-index.yaml" ]]; then
            echo "[i] 迁移现有API文件到 $api_version_dir"
            mkdir -p "$api_version_dir"
            
            [[ -d "$API_BASE_DIR/domains" ]] && mv "$API_BASE_DIR/domains" "$api_version_dir/"
            [[ -d "$API_BASE_DIR/modules" ]] && mv "$API_BASE_DIR/modules" "$api_version_dir/"
            [[ -f "$API_BASE_DIR/global-api-index.yaml" ]] && mv "$API_BASE_DIR/global-api-index.yaml" "$api_version_dir/"
        fi
    fi
    
    # 迁移prompt文件
    if [[ -d "$PROMPT_BASE_DIR" && ! -d "$PROMPT_BASE_DIR/$version" ]]; then
        local prompt_version_dir=$(get_versioned_path "$PROMPT_BASE_DIR" "$version")
        
        # 备份现有prompt文件
        if ls "$PROMPT_BASE_DIR"/*.md >/dev/null 2>&1; then
            echo "[i] 迁移现有prompt文件到 $prompt_version_dir"
            mkdir -p "$prompt_version_dir/api"
            mv "$PROMPT_BASE_DIR"/*.md "$prompt_version_dir/api/" 2>/dev/null || true
        fi
    fi
    
    echo "[√] 文件迁移完成"
}

# 主函数：初始化版本化结构
init_versioned_structure() {
    local version
    version=$(detect_prd_version)
    
    if [[ $? -ne 0 ]]; then
        echo "[错误] 无法检测PRD版本号" >&2
        return 1
    fi
    
    echo "[i] 检测到PRD版本: $version"
    
    # 检查PRD版本目录
    check_version_directories "$version"
    
    # 迁移现有文件
    migrate_existing_files "$version"
    
    # 创建版本化目录
    create_versioned_directories "$version"
    
    echo ""
    echo "[√] 版本化结构初始化完成"
    echo "[i] 当前版本: $version"
    echo "[i] API目录: $(get_versioned_path "$API_BASE_DIR" "$version")"
    echo "[i] 输出目录: $(get_versioned_path "$OUTPUT_BASE_DIR" "$version")"
    echo "[i] Prompt目录: $(get_versioned_path "$PROMPT_BASE_DIR" "$version")"
}

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "detect")
            detect_prd_version
            ;;
        "init")
            init_versioned_structure
            ;;
        "paths")
            version=$(detect_prd_version)
            echo "=== PRD Paths ==="
            get_prd_paths "$version"
            echo ""
            echo "=== Output Paths ==="
            get_output_paths "$version"
            ;;
        *)
            echo "用法: $0 {detect|init|paths}"
            echo ""
            echo "命令说明:"
            echo "  detect  - 检测当前PRD版本号"
            echo "  init    - 初始化版本化目录结构"
            echo "  paths   - 显示版本化路径信息"
            exit 1
            ;;
    esac
fi
