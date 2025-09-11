#!/bin/bash
DOCKER_FILE="docker-compose-pull.yml"
docker compose -f $DOCKER_FILE down -v
docker compose -f $DOCKER_FILE up -d
docker stop aquinas-search-engine-app-1
docker-compose -f $DOCKER_FILE exec db psql -h localhost -U rwv1001 -d postgres -c "DROP DATABASE IF EXISTS philosophyfinderpsql_production4;"
docker-compose -f $DOCKER_FILE exec db psql -h localhost -U rwv1001 -d postgres -c "CREATE DATABASE philosophyfinderpsql_production4 OWNER rwv1001;"
docker-compose -f $DOCKER_FILE exec db pg_restore --verbose --clean --no-owner --username=rwv1001 --dbname=philosophyfinderpsql_production4 /backups/aquinas.dump
docker-compose -f $DOCKER_FILE down
docker-compose -f $DOCKER_FILE up -d