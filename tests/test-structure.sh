#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md CHANGELOG.md .github/workflows/assurance.yml scripts/health-check.sh tests/test-structure.sh tests/test-adversarial.sh)
fail=0
for f in "${required[@]}"; do
  [ -s "$ROOT/$f" ] || { echo "FAIL missing: $f"; fail=1; }
done
for marker in 'STATUS:' 'CURRENT_TASK:' 'NEXT_ACTION:' 'GO' 'NO-GO'; do
  grep -q "$marker" "$ROOT/STATE.md" "$ROOT/RUNBOOK.md" "$ROOT/SPEC.md" || { echo "FAIL marker: $marker"; fail=1; }
done
[ -s "$ROOT/.github/workflows/assurance.yml" ] || fail=1
if [ "$fail" -eq 0 ]; then echo 'STRUCTURE=PASS'; exit 0; else echo 'STRUCTURE=FAIL'; exit 1; fi
