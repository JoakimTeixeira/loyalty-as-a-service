#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

# Make sure the terraform credentials sources are available
source scripts/auth/Access.sh

echo

echo "S3 IS AVAILABLE HERE:"
echo "${addressS3}"
echo

echo "RDS IS AVAILABLE HERE:"
# Loop through the addresses and print each one on a new line
for address in "${addressesRDS[@]}"; do
    echo "$address"
done
echo

echo "KAFKA IS AVAILABLE HERE:"
echo "${addresskafka}"
echo

echo "MICROSERVICE purchase IS AVAILABLE HERE:"
echo "http://${pathPurchase}:8080/q/swagger-ui/"
echo

echo "MICROSERVICE customer IS AVAILABLE HERE:"
echo "http://${pathCustomer}:8080/q/swagger-ui/"
echo

echo "MICROSERVICE shop IS AVAILABLE HERE:"
echo "http://${pathShop}:8080/q/swagger-ui/"
echo

echo "MICROSERVICE loyaltycard IS AVAILABLE HERE:"
echo "http://${pathLoyaltyCard}:8080/q/swagger-ui/"
echo

echo "MICROSERVICE discountcoupon IS AVAILABLE HERE:"
echo "http://${pathDiscountCoupon}:8080/q/swagger-ui/"
echo

echo "MICROSERVICE crossselling IS AVAILABLE HERE:"
echo "http://${pathCrossSelling}:8080/q/swagger-ui/"
echo

echo "KONG IS AVAILABLE HERE:"
echo "http://${pathKongKongaCamunda}:8001/"
echo

echo "KONGA LOGIN PAGE IS AVAILABLE HERE:"
echo "http://${pathKongKongaCamunda}:1337/#!/login"
echo
echo "KONGA REGISTER PAGE IS AVAILABLE HERE:"
echo "http://${pathKongKongaCamunda}:1337/register"
echo

echo "CAMUNDA IS AVAILABLE HERE:"
echo "http://${pathKongKongaCamunda}:8080/camunda"
echo

echo
