#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
TMP="$(mktemp)"
cp swarm/autopilot/task-queue.json "$TMP"
cleanup(){ cp "$TMP" swarm/autopilot/task-queue.json; rm -f "$TMP"; }
trap cleanup EXIT
python3 swarm/autopilot/intent-compiler.py >/tmp/intent-compiler-1.json
C1=$(python3 - <<'PY'
import json
q=json.load(open('swarm/autopilot/task-queue.json',encoding='utf-8'))
xs=[t for t in q['tasks'] if t.get('source_requirement') is not None]
assert xs, 'compiler produced no requirement tasks'
assert len({str(t['source_requirement']) for t in xs})==len(xs), 'duplicate source requirements'
print(len(xs))
PY
)
python3 swarm/autopilot/intent-compiler.py >/tmp/intent-compiler-2.json
C2=$(python3 - <<'PY'
import json
q=json.load(open('swarm/autopilot/task-queue.json',encoding='utf-8'))
xs=[t for t in q['tasks'] if t.get('source_requirement') is not None]
print(len(xs))
PY
)
[ "$C1" = "$C2" ] || { echo 'INTENT_COMPILER_NOT_IDEMPOTENT'; exit 1; }
echo "INTENT_COMPILER=PASS tasks=$C1"
