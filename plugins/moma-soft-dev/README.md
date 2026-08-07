# moma-soft-dev 插件

AI 驱动的简化软件开发流程管控插件，通过标准化的文档体系驱动软件项目的完整生命周期。核心理念：

> **用户输入需求 → AI 按阶段生成约束文档 → 文档约束 AI 编码**

本插件以 Claude Code plugin 格式打包，技能内容为纯 Markdown 自然语言指令、不绑定任何特定工具，因此也可在 GitHub Copilot CLI、Codex CLI、Cursor、Gemini CLI 等 AI 工具中使用（见下文各工具安装说明）。

## 提供的技能（斜杠指令）

| 指令 | 用途 |
|------|------|
| `/moma-init` | 启动新项目，按阶段生成 01~07 全套文档 |
| `/moma-sync` | 分析已有项目代码，反向补全或生成 01~07 文档 |
| `/moma-coding` | 文档就绪后进入编码 |
| `/moma-modify` | 调整已有需求（含功能删减），同步更新文档与代码 |
| `/moma-optimize` | 细化已有功能的行为边界（含纯重构模式） |
| `/moma-new` | 增加原需求未包含的新功能 |
| `/moma-fix` | 定位并修复代码异常 |
| `/moma-test` | 补齐并执行测试，输出报告，闭环缺陷状态 |
| `/moma-review` | 对照文档与规约评审代码变更，输出分级问题 |
| `/moma-check` | 只读检查文档与代码的双向漂移（防腐层） |
| `/moma-release` | 聚合变更记录，产出发布说明、版本号与 tag |
| `/moma-session-complete` | 总结当前会话流程并归档为 md 文档 |

另有一个总览技能 `moma-soft-dev`，用于介绍整体流程与共享约定，不执行具体工作。

## 安装

各工具支持程度一览：

| 工具 | 安装方式 | 体验 |
|------|---------|------|
| Claude Code | marketplace 安装（推荐） | 完整插件体验：`/moma-*` 自动补全、命名空间、一键升级 |
| GitHub Copilot CLI | marketplace 安装或手动复制 | 完整插件体验（兼容 Claude Code 插件格式） |
| Codex CLI / OpenCode 等 | 通用安装法（复制 + AGENTS.md 挂载） | 指令可用，无自动补全 |
| Cursor | 通用安装法，或原生 skills 目录 | 指令可用 |
| Gemini CLI 及其他 | 通用安装法（GEMINI.md 等挂载） | 指令可用，无自动补全 |

### Claude Code（推荐）

在 Claude Code 中依次执行：

```
/plugin marketplace add shim007/moma-dev-marketplace
/plugin install moma-soft-dev@moma-dev-marketplace
```

然后重启 Claude Code（或开启新会话）。在输入栏键入 `/moma-`，即可看到全部指令的自动补全。

**本地安装（开发调试用）**：克隆本仓库后，将 marketplace 指向本地目录：

```
/plugin marketplace add /绝对路径/到/moma-dev-marketplace
/plugin install moma-soft-dev@moma-dev-marketplace
```

### GitHub Copilot CLI

Copilot CLI 兼容 Claude Code 插件格式，可尝试相同的 marketplace 流程：

```
/plugin marketplace add shim007/moma-dev-marketplace
/plugin install moma-soft-dev
```

如果你的 Copilot CLI 版本不支持 marketplace，可手动复制整个插件目录：

```powershell
# Windows (PowerShell)
$dst = "$env:USERPROFILE\.copilot\installed-plugins\local\moma-soft-dev"
New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
Copy-Item -Recurse -Force "<克隆的本仓库>\plugins\moma-soft-dev" $dst
```

```bash
# macOS / Linux (bash)
mkdir -p "$HOME/.copilot/installed-plugins/local"
cp -R /path/to/moma-dev-marketplace/plugins/moma-soft-dev "$HOME/.copilot/installed-plugins/local/"
```

