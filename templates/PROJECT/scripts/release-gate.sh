#!/usr/bin/env bash
set -euo pipefail
required=(SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md)
for f in "${required[@]}"; do test -s "$f" || { echo "NO-GO: $f missing/empty"; exit 1; }; done
bash tests/test-structure.sh
bash tests/test-adversarial.sh
test -d artifacts || { echo 'NO-GO: artifacts directory missing'; exit 1; }
if find artifacts -type f -size +0c -print -quit | grep -q .; then :; else echo 'NO-GO: no non-empty artifact'; exit 1; fi
echo 'GO: release gate passed'
