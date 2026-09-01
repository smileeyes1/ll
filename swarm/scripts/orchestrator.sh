#!/usr/bin/env bash
set -euo pipefail
QUEUE="swarm/tasks/queue.json"
RUNS="swarm/runs"
mkdir -p "$RUNS"
python3 - "$QUEUE" "$RUNS" <<'PY'
import json,sys,datetime,pathlib
q=pathlib.Path(sys.argv[1]); runs=pathlib.Path(sys.argv[2])
data=json.loads(q.read_text())
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
completed={t['id'] for t in data['tasks'] if t['status']=='SUCCEEDED'}
for t in data['tasks']:
    if t['status']=='PENDING' and all(d in completed for d in t['dependencies']):
        t['status']='CLAIMED'; t['owner']=t['role']+'-auto'; t['lease_expires']=now
        (runs/(t['id']+'.md')).write_text(f"# {t['id']}\n\nRole: {t['role']}\nClaimed: {now}\nStatus: CLAIMED\nGoal: {t['goal']}\n\nHandoff is durable in the repository.\n")
        print('CLAIMED',t['id']); break
q.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
PY
