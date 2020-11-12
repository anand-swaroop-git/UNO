#!/bin/bash
echo
echo "Performing ALB workaround now..."
echo
echo "Finding ALB ARN..."
alb_arn=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --profile default --output text | grep uno-application-lb)
echo "Found."
echo "Finding HTTP 80 Listener ARN..."
aws_http_80_listener_arn=`aws elbv2 describe-listeners --load-balancer-arn $alb_arn --query 'Listeners[].[ListenerArn, Port]' --profile default --output text | grep 80 | awk '{print $1}'`
echo "Found."
echo "Finding Target Groups..."
create_tg_arn=$(aws elbv2 describe-target-groups --names uno-application-lb-tg-create --query 'TargetGroups[].TargetGroupArn' --profile default --output text)
read_tg_arn=$(aws elbv2 describe-target-groups --names uno-application-lb-tg-read --query 'TargetGroups[].TargetGroupArn' --profile default --output text)
update_tg_arn=$(aws elbv2 describe-target-groups --names uno-application-lb-tg-update --query 'TargetGroups[].TargetGroupArn' --profile default --output text)
echo "Found."
echo
echo "Registering create target group to HTTP 80 listener..."
aws elbv2 create-rule \
    --listener-arn $aws_http_80_listener_arn \
    --priority 7 \
    --conditions file://alb-workaround/create-service-path-pattern.json \
    --actions Type=forward,TargetGroupArn=$create_tg_arn --profile default  &> /dev/null
echo "Registered."
echo "Registering read target group to HTTP 80 listener..."
aws elbv2 create-rule \
    --listener-arn $aws_http_80_listener_arn \
    --priority 8 \
    --conditions file://alb-workaround/read-service-path-pattern.json \
    --actions Type=forward,TargetGroupArn=$read_tg_arn --profile default &> /dev/null
echo "Registered."
echo "Registering update target group to HTTP 80 listener..."
aws elbv2 create-rule \
    --listener-arn $aws_http_80_listener_arn \
    --priority 9 \
    --conditions file://alb-workaround/update-service-path-pattern.json \
    --actions Type=forward,TargetGroupArn=$update_tg_arn --profile default &> /dev/null
echo "Registered."
echo
echo "Please refer to curl commands section in readme.md to use the APIs"
echo
