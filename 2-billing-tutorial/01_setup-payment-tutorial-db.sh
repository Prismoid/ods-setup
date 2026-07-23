#!/usr/bin/env bash
set -euo pipefail

echo "1. データ提供者・利用者をDBに登録する。簡単のため、同一のIDとする。`uuidgen -t`が動く必要あり"
read -p "OPERATOR_ID を入力: " OPERATOR_ID
PAYMENT_SERVICE_ID=$(uuidgen -t)
PAYMENT_SERVICE_ID="57cc2dbe-7e8d-11f1-8c4f-6645bcee2088"
docker exec -it payment-db psql fastapi_db -U postgres -c "INSERT INTO payment_services VALUES ('$PAYMENT_SERVICE_ID', 'test_service', 'http://example.com/')"
docker exec -it payment-db psql fastapi_db -U postgres -c 'SELECT * FROM payment_services'

docker exec -it payment-db psql fastapi_db -U postgres -c "INSERT INTO payment_service_user_registrations VALUES ('$OPERATOR_ID', '$PAYMENT_SERVICE_ID', '$OPERATOR_ID', '$OPERATOR_ID')"
docker exec -it payment-db psql fastapi_db -U postgres -c '\x' -c 'SELECT * FROM payment_service_user_registrations'
