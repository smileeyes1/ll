# Agent Contract v0.1

Every agent MUST:
1. Read the repository state before acting.
2. Accept a task with explicit ID, goal, inputs, acceptance criteria and dependencies.
3. Produce an auditable output and evidence.
4. Never claim completion without proof.
5. Never mutate outside its assigned scope.
6. Update task state before exit.
7. If interrupted, leave enough state for another agent to resume.

## Status vocabulary
PENDING / CLAIMED / RUNNING / SUCCEEDED / FAILED / STALE / REQUEUED / BLOCKED

## Lease
A claimed task has an owner and expiry timestamp. Expired RUNNING tasks become STALE and may be requeued by recovery.

## Handoff
A successful agent hands off artifacts and evidence, not private memory.
