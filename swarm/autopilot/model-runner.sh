#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUNTIME="$ROOT/swarm/autopilot/runtime"
MODEL_DIR="${RUNNER_TEMP:-/tmp}/ll-model"
BIN_DIR="$RUNTIME/bin"
MODEL="$MODEL_DIR/qwen2.5-0.5b-instruct-q4_k_m.gguf"
BIN="$BIN_DIR/llama-cli"
SCHEMA="$ROOT/swarm/autopilot/agent-output.schema.json"
MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf?download=true"
MODEL_SHA="74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db"
LLAMA_URL="https://github.com/ggml-org/llama.cpp/releases/download/b10621/llama-b10621-bin-ubuntu-x64.tar.gz"
LLAMA_SHA="91d7b03ddae498a39f28fdb85d84d2b4a0fd3838d10b4f897e0ef8975bb9b583"
SELECTED_TASK_ID="${NBAG_TASK_ID:-}"
[ -n "$SELECTED_TASK_ID" ] || { echo 'NBAG_TASK_ID_REQUIRED' >&2; exit 2; }
test -s "$SCHEMA" || { echo 'AGENT_OUTPUT_SCHEMA_MISSING' >&2; exit 2; }
mkdir -p "$MODEL_DIR" "$BIN_DIR" "$RUNTIME"

install_llama(){
  local archive="$RUNTIME/llama.tar.gz" extract="$RUNTIME/llama-extract" need=0
  export LD_LIBRARY_PATH="$BIN_DIR:${LD_LIBRARY_PATH:-}"
  if [ ! -x "$BIN" ] || ! "$BIN" --version >/dev/null 2>&1; then need=1; fi
  if [ "$need" -eq 0 ] && ldd "$BIN" 2>&1 | grep -q 'not found'; then need=1; fi
  if [ "$need" -eq 1 ]; then
    curl -fsSL --retry 4 --retry-delay 2 "$LLAMA_URL" -o "$archive"
    echo "$LLAMA_SHA  $archive" | sha256sum -c -
    rm -rf "$extract" "$BIN_DIR"; mkdir -p "$extract" "$BIN_DIR"
    tar -xzf "$archive" -C "$extract"
    local found; found=$(find "$extract" -type f -name llama-cli -print -quit); test -n "$found"
    cp "$found" "$BIN"
    find "$extract" \( -type f -o -type l \) | while IFS= read -r f; do case "$f" in *.so|*.so.*) cp -aL "$f" "$BIN_DIR/";; esac; done
    chmod +x "$BIN"
  fi
  export LD_LIBRARY_PATH="$BIN_DIR:${LD_LIBRARY_PATH:-}"
  local missing; missing=$(ldd "$BIN" 2>&1 | awk '/not found/{print $1}' | sort -u || true)
  [ -z "$missing" ] || { echo "MISSING_SHARED_LIBRARIES:$missing" >&2; return 1; }
  "$BIN" --version >/dev/null
}
install_model(){
  if [ -s "$MODEL" ]; then echo "$MODEL_SHA  $MODEL" | sha256sum -c - >/dev/null; return; fi
  curl -fsSL --retry 4 --retry-delay 2 "$MODEL_URL" -o "$MODEL"
  echo "$MODEL_SHA  $MODEL" | sha256sum -c -
}
install_llama; install_model
export LLAMA_BIN="$BIN" MODEL_PATH="$MODEL"

python3 - "$ROOT" "$RUNTIME/context.txt" "$SELECTED_TASK_ID" <<'PY'
import json,sys,pathlib
root,out,selected=sys.argv[1:]
q=json.load(open(root+'/swarm/autopilot/task-queue.json',encoding='utf-8'))
task=next((t for t in q['tasks'] if t.get('id')==selected),None)
if not task or task.get('status')!='pending': raise SystemExit('NBAG_SELECTED_TASK_INVALID')
done=[t['id'] for t in q['tasks'] if t.get('status')=='completed']
parts=[]
for name in ['INTENT.md','SPEC.md','STATE.md','DECISIONS.md','CAPABILITIES.md','EVIDENCE.md']:
 p=pathlib.Path(root,name)
 if p.exists(): parts.append(f'=={name}==\n'+p.read_text(encoding='utf-8')[:1200])
