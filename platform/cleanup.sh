#!/bin/bash
echo "Running terraform destroy..."
terraform destroy --force
# echo "Removing Terraform state from s3 bucket..."
# aws s3 rm --recursive s3://tf-state-conf-2020-random-11-random --profile default
# echo
# echo "Removing the bucket now..."
# aws s3 rb --force s3://tf-state-conf-2020-random-11-random --profile default
echo 
echo "Everything Cleaned Up!"

