#!/bin/bash

source scripts/terraform/ExportAddresses.sh

echo "Starting Kong services and routes configuration..."
echo

KONG_SERVER_ADDRESS="http://${pathKong}"
SHOP_URL="http://${pathShop}:8080/Shop"
PURCHASE_URL="http://${pathPurchase}:8080/Purchase"
CUSTOMER_URL="http://${pathCustomer}:8080/Customer"
LOYALTYCARD_URL="http://${pathLoyaltyCard}:8080/LoyaltyCard"

# == SHOP ==

# Service
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/" \
  --data "name=shop-service" \
  --data "url=${SHOP_URL}"

# Route
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/shop-service/routes" \
  --data "hosts[]=servershop.com"

# ===================================================================

# == PURCHASE ==

# Service
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/" \
  --data "name=purchase-service" \
  --data "url=${PURCHASE_URL}"

# Route
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/purchase-service/routes" \
  --data "hosts[]=serverpurchase.com"

# ===================================================================

# == CUSTOMER ==

# Service
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/" \
  --data "name=customer-service" \
  --data "url=${CUSTOMER_URL}"

# Route
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/customer-service/routes" \
  --data "hosts[]=servercustomer.com"

# ===================================================================

# == LOYALTY CARD ==

# Service
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/" \
  --data "name=loyaltycard-service" \
  --data "url=${LOYALTYCARD_URL}"

# Route
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/loyaltycard-service/routes" \
  --data "hosts[]=serverloyaltycard.com"
