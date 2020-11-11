# CRUD | Python (Flask) | Terraform | Cognito | API Gateway | ECS Fargate | DynamoDB

## Project Description

1. The project takes microservices approach and consists of three core microservices/APIs (/create, /read and /update), fronted by API Gateway and one authentication microservice/API (/authenticate) namely:
/create
/read
/update
/authenticate
2. The core microservices are deployed on an ECS cluster in private subnet.
3. The proxy and authentication APIs are deployed on API Gateway.
3. Application workflow:
- Send a POST request to authentication service with a username and password. If the user already exists in the user pool (User Pool is preconfigured - Manual for now, can be automated) the service will return an id_token.
- If the user does not exist, it will add the user and then return the id_token.
- Once you have got the token, you can then call the APIs by providing the id_token with the HTTP request. For commands, please refer to the cURL Commands section below.

## End to End flow
1. The user is authenticated against Cognito.
2. API gateway proxies the HTTP request to an Application Load Balancer.
3. The Application Load Balancer is listening on Port 80 and is associated with three target groups (`./platform/alb-workaround/alb-workaround.sh`)
4. Each target group is listening on different ports and routes. Application Load Balancer does the path based routing to respective backend containers running in fargate.
5. Backend containers are able to access a DynamoDB Table to perform CRU operations.
6. Since ECR Fargate cluster is in private subnet, it uses NAT Gateways placed in public subnets for egress Internet access.


Terraform is used to deploy the following components of Stack:
>1. Networking Components - VPC, Public and Private Subnets, NAT Gateway, Internet Gateway, Route Tables, Routes, Subnet Associations, Security Groups.
>2. Compute - Application Load Balancer, Target Groups, HTTP Listeners, Elastic Container Service (ECS) Cluster, ECS Service and ECS Task.
>3. **Encrypted** DynamoDB Table
>4. API Gateway API Resources, HTTP Proxy Integration and Deployment.
>5. IAM Role

Manual intervention is required for two actions (Time constraint):
>6. Cognito configuration

Terraform is using **encrypted** S3 as it's remote backend. 


# Steps for Deployment

There are two steps, one is to deploy the APP and the other is to configure Cognito.



