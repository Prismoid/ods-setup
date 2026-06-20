#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/open-dataspaces/SDK-docker-compose
cd SDK-docker-compose

git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/L2-dp-webapi.git
git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/L3-identity-component.git
git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/DCS-Payment.git

sed -i.bak 's/postgres:18-alpine/postgres:16-alpine/g' ./payment/docker-compose.yml
