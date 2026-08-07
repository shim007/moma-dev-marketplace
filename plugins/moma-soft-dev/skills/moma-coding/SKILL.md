---
name: moma-coding
description: 'moma-soft-dev 子技能 —— 编码开始。当用户消息以 /moma-coding 开头时使用本技能， 基于已生成的 01~07 文档进入阶段4 编码，严格遵循文档中的 ⚠️ AI 约束 标记。 实现后需进行初步自我验证；如需偏离文档，必须先在 08-变更日志.md 登记并获用户确认。'
---

# /moma-coding —— 编码开始

直接进入阶段4，基于已生成的文档进行编码。

> 共享约定见 `${CLAUDE_PLUGIN_ROOT}/skills/moma-soft-dev/references/common-conventions.md`，编码通用约束（约束即法律 / 可追溯性 / 先登记后变更 / 自我验证）必须严格遵守。

## 上下文范围

加载 `docs/` 下的 01~07 全部文档，特别关注所有 `⚠️ AI 约束` 标记。不加载插件内置模板（`${CLAUDE_PLUGIN_ROOT}/templates/simple-software/`）。

## 步骤

1. 将 01~07 文档作为编码约束上下文。
2. 严格遵循 `⚠️ AI 约束` 标记进行编码实现。
3. 实现后根据技术栈进行初步自我验证，验证通过才算完成。
4. 如需偏离文档，先在 `docs/08-变更日志.md` 登记，获用户确认后再执行。
