#!/usr/bin/env bash
set -euo pipefail

cd SDK-docker-compose

docker network create shared-network-ods || true
docker compose up -d --build

cd setup
bash setup_l3.sh
cd ..

docker compose -f l3/docker-compose.yml up -d

cd setup
bash setup_l2.sh
cd ..
