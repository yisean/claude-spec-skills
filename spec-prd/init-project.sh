#!/usr/bin/env bash
# 把 spec-* 的工程骨架文件初始化到当前项目（constitution.md + workflow.md）
# 用法（在目标项目根目录运行）：
#   "$HOME/.claude/skills/spec-prd/init-project.sh"            # 缺失才建，不覆盖
#   "$HOME/.claude/skills/spec-prd/init-project.sh" --force    # 覆盖已存在的
#   "$HOME/.claude/skills/spec-prd/init-project.sh" --project /path/to/proj
set -euo pipefail

project_root="$(pwd)"
force=""
while [ $# -gt 0 ]; do
  case "$1" in
    --force) force="1"; shift ;;
    --project) project_root="$2"; shift 2 ;;
    *) echo "未知参数：$1" >&2; exit 1 ;;
  esac
done

src="$(cd "$(dirname "$0")" && pwd)/templates"
dest="$project_root/docs/engineering"
mkdir -p "$dest"

for name in constitution.md workflow.md; do
  from="$src/$name"
  to="$dest/$name"
  if [ ! -f "$from" ]; then echo "模板缺失：$from" >&2; continue; fi
  if [ -f "$to" ] && [ -z "$force" ]; then
    echo "  skip    docs/engineering/$name（已存在，加 --force 覆盖）"
    continue
  fi
  cp -f "$from" "$to"
  echo "  created docs/engineering/$name"
done

echo ""
echo "完成。已初始化到 $dest"
echo "下一步：编辑 constitution.md 的 version/date，按项目技术栈补全 workflow.md 的占位符（<后端栈>/<前端栈>），再开始跑 /spec-prd。"
