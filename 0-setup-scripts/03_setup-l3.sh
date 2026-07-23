#!/usr/bin/env bash
set -euo pipefail

cd SDK-docker-compose

echo "Configure Keycloak master realm sslRequired=none..."

docker exec keycloak /opt/keycloak/bin/kcadm.sh config credentials \
  --server http://localhost:8082 \
  --realm master \
  --user admin \
  --password password

docker exec keycloak /opt/keycloak/bin/kcadm.sh update realms/master \
  -s sslRequired=none

docker exec keycloak /opt/keycloak/bin/kcadm.sh get realms/master | grep sslRequired


cd setup
bash setup_l3.sh
cd -
docker compose -f l3/docker-compose.yml up -d
