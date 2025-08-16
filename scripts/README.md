# Scripts 目录说明

本目录包含 IT 运维门户系统项目的所有脚本工具，按功能分类组织。

## 📁 目录结构

### `api-quality/` - API 质量检查工具
- `api-quality-checker.py` - 主要的 API 质量检查器
- `analyze-parameter-inconsistencies.py` - 参数不一致性分析工具
- `fix-parameter-inconsistencies.py` - 参数类型统一修复工具
- `fix-restful-naming.py` - RESTful 命名规范修复工具
- `fix-api-references.py` - API 引用路径修复工具
- `sync-global-index.py` - 全局索引同步工具
- `quick-fix-api-issues.py` - 快速修复 API 问题工具
- `comprehensive-api-review.sh` - 综合 API 审查脚本

### `validation/` - 验证工具
- 包含各种验证相关的脚本

### `mock-server/` - Mock 服务器工具
- `start-mock-server.sh` - 启动 Mock 服务器
- `mock-server-control.sh` - Mock 服务器控制脚本
- `setup-mock-server.sh` - Mock 服务器设置脚本
- `test-mock-server.sh` - Mock 服务器测试脚本
- `start-auth-mock.sh` - 启动认证 Mock 服务
- `start-customer-mock.sh` - 启动客户 Mock 服务
- `start-global-mock.sh` - 启动全局 Mock 服务
- `docker-mock-server.sh` - Docker Mock 服务器脚本
- `Dockerfile.mock-server` - Mock 服务器 Docker 文件
- `docker-compose.mock-server.yml` - Docker Compose 配置
- `nginx.mock.conf` - Nginx Mock 配置
- `package.json` - Node.js 依赖配置
- `start-mock-server.js` - Node.js Mock 服务器启动脚本

### `prd/` - PRD 相关工具
- `ai_prd_quality_check.sh` - AI PRD 质量检查
- `gen_iter_prompt.sh` - 生成迭代提示脚本
- `gen_module_list.sh` - 生成模块列表脚本
- `gen_prd_analysis.sh` - 生成 PRD 分析脚本
- `gen_prd_complete.sh` - 生成完整 PRD 脚本
- `simple_prd_quality_check.sh` - 简单 PRD 质量检查
- `validate_prd_quality.sh` - 验证 PRD 质量脚本

### `utils/` - 工具类脚本
- `init_api_structure.sh` - 初始化 API 结构脚本
- `version_utils.sh` - 版本工具脚本
- `module_list_*.txt` - 模块列表文件

## 🚀 常用命令

### API 质量检查
```bash
# 运行完整的 API 质量检查
python3 scripts/api-quality/api-quality-checker.py

# 分析参数不一致性
python3 scripts/api-quality/analyze-parameter-inconsistencies.py

# 修复参数类型不一致
python3 scripts/api-quality/fix-parameter-inconsistencies.py
```

### Mock 服务器
```bash
# 启动全局 Mock 服务器
bash scripts/mock-server/start-mock-server.sh --global --port 3000

# 测试 Mock 服务器
bash scripts/mock-server/test-mock-server.sh
```

### PRD 工具
```bash
# PRD 质量检查
bash scripts/prd/ai_prd_quality_check.sh

# 生成模块列表
bash scripts/prd/gen_module_list.sh
```

## 📝 使用说明

1. 所有脚本都应该从项目根目录执行
2. 确保具有适当的执行权限：`chmod +x scripts/**/*.sh`
3. Python 脚本需要 Python 3.7+ 环境
4. Mock 服务器需要 Node.js 环境

## 🔧 维护说明

- 新增脚本请按功能分类放入对应目录
- 更新脚本时请同步更新此 README
- 删除脚本前请确认没有其他脚本依赖
