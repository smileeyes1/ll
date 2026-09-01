#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
Q="$ROOT/swarm/autopilot/task-queue.json"
STATE="$ROOT/swarm/autopilot/runtime-state.json"
mkdir -p "$(dirname "$STATE")"
python3 - "$Q" "$STATE" <<'PY'
import json,sys,datetime,os
q,s=sys.argv[1:]
data=json.load(open(q)); now=datetime.datetime.now(datetime.timezone.utc).isoformat()
state=json.load(open(s)) if os.path.exists(s) else {'runs':0,'history':[]}
done={x['id'] for x in data['tasks'] if x['status']=='completed'}
active=next((t for t in data['tasks'] if t['status']=='pending' and all(d in done for d in t['depends_on'])),None)
state['runs']=state.get('runs',0)+1; state['last_run']=now; state['next_executable']=active['id'] if active else None
# Smoke orchestration is read-only. Only the real model runner may change task status.
json.dump(state,open(s,'w'),indent=2)
print(active['id'] if active else 'NO_EXECUTABLE_TASK')
PY
