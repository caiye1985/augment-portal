#!/usr/bin/env python3
"""
参数类型不一致性自动修复工具
根据分析结果自动修复 API 文档中的参数类型不一致问题
"""

import os
import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple
import re

class ParameterTypeFixer:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.fixes_applied = 0
        self.files_modified = set()
        
        # 参数类型标准化规则
        self.type_standards = {
            'status': {'type': 'array', 'items': {'type': 'string'}, 'description': '状态过滤，支持多选'},
            'priority': {'type': 'array', 'items': {'type': 'string'}, 'description': '优先级过滤，支持多选'},
            'level': {'type': 'array', 'items': {'type': 'string'}, 'description': '级别过滤，支持多选'},
            'ticket_id': {'type': 'string', 'description': '工单ID'},
            'task_id': {'type': 'string', 'description': '任务ID'},
            'task_type': {'type': 'array', 'items': {'type': 'string'}, 'description': '任务类型过滤，支持多选'},
            'role_type': {'type': 'string', 'description': '角色类型'},
            'result': {'type': 'string', 'description': '结果状态'},
            'time_range': {'type': 'string', 'description': '时间范围，如7d, 1m, 3h'}
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
    
    def fix_parameter_in_operation(self, operation: Dict[str, Any], param_name: str) -> bool:
        """修复操作中的参数类型"""
        fixed = False
        parameters = operation.get('parameters', [])
        
        for i, param in enumerate(parameters):
            if isinstance(param, dict) and param.get('name') == param_name:
                if param_name in self.type_standards:
                    standard = self.type_standards[param_name]
                    old_schema = param.get('schema', {})
                    
                    # 更新schema
                    param['schema'] = {
                        'type': standard['type']
                    }
                    
                    # 如果是数组类型，添加items
                    if standard['type'] == 'array' and 'items' in standard:
                        param['schema']['items'] = standard['items']
                    
                    # 更新描述
                    if 'description' not in param or not param['description']:
                        param['description'] = standard['description']
                    
                    print(f"    ✅ 修复参数 {param_name}: {old_schema} -> {param['schema']}")
                    fixed = True
        
        return fixed
    
    def fix_file(self, file_path: Path) -> int:
        """修复单个文件中的参数类型不一致"""
        print(f"\n📝 检查文件: {file_path.name}")
        
        spec = self.load_yaml_file(file_path)
        if not spec:
            return 0
        
        fixes_in_file = 0
        paths = spec.get('paths', {})
        
        for path, methods in paths.items():
            if isinstance(methods, dict) and '$ref' not in methods:
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        # 检查每个需要标准化的参数
                        for param_name in self.type_standards.keys():
                            if self.fix_parameter_in_operation(operation, param_name):
                                fixes_in_file += 1
        
        # 如果有修改，保存文件
        if fixes_in_file > 0:
            if self.save_yaml_file(file_path, spec):
                self.files_modified.add(str(file_path))
                print(f"  💾 已保存 {fixes_in_file} 个修复")
            else:
                print(f"  ❌ 保存失败")
                fixes_in_file = 0
        else:
            print(f"  ✅ 无需修复")
        
        return fixes_in_file
    
    def fix_dashboard_naming(self, file_path: Path) -> int:
        """修复dashboard命名问题（单数改复数）"""
        spec = self.load_yaml_file(file_path)
        if not spec:
            return 0
        
        fixes_in_file = 0
        paths = spec.get('paths', {})
        new_paths = {}
        
        for path, methods in paths.items():
            # 将 /api/v1/dashboard/ 改为 /api/v1/dashboards/
            new_path = path.replace('/api/v1/dashboard/', '/api/v1/dashboards/')
            if new_path != path:
                print(f"    ✅ 修复路径: {path} -> {new_path}")
                fixes_in_file += 1
            new_paths[new_path] = methods
        
        if fixes_in_file > 0:
            spec['paths'] = new_paths
            if self.save_yaml_file(file_path, spec):
                self.files_modified.add(str(file_path))
                print(f"  💾 已保存 {fixes_in_file} 个路径修复")
            else:
                print(f"  ❌ 保存失败")
                fixes_in_file = 0
        
        return fixes_in_file
    
    def run_fixes(self) -> Dict[str, Any]:
        """运行所有修复"""
        print("🚀 开始自动修复参数类型不一致性...")
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
        
        # 修复参数类型不一致
        print("\n🔧 修复参数类型不一致...")
        for file_path in api_files:
            fixes = self.fix_file(file_path)
            self.fixes_applied += fixes
        
        # 修复dashboard命名问题
        print("\n🔧 修复dashboard命名问题...")
        dashboard_files = [f for f in api_files if 'dashboard' in str(f).lower()]
        for file_path in dashboard_files:
            fixes = self.fix_dashboard_naming(file_path)
            self.fixes_applied += fixes
        
        return {
            'total_fixes': self.fixes_applied,
            'files_modified': len(self.files_modified),
            'modified_files': list(self.files_modified)
        }

def main():
    fixer = ParameterTypeFixer()
    results = fixer.run_fixes()
    
    print("\n" + "=" * 60)
    print("📊 修复结果摘要")
    print("=" * 60)
    print(f"🔧 总修复数: {results['total_fixes']}")
    print(f"📁 修改文件数: {results['files_modified']}")
    
    if results['modified_files']:
        print("\n📝 修改的文件:")
        for file_path in results['modified_files']:
            file_short = '/'.join(file_path.split('/')[-2:])
            print(f"  - {file_short}")
    
    # 保存修复报告
    output_file = "parameter_fix_report.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 修复报告已保存到: {output_file}")
    
    if results['total_fixes'] > 0:
        print("\n🎉 修复完成！建议运行以下命令验证修复效果:")
        print("python3 scripts/api-quality-checker.py")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
