#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUNTIME="$ROOT/swarm/autopilot/runtime"
MODEL_DIR="${RUNNER_TEMP:-/tmp}/ll-model"
BIN_DIR="$RUNTIME/bin"
MODEL="$MODEL_DIR/qwen2.5-0.5b-instruct-q4_k_m.gguf"
BIN="$BIN_DIR/llama-cli"
MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf?download=true"
MODEL_SHA="74a4da8c9fdbcd15bd1f6d01d621410d31c6fc00986f5eb687824e7b93d7a9db"
LLAMA_URL="https://github.com/ggml-org/llama.cpp/releases/download/b10621/llama-b10621-bin-ubuntu-x64.tar.gz"
LLAMA_SHA="91d7b03ddae498a39f28fdb85d84d2b4a0fd3838d10b4f897e0ef8975bb9b583"
mkdir -p "$MODEL_DIR" "$BIN_DIR" "$RUNTIME"
install_llama() {
  local archive="$RUNTIME/llama.tar.gz"
  local extract="$RUNTIME/llama-extract"
  local need_extract=0

  # Never trust a cached executable after a dependency failure. Rebuild the
  # complete runtime from the verified archive when dependencies are missing.
  if [ -x "$BIN" ]; then
    export LD_LIBRARY_PATH="$BIN_DIR:${LD_LIBRARY_PATH:-}"
    if ! "$BIN" --version >/dev/null 2>&1; then need_extract=1; fi
  else
    need_extract=1
  fi

  if [ "$need_extract" -eq 0 ]; then
    local missing
    missing=$(ldd "$BIN" 2>&1 | awk '/not found/{print $1}' | sort -u || true)
    [ -z "$missing" ] || need_extract=1
  fi

  if [ "$need_extract" -eq 1 ]; then
    curl -fsSL --retry 4 --retry-delay 2 "$LLAMA_URL" -o "$archive"
    echo "$LLAMA_SHA  $archive" | sha256sum -c -
    rm -rf "$extract" "$BIN_DIR"
    mkdir -p "$extract" "$BIN_DIR"
    tar -xzf "$archive" -C "$extract"
    local found src
    found=$(find "$extract" -type f -name llama-cli -print -quit)
    test -n "$found"
    src="$(dirname "$found")"
    cp "$found" "$BIN"
    # Preserve the complete runtime library set, including symlinks and
    # nested directories. Flattening is safe because the release uses SONAMEs
    # and avoids the previous partial-copy failure mode.
    find "$extract" -type f -o -type l | while IFS= read -r f; do
      case "$f" in
        *.so|*.so.*) cp -aL "$f" "$BIN_DIR/" ;;
      esac
    done
    chmod +x "$BIN"
  fi

  export LD_LIBRARY_PATH="$BIN_DIR:${LD_LIBRARY_PATH:-}"
  local missing_after
  missing_after=$(ldd "$BIN" 2>&1 | awk '/not found/{print $1}' | sort -u || true)
  if [ -n "$missing_after" ]; then
    echo "MISSING_SHARED_LIBRARIES:$missing_after" >&2
    return 1
  fi
  "$BIN" --version >/dev/null
}
install_model() {
  if [ -s "$MODEL" ]; then echo "$MODEL_SHA  $MODEL" | sha256sum -c - >/dev/null; return; fi
  curl -fsSL --retry 4 --retry-delay 2 "$MODEL_URL" -o "$MODEL"
  echo "$MODEL_SHA  $MODEL" | sha256sum -c -
}
install_llama
install_model
export LLAMA_BIN="$BIN"
export MODEL_PATH="$MODEL"
python3 - "$ROOT" "$RUNTIME/context.txt" <<'PY'
import json,sys,pathlib
root,out=sys.argv[1:]
q=json.load(open(root+'/swarm/autopilot/task-queue.json'))
completed={t['id'] for t in q['tasks'] if t['status']=='completed'}
active=next((t for t in q['tasks'] if t['status']=='pending' and all(d in completed for d in t['depends_on'])),None)
parts=[]
for name in ['SPEC.md','STATE.md','DECISIONS.md','CAPABILITIES.md','EVIDENCE.md']:
    p=pathlib.Path(root,name); parts.append(f'===== {name} =====\n'+p.read_text()[:12000])
