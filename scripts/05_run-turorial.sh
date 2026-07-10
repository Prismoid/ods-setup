#!/usr/bin/env bash
set -e

read -p "SYSTEM_CLIENT_SECRET を入力(SDK-docker-compose/l3/docker-compose.yml のKEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRETの設定値): " SYSTEM_CLIENT_SECRET

echo "2-1-1. アクセストークン取得"

ACCESS_TOKEN=$(curl -s -X POST "http://localhost:8080/auth/token/client" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-d '{
  "client_id": "system-auth-sample",
  "client_secret": "'$SYSTEM_CLIENT_SECRET'"
}' | jq -r '.data.access_token')

echo "$ACCESS_TOKEN"

echo
echo "2-1-2. 事業者情報登録"

curl -i -X POST "http://localhost:8080/account/operator" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-d '{
  "login_user_id": "login_user_id_sample",
  "operator_name": "サンプル株式会社",
  "operator_address": "試験県サンプル市examビル1F",
  "open_operator_id": "1234567890120",
  "global_operator_id": "123456789TT234567890",
  "effective_start_date": "2000-01-01",
  "effective_end_date": "9999-12-31",
  "create_password_flag": true,
  "password_temporary_flag": false
}'

echo
read -p "OPERATOR_ID を入力: " OPERATOR_ID
read -p "OPERATOR_PASSWORD を入力: " OPERATOR_PASSWORD

echo
echo "2-1-3. 事業者情報取得"

curl -i -X GET "http://localhost:8080/account/operator/$OPERATOR_ID" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-H "Authorization: Bearer $ACCESS_TOKEN"

echo
echo "2-1-4. 事業者クライアントID発行"

curl -i -X POST "http://localhost:8080/auth/clients" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-H "Authorization: Bearer $ACCESS_TOKEN" \
-d '{
  "flow_type": "client_credentials",
  "client_id": "login_user_client_id_sample",
  "name": "サンプル株式会社クライアントID",
  "description": "サンプル株式会社クライアントID",
  "operator_id": "'$OPERATOR_ID'",
  "open_system_id": "login_user_open_system_id_sample"
}'

echo
read -p "OPERATOR_CLIENT_UUID を入力: " OPERATOR_CLIENT_UUID

echo
echo "2-1-5. 事業者クライアントシークレット取得"

curl -i -X POST "http://localhost:8080/auth/clients/secret/$OPERATOR_CLIENT_UUID" \
-H "API-Key: API-Key-Sample" \
-H "Authorization: Bearer $ACCESS_TOKEN"

echo
read -p "OPERATOR_CLIENT_SECRET を入力: " OPERATOR_CLIENT_SECRET

cat > generated-l3-app.env <<EOF
SYSTEM_CLIENT_SECRET='$SYSTEM_CLIENT_SECRET'
ACCESS_TOKEN='$ACCESS_TOKEN'
OPERATOR_ID='$OPERATOR_ID'
OPERATOR_PASSWORD='$OPERATOR_PASSWORD'
OPERATOR_CLIENT_UUID='$OPERATOR_CLIENT_UUID'
OPERATOR_CLIENT_SECRET='$OPERATOR_CLIENT_SECRET'
EOF

echo
cat generated-l3-app.env
