# Runbook

## Fresh start
Read `AGENT.md`, `SPEC.md`, `STATE.md`, `DECISIONS.md`, `CAPABILITIES.md`, `EVIDENCE.md`.

## Resume after interruption
1. Read STATE.
2. Verify the last known-good commit.
3. Verify the latest CI/checkpoint evidence.
4. Inspect only the first incomplete task.
5. Continue without repeating completed work unless inputs changed or evidence was invalidated.

## Failure recovery
DIAGNOSE → PRESERVE EVIDENCE → TRY VERIFIED PRIMARY → TRY VERIFIED FALLBACK → LOCAL PATH → RECORD STATE.

## Release
Run the release gate. `GO` is forbidden when a required check, artifact, evidence item, or high-impact requirement is missing.