完成后执行 `/reload-plugins` 或重启 CLI。具体目录与命令以你当前 Copilot CLI 版本的官方文档为准。

### Codex CLI / OpenCode（通用安装法）

Codex 等遵循 `AGENTS.md` 标准但没有插件 marketplace 的工具，采用"整体复制 + 指令文件挂载"方式：

1. 将插件目录整体复制到你的项目中（推荐命名为 `.moma/`）：

   ```bash
   cp -R /path/to/moma-dev-marketplace/plugins/moma-soft-dev ./.moma
   ```

2. 在项目根目录的 `AGENTS.md` 中追加下方 **[通用挂载段落]**（把其中的 `.moma` 替换为实际路径）。
3. 重启会话后，直接发送 `/moma-init` 等指令即可。

### Cursor

两种方式任选其一：

- **方式 A（推荐）：通用安装法** —— 同 Codex：把插件目录复制到项目内（如 `.cursor/moma/` 或任意稳定目录），在 `.cursor/rules/` 下新建规则文件，粘贴 [通用挂载段落]（路径相应替换）。
- **方式 B：原生 skills 目录** —— 把 `skills/` 下每个 `moma-*` 目录复制到项目的 `.cursor/skills/`（或全局 `~/.cursor/skills/`）。注意：此方式模板与共享约定不在技能目录内，技能中的 `${CLAUDE_PLUGIN_ROOT}` 不会自动解析，需自行保证插件目录可被访问；不确定时请用方式 A。

### Gemini CLI 及其他工具

同样使用通用安装法：复制插件目录后，把 [通用挂载段落] 追加到对应工具的指令文件（Gemini CLI 为 `GEMINI.md`，Aider 为 `CONVENTIONS.md`，等等），路径按实际位置替换。

### 附：通用挂载段落

将以下内容追加到你的项目指令文件（`AGENTS.md` / `GEMINI.md` / Cursor rules 等），并把其中的 `.moma` 替换为插件目录的实际路径：

````markdown
## moma-soft-dev 工作指令

当用户消息以下列任一指令开头时，执行对应的 moma-soft-dev 技能：
/moma-init、/moma-sync、/moma-coding、/moma-modify、/moma-optimize、/moma-new、/moma-fix、/moma-test、/moma-review、/moma-check、/moma-release、/moma-session-complete

执行规则：

1. 先阅读 `.moma/skills/moma-soft-dev/references/common-conventions.md` 了解共享约定；
2. 阅读并严格遵循 `.moma/skills/<与指令同名的目录>/SKILL.md` 中的步骤；
3. 技能文档中出现的 `${CLAUDE_PLUGIN_ROOT}` 一律解析为本插件目录的绝对路径（本配置下即 `.moma`），例如模板位于 `.moma/templates/simple-software/`。
````

## 典型工作流

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
（需求调整）  （细节优化/重构）（功能新增）（异常修复）
              ▼
        质量与发布闭环
              ▼
/moma-test（测试验证、缺陷回归）→ /moma-review（评审把关）
              ▼
/moma-release（发布说明、版本号、tag）
              ▼
      /moma-session-complete（会话归档）
