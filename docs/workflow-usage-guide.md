# IT运维门户系统 - 分批处理PRD文档自动化工作流使用指南

## 概述

本工作流解决了一次性处理所有PRD模块时生成文件丢失内容的问题，通过迭代式处理确保每次处理1-2个模块以提高生成精度。

## 工作流程

### 1. 初始化API文档结构

```bash
# 生成三级分离的API文档架构（全局/业务域/模块）
bash scripts/init_api_structure.sh
```

**功能说明：**
- 解析 `docs/prd/split/4.5/globals/06-api-domain-mapping.md` 中的业务域与模块映射关系
- 生成全局入口文件：`docs/api/global-api-index.yaml`
- 生成业务域聚合文件：`docs/api/domains/{domain}-domain.yaml`
- 生成模块占位文件：`docs/api/modules/{MODULE_ID}-{MODULE_NAME}/openapi.yaml`

**输出结构：**
```
docs/api/
├── global-api-index.yaml          # 全局API入口
├── domains/                       # 业务域聚合文件
│   ├── auth-domain.yaml
│   ├── ticket-domain.yaml
│   └── ...
└── modules/                       # 模块API文件
    ├── REQ-001-基础架构模块/
    ├── REQ-003-工单管理系统/
    └── ...
```

### 2. 生成模块列表

```bash
# 自动生成各阶段的模块列表文件
bash scripts/gen_module_list.sh
```

**生成文件：**
- `scripts/module_list_all.txt` - 所有需要API的模块（21个，排除REQ-002/REQ-015/REQ-020）
- `scripts/module_list_P0.txt` - P0阶段模块（6个，排除REQ-002）
- `scripts/module_list_P1.txt` - P1阶段模块（8个）
- `scripts/module_list_P2.txt` - P2阶段模块（7个，排除REQ-015/REQ-020）

**排除的模块：**
- `REQ-002` - 工作台与仪表板模块（数据聚合展示，不产生新API）
- `REQ-015` - 用户体验增强系统（前端/交互优化）
- `REQ-020` - 移动端应用模块（复用其他业务域API）

### 3. 生成迭代式Prompt

```bash
# 语法：bash scripts/gen_iter_prompt.sh <模式> <阶段> [批量数]

# API文档生成（推荐批量数：1-2）
bash scripts/gen_iter_prompt.sh api P0 2        # P0阶段，每次2个模块
bash scripts/gen_iter_prompt.sh api P1 1        # P1阶段，每次1个模块

# API初始化（一次性生成全局架构）
bash scripts/gen_iter_prompt.sh api-init P0 1

# 后端代码生成
bash scripts/gen_iter_prompt.sh backend P0 2
bash scripts/gen_iter_prompt.sh backend-init P0 1

# 前端代码生成
bash scripts/gen_iter_prompt.sh frontend P0 2
bash scripts/gen_iter_prompt.sh frontend-init P0 1

# 移动端代码生成
bash scripts/gen_iter_prompt.sh mobile P0 2
bash scripts/gen_iter_prompt.sh mobile-init P0 1
```

**支持的模式：**
- `api-init` / `api` - API文档生成
- `backend-init` / `backend` - 后端代码生成
- `frontend-init` / `frontend` - 前端代码生成
- `mobile-init` / `mobile` - 移动端代码生成

**支持的阶段：**
- `P0` - 核心功能模块
- `P1` - 重要功能模块
- `P2` - 增强功能模块
- `all` - 所有模块

### 4. 使用生成的Prompt

生成的prompt文件保存在 `prompts/` 目录下，文件名格式：`{模式}-{模块ID}.md`

**示例：**
- `prompts/api-iter-REQ-001.md` - REQ-001模块的API迭代prompt
- `prompts/api-init-REQ-001.md` - REQ-001模块的API初始化prompt

每次生成的prompt会自动复制到剪贴板，可直接粘贴给AI使用。

## 最佳实践

### 1. 推荐的处理顺序

1. **第一步：API架构初始化**
   ```bash
   bash scripts/init_api_structure.sh
   bash scripts/gen_iter_prompt.sh api-init P0 1
   ```

2. **第二步：分批处理API文档**
   ```bash
   bash scripts/gen_iter_prompt.sh api P0 2  # 每次2个模块
   bash scripts/gen_iter_prompt.sh api P1 2
   bash scripts/gen_iter_prompt.sh api P2 2
   ```

3. **第三步：后端代码生成**
   ```bash
   bash scripts/gen_iter_prompt.sh backend-init P0 1
   bash scripts/gen_iter_prompt.sh backend P0 2
   ```

4. **第四步：前端代码生成**
   ```bash
   bash scripts/gen_iter_prompt.sh frontend-init P0 1
   bash scripts/gen_iter_prompt.sh frontend P0 2
   ```

### 2. 批量大小建议

- **API文档生成：** 1-2个模块/批次（内容复杂度高）
- **代码生成：** 2-3个模块/批次（可并行处理）
- **初始化模式：** 1个模块/批次（需要完整架构）

### 3. 进度管理

脚本会自动保存进度状态文件：`.gen_iter_state_phase_{阶段}_{模式}`

可以随时中断和恢复处理：
```bash
# 继续上次未完成的处理
bash scripts/gen_iter_prompt.sh api P0 2
```

## 故障排除

### 1. 脚本执行失败

**问题：** `declare: -A: invalid option`
**解决：** 升级bash版本或使用兼容的shell

**问题：** 文件名过长错误
**解决：** 检查映射文件格式，确保表格解析正确

### 2. 生成的文件有问题

**问题：** API文档结构错误
**解决：** 
```bash
rm -rf docs/api
bash scripts/init_api_structure.sh
```

**问题：** Prompt中`$ref`显示错误
**解决：** 已修复，确保使用最新版本的脚本

### 3. 模块列表不完整

**问题：** 某些模块未包含在列表中
**解决：** 检查 `docs/prd/split/4.5/modules/` 目录中的文件，更新 `scripts/gen_module_list.sh` 中的模块定义

## 技术细节

### 文件依赖关系

- `docs/prd/split/4.5/globals/06-api-domain-mapping.md` - 业务域映射表
- `docs/global-context.md` - 全局上下文文档
- `docs/prd/split/4.5/globals/05-mock-data-guidelines.md` - Mock数据规范
- `docs/prd/split/4.5/modules/*.md` - 各模块PRD文档

### 环境变量

脚本使用以下环境变量进行模板替换：
- `GLOBAL_FILE` - 全局上下文文件路径
- `MOCK_GUIDE` - Mock数据规范文件路径
- `MODULE_FILE` - 当前模块PRD文件路径
- `MODULE_ID` - 当前模块ID
- `API_BUNDLE` - API合并文件路径（可选）

### 模板系统

Prompt模板位于 `prompt-templates/` 目录：
- `api-init.md` / `api-iter.md` - API文档模板
- `backend-init.md` / `backend-iter.md` - 后端代码模板
- `frontend-init.md` / `frontend-iter.md` - 前端代码模板
- `mobile-init.md` / `mobile-iter.md` - 移动端代码模板

模板使用 `envsubst` 进行变量替换，支持标准的shell变量语法。
