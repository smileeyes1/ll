# Ω Autonomous Loop

This layer makes project continuity repository-driven rather than conversation-driven.

## Components
- `task-queue.json`: durable task graph.
- `agent-contract.md`: stateless agent contract.
- `orchestrator.sh`: advances only tasks whose dependencies are proven complete.
- `watchdog.sh`: expires stale leases for recovery.
- `chaos-test.sh`: controlled agent-loss and primary-path-loss drill.

## Important proof boundary
The orchestrator is currently a deterministic local coordinator. It does NOT pretend to be an LLM agent, and it does NOT autonomously invent arbitrary code changes. A future model runner can implement the Agent Contract while keeping the same durable state and gates.

No chat history is required to recover the queue.
