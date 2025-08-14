# 版本化目录结构使用指南

## 概述

本指南介绍IT运维门户系统的版本化目录结构，确保生成的API文档和其他PRD相关文档与PRD版本号保持一致。

## 版本化架构

### 目录结构对比

**修改前（非版本化）：**
```
docs/api/
├── global-api-index.yaml
├── domains/
└── modules/

prompts/
├── api-iter-REQ-001.md
└── ...
```

**修改后（版本化）：**
```
docs/api/4.5/                      # 版本化API目录
├── global-api-index.yaml
├── domains/
└── modules/

prompts/4.5/                       # 版本化prompt目录
├── api/
│   ├── api-iter-REQ-001.md
│   └── ...
├── backend/
├── frontend/
└── mobile/

docs/output/4.5/                   # 版本化输出目录
├── api-docs/
├── backend/
├── frontend/
├── mobile/
└── architecture/
```

## 版本检测机制

### 自动版本检测

系统会自动检测当前PRD版本号：

```bash
# 检测当前PRD版本
bash scripts/version_utils.sh detect
# 输出: 4.5
```

### 版本检测逻辑

1. 扫描 `docs/prd/split/` 目录下的版本子目录
2. 按版本号排序，选择最新版本
3. 验证版本目录的有效性

## 使用方法

### 1. 初始化版本化结构

```bash
# 一键初始化版本化目录结构
bash scripts/version_utils.sh init
```

**执行效果：**
- 自动检测PRD版本号
- 创建版本化目录结构
- 迁移现有文件到版本化目录
- 显示版本信息和目录路径

### 2. 查看版本化路径信息

```bash
# 显示所有版本化路径
bash scripts/version_utils.sh paths
```

**输出示例：**
```
=== PRD Paths ===
PRD_VERSION_DIR="docs/prd/split/4.5"
PRD_MODULES_DIR="docs/prd/split/4.5/modules"
MOCK_GUIDE_FILE="docs/prd/split/4.5/globals/05-mock-data-guidelines.md"
...

=== Output Paths ===
API_VERSION_DIR="docs/api/4.5"
OUTPUT_VERSION_DIR="docs/output/4.5"
PROMPT_VERSION_DIR="prompts/4.5"
...
```

### 3. 使用版本化脚本

所有相关脚本已自动支持版本化：

```bash
# API结构初始化（自动使用版本化路径）
bash scripts/init_api_structure.sh

# 生成版本化prompt文件
bash scripts/gen_iter_prompt.sh api P0

# 生成模块列表（自动检测版本）
bash scripts/gen_module_list.sh
```

## 脚本修改说明

### 1. 版本工具脚本 (`scripts/version_utils.sh`)

**新增功能：**
- `detect_prd_version()` - 自动检测PRD版本号
- `create_versioned_directories()` - 创建版本化目录结构
- `migrate_existing_files()` - 迁移现有文件
- `get_prd_paths()` / `get_output_paths()` - 获取版本化路径

### 2. API结构初始化脚本 (`scripts/init_api_structure.sh`)

**修改内容：**
- 导入版本工具
- 自动检测版本号
- 使用版本化路径创建API结构
- 输出版本信息

### 3. Prompt生成脚本 (`scripts/gen_iter_prompt.sh`)

**修改内容：**
- 导入版本工具
- 自动检测版本号
- 使用版本化prompt目录
- 按模式分类保存prompt文件
- 在prompt中使用版本化路径

### 4. 模块列表生成脚本 (`scripts/gen_module_list.sh`)

**修改内容：**
- 导入版本工具
- 自动检测版本号
- 使用版本化PRD模块目录

## 版本化优势

### 1. 版本追踪

- **清晰的版本对应关系**：每个版本的文档都有独立目录
- **历史版本保留**：可以同时保存多个版本的文档
- **版本比较**：便于对比不同版本的差异

### 2. 并行开发

- **多版本并行**：可以同时开发多个版本
- **独立维护**：每个版本的修改不会影响其他版本
- **回滚支持**：可以快速回滚到之前的版本

### 3. 自动化管理

- **自动检测**：无需手动指定版本号
- **自动迁移**：现有文件自动迁移到版本化目录
- **向前兼容**：新版本发布时自动适配

## 文件路径映射

### PRD文件路径

| 文件类型 | 版本化路径 |
|----------|------------|
| 模块PRD | `docs/prd/split/4.5/modules/REQ-XXX.md` |
| 全局配置 | `docs/prd/split/4.5/globals/` |
| 附录文档 | `docs/prd/split/4.5/appendix/` |

### 生成文件路径

| 文件类型 | 版本化路径 |
|----------|------------|
| API文档 | `docs/api/4.5/` |
| Prompt文件 | `prompts/4.5/{api,backend,frontend,mobile}/` |
| 输出文档 | `docs/output/4.5/` |

### Prompt文件中的路径

生成的prompt文件中的路径会自动使用版本化格式：

```yaml
# 示例：REQ-001模块的API文档路径
路径：docs/api/4.5/modules/REQ-001-基础架构模块/openapi.yaml

# 验证命令
swagger-cli validate docs/api/4.5/modules/REQ-001-基础架构模块/openapi.yaml
```

## 最佳实践

### 1. 版本管理

```bash
# 开始新版本开发前，先初始化版本化结构
bash scripts/version_utils.sh init

# 确认当前使用的版本
bash scripts/version_utils.sh detect
```

### 2. 文件组织

- **按版本分离**：不同版本的文件完全分离
- **按类型分类**：prompt文件按模式（api/backend/frontend/mobile）分类
- **保持一致性**：所有脚本都使用相同的版本检测逻辑

### 3. 团队协作

- **版本同步**：团队成员使用相同的PRD版本
- **路径统一**：所有生成的文档都使用版本化路径
- **文档追踪**：便于追踪文档的版本历史

## 故障排除

### 常见问题

1. **版本检测失败**
   ```bash
   # 检查PRD目录结构
   ls -la docs/prd/split/
   
   # 确保存在版本目录（如4.5）
   ```

2. **路径引用错误**
   ```bash
   # 重新初始化版本化结构
   bash scripts/version_utils.sh init
   ```

3. **文件迁移问题**
   ```bash
   # 手动检查文件是否正确迁移
   ls -la docs/api/4.5/
   ls -la prompts/4.5/
   ```

### 调试命令

```bash
# 显示详细的版本信息
bash scripts/version_utils.sh paths

# 检查脚本中的版本变量
bash -c 'source scripts/version_utils.sh && echo "VERSION: $(detect_prd_version)"'
```

## 总结

版本化目录结构提供了：

- ✅ **自动版本检测**：无需手动管理版本号
- ✅ **完整的版本隔离**：每个版本独立管理
- ✅ **向前兼容性**：支持未来版本的自动适配
- ✅ **团队协作友好**：统一的版本管理机制
- ✅ **文档追踪能力**：便于版本对比和历史追踪

通过版本化结构，可以更好地管理不同版本的文档，确保开发过程的有序性和可追溯性。
