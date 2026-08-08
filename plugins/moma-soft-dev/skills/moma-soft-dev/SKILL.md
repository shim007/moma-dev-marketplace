---
name: moma-soft-dev
description: 'AI 驱动的简化软件开发流程管控总览技能，集中维护 moma-* 系列子技能的共享约定（文档存放规则、文档体系、编码通用约束、验证阶梯、文档预检规则）。 当用户询问 moma-soft-dev 流程的总体设计、文档体系、阶段划分，或不确定该用哪个 /moma-* 指令时使用本技能。 每个具体的工作指令由独立的子技能处理：/moma-init、/moma-sync、/moma-coding、/moma-modify、/moma-optimize、/moma-new、/moma-fix、/moma-test、/moma-review、/moma-check、/moma-release、/moma-incident、/moma-migrate、/moma-security、/moma-retro、/moma-session-complete、/moma-commit。 这些子技能均位于 skills/moma-* 目录下，并共享 skills/moma-soft-dev/references/common-conventions.md 中定义的约定。'
---

# moma-soft-dev：AI 驱动的简化软件开发流程（总览）

本技能将用户的自然语言需求转化为一套结构化的项目文档体系，再用这些文档反过来约束 AI 的编码行为。核心理念：

> **用户输入需求 → AI 按阶段生成约束文档 → 文档约束 AI 编码**

每份文档都包含 `⚠️ AI 约束` 标记，这些约束在编码时具有最高优先级，防止 AI 偏离需求或技术栈漂移。

## 子技能（斜杠指令）

实际工作由下列独立的子技能承担，每个子技能对应一个斜杠指令，可在输入栏直接通过 `/` 自动补全：

| 指令 | 子技能位置 | 用途 |
|------|------------|------|
| `/moma-init` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-init/` | 启动新项目，生成全套文档 |
| `/moma-sync` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-sync/` | 分析已有项目代码，补全或生成文档 |
| `/moma-coding` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-coding/` | 文档就绪后进入编码 |
| `/moma-modify` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-modify/` | 调整已有需求（含功能删减），同步文档与代码 |
| `/moma-optimize` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-optimize/` | 细化已有功能的行为边界（含纯重构模式） |
| `/moma-new` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-new/` | 增加原需求未包含的新功能 |
| `/moma-fix` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-fix/` | 定位并修复代码异常 |
| `/moma-test` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-test/` | 补齐并执行测试，闭环缺陷状态 |
| `/moma-review` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-review/` | 对照文档与规约评审代码变更 |
| `/moma-check` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-check/` | 只读检查文档与代码的双向漂移 |
| `/moma-release` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-release/` | 聚合变更记录，产出发布说明与 tag |
| `/moma-incident` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-incident/` | 事故应急：先止血、后定位、再修复 |
| `/moma-migrate` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-migrate/` | 数据库迁移：可回滚、先备份、确认执行 |
| `/moma-security` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-security/` | 六维度安全审查，输出分级问题 |
| `/moma-retro` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-retro/` | 项目/里程碑复盘与改进行动 |
| `/moma-session-complete` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-session-complete/` | 总结当前会话流程并归档 md 文档 |
| `/moma-commit` | `${CLAUDE_PLUGIN_ROOT}/skills/moma-commit/` | 一键区分未提交变更并分组做规范提交（项目周期外的实用指令） |

其中 `/moma-commit` 是项目周期外的实用指令：不依赖 01~09 文档、不做文档预检，用于整理工作区中混杂的未提交变更（区分有用改动、应忽略文件、无意义空文件与疑似敏感文件），可在任何时候单独使用。

## 共享约定

所有 `moma-*` 子技能都遵循以下共享约定，集中维护在：

- **`${CLAUDE_PLUGIN_ROOT}/skills/moma-soft-dev/references/common-conventions.md`** —— 文档存放规则（`dev-docs/`）、文档体系与阶段、编码通用约束（含验证阶梯）、文档预检规则、上下文精简原则、多会话并行规约
- **`${CLAUDE_PLUGIN_ROOT}/skills/moma-soft-dev/references/doc-dependencies.md`** —— 文档间依赖关系图与派生产物清单
- **`${CLAUDE_PLUGIN_ROOT}/skills/moma-soft-dev/references/change-workflow.md`** —— `/moma-modify`、`/moma-optimize`、`/moma-new` 共用的变更流程（登记→文档同步→代码变更→变更日志→提交）

