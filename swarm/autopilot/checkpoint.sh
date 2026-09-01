#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
TASK_ID="${AUTONOMY_TASK_ID:-no-task}"

mkdir -p ops
test ! -f swarm/autopilot/last-agent-output.json || cp swarm/autopilot/last-agent-output.json ops/autopilot-last-result.json
test ! -f swarm/autopilot/next-best-action.json || cp swarm/autopilot/next-best-action.json ops/next-best-action.json
test ! -f swarm/autopilot/leadership-decision.json || cp swarm/autopilot/leadership-decision.json ops/leadership-decision.json
test ! -f swarm/autopilot/continuation.json || cp swarm/autopilot/continuation.json ops/continuation-state.json

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'

# Optimistic concurrency: never push a decision computed from a stale snapshot.
git fetch origin main
LOCAL_BASE="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse origin/main)"
if [ "$LOCAL_BASE" != "$REMOTE_HEAD" ]; then
  echo "STALE_SNAPSHOT: local=$LOCAL_BASE remote=$REMOTE_HEAD; discarding local snapshot and requesting re-evaluation"
  git reset --hard origin/main
  git clean -fd
  [ -n "${GITHUB_OUTPUT:-}" ] && echo 'stale=true' >> "$GITHUB_OUTPUT"
  exit 0
fi

[ -n "${GITHUB_OUTPUT:-}" ] && echo 'stale=false' >> "$GITHUB_OUTPUT"
git add -A
STAGED="$(git diff --cached --name-only)"
if printf '%s\n' "$STAGED" | grep -E '^\.github/|^\.git/' >/dev/null; then
  echo 'FORBIDDEN_AUTONOMOUS_CHANGE_IN_GOVERNANCE_AREA'
  exit 1
fi
if printf '%s\n' "$STAGED" | grep -E '^swarm/autopilot/runtime/|\.gguf$' >/dev/null; then
  echo 'FORBIDDEN_AUTONOMOUS_RUNTIME_ARTIFACT'
  exit 1
fi
if git diff --cached --quiet; then
  echo 'CHECKPOINT_NO_CHANGES'
  exit 0
fi

git commit -m "chore: autonomous leadership checkpoint ($TASK_ID)"
if ! git push; then
  # A race may occur after fetch. Do not force-push or merge a stale decision.
  git fetch origin main
  echo 'CHECKPOINT_PUSH_RACE: remote advanced; abandoning local checkpoint and requesting fresh cycle'
  git reset --hard origin/main
  git clean -fd
  [ -n "${GITHUB_OUTPUT:-}" ] && echo 'stale=true' >> "$GITHUB_OUTPUT"
fi
