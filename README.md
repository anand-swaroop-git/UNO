# CRUD | Python (Flask) | Cognito | API Gateway | ECS Fargate | DynamoDB | Fully Automated with Terraform

## Project Description

1. The project takes microservices approach and consists of three core microservices/APIs (/create, /read and /update), fronted by API Gateway and one authentication microservice/API (/authenticate) namely:
>1. /create 
>2. /read (Parses the incoming request to validate the userId is numberic, returns validation error otherwise)
>3. /update
>4. /authenticate
2. The core microservices are deployed on an ECS cluster in private subnet.
3. The proxy and authentication APIs are deployed on API Gateway.

## Application workflow:
- Send a POST request to authentication service with a username and password. If the user already exists in the user pool the service will return an id_token.
- If the user does not exist, it will add the user and then return the id_token.
- Once you have got the token, you can then call the APIs by providing the id_token with the HTTP request. For commands, please refer to the cURL Commands section below.

## End to End flow
1. The user is authenticated against Cognito.
2. API gateway proxies the HTTP request to an Application Load Balancer.
3. The Application Load Balancer is listening on Port 80 and is associated with three target groups (`./platform/alb-workaround/alb-workaround.sh` performs this)
4. Each target group is listening on different ports and routes. Application Load Balancer does the path based routing to respective backend containers running in fargate.
5. Backend containers are able to access a DynamoDB Table to perform CRU operations.
6. Since ECR Fargate cluster is in private subnet, it uses NAT Gateways placed in public subnets for egress Internet access.


**Terraform is used to deploy 63 resources/components of Stack.:**
>1. Networking Components - VPC, Public and Private Subnets, NAT Gateway, Internet Gateway, Route Tables, Routes, Subnet Associations, Security Groups.
>2. Compute - Application Load Balancer, Target Groups, HTTP Listeners, Elastic Container Service (ECS) Cluster, ECS Service and ECS Task.
>3. **Encrypted** DynamoDB Table
>4. API Gateway API Resources, HTTP Proxy Integration and Deployment.
>5. IAM Roles and Policies
>6. API Gateway APIs (Main and Authentication)
>7. Lambda Functions
>8. Cognito UserPool, Authorizer, IAM Roles and Permissions etc.

To make it easier to test, have commented out the remote backend config in Terraform.

# Steps for Deployment

## Prerequisites and Deployment of APP

1. Please make sure that AWS CLI is installed. If not, please follow [this](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) link and configure the same using the default profile. 
2. Please also make sure that you have configured aws cli's **default profile**. Use this command `aws configure --profile default`. The user should have enough permissions to perform the operations mentioned under the **Terraform is used to deploy the following components of Stack:** section above.
3. Download and install Terraform CLI by following [this](https://www.terraform.io/downloads.html) link if it's not already installed. Make sure it's in your $PATH and is working fine.
4. Clone this repo and then browse indside the root directory `UNO`.
5. **Browse inside `./platform` and create a file called `terraform.tfvars`**
6. Manually replace the values of variables as shown in `./diagram/screenshots/terraform.tfvars` with your actual values.
7. **Make sure that the region that you have entered in the terraform.tfvars file above, is the same as you have specified while configuring the default aws cli profile by using** `aws configure --profile default` command.
8. **Run `bash go.sh`** (From `./platform/` directory)

Once Terraform finishes, it would output something like `./diagram/screenshots/successful_terraform_run.png`

> Once Terraform is finished, you would see two endpoints on the terminal:
> CRUD APPLICATION ENDPOINT
> AUTHENTICATION ENDPOINT

**Use the Authentication_Endpoint from the Terraform output to get the secret token and then use that token in subsequent calls to application endpoints also shown in the Terraform output as Create_API_Endpoint, Read_API_Endpoint, Update_API_Endpoint**

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

## Clean Up
1. Make sure you are inside `./platform` directory.
2. **Run `bash cleanup.sh`**

## Future Work
1. Enable DynamoDB Autoscaling
2. Enable ECS Autoscaling
3. Scope down IAM access.
4. Benchmarking/load testing.
5. Monitoring and alerting.
6. Private integration between API Gateway and ALB using VPC link/endpoint.
7. SG restrictions.
8. Build and deploy pipeline | CI/CD 


**Hight Level Architecture Diagram**

![alt text](https://github.com/anand-swaroop-git/UNO/blob/develop/diagram/uno-fully-automated.drawio.png?raw=true)

