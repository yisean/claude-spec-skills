# 把本机 ~/.claude/skills/spec-* 的最新内容同步回本分发仓库（维护者用）
# 用法：
#   .\sync-from-local.ps1                      只同步+暂存，显示改动
#   .\sync-from-local.ps1 -Message "feat: ..."  同步并提交
#   .\sync-from-local.ps1 -Message "feat: ..." -Push  同步、提交并推送
param(
    [string]$Message,
    [switch]$Push
)
$ErrorActionPreference = 'Stop'

$repo   = $PSScriptRoot
$srcDir = Join-Path $HOME '.claude\skills'
$skills = 'spec-prd', 'spec-prototype', 'spec-design', 'spec-plan', 'spec-change', 'spec-check', 'spec-init'

foreach ($name in $skills) {
    $from = Join-Path $srcDir $name
    if (-not (Test-Path $from)) {
        Write-Warning "跳过 $name：本机不存在 $from"
        continue
    }
    Copy-Item -Recurse -Force $from $repo
    Write-Host "  synced  $name"
}

git -C $repo add -A

# 没有改动就退出
$changed = git -C $repo status --porcelain
if (-not $changed) {
    Write-Host "`n无改动，分发仓库已是最新。" -ForegroundColor Green
    return
}

Write-Host "`n待提交改动：" -ForegroundColor Yellow
git -C $repo status --short

if (-not $Message) {
    Write-Host "`n已暂存但未提交。加 -Message ""...""（可选 -Push）即可提交。"
    return
}

git -C $repo commit -m $Message
Write-Host "已提交：$Message" -ForegroundColor Green

if ($Push) {
    git -C $repo push
    Write-Host "已推送到远端。" -ForegroundColor Green
} else {
    Write-Host "未推送。加 -Push 可直接推送，或手动 git push。"
}
