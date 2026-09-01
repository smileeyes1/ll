#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

test -s "$ROOT/INTENT.md"
test -s "$ROOT/scripts/intent-gate.sh"
grep -q '^ID:' "$ROOT/INTENT.md"
grep -q '^STATUS: ACTIVE' "$ROOT/INTENT.md"
# An active intent must not be treated as completed.
if grep -q '^STATUS: ACHIEVED' "$ROOT/INTENT.md"; then
  echo 'FAIL active intent unexpectedly marked achieved'; exit 1
fi
bash "$ROOT/scripts/intent-gate.sh"
echo 'INTENT_GATE_TEST=PASS'
