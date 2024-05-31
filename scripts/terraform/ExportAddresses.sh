#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")")
cd "$BASE_DIR"

# Make sure the terraform credentials sources are available
source scripts/auth/Access.sh

echo
echo "Exporting terraform addresses..."
echo

cd terraform/RDS
export addressRDS="$(terraform state show aws_db_instance.rds_db | grep address | sed "s/address//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

cd terraform/Kafka
export addresskafka="$(terraform state show 'aws_instance.kafkaCluster[0]' | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

cd terraform/Quarkus/Purchase
export pathPurchase="$(terraform state show aws_instance.purchaseQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../../..

cd terraform/Quarkus/customer
export pathCustomer="$(terraform state show aws_instance.customerQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../../..

cd terraform/Quarkus/shop
export pathShop="$(terraform state show aws_instance.shopQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../../..

cd terraform/Quarkus/loyaltycard
export pathLoyaltyCard="$(terraform state show aws_instance.loyaltyCardQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../../..

cd terraform/Kong
export pathKong="$(terraform state show aws_instance.installKong | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

cd terraform/Konga
export pathKonga="$(terraform state show aws_instance.installKonga | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

cd terraform/Camunda
export addressCamunda="$(terraform state show aws_instance.installCamundaEngine | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

echo "Finished exporting addresses."
echo
