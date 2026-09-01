#!/usr/bin/env bash
set -euo pipefail
bash tests/test-structure.sh
bash tests/test-adversarial.sh
test -s artifacts/continuity-proof.md
echo 'DEMO RELEASE GATE: GO'
