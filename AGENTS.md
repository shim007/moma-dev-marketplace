# AGENTS.md

本文件是本仓库面向所有 AI 编码助手（Claude Code、Codex CLI、Cursor、GitHub Copilot CLI、Gemini CLI 等）的**通用开发约定**，是项目规范的单一事实来源。Claude Code 专属补充见 `CLAUDE.md`。

本仓库是 **moma-dev-marketplace** —— MoMa Soft 的 AI 插件市场（Marketplace），用于发布 moma 系列插件。当前发布的插件为 `moma-soft-dev`（文档驱动的软件开发流程管控，含 13 个技能：12 个工作指令 + 1 个总览）。

## 仓库结构

- `.claude-plugin/marketplace.json` —— marketplace 主清单（Claude Code 插件规范，唯一事实来源）
- `.github/plugin/marketplace.json` —— GitHub Copilot CLI 兼容副本，**内容必须与主清单保持同步**
- `plugins/<插件名>/` —— 每个插件一个目录，安装时以该目录为单位整体分发
  - `.claude-plugin/plugin.json` —— 插件清单
  - `skills/<技能名>/SKILL.md` —— 技能定义（Agent Skills 开放格式，跨工具可用）
  - `templates/`、`references/` 等 —— 插件内置资源
- `scripts/` —— 开发辅助脚本（如 `sync-local-plugin.sh` / `sync-local-plugin.ps1`：本地开发时同步插件到 Claude Code 安装，后者为 Windows PowerShell 版）
- `software/` —— 完整版（10 阶段）文档模板库，仅参考资料，未打包进任何插件
- `moma-soft-dev-workspace/` —— 技能评测（evals）工作区与历史结果存档

## 核心规范（修改插件时必须遵守）

1. **自包含原则**：插件运行所需的一切资源（模板、参考文档、脚本）必须位于该插件目录内部，随插件一起分发；**严禁引用仓库根目录下的文件**（安装后根目录文件不存在于用户环境）。
2. **路径引用**：技能中引用插件内置资源一律使用 `${CLAUDE_PLUGIN_ROOT}/...`。该变量在 Claude Code / GitHub Copilot CLI 中自动展开为插件安装根目录；在其他工具中不会展开，读者应将其理解为"插件目录的绝对路径"（各技能文档已包含该兜底说明，**勿删除**）。
3. **保持工具无关**：SKILL.md 正文只使用自然语言指令与通用文件操作描述，**不得写入特定工具专有的命令、API 或配置路径**，保证技能可被任意 AI 工具执行。面向用户的安装差异集中写在 README 中，不要渗进技能正文。
4. **SKILL.md frontmatter**：
   - `name` 必须与所在目录名一致；
   - `description` 写成单行 YAML 字符串（内容较长时用引号包成一行，不要折行）；
   - description 应说明触发时机（如"当用户消息以 /moma-init 开头时使用本技能"）。
5. **共享约定单点维护**：moma-* 系列技能的共享约定集中在 `plugins/moma-soft-dev/skills/moma-soft-dev/references/common-conventions.md`（文档存放规则 `dev-docs/` 优先于 `docs/`、文档体系、编码通用约束、验证阶梯、文档预检规则、多会话并行规约）；`/moma-modify`、`/moma-optimize`、`/moma-new` 的共用变更流程集中在同目录 `change-workflow.md`。修改任何技能行为时，须同步检查并更新这些文件、总览技能 `moma-soft-dev/SKILL.md` 及 `evals/evals.json`。
6. **版本一致性**：调整插件内容后，必须同步更新以下三处 `version`（语义化版本），保持一致：
   - `plugins/moma-soft-dev/.claude-plugin/plugin.json`
   - `.claude-plugin/marketplace.json` 中对应插件条目
   - `.github/plugin/marketplace.json` 中对应插件条目
7. **禁止提交本地状态**：`.omc/`、`.claude/settings.local.json`、操作系统/编辑器临时文件等不得提交（见 `.gitignore`）。

## 文档体系要点（moma-soft-dev 的业务背景）

- 文档分阶段：**阶段1 需求定义**（01 项目概要、02 产品需求）→ **阶段2 技术设计**（03 架构、04 数据模型、05 API）→ **阶段3 开发约束**（06 开发规约、07 测试策略）→ **阶段4 AI 编码**；`08-变更日志` 贯穿全程，`09-BUG记录` 跟踪缺陷。
- 生成的项目文档存放在用户项目的 `dev-docs/`（优先）或 `docs/` 下；模板来自插件内置的 `templates/simple-software/`。
- 文档间依赖关系见 `plugins/moma-soft-dev/skills/moma-soft-dev/references/doc-dependencies.md`。

## 本地验证流程（Claude Code 环境）

1. `/plugin marketplace add <本仓库根目录绝对路径>`（已添加则 `/plugin marketplace update moma-dev-marketplace`）
2. `/plugin install moma-soft-dev@moma-dev-marketplace`（或 `/plugin update moma-soft-dev`）
3. 重启会话，确认输入 `/moma-` 时 12 个工作指令全部出现在自动补全中
4. 用 `plugins/moma-soft-dev/skills/moma-soft-dev/evals/evals.json` 中的 prompt 至少抽查 1 个场景（如 `/moma-init`），确认模板能从 `${CLAUDE_PLUGIN_ROOT}/templates/simple-software/` 正常读取

## 写作约定

- 用户可见文档（README、SKILL.md、模板、清单 description）统一使用**简体中文**。
- Git 提交信息使用简体中文，沿用现有风格（简短描述或 `类型(范围): 描述`）。
