#!/bin/bash

# echo "Finding ALB ARN."
# alb_arn=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text | grep uno-application-lb)
# echo "Found."

# echo "Finding port 80 listener registered to the ALB:"
# aws_http_80_listener_arn=$(aws elbv2 describe-listeners --load-balancer-arn arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:loadbalancer/app/uno-application-lb/cc7bc4afcdbe6277 \ 
# --query 'Listeners[].[ListenerArn, Port]' --output text | grep -E '80' | awk '{print $1}')
# echo "Found."

# echo "Finding Target Group for create service:"




# aws elbv2 describe-listeners --load-balancer-arn \
# $(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text)


# aws elbv2 create-rule \
# --listener-arn arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:listener/app/uno-application-lb/0fad057ac3704e91/de5a11e77b935a95 \
# --conditions 



# aws elbv2 create-rule \
#     --listener-arn arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:listener/app/uno-application-lb/0fad057ac3704e91/de5a11e77b935a95 \
#     --priority 7 \
#     --conditions file://read-service-path-pattern.json \
#     --actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:targetgroup/uno-application-lb-tg-read/bf8ad07bc77a65d3



# alb-arn=`aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text | grep uno-application-lb`
# echo $LB-ARN

# CREATE-TG=`aws elbv2 describe-target-groups --load-balancer-arn $(alb-arn) --query 'TargetGroups[].TargetGroupArn' --output text | grep -i create`
# CREATE-TG=aws elbv2 describe-target-groups --load-balancer-arn $(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text | grep uno-application-lb) --query 'TargetGroups[].TargetGroupArn' --output text | grep -i create
# echo $CREATE-TG


# aws_alb_endpoint=uno-application-lb-1064115610.ap-southeast-2.elb.amazonaws.com

# aws_alb_arn=arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:loadbalancer/app/uno-application-lb/a1512e9dd5608b1c 


aws_http_80_listener_arn=arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:listener/app/uno-application-lb/20743530051c36de/26b26b77bcf69269
aws_target_groups_arn_create=arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:targetgroup/uno-application-lb-tg-create/54011ca8553281d2
aws_target_groups_arn_read=arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:targetgroup/uno-application-lb-tg-read/d4f9b9d94ad7c512
aws_target_groups_arn_update=arn:aws:elasticloadbalancing:ap-southeast-2:001983725908:targetgroup/uno-application-lb-tg-update/757ebd19d86b3a98

aws elbv2 create-rule \
    --listener-arn $aws_http_80_listener_arn \
    --priority 7 \
    --conditions file://create-service-path-pattern.json \
    --actions Type=forward,TargetGroupArn=$aws_target_groups_arn_create

aws elbv2 create-rule \
    --listener-arn $aws_http_80_listener_arn \
    --priority 8 \
    --conditions file://read-service-path-pattern.json \
    --actions Type=forward,TargetGroupArn=$aws_target_groups_arn_read

aws elbv2 create-rule \
    --listener-arn $aws_http_80_listener_arn \
    --priority 9 \
    --conditions file://update-service-path-pattern.json \
    --actions Type=forward,TargetGroupArn=$aws_target_groups_arn_update