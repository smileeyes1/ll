#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/swarm/autopilot"
cp "$ROOT/swarm/autopilot/continuation.py" "$TMP/swarm/autopilot/continuation.py"

run_case(){
  local expected="$1" json="$2" lead="${3:-PROCEED}"
  printf '%s\n' "$json" > "$TMP/swarm/autopilot/task-queue.json"
  printf '{"decision":"%s"}\n' "$lead" > "$TMP/swarm/autopilot/leadership-decision.json"
  (cd "$TMP" && python3 swarm/autopilot/continuation.py >/dev/null)
  python3 - "$TMP/swarm/autopilot/continuation.json" "$expected" "$lead" <<'PY'
import json,sys
p,expected,lead=sys.argv[1:]
x=json.load(open(p,encoding='utf-8'))
assert x['gate']=='OMEGA_CONTINUATION'
assert x['rule']=='CONTINUE_UNTIL_TERMINAL_OR_SAFE_BLOCKED'
assert x['decision']==expected,(x,expected)
assert x['leadership_decision']==lead
PY
}

run_case CONTINUE '{"tasks":[{"id":"A","status":"pending","depends_on":[]}]}'
run_case SAFE_BLOCKED '{"tasks":[{"id":"A","status":"failed","depends_on":[]},{"id":"B","status":"pending","depends_on":["A"]}]}'
run_case SAFE_BLOCKED '{"tasks":[{"id":"B","status":"pending","depends_on":["MISSING"]}]}'
run_case TERMINAL_CANDIDATE '{"tasks":[{"id":"A","status":"completed","depends_on":[]}]}'
run_case SAFE_BLOCKED '{"tasks":[{"id":"A","status":"pending","depends_on":[]}]}' HUMAN_REQUIRED
run_case SAFE_BLOCKED '{"tasks":[{"id":"A","status":"pending","depends_on":[]}]}' SAFE_BLOCKED

grep -q 'gh workflow run autopilot.yml --ref main' "$ROOT/.github/workflows/autopilot.yml"
grep -q 'CONTINUE_UNTIL_TERMINAL_OR_SAFE_BLOCKED' "$ROOT/swarm/autopilot/continuation.py"
grep -q 'leadership_decision' "$ROOT/swarm/autopilot/continuation.py"
echo 'CONTINUATION=PASS'
