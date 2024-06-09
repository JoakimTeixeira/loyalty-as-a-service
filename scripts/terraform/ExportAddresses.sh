#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

# Make sure the terraform credentials sources are available
source scripts/auth/Access.sh

echo
echo "Exporting terraform addresses..."
echo

cd terraform/S3
export addressS3="$(terraform state show aws_s3_bucket.terraform_state | grep bucket_domain_name | sed "s/bucket_domain_name//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

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

cd terraform/Quarkus/discountcoupon
export pathDiscountCoupon="$(terraform state show aws_instance.discountCouponQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../../..

cd terraform/Quarkus/crossselling
export pathCrossSelling="$(terraform state show aws_instance.crossSellingQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../../..

cd terraform/Kong
export pathKongKongaCamunda="$(terraform state show aws_instance.installKongKongaCamunda | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
cd ../..

echo "Finished exporting addresses."
echo
