#!/bin/bash

# Accesses variables exported by KongConfiguration.sh after running DeploymentAutomation-ubuntu.sh

# == SHOP ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servershop.com"

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
  --header "Host: servershop.com"

curl -i -X PUT \
  --url "${KONG_SERVER_ADDRESS}:8000/7/ArcoCego/Porto" \
  --header "Host: servershop.com" \
  --header "Content-Type: application/json"

# ===================================================================

# == PURCHASE ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverpurchase.com"

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000/Consume" \
  --header "Host: serverpurchase.com" \
  --header "Content-Type: application/json" \
  --data '{
  "topicName": "1-ArcoCego"
}'

curl -i -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: serverpurchase.com"

# ===================================================================

# == CUSTOMER ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servercustomer.com"

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
  --header "Host: servercustomer.com"

curl -i -X PUT \
  --url "${KONG_SERVER_ADDRESS}:8000/1/UpdatedName/123456789/Lisbon" \
  --header "Host: servercustomer.com" \
  --header "Content-Type: application/json"

# ===================================================================

# == LOYALTY CARD ==

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverloyaltycard.com"

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
  --header "Host: serverloyaltycard.com"

curl -i -X PUT \
  --url "${KONG_SERVER_ADDRESS}:8000/1/2/3" \
  --header "Host: serverloyaltycard.com" \
  --header "Content-Type: application/json"

# ===================================================================

# == DISCOUNT COUPON ==

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000/Consume" \
  --header "Host: serverdiscountcoupon.com" \
  --header "Content-Type: application/json" \
  --data '{
  "topicName": "Discount-1-5"
}'

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverdiscountcoupon.com"

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverdiscountcoupon.com" \
  --header "Content-Type: application/json" \
  --data '{
  "topic": {
    "topicName": "Discount-1-5"
  },
  "coupon": {
    "id": 0,
    "discount": "30% off",
    "expiryDate": "2020-01-01"
  }
}'

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: serverdiscountcoupon.com"

curl -s -X DELETE \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: serverdiscountcoupon.com"

# ===================================================================

# == CROSS SELLING ==

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000/Consume" \
  --header "Host: servercrossselling.com" \
  --header "Content-Type: application/json" \
  --data '{
  "topicName": "CrossSelling-2-4"
}'

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servercrossselling.com"

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: servercrossselling.com" \
  --header "Content-Type: application/json" \
  --data '{
  "topic": {
    "topicName": "CrossSelling-2-4"
  },
  "crossselling": {
    "id": 0,
    "partnerShop": "H&M",
    "recommendedProduct": "Jacket"
  }
}'

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: servercrossselling.com"

curl -s -X DELETE \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: servercrossselling.com"

# ===================================================================

# == SELLED PRODUCT ==

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000/Consume" \
  --header "Host: serverselledproduct.com" \
  --header "Content-Type: application/json" \
  --data '{
  "topicName": "SelledProduct-Lisboa"
}'

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverselledproduct.com"

curl -i -X POST \
  --url "${KONG_SERVER_ADDRESS}:8000" \
  --header "Host: serverselledproduct.com" \
  --header "Content-Type: application/json" \
  --data '{
  "topic": {
    "topicName": "SelledProduct-Lisboa"
  },
  "product": {
    "id": 0,
    "couponId": 2,
    "productsSelledByCoupon": 128,
    "shopId": 4,
    "productsSelledByShop": 14,
    "shopLocation": "Lisboa",
    "productsSelledByLocation": 356,
    "loyaltyCardId": 7,
    "productsSelledByLoyaltyCard": 55,
    "customerId": 1,
    "productsSelledByCustomer": 38
  }
}'

curl -s -X GET \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: serverselledproduct.com"

curl -s -X DELETE \
  --url "${KONG_SERVER_ADDRESS}:8000/1" \
  --header "Host: serverselledproduct.com"
