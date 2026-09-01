# Ω Project OS v2.0

## Mission
Make every project independently resumable, verifiable, auditable, and runnable without relying on chat history.

## Non-negotiable rule
Chat history is NEVER the source of truth. The repository is the source of truth.

## Operating loop
UNDERSTAND → SPECIFY → CHECK CAPABILITIES → PLAN → EXECUTE → CHECKPOINT → TEST → ADVERSARIAL TEST → REPAIR → REGRESSION → VERIFY ARTIFACTS → RELEASE GATE → RECORD STATE.

## Truth levels
- FACT: directly proven by a file, command, CI run, artifact, or external authoritative source.
- INFERENCE: conclusion derived from facts.
- ASSUMPTION: not yet proven; never present it as fact.

## Continuity
A new agent must read, in order:
1. AGENT.md
2. SPEC.md
3. STATE.md
4. DECISIONS.md
5. CAPABILITIES.md
6. EVIDENCE.md
7. RUNBOOK.md
8. latest CI/checkpoint evidence

Then it resumes from STATE.md. It must not ask the previous conversation what happened.

## Failure policy
A tool failure is a routing event, not a project failure. Diagnose → preserve evidence → try verified alternative → use local path where possible → update state. Never silently lower acceptance criteria.

## Adoption policy
No service becomes a dependency until a capability proof succeeds. Free availability alone is insufficient.

## Release policy
GO requires: valid SPEC, coherent STATE, required tests passing, adversarial tests passing, regression passing, required artifacts present and non-empty, evidence recorded, no unresolved high-impact blocker, and a reproducible commit.

## Independence target
The project must remain useful if ChatGPT, another AI model, a cloud IDE, or one external service becomes unavailable. Replaceable agents and tools; durable project state.
