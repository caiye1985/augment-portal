#!/usr/bin/env python3
"""
API 引用路径修复工具
修复由于路径重命名导致的引用路径不一致问题
"""

import os
import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple
import re

class APIReferenceFixer:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.fixes_applied = 0
        self.files_modified = set()
        
        # 路径重命名映射
        self.path_mappings = {
            '/api/v1/dashboard/': '/api/v1/dashboards/',
            '/api/v1/workflow/': '/api/v1/workflows/',
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
    
    def fix_reference_path(self, ref_path: str) -> Tuple[str, bool]:
        """修复引用路径"""
        original_path = ref_path
        fixed = False
        
        # 修复路径中的单数资源名称
        for old_path, new_path in self.path_mappings.items():
            if old_path in ref_path:
                ref_path = ref_path.replace(old_path, new_path)
                fixed = True
        
        # 修复 URL 编码的路径
        # ~1api~1v1~1dashboard~1 -> ~1api~1v1~1dashboards~1
        ref_path = ref_path.replace('~1api~1v1~1dashboard~1', '~1api~1v1~1dashboards~1')
        ref_path = ref_path.replace('~1api~1v1~1workflow~1', '~1api~1v1~1workflows~1')
        
        if ref_path != original_path:
            fixed = True
        
        return ref_path, fixed
    
    def fix_paths_in_spec(self, spec: Dict[str, Any]) -> int:
        """修复规范中的路径引用"""
        fixes_in_spec = 0
        
        # 修复 paths 中的 $ref
        paths = spec.get('paths', {})
        new_paths = {}
        
        for path, methods in paths.items():
            # 修复路径本身
            new_path = path
            for old_path, new_path_replacement in self.path_mappings.items():
                if old_path in path:
                    new_path = path.replace(old_path, new_path_replacement)
                    break
            
            # 修复方法中的 $ref
            if isinstance(methods, dict):
                if '$ref' in methods:
                    # 整个路径是引用
                    new_ref, ref_fixed = self.fix_reference_path(methods['$ref'])
                    if ref_fixed:
                        methods['$ref'] = new_ref
                        print(f"    ✅ 修复路径引用: {path} -> {new_ref}")
                        fixes_in_spec += 1
                else:
                    # 检查每个HTTP方法
                    for method, operation in methods.items():
                        if isinstance(operation, dict) and '$ref' in operation:
                            new_ref, ref_fixed = self.fix_reference_path(operation['$ref'])
                            if ref_fixed:
                                operation['$ref'] = new_ref
                                print(f"    ✅ 修复操作引用: {path}:{method} -> {new_ref}")
                                fixes_in_spec += 1
            
            new_paths[new_path] = methods
        
        if new_paths != paths:
            spec['paths'] = new_paths
        
        return fixes_in_spec
    
    def fix_file(self, file_path: Path) -> int:
        """修复单个文件中的引用路径"""
        print(f"\n📝 检查文件: {file_path.name}")
        
        spec = self.load_yaml_file(file_path)
        if not spec:
            return 0
        
        fixes_in_file = self.fix_paths_in_spec(spec)
        
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
    
    def run_fixes(self) -> Dict[str, Any]:
        """运行所有修复"""
        print("🚀 开始修复 API 引用路径...")
        print("=" * 60)
        
        # 获取所有需要修复的文件
        files_to_fix = []
        
        # 域文件
        domains_dir = self.base_path / "domains"
        if domains_dir.exists():
            for domain_file in domains_dir.glob("*.yaml"):
                files_to_fix.append(domain_file)
        
        # 全局索引文件
        global_file = self.base_path / "global-api-index.yaml"
        if global_file.exists():
            files_to_fix.append(global_file)
        
        print(f"📁 找到 {len(files_to_fix)} 个需要检查的文件")
        
        # 修复每个文件
        for file_path in files_to_fix:
            fixes = self.fix_file(file_path)
            self.fixes_applied += fixes
        
        return {
            'total_fixes': self.fixes_applied,
            'files_modified': len(self.files_modified),
            'modified_files': list(self.files_modified)
        }

def main():
    # 切换到正确的目录
    if os.getcwd().endswith('docs/api/4.5.1'):
        base_path = "."
    else:
        base_path = "docs/api/4.5.1"
    
    fixer = APIReferenceFixer(base_path)
    results = fixer.run_fixes()
    
    print("\n" + "=" * 60)
    print("📊 API 引用路径修复结果摘要")
    print("=" * 60)
    print(f"🔧 总修复数: {results['total_fixes']}")
    print(f"📁 修改文件数: {results['files_modified']}")
    
    if results['modified_files']:
        print("\n📝 修改的文件:")
        for file_path in results['modified_files']:
            file_short = file_path.split('/')[-1]
            print(f"  - {file_short}")
    
    # 保存修复报告
    output_file = "api_reference_fix_report.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 修复报告已保存到: {output_file}")
    
    if results['total_fixes'] > 0:
        print("\n🎉 API 引用路径修复完成！")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
