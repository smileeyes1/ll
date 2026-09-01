# TOOL VERIFICATION PROTOCOL

## Purpose
Prevent an untested service, permission or free-tier assumption from becoming a project dependency.

## Required proof
For every candidate tool:
1. Availability: account/service is reachable.
2. Permission: required operation is allowed.
3. Capability: the exact needed operation works.
4. Persistence: the result survives the session/process where persistence matters.
5. Failure path: a controlled failure is detectable.
6. Cost: current free allowance is sufficient for the intended workload.
7. Evidence: record URL/reference, date, operation, result and limits.

## Adoption states
DISCOVERED → TESTING → VERIFIED → ADOPTED
or
DISCOVERED → TESTING → FAILED → FALLBACK

UNVERIFIED services never enter the critical path.

## Current policy
GitHub repository, Git writes, GitHub Actions, pull-request CI and Actions artifacts have real project evidence. Scheduled execution is configured and will be time-verified by its first scheduled run. Other services remain optional until their own capability proof is executed.

## Fallback order
1. Verified primary service.
2. Verified second service if available.
3. Local/offline implementation.
4. Manual recovery from last known good checkpoint.

The goal is continuity, not attachment to a vendor.
