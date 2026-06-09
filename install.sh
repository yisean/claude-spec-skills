#!/usr/bin/env bash
# 安装 spec-* skill 到用户级 Claude Code 目录（~/.claude/skills/）
# 用法：在本仓库根目录运行  ./install.sh
set -euo pipefail

dest="$HOME/.claude/skills"
mkdir -p "$dest"

src="$(cd "$(dirname "$0")" && pwd)"
skills="spec-prd spec-prototype spec-design spec-plan spec-change spec-check spec-init"

for name in $skills; do
  if [ ! -d "$src/$name" ]; then
    echo "找不到 $src/$name，请在本仓库根目录运行此脚本" >&2
    exit 1
  fi
  rm -rf "${dest:?}/$name"   # 清掉旧版，避免重构后残留陈旧文件
  cp -R "$src/$name" "$dest/"
  echo "  installed  $name"
done

echo ""
echo "完成。已安装到 $dest"
echo "请重启 Claude Code，然后输入 /spec- 验证六个命令是否出现。"
