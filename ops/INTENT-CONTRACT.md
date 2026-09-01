# Ω Intent Contract

Purpose: convert a human goal into durable project work without using chat history as project state.

## Source of truth
The repository is authoritative. Chat history is never required for recovery.

## Intent lifecycle
`RECEIVED -> NORMALIZED -> PLANNED -> EXECUTING -> VERIFIED -> RELEASED`

An intent is a durable JSON document under `ops/intents/inbox/`.

Required fields:
- `intent_id`
- `created_at`
- `goal`
- `acceptance_criteria`
- `source`
- `status`

The router must reject malformed intents. It must not silently invent acceptance criteria for high-risk changes.

## Execution rule
Once an intent is committed to the repository, automation owns the lifecycle. No human approval is required between tasks unless an explicit safety policy marks the intent as requiring approval.

## Safety
The intent router and agents may not modify CI governance, security policy, permissions, release gates, or secrets to make a task pass.

## Recovery
A new runner must be able to resume using only SPEC.md, STATE.md, DECISIONS.md, EVIDENCE.md, TASK_QUEUE, and the durable intent records.

## Chat boundary
ChatGPT is an optional intent-entry interface. The runtime must remain functional if the chat session disappears.
