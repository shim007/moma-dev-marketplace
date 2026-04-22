# moma-soft-dev 插件

AI 驱动的简化软件开发流程管控插件，通过标准化的文档体系驱动软件项目的完整生命周期。

## 提供的斜杠指令

安装后，在 Copilot CLI 输入栏键入 `/m` 即可看到自动补全：

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

## 快速安装（推荐）

### 方式一：通过 Copilot CLI 的 `/plugin` 命令安装本地插件

1. 在 Copilot CLI 中执行：
   ```
   /plugin marketplace add E:\Workspace\momasoft\doc-template
   ```
   （路径请改成你本机的仓库根目录绝对路径；macOS/Linux 同理。）

2. 然后安装本插件：
   ```
   /plugin install moma-soft-dev
   ```

3. 重新加载：
   ```
   /reload-plugins
   ```
   或重启 Copilot CLI。

4. 在输入栏键入 `/m`，即可看到 `/moma-init`、`/moma-coding` 等所有 `/moma-*` 指令的自动补全。

### 方式二：复制安装（无需 marketplace）

#### Windows (PowerShell)

```powershell
$src = "E:\Workspace\momasoft\doc-template\plugins\moma-soft-dev"
$dst = "$env:USERPROFILE\.copilot\installed-plugins\local\moma-soft-dev"
New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
Copy-Item -Recurse -Force $src $dst
```

#### macOS / Linux (bash)

```bash
SRC="/path/to/doc-template/plugins/moma-soft-dev"
DST="$HOME/.copilot/installed-plugins/local/moma-soft-dev"
mkdir -p "$(dirname "$DST")"
rm -rf "$DST"
cp -R "$SRC" "$DST"
```

完成后在 Copilot CLI 中执行 `/reload-plugins`（或重启 CLI）即可生效。

### 方式三：直接安装为用户级 skills（最简单，但失去插件命名空间）

如果只想快速试用，把每个子 skill 文件夹直接拷贝到 `~/.copilot/skills/` 即可：

#### Windows (PowerShell)

```powershell
$src = "E:\Workspace\momasoft\doc-template\plugins\moma-soft-dev\skills"
$dst = "$env:USERPROFILE\.copilot\skills"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item -Recurse -Force "$src\*" $dst
```

#### macOS / Linux (bash)

```bash
SRC="/path/to/doc-template/plugins/moma-soft-dev/skills"
DST="$HOME/.copilot/skills"
mkdir -p "$DST"
cp -R "$SRC"/. "$DST/"
```

## 验证安装

在 Copilot CLI 中：

1. 执行 `/env`，查看 "Skills" 部分应能列出 `moma-init`、`moma-sync`、`moma-coding`、`moma-modify`、`moma-optimize`、`moma-new`、`moma-fix`、`moma-session-complete`、`moma-soft-dev` 共 9 个。
2. 在输入栏键入 `/m`，应能看到上述所有 `/moma-*` 指令出现在自动补全列表中。

## 升级 / 卸载

- **升级：** 重新执行对应安装方式的拷贝命令；marketplace 安装方式可在 CLI 中执行 `/plugin update moma-soft-dev`。
- **卸载：**
  - 方式一（marketplace）：`/plugin uninstall moma-soft-dev`
  - 方式二/三（手动复制）：直接删除对应目标目录即可。

## 目录结构

```
plugins/moma-soft-dev/
├── .github/plugin/plugin.json        # 插件清单（Copilot CLI / Claude Code 兼容）
├── README.md                         # 本文件
└── skills/
    ├── moma-soft-dev/                # 总览父 skill（共享约定与文档体系说明）
    │   ├── SKILL.md
    │   ├── evals/evals.json
    │   └── references/
    │       ├── common-conventions.md # 所有子 skill 共享的约定
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
