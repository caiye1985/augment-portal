#!/usr/bin/env python3
"""
查找业务域中存在但全局索引中缺失的API路径
"""

import yaml
import os
from pathlib import Path

def load_yaml_file(file_path):
    """加载YAML文件"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"❌ 加载文件失败 {file_path}: {e}")
        return None

def extract_api_paths(yaml_content):
    """从YAML内容中提取API路径"""
    if not yaml_content or 'paths' not in yaml_content:
        return set()
    
    return set(yaml_content['paths'].keys())

def main():
    """主函数"""
    print("🔍 分析业务域与全局索引API差异")
    print("=" * 60)
    
    # 获取所有业务域文件
    domains_dir = Path("domains")
    global_index_file = "global-api-index.yaml"
    
    if not domains_dir.exists():
        print("❌ domains目录不存在")
        return
    
    if not Path(global_index_file).exists():
        print("❌ global-api-index.yaml文件不存在")
        return
    
    # 加载全局索引
    global_content = load_yaml_file(global_index_file)
    if not global_content:
        return
    
    global_apis = extract_api_paths(global_content)
    print(f"📊 全局索引API数量: {len(global_apis)}")
    
    # 分析每个业务域
    total_domain_apis = set()
    domain_stats = {}
    
    for domain_file in domains_dir.glob("*.yaml"):
        domain_name = domain_file.stem
        domain_content = load_yaml_file(domain_file)
        
        if domain_content:
            domain_apis = extract_api_paths(domain_content)
            total_domain_apis.update(domain_apis)
            domain_stats[domain_name] = {
                'apis': domain_apis,
                'count': len(domain_apis)
            }
            print(f"📋 {domain_name}: {len(domain_apis)} 个API")
    
    print(f"\n📊 业务域API总数: {len(total_domain_apis)}")
    print(f"📊 全局索引API总数: {len(global_apis)}")
    print(f"📊 差异: {len(total_domain_apis) - len(global_apis)} 个API")
    
    # 查找缺失的API
    missing_apis = total_domain_apis - global_apis
    
    if missing_apis:
        print(f"\n❌ 发现 {len(missing_apis)} 个缺失的API路径:")
        print("-" * 60)
        
        # 按业务域分组显示缺失的API
        for domain_name, domain_info in domain_stats.items():
            domain_missing = domain_info['apis'] & missing_apis
            if domain_missing:
                print(f"\n🔸 {domain_name} 缺失 {len(domain_missing)} 个API:")
                for api in sorted(domain_missing):
                    print(f"   - {api}")
    else:
        print("\n✅ 没有发现缺失的API路径")
    
    # 查找多余的API（在全局索引中但不在业务域中）
    extra_apis = global_apis - total_domain_apis
    if extra_apis:
        print(f"\n⚠️  发现 {len(extra_apis)} 个多余的API路径（在全局索引中但不在业务域中）:")
        print("-" * 60)
        for api in sorted(extra_apis):
            print(f"   - {api}")

if __name__ == "__main__":
    main()
