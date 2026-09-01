#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LEASES="$ROOT/swarm/autopilot/leases.json"
mkdir -p "$(dirname "$LEASES")"
python3 - "$LEASES" <<'PY'
import json,sys,os,datetime
p=sys.argv[1]
data=json.load(open(p)) if os.path.exists(p) else {'leases':[]}
now=datetime.datetime.now(datetime.timezone.utc)
recovered=[]
for x in data['leases']:
    if x.get('status')=='active':
        try: expired=datetime.datetime.fromisoformat(x['expires_at'].replace('Z','+00:00')) <= now
        except: expired=True
        if expired:
            x['status']='expired'; recovered.append(x['task_id'])
json.dump(data,open(p,'w'),indent=2)
print('WATCHDOG recovered:', ','.join(recovered) if recovered else 'none')
PY
