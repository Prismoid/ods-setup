#!/usr/bin/env bash
set -e

read -r -p "OPERATOR_CLIENT_ID: " OPERATOR_CLIENT_ID
read -r -p "OPERATOR_CLIENT_SECRET: " OPERATOR_CLIENT_SECRET

echo "2-1-1. アクセストークン取得"

ACCESS_TOKEN=$(curl -X POST "http://localhost:8080/auth/token/client" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-d '{
  "client_id": "'$OPERATOR_CLIENT_ID'",
  "client_secret": "'$OPERATOR_CLIENT_SECRET'"
}' | jq -r '.data.access_token')

echo "$ACCESS_TOKEN"

for METHOD in GET POST PUT DELETE; do
  echo
  echo "===== ${METHOD} ====="

  if [[ "${METHOD}" == "GET" ]]; then
    curl -i -X GET "http://localhost:8090/test" \
      -H 'api-key: 2dfd3409-ce01-4451-96fa-7e10c9681422y' \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      -H "X-ODS-UserId: 112233"
  else
    curl -i -X "${METHOD}" "http://localhost:8090/test" \
      -H 'api-key: 2dfd3409-ce01-4451-96fa-7e10c9681422y' \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      -H "X-ODS-UserId: 112233" \
      -H "Content-Type: application/json" \
      -d '{"userid":112233}'
  fi
done
