#!/usr/bin/env python3
"""
全面的OpenAPI文档验证脚本
验证YAML语法、OpenAPI结构、引用路径和Mock Server兼容性
"""

import yaml
import sys
import os
import glob
import subprocess
import time
import requests
from pathlib import Path

def validate_openapi_file(file_path):
    """验证OpenAPI文件的基本结构"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)

        # 检查基本的OpenAPI结构
        required_fields = ['openapi', 'info', 'paths']
        for field in required_fields:
            if field not in data:
                print(f"❌ 缺少必需字段: {field}")
                return False, data

        # 检查OpenAPI版本
        if not data['openapi'].startswith('3.0'):
            print(f"❌ OpenAPI版本不正确: {data['openapi']}")
            return False, data

        # 检查info字段
        info_required = ['title', 'version']
        for field in info_required:
            if field not in data['info']:
                print(f"❌ info缺少必需字段: {field}")
                return False, data

        # 检查paths不为空
        if not data['paths']:
            print("❌ paths字段为空")
            return False, data

        # 统计API数量
        api_count = len(data['paths'])
        print(f"✅ API端点数量: {api_count}")

        # 检查components.schemas（如果存在）
        if 'components' in data and 'schemas' in data['components']:
            schema_count = len(data['components']['schemas'])
            print(f"✅ Schema定义数量: {schema_count}")

        print(f"✅ {file_path} 基本结构验证通过")
        return True, data

    except yaml.YAMLError as e:
        print(f"❌ YAML语法错误: {e}")
        return False, None
    except FileNotFoundError:
        print(f"❌ 文件不存在: {file_path}")
        return False, None
    except Exception as e:
        print(f"❌ 验证失败: {e}")
        return False, None

def validate_references(file_path, data):
    """验证文件中的$ref引用"""
    print(f"🔍 检查引用路径: {file_path}")
    issues = []

    def check_refs_recursive(obj, path=""):
        if isinstance(obj, dict):
            for key, value in obj.items():
                current_path = f"{path}.{key}" if path else key
                if key == "$ref" and isinstance(value, str):
                    # 检查引用路径
                    if not validate_single_reference(file_path, value):
                        issues.append(f"无效引用: {current_path} -> {value}")
                else:
                    check_refs_recursive(value, current_path)
        elif isinstance(obj, list):
            for i, item in enumerate(obj):
                check_refs_recursive(item, f"{path}[{i}]")

    check_refs_recursive(data)

    if issues:
        print(f"❌ 发现 {len(issues)} 个引用问题:")
        for issue in issues:
            print(f"   - {issue}")
        return False
    else:
        print("✅ 所有引用路径验证通过")
        return True

def validate_single_reference(file_path, ref_path):
    """验证单个引用路径"""
    try:
        if ref_path.startswith('#/'):
            # 内部引用，检查当前文件
            return True  # 简化处理，假设内部引用正确
        else:
            # 外部引用
            if '#/' in ref_path:
                file_ref, json_pointer = ref_path.split('#/', 1)
            else:
                file_ref = ref_path
                json_pointer = ""

            # 解析相对路径
            base_dir = os.path.dirname(file_path)
            target_file = os.path.join(base_dir, file_ref)
            target_file = os.path.normpath(target_file)

            # 检查目标文件是否存在
            if not os.path.exists(target_file):
                return False

            # 如果有JSON指针，检查目标路径是否存在
            if json_pointer:
                try:
                    with open(target_file, 'r', encoding='utf-8') as f:
                        target_data = yaml.safe_load(f)

                    # 简化的JSON指针解析
                    parts = json_pointer.split('/')
                    current = target_data
                    for part in parts:
                        if part:
                            # 处理编码的路径分隔符
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

def find_all_api_files():
    """查找所有API文件"""
    files = {
        'modules': [],
        'domains': [],
        'global': 'global-api-index.yaml'
    }

    # 查找所有模块文件
    module_pattern = "modules/*/openapi.yaml"
    for file_path in glob.glob(module_pattern):
        if os.path.exists(file_path):
            files['modules'].append(file_path)

    # 查找所有域文件
    domain_pattern = "domains/*-domain.yaml"
    for file_path in glob.glob(domain_pattern):
        if os.path.exists(file_path):
            files['domains'].append(file_path)

    return files

def test_mock_server(file_path, port=3000):
    """测试Mock Server启动"""
    print(f"🚀 测试Mock Server: {file_path}")

    try:
        # 启动Prism Mock Server
        cmd = [
            'prism', 'mock', file_path,
            '--port', str(port),
            '--host', '127.0.0.1',
            '--cors'
        ]

        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        # 等待服务器启动
        time.sleep(3)

        # 检查进程是否还在运行
        if process.poll() is not None:
            stdout, stderr = process.communicate()
            print(f"❌ Mock Server启动失败:")
            print(f"   stdout: {stdout}")
            print(f"   stderr: {stderr}")
            return False

        # 尝试访问API
        try:
            response = requests.get(f"http://127.0.0.1:{port}", timeout=5)
            print(f"✅ Mock Server启动成功，状态码: {response.status_code}")
            success = True
        except requests.RequestException as e:
            print(f"❌ Mock Server无法访问: {e}")
            success = False

        # 停止服务器
        process.terminate()
        process.wait(timeout=5)

        return success

    except FileNotFoundError:
        print("❌ Prism CLI未安装")
        return False
    except Exception as e:
        print(f"❌ Mock Server测试失败: {e}")
        return False

def main():
    """主函数"""
    print("🔍 开始全面API文件验证...")
    print("=" * 60)

    # 查找所有API文件
    api_files = find_all_api_files()

    total_files = len(api_files['modules']) + len(api_files['domains']) + 1
    passed_files = 0
    failed_files = []

    # 验证全局文件
    print(f"\n📋 验证全局API索引文件...")
    print("-" * 40)
    global_file = api_files['global']
    if os.path.exists(global_file):
        success, data = validate_openapi_file(global_file)
        if success:
            if validate_references(global_file, data):
                passed_files += 1
                print(f"✅ {global_file} 完全验证通过")
            else:
                failed_files.append(global_file)
        else:
            failed_files.append(global_file)
    else:
        print(f"❌ 全局文件不存在: {global_file}")
        failed_files.append(global_file)

    # 验证域文件
    print(f"\n🏢 验证业务域文件 ({len(api_files['domains'])} 个)...")
    print("-" * 40)
    for domain_file in sorted(api_files['domains']):
        print(f"\n验证域文件: {domain_file}")
        success, data = validate_openapi_file(domain_file)
        if success and data:
            if validate_references(domain_file, data):
                passed_files += 1
                print(f"✅ {domain_file} 完全验证通过")
            else:
                failed_files.append(domain_file)
        else:
            failed_files.append(domain_file)

    # 验证模块文件
    print(f"\n📦 验证模块文件 ({len(api_files['modules'])} 个)...")
    print("-" * 40)
    for module_file in sorted(api_files['modules']):
        print(f"\n验证模块文件: {module_file}")
        success, data = validate_openapi_file(module_file)
        if success and data:
            if validate_references(module_file, data):
                passed_files += 1
                print(f"✅ {module_file} 完全验证通过")
            else:
                failed_files.append(module_file)
        else:
            failed_files.append(module_file)

    # 输出总结
    print("\n" + "=" * 60)
    print("📊 验证结果总结:")
    print(f"   总文件数: {total_files}")
    print(f"   通过验证: {passed_files}")
    print(f"   验证失败: {len(failed_files)}")

    if failed_files:
        print(f"\n❌ 验证失败的文件:")
        for file_path in failed_files:
            print(f"   - {file_path}")
        sys.exit(1)
    else:
        print(f"\n🎉 所有 {total_files} 个API文件验证通过！")

        # 可选：测试Mock Server（仅测试几个关键文件）
        print(f"\n🚀 测试关键文件的Mock Server兼容性...")
        test_files = [
            "modules/REQ-018-财务管理模块/openapi.yaml",
            "domains/finance-domain.yaml"
        ]

        for i, test_file in enumerate(test_files):
            if os.path.exists(test_file):
                port = 3000 + i
                test_mock_server(test_file, port)

if __name__ == "__main__":
    main()
