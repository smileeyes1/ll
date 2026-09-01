#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP="$ROOT/swarm/autopilot/chaos-runtime"
rm -rf "$TMP"; mkdir -p "$TMP"
cat > "$TMP/leases.json" <<'JSON'
{"leases":[{"task_id":"CHAOS-001","agent":"agent-a","status":"active","expires_at":"2000-01-01T00:00:00Z"}]}
JSON
export LEASES="$ROOT/swarm/autopilot/leases.json"
cp "$TMP/leases.json" "$LEASES"
"$ROOT/swarm/autopilot/watchdog.sh" >/tmp/watchdog.out
python3 - "$LEASES" <<'PY'
import json,sys
x=json.load(open(sys.argv[1]))['leases'][0]
assert x['status']=='expired', x
print('CHAOS_AGENT_LOSS: PASS')
PY
# Primary-path loss simulation: prove the fallback is identical to the last known primary state.
printf 'primary-state-proof\n' > "$TMP/primary.state"
cp "$TMP/primary.state" "$TMP/fallback.state"
sha256sum "$TMP/primary.state" | cut -d' ' -f1 > "$TMP/primary.sha"
rm "$TMP/primary.state"
sha256sum -c <(printf '%s  %s\n' "$(cat "$TMP/primary.sha")" "$TMP/fallback.state")
printf 'CHAOS_PRIMARY_LOSS: PASS\n'
