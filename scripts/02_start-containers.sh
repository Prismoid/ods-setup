#!/usr/bin/env bash
set -euo pipefail

cd SDK-docker-compose

docker network create shared-network-ods || true
docker compose up -d --build
