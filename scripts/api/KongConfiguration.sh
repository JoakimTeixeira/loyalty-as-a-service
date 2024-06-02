#!/bin/bash

# Accesses variables exported by ExportAddresses.sh after running DeploymentAutomation-ubuntu.sh

echo "Starting Kong services and routes configuration..."
echo

export KONG_SERVER_ADDRESS="http://${pathKong}"
export SHOP_URL="http://${pathShop}:8080/Shop"
export PURCHASE_URL="http://${pathPurchase}:8080/Purchase"
export CUSTOMER_URL="http://${pathCustomer}:8080/Customer"
export LOYALTYCARD_URL="http://${pathLoyaltyCard}:8080/LoyaltyCard"
export DISCOUNTCOUPON_URL="http://${pathDiscountCoupon}:8080/DiscountCoupon"

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

# ===================================================================

# == DISCOUNT COUPON ==

# Service
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/" \
  --data "name=discountcoupon-service" \
  --data "url=${DISCOUNTCOUPON_URL}"

# Route
curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8001/services/discountcoupon-service/routes" \
  --data "hosts[]=serverdiscountcoupon.com"
