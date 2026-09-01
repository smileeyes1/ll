# Agent Contract v1

An agent is stateless between executions. Repository state is authoritative.

## Input
SPEC.md, STATE.md, DECISIONS.md, CAPABILITIES.md, EVIDENCE.md, and one claimed task.

## Output
The agent MUST emit: task_id, status, changed_files, tests, evidence, next_task, failure_reason.

## Safety
An agent may not change release criteria, bypass required tests, erase evidence, or claim success without proof.

## Recovery
A missing/failed agent leaves its task recoverable. Expired leases are re-queued by the watchdog.
