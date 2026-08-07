# moma-dev-marketplace

MoMa Soft 的 **Claude Code 插件市场（Marketplace）** 仓库，用于发布与维护 moma 系列 Claude Code 插件。

## 插件列表

| 插件 | 版本 | 说明 |
|------|------|------|
| [moma-soft-dev](./plugins/moma-soft-dev/) | 1.5.0 | AI 驱动的简化软件开发流程管控插件：文档先行、约束编码，提供 `/moma-init`、`/moma-coding`、`/moma-test`、`/moma-release` 等 16 个工作指令 |

## 快速安装

在 Claude Code 中依次执行：

```
/plugin marketplace add shim007/moma-dev-marketplace
/plugin install moma-soft-dev@moma-dev-marketplace
```

重启 Claude Code（或开启新会话）后，在输入栏键入 `/moma-` 即可看到全部指令。

更详细的安装、验证、升级、卸载说明见 [plugins/moma-soft-dev/README.md](./plugins/moma-soft-dev/README.md)。

## 跨工具支持

本 marketplace 以 Claude Code 插件格式打包，但技能内容为纯 Markdown 自然语言指令、不绑定特定工具，也可在其他 AI 工具中使用：

| 工具 | 安装方式 |
|------|---------|
| Claude Code | `/plugin marketplace add` + `/plugin install`（完整插件体验） |
| GitHub Copilot CLI | 同上（兼容格式），或手动复制插件目录 |
| Codex CLI / OpenCode | 通用安装法：复制插件目录 + 在 `AGENTS.md` 挂载（见插件 README 附录） |
| Cursor | 通用安装法，或复制到原生 `.cursor/skills/` 目录 |
| Gemini CLI 及其他 | 通用安装法：复制插件目录 + 在 `GEMINI.md` 等指令文件挂载 |

各工具的详细安装步骤见 [plugins/moma-soft-dev/README.md](./plugins/moma-soft-dev/README.md#安装)。

## moma-soft-dev 是什么

它把自然语言需求转化为结构化文档体系，再用文档约束 AI 编码，防止需求漂移和技术栈漂移：

```
用户输入需求 → AI 按阶段生成约束文档（01~07）→ 文档约束 AI 编码 → 变更全程留痕（08 变更日志 / 09 BUG 记录）
```

| 指令 | 用途 |
|------|------|
| `/moma-init` | 启动新项目，按阶段生成 01~07 全套文档 |
| `/moma-sync` | 分析已有项目代码，反向补全或生成文档 |
| `/moma-coding` | 文档就绪后进入编码 |
| `/moma-modify` | 调整已有需求（含功能删减），同步更新文档与代码 |
| `/moma-optimize` | 细化已有功能的行为边界（含纯重构模式） |
| `/moma-new` | 增加原需求未包含的新功能 |
| `/moma-fix` | 定位并修复代码异常 |
| `/moma-test` | 补齐并执行测试，输出报告，闭环缺陷状态 |
| `/moma-review` | 对照文档与规约评审代码变更，输出分级问题 |
| `/moma-check` | 只读检查文档与代码的双向漂移（防腐层） |
| `/moma-release` | 聚合变更记录，产出发布说明、版本号与 tag |
| `/moma-incident` | 事故应急：先止血、后定位、再修复防复发 |
| `/moma-migrate` | 数据库迁移：可回滚、先备份、确认后执行 |
| `/moma-security` | 六维度安全审查，输出分级问题与报告 |
| `/moma-retro` | 项目/里程碑复盘，产出经验教训与改进行动 |
| `/moma-session-complete` | 总结当前会话流程并归档为 md 文档 |

## 仓库结构

```
moma-dev-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # marketplace 主清单（Claude Code 插件规范入口）
├── .github/plugin/
│   └── marketplace.json          # GitHub Copilot CLI 兼容副本（须与主清单同步）
├── plugins/
│   └── moma-soft-dev/            # 插件本体（安装时以该目录为单位整体分发）
│       ├── .claude-plugin/plugin.json
│       ├── skills/               # 17 个技能（16 个工作指令 + 1 个总览）
│       └── templates/            # 内置文档模板，随插件分发
├── software/                     # 完整版（10 阶段）软件文档模板库，参考资料，暂未打包为插件
├── moma-soft-dev-workspace/      # moma-soft-dev 技能评测（evals）工作区与结果存档
├── AGENTS.md                     # 面向所有 AI 助手的项目开发约定（跨工具标准）
├── CLAUDE.md                     # Claude Code 专属补充（指向 AGENTS.md）
└── README.md                     # 本文件
```

## 开发者指南

### 本地调试插件

```
/plugin marketplace add <本仓库根目录的绝对路径>
/plugin install moma-soft-dev@moma-dev-marketplace
```

重启会话后用 `plugins/moma-soft-dev/skills/moma-soft-dev/evals/evals.json` 中的 prompt 抽查场景。

> 已知问题：部分 Claude Code 版本对本地目录源 marketplace 的插件 install/update 会报 *"source type ... does not support"*。此时改用仓库自带的同步脚本：修改插件后运行 `bash scripts/sync-local-plugin.sh`（Windows 下用 `pwsh scripts/sync-local-plugin.ps1`），再重启会话即可。

### 发布新版本

1. 修改插件内容后，同步更新三处版本号（语义化版本）：
   - `plugins/moma-soft-dev/.claude-plugin/plugin.json` 的 `version`
   - `.claude-plugin/marketplace.json` 中对应插件条目的 `version`
   - `.github/plugin/marketplace.json` 中对应插件条目的 `version`
2. 提交并推送到 `master`；用户侧执行 `/plugin marketplace update` + `/plugin update` 即可获取。

### 新增插件

1. 在 `plugins/<插件名>/` 下创建插件目录，包含 `.claude-plugin/plugin.json` 清单；
2. 技能放在 `plugins/<插件名>/skills/<技能名>/SKILL.md`；
3. **插件运行所需的一切资源（模板、脚本、参考文档）必须放在该插件目录内部**，并在技能中通过 `${CLAUDE_PLUGIN_ROOT}` 引用，不得依赖仓库根目录文件；
4. 在 `.claude-plugin/marketplace.json` 的 `plugins` 数组中登记该插件；
5. 按上文"本地调试"流程验证后发布。

## 相关链接

- Claude Code 插件机制：`/plugin` 命令、`/plugin marketplace --help`
- 问题反馈：本仓库 Issues
