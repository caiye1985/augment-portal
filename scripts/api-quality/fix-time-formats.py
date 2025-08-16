#!/usr/bin/env python3
"""
批量修复API文档中的时间字段格式
将日期格式从 YYYY-MM-DD 转换为 ISO8601 格式 YYYY-MM-DDTHH:mm:ssZ
"""

import re
import json
from pathlib import Path

def fix_time_formats():
    """修复时间格式"""
    
    # 读取当前的API质量报告
    with open('current-api-quality-report.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 获取需要修复的时间字段
    mock_warnings = [w for w in data['warnings'] if w['category'] == 'MOCK_DATA']
    time_field_fixes = []
    
    for w in mock_warnings:
        field_name = w['message'].split(': ')[1].split(' = ')[0]
        current_value = w['message'].split(': ')[1].split(' = ')[1]
        
        # 跳过配置字段
        if any(keyword in field_name.lower() for keyword in ['format', 'frequency', 'pattern', 'template']):
            continue
            
        # 跳过非时间字段（如updated_by）
        if not any(keyword in field_name.lower() for keyword in ['date', 'time']):
            continue
            
        file_path = w['file']
        location = w['location']
        
        # 检查是否是日期格式 YYYY-MM-DD
        if re.match(r'^\d{4}-\d{2}-\d{2}$', current_value):
            # 转换为ISO8601格式
            new_value = f"{current_value}T00:00:00Z"
            time_field_fixes.append({
                'file': file_path,
                'field': field_name,
                'old_value': current_value,
                'new_value': new_value,
                'location': location
            })
    
    print(f"找到 {len(time_field_fixes)} 个需要修复的时间字段")
    
    # 按文件分组修复
    files_to_fix = {}
    for fix in time_field_fixes:
        file_path = fix['file']
        if file_path not in files_to_fix:
            files_to_fix[file_path] = []
        files_to_fix[file_path].append(fix)
    
    total_fixed = 0
    
    for file_path, fixes in files_to_fix.items():
        print(f"\n修复文件: {file_path}")
        
        try:
            # 读取文件内容
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 应用修复
            for fix in fixes:
                old_pattern = f"example: '{fix['old_value']}'"
                new_pattern = f"example: '{fix['new_value']}'"
                
                if old_pattern in content:
                    content = content.replace(old_pattern, new_pattern)
                    print(f"  ✓ 修复 {fix['field']}: {fix['old_value']} -> {fix['new_value']}")
                    total_fixed += 1
                else:
                    print(f"  ✗ 未找到 {fix['field']}: {fix['old_value']}")
            
            # 写回文件
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
                
        except Exception as e:
            print(f"  ✗ 修复文件失败: {e}")
    
    print(f"\n总共修复了 {total_fixed} 个时间字段")
    return total_fixed

if __name__ == "__main__":
    fix_time_formats()
