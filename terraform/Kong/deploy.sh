#!/bin/bash

# ====================================== KONG ======================================

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo service docker start

# Create Docker network
sudo docker network create kong-net

# Run PostgreSQL container for Kong database
sudo docker run -d --name kong-database \
  --network=kong-net \
  -p 5432:5432 \
  -e "POSTGRES_USER=kong" \
  -e "POSTGRES_DB=kong" \
  -e "POSTGRES_PASSWORD=kongpass" \
  postgres:13

# Run Kong migrations
sudo docker run --rm --network=kong-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-database" \
  -e "KONG_PG_PASSWORD=kongpass" \
  kong:3.1.1 kong migrations bootstrap

# Run Kong container
sudo docker run -d --name kong-gateway \
  --network=kong-net \
  -e "KONG_DATABASE=postgres" \
  -e "KONG_PG_HOST=kong-database" \
  -e "KONG_PG_USER=kong" \
  -e "KONG_PG_PASSWORD=kongpass" \
  -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
  -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
  -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
  -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
  -p 8000:8000 \
  -p 8443:8443 \
  -p 8001:8001 \
  -p 127.0.0.1:8444:8444 \
  kong:3.1.1

# ====================================== KONGA ======================================

# Pull Konga Docker image
sudo docker pull pantsel/konga

addressKong=$(curl http://169.254.169.254/latest/meta-data/public-hostname)

cat <<EOL >~/userdb.data
module.exports = [
    {
        "username": "teste",
        "email": "myadmin@some.domain",
        "firstName": "John",
        "lastName": "Doe",
        "node_id": "http://${addressKong}:8001",
        "admin": true,
        "active" : true,
        "password": "testeteste"
    }
]
EOL

cat <<EOL >~/kong_node.data
module.exports = [
    {
        "name": "Kong Node",
        "type": "default",
        "kong_admin_url": "http://${addressKong}:8001",
        "health_checks": false,
    }
]
EOL

sudo docker run -d --name konga -p 1337:1337 \
  -e "NODE_ENV=production" \
  -e "KONGA_SEED_USER_DATA_SOURCE_FILE=/app/userdb.data" \
  -e "KONGA_SEED_KONG_NODE_DATA_SOURCE_FILE=/app/kong_node.data" \
  -v ~/userdb.data:/app/userdb.data \
  -v ~/kong_node.data:/app/kong_node.data \
  pantsel/konga

# ===================================== CAMUNDA =====================================

sudo docker pull camunda/camunda-bpm-platform:latest

sudo docker run -d --name camunda -p 8080:8080 camunda/camunda-bpm-platform:latest
