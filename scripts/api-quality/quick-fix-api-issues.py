#!/usr/bin/env python3
"""
API 问题快速修复工具
自动修复常见的 API 设计问题，如参数类型不一致、命名规范等
"""

import os
import sys
import yaml
import json
import re
from pathlib import Path
from typing import Dict, List, Any, Set
import argparse

class APIQuickFixer:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.fixes_applied = []
        self.backup_dir = Path("backups/api-fixes")
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        
    def log_fix(self, fix_type: str, file_path: str, description: str):
        """记录修复操作"""
        fix = {
            "type": fix_type,
            "file": file_path,
            "description": description,
            "timestamp": "2024-08-16T14:30:00Z"
        }
        self.fixes_applied.append(fix)
        print(f"✅ {fix_type}: {description} ({file_path})")
    
    def backup_file(self, file_path: Path):
        """备份文件"""
        if file_path.exists():
            backup_path = self.backup_dir / file_path.name
            backup_path.write_text(file_path.read_text(encoding='utf-8'), encoding='utf-8')
            print(f"📄 备份文件: {backup_path}")
    
    def load_yaml_file(self, file_path: Path) -> Dict[str, Any]:
        """安全加载YAML文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"❌ 无法加载文件 {file_path}: {e}")
            return {}
    
    def save_yaml_file(self, file_path: Path, data: Dict[str, Any]):
        """保存YAML文件"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                yaml.dump(data, f, default_flow_style=False, allow_unicode=True, sort_keys=False)
        except Exception as e:
            print(f"❌ 无法保存文件 {file_path}: {e}")
    
    def fix_parameter_types(self, file_path: Path):
        """修复参数类型不一致问题"""
        data = self.load_yaml_file(file_path)
        if not data:
            return
        
        self.backup_file(file_path)
        modified = False
        
        # 标准化常见参数类型
        standard_params = {
            'page': {'type': 'integer', 'minimum': 1, 'default': 1},
            'size': {'type': 'integer', 'minimum': 1, 'maximum': 100, 'default': 20},
            'id': {'type': 'integer'},
            'task_id': {'type': 'integer'},
            'model_id': {'type': 'integer'},
            'dataset_id': {'type': 'integer'},
            'result_id': {'type': 'integer'},
            'priority': {'type': 'integer', 'minimum': 1, 'maximum': 3}
        }
        
        # 修复路径参数
        paths = data.get('paths', {})
        for path, methods in paths.items():
            if isinstance(methods, dict) and '$ref' not in methods:
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        parameters = operation.get('parameters', [])
                        for param in parameters:
                            if isinstance(param, dict) and '$ref' not in param:
                                param_name = param.get('name', '')
                                if param_name in standard_params:
                                    old_schema = param.get('schema', {})
                                    new_schema = standard_params[param_name].copy()
                                    if 'example' in old_schema:
                                        new_schema['example'] = old_schema['example']
                                    param['schema'] = new_schema
                                    modified = True
        
        # 修复Schema中的属性类型
        schemas = data.get('components', {}).get('schemas', {})
        for schema_name, schema_def in schemas.items():
            if isinstance(schema_def, dict):
                properties = schema_def.get('properties', {})
                for prop_name, prop_def in properties.items():
                    if isinstance(prop_def, dict) and prop_name in standard_params:
                        old_type = prop_def.get('type')
                        new_type = standard_params[prop_name]['type']
                        if old_type != new_type:
                            prop_def.update(standard_params[prop_name])
                            modified = True
        
        if modified:
            self.save_yaml_file(file_path, data)
            self.log_fix("PARAMETER_TYPE", str(file_path), "标准化参数类型定义")
    
    def fix_operation_ids(self, file_path: Path):
        """修复operationId命名规范"""
        data = self.load_yaml_file(file_path)
        if not data:
            return
        
        # 确定模块域名
        domain = "unknown"
        if "REQ-023" in str(file_path):
            domain = "analytics"
        elif "REQ-003" in str(file_path):
            domain = "ticket"
        elif "REQ-016" in str(file_path):
            domain = "customer"
        # 可以根据需要添加更多模块映射
        
        modified = False
        paths = data.get('paths', {})
        
        for path, methods in paths.items():
            if isinstance(methods, dict) and '$ref' not in methods:
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        current_id = operation.get('operationId', '')
                        if current_id:
                            # 检查是否符合规范
                            if not re.match(r'^[a-z]+_[a-z_]+$', current_id):
                                # 尝试生成标准的operationId
                                action = self.infer_action_from_path_method(path, method.upper())
                                new_id = f"{domain}_{action}"
                                
                                if new_id != current_id:
                                    self.backup_file(file_path)
                                    operation['operationId'] = new_id
                                    modified = True
        
        if modified:
            self.save_yaml_file(file_path, data)
            self.log_fix("OPERATION_ID", str(file_path), "规范化operationId命名")
    
    def infer_action_from_path_method(self, path: str, method: str) -> str:
        """从路径和方法推断操作名称"""
        # 提取资源名称
        parts = path.strip('/').split('/')
        resource = parts[-1] if parts else "unknown"
        
        # 移除路径参数
        resource = re.sub(r'\{[^}]+\}', '', resource).strip('-')
        
        # 根据HTTP方法确定动作
        action_map = {
            'GET': 'get' if '{' in path else 'list',
            'POST': 'create',
            'PUT': 'update',
            'PATCH': 'update',
            'DELETE': 'delete'
        }
        
        base_action = action_map.get(method, 'unknown')
        
        # 处理特殊操作
        if 'execute' in resource:
            return 'execute'
        elif 'pause' in resource:
            return 'pause'
        elif 'resume' in resource:
            return 'resume'
        elif 'export' in resource:
            return 'export'
        elif 'train' in resource:
            return 'train'
        elif 'predict' in resource:
            return 'predict'
        
        return base_action
    
    def fix_mock_data_quality(self, file_path: Path):
        """修复Mock数据质量"""
        data = self.load_yaml_file(file_path)
        if not data:
            return
        
        modified = False
        
        # 不良示例值映射
        bad_examples = {
            'string': '运营效率分析任务',
            'test': '月度客户满意度分析',
            'example': '工单处理时间预测',
            'sample': '系统性能监控报告',
            '123': '12345',
            'abc': 'TK-20240814-001'
        }
        
        def fix_example_recursive(obj, path=""):
            nonlocal modified
            if isinstance(obj, dict):
                for key, value in obj.items():
                    if key == 'example' and isinstance(value, str):
                        if value.lower() in bad_examples:
                            obj[key] = bad_examples[value.lower()]
                            modified = True
                    else:
                        fix_example_recursive(value, f"{path}.{key}")
            elif isinstance(obj, list):
                for i, item in enumerate(obj):
                    fix_example_recursive(item, f"{path}[{i}]")
        
        fix_example_recursive(data)
        
        if modified:
            self.backup_file(file_path)
            self.save_yaml_file(file_path, data)
            self.log_fix("MOCK_DATA", str(file_path), "改进Mock数据质量")
    
    def fix_tenant_id_support(self, file_path: Path):
        """添加tenant_id支持"""
        data = self.load_yaml_file(file_path)
        if not data:
            return
        
        modified = False
        schemas = data.get('components', {}).get('schemas', {})
        
        # 需要添加tenant_id的Schema类型
        business_schema_patterns = [
            r'.*Info$',
            r'.*Detail.*$',
            r'.*Task.*$',
            r'.*Model.*$',
            r'.*Dataset.*$',
            r'.*Result.*$'
        ]
        
        for schema_name, schema_def in schemas.items():
            if isinstance(schema_def, dict):
                # 检查是否是业务Schema
                is_business_schema = any(
                    re.match(pattern, schema_name) 
                    for pattern in business_schema_patterns
                )
                
                if is_business_schema:
                    properties = schema_def.get('properties', {})
                    if 'tenant_id' not in properties:
                        self.backup_file(file_path)
                        properties['tenant_id'] = {
                            'type': 'integer',
                            'description': '租户ID',
                            'example': 1001
                        }
                        modified = True
        
        if modified:
            self.save_yaml_file(file_path, data)
            self.log_fix("TENANT_ID", str(file_path), "添加tenant_id字段支持")
    
    def fix_file(self, file_path: Path):
        """修复单个文件"""
        print(f"\n🔧 修复文件: {file_path}")
        
        # 应用各种修复
        self.fix_parameter_types(file_path)
        self.fix_operation_ids(file_path)
        self.fix_mock_data_quality(file_path)
        self.fix_tenant_id_support(file_path)
    
    def fix_all_modules(self):
        """修复所有模块文件"""
        print("🚀 开始批量修复 API 问题...")
        
        # 修复模块文件
        modules_dir = self.base_path / "modules"
        if modules_dir.exists():
            for module_dir in modules_dir.iterdir():
                if module_dir.is_dir():
                    openapi_file = module_dir / "openapi.yaml"
                    if openapi_file.exists():
                        self.fix_file(openapi_file)
        
        return self.generate_report()
    
    def fix_specific_module(self, module_name: str):
        """修复特定模块"""
        print(f"🚀 修复模块: {module_name}")
        
        module_dir = self.base_path / "modules" / module_name
        openapi_file = module_dir / "openapi.yaml"
        
        if openapi_file.exists():
            self.fix_file(openapi_file)
        else:
            print(f"❌ 模块文件不存在: {openapi_file}")
        
        return self.generate_report()
    
    def generate_report(self) -> Dict[str, Any]:
        """生成修复报告"""
        report = {
            "summary": {
                "total_fixes": len(self.fixes_applied),
                "fix_types": list(set(fix["type"] for fix in self.fixes_applied)),
                "files_modified": list(set(fix["file"] for fix in self.fixes_applied))
            },
            "fixes": self.fixes_applied
        }
        
        return report

def main():
    parser = argparse.ArgumentParser(description='API问题快速修复工具')
    parser.add_argument('--base-path', default='docs/api/4.5.1', help='API文档基础路径')
    parser.add_argument('--module', help='指定要修复的模块名称')
    parser.add_argument('--output', help='输出修复报告文件路径')
    
    args = parser.parse_args()
    
    fixer = APIQuickFixer(args.base_path)
    
    if args.module:
        report = fixer.fix_specific_module(args.module)
    else:
        report = fixer.fix_all_modules()
    
    # 输出报告
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"\n📄 修复报告已保存到: {args.output}")
    
    # 控制台输出摘要
    print("\n" + "=" * 60)
    print("📊 修复结果摘要")
    print("=" * 60)
    print(f"🔧 总修复数: {report['summary']['total_fixes']}")
    print(f"📁 修改文件数: {len(report['summary']['files_modified'])}")
    print(f"🏷️  修复类型: {', '.join(report['summary']['fix_types'])}")
    
    if report['fixes']:
        print(f"\n✅ 应用的修复:")
        for fix in report['fixes']:
            print(f"  - [{fix['type']}] {fix['description']}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
