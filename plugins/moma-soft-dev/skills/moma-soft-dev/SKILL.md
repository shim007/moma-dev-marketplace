---
name: moma-soft-dev
description: >
  AI 驱动的简化软件开发流程管控总览技能，集中维护 moma-* 系列子技能的共享约定（文档存放规则、文档体系、编码通用约束）。
  当用户询问 moma-soft-dev 流程的总体设计、文档体系、阶段划分，或不确定该用哪个 /moma-* 指令时使用本技能。
  每个具体的工作指令由独立的子技能处理：/moma-init、/moma-sync、/moma-coding、/moma-modify、/moma-optimize、/moma-new、/moma-fix、/moma-session-complete。
  这些子技能均位于 skills/moma-* 目录下，并共享 skills/moma-soft-dev/references/common-conventions.md 中定义的约定。
---

# moma-soft-dev：AI 驱动的简化软件开发流程（总览）

本技能将用户的自然语言需求转化为一套结构化的项目文档体系，再用这些文档反过来约束 AI 的编码行为。核心理念：

> **用户输入需求 → AI 按阶段生成约束文档 → 文档约束 AI 编码**

每份文档都包含 `⚠️ AI 约束` 标记，这些约束在编码时具有最高优先级，防止 AI 偏离需求或技术栈漂移。

## 子技能（斜杠指令）

实际工作由下列独立的子技能承担，每个子技能对应一个斜杠指令，可在输入栏直接通过 `/` 自动补全：

| 指令 | 子技能位置 | 用途 |
|------|------------|------|
| `/moma-init` | `skills/moma-init/` | 启动新项目，生成全套文档 |
| `/moma-sync` | `skills/moma-sync/` | 分析已有项目代码，补全或生成文档 |
| `/moma-coding` | `skills/moma-coding/` | 文档就绪后进入编码 |
| `/moma-modify` | `skills/moma-modify/` | 调整已有需求，同步文档与代码 |
| `/moma-optimize` | `skills/moma-optimize/` | 对已有功能进行细节约束优化 |
| `/moma-new` | `skills/moma-new/` | 增加原需求未包含的新功能 |
| `/moma-fix` | `skills/moma-fix/` | 定位并修复代码异常 |
| `/moma-session-complete` | `skills/moma-session-complete/` | 总结当前会话流程并归档 md 文档 |

## 共享约定

所有 `moma-*` 子技能都遵循以下共享约定，集中维护在：

- **`references/common-conventions.md`** —— 文档存放规则（`dev-docs/` 优先于 `docs/`）、文档体系与阶段、编码通用约束、上下文精简原则
- **`references/doc-dependencies.md`** —— 文档间依赖关系图

子技能在执行前应先阅读 `common-conventions.md` 以获取最新约定。

## 与单 skill 旧版本的关系

历史版本中所有指令行为集中在本 SKILL.md 中（通过中括号关键字 `[项目启动]` 等触发）。为了支持输入栏的 `/` 斜杠指令自动补全，已将每个指令拆分成同名独立子技能。本文件仅保留总览与共享约定的指引，不再承担具体指令的执行职责。