子技能在执行前应先阅读 `common-conventions.md` 以获取最新约定。

## 主流程与质量闭环

```
新项目                        已有代码的项目
   │                              │
/moma-init（生成全套文档）    /moma-sync（反向补全文档）
   │                              │
   └──────────┬───────────────────┘
              ▼
        用户审核文档
              ▼
        /moma-coding（受文档约束编码）
              ▼
  ┌───────────┼────────────────────────┐
/moma-modify  /moma-optimize  /moma-new  /moma-fix
（需求调整）   （细节优化/重构）（功能新增）（异常修复）
              ▼
        质量与发布闭环
              ▼
/moma-test（测试验证、缺陷回归）→ /moma-review（评审把关）
              ▼
/moma-release（发布说明、版本号、tag）
              ▼
/moma-session-complete（会话归档）
```

- **防腐层：** 开发过程中建议定期执行 `/moma-check`（只读、可并行），检测文档与代码的双向漂移，防止文档腐烂导致约束失效。
- **缺陷状态闭环：** `/moma-fix` 修复后将 BUG 置为"已修复"，`/moma-test` 回归通过后按共享约定规则4的"状态流转例外"流转为"已验证"。

## 扩展保障（低频但关键）

主流程之外，四类低频但高风险的场景由专门指令承接：

| 场景 | 指令 | 核心纪律 |
|------|------|----------|
| 生产事故 | `/moma-incident` | 先止血（回滚/降级）后定位，止血操作需用户确认，事后补齐流程登记 |
| 数据模型高危变更 | `/moma-migrate` | 脚本必可回滚、执行前必备份、物理删除必明确确认；变更类指令发现需迁移时应路由到此 |
| 安全审查 | `/moma-security` | 六维度只读审查（注入/认证/敏感信息/依赖/配置/数据保护），严重问题建议立即修复 |
| 里程碑/项目复盘 | `/moma-retro` | 聚合过程数据产出经验教训，每条改进行动必须标注承接指令 |

## 多会话并行

moma-* 工作指令支持多个 AI 会话（agent）在同一工作目录并行工作，核心规则六条：

1. **会话登记** —— 每个会话在花名册 `<docs-root>/.moma-state/roster.md` 中登记会话 ID、指令、工作范围与状态；
2. **代码并行** —— 涉及代码修改的指令声明工作范围，范围重叠时后到者拒绝执行，避免互相覆盖；`/moma-check`、`/moma-review`、`/moma-security`、`/moma-retro` 为只读指令，不参与范围冲突；`/moma-incident` 应急时可经用户确认优先执行；
3. **文档单写者** —— 01~07 文档同一时刻只允许一个会话写入；`/moma-init`、`/moma-sync` 为独占指令；
4. **追加式写入** —— 08-变更日志与 09-BUG记录只允许追加含会话 ID 的条目（仅状态字段可按"状态流转例外"受控更新），写入前后重读验证；
5. **git 兜底** —— 写入前打检查点提交，完成后只提交本会话范围内的文件，保证冲突可回滚、提交不互相污染；
6. **worktree 兜底隔离** —— 范围重叠、文档单写者或独占指令冲突无法避免时，向用户提议迁移到独立 git worktree 继续（需前置检查与用户确认），把实时冲突转化为合并时的显式冲突处理。

完整规则见 `common-conventions.md` 的"多会话并行规约"章节。重度并行场景（3 个以上会话）建议直接改用 git worktree 为每个会话提供独立工作目录，稳定性最高。

> `${CLAUDE_PLUGIN_ROOT}` 在 Claude Code / GitHub Copilot CLI 中自动解析为本插件的安装根目录；在其他工具中若未展开，视为本插件目录的绝对路径即可。模板文件位于 `${CLAUDE_PLUGIN_ROOT}/templates/simple-software/`。

## 与单 skill 旧版本的关系

历史版本中所有指令行为集中在本 SKILL.md 中（通过中括号关键字 `[项目启动]` 等触发）。为了支持输入栏的 `/` 斜杠指令自动补全，已将每个指令拆分成同名独立子技能。本文件仅保留总览与共享约定的指引，不再承担具体指令的执行职责。
