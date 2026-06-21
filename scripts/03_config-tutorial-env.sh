#!/usr/bin/env bash
set -euo pipefail

cd SDK-docker-compose/L3-identity-component

ENV_FILE="docs/tutorials/env/tutorials.env"

echo "チュートリアル用 env をローカル環境向けに変更します。"
echo "Keycloak password: password"
echo "Keycloak URL     : http://localhost:8082"
echo "OpenFGA URL      : http://localhost:8083"

sed -i.bak 's|^KEYCLOAK_PASSWORD=.*|KEYCLOAK_PASSWORD=password|' "${ENV_FILE}"
sed -i.bak 's|^KEYCLOAK_BASE_URL=.*|KEYCLOAK_BASE_URL=http://localhost:8082|' "${ENV_FILE}"
sed -i.bak 's|^OPENFGA_BASE_URL=.*|OPENFGA_BASE_URL=http://localhost:8083|' "${ENV_FILE}"

echo "完了しました。"
echo "バックアップ: ${ENV_FILE}.bak"
