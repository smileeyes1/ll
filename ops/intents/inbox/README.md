# Intent Inbox

Place one JSON intent per file in this directory. A push to this directory starts the intent router.

Example:
```json
{
  "intent_id": "INTENT-001",
  "created_at": "2026-09-01T00:00:00Z",
  "source": "user",
  "goal": "Build the requested product",
  "acceptance_criteria": ["usable", "tested", "release-gated"],
  "status": "received"
}
```

Processed intents are moved to `ops/intents/processed/` with evidence. The repository remains the durable source of truth.
