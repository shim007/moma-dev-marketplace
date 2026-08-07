# CLAUDE.md

> **开始任何工作前，请先完整阅读 [AGENTS.md](./AGENTS.md) 并严格遵守其中的全部规范。**
> `AGENTS.md` 是本仓库的跨 AI 工具通用开发约定（单一事实来源）；本文件仅补充 Claude Code 专属事项，不得与 AGENTS.md 冲突。

## Claude Code 专属补充

1. **marketplace 清单**：Claude Code 读取 `.claude-plugin/marketplace.json`（主清单）；`.github/plugin/marketplace.json` 是 GitHub Copilot CLI 兼容副本，修改任一处插件条目时两处必须同步。
2. **技能命名空间**：插件技能以 `moma-soft-dev:<技能名>` 形式注册；用户在输入栏键入 `/moma-` 触发自动补全。
3. **`${CLAUDE_PLUGIN_ROOT}`**：在 Claude Code 中自动展开为插件安装根目录（通常为 `~/.claude/plugins/` 下对应插件目录）；编写技能时直接使用该变量引用插件内置资源，无需硬编码路径。
4. **本地验证**：
   - `/plugin marketplace add <本仓库根目录绝对路径>`（已添加则 `/plugin marketplace update moma-dev-marketplace`）
   - `/plugin install moma-soft-dev@moma-dev-marketplace`（或 `/plugin update moma-soft-dev`）
   - 重启会话，确认输入 `/moma-` 时 17 个工作指令全部出现
   - 用 `plugins/moma-soft-dev/skills/moma-soft-dev/evals/evals.json` 中的 prompt 至少抽查 1 个场景
5. **本地同步脚本**：当前 Claude Code 对 directory 源 marketplace 的插件执行 install/update 时会报 *"source type ... does not support"*。修改插件后改为运行同步脚本一键同步到本地安装（复制文件到缓存目录、更新注册记录、清理旧版本缓存），然后重启会话即可生效：
   - Linux/macOS/Git Bash：`bash scripts/sync-local-plugin.sh`
   - Windows PowerShell：`pwsh scripts/sync-local-plugin.ps1`（兼容 PowerShell 5.1：`powershell -ExecutionPolicy Bypass -File scripts\sync-local-plugin.ps1`）
