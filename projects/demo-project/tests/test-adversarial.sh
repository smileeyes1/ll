#!/usr/bin/env bash
set -euo pipefail
# Critical files must be non-empty.
for f in SPEC.md STATE.md EVIDENCE.md; do test -s "$f" || exit 1; done
# Artifact must remain non-empty.
test -s artifacts/continuity-proof.md
# Evidence ledger must be structurally present.
grep -q '^# Evidence Ledger' EVIDENCE.md
echo 'DEMO ADVERSARIAL: PASS'
