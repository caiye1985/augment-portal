# Prompt Templates 目录说明

本目录包含 IT 运维门户系统项目的所有 AI prompt 模板，经过优化整理，保留最佳版本并按功能分类组织。

## 📁 目录结构

### **核心 Prompt 模板**

#### **PRD 生成模板**
- `prd-generation-ai-enhanced.md` - **主要PRD生成模板**（AI增强版，功能最完整）
- `prd-analysis.md` - PRD分析专用模板
- `prd-quality-check.md` - PRD质量检查模板

#### **专业化 PRD 模板**
- `prd-api-specialized.md` - API开发专用PRD模板
- `prd-backend-specialized.md` - 后端开发专用PRD模板
- `prd-frontend-specialized.md` - 前端开发专用PRD模板
- `prd-mobile-specialized.md` - 移动端开发专用PRD模板

#### **开发模板（配套使用）**
- `api-init.md` / `api-iter.md` - API开发初始化和迭代模板
- `backend-init.md` / `backend-iter.md` - 后端开发初始化和迭代模板
- `frontend-init.md` / `frontend-iter.md` - 前端开发初始化和迭代模板
- `mobile-init.md` / `mobile-iter.md` - 移动端开发初始化和迭代模板

### **存档目录**
- `archive/prd-generation/` - 存档的PRD生成模板版本
- `archive/mobile/` - 存档的移动端模板
- `archive/docs/` - 存档的文档和说明文件

## 🎯 模板选择指南

### **PRD 生成场景**
- **通用PRD生成**: 使用 `prd-generation-ai-enhanced.md`
- **API专项开发**: 使用 `prd-api-specialized.md`
- **后端专项开发**: 使用 `prd-backend-specialized.md`
- **前端专项开发**: 使用 `prd-frontend-specialized.md`
- **移动端开发**: 使用 `prd-mobile-specialized.md`

### **开发场景**
- **项目初始化**: 使用 `*-init.md` 模板
- **迭代开发**: 使用 `*-iter.md` 模板

## 🚀 常用命令

### PRD 生成
```bash
# 生成AI增强版PRD（推荐）
bash scripts/prd/gen_iter_prompt.sh prd P0

# 生成专业化PRD
bash scripts/prd/gen_iter_prompt.sh prd-api P0      # API专用
bash scripts/prd/gen_iter_prompt.sh prd-backend P0  # 后端专用
bash scripts/prd/gen_iter_prompt.sh prd-frontend P0 # 前端专用
bash scripts/prd/gen_iter_prompt.sh prd-mobile P0   # 移动端专用
```

### 开发模板生成
```bash
# API开发
bash scripts/prd/gen_iter_prompt.sh api-init P0
bash scripts/prd/gen_iter_prompt.sh api P0

# 后端开发
bash scripts/prd/gen_iter_prompt.sh backend-init P0
bash scripts/prd/gen_iter_prompt.sh backend P0

# 前端开发
bash scripts/prd/gen_iter_prompt.sh frontend-init P0
bash scripts/prd/gen_iter_prompt.sh frontend P0
```

## 📊 优化说明

### **保留的最优模板**
1. **prd-generation-ai-enhanced.md** - 选择理由：
   - 功能最完整（965行）
   - AI优化程度最高
   - 包含完整的技术架构和实现指导
   - 支持全栈开发需求

2. **专业化模板全部保留** - 选择理由：
   - 各有专门用途，不可替代
   - 针对特定开发场景优化
   - 提供专业化的技术指导

3. **开发模板配套保留** - 选择理由：
   - init和iter模板配套使用
   - 支持完整的开发生命周期
   - 各技术栈都有对应模板

### **存档的模板**
- `prd-generation.md` - 基础版本，功能不如AI增强版完整
- `prd-generation-ai-focused.md` - 精简版本，功能覆盖不够
- `prd-mobile.md` - 与专业化版本重复
- `API_PROMPT_UPDATE_SUMMARY.md` - 历史文档

## 📝 使用说明

1. **模板选择**: 根据开发场景选择合适的模板
2. **脚本执行**: 所有脚本都应该从项目根目录执行
3. **版本管理**: 模板已更新到最新版本，支持当前技术栈
4. **自定义**: 可基于现有模板创建项目特定的变体

## 🔧 维护说明

- **新增模板**: 请按功能分类放入对应目录
- **版本更新**: 优先更新AI增强版本的模板
- **存档管理**: 过期版本移动到archive目录
- **脚本同步**: 更新模板时同步更新相关脚本引用
