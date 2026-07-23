#!/usr/bin/env bash
set -euo pipefail

read -r -p "TRACKING_ID を入力: " TRACKING_ID

if [[ -z "$TRACKING_ID" ]]; then
  echo "TRACKING_ID が入力されていません。"
  exit 1
fi

docker exec -it payment-db \
  psql fastapi_db -U postgres -v ON_ERROR_STOP=1 -c "
UPDATE transactions
SET
    consumer_exchange_status = 'completed',
    provider_exchange_status = 'completed'
WHERE tracking_id = '$TRACKING_ID';
"
