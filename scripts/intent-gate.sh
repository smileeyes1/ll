#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
intent="$ROOT/INTENT.md"
state="$ROOT/STATE.md"
evidence="$ROOT/EVIDENCE.md"

fail(){ echo "INTENT_GATE=NO-GO: $1"; exit 1; }
[ -s "$intent" ] || fail "INTENT.md missing"
[ -s "$state" ] || fail "STATE.md missing"
[ -s "$evidence" ] || fail "EVIDENCE.md missing"

grep -q '^STATUS: ACTIVE\|^STATUS: ACHIEVED' "$intent" || fail "invalid intent status"
grep -q '^ID:' "$intent" || fail "intent ID missing"

evidence_has(){ grep -Eiq "$1" "$evidence"; }

# ACHIEVED is forbidden unless evidence proves the terminal outcome.
if grep -q '^STATUS: ACHIEVED' "$intent"; then
  evidence_has 'INTENT.*ACHIEVED|intent.*achieved' || fail "ACHIEVED without evidence"
  evidence_has 'commit|artifact' || fail "ACHIEVED lacks commit/artifact evidence"
  evidence_has 'PASS|success|SUCCESS' || fail "ACHIEVED lacks successful verification evidence"
fi

# Active intent must never be reported complete by the gate.
if grep -q '^STATUS: ACTIVE' "$intent"; then
  echo 'INTENT_GATE=PASS: active intent is durable and cannot be falsely marked achieved'
else
  echo 'INTENT_GATE=PASS: terminal intent has supporting evidence markers'
fi
