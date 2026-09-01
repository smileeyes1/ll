# DECISIONS

## D-001 — GitHub is the primary external source of truth
Reason: the target repository is public, accessible, versioned, and supports Git, Actions, Issues and artifacts.
Status: FROZEN

## D-002 — Local execution is the first fallback
Reason: loss of network or a cloud tool must not erase the ability to continue.
Status: FROZEN

## D-003 — No unverified service becomes a dependency
Reason: a service claim is not proof of availability, permission, or suitability.
Status: FROZEN

## D-004 — CI evidence is required for automated claims
Reason: a workflow definition alone does not prove execution.
Status: FROZEN

## D-005 — Scheduled assurance is used for continuity
Reason: periodic execution detects drift without requiring the same conversation to remain open.
Status: FROZEN

## D-006 — Optional services remain optional until Capability Proof passes
Candidates: GitHub Pages, Cloudflare Pages, Netlify, Supabase, Codespaces.
Status: UNVERIFIED / NOT REQUIRED
