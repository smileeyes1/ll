#!/usr/bin/env python3
"""Ω Autonomous Continuation Controller.

Decides whether the autonomous loop must continue immediately, stop safely,
or enter terminal verification. Leadership can block continuation before NBAG;
NBAG owns task selection when leadership authorizes execution.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QUEUE = ROOT / "swarm/autopilot/task-queue.json"
LEADERSHIP = ROOT / "swarm/autopilot/leadership-decision.json"
OUT = ROOT / "swarm/autopilot/continuation.json"

q = json.loads(QUEUE.read_text(encoding="utf-8"))
tasks = q.get("tasks", [])
done = {t.get("id") for t in tasks if t.get("status") == "completed"}
failed = [t for t in tasks if t.get("status") == "failed"]
pending = [t for t in tasks if t.get("status") == "pending"]
executable = [
    t for t in pending
    if all(dep in done for dep in t.get("depends_on", []))
]
lead = json.loads(LEADERSHIP.read_text(encoding="utf-8")) if LEADERSHIP.is_file() else None
lead_decision = lead.get("decision") if lead else "MISSING"

if lead_decision in ("SAFE_BLOCKED", "HUMAN_REQUIRED"):
    decision = "SAFE_BLOCKED"
    reason = "leadership_" + lead_decision.lower()
elif lead_decision not in ("PROCEED",):
    decision = "SAFE_BLOCKED"
    reason = "leadership_decision_missing_or_invalid"
elif failed:
    decision = "SAFE_BLOCKED"
    reason = "terminal_failed_task"
elif executable:
    decision = "CONTINUE"
    reason = "executable_work_remains"
elif pending:
    decision = "SAFE_BLOCKED"
    reason = "dependency_deadlock_or_unmet_dependency"
else:
    decision = "TERMINAL_CANDIDATE"
    reason = "no_pending_or_failed_tasks"

result = {
    "gate": "OMEGA_CONTINUATION",
    "decision": decision,
    "reason": reason,
    "leadership_decision": lead_decision,
    "executable_task_ids": [t.get("id") for t in executable],
    "pending_task_ids": [t.get("id") for t in pending],
    "failed_task_ids": [t.get("id") for t in failed],
    "rule": "CONTINUE_UNTIL_TERMINAL_OR_SAFE_BLOCKED",
}
OUT.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, ensure_ascii=False))
