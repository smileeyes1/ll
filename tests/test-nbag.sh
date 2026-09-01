#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
python3 swarm/autopilot/nbag.py >/tmp/nbag.out
python3 - <<'PY'
import json
from pathlib import Path
p=Path('swarm/autopilot/next-best-action.json')
x=json.loads(p.read_text(encoding='utf-8'))
assert x['gate']=='OMEGA_NBAG'
assert x['rule']=='NO_VERIFIED_DECISION_NO_EXECUTION'
assert x['intent_present'] is True
assert x['state_present'] is True
assert x['decision'] in ('EXECUTE','NO_EXECUTABLE_ACTION')
if x['decision']=='EXECUTE':
    assert x['selected_task_id']
    ids=[c['task_id'] for c in x['candidates']]
    assert x['selected_task_id'] in ids
    scores=[c['score'] for c in x['candidates']]
    assert scores==sorted(scores, reverse=True)
print('NBAG_GATE=PASS')
PY
