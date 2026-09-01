#!/usr/bin/env bash
set -euo pipefail
required=(AUTONOMY_CONSTITUTION.md INTENT.md SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md)
for f in "${required[@]}"; do test -s "$f" || { echo "MISSING_OR_EMPTY:$f"; exit 1; }; done
grep -q 'NO LEADERSHIP DECISION' AUTONOMY_CONSTITUTION.md || { echo 'LEADERSHIP_INVARIANT_MISSING'; exit 1; }
grep -q '^STATUS: ACTIVE\|^STATUS: ACHIEVED' INTENT.md || { echo 'INTENT_STATUS_INVALID'; exit 1; }
test -d tests || exit 1
test -d artifacts || exit 1
echo 'STRUCTURE: PASS'