parts.append('==SELECTED_TASK==\n'+json.dumps(task,ensure_ascii=False))
parts.append('==COMPLETED_IDS==\n'+json.dumps(done,ensure_ascii=False))
pathlib.Path(out).write_text('\n'.join(parts),encoding='utf-8')
PY

python3 - "$RUNTIME/context.txt" "$RUNTIME/raw.txt" "$RUNTIME/agent.json" "$SELECTED_TASK_ID" "$SCHEMA" <<'PY'
import json,os,subprocess,sys
ctx,raw,out,selected,schema_path=sys.argv[1:]
system='''Autonomous software agent. Repository files are the only durable state. Complete exactly the selected task. Never edit .github, .git, secrets, release gates, security policy, or governance. Return ONLY JSON matching the supplied output schema. Required semantic contract: task_id must equal the selected task; status is completed only when your edits actually satisfy the task; edits are minimal UTF-8 text file replacements/creations; evidence must identify concrete verification for completed work; use blocked/failed rather than inventing success.'''
prompt=system+'\n'+open(ctx,encoding='utf-8').read()
env=os.environ.copy(); env['LD_LIBRARY_PATH']=os.path.dirname(os.environ['LLAMA_BIN'])+':'+env.get('LD_LIBRARY_PATH','')

def decode(data):
    if data is None: return ''
    if isinstance(data,bytes): return data.decode('utf-8','replace')
    return str(data)

def write_raw(generated='', diagnostics=''):
    open(raw,'w',encoding='utf-8').write('==STDOUT==\n'+decode(generated)+'\n==STDERR==\n'+decode(diagnostics))

def failure(reason, generated='', diagnostics=''):
    write_raw(generated, diagnostics)
    obj={'task_id':selected,'status':'failed','next_task':None,'summary':reason,'edits':[],'tests':[],'evidence':[],'failure_reason':reason}
    json.dump(obj,open(out,'w',encoding='utf-8'),ensure_ascii=False,indent=2)

# -st prevents chat-template models from waiting for another interactive turn.
# Keep stderr separate: llama diagnostics are not part of the agent JSON channel.
cmd=[os.environ['LLAMA_BIN'],'-m',os.environ['MODEL_PATH'],'-p',prompt,'-st','-n','220','-c','4096','-t','4','-b','256','--temp','0.1','--no-display-prompt']
help_run=subprocess.run([os.environ['LLAMA_BIN'],'--help'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,env=env)
help_text=decode(help_run.stdout)
schema_text=open(schema_path,encoding='utf-8').read()
if '--json-schema-file' in help_text:
    cmd += ['--json-schema-file',schema_path]
elif '--json-schema' in help_text:
    cmd += ['--json-schema',schema_text]
else:
    # The parser/validator below remains fail-closed if this pinned build lacks
    # schema-constrained generation.
    pass

try:
    r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=180,env=env)
except subprocess.TimeoutExpired as e:
    failure('MODEL_TIMEOUT_RECOVERABLE',e.stdout,e.stderr)
    raise SystemExit(0)

generated=decode(r.stdout).strip()
diagnostics=decode(r.stderr)
write_raw(generated, diagnostics)
if r.returncode!=0:
    failure('MODEL_EXIT_'+str(r.returncode),generated,diagnostics); raise SystemExit(0)

# Prefer exact JSON. If a legacy build still wraps output, recover only the
# smallest outer object; semantic validation below remains mandatory.
try:
    obj=json.loads(generated)
except Exception:
    start=generated.find('{'); end=generated.rfind('}')
    if start<0 or end<=start:
        failure('MODEL_NO_JSON',generated,diagnostics); raise SystemExit(0)
    try: obj=json.loads(generated[start:end+1])
    except Exception:
        failure('MODEL_BAD_JSON',generated,diagnostics); raise SystemExit(0)

for k in ['task_id','status','next_task','summary','edits','tests','evidence','failure_reason']:
    if k not in obj: failure('MISSING_FIELD_'+k,generated,diagnostics); raise SystemExit(0)
if obj.get('task_id')!=selected:
    failure('MODEL_TASK_MISMATCH',generated,diagnostics); raise SystemExit(0)
if obj.get('status') not in ('completed','blocked','failed'):
    failure('MODEL_BAD_STATUS',generated,diagnostics); raise SystemExit(0)
