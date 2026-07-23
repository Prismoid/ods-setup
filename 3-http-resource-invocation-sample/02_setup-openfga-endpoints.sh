#!/usr/bin/env bash
set -e

read -r -p "FGA STORE_ID: " STORE_ID
read -r -p "FGA MODEL_ID: " MODEL_ID

curl -i -X POST \
  "http://localhost:8083/stores/${STORE_ID}/write" \
  -H "Content-Type: application/json" \
  -d "{
    \"authorization_model_id\": \"${MODEL_ID}\",
    \"writes\": {
      \"tuple_keys\": [
        {
          \"user\": \"group:endpoint-test-get#member\",
          \"relation\": \"can_access\",
          \"object\": \"endpoint:test.get\"
        },
        {
          \"user\": \"group:endpoint-test-post#member\",
          \"relation\": \"can_access\",
          \"object\": \"endpoint:test.post\"
        },
        {
          \"user\": \"group:endpoint-test-put#member\",
          \"relation\": \"can_access\",
          \"object\": \"endpoint:test.put\"
        },
        {
          \"user\": \"group:endpoint-test-delete#member\",
          \"relation\": \"can_access\",
          \"object\": \"endpoint:test.delete\"
        }
      ]
    }
  }"

echo
echo "OpenFGAのエンドポイント設定が完了しました。"
