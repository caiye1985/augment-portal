#!/usr/bin/env python3
"""
全局索引同步工具
同步更新全局索引文件中的路径，确保与域文件一致
"""

import os
import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple

class GlobalIndexSyncer:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.fixes_applied = 0
        
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
    
    def sync_global_index(self) -> int:
        """同步全局索引文件"""
        global_file = self.base_path / "global-api-index.yaml"
        if not global_file.exists():
            print("❌ 全局索引文件不存在")
            return 0
        
        print(f"📝 同步全局索引文件: {global_file.name}")
        
        spec = self.load_yaml_file(global_file)
        if not spec:
            return 0
        
        fixes_in_file = 0
        paths = spec.get('paths', {})
        new_paths = {}
        
        for path, methods in paths.items():
            # 更新路径本身
            new_path = path
            for old_path, new_path_replacement in self.path_mappings.items():
                if old_path in path:
                    new_path = path.replace(old_path, new_path_replacement)
                    print(f"    ✅ 更新路径: {path} -> {new_path}")
                    fixes_in_file += 1
                    break
            
            new_paths[new_path] = methods
        
        if fixes_in_file > 0:
            spec['paths'] = new_paths
            if self.save_yaml_file(global_file, spec):
                print(f"  💾 已保存 {fixes_in_file} 个路径更新")
            else:
                print(f"  ❌ 保存失败")
                fixes_in_file = 0
        else:
            print(f"  ✅ 无需更新")
        
        return fixes_in_file
    
    def run_sync(self) -> Dict[str, Any]:
        """运行同步"""
        print("🚀 开始同步全局索引...")
        print("=" * 60)
        
        fixes = self.sync_global_index()
        self.fixes_applied += fixes
        
        return {
            'total_fixes': self.fixes_applied,
            'files_modified': 1 if fixes > 0 else 0
        }

def main():
    # 切换到正确的目录
    if os.getcwd().endswith('docs/api/4.5.1'):
        base_path = "."
    else:
        base_path = "docs/api/4.5.1"
    
    syncer = GlobalIndexSyncer(base_path)
    results = syncer.run_sync()
    
    print("\n" + "=" * 60)
    print("📊 全局索引同步结果摘要")
    print("=" * 60)
    print(f"🔧 总修复数: {results['total_fixes']}")
    print(f"📁 修改文件数: {results['files_modified']}")
    
    # 保存同步报告
    output_file = "global_index_sync_report.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 同步报告已保存到: {output_file}")
    
    if results['total_fixes'] > 0:
        print("\n🎉 全局索引同步完成！")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
