#!/bin/bash

# OpenAPI 规范文档验证脚本
# 用于验证 IT运维门户系统的三级分离 OpenAPI 文档架构

set -e

echo "🔍 开始验证 IT运维门户系统 OpenAPI 规范文档..."
echo ""

# 检查 swagger-cli 是否安装
if ! command -v swagger-cli &> /dev/null; then
    echo "❌ swagger-cli 未安装，请先安装："
    echo "   npm install -g swagger-cli"
    exit 1
fi

# 验证全局规范文件
echo "📋 验证全局规范文件..."
if swagger-cli validate docs/api/_global.yaml; then
    echo "✅ docs/api/_global.yaml 验证通过"
else
    echo "❌ docs/api/_global.yaml 验证失败"
    exit 1
fi
echo ""

# 验证业务域规范文件
echo "🏢 验证业务域规范文件..."
for domain_file in docs/api/domains/*.yaml; do
    if [ -f "$domain_file" ]; then
        filename=$(basename "$domain_file")
        if swagger-cli validate "$domain_file"; then
            echo "✅ $filename 验证通过"
        else
            echo "❌ $filename 验证失败"
            exit 1
        fi
    fi
done
echo ""

# 验证模块规范文件
echo "📦 验证模块规范文件..."
for module_file in docs/api/modules/*.yaml; do
    if [ -f "$module_file" ]; then
        filename=$(basename "$module_file")
        if swagger-cli validate "$module_file"; then
            echo "✅ $filename 验证通过"
        else
            echo "❌ $filename 验证失败"
            exit 1
        fi
    fi
done
echo ""

# 统计信息
global_count=$(find docs/api -name "_global.yaml" | wc -l)
domain_count=$(find docs/api/domains -name "*.yaml" | wc -l)
module_count=$(find docs/api/modules -name "*.yaml" | wc -l)
total_count=$((global_count + domain_count + module_count))

echo "📊 验证统计："
echo "   全局规范文件: $global_count 个"
echo "   业务域文件: $domain_count 个"
echo "   模块文件: $module_count 个"
echo "   总计: $total_count 个文件"
echo ""

echo "🎉 所有 OpenAPI 规范文件验证通过！"
echo ""
echo "📁 文件结构："
echo "   docs/api/"
echo "   ├── _global.yaml          # 全局通用组件"
echo "   ├── domains/              # 业务域规范"
echo "   │   ├── auth.yaml         # 认证授权域"
echo "   │   ├── ticket.yaml       # 工单管理域"
echo "   │   ├── user.yaml         # 用户管理域"
echo "   │   └── system.yaml       # 系统管理域"
echo "   └── modules/              # 模块规范"
echo "       ├── portal-auth.yaml  # 认证授权模块"
echo "       ├── portal-ticket.yaml# 工单管理模块"
echo "       ├── portal-user.yaml  # 用户管理模块"
echo "       └── portal-system.yaml# 系统管理模块"
echo ""
echo "🔗 引用关系："
echo "   模块 → 域 → 全局"
echo "   通过 \$ref 实现组件复用和一致性"
