# API Prompt 生成使用指南

## 概述

本指南介绍如何使用简化后的 `scripts/gen_iter_prompt.sh` 脚本生成API文档的prompt文件。

## 快速开始

### 基本语法

```bash
bash scripts/gen_iter_prompt.sh <模式> <阶段>
```

### 参数说明

- **模式**: `api-init`, `api`, `backend-init`, `backend`, `frontend-init`, `frontend`, `mobile-init`, `mobile`
- **阶段**: `P0`, `P1`, `P2`, `all`

## 使用示例

### 1. 生成单个阶段的API prompt

```bash
# 生成P0阶段所有模块的API prompt（6个模块）
bash scripts/gen_iter_prompt.sh api P0

# 生成P1阶段所有模块的API prompt（8个模块）
bash scripts/gen_iter_prompt.sh api P1

# 生成P2阶段所有模块的API prompt（7个模块）
bash scripts/gen_iter_prompt.sh api P2
```

### 2. 生成所有阶段的API prompt

```bash
# 一次性生成所有阶段的API prompt（21个模块）
bash scripts/gen_iter_prompt.sh api all
```

### 3. 生成其他类型的prompt

```bash
# 后端代码prompt
bash scripts/gen_iter_prompt.sh backend P0

# 前端代码prompt
bash scripts/gen_iter_prompt.sh frontend P0

# 移动端代码prompt
bash scripts/gen_iter_prompt.sh mobile P0
```

## 输出结果

### 文件命名规则

生成的prompt文件保存在 `prompts/` 目录下，命名格式为：
```
prompts/{模式}-{模块ID}.md
```

例如：
- `prompts/api-iter-REQ-001.md` - REQ-001模块的API迭代prompt
- `prompts/api-iter-REQ-003.md` - REQ-003模块的API迭代prompt

### 生成统计

- **P0阶段**: 6个模块 (REQ-001, REQ-003, REQ-004, REQ-006A, REQ-010, REQ-022)
- **P1阶段**: 8个模块 (REQ-005, REQ-006B, REQ-007, REQ-011, REQ-012, REQ-016, REQ-017, REQ-018)
- **P2阶段**: 7个模块 (REQ-008, REQ-009, REQ-013, REQ-014, REQ-019, REQ-021, REQ-023)
- **总计**: 21个模块

## 进度管理

### 自动进度保存

脚本会自动保存进度到状态文件：
```
.gen_iter_state_phase_{阶段}_{模式}
```

### 中断和恢复

如果生成过程被中断，再次运行相同命令会从上次停止的地方继续：

```bash
# 假设P1阶段生成到第3个模块时中断
bash scripts/gen_iter_prompt.sh api P1
# 输出: [i] 进度: 3/8
# 会从第4个模块开始继续生成
```

### 重新开始

如果需要重新生成某个阶段的所有prompt：

```bash
# 删除进度文件，重新开始
rm .gen_iter_state_phase_P0_api
bash scripts/gen_iter_prompt.sh api P0
```

## 特性说明

### 1. 每个模块独立prompt文件

- **优势**: 便于单独修改、版本控制、质量保证
- **结果**: 每个模块生成一个完整的、可独立使用的prompt文件

### 2. 变量自动替换

每个prompt文件中的变量会自动替换为具体值：
- `$MODULE_ID` → `REQ-003`
- `$MODULE_NAME` → `工单管理系统`
- 路径 → `docs/api/modules/REQ-003-工单管理系统/openapi.yaml`

### 3. 向后兼容性

脚本仍支持旧的三参数格式，但会忽略第三个参数：

```bash
# 旧格式（仍然有效，但会显示提示）
bash scripts/gen_iter_prompt.sh api P0 2
# 输出: [i] 注意: 批量数参数已被移除，每个模块都会生成独立的prompt文件
```

## 最佳实践

### 1. 推荐的工作流程

```bash
# 1. 初始化API结构
bash scripts/init_api_structure.sh

# 2. 生成API prompt文件
bash scripts/gen_iter_prompt.sh api all

# 3. 使用生成的prompt文件进行API设计
# 每个prompt文件都可以独立使用
```

### 2. 阶段性处理

如果项目较大，建议按阶段处理：

```bash
# 先处理核心功能
bash scripts/gen_iter_prompt.sh api P0

# 完成P0后再处理P1
bash scripts/gen_iter_prompt.sh api P1

# 最后处理增强功能
bash scripts/gen_iter_prompt.sh api P2
```

### 3. 质量控制

- 每个prompt文件都包含完整的验证命令
- 支持独立的swagger-cli验证
- 便于单独测试和调试

## 故障排除

### 常见问题

1. **模块列表文件不存在**
   ```bash
   # 解决方案：重新生成模块列表
   bash scripts/gen_module_list.sh
   ```

2. **映射文件找不到**
   ```bash
   # 确保映射文件存在
   ls docs/prd/split/4.5/globals/06-api-domain-mapping.md
   ```

3. **权限问题**
   ```bash
   # 确保脚本有执行权限
   chmod +x scripts/gen_iter_prompt.sh
   ```

### 调试信息

脚本会输出详细的进度信息：
- 当前处理的模块
- 进度统计
- 文件保存位置
- 剪贴板复制状态

## 总结

简化后的脚本提供了更直观的使用方式，同时保持了所有核心功能：
- ✅ 简化的参数格式
- ✅ 每个模块独立prompt文件
- ✅ 自动变量替换
- ✅ 进度管理和恢复
- ✅ 向后兼容性
- ✅ 详细的输出信息
