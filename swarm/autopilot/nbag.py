#!/usr/bin/env python3
"""Ω NBAG — Next-Best-Action Gate.

Selects exactly one executable task from durable repository state before any
agent execution. The decision is evidence: candidates, scores and rejection
reasons are written to a durable JSON record. Execution is forbidden without
this record.
"""
from __future__ import annotations
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QUEUE = ROOT / "swarm/autopilot/task-queue.json"
DECISION = ROOT / "swarm/autopilot/next-best-action.json"
INTENT = ROOT / "INTENT.md"
STATE = ROOT / "STATE.md"

q = json.loads(QUEUE.read_text(encoding="utf-8"))
done = {t["id"] for t in q["tasks"] if t.get("status") == "completed"}
executable = [
    t for t in q["tasks"]
    if t.get("status") == "pending"
    and all(d in done for d in t.get("depends_on", []))
]

# Stable policy: unblock the intent first, then verification/release work,
# while penalizing retries and dependency breadth. This is deterministic,
# auditable, and cannot silently devolve to queue order.
ROLE_VALUE = {
    "orchestrator": 100,
    "planner": 90,
    "builder": 80,
    "tester": 70,
    "adversary": 65,
    "reviewer": 60,
    "release": 50,
}

def score(t: dict) -> tuple[int, list[str]]:
    reasons = []
    s = ROLE_VALUE.get(t.get("role", ""), 40)
    reasons.append(f"role_value={s}")
    goal = (t.get("goal") or "").lower()
    intent_terms = ("intent", "autonomy", "release", "deploy", "recovery", "failover", "test", "artifact")
    hits = sum(1 for term in intent_terms if term in goal)
    s += hits * 6
    if hits:
        reasons.append(f"intent_alignment=+{hits*6}")
    attempts = int(t.get("attempts", 0))
    s -= attempts * 8
    if attempts:
        reasons.append(f"retry_penalty=-{attempts*8}")
    deps = len(t.get("depends_on", []))
    s -= deps
    if deps:
        reasons.append(f"dependency_cost=-{deps}")
    return s, reasons

ranked = []
for t in executable:
    s, reasons = score(t)
    ranked.append({"task_id": t["id"], "score": s, "reasons": reasons})
ranked.sort(key=lambda x: (-x["score"], x["task_id"]))
selected = ranked[0]["task_id"] if ranked else None
now = datetime.now(timezone.utc).isoformat()
record = {
    "schema_version": "1.0",
    "gate": "OMEGA_NBAG",
    "decision_time": now,
    "intent_present": INTENT.is_file() and INTENT.stat().st_size > 0,
    "state_present": STATE.is_file() and STATE.stat().st_size > 0,
    "candidate_count": len(ranked),
    "candidates": ranked,
    "selected_task_id": selected,
    "decision": "EXECUTE" if selected else "NO_EXECUTABLE_ACTION",
    "rule": "NO_VERIFIED_DECISION_NO_EXECUTION",
}
DECISION.write_text(json.dumps(record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(record, ensure_ascii=False))
