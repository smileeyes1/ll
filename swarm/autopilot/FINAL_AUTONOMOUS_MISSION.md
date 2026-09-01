# Ω FINAL AUTONOMOUS MISSION

## Objective
Operate this repository as an autonomous production system without operational dependence on ChatGPT, phone, or conversational approval between stages.

## Rules
1. Repository state is the sole durable source of truth. Read SPEC, STATE, DECISIONS, TASK QUEUE, and EVIDENCE before every cycle.
2. If an executable task exists, execute it automatically; never wait for conversational confirmation.
3. Use a real Model Runner when needed, with provider fallback where available. Never label deterministic execution as AI.
4. For every task: understand → execute → test → diagnose/fix → retest → evidence → checkpoint → commit.
5. After success, update STATE, select the next ready task, and dispatch the next cycle automatically.
6. On agent failure: lease/watchdog → recovery → requeue → alternate agent/provider → independent verification.
7. On primary-path failure: backup → failover → restore → integrity check → resume.
8. Run regression, adversarial, chaos, and artifact validation; never bypass the release gate.
9. Agents cannot elevate permissions, disable tests, alter security policy, release criteria, or evidence.
10. Prevent infinite loops, duplicate work, fabricated success, and claims without evidence.
11. Create required subtasks automatically when needed to reach the goal.
12. When requirements are complete: build → release gate → deploy → smoke test → record final artifact/link.
13. On failure: diagnose → repair → retest → fallback → resume, without waiting for the user.
14. New agents must be able to resume entirely from repository state; chat memory is non-authoritative.
15. Never declare COMPLETE or GO without verifiable evidence.

## Terminal conditions
A. COMPLETE + RELEASED, or
B. genuinely BLOCKED after bounded recovery attempts, with the blocker, evidence, and recovery attempts recorded.

## Zero-intervention requirement
No human approval is required between executable stages. The initial goal/specification is the only required human input. The system must continue through its own scheduler/event triggers until a terminal condition is reached.

## Safety boundary
Irreversible/high-impact actions may remain explicitly gated. The system must not remove its own safety controls merely to achieve completion.
