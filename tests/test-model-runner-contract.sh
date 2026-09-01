#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="$ROOT/swarm/autopilot/model-runner.sh"
test -s "$RUNNER"
grep -q "'-st'" "$RUNNER" || { echo 'FAIL single-turn flag missing'; exit 1; }
grep -q "decode('utf-8','replace')" "$RUNNER" || { echo 'FAIL defensive byte decoding missing'; exit 1; }
if grep -q 'text=True,timeout=180' "$RUNNER"; then
  echo 'FAIL strict subprocess text decoding reintroduced'; exit 1
fi
grep -q 'MODEL_TIMEOUT_RECOVERABLE' "$RUNNER" || { echo 'FAIL timeout recovery missing'; exit 1; }
grep -q 'independent-regression-pass' "$RUNNER" || { echo 'FAIL independent evidence missing'; exit 1; }
grep -q 'AUTONOMY_CONSTITUTION.md' "$RUNNER" || { echo 'FAIL constitution edit protection missing'; exit 1; }
if grep -q "projects/demo-project/scripts/release-gate.sh" "$RUNNER"; then
  echo 'FAIL unrelated demo release gate still coupled to generic task verification'; exit 1
fi
grep -q '^swarm/autopilot/runtime/$' "$ROOT/.gitignore" || { echo 'FAIL runtime not ignored'; exit 1; }
grep -q 'FORBIDDEN_AUTONOMOUS_RUNTIME_ARTIFACT' "$ROOT/swarm/autopilot/checkpoint.sh" || { echo 'FAIL runtime checkpoint guard missing'; exit 1; }
echo 'MODEL_RUNNER_CONTRACT=PASS'
