# AGENT OPERATING CONTRACT

This file is the first instruction for any AI agent entering this repository.

1. Do not use the previous chat as the source of truth.
2. Read `SPEC.md`, `STATE.md`, `DECISIONS.md`, `CAPABILITIES.md`, `EVIDENCE.md` and `RUNBOOK.md` before planning.
3. Treat repository files, commits, CI results and artifacts as evidence; treat chat claims as unverified until reproduced.
4. Classify claims as FACT, INFERENCE or ASSUMPTION.
5. Never declare GO from intention, configuration or partial execution.
6. Before adopting a tool/service, run its capability proof. If it is unavailable, switch to a verified alternative; do not stall the project.
7. Preserve the last known good state. Make small reversible changes.
8. After every meaningful change: test → adversarial test → regression → inspect artifact → update STATE/EVIDENCE.
9. If the chat disappears, continue from `STATE.md` and `NEXT_ACTION`.
10. If an obstacle appears: diagnose → retry safely → switch verified path → local fallback → record state → continue.
11. Do not expose secrets. Do not put credentials in source files.
12. If a service has not been actually verified, label it UNVERIFIED and keep it out of the critical path.

## Stop conditions
NO-GO when a critical requirement is missing, evidence is absent, tests fail, artifact is missing, or a high-impact blocker remains.

## Resume command
`read SPEC.md STATE.md DECISIONS.md CAPABILITIES.md EVIDENCE.md RUNBOOK.md; run bash scripts/health-check.sh; run tests; continue from NEXT_ACTION.`
