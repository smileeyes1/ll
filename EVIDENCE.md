# EVIDENCE

## E-001 — Repository access
CLAIM: The target repository is reachable and writable by the connected GitHub integration.
EVIDENCE: Repository metadata returned public visibility, admin/maintain/push permissions, default branch `main`; README commit created successfully.
COMMIT: d9443ee045c01570a2a85bd1cddae54ed1147de7
STATUS: VERIFIED

## E-002 — GitHub Actions execution
CLAIM: GitHub Actions executes the assurance workflow.
EVIDENCE: Run `33484706739` on `main` completed with conclusion `success`; workflow `Ω Assurance` executed Health Check, Structure, Adversarial and Regression steps.
COMMIT: 5b44c8d7757b0d70b4e2d243021d5bc770ceedbe
STATUS: VERIFIED

## E-003 — Proof PR execution
CLAIM: The workflow also executes for pull requests.
EVIDENCE: Run `33484726039` for PR #1 completed with conclusion `success`.
COMMIT: 7242d5f91df9423cb42193ebbe8c5b1205d48f4a
STATUS: VERIFIED

## E-004 — Automated artifact
CLAIM: CI can produce a downloadable evidence artifact.
EVIDENCE: Artifact `assurance-report`, ID `9791290151`, exists for Run `33484706739`, size 321 bytes, SHA-256 `f15e5e82132be34bd68f68c3c35a6fd8a08855f86946e33ae5a75a9b21e1b2e7`, expiry 2026-10-01.
STATUS: VERIFIED

## E-005 — Assurance tests
CLAIM: The assurance suite passes in GitHub Actions.
EVIDENCE: Run `33484706739` shows successful Health check, Structure test, Adversarial test, Regression pass, report creation and artifact upload.
STATUS: VERIFIED

## E-006 — Scheduled continuity mechanism
CLAIM: The workflow contains a weekly scheduled trigger and a state checkpoint mechanism.
EVIDENCE: `.github/workflows/assurance.yml` contains a weekly cron and writes `ops/last-run.md` for scheduled/manual execution. A real scheduled execution is still pending because its first scheduled time has not yet occurred.
STATUS: CONFIGURED / NOT YET TIME-VERIFIED

## Evidence rule
A configured workflow is not evidence of execution. A successful Run, job result and artifact are required before marking CI VERIFIED.
