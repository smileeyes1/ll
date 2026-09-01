# CAPABILITIES

Legend: VERIFIED = tested; CONFIGURED = implemented but current live proof still pending; AVAILABLE = documented but not yet tested; UNVERIFIED = do not depend on it.

| Capability | Status | Proof / policy |
|---|---|---|
| Public GitHub repository | VERIFIED | Repository metadata and successful writes |
| GitHub file read/write | VERIFIED | Multiple successful commits |
| Git versioning | VERIFIED | Main commit history is available and recoverable |
| GitHub Actions standard runner | VERIFIED | Multiple successful assurance runs |
| Pull-request CI | VERIFIED | Proof PR #1 executed successfully |
| Actions artifacts | VERIFIED | Assurance artifact exists with digest |
| Ω Autonomous Leadership Kernel | CONFIGURED | `AUTONOMY_CONSTITUTION.md`, `leadership-core.py`, mandatory Autopilot gate, dedicated tests; live CI verification required before VERIFIED |
| Dynamic leadership question packs | CONFIGURED | Delivery, security/privacy, external service/API, cost, destructive change, and user-experience packs implemented |
| HUMAN_REQUIRED exception gate | CONFIGURED | Executable tasks explicitly marked `requires_human=true` block autonomous execution; dedicated regression test added |
| Ω NBAG | CONFIGURED / PREVIOUSLY PARTIAL-PROVEN | Mandatory next-best-action gate; now downstream of Leadership Gate |
| Direct autonomous self-chain | CONFIGURED | Autopilot can dispatch the next Autopilot cycle; current architecture preserves single-writer concurrency |
| Scheduled GitHub Actions | CONFIGURED | Cron remains a fallback continuity mechanism |
| Local Bash/Python execution | VERIFIED by design | Assurance and leadership scripts use standard tooling only |
| GitHub Pages | AVAILABLE | Not a dependency until enabled and tested |
| Codespaces | AVAILABLE | Not a dependency |
| Cloudflare Pages | UNVERIFIED | Candidate fallback; no critical dependency |
| Netlify | UNVERIFIED | Candidate fallback; no critical dependency |
| Supabase | UNVERIFIED | Candidate backend; no critical dependency |

## Capability Proof Protocol
DISCOVER → CHECK CURRENT TERMS → CHECK PERMISSION → MINIMUM TEST → VERIFY RESULT → RECORD EVIDENCE → ADOPT OR REJECT.

A service or new subsystem may not be marked VERIFIED from code/configuration alone. A real test/run is required.
