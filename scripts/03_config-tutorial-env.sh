#!/usr/bin/env bash
set -euo pipefail

cd SDK-docker-compose/L3-identity-component

ENV_FILE="docs/tutorials/env/tutorials.env"

sed -i.bak 's|^KEYCLOAK_PASSWORD=.*|KEYCLOAK_PASSWORD=password|' "${ENV_FILE}"
sed -i.bak 's|^KEYCLOAK_BASE_URL=.*|KEYCLOAK_BASE_URL=http://localhost:8082|' "${ENV_FILE}"
sed -i.bak 's|^OPENFGA_BASE_URL=.*|OPENFGA_BASE_URL=http://localhost:8083|' "${ENV_FILE}"
