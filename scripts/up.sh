#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker-compose up -d postgres redis
./scripts/wait-service.sh postgres 5432
./scripts/wait-service.sh redis 6379
docker-compose up migrate
docker-compose up -d