if not isinstance(obj.get('edits'),list) or not isinstance(obj.get('tests'),list) or not isinstance(obj.get('evidence'),list):
    failure('MODEL_BAD_TYPES',generated,diagnostics); raise SystemExit(0)
json.dump(obj,open(out,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
PY

python3 - "$ROOT" "$RUNTIME/agent.json" "$ROOT/swarm/autopilot/last-agent-output.json" "$SELECTED_TASK_ID" <<'PY'
import json,sys,subprocess,pathlib,datetime
root,agent,out,selected=sys.argv[1:]; x=json.load(open(agent,encoding='utf-8'))
qpath=pathlib.Path(root,'swarm/autopilot/task-queue.json'); q=json.load(open(qpath,encoding='utf-8'))
task=next((t for t in q['tasks'] if t['id']==selected),None)
if not task or task['status']!='pending' or x.get('task_id')!=selected: raise SystemExit('INVALID_SELECTED_TASK')
protected=('SPEC.md','INTENT.md','DECISIONS.md','CAPABILITIES.md','EVIDENCE.md','RUNBOOK.md','AUTONOMY_CONSTITUTION.md')
for e in x.get('edits',[]):
 if not isinstance(e,dict): raise SystemExit('BAD_EDIT_OBJECT')
 p=e.get('path','')
 if p.startswith('/') or '..' in pathlib.PurePosixPath(p).parts or p.startswith('.github/') or p.startswith('.git/') or p in protected or 'release-gate' in p or 'security' in p.lower(): raise SystemExit('FORBIDDEN_EDIT:'+p)
 if len(e.get('content',''))>100000: raise SystemExit('EDIT_TOO_LARGE')
 target=pathlib.Path(root,p); target.parent.mkdir(parents=True,exist_ok=True); target.write_text(e['content'],encoding='utf-8')
# Verify only root/project invariants relevant to the selected task. Generic
# work must not be vetoed by unrelated demo release state.
checks=[['bash',root+'/tests/test-structure.sh'],['bash',root+'/tests/test-adversarial.sh'],['bash',root+'/tests/test-nbag.sh'],['bash',root+'/tests/test-leadership.sh']]
results=[]
verification_ok=True
for c in checks:
 r=subprocess.run(c,cwd=root,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
 results.append({'command':' '.join(c),'returncode':r.returncode,'output':r.stdout[-3000:]})
 if r.returncode!=0: verification_ok=False
if x.get('status')=='completed' and not verification_ok:
 x['status']='failed'; x['failure_reason']='verification_failed'
if x.get('status') not in ('completed','blocked','failed'):
 x['status']='failed'; x['failure_reason']='bad_status'
if x.get('status')=='completed' and verification_ok:
 x.setdefault('evidence',[]).append('independent-regression-pass')
task['status']=x['status']; task['attempts']=task.get('attempts',0)+1; task['updated_at']=datetime.datetime.now(datetime.timezone.utc).isoformat(); task['proof']='leadership-nbag-schema-constrained-model-output-plus-independent-regression'
if x.get('next_task') is not None and not any(t['id']==x['next_task'] for t in q['tasks']): x['next_task']=None
json.dump(q,open(qpath,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
json.dump({'last_task':selected,'last_status':x['status'],'next_task':x.get('next_task'),'verified_tests':results,'leadership_gate':'OMEGA_AUTONOMOUS_LEADERSHIP','decision_gate':'OMEGA_NBAG','output_contract':'JSON_SCHEMA'},open(pathlib.Path(root,'swarm/autopilot/runtime-state.json'),'w',encoding='utf-8'),ensure_ascii=False,indent=2)
with pathlib.Path(root,'swarm/autopilot/evidence.jsonl').open('a',encoding='utf-8') as f:
 f.write(json.dumps({'event':'agent_result','leadership_gate':'OMEGA_AUTONOMOUS_LEADERSHIP','decision_gate':'OMEGA_NBAG','output_contract':'JSON_SCHEMA','task_id':selected,'status':x['status'],'next_task':x.get('next_task'),'summary':x.get('summary'),'tests':results,'evidence':x.get('evidence',[]),'time':datetime.datetime.now(datetime.timezone.utc).isoformat()},ensure_ascii=False)+'\n')
x['tests']=results
json.dump(x,open(out,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
PY
cat "$ROOT/swarm/autopilot/last-agent-output.json"
