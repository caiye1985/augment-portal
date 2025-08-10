# 📚 双版本需求文档维护操作规程（SOP）

## 1. 目标
本规程旨在确保 **完整版PRD（Full PRD）** 与 **AI执行版（Execution PRD）** 在内容上的一致性，通过明确责任人、工作流、版本管理和自动化工具使用规则，避免信息漂移，保障开发与AI使用的统一信息源。

---

## 2. 角色与职责

| 角色 | 职责 |
|------|------|
| **产品经理（PM）** | 维护完整版PRD为唯一权威源，负责所有需求变更的收集与确认 |
| **文档专员 / 研发代表** | 根据完整版PRD更新派生的AI执行版，确保信息准确性和可执行性 |
| **AI生成引擎（Claude/GPT）** | 根据模板和规则自动生成AI执行版 |
| **审核人（技术负责人/QA）** | 审核PRD变更及AI执行版输出，确保一致性 |

---

## 3. 文档存储结构（Git 仓库示例）

```
/docs/prd/full/REQ-xxx_Full_vX.Y.md           # 完整版PRD
/docs/prd/execution/REQ-xxx_Exec_vA.B_from_X.Y.md  # AI执行版
/docs/prd/changelog.md                        # 变更日志（双份文档更新记录）
```

- **命名规范**：
  - 完整版：`REQ-016_Full_v1.2.md`
  - 执行版：`REQ-016_Exec_v1.0_from_v1.2.md`
- **含义**：执行版 `v1.0` 从完整版 `v1.2` 派生

---

## 4. 版本与源的原则

- **完整版 PRD** 是 **单一信息源（SSOT）**  
  所有需求变更必须先改完整版  
- **AI执行版** 是从完整版自动/半自动派生  
  执行版不可直接修改，如有调整需求 → 回写完整版 → 重新生成执行版

---

## 5. 更新触发与工作流

**更新触发条件**：
1. PRD 新增功能或调整（任何需求变更）
2. 功能清单、接口规范、数据模型、业务规则修改
3. 非功能需求（性能/安全/扩展性）数值化指标变更

---

### **工作流步骤**

#### Step 1 - 修改完整版PRD
- PM 修改 `/full/` 下的对应MD文件
- 更新版本号和变更记录（简述变更点）
- 提交至 Git，发起 Merge Request/PR

#### Step 2 - 自动生成执行版
- CI/CD Pipeline 或手动运行 AI 同步脚本
- 使用固定 Prompt 将最新版完整版 PRD 生成执行版格式：
  - 删除业务背景、市场描述
  - 保留结构化可执行信息（功能/规则/用例/API/数据模型/非功能指标/依赖关系）
  - 按执行版模板输出

Prompt 模板示例：
```markdown
根据以下完整版PRD生成AI执行版：
- 删除非实现相关描述（背景、ROI、竞争优势）
- 保留并结构化功能清单、业务规则、用例（Given/When/Then格式）、数据模型（字段表）、API规范（URL/参数/响应）、非功能需求（具体数值）、依赖关系
- 输出Markdown，表格字段命名与接口保持统一
```

#### Step 3 - 审核与对比
- 系统生成执行版后，与之前执行版做 `diff`
- 由 **文档专员** 对比差异并人工确认
- 技术负责人/QA 审核执行版是否与完整版100%一致（内容+版本号）

#### Step 4 - 发布与归档
- 审核通过后合并执行版文件到 `/execution/`
- 更新 `/changelog.md` 记录：
  ```
  2025-01-15:
  REQ-018 Full v2.3 -> Exec v1.5_from_v2.3
  - 更新了 API /invoices 增加字段 tax_amount
  - 数据模型新增 tax_amount 字段
  ```

---

## 6. 自动化保障（推荐）

### CI/CD 自动生成执行版
- GitHub Actions 或 GitLab CI 脚本示例：
```yaml
on:
  push:
    paths:
      - 'docs/prd/full/**.md'
jobs:
  generate-exec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run AI to generate Execution PRD
        run: |
          python generate_exec.py --input docs/prd/full --output docs/prd/execution
      - name: Commit execution docs
        run: |
          git config --global user.name 'AI Bot'
          git config --global user.email 'bot@example.com'
          git add docs/prd/execution
          git commit -m "Update Execution PRD from Full PRD"
          git push
```

---

## 7. 变更审核Checklist

**每次PRD更新必须检查：**
- [ ] 功能清单编号和名称是否同步更新执行版
- [ ] 数据模型字段是否完整且类型、命名一致
- [ ] API参数/返回结构是否同步执行版
- [ ] 非功能指标的数值和单位一致
- [ ] 依赖模块清单是否正确反映
- [ ] 版本号、变更记录已更新

---

## 8. 风险与防范

**风险**：
- 双版本手工维护可能出现漏同步  
- AI生成版未复核直接投入AI训练/开发，导致用错数据

**防范**：
- 所有执行版由系统生成，严禁人工直接修改
- 关键版本差异通过 `diff` 工具和AI对比报告双重验证
- 定期（每月）全量比对完整版和执行版的一致性

---

## 9. 总结

- **单一源头、自动派生、人工复核**是双版本不漂移的核心  
- 用 Git+CI/CD+AI 自动生成执行版，减少人工重复劳动  
- 完整版服务于管理与决策，执行版直供AI开发、接口设计、测试用例生成  
- 严格的版本号与变更日志是追溯和审计的保障

---

✅ 如果你愿意，我可以直接帮你做一份 **执行版PRD模板**，这样以后AI同步时就严格往模版里填，实现结构100%标准化。  
这样不仅方便同步，也方便Claude/GPT进行解析、编码和测试用例生成。  

是否帮你出一份 **AI执行版PRD模板**？这样以后可以自动生成、自动比对。