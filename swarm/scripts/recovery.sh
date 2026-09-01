#!/usr/bin/env bash
set -euo pipefail
QUEUE="swarm/tasks/queue.json"
python3 - "$QUEUE" <<'PY'
import json,sys,datetime
p=sys.argv[1]; d=json.load(open(p)); now=datetime.datetime.now(datetime.timezone.utc).isoformat()
for t in d['tasks']:
    if t['status']=='CLAIMED' and t.get('lease_expires') and t['lease_expires'] < now:
        t['status']='REQUEUED'; t['owner']=None; t['lease_expires']=None
        print('REQUEUED',t['id'])
open(p,'w').write(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
PY
