#!/bin/bash

# ECR Repo arn
# 001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr
# echo "Auth docker client with ecr registry"
# aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin 001983725908.dkr.ecr.ap-southeast-2.amazonaws.com
# echo "Tagging the image"
# docker builddocker tag $imageid 001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:$tag
# echo "Pushing the image"
# docker push 001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:$tag

# Images arns
# create_container_image_uri = "001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:create_hc_v2"
# read_container_image_uri = "001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:read_hc_v2"
# update_container_image_uri = "001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:update_hc_v2"

terraform apply -auto-approve && bash ./alb-workaround/alb-workaround.sh