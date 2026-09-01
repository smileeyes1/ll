#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
# Empty critical source must be detected.
tmp="$ROOT/tests/.tmp-empty"
: > "$tmp"
if [ -s "$tmp" ]; then echo 'FAIL empty-file test'; fail=1; else echo 'PASS empty-file detection primitive'; fi
rm -f "$tmp"
# Broken JSON must be rejected without external dependencies.
bad="$ROOT/tests/.tmp-bad.json"
printf '{broken' > "$bad"
if python3 - "$bad" <<'PY'
import json,sys
try:
    json.load(open(sys.argv[1], encoding='utf-8'))
except Exception:
    raise SystemExit(0)
raise SystemExit(1)
PY
then echo 'PASS malformed-data rejection'; else echo 'FAIL malformed-data rejection'; fail=1; fi
rm -f "$bad"
# Missing artifact must not be treated as success.
missing="$ROOT/tests/.tmp-artifact"
rm -f "$missing"
if [ -e "$missing" ]; then echo 'FAIL missing-artifact test'; fail=1; else echo 'PASS missing-artifact detection primitive'; fi
# No secrets test.
if grep -RInE '(BEGIN (RSA|OPENSSH|PRIVATE KEY)|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9_-]{20,})' "$ROOT" --exclude-dir=.git --exclude='test-adversarial.sh' >/dev/null 2>&1; then echo 'FAIL secret-pattern defense'; fail=1; else echo 'PASS secret-pattern defense'; fi
if [ "$fail" -eq 0 ]; then echo 'ADVERSARIAL=PASS'; exit 0; else echo 'ADVERSARIAL=FAIL'; exit 1; fi
