# CAPABILITIES

Legend: VERIFIED = tested; AVAILABLE = documented but not yet tested in this project; UNVERIFIED = do not depend on it.

| Capability | Status | Proof / policy |
|---|---|---|
| Public GitHub repository | VERIFIED | Repository metadata and successful write commit |
| GitHub file read/write | VERIFIED | README commit created successfully |
| Git versioning | VERIFIED | Commit d9443ee... exists |
| GitHub Actions standard runner | AVAILABLE | Official GitHub documentation; first project Run is required before marking VERIFIED |
| Scheduled GitHub Actions | AVAILABLE | Workflow configured; first scheduled/manual Run is required |
| Actions artifacts | AVAILABLE | Workflow configured; first successful artifact upload required |
| Local Bash execution | VERIFIED by design | Health script has no third-party dependency |
| GitHub Pages | AVAILABLE | Public repo supports Pages on GitHub Free; NOT a dependency until enabled and tested |
| Codespaces | AVAILABLE | Free quota exists on GitHub Free; NOT a dependency |
| Cloudflare Pages | UNVERIFIED | Candidate fallback; no dependency until capability proof |
| Netlify | UNVERIFIED | Candidate fallback; no dependency until capability proof |
| Supabase | UNVERIFIED | Candidate backend; no dependency until capability proof |

## Capability Proof Protocol
DISCOVER → CHECK CURRENT TERMS → CHECK PERMISSION → MINIMUM TEST → VERIFY RESULT → RECORD EVIDENCE → ADOPT OR REJECT.

A service may not be placed in the critical path while UNVERIFIED.
