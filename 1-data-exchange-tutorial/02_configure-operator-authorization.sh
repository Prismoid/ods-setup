#!/usr/bin/env bash
set -e

read -r -p "FGA STORE_ID を入力(SDK-docker-compose/l2/docker-compose.yml内のFGA_STORE_ID の設定値): " USER_STORE_ID

curl -i -X POST \
  "http://localhost:8083/stores/$USER_STORE_ID/write" \
  -H "Content-Type: application/json" \
  -d '{
  "writes": {
    "tuple_keys": [
      { "user": "group:endpoint-test-get#member",    "relation": "can_access", "object": "endpoint:test.get" },
      { "user": "group:endpoint-test-post#member",   "relation": "can_access", "object": "endpoint:test.post" },
      { "user": "group:endpoint-test-put#member",    "relation": "can_access", "object": "endpoint:test.put" },
      { "user": "group:endpoint-test-delete#member", "relation": "can_access", "object": "endpoint:test.delete" }
    ],
    "on_duplicate": "ignore"
  }
}'

echo ""
read -r -p "USER_STORE_ID を入力(SDK-docker-compose/l2/docker-compose.yml内のFGA_STORE_ID の設定値): " USER_STORE_ID
read -r -p "USER_MODEL_ID を入力(SDK-docker-compose/l2/docker-compose.yml内のFGA_MODEL_ID の設定値): " USER_MODEL_ID
read -r -p "OPERATOR_ID を入力(05_run-turorial.sh の最後の出力結果): " OPERATOR_ID

curl -i -X POST "http://localhost:8083/stores/$USER_STORE_ID/write" \
-H "Content-Type: application/json" \
-d '{
  "authorization_model_id": "'$USER_MODEL_ID'",
  "writes": {
    "tuple_keys": [
      {
        "user": "user:'$OPERATOR_ID'",
        "relation": "member",
        "object": "group:endpoint-test-post"
      }
    ]
  }
}'

curl -X POST\
    -H "Content-Type: application/json"\
    -H "X-API-KEY: your-secret-management-api-key"\
    -d '{
    "id": "route01",
    "uri": "http://mockoon:4011/test",
    "predicates": [{
        "name": "Path",
        "args": {
        "_genkey_0": "/test**"
         }
     },
      { 
        "name": "Method",
        "args": { 
        "_genkey_0": "POST"
         }
      }],
    "metadata": {
      "endpointId": "test.post"
     }    
    }'\
    http://localhost:8090/actuator/gateway/routes/route01
