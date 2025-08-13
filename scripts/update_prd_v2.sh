#!/bin/bash
set -e

# ========== 1. 找出最新 PRD 版本目录 ==========
PRD_BASE="docs/prd/split"
LATEST_VERSION=$(ls -d $PRD_BASE/*/ | grep -oE '[0-9]+\.[0-9]+' | sort -V | tail -n 1)
LATEST_PRD_DIR="$PRD_BASE/$LATEST_VERSION"

echo "📂 最新 PRD 版本: v$LATEST_VERSION"
echo "📁 最新 PRD 路径: $LATEST_PRD_DIR"

# ========== 2. 拼接 Prompt 内容 ==========
PROMPT=$(cat <<EOF
你现在是资深系统架构师兼 AI 产品经理。

---

## Step 0：读取 PRD 最新版本路径
- 使用路径 \`$LATEST_PRD_DIR\`
- 递归读取该目录下所有 \`.md\` 文件（原始拆分版 + AI 精简版如存在）

---

## Step 1：生成主要交付文件（存放到 docs/output/$LATEST_VERSION/）

### 1. backend-prd.md  
   - 后端精简 PRD（架构、模块、技术栈、部署、安全要求等）  

### 2. frontend-prd.md  
   - Web 前端精简 PRD（UI、交互、布局、API对接等）  

### 3. mobile-prd.md（Flutter 版 ）
   - 忽略任何非 Flutter的技术方案。
   - Flutter 技术栈（Dart 3.x、Material/Cupertino、自定义主题、Riverpod、GoRouter、drift、Dio）
   - 模块功能 & API 对接
   - 手势/响应式/离线模式/性能优化/Security
   - 可直接给 Cursor 生成 Flutter App  

### 4.1 Markdown API 文档（api-docs.md）
- 按模块分组接口
- 对每个接口说明：
  - 接口路径 / 方法（GET/POST/PUT/DELETE）
  - **覆盖需求: REQ-ID 列表**（从 PRD 模块提取，必须出现在接口标题或描述中）
  - 权限要求
  - 请求参数（表格）
  - 响应结构
  - 错误码表
  - 请求/响应示例 JSON（Mock 数据）

**Markdown 标注规范：**
```
### GET /api/v1/tickets/{id}
覆盖需求: REQ-007, REQ-009

简要描述...
```
---

### 4.2 OpenAPI 3.1 文件（openapi.yaml）
- **每个接口的 summary 中必须包含 REQ-ID**  
- 如果涉及多个需求，多个 REQ-ID 用逗号分隔
- 例：
```yaml
summary: 获取工单详情（覆盖需求: REQ-007, REQ-009）
description: 返回与工单相关的详细信息
```
- 保持字段命名、Mock 数据规范

--- 

### 5. openapi.yaml  
   - OpenAPI 3.1 标准
   - 路径含 \`/api/v{version}/\`，字段命名规范 & Mock  
   - 可直接导入 Swagger / Postman  

### 6. execution-plan.md  
   - 立即行动 / 中期改进 / 长期维护  

---

## Step 2：生成并行交接图（美化版）

### Mermaid 源码模版：
\`\`\`mermaid
flowchart TD
    style A fill:#dddddd,stroke:#555,stroke-width:1px,color:#000
    style B fill:#4682B4,stroke:#333,stroke-width:1px,color:#fff
    style C1 fill:#4682B4,stroke:#333,stroke-width:1px,color:#fff
    style C2 fill:#32CD32,stroke:#333,stroke-width:1px,color:#fff
    style C3 fill:#32CD32,stroke:#333,stroke-width:1px,color:#fff
    style C4 fill:#f4a261,stroke:#333,stroke-width:1px,color:#fff
    style C5 fill:#f4a261,stroke:#333,stroke-width:1px,color:#fff
    style C6 fill:#f4a261,stroke:#333,stroke-width:1px,color:#fff
    style D fill:#999999,stroke:#333,stroke-width:1px,color:#fff

    A[原始 PRD 目录<br/>$LATEST_PRD_DIR] --> B[augment 运行<br/>一次性终极 Prompt]

    B --> C1[backend-prd.md<br/>后端精简 PRD]
    B --> C2[frontend-prd.md<br/>Web 前端精简 PRD]
    B --> C3[mobile-prd.md<br/>Flutter 移动端精简 PRD]
    B --> C4[api-docs.md<br/>Markdown API]
    B --> C5[openapi.yaml<br/>OpenAPI 3.1 + Mock]
    B --> C6[execution-plan.md<br/>执行计划]

    C1 --> D1[augment<br/>生成后端代码]
    C5 --> D1

    C2 --> D2[Cursor<br/>生成 Web 前端代码]
    C5 --> D2

    C3 --> D3[Cursor<br/>生成 Flutter 移动端代码]
    C5 --> D3

    C4 --> D4[测试/管理团队<br/>使用 Mock API & 执行计划]
    C5 --> D4
    C6 --> D4

    D1 --> E[CI/CD<br/>集成测试]
    D2 --> E
    D3 --> E

    E --> F[正式上线<br/>后端 + Web + 移动端]
\`\`\`

---

## Step 3：交接图交付要求
- 输出到 \`docs/output/$LATEST_VERSION/\`  
- 包含：
  - \`handoff-diagram.mmd\`（Mermaid 源文件）
- PNG 必须按模板配色，比例适合 Wiki/PPT 展示
- Mermaid 源文件便于后期修改

---

## Step 4：统一规范
1. 删除冗余背景和重复描述  
2. 缩写首次出现加全称（中英文）  
3. 输出 Markdown 结构一致  
4. API 文档和 OpenAPI 字段命名一致  
5. Mock 数据符合命名规范 & 版本化规范  

---

## Step 5：一次性输出以下文件：
1. backend-prd.md  
2. frontend-prd.md  
3. mobile-prd.md  
4. api-docs.md  
5. openapi.yaml  
6. execution-plan.md  
7. handoff-diagram.mmd  
8. README.md
EOF
)

# ========== 3. 复制到剪贴板 ==========
if command -v pbcopy &>/dev/null; then
    echo "$PROMPT" | pbcopy
    echo "✅ Prompt 已复制到剪贴板（macOS）"
elif command -v xclip &>/dev/null; then
    echo "$PROMPT" | xclip -selection clipboard
    echo "✅ Prompt 已复制到剪贴板（Linux）"
elif command -v clip &>/dev/null; then
    echo "$PROMPT" | clip
    echo "✅ Prompt 已复制到剪贴板（Windows Git Bash）"
else
    echo "❌ 未检测到剪贴板工具，请手动复制提示内容"
    echo "$PROMPT"
fi

echo "💡 打开 VSCode augment 插件，直接粘贴（Ctrl+V / Cmd+V）即可执行"
