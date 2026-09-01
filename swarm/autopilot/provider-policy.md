# Model Provider Policy

## Objective
The project must not depend on ChatGPT conversation memory or a paid OpenAI API subscription.

## Current provider
Provider-neutral deterministic runner. It can execute and checkpoint without an external AI service.

## AI provider rule
An AI provider may be plugged into `model-runner.sh` only after a live capability check succeeds. Provider credentials must be stored as GitHub Actions secrets, never committed.

## Important 2026 status
GitHub Models inference was retired on July 30, 2026. Therefore the project MUST NOT depend on GitHub Models or `actions/ai-inference`'s retired GitHub Models provider. GitHub Copilot is a separate route and requires its own authentication/licensing. See the current provider documentation before enabling it.

## Product behavior
The end user supplies a goal. The repository turns that goal into a durable task graph. The autonomous loop executes, verifies, repairs, packages, and publishes the resulting product without requiring the user to manage intermediate steps.
