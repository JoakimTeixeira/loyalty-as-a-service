#!/bin/bash

# aws access variables
aws_access_key_id=
aws_secret_access_key=
aws_session_token=

export AWS_ACCESS_KEY_ID=$aws_access_key_id
export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
export AWS_SESSION_TOKEN=$aws_session_token

export TF_VAR_dockerhub_username=
export TF_VAR_dockerhub_password=