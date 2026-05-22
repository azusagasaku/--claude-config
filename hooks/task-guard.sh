#!/usr/bin/env bash
# ============================================================
# 任务守卫 — 未完成任务时阻止 Claude Code 结束
# ============================================================
set -euo pipefail

TASK_FILE="$HOME/.claude/task-monitor.json"

# 任务文件不存在 → 放行（首次运行或未启用监控）
if [ ! -f "$TASK_FILE" ]; then
  exit 0
fi

# 用 node 解析 JSON（Windows bash 环境无 jq）
RESULT=$(node -e "
const fs = require('fs');
try {
  const data = JSON.parse(fs.readFileSync('$TASK_FILE', 'utf8'));
  const pending = data.tasks ? data.tasks.filter(t => t.status === 'pending' || t.status === 'in_progress') : [];
  if (!data.active) {
    console.log('ALLOW:inactive');
  } else if (pending.length === 0) {
    console.log('ALLOW:complete');
  } else {
    console.log('BLOCK:' + pending.length);
    pending.forEach(t => console.log('  - ' + t.description));
  }
} catch(e) {
  console.log('ALLOW:parse_error');
}
" 2>/dev/null)

case "$RESULT" in
  ALLOW:*)
    exit 0
    ;;
  BLOCK:*)
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║  [拒绝] 任务未完成 — 禁止结束会话                       ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  以下任务尚未完成：                                      ║"
    echo "$RESULT" | tail -n +2 | while IFS= read -r line; do
      printf "║  %-52s ║\n" "$line"
    done
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║  请继续工作完成上述任务后再结束。                        ║"
    echo "║  紧急放行: 将 task-monitor.json 中 active 设为 false     ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    exit 2
    ;;
  *)
    # 解析异常，放行但警告
    echo "[task-guard] 无法解析任务文件，跳过检查"
    exit 0
    ;;
esac
