#!/usr/bin/env bash
set -euo pipefail

docker exec -it payment-db psql fastapi_db -U postgres -c "
SELECT
    tracking_id,
    provider_id,
    consumer_id,
    data_id,
    consumer_exchange_status,
    provider_exchange_status,
    l2_http_status,
    calculated_amount,
    created_at
FROM transactions
ORDER BY created_at DESC
LIMIT 10;
"
