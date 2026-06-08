#!/usr/bin/env bash
# 把本机 ~/.claude/skills/spec-* 的最新内容同步回本分发仓库（维护者用）
# 用法：
#   ./sync-from-local.sh                       只同步+暂存，显示改动
#   ./sync-from-local.sh "feat: ..."           同步并提交
#   ./sync-from-local.sh "feat: ..." --push     同步、提交并推送
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
src="$HOME/.claude/skills"
skills="spec-prd spec-prototype spec-design spec-plan spec-change spec-check"

message="${1:-}"
push=""
[ "${2:-}" = "--push" ] && push="1"

for name in $skills; do
  if [ ! -d "$src/$name" ]; then
    echo "跳过 $name：本机不存在 $src/$name" >&2
    continue
  fi
  cp -R "$src/$name" "$repo/"
  echo "  synced  $name"
done

git -C "$repo" add -A

if [ -z "$(git -C "$repo" status --porcelain)" ]; then
  echo ""
  echo "无改动，分发仓库已是最新。"
  exit 0
fi

echo ""
echo "待提交改动："
git -C "$repo" status --short

if [ -z "$message" ]; then
  echo ""
  echo "已暂存但未提交。传提交信息（可选 --push）即可提交。"
  exit 0
fi

git -C "$repo" commit -m "$message"
echo "已提交：$message"

if [ -n "$push" ]; then
  git -C "$repo" push
  echo "已推送到远端。"
else
  echo "未推送。加 --push 可直接推送，或手动 git push。"
fi
