#!/usr/bin/env bash
set -e

# 导入版本工具
source "$(dirname "$0")/version_utils.sh"

# 检测版本并设置路径
VERSION=$(detect_prd_version)
if [[ $? -ne 0 ]]; then
    echo "[错误] 无法检测PRD版本号" >&2
    exit 1
fi

echo "[i] 检测到PRD版本: $VERSION"

# 设置版本化路径
API_ROOT="docs/api/$VERSION"
DOMAIN_DIR="$API_ROOT/domains"
MODULE_DIR="$API_ROOT/modules"
GLOBAL_INDEX="$API_ROOT/global-api-index.yaml"
MAPPING_FILE="docs/prd/split/$VERSION/globals/06-api-domain-mapping.md"

# 确保版本化目录存在
create_versioned_directories "$VERSION"

mkdir -p "$DOMAIN_DIR" "$MODULE_DIR"

echo "[i] 读取业务域与模块映射..."

# 定义不需要生成API的模块列表
API_EXCLUDE_MODULES=(
    "REQ-020"  # 移动端应用模块 - 复用其他业务域API
    "REQ-015"  # 用户体验增强系统 - 前端/交互优化
    "REQ-002"  # 工作台与仪表板模块 - 数据聚合展示
)

domains=()
# 使用普通数组替代关联数组以提高兼容性
domain_modules_data=""
last_domain=""

# 从映射表解析数据
while IFS= read -r line; do
    # 跳过空行和markdown标题
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue

    # 只处理表格行（包含|符号）
    if [[ "$line" =~ \| ]]; then
        # 分割表格列
        IFS='|' read -ra cols <<< "$line"

        # 确保有足够的列
        if [[ ${#cols[@]} -ge 4 ]]; then
            # 去掉首尾空格
            domain=$(echo "${cols[1]}" | xargs 2>/dev/null || echo "")
            desc=$(echo "${cols[2]}" | xargs 2>/dev/null || echo "")
            mod_id=$(echo "${cols[3]}" | xargs 2>/dev/null || echo "")
            mod_name=$(echo "${cols[4]}" | xargs 2>/dev/null || echo "")

            # 跳过表头和分隔线
            [[ "$domain" =~ ^业务域 ]] && continue
            [[ "$domain" =~ ^-+$ ]] && continue
            [[ "$domain" == "" && "$mod_id" == "" ]] && continue

            # 如果域是空，则继承上一有效域
            if [[ -z "$domain" ]]; then
                domain="$last_domain"
            fi
            last_domain="$domain"

            # 记录域列表（去重）
            if [[ ! " ${domains[*]} " =~ " ${domain} " ]]; then
                domains+=("$domain")
            fi

            # 检查模块是否在API排除列表中
            exclude_module=false
            for exclude_id in "${API_EXCLUDE_MODULES[@]}"; do
                if [[ "$mod_id" == "$exclude_id" ]]; then
                    exclude_module=true
                    echo "[i] 跳过API生成模块: $mod_id ($mod_name)"
                    break
                fi
            done

            # 记录该域下的模块（使用简单字符串格式），但排除不需要API的模块
            if [[ -n "$mod_id" && -n "$mod_name" && "$exclude_module" == "false" ]]; then
                domain_modules_data+="${domain}|${mod_id}|${mod_name};"
            fi
        fi
    fi
done < "$MAPPING_FILE"

# 生成全局入口文件
echo "[i] 生成全局入口文档: $GLOBAL_INDEX"
cat > "$GLOBAL_INDEX" <<EOF
openapi: 3.0.3
info:
  title: IT运维门户系统 API
  version: 1.0.0
  description: 全局 API 入口文档（聚合所有业务域）
paths: {}
x-domains:
EOF

# 遍历每个域，生成域聚合文件和模块占位
for domain in "${domains[@]}"; do
    domain_file="$DOMAIN_DIR/${domain}-domain.yaml"
    echo "  - name: $domain" >> "$GLOBAL_INDEX"
    echo "    \$ref: './domains/${domain}-domain.yaml'" >> "$GLOBAL_INDEX"

    echo "[i] 生成业务域文件: $domain_file"
    # 首字母大写（兼容性处理）
    domain_title=$(echo "$domain" | sed 's/^./\U&/')
    {
        echo "openapi: 3.0.3"
        echo "info:"
        echo "  title: ${domain_title} 业务域 API 聚合"
        echo "  version: 1.0.0"
        echo "paths:"
    } > "$domain_file"

    # 从数据字符串中提取该域的模块
    # 使用分号分割，然后过滤出当前域的模块
    IFS=';' read -ra all_entries <<< "$domain_modules_data"

    for entry in "${all_entries[@]}"; do
        [[ -z "$entry" ]] && continue

        # 解析域|模块ID|模块名称格式
        IFS='|' read -r entry_domain mod_id mod_name <<< "$entry"

        # 只处理当前域的模块
        [[ "$entry_domain" != "$domain" ]] && continue
        [[ -z "$mod_id" || -z "$mod_name" ]] && continue

        # 创建模块目录和占位文件
        mod_dir="$MODULE_DIR/${mod_id}-${mod_name}"
        mkdir -p "$mod_dir"
        mod_file="$mod_dir/openapi.yaml"
        if [[ ! -f "$mod_file" ]]; then
            echo "[i]   创建模块文件: $mod_file"
            cat > "$mod_file" <<EOF2
openapi: 3.0.3
info:
  title: ${mod_name} API
  version: 1.0.0
paths: {}
components:
  schemas: {}
EOF2
        fi

        # 域文件中引用模块 paths
        # 使用兼容的小写转换
        path_key="/${mod_name}"
        path_key=$(echo "$path_key" | tr '[:upper:]' '[:lower:]')
        echo "  ${path_key}:" >> "$domain_file"
        mod_name_lower=$(echo "$mod_name" | tr '[:upper:]' '[:lower:]')
        echo "    \$ref: '../modules/${mod_id}-${mod_name}/openapi.yaml#/paths/~1${mod_name_lower}'" >> "$domain_file"

    done
done

echo "[✔] 初始化完成：全局入口 + 域聚合 + 模块占位 已生成"
echo "[i] 版本: $VERSION"
echo "[i] API目录: $API_ROOT"
