#!/usr/bin/env bash
set -euo pipefail

cd SDK-docker-compose/L3-identity-component
cd scripts

echo "------------------------------------------------------------"
echo "1.1. 認証情報の入力"
echo "------------------------------------------------------------"

read -rp "SYSTEM_CLIENT_SECRET: " SYSTEM_CLIENT_SECRET
read -rp "API_AUTHZ_STORE_ID: " API_AUTHZ_STORE_ID

if [ -z "${SYSTEM_CLIENT_SECRET}" ]; then
  echo "ERROR: SYSTEM_CLIENT_SECRET is required."
  exit 1
fi

if [ -z "${API_AUTHZ_STORE_ID}" ]; then
  echo "ERROR: API_AUTHZ_STORE_ID is required."
  exit 1
fi



echo "------------------------------------------------------------"
echo "2-1-1. L3 APIアクセストークンの取得"
echo "------------------------------------------------------------"

TOKEN_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/token/client" \
    -H "Content-Type: application/json" \
    -H "API-Key: API-Key-Sample" \
    -d '{
      "client_id": "system-auth-sample",
      "client_secret": "'"${SYSTEM_CLIENT_SECRET}"'"
    }'
)"

ACCESS_TOKEN="$(
  echo "${TOKEN_RESPONSE}" | jq -r '.data.access_token'
)"

export ACCESS_TOKEN

echo "ACCESS_TOKEN=${ACCESS_TOKEN}"


LOGIN_USER_ID="login_user_id_sample_$(date +%Y%m%d%H%M%S)"

echo
echo "------------------------------------------------------------"
echo "2-1-2. 事業者情報の登録"
echo "------------------------------------------------------------"
echo "以下のサンプル事業者を L3 API に登録します。"
echo
echo "login_user_id       : ${LOGIN_USER_ID}"
echo "operator_name       : サンプル株式会社"
echo "operator_address    : 試験県サンプル市examビル1F"
echo "open_operator_id    : 1234567890120"
echo "global_operator_id  : 123456789TT234567890"
echo "effective_start_date: 2000-01-01"
echo "effective_end_date  : 9999-12-31"
echo

OPERATOR_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/account/operator" \
    -H "Content-Type: application/json" \
    -H "API-Key: API-Key-Sample" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{
      "login_user_id": "'"${LOGIN_USER_ID}"'",
      "operator_name": "サンプル株式会社",
      "operator_address": "試験県サンプル市examビル1F",
      "open_operator_id": "1234567890120",
      "global_operator_id": "123456789TT234567890",
      "effective_start_date": "2000-01-01",
      "effective_end_date": "9999-12-31",
      "create_password_flag": true,
      "password_temporary_flag": false
    }'
)"

echo "${OPERATOR_RESPONSE}" | jq .

OPERATOR_ID="$(
  echo "${OPERATOR_RESPONSE}" | jq -r '.data.operator_id'
)"

OPERATOR_PASSWORD="$(
  echo "${OPERATOR_RESPONSE}" | jq -r '.data.password'
)"

export LOGIN_USER_ID
export OPERATOR_ID
export OPERATOR_PASSWORD

echo
echo "LOGIN_USER_ID=${LOGIN_USER_ID}"
echo "  - 登録されたログインユーザー ID です。"
echo
echo "OPERATOR_ID=${OPERATOR_ID}"
echo "  - 登録された事業者を識別する ID です。"
echo
echo "OPERATOR_PASSWORD='${OPERATOR_PASSWORD}'"
echo "  - 作成されたログインユーザーの初期パスワードです。"
echo "------------------------------------------------------------"



echo
echo "------------------------------------------------------------"
echo "2-1-3. 事業者情報取得"
echo "------------------------------------------------------------"
echo "登録した事業者情報を取得します。"
echo
echo "operator_id: ${OPERATOR_ID}"
echo

curl -s -X GET "http://localhost:8080/account/operator/${OPERATOR_ID}" \
  -H "Content-Type: application/json" \
  -H "API-Key: API-Key-Sample" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  | jq .


echo
echo "------------------------------------------------------------"
echo "2-1-4. 事業者クライアントID発行"
echo "------------------------------------------------------------"
echo "事業者用のクライアントIDを発行します。"
echo

OPERATOR_CLIENT_ID="login_user_client_id_sample_$(date +%s)"
OPERATOR_OPEN_SYSTEM_ID="login_user_open_system_id_sample_$(date +%s)"

OPERATOR_CLIENT_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/clients" \
    -H "Content-Type: application/json" \
    -H "API-Key: API-Key-Sample" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{
      "flow_type": "client_credentials",
      "client_id": "'"${OPERATOR_CLIENT_ID}"'",
      "name": "サンプル株式会社クライアントID",
      "description": "サンプル株式会社クライアントID",
      "operator_id": "'"${OPERATOR_ID}"'",
      "open_system_id": "'"${OPERATOR_OPEN_SYSTEM_ID}"'"
    }'
)"

echo "$OPERATOR_CLIENT_RESPONSE" | jq .

OPERATOR_CLIENT_UUID="$(echo "$OPERATOR_CLIENT_RESPONSE" | jq -r '.data.client_uuid // empty')"

