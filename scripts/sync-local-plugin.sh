#!/usr/bin/env bash
# 将本仓库中的 moma-soft-dev 插件同步到本地 Claude Code 安装（开发用）。
#
# 背景：当前 Claude Code 对 directory 源 marketplace（本地目录方式添加的
# marketplace）中的插件执行 /plugin install 或 /plugin update 时会报
# "This plugin uses a source type your Claude Code version does not support"。
# 因此本地开发时，修改插件后运行本脚本一键同步到本地安装：
#
#   1. 复制 plugins/moma-soft-dev/ 最新内容到插件缓存目录
#   2. 更新 installed_plugins.json 注册记录（版本号、commit SHA、时间）
#   3. 清理旧版本的缓存目录
#
# 用法（在仓库任意位置）：
#   bash scripts/sync-local-plugin.sh
#
# 同步完成后需重启 Claude Code 会话才能生效。
# 说明：缓存目录固定使用 ~/.claude/plugins/cache/（与本环境的实际安装位置一致）；
# 注册记录会同时更新 CLAUDE_CONFIG_DIR 与 ~/.claude 下的 installed_plugins.json（存在才改）。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/plugins/moma-soft-dev"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"

[ -d "$PLUGIN_DIR" ] || { echo "错误：找不到插件目录 $PLUGIN_DIR" >&2; exit 1; }
[ -f "$MARKETPLACE_JSON" ] || { echo "错误：找不到 marketplace 清单 $MARKETPLACE_JSON" >&2; exit 1; }

# 读取插件名、版本、marketplace 名与当前 commit
NAME=$(node -p "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')).name" "$PLUGIN_DIR/.claude-plugin/plugin.json")
VERSION=$(node -p "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')).version" "$PLUGIN_DIR/.claude-plugin/plugin.json")
MARKET=$(node -p "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8')).name" "$MARKETPLACE_JSON")
SHA=$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo "")

CACHE_ROOT="$HOME/.claude/plugins/cache"
DEST="$CACHE_ROOT/$MARKET/$NAME/$VERSION"

echo "==> 同步 $NAME v$VERSION -> $DEST"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$PLUGIN_DIR/." "$DEST/"

# 清理其他版本的缓存目录
for d in "$CACHE_ROOT/$MARKET/$NAME"/*/; do
  [ -d "$d" ] || continue
  if [ "$(basename "$d")" != "$VERSION" ]; then
    echo "==> 清理旧版本缓存: $d"
    rm -rf "$d"
  fi
done

# 更新注册记录（installPath 由 node 用平台原生格式构造）
REGS=()
[ -n "${CLAUDE_CONFIG_DIR:-}" ] && REGS+=("$CLAUDE_CONFIG_DIR/plugins/installed_plugins.json")
REGS+=("$HOME/.claude/plugins/installed_plugins.json")

UPDATED=0
for REG in "${REGS[@]}"; do
  [ -f "$REG" ] || continue
  KEY="$NAME@$MARKET" NAME_ARG="$NAME" MARKET_ARG="$MARKET" node -e '
    const fs = require("fs");
    const os = require("os");
    const path = require("path");
    const [reg, version, sha] = process.argv.slice(1);
    const key = process.env.KEY;
    const installPath = path.join(os.homedir(), ".claude", "plugins", "cache",
      process.env.MARKET_ARG, process.env.NAME_ARG, version);
    const j = JSON.parse(fs.readFileSync(reg, "utf8"));
    const prev = (j.plugins[key] && j.plugins[key][0]) || null;
    const now = new Date().toISOString();
    const entry = {
      scope: "user",
      installPath,
      version,
      installedAt: prev ? prev.installedAt : now,
      lastUpdated: now,
    };
    if (sha) entry.gitCommitSha = sha;
    j.plugins[key] = [entry];
    fs.writeFileSync(reg, JSON.stringify(j, null, 2) + "\n");
    console.log("==> 注册记录已更新:", reg);
  ' "$REG" "$VERSION" "$SHA"
  UPDATED=1
done

[ "$UPDATED" = "1" ] || echo "警告：未找到任何 installed_plugins.json，跳过注册（仅复制了文件）"

echo ""
echo "完成。请重启 Claude Code 会话以加载 $NAME v$VERSION。"
