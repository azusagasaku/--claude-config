#!/usr/bin/env bash
# ============================================================
# Memory → Obsidian 同步脚本
# 将 Claude Code 自动记忆同步到 Obsidian Vault 对应笔记
# ============================================================
set -euo pipefail

MEMORY_DIR="$HOME/.claude/projects/C--Users----/memory"
VAULT_DIR="D:/WIKI/WIKI"

# 仅在记忆目录存在时执行
[ -d "$MEMORY_DIR" ] || exit 0
[ -d "$VAULT_DIR" ] || exit 0

SYNC_COUNT=0

# ── 记忆 → Obsidian 映射表 ──────────────────────────────────
declare -A MAP=(
  ["user_roommate.md"]="$VAULT_DIR/10-记忆/室友-方楷.md"
  ["feedback_parallel_agents.md"]="$VAULT_DIR/10-记忆/偏好-并行调度.md"
  ["feedback_chinese_all.md"]="$VAULT_DIR/10-记忆/偏好-全中文.md"
  ["feedback_claude_status_meaning.md"]="$VAULT_DIR/10-记忆/约定-Claude状态.md"
  ["reference_claude_backup_restore.md"]="$VAULT_DIR/10-记忆/备份恢复.md"
  ["formal-chinese-style.md"]="$VAULT_DIR/10-记忆/偏好-正式中文.md"
  ["self-managed-wiki.md"]="$VAULT_DIR/10-记忆/自行管理知识库.md"
)

# ── 同步逻辑 ────────────────────────────────────────────────
for memory_file in "${!MAP[@]}"; do
  obsidian_file="${MAP[$memory_file]}"
  src="$MEMORY_DIR/$memory_file"

  if [ ! -f "$src" ]; then
    continue
  fi

  # 目标不存在、--force、或源文件更新 → 同步
  if [ ! -f "$obsidian_file" ] || [ "${1:-}" = "--force" ] || [ "$src" -nt "$obsidian_file" ]; then
    # 提取正文（跳过 frontmatter）
    body=$(awk '
      BEGIN { in_body=0 }
      /^---$/ { in_body++; next }
      in_body >= 2 { print }
    ' "$src")

    # 如果正文为空则跳过
    [ -z "$body" ] && continue

    # 生成 Obsidian 格式笔记
    {
      echo "---"
      echo "synced: $(date +%Y-%m-%dT%H:%M:%S)"
      echo "source: $(basename "$memory_file")"
      echo "---"
      echo ""
      echo "$body"
    } > "$obsidian_file"

    SYNC_COUNT=$((SYNC_COUNT + 1))
  fi
done

echo "[memory-sync] 同步完成: $SYNC_COUNT 篇"
