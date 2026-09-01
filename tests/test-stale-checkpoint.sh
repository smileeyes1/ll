#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir "$TMP/source"
cd "$TMP/source"
git init -b main >/dev/null
git config user.name test
git config user.email test@example.invalid
mkdir -p swarm/autopilot
echo base > README.md
git add . && git commit -m base >/dev/null
git init --bare "$TMP/remote.git" >/dev/null
git remote add origin "$TMP/remote.git"
git push -u origin main >/dev/null
git --git-dir="$TMP/remote.git" symbolic-ref HEAD refs/heads/main

git clone "$TMP/remote.git" "$TMP/agent" >/dev/null
git clone "$TMP/remote.git" "$TMP/other" >/dev/null
mkdir -p "$TMP/agent/swarm/autopilot"
cp "$ROOT/swarm/autopilot/checkpoint.sh" "$TMP/agent/swarm/autopilot/checkpoint.sh"
chmod +x "$TMP/agent/swarm/autopilot/checkpoint.sh"

# Remote advances after the agent snapshot was taken.
cd "$TMP/other"
git config user.name other
git config user.email other@example.invalid
echo newer > remote-change.txt
git add . && git commit -m newer >/dev/null
git push origin main >/dev/null

# Stale agent has local autonomous output; it must not overwrite the newer state.
cd "$TMP/agent"
mkdir -p swarm/autopilot
echo '{"decision":"PROCEED"}' > swarm/autopilot/leadership-decision.json
OUT="$TMP/out-stale"
GITHUB_OUTPUT="$OUT" AUTONOMY_TASK_ID=T-STale bash swarm/autopilot/checkpoint.sh >/tmp/checkpoint-stale.log
grep -q '^stale=true$' "$OUT"
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"
test -f remote-change.txt
test ! -e swarm/autopilot/leadership-decision.json
echo 'STALE_SNAPSHOT_GUARD=PASS'

# On a fresh snapshot, checkpointing is allowed and is pushed normally.
echo '{"decision":"PROCEED"}' > swarm/autopilot/leadership-decision.json
OUT2="$TMP/out-fresh"
GITHUB_OUTPUT="$OUT2" AUTONOMY_TASK_ID=T-FRESH bash swarm/autopilot/checkpoint.sh >/tmp/checkpoint-fresh.log
grep -q '^stale=false$' "$OUT2"
git fetch origin main >/dev/null
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"
git show origin/main:ops/leadership-decision.json | grep -q 'PROCEED'
echo 'FRESH_CHECKPOINT=PASS'
echo 'STALE_CHECKPOINT=PASS'
