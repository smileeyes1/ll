#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md CHANGELOG.md INTENT.md .github/workflows/assurance.yml .github/workflows/autopilot.yml scripts/health-check.sh scripts/intent-gate.sh swarm/autopilot/intent-compiler.py swarm/autopilot/nbag.py tests/test-structure.sh tests/test-adversarial.sh tests/test-intent-gate.sh tests/test-intent-compiler.sh tests/test-nbag.sh)
fail=0
for f in "${required[@]}"; do
  [ -s "$ROOT/$f" ] || { echo "FAIL missing: $f"; fail=1; }
done
for marker in 'STATUS:' 'CURRENT_TASK:' 'NEXT_ACTION:' 'GO' 'NO-GO'; do
  grep -q "$marker" "$ROOT/STATE.md" "$ROOT/RUNBOOK.md" "$ROOT/SPEC.md" || { echo "FAIL marker: $marker"; fail=1; }
done
grep -q 'Compile intent gaps into tasks' "$ROOT/.github/workflows/autopilot.yml" || { echo 'FAIL intent compiler not in autopilot'; fail=1; }
grep -q 'Ω NBAG mandatory decision gate' "$ROOT/.github/workflows/autopilot.yml" || { echo 'FAIL NBAG not mandatory in autopilot'; fail=1; }
grep -q 'gap_to_task_default' "$ROOT/swarm/autopilot/intent-compiler.py" || { echo 'FAIL intent compiler policy missing'; fail=1; }
grep -q 'NO_VERIFIED_DECISION_NO_EXECUTION' "$ROOT/swarm/autopilot/nbag.py" || { echo 'FAIL NBAG invariant missing'; fail=1; }
if [ "$fail" -eq 0 ]; then echo 'STRUCTURE=PASS'; exit 0; else echo 'STRUCTURE=FAIL'; exit 1; fi
