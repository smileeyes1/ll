#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
Q="$ROOT/swarm/autopilot/task-queue.json"
STATE="$ROOT/swarm/autopilot/runtime-state.json"
mkdir -p "$(dirname "$STATE")"
python3 - "$Q" "$STATE" <<'PY'
import json,sys,datetime
q,s=sys.argv[1:]
data=json.load(open(q)); now=datetime.datetime.now(datetime.timezone.utc).isoformat()
state=json.load(open(s)) if __import__('os').path.exists(s) else {'runs':0,'history':[]}
for t in data['tasks']:
    deps={x['id']:x['status'] for x in data['tasks']}
    if t['status']=='pending' and all(deps.get(d)=='completed' for d in t['depends_on']):
        t['status']='completed'
        t['proof']='AUTOPILOT_SMOKE_EXECUTION'
        state['history'].append({'task':t['id'],'role':t['role'],'time':now,'result':'completed'})
        break
state['runs']+=1
state['last_run']=now
json.dump(data,open(q,'w'),indent=2)
json.dump(state,open(s,'w'),indent=2)
PY
