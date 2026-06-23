

OPERATOR_CLIENT_SECRET=4jxjjRZdcNOF61q3MS9q1cgmRus0jRJR
curl -i -X POST "http://localhost:8080/auth/token/client" \
-H "Content-Type: application/json" \
-H "API-Key: API-Key-Sample" \
-d '{
  "client_id": "login_user_client_id_sample_1782192024",
  "client_secret": "'$OPERATOR_CLIENT_SECRET'"
}'
