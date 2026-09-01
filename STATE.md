# STATE

STATUS: INITIALIZED
VERSION: 2.0
LAST_GOOD_COMMIT: d9443ee045c01570a2a85bd1cddae54ed1147de7
LAST_VERIFIED_RUN: NONE
LAST_HEALTH: NOT_YET_RUN
LAST_REGRESSION: NOT_YET_RUN
LAST_ARTIFACT: NONE
BLOCKER: NONE
CURRENT_TASK: bootstrap assurance files and execute first CI proof
NEXT_ACTION: inspect CI run and record evidence
RECOVERY_POINT: d9443ee045c01570a2a85bd1cddae54ed1147de7

## Resume Contract
1. Read SPEC.md, STATE.md, DECISIONS.md, CAPABILITIES.md, EVIDENCE.md and RUNBOOK.md.
2. Verify repository default branch and latest commit.
3. Verify last known good commit before changing anything.
4. Run `bash scripts/health-check.sh`.
5. Run tests in `tests/`.
6. Continue from CURRENT_TASK; do not redo verified work without a changed input or contradictory evidence.
