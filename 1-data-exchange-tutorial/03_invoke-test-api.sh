#!/usr/bin/env bash
set -e

read -p "OPERATOR_CLIENT_SECRET を入力: " OPERATOR_CLIENT_SECRET

echo "2-1-1. アクセストークン取得"

ACCESS_TOKEN=$(curl -X POST "http://localhost:8080/auth/token/client" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-d '{
  "client_id": "login_user_client_id_sample",
  "client_secret": "'$OPERATOR_CLIENT_SECRET'"
}' | jq -r '.data.access_token')

echo "$ACCESS_TOKEN"

curl -i -X POST "http://localhost:8090/test" \
  -H 'api-key: 2dfd3409-ce01-4451-96fa-7e10c9681422y' \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H 'X-ODS-UserId: 112233' \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{"userid":112233}'