## Step 1 - Prerequisites and Deployment of APP
1. Since the container images are currently stored in AWS ECR Reposiroty, [cross account access](https://aws.amazon.com/premiumsupport/knowledge-center/secondary-account-access-ecr/) can be provisioned. 
2. Please make sure that AWS CLI is installed. If not, please follow [this](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) link and configure the same.
3. Install Terraform CLI by following [this](https://learn.hashicorp.com/tutorials/terraform/install-cli) link.
4. Configure Terraform to run with AWS by following [this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) link.
5. Make sure that a bucket is created in your AWS account and update that bucket name in ./platform/backend.tf file. You might need to create a subdirectory named terraform-platform-backend in that bucket as well.
6. Clone this repo.
7. Run `terraform init` inside the root of the repository. 
8. Create a `terraform.tfvars` file and enter variables listed in both (`variables-app.tf` and `variables-auth.tf`) files.
9. **Browse inside `./platform` and run `bash go.sh`**

Once Terraform finishes, it would output something like `./diagram/successful_terraform_run.png`

## Step 2 - Cognito Configuration (Manual Steps, can be completely automated)

1. Create user-pool and note down user pool ID.
2. Create client in user-pool and note down Client Secret and Client access key.
3. Create presignup lambda (Present in`./platform/lambda/` directory).
4. Add presignup lambda in user-pool as a pre signup trigger (Present in`./platform/lambda/` directory).
5. Create unosignin lambda which will talk to cognito to authenticate - update user-pool ID and client secrete and access key (Present in`./platform/lambda/` directory).
6. Create API Gateway resource/api for the uno-signin lambda - call it `/authenticate` endpoint and deploy it. This will give you the authentication endpoint.
7. Create a new authorizer in your main API named UnoAPI and choose your user-pool as authorizer - Add Authorization header via which token would be provided. Screenshot `cognito_authorizer.png`
8. Add the authorizer to UnoAPI. Screenshot `cognito_add_authorizer.png`
9. Deploy the API
10. Test - Hit /authenticate endpoint to get token for any user/password.
11. Hit UnoAPI  by supplying the token in the Authorization header - it should succeed, without token it should give 401.

## cURL Commands

Get token from `/authenticate`. You will get the URL from Step 6 above.
```
    curl --location --request POST 'https://b65356rvze.execute-api.ap-southeast-2.amazonaws.com/prod/authenticate' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "username": "randomuser", 
        "password": "randompassword"
    }'
```
`/create`. You will get the URL from Terraform output section. `api_gateway_invoke_url `
```
curl --location --request POST 'https://4preuhxncc.execute-api.ap-southeast-2.amazonaws.com/prod/create' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJraWQiOiJoUWhYTWpwZDUxV0pZTkllU2V6ZjlFdG5FSURmeUNxXC9qXC9NS3ZDMnIxcG89IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI2NzY0MzE2Yi0xMGU2LTQ5ZTktYjRkZC0xN2NiZWNkMmE1ZTAiLCJhdWQiOiIxaDlnM2tmNXRmaGpycG9mY3Nla3RuZ2RpbyIsImV2ZW50X2lkIjoiOGUxNjU0MTUtYWRkNS00ODVhLWFlMTUtNjVmMjk2YjY1MWI3IiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE2MDUxMDAzMjAsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC5hcC1zb3V0aGVhc3QtMi5hbWF6b25hd3MuY29tXC9hcC1zb3V0aGVhc3QtMl9LMHBSZFBEeGgiLCJjb2duaXRvOnVzZXJuYW1lIjoiaG93YXJleW91IiwiZXhwIjoxNjA1MTAzOTIwLCJpYXQiOjE2MDUxMDAzMjF9.O5kjVY1QRszFnUgNEc__2QDdnGdSq_t7OM-COu4spIN3Vmrz5_PzS-uaUVB9c6u5i-26I42NmVQk_dQG15s61GfvjsijyQrkrA5pZa4kogHnwojkC6pIRgF4LKdZGScRXQYZIqJUmYqAlw9dUTGO-hE3I9wytFt2imV7MP9YXuGdvVS5yDYcviswUJNW7vk_xA8zRDkEXuDC_uHioaufi2KiUD7X7blR3RZKmR8feZtsmXG746r6xxiU4kTqtuHsVmAo8weGSHNlx1Dw4rOuLuHcGAoUe-AOgguPImU7IEniZF5ylgXUhGuwgEk0AnFyOYvyZfHIi26QqGp_a8g0NQ' \
--data-raw '{
    "title": "Mr",
    "firstName": "John",
    "lastName": "P",
    "mobileNumber": "047777777",
    "address": {
        "postcode": "2040",
        "suburb": "LEICHHARDT",
        "state": "NSW",
        "fullAddress": "100 william street, leichhdart, nsw 2040"
    }
}'
```
`/read`
```
curl --location --request GET 'https://4preuhxncc.execute-api.ap-southeast-2.amazonaws.com/prod/read?userId=28736440' \
--header 'Authorization: Bearer eyJraWQiOiJoUWhYTWpwZDUxV0pZTkllU2V6ZjlFdG5FSURmeUNxXC9qXC9NS3ZDMnIxcG89IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI2NzY0MzE2Yi0xMGU2LTQ5ZTktYjRkZC0xN2NiZWNkMmE1ZTAiLCJhdWQiOiIxaDlnM2tmNXRmaGpycG9mY3Nla3RuZ2RpbyIsImV2ZW50X2lkIjoiOGUxNjU0MTUtYWRkNS00ODVhLWFlMTUtNjVmMjk2YjY1MWI3IiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE2MDUxMDAzMjAsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC5hcC1zb3V0aGVhc3QtMi5hbWF6b25hd3MuY29tXC9hcC1zb3V0aGVhc3QtMl9LMHBSZFBEeGgiLCJjb2duaXRvOnVzZXJuYW1lIjoiaG93YXJleW91IiwiZXhwIjoxNjA1MTAzOTIwLCJpYXQiOjE2MDUxMDAzMjF9.O5kjVY1QRszFnUgNEc__2QDdnGdSq_t7OM-COu4spIN3Vmrz5_PzS-uaUVB9c6u5i-26I42NmVQk_dQG15s61GfvjsijyQrkrA5pZa4kogHnwojkC6pIRgF4LKdZGScRXQYZIqJUmYqAlw9dUTGO-hE3I9wytFt2imV7MP9YXuGdvVS5yDYcviswUJNW7vk_xA8zRDkEXuDC_uHioaufi2KiUD7X7blR3RZKmR8feZtsmXG746r6xxiU4kTqtuHsVmAo8weGSHNlx1Dw4rOuLuHcGAoUe-AOgguPImU7IEniZF5ylgXUhGuwgEk0AnFyOYvyZfHIi26QqGp_a8g0NQ'
```
`/update`
```
curl --location --request PUT 'https://m1nmogphg2.execute-api.ap-southeast-2.amazonaws.com/development/update' \
--header 'Authorization: Bearer eyJraWQiOiJoUWhYTWpwZDUxV0pZTkllU2V6ZjlFdG5FSURmeUNxXC9qXC9NS3ZDMnIxcG89IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIwYzgxZTBhZi0xOGMwLTQ0NmUtODg5Ny03ZjA5Njk0OTA1NDEiLCJhdWQiOiIxaDlnM2tmNXRmaGpycG9mY3Nla3RuZ2RpbyIsImV2ZW50X2lkIjoiZDYwYjlkZjMtZTNiNS00YmM2LWFhMjQtOTk3NWIyNDU4MTE4IiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE2MDUwODQ1NzQsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC5hcC1zb3V0aGVhc3QtMi5hbWF6b25hd3MuY29tXC9hcC1zb3V0aGVhc3QtMl9LMHBSZFBEeGgiLCJjb2duaXRvOnVzZXJuYW1lIjoidXNlcjMiLCJleHAiOjE2MDUwODgxNzQsImlhdCI6MTYwNTA4NDU3NH0.D-XZ8jBg3YqHxwc9uvHGxOJgJBx7QIbMIIGTWXgXwiKqRAuXjPRlCWq5RVCKEKICEtPbeBGgpmTry2d-ikGYGglormcobESsWYGc4uiNZLdECPmyWfHBVUtfNO0Qe1WrhD_xEWOnaSrAH-c2B4gGngbYOSy5TDLkJZuSH0sTJPXv2YJ5NGQDks-A7fnEetrfHY2fmv5lTBqKSnUg_BWwS9cy36gDvSUx-oKdDT1J87MfQyT4qH7bCMY8tz_DAvysTxhbsL9sDcKw0ENzdqMeNyb5TNQd00lDyIOXUdahUgbJV14nBKhnwdb7K3HhpDk20jgGBXCVgVasQ04lnCNh_Q' \
--header 'Content-Type: application/json' \
--data-raw '{
    "userId": "31327518",
    "title": "MR",
    "firstName": "Sanders",
    "lastName": "P",
    "mobileNumber": "99999999",
    "address": {
        "postcode": "9999",
        "suburb": "SOME_SUBURB",
        "state": "NA",
        "fullAddress": "100 william street, leichhdart, nsw 2040"
    }
}'
```

> Some screenshots of the above requests can be found in `./diagram/screenshots` directory.

## Future Work
1. Enable DynamoDB Autoscaling
2. Enable ECS Autoscaling
3. Scope down IAM access.
4. Benchmarking/load testing.
5. Monitoring and alerting.
6. Automate Cognito Configuration.
7. Private integration between API Gateway and ALB using VPC link/endpoint.
8. SG restrictions.
9. Build and deploy pipeline | CI/CD 


**Hight Level Architecture Diagram**

![alt text](https://github.com/anand-swaroop-git/UNO/blob/master/diagram/high_level_v3.png?raw=true)