parts.append('===== ACTIVE TASK =====\n'+json.dumps(active or {},ensure_ascii=False,indent=2))
parts.append('===== QUEUE =====\n'+json.dumps(q,ensure_ascii=False,indent=2))
pathlib.Path(out).write_text('\n\n'.join(parts),encoding='utf-8')
PY
python3 - "$RUNTIME/context.txt" "$RUNTIME/raw.txt" "$RUNTIME/agent.json" "$ROOT" <<'PY'
import json,os,subprocess,sys
ctx,raw,out,root=sys.argv[1:]
system='''You are an autonomous software project agent. Repository state is authoritative; chat history does not exist. Complete exactly ONE active task. You may propose edits only to project files and evidence/state files; NEVER edit .github workflows, secrets, release-gate rules, or security policy. Do not claim completion without concrete verification. Return ONLY one JSON object, no markdown. Schema: {"task_id":string,"status":"completed"|"blocked"|"failed","next_task":string|null,"summary":string,"edits":[{"path":string,"content":string}],"tests":[string],"evidence":[string],"failure_reason":string|null}. If no safe task can be completed, use blocked. Keep edits minimal and valid.'''
prompt=system+'\n\n'+open(ctx,encoding='utf-8').read()
cmd=[os.environ['LLAMA_BIN'],'-m',os.environ['MODEL_PATH'],'-p',prompt,'-n','1200','--temp','0.1','--no-display-prompt']
env=os.environ.copy(); env['LD_LIBRARY_PATH']=os.path.dirname(os.environ['LLAMA_BIN'])+':'+env.get('LD_LIBRARY_PATH','')
r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=600,env=env)
open(raw,'w',encoding='utf-8').write(r.stdout)
if r.returncode!=0: raise SystemExit('MODEL_EXIT:'+str(r.returncode))
text=r.stdout; start=text.find('{'); end=text.rfind('}')
if start<0 or end<=start: raise SystemExit('MODEL_NO_JSON')
obj=json.loads(text[start:end+1])
for k in ['task_id','status','next_task','summary','edits','tests','evidence','failure_reason']:
    if k not in obj: raise SystemExit('MISSING_FIELD:'+k)
if obj['status'] not in ('completed','blocked','failed'): raise SystemExit('BAD_STATUS')
json.dump(obj,open(out,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
PY
python3 - "$ROOT" "$RUNTIME/agent.json" "$ROOT/swarm/autopilot/last-agent-output.json" <<'PY'
import json,sys,subprocess,pathlib,datetime
root,agent,out=sys.argv[1:]
x=json.load(open(agent,encoding='utf-8'))
qpath=pathlib.Path(root,'swarm/autopilot/task-queue.json'); q=json.load(open(qpath,encoding='utf-8'))
task=next((t for t in q['tasks'] if t['id']==x['task_id']),None)
if not task or task['status']!='pending': raise SystemExit('INVALID_TASK')
for e in x['edits']:
    p=e.get('path','')
    if p.startswith('/') or '..' in pathlib.PurePosixPath(p).parts or p.startswith('.github/') or p.startswith('.git/'):
        raise SystemExit('FORBIDDEN_EDIT:'+p)
    if len(e.get('content',''))>100000: raise SystemExit('EDIT_TOO_LARGE')
    target=pathlib.Path(root,p); target.parent.mkdir(parents=True,exist_ok=True); target.write_text(e['content'],encoding='utf-8')
checks=[['bash',root+'/tests/test-structure.sh'],['bash',root+'/tests/test-adversarial.sh']]
if pathlib.Path(root,'projects/demo-project/scripts/release-gate.sh').exists(): checks.append(['bash',root+'/projects/demo-project/scripts/release-gate.sh'])
results=[]
for c in checks:
    r=subprocess.run(c,cwd=root,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=180)
    results.append({'command':' '.join(c),'returncode':r.returncode,'output':r.stdout[-4000:]})
    if r.returncode!=0:
        x['status']='failed'; x['failure_reason']='verification_failed'; x['tests']=results; json.dump(x,open(out,'w',encoding='utf-8'),ensure_ascii=False,indent=2); raise SystemExit(1)
if x['status']=='completed': task['status']='completed'
elif x['status']=='blocked': task['status']='blocked'
else: task['status']='failed'
task['attempts']=task.get('attempts',0)+1; task['updated_at']=datetime.datetime.now(datetime.timezone.utc).isoformat(); task['proof']='model-output-plus-independent-regression'
if x['next_task'] is not None and not any(t['id']==x['next_task'] for t in q['tasks']): raise SystemExit('INVALID_NEXT_TASK')
json.dump(q,open(qpath,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
state=pathlib.Path(root,'swarm/autopilot/runtime-state.json'); json.dump({'last_task':x['task_id'],'last_status':x['status'],'next_task':x['next_task'],'verified_tests':results},open(state,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
ev=pathlib.Path(root,'swarm/autopilot/evidence.jsonl'); record={'task_id':x['task_id'],'status':x['status'],'next_task':x['next_task'],'summary':x['summary'],'tests':results,'time':datetime.datetime.now(datetime.timezone.utc).isoformat()}
with ev.open('a',encoding='utf-8') as f: f.write(json.dumps(record,ensure_ascii=False)+'\n')
json.dump(x,open(out,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
PY
cat "$ROOT/swarm/autopilot/last-agent-output.json"
