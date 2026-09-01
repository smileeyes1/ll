# CAPABILITIES

Legend: VERIFIED = tested; AVAILABLE = documented but not yet tested; UNVERIFIED = do not depend on it.

| Capability | Status | Proof / policy |
|---|---|---|
| Public GitHub repository | VERIFIED | Repository metadata and successful writes |
| GitHub file read/write | VERIFIED | Multiple successful commits |
| Git versioning | VERIFIED | Main commit history is available and recoverable |
| GitHub Actions standard runner | VERIFIED | Runs 33484706739 and 33484726039 both succeeded |
| Pull-request CI | VERIFIED | Proof PR #1 executed successfully |
| Actions artifacts | VERIFIED | Artifact 9791290151 exists with SHA-256 digest |
| Scheduled GitHub Actions | CONFIGURED / TIME-PENDING | Weekly cron is present; first scheduled execution still pending |
| Local Bash execution | VERIFIED by design | Assurance scripts use Bash/Python standard tooling only |
| GitHub Pages | AVAILABLE | Public repo supports Pages on GitHub Free; not a dependency until enabled and tested |
| Codespaces | AVAILABLE | Free quota exists on GitHub Free; not a dependency |
| Cloudflare Pages | UNVERIFIED | Candidate fallback; no critical dependency |
| Netlify | UNVERIFIED | Candidate fallback; no critical dependency |
| Supabase | UNVERIFIED | Candidate backend; no critical dependency |

## Capability Proof Protocol
DISCOVER → CHECK CURRENT TERMS → CHECK PERMISSION → MINIMUM TEST → VERIFY RESULT → RECORD EVIDENCE → ADOPT OR REJECT.

A service may not be placed in the critical path while UNVERIFIED.
