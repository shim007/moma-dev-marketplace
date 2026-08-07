<#
.SYNOPSIS
    将本仓库中的 moma-soft-dev 插件同步到本地 Claude Code 安装（开发用）。

.DESCRIPTION
    背景：当前 Claude Code 对 directory 源 marketplace（本地目录方式添加的
    marketplace）中的插件执行 /plugin install 或 /plugin update 时会报
    "This plugin uses a source type your Claude Code version does not support"。
    因此本地开发时，修改插件后运行本脚本一键同步到本地安装：

      1. 复制 plugins/moma-soft-dev/ 最新内容到插件缓存目录
      2. 更新 installed_plugins.json 注册记录（版本号、commit SHA、时间）
      3. 清理旧版本的缓存目录

    同步完成后需重启 Claude Code 会话才能生效。
    说明：缓存目录固定使用 ~/.claude/plugins/cache/（与本环境的实际安装位置一致）；
    注册记录会同时更新 CLAUDE_CONFIG_DIR 与 ~/.claude 下的 installed_plugins.json（存在才改）。

.EXAMPLE
    pwsh scripts/sync-local-plugin.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\sync-local-plugin.ps1

.NOTES
    sync-local-plugin.sh 的 Windows PowerShell 版本（行为一致），
    兼容 Windows PowerShell 5.1 与 PowerShell 7+，除 git 外无外部依赖
    （git 缺失时仅跳过 commit SHA 记录）。
    注册记录更新在 PowerShell 7 下使用 System.Text.Json（逐字节保留未改动字段，
    避免 ConvertFrom-Json 的日期自动转换破坏原有时间戳格式）；
    在 5.1 下使用 ConvertFrom-Json/ConvertTo-Json 并规范化为 2 空格缩进。
#>
#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

# 规范化 JSON 输出：2 空格缩进、"key": value 单空格，与 Claude Code 自身写入的风格一致；
# 同时修正 PS 5.1 ConvertTo-Json 的对齐式缩进（按最长键对齐、产生超长行）。
function Format-JsonText([string]$Json) {
    $depth = 0
    $sb = New-Object System.Text.StringBuilder
    foreach ($raw in ($Json -split "`r?`n")) {
        $line = $raw.Trim()
        if (-not $line) { continue }
        if ($line -match '^[\}\]]') { $depth = [Math]::Max(0, $depth - 1) }
        [void]$sb.Append(('  ' * $depth))
        [void]$sb.Append(($line -replace '":\s{2,}', '": '))
        [void]$sb.Append("`n")
        if ($line -match '[\{\[]$') { $depth++ }
    }
    return $sb.ToString().TrimEnd("`n")
}

$RepoRoot        = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$PluginDir       = Join-Path $RepoRoot 'plugins\moma-soft-dev'
$MarketplaceJson = Join-Path $RepoRoot '.claude-plugin\marketplace.json'

if (-not (Test-Path $PluginDir -PathType Container)) {
    Write-Host "错误：找不到插件目录 $PluginDir" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $MarketplaceJson -PathType Leaf)) {
    Write-Host "错误：找不到 marketplace 清单 $MarketplaceJson" -ForegroundColor Red
    exit 1
}

# 读取插件名、版本、marketplace 名与当前 commit（这三个文件无日期字段，直接解析即可）
$PluginMeta = Get-Content -Raw -Encoding UTF8 (Join-Path $PluginDir '.claude-plugin\plugin.json') | ConvertFrom-Json
$MarketMeta = Get-Content -Raw -Encoding UTF8 $MarketplaceJson | ConvertFrom-Json
$Name    = $PluginMeta.name
$Version = $PluginMeta.version
$Market  = $MarketMeta.name

$Sha = ''
try {
    $GitOut = & git -C $RepoRoot rev-parse HEAD 2>$null
    if ($LASTEXITCODE -eq 0) { $Sha = ($GitOut | Out-String).Trim() }
} catch { }

$CacheRoot = Join-Path $HOME '.claude\plugins\cache'
$Dest      = Join-Path $CacheRoot (Join-Path $Market (Join-Path $Name $Version))

Write-Host "==> 同步 $Name v$Version -> $Dest"
if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
New-Item -ItemType Directory -Path $Dest -Force | Out-Null
Copy-Item -Path (Join-Path $PluginDir '*') -Destination $Dest -Recurse -Force

# 清理其他版本的缓存目录
$VersionRoot = Join-Path $CacheRoot (Join-Path $Market $Name)
Get-ChildItem -Path $VersionRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -ne $Version } |
    ForEach-Object {
        Write-Host "==> 清理旧版本缓存: $($_.FullName)"
        Remove-Item $_.FullName -Recurse -Force
    }

# 更新注册记录（installPath 使用平台原生路径格式）
$Regs = @()
if ($env:CLAUDE_CONFIG_DIR) { $Regs += Join-Path $env:CLAUDE_CONFIG_DIR 'plugins\installed_plugins.json' }
$Regs += Join-Path $HOME '.claude\plugins\installed_plugins.json'
$Regs = @($Regs | ForEach-Object { [System.IO.Path]::GetFullPath($_) } | Select-Object -Unique)

