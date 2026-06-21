#!/usr/bin/env bash
set -euo pipefail

ADMIN_ACCESS_TOKEN=$(
  curl -s -X POST "http://localhost:8082/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" \
    -d "username=admin" \
    -d "password=password" | jq -r .access_token
)

curl -X PUT "http://localhost:8082/admin/realms/master" \
  -H "Authorization: Bearer ${ADMIN_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"accessTokenLifespan": 300}'

echo $ADMIN_ACCESS_TOKEN
