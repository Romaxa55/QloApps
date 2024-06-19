#!/bin/bash
export $(cat .env | xargs)
docker stack deploy -c docker-compose.yml -c docker-compose.override.yml app