```

- **防腐层：** 开发过程中定期执行 `/moma-check`（只读、可与其他指令并行），检测文档与代码的双向漂移，防止文档腐烂导致约束失效。
- **缺陷状态闭环：** `/moma-fix` 修复后置为"已修复"，`/moma-test` 回归通过后流转为"已验证"（状态流转规则见共享约定规则4）。

## 多会话并行（多 agent 同目录协作）

工作指令支持多个 AI 会话（agent）在同一工作目录并行工作，依靠花名册与六条规则保证安全（完整规则见 `skills/moma-soft-dev/references/common-conventions.md` 的"多会话并行规约"）：

1. **会话登记** —— 每个会话在花名册 `<docs-root>/.moma-state/roster.md` 中登记会话 ID、指令、工作范围与状态；
2. **代码并行** —— 涉及代码修改的指令声明工作范围，范围重叠时后到者拒绝执行，避免互相覆盖；
3. **文档单写者** —— 01~07 文档同一时刻只允许一个会话写入；`/moma-init`、`/moma-sync` 为独占指令；
4. **追加式写入** —— 08-变更日志与 09-BUG记录只允许追加含会话 ID 的条目，写入前后重读验证；
5. **git 兜底** —— 写入前打检查点提交，完成后只暂存本会话范围内的文件提交，冲突可回滚、提交不互相污染；
6. **worktree 兜底隔离** —— 冲突无法避免时（范围重叠、文档单写者、独占指令遇活跃会话），向用户提议迁移到独立 git worktree 继续，把实时冲突转化为合并时的显式冲突；需满足前置条件（git 仓库、文档已入库）并获用户确认。

单会话使用时上述限制全部不生效，行为与旧版本一致。重度并行场景（3 个以上会话）建议直接改用 git worktree 为每个会话提供独立工作目录与分支，稳定性最高。

## 验证安装

- **Claude Code / Copilot CLI**：执行 `/plugin` 打开插件管理界面，确认 `moma-soft-dev` 已安装并启用；输入 `/moma-` 应看到 12 个工作指令的自动补全。
- **通用安装法**：向 AI 发送 `/moma-init 我想做一个待办事项应用`，确认其能读取 `.moma/templates/simple-software/` 下的模板并开始生成文档。

## 升级 / 卸载

- **Claude Code**：

  ```
  /plugin marketplace update moma-dev-marketplace   # 刷新 marketplace 元数据
  /plugin update moma-soft-dev                      # 升级插件
  /plugin uninstall moma-soft-dev                   # 卸载插件
  /plugin marketplace remove moma-dev-marketplace   # 移除 marketplace（可选）
  ```

- **Copilot CLI（手动复制方式）/ 通用安装法**：重新复制最新版本的插件目录覆盖原目录即可；卸载则直接删除该目录（及指令文件中的挂载段落）。

## 目录结构

```
plugins/moma-soft-dev/
├── .claude-plugin/plugin.json        # 插件清单（Claude Code / Copilot CLI 插件规范）
├── README.md                         # 本文件
├── templates/
│   └── simple-software/              # 内置文档模板（01~08），随插件一起分发
│       ├── README.md                 # 文档体系说明
│       ├── 01-项目概要.md ~ 07-测试策略.md
│       └── 08-变更日志.md
└── skills/
    ├── moma-soft-dev/                # 总览技能（共享约定与文档体系说明）
    │   ├── SKILL.md
    │   ├── evals/evals.json          # 技能评测用例
    │   └── references/
    │       ├── common-conventions.md # 所有子技能共享的约定
    │       ├── doc-dependencies.md   # 文档间依赖关系图
    │       └── change-workflow.md    # modify/optimize/new 共用变更流程
    ├── moma-init/SKILL.md
    ├── moma-sync/SKILL.md
    ├── moma-coding/SKILL.md
    ├── moma-modify/SKILL.md
    ├── moma-optimize/SKILL.md
    ├── moma-new/SKILL.md
    ├── moma-fix/SKILL.md
    ├── moma-test/SKILL.md
    ├── moma-review/SKILL.md
    ├── moma-check/SKILL.md
    ├── moma-release/SKILL.md
    └── moma-session-complete/SKILL.md
```

> 插件运行所需的全部资源（模板、参考文档）均已内置在插件目录中，通过 `${CLAUDE_PLUGIN_ROOT}` 引用。该变量在 Claude Code / Copilot CLI 中自动展开为插件安装根目录；在其他工具中不会展开，按上文"通用挂载段落"的方式将其解析为插件目录实际路径即可，因此本插件可跨工具使用。
