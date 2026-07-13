#!/usr/bin/env bash
set -euo pipefail

echo "精算・課金／決済データベースのマイグレーションを実行"
cd ./SDK-docker-compose/DCS-Payment
docker compose exec payment-app alembic -c migrations/alembic.ini upgrade head
cd ../../

read -p "SYSTEM_CLIENT_SECRET を入力(SDK-docker-compose/l3/docker-compose.yml のKEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRETの設定値): " SYSTEM_CLIENT_SECRET
sed -i.bak -E 's|(L3_CLIENT_SECRET:[[:space:]]*\$\{L3_CLIENT_SECRET:-)[^}]+(\})|\1'"${SYSTEM_CLIENT_SECRET}"'\2|' ./SDK-docker-compose/payment/docker-compose.yml
echo "L3_CLIENT_SECRET: \${L3_CLIENT_SECRET:-${SYSTEM_CLIENT_SECRET}} に更新しました。"


cd ./SDK-docker-compose
docker compose up payment-app -d

echo "データ提供者・利用者をDBに登録する。簡単のため、同一のIDとする。`uuidgen -t`が動く必要あり"
PAYMENT_SERVICE_ID=$(uuidgen -t)
docker exec -it payment-db psql fastapi_db -U postgres -c "INSERT INTO payment_services VALUES ('$PAYMENT_SERVICE_ID', 'test_service', 'http://example.com/')"
docker exec -it payment-db psql fastapi_db -U postgres -c 'SELECT * FROM payment_services'
