#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(AUTONOMY_CONSTITUTION.md SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md CHANGELOG.md INTENT.md .github/workflows/assurance.yml .github/workflows/autopilot.yml scripts/health-check.sh scripts/intent-gate.sh swarm/autopilot/leadership-core.py swarm/autopilot/intent-compiler.py swarm/autopilot/nbag.py swarm/autopilot/continuation.py swarm/autopilot/checkpoint.sh swarm/autopilot/model-runner.sh tests/test-structure.sh tests/test-adversarial.sh tests/test-leadership.sh tests/test-intent-gate.sh tests/test-intent-compiler.sh tests/test-nbag.sh tests/test-continuation.sh tests/test-stale-checkpoint.sh tests/test-model-runner-contract.sh)
fail=0
for f in "${required[@]}"; do
  [ -s "$ROOT/$f" ] || { echo "FAIL missing: $f"; fail=1; }
done
for marker in 'STATUS:' 'CURRENT_TASK:' 'NEXT_ACTION:' 'GO' 'NO-GO'; do
  grep -q "$marker" "$ROOT/STATE.md" "$ROOT/RUNBOOK.md" "$ROOT/SPEC.md" || { echo "FAIL marker: $marker"; fail=1; }
done
grep -q 'Ω Autonomous Leadership mandatory gate' "$ROOT/.github/workflows/autopilot.yml" || { echo 'FAIL leadership gate not mandatory'; fail=1; }
grep -q 'NO_LEADERSHIP_DECISION_NO_NBAG_NO_EXECUTION' "$ROOT/swarm/autopilot/leadership-core.py" || { echo 'FAIL leadership invariant missing'; fail=1; }
grep -q 'Compile intent gaps into tasks' "$ROOT/.github/workflows/autopilot.yml" || { echo 'FAIL intent compiler not in autopilot'; fail=1; }
grep -q 'Ω NBAG mandatory decision gate' "$ROOT/.github/workflows/autopilot.yml" || { echo 'FAIL NBAG not mandatory in autopilot'; fail=1; }
grep -q 'Dispatch immediate next autonomous cycle' "$ROOT/.github/workflows/autopilot.yml" || { echo 'FAIL direct self-chain missing'; fail=1; }
grep -q 'gh workflow run autopilot.yml --ref main' "$ROOT/.github/workflows/autopilot.yml" || { echo 'FAIL autopilot does not self-dispatch'; fail=1; }
grep -q 'gap_to_task_default' "$ROOT/swarm/autopilot/intent-compiler.py" || { echo 'FAIL intent compiler policy missing'; fail=1; }
grep -q 'NO_VERIFIED_DECISION_NO_EXECUTION' "$ROOT/swarm/autopilot/nbag.py" || { echo 'FAIL NBAG invariant missing'; fail=1; }
grep -q 'CONTINUE_UNTIL_TERMINAL_OR_SAFE_BLOCKED' "$ROOT/swarm/autopilot/continuation.py" || { echo 'FAIL continuation invariant missing'; fail=1; }
grep -q 'leadership_decision' "$ROOT/swarm/autopilot/continuation.py" || { echo 'FAIL continuation ignores leadership'; fail=1; }
grep -q 'STALE_SNAPSHOT' "$ROOT/swarm/autopilot/checkpoint.sh" || { echo 'FAIL stale checkpoint guard missing'; fail=1; }
grep -q 'git reset --hard origin/main' "$ROOT/swarm/autopilot/checkpoint.sh" || { echo 'FAIL safe stale reset missing'; fail=1; }
grep -q "'-st'" "$ROOT/swarm/autopilot/model-runner.sh" || { echo 'FAIL model runner single-turn missing'; fail=1; }
if [ "$fail" -eq 0 ]; then
  bash "$ROOT/tests/test-model-runner-contract.sh" || fail=1
fi
if [ "$fail" -eq 0 ]; then echo 'STRUCTURE=PASS'; exit 0; else echo 'STRUCTURE=FAIL'; exit 1; fi
