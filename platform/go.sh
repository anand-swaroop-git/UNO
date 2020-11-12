#!/bin/bash
AWS_PROFILE=default
export AWS_PROFILE=default
echo
echo "Starting the process.."
echo
terraform init && terraform apply -auto-approve && bash ./alb-workaround/alb-workaround.sh