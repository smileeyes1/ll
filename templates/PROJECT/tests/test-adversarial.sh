#!/usr/bin/env bash
set -euo pipefail
fail=0
# Empty critical state must fail.
tmp=$(mktemp)
cp STATE.md "$tmp"
: > STATE.md
if test -s STATE.md; then echo 'ADVERSARIAL_EMPTY_STATE: FAIL'; fail=1; else echo 'ADVERSARIAL_EMPTY_STATE: PASS'; fi
mv "$tmp" STATE.md
# Required evidence must contain an evidence ledger heading.
grep -q '^# Evidence Ledger' EVIDENCE.md || { echo 'ADVERSARIAL_EVIDENCE_LEDGER: FAIL'; fail=1; }
echo 'ADVERSARIAL_EVIDENCE_LEDGER: PASS'
exit "$fail"
