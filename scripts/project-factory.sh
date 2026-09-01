#!/usr/bin/env bash
set -euo pipefail
NAME="${1:-demo-project}"
GOAL="${2:-replace this with the project goal}"
ROOT="projects/$NAME"
test ! -e "$ROOT" || { echo "EXISTS:$ROOT"; exit 1; }
mkdir -p "$ROOT"/{tests,scripts,artifacts,ops}
for f in README.md AUTONOMY_CONSTITUTION.md INTENT.md SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md; do cp "templates/PROJECT/$f" "$ROOT/$f"; done
sed -i "s/{{PROJECT_NAME}}/$NAME/g; s/{{GOAL}}/$GOAL/g" "$ROOT"/README.md "$ROOT"/INTENT.md "$ROOT"/SPEC.md
cp templates/PROJECT/tests/test-structure.sh "$ROOT/tests/"
cp templates/PROJECT/tests/test-adversarial.sh "$ROOT/tests/"
cp templates/PROJECT/scripts/release-gate.sh "$ROOT/scripts/"
chmod +x "$ROOT/tests/"*.sh "$ROOT/scripts/"*.sh
printf '# Factory manifest\n\nPROJECT: %s\nCREATED_UTC: %s\nFACTORY: Project Factory v3.0 — Autonomous Leadership Ready\nLEADERSHIP: AUTONOMY_CONSTITUTION.md + INTENT.md\n' "$NAME" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$ROOT/ops/factory-manifest.md"
printf 'Factory created: %s\n' "$ROOT"
