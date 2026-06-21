#!/usr/bin/env bash
set -euo pipefail

cd - 
git clone https://github.com/open-dataspaces/SDK-docker-compose
cd SDK-docker-compose

git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/L2-dp-webapi.git
git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/L3-identity-component.git
git clone --branch=v1.0.0 --depth=1 https://github.com/open-dataspaces/DCS-Payment.git

sed -i.bak 's/postgres:18-alpine/postgres:16-alpine/g' ./payment/docker-compose.yml
sed -i.bak 's/localhost:24224/127.0.0.1:24224/g' ./l2/docker-compose.yml

if ! grep -q 'fluentd-async:' ./l2/docker-compose.yml; then
  sed -i.bak '/fluentd-address:/a\
        fluentd-async: "true"
' ./l2/docker-compose.yml
fi
