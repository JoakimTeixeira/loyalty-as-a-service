#!/bin/bash

# Accesses variables exported by ExportAddresses.sh after running DeploymentAutomation-ubuntu.sh

echo "Starting Kong services and routes configuration..."
echo

export KONG_SERVER_ADDRESS="http://${pathKongKongaCamunda}"
export SHOP_URL="http://${pathShop}:8080/Shop"
export PURCHASE_URL="http://${pathPurchase}:8080/Purchase"
export CUSTOMER_URL="http://${pathCustomer}:8080/Customer"
export LOYALTYCARD_URL="http://${pathLoyaltyCard}:8080/LoyaltyCard"
export DISCOUNTCOUPON_URL="http://${pathDiscountCoupon}:8080/DiscountCoupon"
export CROSSSELLING_URL="http://${pathCrossSelling}:8080/CrossSelling"

create_service() {
  local service_name=$1
  local service_url=$2

  # Check if service already exists
  service_exists=$(curl -s -o /dev/null -w "%{http_code}" "${KONG_SERVER_ADDRESS}:8001/services/${service_name}")

  if [ "$service_exists" -eq 404 ]; then
    # Service doesn't exist, create it
    echo "Creating service: ${service_name}"
    echo
    curl -i -X POST \
      --url "${KONG_SERVER_ADDRESS}:8001/services/" \
      --data "name=${service_name}" \
      --data "url=${service_url}"
    echo
    echo
  else
    # If the service exists, check the current URL
    service_info=$(curl -s "${KONG_SERVER_ADDRESS}:8001/services/${service_name}")
    current_protocol=$(echo "$service_info" | awk -F'"protocol":"' '{print $2}' | awk -F'","' '{print $1}')
    current_host=$(echo "$service_info" | awk -F'"host":"' '{print $2}' | awk -F'","' '{print $1}')
    current_port=$(echo "$service_info" | awk -F'"port":' '{print $2}' | awk -F',' '{print $1}')
    current_path=$(echo "$service_info" | awk -F'"path":"' '{print $2}' | awk -F'","' '{print $1}')

    current_url="${current_protocol}://${current_host}:${current_port}${current_path}"

    # If the URL has changed, update the service
    if [ "$current_url" != "$service_url" ]; then
      echo "Service ${service_name} exists but URL has changed. Updating it."
      echo
      curl -i -X PATCH \
        --url "${KONG_SERVER_ADDRESS}:8001/services/${service_name}" \
        --data "url=${service_url}"
      echo
      echo
    else
      echo "Service ${service_name} already exists with the correct URL. No update needed."
      echo
    fi
  fi
}

create_route() {
  local service_name=$1
  local route_host=$2

  # Check if route already exists
  existing_routes=$(curl -s ${KONG_SERVER_ADDRESS}:8001/services/${service_name}/routes)
  route_count=$(echo "$existing_routes" | sed -n '/"hosts":.*'"${route_host}"'/p' | wc -l)

  if [ "$route_count" -gt 0 ]; then
    echo "Route for ${service_name} already exists"
    echo
  else
    # Route doesn't exist, create it
    echo "Creating route for service: ${service_name} with host ${route_host}"
    echo
    curl -i -X POST \
      --url "${KONG_SERVER_ADDRESS}:8001/services/${service_name}/routes" \
      --data "hosts[]=${route_host}"
    echo
    echo
  fi
}

# == SHOP ==
if [ -n "$pathShop" ]; then
  create_service "shop-service" "${SHOP_URL}"
  create_route "shop-service" "servershop.com"
fi

# == PURCHASE ==
if [ -n "$pathPurchase" ]; then
  create_service "purchase-service" "${PURCHASE_URL}"
  create_route "purchase-service" "serverpurchase.com"
fi

# == CUSTOMER ==
if [ -n "$pathCustomer" ]; then
  create_service "customer-service" "${CUSTOMER_URL}"
  create_route "customer-service" "servercustomer.com"
fi

# == LOYALTY CARD ==
if [ -n "$pathLoyaltyCard" ]; then
  create_service "loyaltycard-service" "${LOYALTYCARD_URL}"
  create_route "loyaltycard-service" "serverloyaltycard.com"
fi

# == DISCOUNT COUPON ==
if [ -n "$pathDiscountCoupon" ]; then
  create_service "discountcoupon-service" "${DISCOUNTCOUPON_URL}"
  create_route "discountcoupon-service" "serverdiscountcoupon.com"
fi

# == CROSS SELLING ==
if [ -n "$pathCrossSelling" ]; then
  create_service "crossselling-service" "${CROSSSELLING_URL}"
  create_route "crossselling-service" "servercrossselling.com"
fi
