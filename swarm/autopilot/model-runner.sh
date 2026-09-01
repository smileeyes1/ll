#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROMPT="$ROOT/swarm/autopilot/runtime-prompt.md"
OUT="$ROOT/swarm/autopilot/model-response.json"
cat > "$PROMPT" <<'EOF'
You are the project execution agent. Work ONLY from repository state. Read SPEC.md, STATE.md, DECISIONS.md, CAPABILITIES.md, EVIDENCE.md and the active task queue. Determine the single next executable task. Do not claim completion without evidence. Do not change release criteria. Return strict JSON with: task_id,status,next_task,changed_files,tests,evidence,failure_reason. If no safe executable task exists, status must be blocked.
EOF
# Provider-neutral runner: deterministic mode is always available; an external model can be injected later.
python3 - "$ROOT" "$PROMPT" "$OUT" <<'PY'
import json,os,sys,datetime
root,prompt,out=sys.argv[1:]
q=json.load(open(root+'/swarm/autopilot/task-queue.json'))
completed={t['id'] for t in q['tasks'] if t['status']=='completed'}
active=None
for t in q['tasks']:
    if t['status']=='pending' and all(d in completed for d in t['depends_on']): active=t; break
result={'task_id':active['id'] if active else None,'status':'ready' if active else 'blocked','next_task':active.get('next') if active else None,'changed_files':[],'tests':[],'evidence':['repository-state-read'],'failure_reason':None if active else 'no executable task'}
json.dump(result,open(out,'w'),indent=2)
PY
cat "$OUT"
