#!/usr/bin/env bash
set -euo pipefail

read -r -p "アクセストークンの有効期間を秒数で入力してください (例: 14400): " ACCESS_TOKEN_LIFESPAN

if [[ ! "${ACCESS_TOKEN_LIFESPAN}" =~ ^[1-9][0-9]*$ ]]; then
  echo "エラー: 1以上の整数を入力してください。" >&2
  exit 1
fi

ADMIN_ACCESS_TOKEN=$(
  curl -s -X POST "http://localhost:8082/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" \
    -d "username=admin" \
    -d "password=password" |
    jq -r '.access_token'
)

curl -X PUT "http://localhost:8082/admin/realms/master" \
  -H "Authorization: Bearer ${ADMIN_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"accessTokenLifespan\": ${ACCESS_TOKEN_LIFESPAN}}"

echo
echo "master realmのアクセストークン有効期間を${ACCESS_TOKEN_LIFESPAN}秒に変更しました。"
echo "この設定は、今後新しく発行されるアクセストークンに適用されます。"
