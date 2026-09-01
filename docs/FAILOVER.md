# FAILOVER MATRIX

## Failure: ChatGPT conversation disappears
Action: load AGENT.md + SPEC + STATE + DECISIONS + EVIDENCE + RUNBOOK; continue from NEXT_ACTION.

## Failure: Internet unavailable
Action: use local Git working copy and local Bash tests; preserve changes; sync later.

## Failure: GitHub write unavailable
Action: continue locally; create a checkpoint; retry when write access returns.

## Failure: GitHub Actions unavailable
Action: run the same scripts locally; mark CI evidence as stale; do not claim CI verification.

## Failure: artifact upload unavailable
Action: keep the local artifact and commit a manifest/hash when appropriate; do not claim downloadable CI artifact.

## Failure: hosting service unavailable
Action: use local build/preview or another VERIFIED host. Hosting is not part of the core project state.

## Failure: dependency/service changes pricing or limits
Action: freeze adoption, re-run capability proof, switch to verified alternative or local implementation.

## Failure: test environment differs
Action: identify environment-specific assumptions; keep tests portable; run both the project-native and CI paths when relevant.

## Failure recovery law
DIAGNOSE → PRESERVE EVIDENCE → LAST KNOWN GOOD → SAFE RETRY → VERIFIED ALTERNATIVE → LOCAL FALLBACK → RETEST → REGRESSION → UPDATE STATE.

Never convert a tool failure into a project failure unless the tool is itself the only verified implementation of an essential requirement and no safe fallback exists.
