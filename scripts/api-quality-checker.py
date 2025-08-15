#!/usr/bin/env python3
"""
API 设计质量检验工具
用于系统性检查 OpenAPI 规范的设计质量、一致性和合规性
"""

import os
import sys
import yaml
import json
import re
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple
from collections import defaultdict
import argparse

class APIQualityChecker:
    def __init__(self, base_path: str = "docs/api/4.5.1"):
        self.base_path = Path(base_path)
        self.issues = []
        self.warnings = []
        self.stats = defaultdict(int)
        
    def log_issue(self, category: str, severity: str, message: str, file_path: str = "", location: str = ""):
        """记录问题"""
        issue = {
            "category": category,
            "severity": severity,  # ERROR, WARNING, INFO
            "message": message,
            "file": file_path,
            "location": location
        }
        if severity == "ERROR":
            self.issues.append(issue)
        else:
            self.warnings.append(issue)
    
    def load_yaml_file(self, file_path: Path) -> Dict[str, Any]:
        """安全加载YAML文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            self.log_issue("FILE_LOAD", "ERROR", f"无法加载文件: {e}", str(file_path))
            return {}
    
    def check_restful_design(self, api_spec: Dict[str, Any], file_path: str):
        """检查RESTful设计原则"""
        print("🔍 检查 RESTful 设计原则...")
        
        paths = api_spec.get('paths', {})
        for path, methods in paths.items():
            if isinstance(methods, dict) and '$ref' not in methods:
                # 检查路径命名规范
                if not re.match(r'^/api/v\d+/', path):
                    self.log_issue("RESTFUL", "ERROR", f"路径应以 /api/v1/ 开头: {path}", file_path, path)
                
                # 检查资源命名（应使用复数）
                path_parts = path.strip('/').split('/')
                if len(path_parts) >= 3:
                    resource = path_parts[2]
                    if not resource.endswith('s') and not '{' in resource:
                        self.log_issue("RESTFUL", "WARNING", f"资源名称建议使用复数形式: {resource}", file_path, path)
                
                # 检查HTTP方法使用
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        self.check_http_method_usage(path, method.upper(), operation, file_path)
    
    def check_http_method_usage(self, path: str, method: str, operation: Dict, file_path: str):
        """检查HTTP方法使用是否合理"""
        # GET方法不应有requestBody
        if method == 'GET' and 'requestBody' in operation:
            self.log_issue("RESTFUL", "ERROR", f"GET方法不应包含requestBody: {path}", file_path, f"{path}:{method}")
        
        # POST/PUT/PATCH应该有适当的requestBody（除非是操作类接口）
        if method in ['POST', 'PUT', 'PATCH']:
            if 'requestBody' not in operation and not any(action in path for action in ['/execute', '/pause', '/resume', '/enable', '/disable']):
                self.log_issue("RESTFUL", "WARNING", f"{method}方法通常应包含requestBody: {path}", file_path, f"{path}:{method}")
        
        # DELETE方法通常不需要requestBody
        if method == 'DELETE' and 'requestBody' in operation:
            self.log_issue("RESTFUL", "WARNING", f"DELETE方法通常不需要requestBody: {path}", file_path, f"{path}:{method}")
    
    def check_naming_consistency(self, api_spec: Dict[str, Any], file_path: str):
        """检查命名一致性"""
        print("🔍 检查 API 命名一致性...")
        
        # 检查operationId命名规范
        paths = api_spec.get('paths', {})
        for path, methods in paths.items():
            if isinstance(methods, dict) and '$ref' not in methods:
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        operation_id = operation.get('operationId', '')
                        if operation_id:
                            # 检查operationId格式: domain_action
                            if not re.match(r'^[a-z]+_[a-z_]+$', operation_id):
                                self.log_issue("NAMING", "WARNING", 
                                              f"operationId应使用 domain_action 格式: {operation_id}", 
                                              file_path, f"{path}:{method}")
        
        # 检查Schema命名规范
        schemas = api_spec.get('components', {}).get('schemas', {})
        for schema_name in schemas.keys():
            # Schema名称应使用PascalCase
            if not re.match(r'^[A-Z][a-zA-Z0-9]*$', schema_name):
                self.log_issue("NAMING", "WARNING", 
                              f"Schema名称应使用PascalCase: {schema_name}", 
                              file_path, f"components.schemas.{schema_name}")
    
    def check_parameter_consistency(self, api_specs: Dict[str, Dict[str, Any]]):
        """检查参数全局一致性"""
        print("🔍 检查参数全局一致性...")
        
        # 收集所有参数定义
        param_definitions = defaultdict(list)
        
        for file_path, spec in api_specs.items():
            paths = spec.get('paths', {})
            for path, methods in paths.items():
                if isinstance(methods, dict) and '$ref' not in methods:
                    for method, operation in methods.items():
                        if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                            # 检查路径参数
                            parameters = operation.get('parameters', [])
                            for param in parameters:
                                if isinstance(param, dict) and '$ref' not in param:
                                    param_name = param.get('name', '')
                                    param_type = param.get('schema', {}).get('type', '')
                                    param_definitions[param_name].append({
                                        'type': param_type,
                                        'file': file_path,
                                        'location': f"{path}:{method}"
                                    })
        
        # 检查同名参数类型一致性
        for param_name, definitions in param_definitions.items():
            types = set(d['type'] for d in definitions if d['type'])
            if len(types) > 1:
                self.log_issue("CONSISTENCY", "ERROR", 
                              f"参数 '{param_name}' 在不同接口中使用了不同的数据类型: {types}", 
                              "", f"参数: {param_name}")
    
    def check_response_format_consistency(self, api_spec: Dict[str, Any], file_path: str):
        """检查响应格式标准化"""
        print("🔍 检查响应格式标准化...")
        
        paths = api_spec.get('paths', {})
        for path, methods in paths.items():
            if isinstance(methods, dict) and '$ref' not in methods:
                for method, operation in methods.items():
                    if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                        responses = operation.get('responses', {})
                        
                        # 检查200响应是否使用标准格式
                        if '200' in responses:
                            response_200 = responses['200']
                            content = response_200.get('content', {}).get('application/json', {})
                            schema = content.get('schema', {})
                            
                            # 检查是否使用了allOf引用全局ApiResponse
                            if 'allOf' in schema:
                                all_of = schema['allOf']
                                has_api_response = any(
                                    '$ref' in item and 'ApiResponse' in item['$ref'] 
                                    for item in all_of if isinstance(item, dict)
                                )
                                if not has_api_response:
                                    self.log_issue("RESPONSE_FORMAT", "WARNING", 
                                                  f"200响应建议引用全局ApiResponse: {path}", 
                                                  file_path, f"{path}:{method}")
                        
                        # 检查错误响应是否使用全局引用
                        error_codes = ['400', '401', '403', '404', '409', '422', '500']
                        for code in error_codes:
                            if code in responses:
                                response = responses[code]
                                if '$ref' not in response:
                                    self.log_issue("RESPONSE_FORMAT", "WARNING", 
                                                  f"{code}响应应引用全局错误响应: {path}", 
                                                  file_path, f"{path}:{method}")
    
    def check_tenant_id_support(self, api_spec: Dict[str, Any], file_path: str):
        """检查多租户支持"""
        print("🔍 检查多租户支持...")
        
        schemas = api_spec.get('components', {}).get('schemas', {})
        business_schemas = []
        
        # 识别业务Schema（排除请求/响应包装类）
        for schema_name, schema_def in schemas.items():
            if not any(suffix in schema_name for suffix in ['Request', 'Response', 'Info', 'Status', 'Log']):
                continue
            if schema_name in ['ApiResponse', 'PagedResponse', 'ErrorResponse']:
                continue
            business_schemas.append(schema_name)
        
        # 检查业务Schema是否包含tenant_id
        for schema_name in business_schemas:
            schema_def = schemas[schema_name]
            if isinstance(schema_def, dict):
                properties = schema_def.get('properties', {})
                if 'tenant_id' not in properties:
                    # 检查是否通过allOf继承
                    all_of = schema_def.get('allOf', [])
                    has_tenant_id = False
                    for item in all_of:
                        if isinstance(item, dict) and 'properties' in item:
                            if 'tenant_id' in item['properties']:
                                has_tenant_id = True
                                break
                    
                    if not has_tenant_id:
                        self.log_issue("MULTI_TENANT", "WARNING", 
                                      f"业务Schema建议包含tenant_id字段: {schema_name}", 
                                      file_path, f"components.schemas.{schema_name}")
    
    def check_mock_data_quality(self, api_spec: Dict[str, Any], file_path: str):
        """检查Mock数据质量"""
        print("🔍 检查 Mock 数据质量...")
        
        def check_example_value(value, field_name, location):
            """检查示例值质量"""
            if isinstance(value, str):
                # 检查是否使用了无意义的示例
                bad_examples = ['string', 'test', 'example', 'sample', '123', 'abc']
                if value.lower() in bad_examples:
                    self.log_issue("MOCK_DATA", "WARNING", 
                                  f"字段 '{field_name}' 使用了无意义的示例值: {value}", 
                                  file_path, location)
                
                # 检查时间格式
                if 'time' in field_name.lower() or 'date' in field_name.lower():
                    if not re.match(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$', value):
                        self.log_issue("MOCK_DATA", "WARNING", 
                                      f"时间字段应使用ISO8601 UTC格式: {field_name} = {value}", 
                                      file_path, location)
        
        # 检查Schema中的example
        schemas = api_spec.get('components', {}).get('schemas', {})
        for schema_name, schema_def in schemas.items():
            if isinstance(schema_def, dict):
                properties = schema_def.get('properties', {})
                for prop_name, prop_def in properties.items():
                    if isinstance(prop_def, dict) and 'example' in prop_def:
                        check_example_value(prop_def['example'], prop_name, 
                                          f"components.schemas.{schema_name}.properties.{prop_name}")
    
    def run_comprehensive_check(self) -> Dict[str, Any]:
        """运行全面检查"""
        print("🚀 开始 API 设计质量检验...")
        print("=" * 60)
        
        # 加载所有API规范文件
        api_specs = {}
        
        # 加载模块文件
        modules_dir = self.base_path / "modules"
        if modules_dir.exists():
            for module_dir in modules_dir.iterdir():
                if module_dir.is_dir():
                    openapi_file = module_dir / "openapi.yaml"
                    if openapi_file.exists():
                        spec = self.load_yaml_file(openapi_file)
                        if spec:
                            api_specs[str(openapi_file)] = spec
        
        # 加载域文件
        domains_dir = self.base_path / "domains"
        if domains_dir.exists():
            for domain_file in domains_dir.glob("*.yaml"):
                spec = self.load_yaml_file(domain_file)
                if spec:
                    api_specs[str(domain_file)] = spec
        
        # 加载全局文件
        global_file = self.base_path / "global-api-index.yaml"
        if global_file.exists():
            spec = self.load_yaml_file(global_file)
            if spec:
                api_specs[str(global_file)] = spec
        
        print(f"📁 加载了 {len(api_specs)} 个 API 规范文件")
        
        # 执行各项检查
        for file_path, spec in api_specs.items():
            print(f"\n📋 检查文件: {file_path}")
            
            # 1. RESTful设计检查
            self.check_restful_design(spec, file_path)
            
            # 2. 命名一致性检查
            self.check_naming_consistency(spec, file_path)
            
            # 3. 响应格式检查
            self.check_response_format_consistency(spec, file_path)
            
            # 4. 多租户支持检查
            self.check_tenant_id_support(spec, file_path)
            
            # 5. Mock数据质量检查
            self.check_mock_data_quality(spec, file_path)
        
        # 6. 跨文件一致性检查
        self.check_parameter_consistency(api_specs)
        
        return self.generate_report()
    
    def generate_report(self) -> Dict[str, Any]:
        """生成检查报告"""
        total_issues = len(self.issues)
        total_warnings = len(self.warnings)
        
        report = {
            "summary": {
                "total_errors": total_issues,
                "total_warnings": total_warnings,
                "total_checks": total_issues + total_warnings,
                "status": "PASS" if total_issues == 0 else "FAIL"
            },
            "issues": self.issues,
            "warnings": self.warnings,
            "stats": dict(self.stats)
        }
        
        return report

def main():
    parser = argparse.ArgumentParser(description='API设计质量检验工具')
    parser.add_argument('--base-path', default='docs/api/4.5.1', help='API文档基础路径')
    parser.add_argument('--output', help='输出报告文件路径')
    parser.add_argument('--format', choices=['json', 'yaml'], default='json', help='输出格式')
    
    args = parser.parse_args()
    
    checker = APIQualityChecker(args.base_path)
    report = checker.run_comprehensive_check()
    
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
    print("📊 检查结果摘要")
    print("=" * 60)
    print(f"🔴 错误: {report['summary']['total_errors']}")
    print(f"🟡 警告: {report['summary']['total_warnings']}")
    print(f"📈 状态: {report['summary']['status']}")
    
    if report['issues']:
        print(f"\n🔴 发现 {len(report['issues'])} 个错误:")
        for issue in report['issues'][:5]:  # 只显示前5个
            print(f"  - [{issue['category']}] {issue['message']}")
        if len(report['issues']) > 5:
            print(f"  ... 还有 {len(report['issues']) - 5} 个错误")
    
    if report['warnings']:
        print(f"\n🟡 发现 {len(report['warnings'])} 个警告:")
        for warning in report['warnings'][:5]:  # 只显示前5个
            print(f"  - [{warning['category']}] {warning['message']}")
        if len(report['warnings']) > 5:
            print(f"  ... 还有 {len(report['warnings']) - 5} 个警告")
    
    return 0 if report['summary']['total_errors'] == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
