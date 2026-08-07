# moma-soft-dev 插件

AI 驱动的简化软件开发流程管控插件，通过标准化的文档体系驱动软件项目的完整生命周期。核心理念：

> **用户输入需求 → AI 按阶段生成约束文档 → 文档约束 AI 编码**

## 提供的技能（斜杠指令）

安装后，在 Claude Code 输入栏键入 `/moma-` 即可看到自动补全：

| 指令 | 用途 |
|------|------|
| `/moma-init` | 启动新项目，按阶段生成 01~07 全套文档 |
| `/moma-sync` | 分析已有项目代码，反向补全或生成 01~07 文档 |
| `/moma-coding` | 文档就绪后进入编码 |
| `/moma-modify` | 调整已有需求，同步更新文档与代码 |
| `/moma-optimize` | 对已有功能进行细节约束优化 |
| `/moma-new` | 增加原需求未包含的新功能 |
| `/moma-fix` | 定位并修复代码异常 |
| `/moma-session-complete` | 总结当前会话流程并归档为 md 文档 |

另有一个总览技能 `moma-soft-dev`，用于介绍整体流程与共享约定，不执行具体工作。

## 安装

### 方式一：从 marketplace 安装（推荐）

在 Claude Code 中依次执行：

```
/plugin marketplace add shim007/moma-dev-marketplace
/plugin install moma-soft-dev@moma-dev-marketplace
```

然后重启 Claude Code（或开启新会话）。在输入栏键入 `/moma-`，即可看到全部指令的自动补全。

### 方式二：本地安装（开发调试用）

克隆本仓库后，将 marketplace 指向本地目录：

```
/plugin marketplace add /绝对路径/到/moma-dev-marketplace
/plugin install moma-soft-dev@moma-dev-marketplace
```

Windows 路径示例：`/plugin marketplace add C:\workspace\MomaLib\moma-dev-marketplace`。

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
（需求调整）   （细节优化）    （功能新增）（异常修复）
              ▼
      /moma-session-complete（会话归档）
```

## 验证安装

1. 执行 `/plugin` 打开插件管理界面，确认 `moma-soft-dev` 已安装并启用。
2. 在输入栏键入 `/moma-`，应看到上述 8 个工作指令的自动补全。
3. 技能在系统中以 `moma-soft-dev:<技能名>` 形式注册（命名空间前缀即插件名）。

## 升级 / 卸载

```
/plugin marketplace update moma-dev-marketplace   # 刷新 marketplace 元数据
/plugin update moma-soft-dev                      # 升级插件
/plugin uninstall moma-soft-dev                   # 卸载插件
/plugin marketplace remove moma-dev-marketplace   # 移除 marketplace（可选）
```

## 目录结构

```
plugins/moma-soft-dev/
├── .claude-plugin/plugin.json        # 插件清单（Claude Code 插件规范）
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
    │       └── doc-dependencies.md   # 文档间依赖关系图
    ├── moma-init/SKILL.md
    ├── moma-sync/SKILL.md
    ├── moma-coding/SKILL.md
    ├── moma-modify/SKILL.md
    ├── moma-optimize/SKILL.md
    ├── moma-new/SKILL.md
    ├── moma-fix/SKILL.md
    └── moma-session-complete/SKILL.md
```

> 插件运行所需的全部资源（模板、参考文档）均已内置在插件目录中，通过 `${CLAUDE_PLUGIN_ROOT}` 引用（由 Claude Code 自动解析为插件安装根目录），安装后开箱即用，无需依赖本仓库的其他文件。
