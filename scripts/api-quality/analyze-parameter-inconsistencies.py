#!/usr/bin/env python3
"""
参数类型不一致性分析工具
用于详细分析 API 文档中参数类型不一致的具体位置和建议修复方案
"""

import os
import sys
import yaml
import json
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple
from collections import defaultdict

class ParameterInconsistencyAnalyzer:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.param_definitions = defaultdict(list)
        self.inconsistent_params = {}
        
    def load_yaml_file(self, file_path: Path) -> Dict[str, Any]:
        """安全加载YAML文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ 无法加载文件 {file_path}: {e}")
            return {}
    
    def extract_parameters_from_spec(self, spec: Dict[str, Any], file_path: str):
        """从API规范中提取所有参数定义"""
        paths = spec.get('paths', {})
        
        for path, methods in paths.items():
            if isinstance(methods, dict) and '$ref' not in methods:
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        # 提取路径参数
                        parameters = operation.get('parameters', [])
                        for param in parameters:
                            if isinstance(param, dict) and '$ref' not in param:
                                param_name = param.get('name', '')
                                param_schema = param.get('schema', {})
                                param_type = param_schema.get('type', '')
                                
                                if param_name and param_type:
                                    self.param_definitions[param_name].append({
                                        'type': param_type,
                                        'file': file_path,
                                        'location': f"{path}:{method}",
                                        'in': param.get('in', ''),
                                        'schema': param_schema
                                    })
    
    def analyze_inconsistencies(self):
        """分析参数类型不一致性"""
        print("🔍 分析参数类型不一致性...")
        
        for param_name, definitions in self.param_definitions.items():
            # 收集所有类型
            types = set()
            for def_info in definitions:
                param_type = def_info['type']
                # 处理数组类型
                if param_type == 'array':
                    items_type = def_info['schema'].get('items', {}).get('type', 'unknown')
                    types.add(f"array<{items_type}>")
                else:
                    types.add(param_type)
            
            # 如果有多种类型，记录为不一致
            if len(types) > 1:
                self.inconsistent_params[param_name] = {
                    'types': list(types),
                    'definitions': definitions,
                    'count': len(definitions)
                }
    
    def generate_fix_recommendations(self, param_name: str, param_info: Dict) -> Dict[str, Any]:
        """为特定参数生成修复建议"""
        definitions = param_info['definitions']
        types = param_info['types']
        
        # 分析使用模式
        type_usage = defaultdict(list)
        for def_info in definitions:
            param_type = def_info['type']
            if param_type == 'array':
                items_type = def_info['schema'].get('items', {}).get('type', 'unknown')
                type_key = f"array<{items_type}>"
            else:
                type_key = param_type
            type_usage[type_key].append(def_info)
        
        # 确定推荐类型
        recommended_type = self._determine_recommended_type(param_name, type_usage)
        
        # 生成修复计划
        fixes = []
        for type_key, usages in type_usage.items():
            if type_key != recommended_type:
                for usage in usages:
                    fixes.append({
                        'file': usage['file'],
                        'location': usage['location'],
                        'current_type': type_key,
                        'recommended_type': recommended_type,
                        'action': 'change_type'
                    })
        
        return {
            'parameter': param_name,
            'current_types': types,
            'recommended_type': recommended_type,
            'reasoning': self._get_type_reasoning(param_name, recommended_type),
            'fixes': fixes,
            'total_occurrences': len(definitions),
            'files_to_modify': len(set(fix['file'] for fix in fixes))
        }
    
    def _determine_recommended_type(self, param_name: str, type_usage: Dict) -> str:
        """根据参数名称和使用模式确定推荐类型"""
        # 基于参数名称的类型推断规则
        name_lower = param_name.lower()
        
        # ID类参数通常应该是string（考虑到UUID等）
        if name_lower.endswith('_id') or name_lower == 'id':
            return 'string'
        
        # 状态、优先级、级别等枚举类参数
        if name_lower in ['status', 'priority', 'level', 'role_type', 'task_type']:
            # 如果有数组使用，可能是多选过滤，但单个值应该是string
            if any('array' in t for t in type_usage.keys()):
                return 'array<string>'
            return 'string'
        
        # 时间范围参数
        if 'time' in name_lower and 'range' in name_lower:
            return 'string'  # 通常是时间范围字符串如 "7d", "1m"
        
        # 结果类参数
        if name_lower == 'result':
            return 'string'  # 通常是枚举值
        
        # 默认选择使用最多的类型
        max_usage = max(type_usage.items(), key=lambda x: len(x[1]))
        return max_usage[0]
    
    def _get_type_reasoning(self, param_name: str, recommended_type: str) -> str:
        """获取类型推荐的理由"""
        name_lower = param_name.lower()
        
        if name_lower.endswith('_id') or name_lower == 'id':
            return "ID类参数建议使用string类型，支持UUID等非数字ID格式"
        
        if name_lower in ['status', 'priority', 'level']:
            if recommended_type.startswith('array'):
                return "状态/优先级/级别参数支持多选过滤时使用array<string>"
            return "状态/优先级/级别参数建议使用string类型表示枚举值"
        
        if name_lower in ['role_type', 'task_type']:
            return "类型参数建议使用string类型表示枚举值"
        
        if 'time' in name_lower and 'range' in name_lower:
            return "时间范围参数建议使用string类型，如'7d', '1m', '3h'"
        
        if name_lower == 'result':
            return "结果参数建议使用string类型表示枚举值"
        
        return f"基于使用频率分析，推荐使用{recommended_type}类型"
    
    def run_analysis(self) -> Dict[str, Any]:
        """运行完整分析"""
        print("🚀 开始参数类型不一致性分析...")
        print("=" * 60)
        
        # 加载所有API规范文件
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
        
        # 提取所有参数定义
        for file_path in api_files:
            spec = self.load_yaml_file(file_path)
            if spec:
                self.extract_parameters_from_spec(spec, str(file_path))
        
        print(f"📊 提取了 {len(self.param_definitions)} 个不同的参数")
        
        # 分析不一致性
        self.analyze_inconsistencies()
        
        print(f"❌ 发现 {len(self.inconsistent_params)} 个参数存在类型不一致")
        
        # 生成修复建议
        fix_recommendations = {}
        for param_name, param_info in self.inconsistent_params.items():
            fix_recommendations[param_name] = self.generate_fix_recommendations(param_name, param_info)
        
        return {
            'total_parameters': len(self.param_definitions),
            'inconsistent_parameters': len(self.inconsistent_params),
            'inconsistent_details': self.inconsistent_params,
            'fix_recommendations': fix_recommendations
        }

def main():
    analyzer = ParameterInconsistencyAnalyzer()
    results = analyzer.run_analysis()
    
    # 输出详细报告
    print("\n" + "=" * 60)
    print("📋 参数类型不一致性详细报告")
    print("=" * 60)
    
    for param_name, recommendation in results['fix_recommendations'].items():
        print(f"\n🔧 参数: {param_name}")
        print(f"   当前类型: {', '.join(recommendation['current_types'])}")
        print(f"   推荐类型: {recommendation['recommended_type']}")
        print(f"   理由: {recommendation['reasoning']}")
        print(f"   总出现次数: {recommendation['total_occurrences']}")
        print(f"   需修改文件数: {recommendation['files_to_modify']}")
        
        if recommendation['fixes']:
            print("   需要修改的位置:")
            for fix in recommendation['fixes'][:3]:  # 只显示前3个
                file_short = fix['file'].split('/')[-2] + '/' + fix['file'].split('/')[-1]
                print(f"     - {file_short} ({fix['location']})")
            if len(recommendation['fixes']) > 3:
                print(f"     ... 还有 {len(recommendation['fixes']) - 3} 个位置")
    
    # 保存详细报告
    output_file = "parameter_inconsistency_report.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    
    print(f"\n📄 详细报告已保存到: {output_file}")
    
    return 0 if results['inconsistent_parameters'] == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
