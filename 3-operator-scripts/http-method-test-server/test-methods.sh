#!/usr/bin/env bash
set -euo pipefail

BASE_URL="http://localhost:5050/test"

for METHOD in GET POST PUT DELETE; do
  echo
  echo "========================================"
  echo "${METHOD} ${BASE_URL}"
  echo "========================================"

  if [[ "${METHOD}" == "GET" ]]; then
    curl -sS -i \
      -X "${METHOD}" \
      "${BASE_URL}?userid=112233"
  else
    curl -sS -i \
      -X "${METHOD}" \
      "${BASE_URL}" \
      -H "Content-Type: application/json" \
      -d '{
        "userid": 112233,
        "message": "HTTP method test"
      }'
  fi

  echo
done
