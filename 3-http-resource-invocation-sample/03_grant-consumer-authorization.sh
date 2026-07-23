#!/usr/bin/env bash
set -e

read -r -p "FGA STORE_ID: " STORE_ID
read -r -p "FGA MODEL_ID: " MODEL_ID
read -r -p "OPERATOR_ID: " OPERATOR_ID

curl -i -X POST \
  "http://localhost:8083/stores/${STORE_ID}/write" \
  -H "Content-Type: application/json" \
  -d "{
    \"authorization_model_id\": \"${MODEL_ID}\",
    \"writes\": {
      \"tuple_keys\": [
        {
          \"user\": \"user:${OPERATOR_ID}\",
          \"relation\": \"member\",
          \"object\": \"group:endpoint-test-get\"
        },
        {
          \"user\": \"user:${OPERATOR_ID}\",
          \"relation\": \"member\",
          \"object\": \"group:endpoint-test-post\"
        },
        {
          \"user\": \"user:${OPERATOR_ID}\",
          \"relation\": \"member\",
          \"object\": \"group:endpoint-test-delete\"
        }
      ]
    }
  }"

echo
echo "GET、POST、DELETEの権限を付与しました。"
