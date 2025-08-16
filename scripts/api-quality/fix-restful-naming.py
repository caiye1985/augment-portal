#!/usr/bin/env python3
"""
RESTful 命名规范修复工具
修复 API 文档中的 RESTful 命名问题，特别是资源名称单复数问题
"""

import os
import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple
import re

class RESTfulNamingFixer:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.fixes_applied = 0
        self.files_modified = set()

        # 需要修复的单数资源名称映射到复数形式
        self.singular_to_plural = {
            # 原有的映射
            'dashboard': 'dashboards',
            'notification': 'notifications',
            'engineer': 'engineers',
            'customer': 'customers',
            'ticket': 'tickets',
            'task': 'tasks',
            'user': 'users',
            'role': 'roles',
            'permission': 'permissions',
            'category': 'categories',
            'article': 'articles',
            'template': 'templates',
            'workflow': 'workflows',
            'report': 'reports',
            'alert': 'alerts',
            'log': 'logs',
            'config': 'configs',
            'setting': 'settings',
            # 新增的映射（基于分析结果）
            'finance': 'finances',
            'client': 'clients',
            'mobile': 'mobiles',
            'ai': 'ais',
            'customer-portal': 'customer-portals',
            'sla': 'slas',
            'dispatch': 'dispatches',
            'system': 'systems',
            'auth': 'auths',
            'system-config': 'system-configs',
            'knowledge': 'knowledges',
            'gray-release': 'gray-releases',
            'ml': 'mls',
            'admin': 'admins',
            'ux': 'uxs',
            'internal': 'internals',
            'performance': 'performances',
            'audit': 'audits',
            'health': 'healths'
        }

    def load_yaml_file(self, file_path: Path) -> Dict[str, Any]:
        """安全加载YAML文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ 无法加载文件 {file_path}: {e}")
            return {}

    def save_yaml_file(self, file_path: Path, data: Dict[str, Any]) -> bool:
        """保存YAML文件"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                yaml.dump(data, f, default_flow_style=False, allow_unicode=True,
                         sort_keys=False, width=120, indent=2)
            return True
        except Exception as e:
            print(f"❌ 无法保存文件 {file_path}: {e}")
            return False

    def fix_path_naming(self, path: str) -> Tuple[str, bool]:
        """修复路径中的资源命名"""
        original_path = path
        fixed = False

        # 匹配 /api/v1/{resource} 模式
        pattern = r'/api/v1/([a-zA-Z_-]+)'

        def replace_resource(match):
            nonlocal fixed
            resource = match.group(1)

            # 跳过已经是复数或包含参数的资源
            if resource.endswith('s') or '{' in resource or '}' in resource:
                return match.group(0)

            # 检查是否需要修复
            if resource in self.singular_to_plural:
                fixed = True
                return f"/api/v1/{self.singular_to_plural[resource]}"

            return match.group(0)

        new_path = re.sub(pattern, replace_resource, path)
        return new_path, fixed

    def fix_operation_id_naming(self, operation_id: str) -> Tuple[str, bool]:
        """修复 operationId 命名"""
        if not operation_id:
            return operation_id, False

        # 检查是否符合 domain_action 格式
        if not re.match(r'^[a-z]+_[a-z_]+$', operation_id):
            # 尝试转换为标准格式
            # 例如：getDashboard -> dashboard_get
            camel_case_pattern = r'^([a-z]+)([A-Z][a-z]+)$'
            match = re.match(camel_case_pattern, operation_id)
            if match:
                action = match.group(1).lower()
                resource = match.group(2).lower()

                # 转换为复数形式
                if resource in self.singular_to_plural:
                    resource = self.singular_to_plural[resource]

                new_operation_id = f"{resource}_{action}"
                return new_operation_id, True

        return operation_id, False

    def fix_file(self, file_path: Path) -> int:
        """修复单个文件中的 RESTful 命名问题"""
        print(f"\n📝 检查文件: {file_path.name}")

        spec = self.load_yaml_file(file_path)
        if not spec:
            return 0

        fixes_in_file = 0
        paths = spec.get('paths', {})
        new_paths = {}

        # 修复路径命名
        for path, methods in paths.items():
            new_path, path_fixed = self.fix_path_naming(path)
            if path_fixed:
                print(f"    ✅ 修复路径: {path} -> {new_path}")
                fixes_in_file += 1

            # 修复 operationId
            if isinstance(methods, dict) and '$ref' not in methods:
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        operation_id = operation.get('operationId', '')
                        if operation_id:
                            new_operation_id, op_fixed = self.fix_operation_id_naming(operation_id)
                            if op_fixed:
                                operation['operationId'] = new_operation_id
                                print(f"    ✅ 修复 operationId: {operation_id} -> {new_operation_id}")
                                fixes_in_file += 1

            new_paths[new_path] = methods

        # 如果有修改，更新 spec 并保存
        if fixes_in_file > 0:
            spec['paths'] = new_paths
            if self.save_yaml_file(file_path, spec):
                self.files_modified.add(str(file_path))
                print(f"  💾 已保存 {fixes_in_file} 个修复")
            else:
                print(f"  ❌ 保存失败")
                fixes_in_file = 0
        else:
            print(f"  ✅ 无需修复")

        return fixes_in_file

    def run_fixes(self) -> Dict[str, Any]:
        """运行所有修复"""
        print("🚀 开始修复 RESTful 命名规范...")
        print("=" * 60)

        # 获取所有API规范文件
        api_files = []

        # 加载模块文件
        modules_dir = self.base_path / "modules"
        if modules_dir.exists():
            for module_dir in modules_dir.iterdir():
                if module_dir.is_dir():
                    openapi_file = module_dir / "openapi.yaml"
                    if openapi_file.exists():
                        api_files.append(openapi_file)

        # 加载域文件
        domains_dir = self.base_path / "domains"
        if domains_dir.exists():
            for domain_file in domains_dir.glob("*.yaml"):
                api_files.append(domain_file)

        print(f"📁 找到 {len(api_files)} 个 API 规范文件")

        # 修复每个文件
        for file_path in api_files:
            fixes = self.fix_file(file_path)
            self.fixes_applied += fixes

        return {
            'total_fixes': self.fixes_applied,
            'files_modified': len(self.files_modified),
            'modified_files': list(self.files_modified)
        }

def main():
    fixer = RESTfulNamingFixer()
    results = fixer.run_fixes()

    print("\n" + "=" * 60)
    print("📊 RESTful 命名修复结果摘要")
    print("=" * 60)
    print(f"🔧 总修复数: {results['total_fixes']}")
    print(f"📁 修改文件数: {results['files_modified']}")

    if results['modified_files']:
        print("\n📝 修改的文件:")
        for file_path in results['modified_files']:
            file_short = '/'.join(file_path.split('/')[-2:])
            print(f"  - {file_short}")

    # 保存修复报告
    output_file = "restful_naming_fix_report.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"\n📄 修复报告已保存到: {output_file}")

    if results['total_fixes'] > 0:
        print("\n🎉 RESTful 命名修复完成！")

    return 0

if __name__ == "__main__":
    sys.exit(main())