# CAPABILITIES

Legend: VERIFIED = tested; CONFIGURED = implemented but live proof pending; AVAILABLE = documented but not yet tested; UNVERIFIED = do not depend on it.

| Capability | Status | Proof / policy |
|---|---|---|
| Public GitHub repository | VERIFIED | Repository metadata and successful writes |
| GitHub file read/write | VERIFIED | Multiple successful commits |
| Git versioning | VERIFIED | Main commit history is available and recoverable |
| GitHub Actions standard runner | VERIFIED | Multiple successful assurance runs |
| Pull-request CI | VERIFIED | Proof PR #1 executed successfully |
| Actions artifacts | VERIFIED | Assurance artifacts exist with digests |
| Ω Autonomous Leadership Kernel | VERIFIED | Assurance Run 33538959880 #111: leadership gate test + full regression successful |
| Dynamic leadership question packs | VERIFIED | Covered by `tests/test-leadership.sh` in Run 33538959880 |
| HUMAN_REQUIRED exception gate | VERIFIED | Dedicated regression case passed in Run 33538959880 |
| Leadership-aware Continuation | VERIFIED | `tests/test-continuation.sh` passed in Run 33538959880 |
| Ω NBAG | VERIFIED IN ASSURANCE | NBAG decision gate tests passed in Run 33538959880; live mission effectiveness remains mission-specific |
| Direct autonomous self-chain | CONFIGURED / LIVE-E2E-PENDING | Autopilot can self-dispatch; require live chained cycle evidence before full VERIFIED |
| Scheduled GitHub Actions | CONFIGURED | Cron remains a fallback continuity mechanism |
| Local Bash/Python execution | VERIFIED by design | Assurance and leadership scripts use standard tooling only |
| GitHub Pages | AVAILABLE | Not a dependency until enabled and tested |
| Codespaces | AVAILABLE | Not a dependency |
| Cloudflare Pages | UNVERIFIED | Candidate fallback; no critical dependency |
| Netlify | UNVERIFIED | Candidate fallback; no critical dependency |
| Supabase | UNVERIFIED | Candidate backend; no critical dependency |

## Capability Proof Protocol
DISCOVER → CHECK CURRENT TERMS → CHECK PERMISSION → MINIMUM TEST → VERIFY RESULT → RECORD EVIDENCE → ADOPT OR REJECT.

A service or subsystem may not be marked VERIFIED from code/configuration alone. A real test/run is required. Passing generic Assurance proves the subsystem mechanics, not the completion of every future mission.
