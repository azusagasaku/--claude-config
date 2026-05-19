#!/usr/bin/env bash
# 自动提交 Claude Code 配置变更到 Git
set -euo pipefail

CONFIG_DIR="$HOME/.claude"
cd "$CONFIG_DIR"

# 无变更则跳过
if git diff --quiet && git diff --cached --quiet && git diff --quiet --untracked-files=no; then
    exit 0
fi

# 暂存所有变更（.gitignore 已确保不会误提交密钥）
git add -A

# 生成提交信息：列出变更文件摘要
CHANGED=$(git diff --cached --name-only | head -10 | sed 's/^/  /')
if [ $(git diff --cached --name-only | wc -l) -gt 10 ]; then
    CHANGED="$CHANGED
  ... 还有更多文件"
fi

git commit -m "$(cat <<EOF
chore: 自动同步配置变更

$CHANGED
EOF
)"

# 推送
git push origin master 2>/dev/null || echo "[auto-commit] 推送失败，将在下次重试" >&2
