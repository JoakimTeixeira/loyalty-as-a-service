#!/bin/bash

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
cd "$BASE_DIR"

# Make sure the terraform credentials sources are available
source scripts/auth/Access.sh

echo
echo "Exporting terraform addresses..."
echo

TERRAFORM_STATE_FOLDER=".terraform"

cd terraform/S3
echo "Exporting terraform S3 addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export addressS3="$(terraform state show aws_s3_bucket.terraform_state | grep bucket_domain_name | sed "s/bucket_domain_name//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../..

cd terraform/RDS
echo "Exporting terraform RDS addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    addressesRDS=($(terraform state list 'aws_db_instance.rds_db' | xargs -I {} terraform state show {} | grep address | awk '{print $3}' | tr -d '"'))
fi
cd ../..

cd terraform/Kafka
echo "Exporting terraform Kafka addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export addresskafka="$(terraform state show 'aws_instance.kafkaCluster[0]' | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../..

cd terraform/Quarkus/purchase
echo "Exporting terraform purchase addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathPurchase="$(terraform state show aws_instance.purchaseQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../../..

cd terraform/Quarkus/customer
echo "Exporting terraform customer addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathCustomer="$(terraform state show aws_instance.customerQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../../..

cd terraform/Quarkus/shop
echo "Exporting terraform shop addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathShop="$(terraform state show aws_instance.shopQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../../..

cd terraform/Quarkus/loyaltycard
echo "Exporting terraform loyalty card addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathLoyaltyCard="$(terraform state show aws_instance.loyaltyCardQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../../..

cd terraform/Quarkus/discountcoupon
echo "Exporting terraform discount coupon addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathDiscountCoupon="$(terraform state show aws_instance.discountCouponQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../../..

cd terraform/Quarkus/crossselling
echo "Exporting terraform cross selling addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathCrossSelling="$(terraform state show aws_instance.crossSellingQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../../..

cd terraform/Quarkus/selledproduct
echo "Exporting terraform cross selling addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathSelledProduct="$(terraform state show aws_instance.selledProductQuarkus | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../../..

cd terraform/Kong
echo "Exporting terraform kong addresses..."
if [ -d "$TERRAFORM_STATE_FOLDER" ]; then
    export pathKongKongaCamunda="$(terraform state show aws_instance.installKongKongaCamunda | grep public_dns | sed "s/public_dns//g" | sed "s/=//g" | sed "s/\"//g" | sed "s/ //g" | sed "s/$esc\[[0-9;]*m//g")"
fi
cd ../..

echo
echo "Finished exporting addresses."
echo
