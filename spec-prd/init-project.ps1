# 把 spec-* 的工程骨架文件初始化到当前项目（constitution.md + workflow.md）
# 用法（在目标项目根目录运行）：
# 注：-ExecutionPolicy Bypass 为临时授权，仅对本次调用生效、不改系统设置（规避 Restricted 策略禁止跑脚本）。
#   powershell -ExecutionPolicy Bypass -File "$HOME\.claude\skills\spec-prd\init-project.ps1"            # 缺失才建，不覆盖
#   powershell -ExecutionPolicy Bypass -File "$HOME\.claude\skills\spec-prd\init-project.ps1" -Force     # 覆盖已存在的
#   powershell -ExecutionPolicy Bypass -File "$HOME\.claude\skills\spec-prd\init-project.ps1" -ProjectRoot D:\path\to\proj
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [switch]$Force
)
$ErrorActionPreference = 'Stop'

$src  = Join-Path $PSScriptRoot 'templates'
$dest = Join-Path $ProjectRoot 'docs\engineering'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$files = 'constitution.md', 'workflow.md'
foreach ($name in $files) {
    $from = Join-Path $src $name
    $to   = Join-Path $dest $name
    if (-not (Test-Path $from)) { Write-Warning "模板缺失：$from"; continue }
    if ((Test-Path $to) -and -not $Force) {
        Write-Host "  skip    docs/engineering/$name（已存在，加 -Force 覆盖）"
        continue
    }
    Copy-Item -Force $from $to
    Write-Host "  created docs/engineering/$name"
}

Write-Host ""
Write-Host "完成。已初始化到 $dest" -ForegroundColor Green
Write-Host "下一步：编辑 constitution.md 的 version/date，按项目技术栈补全 workflow.md 的占位符（<后端栈>/<前端栈>），再开始跑 /spec-prd。"