$InstallPath = Join-Path $HOME (Join-Path '.claude\plugins\cache' (Join-Path $Market (Join-Path $Name $Version)))
$Now         = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$Key         = "$Name@$Market"
$Utf8NoBom   = New-Object System.Text.UTF8Encoding($false)

# PowerShell 7：优先用 System.Text.Json 做注册记录的回读改写——
# PS7 的 ConvertFrom-Json 会把日期样式字符串转成 DateTime，写回时改变原有格式；
# JsonNode 则逐字节保留未改动的字段。5.1 无此问题（无日期自动转换），走 cmdlet 路径。
$UseStj = $false
if ($PSVersionTable.PSVersion.Major -ge 6) {
    try {
        [void][System.Reflection.Assembly]::Load('System.Text.Json')
        $UseStj = $null -ne ('System.Text.Json.Nodes.JsonNode' -as [type])
    } catch { }
}
if ($UseStj) {
    $StjOpts = [System.Text.Json.JsonSerializerOptions]::new()
    $StjOpts.WriteIndented = $true
    $StjOpts.Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping
}

$Updated = $false
foreach ($Reg in $Regs) {
    if (-not (Test-Path $Reg -PathType Leaf)) { continue }
    $Raw = Get-Content -Raw -Encoding UTF8 $Reg

    if ($UseStj) {
        # --- PowerShell 7：System.Text.Json 路径 ---
        $Node = [System.Text.Json.Nodes.JsonNode]::Parse($Raw)
        $PluginsNode = $Node['plugins']
        if ($null -eq $PluginsNode) {
            $PluginsNode = [System.Text.Json.Nodes.JsonObject]::new()
            $Node['plugins'] = $PluginsNode
        }

        $InstalledAt = $Now
        $PrevArr = $PluginsNode[$Key]
        if ($null -ne $PrevArr) {
            try {
                if ($PrevArr.Count -gt 0 -and $null -ne $PrevArr[0]['installedAt']) {
                    # JsonValue<string>.ToString() 返回原始字符串（不带引号）
                    $InstalledAt = $PrevArr[0]['installedAt'].ToString()
                }
            } catch { }
        }

        $EntryFields = [ordered]@{
            scope       = 'user'
            installPath = $InstallPath
            version     = $Version
            installedAt = $InstalledAt
            lastUpdated = $Now
        }
        if ($Sha) { $EntryFields['gitCommitSha'] = $Sha }

        $EntryNode = [System.Text.Json.Nodes.JsonObject]::new()
        foreach ($kv in $EntryFields.GetEnumerator()) {
            $EntryNode.Add($kv.Key, [System.Text.Json.Nodes.JsonValue]::Create([string]$kv.Value))
        }

        $NewArr = [System.Text.Json.Nodes.JsonArray]::new()
        $NewArr.Add($EntryNode)
        $PluginsNode[$Key] = $NewArr

        # ToJsonString 在 Windows 上用 CRLF 缩进，统一为 LF（与 Claude Code/Node 写入一致）
        $Text = ($Node.ToJsonString($StjOpts) -replace "`r`n", "`n") + "`n"
    } else {
        # --- Windows PowerShell 5.1：cmdlet 路径 ---
        $Json = $Raw | ConvertFrom-Json
        if (-not $Json.PSObject.Properties['plugins']) {
            $Json | Add-Member -NotePropertyName 'plugins' -NotePropertyValue ([PSCustomObject]@{})
        }
        $Plugins = $Json.plugins

        $Prop = $Plugins.PSObject.Properties[$Key]
        $Prev = $null
        if ($Prop) {
            $Arr = @($Prop.Value)
            if ($Arr.Count -gt 0) { $Prev = $Arr[0] }
        }

        $InstalledAt = $Now
        if ($Prev -and $Prev.PSObject.Properties['installedAt']) { $InstalledAt = $Prev.installedAt }

        $Entry = [ordered]@{
            scope       = 'user'
            installPath = $InstallPath
            version     = $Version
            installedAt = $InstalledAt
            lastUpdated = $Now
        }
        if ($Sha) { $Entry['gitCommitSha'] = $Sha }

        if ($Prop) {
            $Prop.Value = @([PSCustomObject]$Entry)
        } else {
            $Plugins | Add-Member -NotePropertyName $Key -NotePropertyValue @([PSCustomObject]$Entry)
        }

        $Text = (Format-JsonText ($Json | ConvertTo-Json -Depth 20)) + "`n"
    }

    # 以 UTF-8（无 BOM）写回，避免 JSON 解析器因 BOM 报错
    [System.IO.File]::WriteAllText($Reg, $Text, $Utf8NoBom)
    Write-Host "==> 注册记录已更新: $Reg"
    $Updated = $true
}

if (-not $Updated) {
    Write-Host "警告：未找到任何 installed_plugins.json，跳过注册（仅复制了文件）" -ForegroundColor Yellow
}

Write-Host ''
Write-Host "完成。请重启 Claude Code 会话以加载 $Name v$Version。"
