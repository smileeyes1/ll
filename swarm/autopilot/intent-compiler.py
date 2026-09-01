#!/usr/bin/env python3
"""Compile durable INTENT.md outcomes into durable executable tasks.

Idempotent: a requirement already represented by source_requirement is never
created twice. This closes the gap between intent and task queue without chat
memory or manual task creation.
"""
import json,re
from datetime import datetime, timezone
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
INTENT=ROOT/'INTENT.md'
QUEUE=ROOT/'swarm/autopilot/task-queue.json'
text=INTENT.read_text(encoding='utf-8')
section=text.split('## Required outcome',1)[1].split('\n## ',1)[0] if '## Required outcome' in text else ''
requirements=[]
for line in section.splitlines():
    m=re.match(r'^\s*(\d+)\.\s+(.+?)\s*$',line)
    if m: requirements.append((int(m.group(1)),m.group(2)))
q=json.loads(QUEUE.read_text(encoding='utf-8'))
existing={str(t.get('source_requirement')) for t in q['tasks'] if t.get('source_requirement') is not None}

def role_for(goal:str)->str:
    g=goal.lower()
    if any(k in g for k in ('release','deploy','build','smoke')): return 'release'
    if any(k in g for k in ('regression','adversarial','chaos','validation','تحقق','اختبار')): return 'tester'
    if any(k in g for k in ('recovery','retry','failover','model runner','تنفيذ')): return 'builder'
    if any(k in g for k in ('intent','تخطيط','مهام','مصدر حقيقة')): return 'planner'
    return 'builder'
created=[]
for num,goal in requirements:
    key=str(num)
    if key in existing: continue
    tid=f'INTENT-GAP-{num:03d}'
    if any(t.get('id')==tid for t in q['tasks']): continue
    q['tasks'].append({
        'id':tid,
        'role':role_for(goal),
        'status':'pending',
        'depends_on':[],
        'goal':goal,
        'source_requirement':num,
        'source_intent':'LL-AUTONOMY-001',
        'created_at':datetime.now(timezone.utc).isoformat(),
        'next':None,
    })
    created.append(tid)
q.setdefault('policy',{})['intent_compiler']='enabled'
q['policy']['gap_to_task_default']=True
QUEUE.write_text(json.dumps(q,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'compiler':'INTENT_TO_TASKS','requirements':len(requirements),'created':created},ensure_ascii=False))
