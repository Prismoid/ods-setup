#!/usr/bin/env bash
set -euo pipefail

cd - 
cd SDK-docker-compose/L3-identity-component
cd scripts

OUTPUT="$(
  bash ./setup.sh ../docs/tutorials/env/tutorials.env | tee /dev/stderr
)"

SYSTEM_CLIENT_SECRET="$(
  echo "${OUTPUT}" | awk -F': ' '/API Authorization client secret in Keycloak:/ {print $2}'
)"

API_AUTHZ_STORE_ID="$(
  echo "${OUTPUT}" | awk -F': ' '/API Authorization store ID in OpenFGA:/ {print $2}'
)"

export SYSTEM_CLIENT_SECRET
export API_AUTHZ_STORE_ID

echo
echo "------------------------------------------------------------"
echo "1. L3 API のアクセストークン取得のためのクライアントシークレット、およびAPI認可モデル・データ参照用のStore ID"
echo "------------------------------------------------------------"
echo "SYSTEM_CLIENT_SECRET=${SYSTEM_CLIENT_SECRET}"
echo "  - Keycloak の system-api-authz-client に対応する client secret です。"
echo "  - L3 API から client credentials でトークンを取得するために使います。"
echo
echo "API_AUTHZ_STORE_ID=${API_AUTHZ_STORE_ID}"
echo "  - OpenFGA 上に作成された API Authorization 用の store ID です。"
echo "  - API 認可モデルや認可データを参照するために使います。"
echo "------------------------------------------------------------"
echo

echo "------------------------------------------------------------"
echo "2. L3 APIアクセストークンの取得"
echo "------------------------------------------------------------"

TOKEN_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/token/client" \
    -H "Content-Type: application/json" \
    -H "API-Key: tutorials-system-api-key" \
    -d '{
      "client_id": "system-api-authz-client",
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
echo "3. 事業者情報の登録"
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
    -H "API-Key: tutorials-system-api-key" \
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
echo "4. 事業者情報取得"
echo "------------------------------------------------------------"
echo "登録した事業者情報を取得します。"
echo
echo "operator_id: ${OPERATOR_ID}"
echo

curl -s -X GET "http://localhost:8080/account/operator/${OPERATOR_ID}" \
  -H "Content-Type: application/json" \
  -H "API-Key: tutorials-system-api-key" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  | jq .


echo
echo "------------------------------------------------------------"
echo "5. 事業者クライアントID発行"
echo "------------------------------------------------------------"
echo "事業者用のクライアントIDを発行します。"
echo

OPERATOR_CLIENT_ID="login_user_client_id_sample_$(date +%s)"
OPERATOR_OPEN_SYSTEM_ID="login_user_open_system_id_sample_$(date +%s)"

OPERATOR_CLIENT_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/clients" \
    -H "Content-Type: application/json" \
    -H "API-Key: tutorials-system-api-key" \
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
echo "6. 事業者クライアントシークレット取得"
echo "------------------------------------------------------------"
echo "事業者クライアントシークレットを取得します。"
echo
echo "operator_client_uuid: ${OPERATOR_CLIENT_UUID}"
echo

OPERATOR_CLIENT_SECRET_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/clients/secret/${OPERATOR_CLIENT_UUID}" \
    -H "API-Key: tutorials-system-api-key" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
)"

echo "$OPERATOR_CLIENT_SECRET_RESPONSE" | jq .

OPERATOR_CLIENT_SECRET="$(echo "$OPERATOR_CLIENT_SECRET_RESPONSE" | jq -r '.data.client_secret')"

echo
echo "OPERATOR_CLIENT_SECRET=${OPERATOR_CLIENT_SECRET}"


echo
echo "------------------------------------------------------------"
echo "7. 個人ユーザ登録"
echo "------------------------------------------------------------"
echo "個人ユーザを登録します。"
echo

PERSONAL_USER_ID="personal_user_id_sample_$(date +%s)"

PERSONAL_USER_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/account/user" \
    -H "Content-Type: application/json" \
    -H "API-Key: tutorials-system-api-key" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{
      "login_user_id": "'"${PERSONAL_USER_ID}"'",
      "create_password_flag": true,
      "password_temporary_flag": false
    }'
)"

echo "$PERSONAL_USER_RESPONSE" | jq .

PERSONAL_USER_PASSWORD="$(echo "$PERSONAL_USER_RESPONSE" | jq -r '.data.password')"

echo
echo "PERSONAL_USER_ID=${PERSONAL_USER_ID}"
echo "PERSONAL_USER_PASSWORD=${PERSONAL_USER_PASSWORD}"
echo "このパスワードは 2-3-2. 認可コード取得 手順で使用します。"

echo
echo "------------------------------------------------------------"
echo "8. 認可コードフロー用クライアントID発行"
echo "------------------------------------------------------------"
echo "認可コードフロー用のクライアントIDを発行します。"
echo

AUTH_CODE_CLIENT_ID="authorization_code_flow_client_id_sample_$(date +%s)"

AUTH_CODE_CLIENT_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/clients" \
    -H "Content-Type: application/json" \
    -H "API-Key: tutorials-system-api-key" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -d '{
      "flow_type": "authorization_code",
      "client_id": "'"${AUTH_CODE_CLIENT_ID}"'",
      "name": "Authorization code flow client id",
      "description": "Authorization code flow client id.",
      "redirect_uris": [
        "urn:ietf:wg:oauth:2.0:oob"
      ]
    }'
)"

echo "$AUTH_CODE_CLIENT_RESPONSE" | jq .

AUTH_CODE_CLIENT_UUID="$(echo "$AUTH_CODE_CLIENT_RESPONSE" | jq -r '.data.client_uuid')"

echo
echo "AUTH_CODE_CLIENT_ID=${AUTH_CODE_CLIENT_ID}"
echo "AUTH_CODE_CLIENT_UUID=${AUTH_CODE_CLIENT_UUID}"


echo
echo "------------------------------------------------------------"
echo "9. 認可コードフロークライアントシークレット取得"
echo "------------------------------------------------------------"
echo "認可コードフロー用クライアントシークレットを取得します。"
echo

AUTH_CODE_CLIENT_SECRET_RESPONSE="$(
  curl -s -X POST "http://localhost:8080/auth/clients/secret/${AUTH_CODE_CLIENT_UUID}" \
    -H "API-Key: tutorials-system-api-key" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
)"

echo "$AUTH_CODE_CLIENT_SECRET_RESPONSE" | jq .

AUTH_CODE_CLIENT_SECRET="$(echo "$AUTH_CODE_CLIENT_SECRET_RESPONSE" | jq -r '.data.client_secret')"

echo
echo "AUTH_CODE_CLIENT_SECRET=${AUTH_CODE_CLIENT_SECRET}"
