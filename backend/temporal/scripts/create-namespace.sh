#!/bin/sh

set -eu

namespace=${DEFAULT_NAMESPACE:-default}
retention=${DEFAULT_NAMESPACE_RETENTION:-24h}
temporal_address=${TEMPORAL_ADDRESS:-temporal:7233}
max_attempts=${TEMPORAL_HEALTH_CHECK_MAX_ATTEMPTS:-30}
sleep_seconds=${TEMPORAL_HEALTH_CHECK_SLEEP_SECONDS:-2}
attempt=1

while ! temporal operator cluster health --address "$temporal_address"; do
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "Temporal did not become healthy after $max_attempts attempts."
    exit 1
  fi

  attempt=$((attempt + 1))
  sleep "$sleep_seconds"
done

if temporal operator namespace describe \
  --namespace "$namespace" \
  --address "$temporal_address" >/dev/null 2>&1; then
  echo "Temporal namespace '$namespace' already exists."
  exit 0
fi

temporal operator namespace create \
  --namespace "$namespace" \
  --retention "$retention" \
  --address "$temporal_address"

echo "Temporal namespace '$namespace' is ready."
