#!/usr/bin/env bash
# ============================================================
# SessionStart Hook — 综合会话初始化
# 四项功能：Wiki 检查 · Obsidian Vault · 环境变量 · Git 状态
# ============================================================

set -euo pipefail

PROJECT_ROOT="$(pwd)"
BORDER="----------------------------------------"

echo ""
echo "SessionStart | $(date '+%Y-%m-%d %H:%M:%S')"

# ── 1. Wiki 结构检查 ────────────────────────────────────────
echo "--- Wiki ---"

if [ -d "$PROJECT_ROOT/raw" ]; then
  RAW_COUNT=$(find "$PROJECT_ROOT/raw" -name "*.md" 2>/dev/null | wc -l)
  echo "  raw/ : $RAW_COUNT 篇素材"
else
  echo "  raw/ : 未初始化"
fi

if [ -d "$PROJECT_ROOT/wiki" ]; then
  WIKI_COUNT=$(find "$PROJECT_ROOT/wiki" -name "*.md" ! -name "index.md" ! -name "log.md" 2>/dev/null | wc -l)
  echo "  wiki/ : $WIKI_COUNT 篇文章"
  if [ -f "$PROJECT_ROOT/wiki/index.md" ]; then
    echo "  index.md : ok"
  fi
else
  echo "  wiki/ : 未初始化"
fi

# ── 2. Obsidian Vault ───────────────────────────────────────
echo "--- Obsidian ---"
VAULT_PATHS=(
  "$HOME/Documents/Obsidian"
  "$HOME/Obsidian"
  "$HOME/.obsidian"
  "$HOME/Documents/Notes"
  "D:/WIKI/WIKI"
)
VAULT_FOUND=""

# 先尝试从 Obsidian 配置中读取 Vault 路径
OBSIDIAN_JSON="$APPDATA/obsidian/obsidian.json"
OBSIDIAN_JSON_UNIX="$(cygpath -u "$OBSIDIAN_JSON" 2>/dev/null || echo "$OBSIDIAN_JSON")"
if [ -f "$OBSIDIAN_JSON_UNIX" ]; then
  while IFS= read -r vault_path; do
    if [ -d "$vault_path" ]; then
      VAULT_FOUND="$vault_path"
      break
    fi
  done < <(grep -oP '"path":"\K[^"]+' "$OBSIDIAN_JSON_UNIX" 2>/dev/null)
fi

# 配置中未找到则回退到预设路径
if [ -z "$VAULT_FOUND" ]; then
  for vp in "${VAULT_PATHS[@]}"; do
    if [ -d "$vp" ]; then
      VAULT_FOUND="$vp"
      break
    fi
  done
fi
if [ -n "$VAULT_FOUND" ]; then
  VAULT_SIZE=$(find "$VAULT_FOUND" -name "*.md" ! -path "*/.obsidian/*" 2>/dev/null | wc -l)
  echo "  Vault : $VAULT_FOUND ($VAULT_SIZE 篇)"
  # 按目录显示分布
  for category in "00-系统" "10-记忆" "20-项目" "90-日志"; do
    if [ -d "$VAULT_FOUND/$category" ]; then
      COUNT=$(find "$VAULT_FOUND/$category" -name "*.md" 2>/dev/null | wc -l)
      echo "    $category/ : $COUNT 篇"
    fi
  done
else
  echo "  Vault : 未检测到"
fi

# ── 3. 环境变量注入 ─────────────────────────────────────────
export SESSION_STARTED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
export SESSION_DATE="$(date +%Y-%m-%d)"
if git rev-parse --git-dir >/dev/null 2>&1; then
  export PROJECT_NAME="$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")"
else
  export PROJECT_NAME="$(basename "$PROJECT_ROOT")"
fi
echo "--- ENV ---"
echo "  SESSION_STARTED=$SESSION_STARTED"
echo "  PROJECT_NAME=$PROJECT_NAME"

# ── 4. Git 状态报告 ─────────────────────────────────────────
echo "--- Git ---"
if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  LAST_COMMIT=$(git log -1 --format="%h %s (%ar)" 2>/dev/null || echo "无")
  echo "  分支 : $BRANCH"
  echo "  最新 : $LAST_COMMIT"

  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)
  CHANGES=$(git diff --stat 2>/dev/null | tail -1)
  if [ -n "$CHANGES" ]; then echo "  变更 : $CHANGES"; fi
  if [ "$UNTRACKED" -gt 0 ]; then echo "  未跟踪 : $UNTRACKED 文件"; fi
else
  echo "  非 Git 仓库"
fi

echo "$BORDER"
echo ""
