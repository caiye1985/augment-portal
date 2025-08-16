#!/usr/bin/env python3
"""
增强的三级API文档质量保证验证脚本
支持模块级→业务域级→全局索引级的完整性检查、一致性验证和自动化检测
"""

import yaml
import sys
import os
import glob
import json
import argparse
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from collections import defaultdict

@dataclass
class ValidationResult:
    """验证结果数据类"""
    success: bool
    message: str
    details: List[str] = None
    
    def __post_init__(self):
        if self.details is None:
            self.details = []

@dataclass
class APIPath:
    """API路径数据类"""
    path: str
    module: str
    domain: str = None
    in_global: bool = False

class ThreeTierAPIValidator:
    """三级API文档验证器"""
    
    def __init__(self, base_dir: str = "."):
        self.base_dir = Path(base_dir)
        self.module_to_domain_mapping = self._load_mapping()
        self.validation_results = []
        
    def _load_mapping(self) -> Dict[str, str]:
        """加载模块到业务域的映射关系"""
        config_file = self.base_dir / "api-mapping-config.yaml"

        if config_file.exists():
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = yaml.safe_load(f)

                mapping = config.get('module_to_domain_mapping', {})
                print(f"✅ 从配置文件加载映射关系: {len(mapping)} 个模块")
                return mapping

            except Exception as e:
                print(f"⚠️ 加载配置文件失败，使用默认映射: {e}")

        # 默认映射关系（向后兼容）
        return {
            'REQ-006-工程师管理系统': 'engineer-domain',
            'REQ-005-知识库管理系统': 'knowledge-domain',
            'REQ-011-通知与消息系统': 'notification-domain',
            'REQ-012-系统集成模块': 'integration-domain',
            'REQ-015-用户体验增强系统': 'experience-domain',
            'REQ-020-移动端应用模块': 'client-domain',
            'REQ-023-数据分析与商业智能模块': 'data-domain',
            'REQ-013-智能分析与AI功能': 'data-domain',
            'REQ-001-基础架构模块': 'auth-domain',
            'REQ-022-用户与权限管理模块': 'auth-domain',
            'REQ-021-资源权限管理模块': 'auth-domain',
            'REQ-003-工单管理系统': 'ticket-domain',
            'REQ-004-智能派单系统': 'ticket-domain',
            'REQ-016-客户关系管理模块': 'customer-domain',
            'REQ-017-SLA管理模块': 'sla-domain',
            'REQ-018-财务管理模块': 'finance-domain',
            'REQ-008-系统设置': 'system-domain',
            'REQ-010-系统管理模块': 'system-domain',
            'REQ-009-运维管理': 'ops-domain',
            'REQ-002-工作台与仪表板': 'portal-domain',
            'REQ-019-客户自助服务模块': 'portal-domain',
            'REQ-014-工作流引擎系统': 'workflow-domain',
        }
    
    def extract_api_paths_from_module(self, module_file: Path) -> List[str]:
        """从模块文件中提取所有API路径"""
        try:
            with open(module_file, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            if 'paths' not in data:
                return []
            
            return list(data['paths'].keys())
        except Exception as e:
            print(f"❌ 读取模块文件失败 {module_file}: {e}")
            return []
    
    def extract_api_paths_from_domain(self, domain_file: Path) -> List[str]:
        """从业务域文件中提取所有API路径"""
        try:
            with open(domain_file, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            if 'paths' not in data:
                return []
            
            return list(data['paths'].keys())
        except Exception as e:
            print(f"❌ 读取业务域文件失败 {domain_file}: {e}")
            return []
    
    def extract_api_paths_from_global(self, global_file: Path) -> List[str]:
        """从全局索引文件中提取所有API路径"""
        try:
            with open(global_file, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)
            
            if 'paths' not in data:
                return []
            
            return list(data['paths'].keys())
        except Exception as e:
            print(f"❌ 读取全局索引文件失败 {global_file}: {e}")
            return []
    
    def find_all_files(self) -> Dict[str, List[Path]]:
        """查找所有API文件"""
        files = {
            'modules': [],
            'domains': [],
            'global': None
        }
        
        # 查找模块文件
        module_pattern = self.base_dir / "modules" / "*" / "openapi.yaml"
        for file_path in glob.glob(str(module_pattern)):
            files['modules'].append(Path(file_path))
        
        # 查找业务域文件
        domain_pattern = self.base_dir / "domains" / "*-domain.yaml"
        for file_path in glob.glob(str(domain_pattern)):
            files['domains'].append(Path(file_path))
        
        # 查找全局索引文件
        global_file = self.base_dir / "global-api-index.yaml"
        if global_file.exists():
            files['global'] = global_file
        
        return files
    
    def validate_module_to_domain_completeness(self) -> ValidationResult:
        """验证模块到业务域的完整性"""
        print("🔍 第一级检查：模块 → 业务域完整性")
        print("-" * 50)
        
        files = self.find_all_files()
        issues = []
        total_missing = 0
        
        for module_file in files['modules']:
            # 提取模块名称
            module_name = module_file.parent.name
            
            # 查找对应的业务域
            if module_name not in self.module_to_domain_mapping:
                issues.append(f"❌ 模块 {module_name} 没有映射到业务域")
                continue
            
            domain_name = self.module_to_domain_mapping[module_name]
            domain_file = self.base_dir / "domains" / f"{domain_name}.yaml"
            
            if not domain_file.exists():
                issues.append(f"❌ 业务域文件不存在: {domain_file}")
                continue
            
            # 提取API路径
            module_apis = set(self.extract_api_paths_from_module(module_file))
            domain_apis = set(self.extract_api_paths_from_domain(domain_file))
            
            # 检查遗漏
            missing_apis = module_apis - domain_apis
            if missing_apis:
                total_missing += len(missing_apis)
                issues.append(f"❌ {domain_name}.yaml 遗漏 {len(missing_apis)} 个API:")
                for api in sorted(missing_apis):
                    issues.append(f"   - {api}")
            else:
                print(f"✅ {domain_name}.yaml 完整包含 {module_name} 的所有 {len(module_apis)} 个API")
        
        if issues:
            return ValidationResult(
                success=False,
                message=f"发现 {total_missing} 个API路径遗漏",
                details=issues
            )
        else:
            return ValidationResult(
                success=True,
                message="所有模块API都已正确映射到业务域"
            )
    
    def validate_domain_to_global_completeness(self) -> ValidationResult:
        """验证业务域到全局索引的完整性"""
        print("\n🔍 第二级检查：业务域 → 全局索引完整性")
        print("-" * 50)
        
        files = self.find_all_files()
        if not files['global']:
            return ValidationResult(
                success=False,
                message="全局索引文件不存在"
            )
        
        issues = []
        total_missing = 0
        
        # 提取全局索引中的所有API
        global_apis = set(self.extract_api_paths_from_global(files['global']))
        
        for domain_file in files['domains']:
            domain_name = domain_file.stem
            domain_apis = set(self.extract_api_paths_from_domain(domain_file))
            
            # 检查遗漏
            missing_apis = domain_apis - global_apis
            if missing_apis:
                total_missing += len(missing_apis)
                issues.append(f"❌ global-api-index.yaml 遗漏 {domain_name} 的 {len(missing_apis)} 个API:")
                for api in sorted(missing_apis):
                    issues.append(f"   - {api}")
            else:
                print(f"✅ global-api-index.yaml 完整包含 {domain_name} 的所有 {len(domain_apis)} 个API")
        
        if issues:
            return ValidationResult(
                success=False,
                message=f"全局索引遗漏 {total_missing} 个API路径",
                details=issues
            )
        else:
            return ValidationResult(
                success=True,
                message="全局索引完整包含所有业务域API"
            )

    def validate_reference_paths(self) -> ValidationResult:
        """验证所有引用路径的有效性"""
        print("\n🔍 第三级检查：引用路径验证")
        print("-" * 50)

        files = self.find_all_files()
        issues = []

        # 检查所有文件的引用
        all_files = files['domains'] + files['modules']
        if files['global']:
            all_files.append(files['global'])

        for file_path in all_files:
            file_issues = self._validate_file_references(file_path)
            if file_issues:
                issues.extend(file_issues)
            else:
                print(f"✅ {file_path.name} 所有引用路径有效")

        if issues:
            return ValidationResult(
                success=False,
                message=f"发现 {len(issues)} 个引用路径问题",
                details=issues
            )
        else:
            return ValidationResult(
                success=True,
                message="所有引用路径验证通过"
            )

    def _validate_file_references(self, file_path: Path) -> List[str]:
        """验证单个文件的引用路径"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                data = yaml.safe_load(f)

            issues = []

            def check_refs_recursive(obj, path=""):
                if isinstance(obj, dict):
                    for key, value in obj.items():
                        current_path = f"{path}.{key}" if path else key
                        if key == "$ref" and isinstance(value, str):
                            if not self._validate_single_reference(file_path, value):
                                issues.append(f"❌ {file_path.name}: 无效引用 {current_path} -> {value}")
                        else:
                            check_refs_recursive(value, current_path)
                elif isinstance(obj, list):
                    for i, item in enumerate(obj):
                        check_refs_recursive(item, f"{path}[{i}]")

            check_refs_recursive(data)
            return issues

        except Exception as e:
            return [f"❌ {file_path.name}: 文件读取失败 - {e}"]

    def _validate_single_reference(self, file_path: Path, ref_path: str) -> bool:
        """验证单个引用路径"""
        try:
            if ref_path.startswith('#/'):
                # 内部引用，简化处理
                return True
            else:
                # 外部引用
                if '#/' in ref_path:
                    file_ref, json_pointer = ref_path.split('#/', 1)
                else:
                    file_ref = ref_path
                    json_pointer = ""

                # 解析相对路径
                target_file = file_path.parent / file_ref
                target_file = target_file.resolve()

                # 检查目标文件是否存在
                if not target_file.exists():
                    return False

                # 如果有JSON指针，检查目标路径
                if json_pointer:
                    try:
                        with open(target_file, 'r', encoding='utf-8') as f:
                            target_data = yaml.safe_load(f)

                        # 简化的JSON指针解析
                        parts = json_pointer.split('/')
                        current = target_data
                        for part in parts:
                            if part:
                                part = part.replace('~1', '/').replace('~0', '~')
                                if isinstance(current, dict) and part in current:
                                    current = current[part]
                                else:
                                    return False
                        return True
                    except:
                        return False

                return True
        except:
            return False

    def generate_completeness_report(self) -> Dict:
        """生成完整性报告"""
        print("\n📊 生成完整性报告")
        print("-" * 50)

        files = self.find_all_files()
        report = {
            'summary': {},
            'modules': {},
            'domains': {},
            'global': {},
            'mapping_coverage': {}
        }

        # 统计模块信息
        for module_file in files['modules']:
            module_name = module_file.parent.name
            api_count = len(self.extract_api_paths_from_module(module_file))

            domain_name = self.module_to_domain_mapping.get(module_name, 'UNMAPPED')

            report['modules'][module_name] = {
                'api_count': api_count,
                'mapped_domain': domain_name,
                'file_path': str(module_file)
            }

        # 统计业务域信息
        for domain_file in files['domains']:
            domain_name = domain_file.stem
            api_count = len(self.extract_api_paths_from_domain(domain_file))

            # 计算映射到此域的模块
            mapped_modules = [k for k, v in self.module_to_domain_mapping.items() if v == domain_name]

            report['domains'][domain_name] = {
                'api_count': api_count,
                'mapped_modules': mapped_modules,
                'file_path': str(domain_file)
            }

        # 统计全局索引信息
        if files['global']:
            global_api_count = len(self.extract_api_paths_from_global(files['global']))
            report['global'] = {
                'api_count': global_api_count,
                'file_path': str(files['global'])
            }

        # 统计映射覆盖率
        total_modules = len(files['modules'])
        mapped_modules = len([m for m in files['modules'] if m.parent.name in self.module_to_domain_mapping])

        report['mapping_coverage'] = {
            'total_modules': total_modules,
            'mapped_modules': mapped_modules,
            'coverage_rate': mapped_modules / total_modules if total_modules > 0 else 0
        }

        # 汇总信息
        report['summary'] = {
            'total_modules': len(report['modules']),
            'total_domains': len(report['domains']),
            'total_module_apis': sum(m['api_count'] for m in report['modules'].values()),
            'total_domain_apis': sum(d['api_count'] for d in report['domains'].values()),
            'total_global_apis': report['global'].get('api_count', 0),
            'mapping_coverage_rate': report['mapping_coverage']['coverage_rate']
        }

        return report

    def run_full_validation(self, generate_report: bool = True) -> bool:
        """运行完整的三级验证"""
        print("🚀 开始三级API文档质量保证验证")
        print("=" * 60)

        all_success = True

        # 第一级检查：模块 → 业务域
        result1 = self.validate_module_to_domain_completeness()
        self.validation_results.append(result1)
        if not result1.success:
            all_success = False
            for detail in result1.details:
                print(detail)

        # 第二级检查：业务域 → 全局索引
        result2 = self.validate_domain_to_global_completeness()
        self.validation_results.append(result2)
        if not result2.success:
            all_success = False
            for detail in result2.details:
                print(detail)

        # 第三级检查：引用路径验证
        result3 = self.validate_reference_paths()
        self.validation_results.append(result3)
        if not result3.success:
            all_success = False
            for detail in result3.details:
                print(detail)

        # 生成报告
        if generate_report:
            report = self.generate_completeness_report()
            self._print_summary_report(report)

        # 输出最终结果
        print("\n" + "=" * 60)
        if all_success:
            print("🎉 所有三级验证检查通过！")
            print("✅ API文档架构完整性验证成功")
        else:
            print("❌ 发现API文档架构问题")
            print("📋 请根据上述报告修复相关问题")

        return all_success

    def _print_summary_report(self, report: Dict):
        """打印汇总报告"""
        print("\n📊 API文档架构统计报告")
        print("-" * 50)

        summary = report['summary']
        print(f"📦 模块文件数量: {summary['total_modules']}")
        print(f"🏢 业务域文件数量: {summary['total_domains']}")
        print(f"🌐 全局索引API数量: {summary['total_global_apis']}")
        print(f"📈 映射覆盖率: {summary['mapping_coverage_rate']:.1%}")

        print(f"\n📋 API数量统计:")
        print(f"   模块级API总数: {summary['total_module_apis']}")
        print(f"   业务域级API总数: {summary['total_domain_apis']}")
        print(f"   全局索引API总数: {summary['total_global_apis']}")

        # 检查数量一致性
        if summary['total_domain_apis'] != summary['total_global_apis']:
            print(f"⚠️  业务域与全局索引API数量不一致")
        else:
            print(f"✅ 业务域与全局索引API数量一致")

def main():
    """主函数"""
    parser = argparse.ArgumentParser(
        description="三级API文档质量保证验证工具",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用示例:
  python enhanced-api-validator.py                    # 运行完整验证
  python enhanced-api-validator.py --check-only       # 仅检查不生成报告
  python enhanced-api-validator.py --report-only      # 仅生成报告
  python enhanced-api-validator.py --output report.json  # 输出JSON报告
        """
    )

    parser.add_argument(
        '--check-only',
        action='store_true',
        help='仅执行验证检查，不生成详细报告'
    )

    parser.add_argument(
        '--report-only',
        action='store_true',
        help='仅生成完整性报告，不执行验证'
    )

    parser.add_argument(
        '--output',
        type=str,
        help='输出报告到指定文件（JSON格式）'
    )

    parser.add_argument(
        '--base-dir',
        type=str,
        default='.',
        help='API文档根目录（默认为当前目录）'
    )

    args = parser.parse_args()

    # 创建验证器
    validator = ThreeTierAPIValidator(args.base_dir)

    if args.report_only:
        # 仅生成报告
        print("📊 生成API文档架构报告...")
        report = validator.generate_completeness_report()
        validator._print_summary_report(report)

        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                json.dump(report, f, indent=2, ensure_ascii=False)
            print(f"📄 报告已保存到: {args.output}")

        return 0

    # 运行验证
    success = validator.run_full_validation(not args.check_only)

    # 输出JSON报告
    if args.output:
        report = validator.generate_completeness_report()
        report['validation_results'] = [
            {
                'success': r.success,
                'message': r.message,
                'details': r.details
            }
            for r in validator.validation_results
        ]

        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        print(f"📄 完整报告已保存到: {args.output}")

    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
