# Ω Autonomous Swarm v0.1

The swarm is repository-state driven. Chat history is not an input.

## Roles
- orchestrator: dispatches tasks and enforces contracts
- planner: decomposes goals
- builder: produces artifacts
- tester: runs verification
- adversary: attempts to break assumptions
- reviewer: evaluates evidence
- recovery: requeues stale work and restores from backup
- release: evaluates the gate

## Durable state
- `swarm/tasks/` is the durable queue.
- `swarm/agents/` contains role contracts.
- `swarm/runs/` contains execution evidence.
- `swarm/failover/` contains recovery drills.

No role may treat chat memory as authoritative.
