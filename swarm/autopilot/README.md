# Ω Autonomous Project OS — Zero-Intervention Policy

The repository is the durable source of truth. Chat history is not required for execution or recovery.

## Continuation contract

1. A scheduled or event-triggered GitHub Actions run reads `SPEC.md`, `STATE.md`, `DECISIONS.md`, `CAPABILITIES.md`, `EVIDENCE.md`, and `task-queue.json`.
2. It selects the first dependency-satisfied task.
3. The Model Runner executes exactly one task and returns machine-checkable JSON.
4. Independent regression tests verify the result before the checkpoint is committed.
5. A successful checkpoint dispatches the next assurance cycle automatically.
6. The next cycle repeats until no executable task remains.
7. Failures are recorded and handled by retry/recovery policy; the agent cannot weaken governance to make a task pass.

## Human interaction

No conversational approval is required between tasks. A human supplies the initial goal/specification and may later inspect the evidence, but the execution loop does not wait for chat confirmation.

## Safety boundary

The autonomous agent cannot modify `.github`, `.git`, secrets, security policy, or release-gate rules. High-impact irreversible operations remain explicitly gated.

## Definition of done

The system is not considered autonomous-release-ready until a live run proves: real model execution, real file change, independent verification, commit, automatic next-task dispatch, recovery after simulated agent loss, failover recovery, regression, artifact validity, and release/deploy verification.
