#!/usr/bin/env bash
set -euo pipefail
required=(SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md)
for f in "${required[@]}"; do test -s "$f" || { echo "MISSING_OR_EMPTY:$f"; exit 1; }; done
test -d tests || exit 1
test -d artifacts || exit 1
echo 'STRUCTURE: PASS'
