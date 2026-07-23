#!/usr/bin/env bash
set -euo pipefail

PAYMENT_SERVICE_ID="57cc2dbe-7e8d-11f1-8c4f-6645bcee2088"
echo "1. アクセストークンの取得。本チュートリアルでは、クライアントIDが、login_user_client_id_sampleで固定されている"
read -p "OPERATOR_ID を入力: " OPERATOR_ID
read -p "OPERATOR_CLIENT_SECRET を入力: " OPERATOR_CLIENT_SECRET

ACCESS_TOKEN=$(curl -X POST "http://localhost:8080/auth/token/client" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-d '{                                                                                                                                                                                                                
  "client_id": "login_user_client_id_sample",                                                                                                                                                                        
  "client_secret": "'$OPERATOR_CLIENT_SECRET'"                                                                                                                                                                       
}' | jq -r '.data.access_token')

echo "$ACCESS_TOKEN \n\n"

echo "2. 利用料モデルの登録: "
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -d '{
    "fee_model_name": "通常モデル",
    "price": 1000,
    "tax_classification": "taxable",
    "tax_rate": 0.10,
    "provider_id": "'"$OPERATOR_ID"'",
    "consumer_id": "'"$OPERATOR_ID"'",
    "data_id": "'"I0101"'",
    "payment_service_id": "'"$PAYMENT_SERVICE_ID"'",
    "valid_from": "'$(date -Iseconds -u)'",
    "is_active": true,
    "version": 1
  }' \
  localhost:8001/api/v1/fee-model
echo "\n\n"

echo "3. 登録した利用料モデル一覧の取得"
curl -s \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  localhost:8001/api/v1/fee-model
echo "\n\n"

echo "4. データ交換状態登録(利用者・提供者)"
export TRACKING_ID=$(uuidgen -t)
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-TrackingId: $(uuidgen -t)" \
  -H "x-payment-api-key: payment-api-key" \
  -d '{
    "tracking_id": "'"$TRACKING_ID"'",
    "provider_id": "'"$OPERATOR_ID"'",
    "consumer_id": "'"$OPERATOR_ID"'",
    "data_id_list": ["I0101"],
    "completed_at": "'$(date -Iseconds -u)'",
    "status": "completed"
  }' \
  localhost:8001/api/v1/data-exchange/status


echo "5. 支払い予定額の取得\n"
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-TrackingId: $TRACKING_ID" \
  -H "x-payment-api-key: payment-api-key" \
  -d '{
    "provider_id": "'"$OPERATOR_ID"'",
    "start_date": "'$(date -I)'",
    "end_date": "'$(date -I -d'+1 day')'"
  }' \
  localhost:8001/api/v1/payment
echo ""

echo "6. 請求予定額の取得\n"
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "X-TrackingId: $TRACKING_ID" \
  -H "x-payment-api-key: payment-api-key" \
  -d '{
    "consumer_id": "'"$OPERATOR_ID"'",
    "start_date": "'$(date -I)'",
    "end_date": "'$(date -I -d'+1 day')'"
  }' \
  localhost:8001/api/v1/billing