if [ -z "$OPERATOR_CLIENT_UUID" ]; then
  echo
  echo "ERROR: 事業者クライアントIDの発行に失敗しました。"
  exit 1
fi

echo
echo "OPERATOR_CLIENT_ID=${OPERATOR_CLIENT_ID}"
echo "OPERATOR_CLIENT_UUID=${OPERATOR_CLIENT_UUID}"


echo
echo "------------------------------------------------------------"
echo "2-1-5. 事業者クライアントシークレット取得"
echo "------------------------------------------------------------"
echo "事業者クライアントシークレットを取得します。"
echo
echo "operator_client_uuid: ${OPERATOR_CLIENT_UUID}"
echo

OPERATOR_CLIENT_SECRET_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/clients/secret/${OPERATOR_CLIENT_UUID}" \
    -H "API-Key: API-Key-Sample" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
)"

echo "$OPERATOR_CLIENT_SECRET_RESPONSE" | jq .

OPERATOR_CLIENT_SECRET="$(echo "$OPERATOR_CLIENT_SECRET_RESPONSE" | jq -r '.data.client_secret')"

echo
echo "OPERATOR_CLIENT_SECRET=${OPERATOR_CLIENT_SECRET}"


echo
echo "------------------------------------------------------------"
echo "3.0. API認可用の入力値設定"
echo "------------------------------------------------------------"
echo "以降の手順で使用する SYSTEM_CLIENT_SECRET / API-Key / client_id を設定します。"
echo
echo "API-Key と client_id は default と入力すると以下を使用します。"
echo "  API-Key  : API-Key-Sample"
echo "  client_id: system-auth-sample"
echo

DEFAULT_SYSTEM_CLIENT_SECRET="$(
  awk -F': ' '/KEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRET:/ {print $2}' ../../l3/docker-compose.yml | tr -d '"'
)"

read -rp "SYSTEM_CLIENT_SECRET [l3/docker-compose.yml の KEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRET]: " SYSTEM_CLIENT_SECRET
SYSTEM_CLIENT_SECRET="${SYSTEM_CLIENT_SECRET:-${DEFAULT_SYSTEM_CLIENT_SECRET}}"

read -rp "USER_STORE_ID [l2/docker-compose.yml の FGA_STORE_ID]: " USER_STORE_ID

read -rp "API-Key [default]: " SYSTEM_API_KEY
if [ "${SYSTEM_API_KEY}" = "default" ] || [ -z "${SYSTEM_API_KEY}" ]; then
    SYSTEM_API_KEY="API-Key-Sample"
fi

read -rp "client_id [default]: " SYSTEM_CLIENT_ID
if [ "${SYSTEM_CLIENT_ID}" = "default" ] || [ -z "${SYSTEM_CLIENT_ID}" ]; then
  SYSTEM_CLIENT_ID="system-auth-sample"
fi

if [ -z "${SYSTEM_CLIENT_SECRET}" ]; then
  echo "ERROR: SYSTEM_CLIENT_SECRET is required."
  exit 1
fi

export SYSTEM_CLIENT_SECRET
export SYSTEM_API_KEY
export SYSTEM_CLIENT_ID

echo
echo "SYSTEM_CLIENT_SECRET=${SYSTEM_CLIENT_SECRET}"
echo "SYSTEM_API_KEY=${SYSTEM_API_KEY}"
echo "SYSTEM_CLIENT_ID=${SYSTEM_CLIENT_ID}"
echo "------------------------------------------------------------"
    
echo "--- OpenFGAストアへのタプル登録"

curl -i -X POST \
  http://localhost:8083/stores/$USER_STORE_ID/write \
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


echo "事業者への認可付与"


# "curl -i -X POST "http://localhost:8083/stores/$USER_STORE_ID/write" \-H "Content-Type: application/json" \-d '{
#        "authorization_model_id": "'$USER_MODEL_ID'",
#        "writes": {
#          "tuple_keys": [
#            {
#              "user": "user:'$OPERATOR_ID'",
#              "relation": "member",
#              "object": "group:endpoint-test-post"
#            }
#          ]
#        }
#      }'"


read -rp "USER_STORE_ID [l2/docker-compose.yml の FGA_STORE_ID]: " USER_STORE_ID
read -rp "USER_MODEL_ID [l2/docker-compose.yml の FGA_MODEL_ID]: " USER_MODEL_ID
echo "OPERATOR_IDは取得済: " 

echo "--- 事業者への認可付与"

#curl -i -X POST "http://localhost:8083/stores/$USER_STORE_ID/write" \
#      -H "Content-Type: application/json" \
#      -d '{
#        "authorization_model_id": "'$USER_MODEL_ID'",
#        "writes": {
#          "tuple_keys": [
#            {
#              "user": "user:'$OPERATOR_ID'",
#              "relation": "member",
#              "object": "group:endpoint-test-post"
#            }
#          ]
#        }
#      }'

#  docker compose up -d gateway

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


curl -X POST "http://localhost:8090/test" \
  -H 'api-key: 2dfd3409-ce01-4451-96fa-7e10c9681422y' \
  -H "Authorization: bearer $ACCESS_TOKEN" \
  -H 'X-ODS-UserId: 112233' \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{"userid":112233}' | jq .
