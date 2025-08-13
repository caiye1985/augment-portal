

### ✅ 修改后的 Prompt（适合新目录结构 + update_prd.sh 调用）

```
你现在是资深系统架构师兼 AI 产品经理。

---

## Step 0：读取 PRD 最新版本路径
- 使用外部传入的路径变量 `LATEST_PRD_DIR`（由 update_prd.sh 提供）
- 例如：`docs/prd/split/4.7`
- 递归读取 `LATEST_PRD_DIR` 下所有 `.md` 文件（原始拆分版 + AI 精简版如存在）

---

## Step 1：生成主要交付文件（存放到 docs/output/{版本号}/）

1. backend-prd.md  
   - 后端精简 PRD（架构、模块、技术栈、部署、安全要求等）  

2. frontend-prd.md  
   - Web 前端精简 PRD（UI、交互、布局、API对接等）  

3. mobile-prd.md（Flutter 版）  
   - Flutter 技术栈（Dart 3.x、Material/Cupertino、自定主题、Riverpod/Bloc、GoRouter、Hive/drift、Dio）
   - 模块功能 & API 对接
   - 手势/响应式/离线模式/性能优化/Security
   - 可直接给 Cursor 生成 Flutter App  

4. api-docs.md  
   - 按模块列 API（路径/方法/权限/参数/响应/错误码），带 Mock 数据  

5. openapi.yaml  
   - OpenAPI 3.1 标准
   - 路径含 `/api/v{version}/`，字段命名规范 & Mock  
   - 可直接导入 Swagger / Postman  

6. execution-plan.md  
   - 立即行动 / 中期改进 / 长期维护  

---

## Step 2：生成并行交接图（美化版）

### Mermaid 源码模版（使用实际 `{LATEST_PRD_DIR}` 路径）：
```mermaid
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

    A[原始 PRD 目录<br/>{LATEST_PRD_DIR}] --> B[augment 运行<br/>一次性终极 Prompt]

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
```

---

## Step 3：交接图交付要求
- 输出到 `docs/output/{版本号}/`  
- 包含：
  - `handoff-diagram.mmd`（Mermaid 源文件）
  - `handoff-diagram.png`（渲染后的彩色流程图）
- PNG 必须按模板配色，比例适合 Wiki/PPT 展示
- Mermaid 源文件便于后期修改

---

## Step 4：统一规范
1. 删除冗余背景和重复描述  
2. 缩写首次出现加全称（中英文）  
3. 输出 Markdown 结构一致  
4. API 文档和 OpenAPI 字段命名一致  
5. Mock 数据符合命名规范 & 版本化规范  
6. 替换 `{LATEST_PRD_DIR}` 为脚本传入的实际路径

---

## Step 5：一次性输出以下文件：
1. backend-prd.md  
2. frontend-prd.md  
3. mobile-prd.md  
4. api-docs.md  
5. openapi.yaml  
6. execution-plan.md  
7. handoff-diagram.mmd  
8. handoff-diagram.png
```

---

这样你在 VSCode augment 插件里运行的时候：  
- `update_prd.sh` 会先算出 `LATEST_PRD_DIR`  
- 然后把这个 Prompt + 路径变量一起粘进 augment  
- augment 按这个路径去读取 PRD → 一次性输出版本化产物到 `docs/output/{版本号}/`  

---
