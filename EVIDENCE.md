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
CLAIM: The baseline assurance suite passes in GitHub Actions.
EVIDENCE: Run `33484706739` shows successful Health check, Structure test, Adversarial test, Regression pass, report creation and artifact upload.
STATUS: VERIFIED

## E-006 — Scheduled continuity mechanism
CLAIM: The workflow contains scheduled and autonomous continuity mechanisms.
EVIDENCE: Assurance has weekly cron; Autopilot has scheduled fallback and direct self-dispatch. A configured trigger is not by itself proof of every future execution.
STATUS: CONFIGURED

## E-007 — Ω Autonomous Leadership Kernel assurance
CLAIM: The new leadership architecture is integrated and its automated verification suite passes in real GitHub Actions.
EVIDENCE: `Ω Assurance` Run `33538959880` (#111), commit `6e3bdca312579c5c59560952cc991e579cb9b99f`, completed with conclusion `success`. Job steps show PASS for Root Health, Root Structure, `Ω Autonomous leadership gate test`, Intent Gate, Intent Compiler, NBAG, Continuation, Adversarial, Project Factory, Demo verification, Autonomous loop smoke, Chaos/disaster drill, full Regression, report build and artifact upload.
ARTIFACT: `assurance-report`, ID `9812791836`, size 421 bytes, digest `sha256:b5c257845f159d75706f74ef68f9ef0595e108fb2d34a92bedfdc0de9dc4403a`, expires 2026-10-01.
STATUS: VERIFIED

## Evidence rule
A configured workflow or written policy is not evidence of execution. A successful Run/job/test and applicable artifact or runtime result are required before marking the corresponding capability VERIFIED. Mission completion requires mission-level evidence; passing Assurance alone does not prove `INTENT_ACHIEVED`.
