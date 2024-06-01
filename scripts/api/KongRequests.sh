#!/bin/bash

# Accesses variables exported by KongConfiguration.sh after running DeploymentAutomation-ubuntu.sh

# == SHOP ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servershop.com" | python3 -m json.tool

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servershop.com" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --data '{
  "id": 0,
  "name": "ArcoCego",
  "location": "Lisbon"
}'

curl -i -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: servershop.com" | python3 -m json.tool

curl -i -X PUT \
  --url "${KONG_SERVER_ADDRESS}:8000/7/ArcoCego/Porto" \
  --header "Host: servershop.com" \
  --header "Content-Type: application/json"

# ===================================================================

# == PURCHASE ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverpurchase.com" | python3 -m json.tool

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000/Consume" \
  --header "Host: serverpurchase.com" \
  --header "Content-Type: application/json" \
  --data '{
  "TopicName": "1-ArcoCego"
}'

curl -i -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: serverpurchase.com" | python3 -m json.tool

# ===================================================================

# == CUSTOMER ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servercustomer.com" | python3 -m json.tool

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servercustomer.com" \
  --header "Content-Type: application/json" \
  --data '{
  "FiscalNumber": 0,
  "id": 0,
  "location": "Lisbon",
  "name": "ArcoCego"
}'

curl -i -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: servercustomer.com" | python3 -m json.tool

curl -i -X PUT \
  --url "${KONG_SERVER_ADDRESS}:8000/1/UpdatedName/123456789/Lisbon" \
  --header "Host: servercustomer.com" \
  --header "Content-Type: application/json"

# ===================================================================

# == LOYALTY CARD ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverloyaltycard.com" | python3 -m json.tool

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverloyaltycard.com" \
  --header "Content-Type: application/json" \
  --data '{
  "id": 0,
  "customerId": 5,
  "shopId": 1
}'

curl -i -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: serverloyaltycard.com" | python3 -m json.tool

curl -i -X PUT \
  --url "${KONG_SERVER_ADDRESS}:8000/1/2/3" \
  --header "Host: serverloyaltycard.com" \
  --header "Content-Type: application/json"
