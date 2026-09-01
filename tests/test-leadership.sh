#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/swarm/autopilot"
cp "$ROOT/swarm/autopilot/leadership-core.py" "$TMP/swarm/autopilot/leadership-core.py"
cat > "$TMP/AUTONOMY_CONSTITUTION.md" <<'EOF'
NO LEADERSHIP DECISION → NO NBAG → NO EXECUTION.
EOF
cat > "$TMP/INTENT.md" <<'EOF'
STATUS: ACTIVE
ID: TEST-001
## Intent
Build and deploy a safe user-facing web product.
## Required outcome
1. Product works.
EOF
cat > "$TMP/SPEC.md" <<'EOF'
## معايير القبول
- Build succeeds.
- Smoke test succeeds.
## غير النطاق
No paid service without authorization.
EOF
cat > "$TMP/STATE.md" <<'EOF'
STATUS: ACTIVE
BLOCKER: NONE
CURRENT_TASK: plan
NEXT_ACTION: choose best action
EOF
cat > "$TMP/DECISIONS.md" <<'EOF'
Local fallback is available.
EOF
cat > "$TMP/CAPABILITIES.md" <<'EOF'
GitHub Actions | VERIFIED
External hosting | UNVERIFIED
EOF
cat > "$TMP/EVIDENCE.md" <<'EOF'
No Evidence = No Success.
EOF
cat > "$TMP/RUNBOOK.md" <<'EOF'
Use small reversible commits and rollback to Last Known Good.
EOF
cat > "$TMP/swarm/autopilot/task-queue.json" <<'EOF'
{"tasks":[{"id":"T1","role":"builder","status":"pending","depends_on":[],"goal":"build"}]}
EOF
OMEGA_ROOT="$TMP" python3 "$TMP/swarm/autopilot/leadership-core.py" >/dev/null
python3 - "$TMP/swarm/autopilot/leadership-decision.json" <<'PY'
import json,sys
x=json.load(open(sys.argv[1],encoding='utf-8'))
assert x['gate']=='OMEGA_AUTONOMOUS_LEADERSHIP'
assert x['rule']=='NO_LEADERSHIP_DECISION_NO_NBAG_NO_EXECUTION'
assert x['decision']=='PROCEED'
assert x['question_count'] >= 20
keys={q['key'] for q in x['questions']}
for key in ['goal','success','unknowns','constraints','capabilities','bottleneck','risk','reversibility','evidence_plan','alternatives','human','stop','delivery.target','delivery.rollback','delivery.smoke']:
    assert key in keys, key
print('LEADERSHIP_NORMAL=PASS')
PY
python3 - "$TMP/swarm/autopilot/task-queue.json" <<'PY'
import json,sys
p=sys.argv[1]; q=json.load(open(p)); q['tasks'][0]['requires_human']=True
json.dump(q,open(p,'w'))
PY
OMEGA_ROOT="$TMP" python3 "$TMP/swarm/autopilot/leadership-core.py" >/dev/null
python3 - "$TMP/swarm/autopilot/leadership-decision.json" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['decision']=='HUMAN_REQUIRED'; assert x['human_required_task_ids']==['T1']
print('LEADERSHIP_HUMAN_GATE=PASS')
PY
rm "$TMP/SPEC.md"
OMEGA_ROOT="$TMP" python3 "$TMP/swarm/autopilot/leadership-core.py" >/dev/null
python3 - "$TMP/swarm/autopilot/leadership-decision.json" <<'PY'
import json,sys
x=json.load(open(sys.argv[1])); assert x['decision']=='SAFE_BLOCKED'; assert 'SPEC.md' in x['missing_core_files']
print('LEADERSHIP_MISSING_CORE=PASS')
PY
echo 'LEADERSHIP=PASS'
