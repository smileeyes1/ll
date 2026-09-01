#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
check(){
  local name="$1" path="$2"
  if [ -s "$ROOT/$path" ]; then printf 'PASS  %s\n' "$name"; else printf 'FAIL  %s (%s)\n' "$name" "$path"; fail=1; fi
}
check SPEC SPEC.md
check STATE STATE.md
check DECISIONS DECISIONS.md
check CAPABILITIES CAPABILITIES.md
check EVIDENCE EVIDENCE.md
check RUNBOOK RUNBOOK.md
check CHANGELOG CHANGELOG.md
check WORKFLOW .github/workflows/assurance.yml
check STRUCTURE_TEST tests/test-structure.sh
check ADVERSARIAL_TEST tests/test-adversarial.sh

if grep -RInE '(BEGIN (RSA|OPENSSH|PRIVATE KEY)|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9_-]{20,})' "$ROOT" --exclude-dir=.git >/dev/null 2>&1; then
  echo 'FAIL  possible secret material detected'; fail=1
else
  echo 'PASS  no obvious secret pattern detected'
fi

if [ "$fail" -eq 0 ]; then echo 'HEALTH=PASS'; exit 0; else echo 'HEALTH=FAIL'; exit 1; fi
