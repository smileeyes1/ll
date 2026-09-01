#!/usr/bin/env bash
set -euo pipefail
required=(SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md)
for f in "${required[@]}"; do test -s "$f" || exit 1; done
test -s artifacts/continuity-proof.md
echo 'DEMO STRUCTURE: PASS'
