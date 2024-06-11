#!/bin/bash

# This script is used to export environment variables for the Terraform scripts

# AWS access
aws_access_key_id=''
aws_secret_access_key=''
aws_session_token=''

export AWS_ACCESS_KEY_ID=${aws_access_key_id}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
export AWS_SESSION_TOKEN=${aws_session_token}

# ================================================================================

# Docker Hub
export DOCKERHUB_USERNAME=''
export DOCKERHUB_PASSWORD=''

# ================================================================================

# Database
export DB_USERNAME=''
export DB_PASSWORD=''
export DB_NAME='quarkus_test_all_operations'
export DB_INSTANCES=6

# ================================================================================

# AWS Key Pair
export KEY_PAIR_NAME='mykey'

# ================================================================================

# Terraform State
export AWS_REGION='us-east-1'
export S3_BUCKET_NAME='iemp-project-2024-group-1-terraform-state'
export DYNAMODB_TABLE_NAME='terraform-locks'
