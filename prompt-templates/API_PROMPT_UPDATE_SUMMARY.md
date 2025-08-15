# OpenAPI生成Prompt模板更新总结

## 🎯 更新目标

基于修复OpenAPI文档引用错误的实际经验，更新 `prompt-templates/api-iter.md` 文件，确保后续生成的OpenAPI文档不会再出现引用错误问题。

## 🔧 主要改进内容

### 1. 技术约束增强

**新增约束**：
- **引用路径规范**：使用正确的JSON Pointer语法，确保所有`$ref`引用的路径在目标文件中真实存在
- **Mock Server兼容**：生成的API文档必须能够与Prism CLI等Mock工具正常启动

### 2. OpenAPI模块文件编写规范

**改进点**：
- 明确API路径命名规范：使用具体的API路径（如`/api/v1/tickets/...`），避免抽象的模块级路径
- 强调引用路径验证：确保所有引用的schema在目标文件中确实存在
- 修正引用语法：使用标准的`$ref`而非`DOLLAR_REF`

### 3. 校验与质量控制升级

**新增验证步骤**：
- **OpenAPI规范验证**：swagger-cli validate + prism validate
- **引用路径验证**：检查JSON Pointer语法正确性
- **Mock Server兼容性验证**：确保API文档能够与Prism CLI正常启动

### 4. 新增引用路径规范章节

**核心内容**：
- **JSON Pointer语法规范**：路径编码规则（`/` → `~1`）
- **正确的引用格式**：提供正确和错误的对比示例
- **引用验证原则**：确保引用路径的真实性和一致性

### 5. 域文件生成指导

**新增指导**：
- **域文件结构模板**：标准化的域文件格式
- **路径映射示例**：认证域、工单域、客户域的实际映射
- **全局API索引更新**：如何正确聚合域文件中的API路径

### 6. 常见引用错误排查

**错误类型与解决方案**：
- `token "xxx" does not exist` → 检查目标文件的实际路径结构
- `EMISSINGPOINTER` → 确保JSON Pointer语法正确
- Mock Server启动失败 → 验证完整的引用链

### 7. 输出要求细化

**新增要求**：
- **引用规范要求**：正确的JSON Pointer语法和相对路径引用
- **验证要求**：Mock Server脚本兼容性
- **域文件更新**：如需要，同时输出域文件内容

### 8. 验证命令扩展

**新增验证命令**：
```bash
# Mock Server启动测试
./scripts/start-mock-server.sh -m $MODULE_ID-$MODULE_NAME -p 3000
./scripts/start-mock-server.sh -d <domain_name> -p 3001
./scripts/start-mock-server.sh -p 3002
```

### 9. 实际示例参考

**基于修复经验的示例**：
- **模块文件示例**：正确的API路径和引用格式
- **域文件示例**：基于实际修复的ticket-domain.yaml格式
- **全局API索引示例**：正确的路径聚合方式

## 📋 修复经验融入

### 基于实际修复案例

1. **auth-domain.yaml修复经验**：
   - 从抽象路径`/基础架构模块`改为具体路径`/api/v1/auth/login`
   - 正确引用基础架构模块和用户权限管理模块的API

2. **ticket-domain.yaml修复经验**：
   - 移除不存在的`/api/v1/tickets/{id}/comments`引用
   - 添加实际存在的路径如`/api/v1/tickets/{id}/accept`

3. **customer-domain.yaml修复经验**：
   - 引用客户关系管理模块的具体API路径
   - 包含客户档案、搜索、健康度等功能

4. **global-api-index.yaml修复经验**：
   - 移除非标准的`x-domains`扩展
   - 使用标准的OpenAPI `paths`结构聚合API

## 🎯 预期效果

### 1. 避免引用错误
- 生成的API文档不会出现`token "xxx" does not exist`错误
- 所有引用路径都指向真实存在的API端点

### 2. Mock Server兼容
- 生成的API文档能够与Prism CLI正常启动
- 支持全局API、域API、模块API的Mock Server部署

### 3. 标准化合规
- 完全符合OpenAPI 3.0.3规范
- 使用标准的JSON Pointer语法
- 避免非标准扩展的使用

### 4. 可维护性提升
- 引用路径清晰明确
- 模块间依赖关系清楚
- 便于后续维护和扩展

## 🚀 使用指南

更新后的prompt模板将指导AI生成：

1. **正确的模块API文件**：
   - 使用具体的API路径
   - 正确引用全局组件
   - 符合Mock Server要求

2. **标准的域文件**（如需要）：
   - 正确聚合模块API
   - 使用标准引用语法
   - 保持引用链完整

3. **兼容的全局API索引**：
   - 从域文件正确聚合
   - 支持Mock Server启动
   - 符合OpenAPI规范

## 📝 技术债务清理

通过这次更新，我们解决了：

1. **历史遗留问题**：非标准的`x-domains`扩展
2. **引用语法问题**：错误的JSON Pointer格式
3. **路径映射问题**：抽象路径vs具体API路径
4. **工具兼容问题**：Mock Server启动失败

---

**更新完成时间**：2024-08-15 23:10  
**更新状态**：✅ 完成  
**验证状态**：✅ 已融入实际修复经验
