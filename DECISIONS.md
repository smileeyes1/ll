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

## D-007 — Autonomous Leadership is mandatory before NBAG
Reason: choosing a task is not enough; the system must first verify intent, success criteria, unknowns, authority, capability, risk, reversibility, evidence and stop conditions.
Invariant: NO LEADERSHIP DECISION → NO NBAG → NO EXECUTION.
Status: FROZEN

## D-008 — Human intervention is an exception, not the default
Reason: unnecessary questions destroy autonomy. Safe reversible assumptions are preferred and recorded. HUMAN_REQUIRED is allowed only for missing authority/secret, irreducible preference, or high-impact irreversible action that cannot be safely inferred.
Status: FROZEN

## D-009 — Re-evaluate after every material result
Reason: a plan is provisional. New evidence can change the best action. The system must return to Leadership → NBAG after execution/recovery instead of blindly following stale queue order.
Status: FROZEN

## D-010 — Completion is mission-level, not task-level
Reason: completing one task does not prove the user's intent. The loop stops only at a verified terminal outcome or a real SAFE_BLOCKED state with evidence.
Status: FROZEN
