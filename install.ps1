# 安装 spec-* skill 到用户级 Claude Code 目录（~/.claude/skills/）
# 用法：在本仓库根目录运行  .\install.ps1
$ErrorActionPreference = 'Stop'

$dest = Join-Path $HOME '.claude\skills'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$src = $PSScriptRoot
$skills = 'spec-prd', 'spec-prototype', 'spec-design', 'spec-plan', 'spec-change', 'spec-check', 'spec-init'

foreach ($name in $skills) {
    $from = Join-Path $src $name
    if (-not (Test-Path $from)) { throw "找不到 $from，请在本仓库根目录运行此脚本" }
    $to = Join-Path $dest $name
    if (Test-Path $to) { Remove-Item -Recurse -Force $to }   # 清掉旧版，避免重构后残留陈旧文件
    Copy-Item -Recurse -Force $from $dest
    Write-Host "  installed  $name"
}

Write-Host ""
Write-Host "完成。已安装到 $dest" -ForegroundColor Green
Write-Host "请重启 Claude Code，然后输入 /spec- 验证六个命令是否出现。"
