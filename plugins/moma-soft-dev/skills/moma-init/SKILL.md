---
name: moma-init
description: 'moma-soft-dev 子技能 —— 项目启动。当用户消息以 /moma-init 开头时使用本技能， 从用户的自然语言需求出发，按阶段1（需求定义）→ 阶段2（技术设计）→ 阶段3（开发约束）的顺序 生成全套项目文档（01~07），为后续 /moma-coding 编码做准备。本指令仅生成文档，不进入编码阶段。'
---

# /moma-init —— 项目启动

从用户需求出发，按阶段生成完整文档体系，为编码做准备。

> 共享约定（文档存放规则 `dev-docs/` 优先于 `docs/`、文档体系、编码通用约束等）见 `${CLAUDE_PLUGIN_ROOT}/skills/moma-soft-dev/references/common-conventions.md`，本文件中出现的 `docs/` 路径均遵循该约定。

## 上下文范围

仅加载用户输入 + 插件内置模板目录 `${CLAUDE_PLUGIN_ROOT}/templates/simple-software/` 下的模板（01~07）。不加载变更日志或已有代码（此时尚无）。

## 步骤

1. **并行检查与登记（独占指令）**
   - 按共享约定的"多会话并行规约"生成会话 ID，读取花名册 `<docs-root>/.moma-state/roster.md`（不存在则创建）。
   - 本指令生成整套文档，属于独占指令：若花名册中存在其他"进行中"会话，拒绝直接执行；按共享约定"规则6：worktree 兜底隔离"提议迁移到独立 worktree 继续，获用户确认后在 worktree 内执行本指令；若用户不接受或前置检查不满足，则等待其他会话完成。若无其他会话，登记本会话条目（指令 `/moma-init`、工作范围"01~07 文档集"、状态"进行中"）。

2. **阶段1 — 需求定义**
   - 总结用户需求意图，详细拆分，补充用户未考虑到的需求细节。
   - 读取 `${CLAUDE_PLUGIN_ROOT}/templates/simple-software/01-项目概要.md` 模板，生成 `docs/01-项目概要.md`。
   - 读取 `${CLAUDE_PLUGIN_ROOT}/templates/simple-software/02-产品需求文档.md` 模板，生成 `docs/02-产品需求文档.md`。

3. **阶段2 — 技术设计**
   - 基于阶段1文档和用户技术倾向，读取模板并生成：
     - `docs/03-技术架构文档.md`
     - `docs/04-数据模型文档.md`
     - `docs/05-API接口文档.md`

4. **阶段3 — 开发约束**
   - 读取模板并生成：
     - `docs/06-开发规约.md`
     - `docs/07-测试策略.md`

5. **完成后提示用户**
   - 请用户审核所有文档内容。
   - 建议用户发送 `/moma-coding` 进入阶段4。
   - 将花名册中本会话状态改为"已完成"。

此指令不进入编码阶段，仅生成文档。
