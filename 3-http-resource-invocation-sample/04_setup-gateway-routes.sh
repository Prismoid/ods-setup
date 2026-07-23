#!/usr/bin/env bash
set -e

GATEWAY_URL="http://localhost:8090"
GATEWAY_API_KEY="your-secret-management-api-key"

read -r -p "転送先URI [e.g., http://host.docker.internal:5050/test]: " UPSTREAM_URI

for METHOD in GET POST PUT DELETE; do
  METHOD_LOWER=$(echo "${METHOD}" | tr '[:upper:]' '[:lower:]')
  ROUTE_ID="route-test-${METHOD_LOWER}"

  echo
  echo "${METHOD}ルートを登録します。"

  curl -i -X POST \
    "${GATEWAY_URL}/actuator/gateway/routes/${ROUTE_ID}" \
    -H "Content-Type: application/json" \
    -H "X-API-KEY: ${GATEWAY_API_KEY}" \
    -d "{
      \"id\": \"${ROUTE_ID}\",
      \"uri\": \"${UPSTREAM_URI}\",
      \"predicates\": [
        {
          \"name\": \"Path\",
          \"args\": {
            \"_genkey_0\": \"/test**\"
          }
        },
        {
          \"name\": \"Method\",
          \"args\": {
            \"_genkey_0\": \"${METHOD}\"
          }
        }
      ],
      \"metadata\": {
        \"endpointId\": \"test.${METHOD_LOWER}\"
      }
    }"
done

echo
echo "Gatewayの設定を反映します。"

curl -i -X POST \
  "${GATEWAY_URL}/actuator/gateway/refresh" \
  -H "X-API-KEY: ${GATEWAY_API_KEY}"

echo
echo "Gatewayルートの登録が完了しました。"
