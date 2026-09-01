# Failover Drill v0.1

## Objective
Prove that loss of the primary execution path does not destroy durable project state.

## Controlled drill
1. Mark primary executor unavailable.
2. Do not modify SPEC, STATE, DECISIONS or EVIDENCE to hide the failure.
3. Recovery agent identifies the stale task.
4. Requeue the task with a new owner.
5. Continue using repository state.
6. Verify artifact integrity and regression.
7. Record the complete incident.

## PASS criteria
- Primary failure is detected.
- Task is not lost.
- Ownership can move to a replacement agent.
- No chat context is required.
- Final artifact and evidence remain recoverable.

## Current status
DRILL DESIGNED — EXECUTION PENDING.
