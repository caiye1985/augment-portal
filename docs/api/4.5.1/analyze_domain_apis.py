#!/usr/bin/env python3
"""
分析业务域API数量和重复情况
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
    print("🔍 分析业务域API数量和重复情况")
    print("=" * 60)
    
    # 获取所有业务域文件
    domains_dir = Path("domains")
    
    if not domains_dir.exists():
        print("❌ domains目录不存在")
        return
    
    # 分析每个业务域
    all_apis = set()
    domain_stats = {}
    total_count = 0
    
    for domain_file in domains_dir.glob("*.yaml"):
        domain_name = domain_file.stem
        domain_content = load_yaml_file(domain_file)
        
        if domain_content:
            domain_apis = extract_api_paths(domain_content)
            domain_stats[domain_name] = {
                'apis': domain_apis,
                'count': len(domain_apis)
            }
            total_count += len(domain_apis)
            all_apis.update(domain_apis)
            print(f"📋 {domain_name}: {len(domain_apis)} 个API")
    
    print(f"\n📊 统计结果:")
    print(f"   各域API数量总和: {total_count}")
    print(f"   去重后API总数: {len(all_apis)}")
    print(f"   重复API数量: {total_count - len(all_apis)}")
    
    # 查找重复的API
    if total_count > len(all_apis):
        print(f"\n🔍 查找重复的API:")
        api_count = {}
        for domain_name, domain_info in domain_stats.items():
            for api in domain_info['apis']:
                if api not in api_count:
                    api_count[api] = []
                api_count[api].append(domain_name)
        
        duplicates = {api: domains for api, domains in api_count.items() if len(domains) > 1}
        
        if duplicates:
            print(f"发现 {len(duplicates)} 个重复的API:")
            for api, domains in duplicates.items():
                print(f"   - {api}")
                print(f"     出现在: {', '.join(domains)}")
        else:
            print("没有发现重复的API")
    
    # 检查映射关系
    print(f"\n📋 模块映射情况:")
    
    # 加载映射配置
    config_file = "api-mapping-config.yaml"
    if Path(config_file).exists():
        with open(config_file, 'r', encoding='utf-8') as f:
            config = yaml.safe_load(f)
        mapping = config.get('module_to_domain_mapping', {})
        
        mapped_domains = set(mapping.values())
        all_domains = set(domain_stats.keys())
        unmapped_domains = all_domains - mapped_domains
        
        print(f"   映射的业务域: {len(mapped_domains)}")
        print(f"   未映射的业务域: {len(unmapped_domains)}")
        
        if unmapped_domains:
            print(f"   未映射的域:")
            for domain in sorted(unmapped_domains):
                count = domain_stats[domain]['count']
                print(f"     - {domain}: {count} 个API")
                
            # 计算未映射域的API总数
            unmapped_api_count = sum(domain_stats[domain]['count'] for domain in unmapped_domains)
            print(f"   未映射域API总数: {unmapped_api_count}")

if __name__ == "__main__":
    main()
