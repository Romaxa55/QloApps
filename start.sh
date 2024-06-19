#!/bin/bash
source .env
docker stack deploy -c docker-compose.yml -c docker-compose.override.yml app
