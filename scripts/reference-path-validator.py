#!/usr/bin/env python3
"""
引用路径验证工具
专门检查 OpenAPI 文档中的 $ref 引用路径是否正确
"""

import os
import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any, Set
from urllib.parse import urlparse, unquote
import argparse

class ReferencePathValidator:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.issues = []
        self.resolved_refs = set()
        self.failed_refs = set()
        
    def log_issue(self, severity: str, message: str, file_path: str = "", ref_path: str = ""):
        """记录问题"""
        issue = {
            "severity": severity,
            "message": message,
            "file": file_path,
            "ref_path": ref_path
        }
        self.issues.append(issue)
    
    def load_yaml_file(self, file_path: Path) -> Dict[str, Any]:
        """安全加载YAML文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            self.log_issue("ERROR", f"无法加载文件: {e}", str(file_path))
            return {}
    
    def resolve_json_pointer(self, data: Dict[str, Any], pointer: str) -> Any:
        """解析JSON Pointer"""
        if not pointer.startswith('/'):
            return None
        
        parts = pointer[1:].split('/')
        current = data
        
        for part in parts:
            # 解码JSON Pointer特殊字符
            part = part.replace('~1', '/').replace('~0', '~')
            
            if isinstance(current, dict):
                if part in current:
                    current = current[part]
                else:
                    return None
            elif isinstance(current, list):
                try:
                    index = int(part)
                    if 0 <= index < len(current):
                        current = current[index]
                    else:
                        return None
                except ValueError:
                    return None
            else:
                return None
        
        return current
    
    def validate_reference(self, ref_path: str, source_file: Path) -> bool:
        """验证单个引用路径"""
        try:
            # 解析引用路径
            if '#' in ref_path:
                file_part, fragment = ref_path.split('#', 1)
            else:
                file_part, fragment = ref_path, ''
            
            # 解析目标文件路径
            if file_part:
                if file_part.startswith('./') or file_part.startswith('../'):
                    # 相对路径
                    target_file = (source_file.parent / file_part).resolve()
                else:
                    # 绝对路径（相对于base_path）
                    target_file = self.base_path / file_part
            else:
                # 同文件引用
                target_file = source_file
            
            # 检查目标文件是否存在
            if not target_file.exists():
                self.log_issue("ERROR", f"引用的文件不存在: {file_part}", str(source_file), ref_path)
                return False
            
            # 如果有fragment，验证JSON Pointer
            if fragment:
                target_data = self.load_yaml_file(target_file)
                if not target_data:
                    return False
                
                resolved = self.resolve_json_pointer(target_data, fragment)
                if resolved is None:
                    self.log_issue("ERROR", f"JSON Pointer路径不存在: {fragment}", str(source_file), ref_path)
                    return False
            
            return True
            
        except Exception as e:
            self.log_issue("ERROR", f"验证引用路径时出错: {e}", str(source_file), ref_path)
            return False
    
    def find_all_references(self, data: Any, current_path: str = "") -> List[str]:
        """递归查找所有$ref引用"""
        refs = []
        
        if isinstance(data, dict):
            for key, value in data.items():
                new_path = f"{current_path}.{key}" if current_path else key
                
                if key == '$ref' and isinstance(value, str):
                    refs.append(value)
                else:
                    refs.extend(self.find_all_references(value, new_path))
        elif isinstance(data, list):
            for i, item in enumerate(data):
                new_path = f"{current_path}[{i}]"
                refs.extend(self.find_all_references(item, new_path))
        
        return refs
    
    def check_json_pointer_encoding(self, ref_path: str, source_file: str):
        """检查JSON Pointer编码是否正确"""
        if '#' not in ref_path:
            return
        
        _, fragment = ref_path.split('#', 1)
        
        # 检查是否包含未编码的特殊字符
        if '/' in fragment and '~1' not in fragment:
            # 可能需要编码的路径
            parts = fragment.split('/')
            for part in parts:
                if part and not part.startswith('~'):
                    # 检查是否包含需要编码的字符
                    if '/' in part or '~' in part:
                        self.log_issue("WARNING", 
                                     f"JSON Pointer可能需要编码特殊字符: {fragment}", 
                                     source_file, ref_path)
                        break
    
    def validate_file_references(self, file_path: Path):
        """验证单个文件中的所有引用"""
        print(f"🔍 检查文件: {file_path}")
        
        data = self.load_yaml_file(file_path)
        if not data:
            return
        
        # 查找所有引用
        refs = self.find_all_references(data)
        
        print(f"  📎 找到 {len(refs)} 个引用")
        
        for ref in refs:
            # 检查JSON Pointer编码
            self.check_json_pointer_encoding(ref, str(file_path))
            
            # 验证引用路径
            if self.validate_reference(ref, file_path):
                self.resolved_refs.add(ref)
            else:
                self.failed_refs.add(ref)
    
    def check_circular_references(self, file_path: Path, visited: Set[str] = None, path_stack: List[str] = None):
        """检查循环引用"""
        if visited is None:
            visited = set()
        if path_stack is None:
            path_stack = []
        
        file_str = str(file_path)
        if file_str in visited:
            if file_str in path_stack:
                cycle = path_stack[path_stack.index(file_str):] + [file_str]
                self.log_issue("WARNING", f"检测到循环引用: {' -> '.join(cycle)}", file_str)
            return
        
        visited.add(file_str)
        path_stack.append(file_str)
        
        data = self.load_yaml_file(file_path)
        if data:
            refs = self.find_all_references(data)
            for ref in refs:
                if '#' in ref:
                    file_part, _ = ref.split('#', 1)
                    if file_part:
                        if file_part.startswith('./') or file_part.startswith('../'):
                            target_file = (file_path.parent / file_part).resolve()
                            if target_file.exists():
                                self.check_circular_references(target_file, visited.copy(), path_stack.copy())
        
        path_stack.pop()
    
    def validate_all_references(self) -> Dict[str, Any]:
        """验证所有引用路径"""
        print("🚀 开始引用路径验证...")
        print("=" * 60)
        
        # 收集所有需要检查的文件
        files_to_check = []
        
        # 模块文件
        modules_dir = self.base_path / "modules"
        if modules_dir.exists():
            for module_dir in modules_dir.iterdir():
                if module_dir.is_dir():
                    openapi_file = module_dir / "openapi.yaml"
                    if openapi_file.exists():
                        files_to_check.append(openapi_file)
        
        # 域文件
        domains_dir = self.base_path / "domains"
        if domains_dir.exists():
            for domain_file in domains_dir.glob("*.yaml"):
                files_to_check.append(domain_file)
        
        # 全局文件
        global_file = self.base_path / "global-api-index.yaml"
        if global_file.exists():
            files_to_check.append(global_file)
        
        print(f"📁 找到 {len(files_to_check)} 个文件需要检查")
        
        # 验证每个文件的引用
        for file_path in files_to_check:
            self.validate_file_references(file_path)
        
        # 检查循环引用
        print("\n🔄 检查循环引用...")
        for file_path in files_to_check:
            self.check_circular_references(file_path)
        
        return self.generate_report()
    
    def generate_report(self) -> Dict[str, Any]:
        """生成验证报告"""
        total_refs = len(self.resolved_refs) + len(self.failed_refs)
        success_rate = len(self.resolved_refs) / total_refs * 100 if total_refs > 0 else 100
        
        report = {
            "summary": {
                "total_references": total_refs,
                "resolved_references": len(self.resolved_refs),
                "failed_references": len(self.failed_refs),
                "success_rate": round(success_rate, 2),
                "total_issues": len(self.issues),
                "status": "PASS" if len(self.failed_refs) == 0 else "FAIL"
            },
            "issues": self.issues,
            "resolved_refs": list(self.resolved_refs),
            "failed_refs": list(self.failed_refs)
        }
        
        return report

def main():
    parser = argparse.ArgumentParser(description='引用路径验证工具')
    parser.add_argument('--base-path', default='docs/api/4.5.1', help='API文档基础路径')
    parser.add_argument('--output', help='输出报告文件路径')
    parser.add_argument('--format', choices=['json', 'yaml'], default='json', help='输出格式')
    
    args = parser.parse_args()
    
    validator = ReferencePathValidator(args.base_path)
    report = validator.validate_all_references()
    
    # 输出报告
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            if args.format == 'yaml':
                yaml.dump(report, f, default_flow_style=False, allow_unicode=True)
            else:
                json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"\n📄 报告已保存到: {args.output}")
    
    # 控制台输出摘要
    print("\n" + "=" * 60)
    print("📊 引用路径验证结果")
    print("=" * 60)
    print(f"📎 总引用数: {report['summary']['total_references']}")
    print(f"✅ 成功解析: {report['summary']['resolved_references']}")
    print(f"❌ 解析失败: {report['summary']['failed_references']}")
    print(f"📈 成功率: {report['summary']['success_rate']}%")
    print(f"🔴 问题总数: {report['summary']['total_issues']}")
    print(f"📊 状态: {report['summary']['status']}")
    
    if report['issues']:
        print(f"\n🔴 发现的问题:")
        for issue in report['issues']:
            print(f"  - [{issue['severity']}] {issue['message']}")
            if issue['ref_path']:
                print(f"    引用: {issue['ref_path']}")
    
    return 0 if report['summary']['failed_references'] == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
