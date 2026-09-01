#!/usr/bin/env python3
"""Durable recovery policy for autonomous tasks.

A failed/blocked task is returned to pending while its retry budget remains.
After the budget is exhausted it stays failed and becomes a real blocker.
This policy never changes governance, security, or release rules.
"""
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QUEUE = ROOT / "swarm/autopilot/task-queue.json"
RESULT = ROOT / "swarm/autopilot/last-agent-output.json"
EVIDENCE = ROOT / "swarm/autopilot/evidence.jsonl"

q = json.loads(QUEUE.read_text(encoding="utf-8"))
x = json.loads(RESULT.read_text(encoding="utf-8"))
max_retries = int(q.get("policy", {}).get("max_retries", 3))
task = next((t for t in q["tasks"] if t.get("id") == x.get("task_id")), None)
if task is None:
    raise SystemExit("RECOVERY_UNKNOWN_TASK")

now = datetime.now(timezone.utc).isoformat()
status = x.get("status")
attempts = int(task.get("attempts", 0))

if status in ("blocked", "failed") and attempts < max_retries:
    task["status"] = "pending"
    task["recovery"] = {
        "action": "automatic_retry",
        "attempt": attempts,
        "max_retries": max_retries,
        "time": now,
        "reason": x.get("failure_reason") or status,
    }
    event = {
        "event": "automatic_retry",
        "task_id": task["id"],
        "attempt": attempts,
        "max_retries": max_retries,
        "time": now,
        "reason": x.get("failure_reason") or status,
    }
    with EVIDENCE.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False) + "\n")
elif status in ("blocked", "failed") and attempts >= max_retries:
    task["status"] = "failed"
    task["proof"] = "retry-limit-reached"

QUEUE.write_text(json.dumps(q, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"RECOVERY_POLICY: {task['id']} status={task['status']} attempts={attempts}/{max_retries}")
