#!/usr/bin/env bash
set -euo pipefail

cd SDK-docker-compose

docker network create shared-network-ods || true
docker compose up -d

cd setup
bash setup_l3.sh
cd ..

docker compose -f l3/docker-compose.yml up -d

cd setup
bash setup_l2.sh
cd ..

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
