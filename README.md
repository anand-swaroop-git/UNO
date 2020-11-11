# Create, Read and Update Python (Flask) App with Terraform, Cognito, API Gateway, ECS Fargate and DynamoDB

The project consists of three apis namely:
/create
/read
/update
which are authenticated using AWS Cognito. The project also uses API gateway to proxy authenticated HTTP calls to an Application Load Balancer, which relays the request to the microservices hosted in Elastic Container Service (Fargate) to perform the operations on a DynamoDB table.

Terraform is used to deploy the following components of Stack:
>1. Networking Components - VPC, Public and Private Subnets, NAT Gateway, Internet Gateway, Route Tables, Routes, Subnet Associations, Security Groups.
>2. Compute - Application Load Balancer, Target Groups, HTTP Listeners, Elastic Container Service (ECS) Cluster, ECS Service and ECS Task.
>3. **Encrypted** DynamoDB Table
>4. API Gateway API Resources, HTTP Proxy Integration and Deployment.
>5. IAM Role

Manual intervention is required for two actions (Time constraint):
>6. Cognito configuration
>7. Adding multiple target groups to HTTP 80 listener with the help of a script in the repository.

Terraform is using **encrypted** S3 as it's remote backend. 





# Steps for Deployment



## Prerequisites and Deployment

1. Please make sure that AWS CLI is installed. If not, please follow [this](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) link and configure the same.
2. Install Terraform CLI by following [this](https://learn.hashicorp.com/tutorials/terraform/install-cli) link.
3. Configure Terraform to run with AWS by following [this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) link.
4. Clone this repo.
5. Browse inside ./platform and update the container images (Yet to push to dockerhub, currently on ECR) in line 429, 442 and 455.
6. Make sure that a bucket is created in your AWS account and update that bucket name in ./platform/backend.tf file. You might need to create a subdirectory named terraform-platform-backend in that bucket as well.
7. Run `terraform init` inside the root of the repository. 
8. Create a `terraform.tfvars` file and enter variables listed in both the variables files.
9. Run `terraform plan` and review the resources Terraform is planning to create.
10.Run `terraform apply -auto-approve` for it to create the resources.

Once Terraform finishes, it would output something like `./diagram/output_vars.png`

>Please copy the four variables from output screen named `aws_http_80_listener_arn, aws_target_groups_arn_create, aws_target_groups_arn_read, aws_target_groups_arn_update` and put them in `./platform/alb-workaround/alb-workaround.sh` script. 
>Once done, please **ensure** to remove white spaces around `=` sign. 

10. Lastly, run the script `bash ./platform/alb-workaround/alb-workaround.sh` and this will run three aws cli commands to add path based routing for corresponding target groups behind ALB.

*At this point, you should be able to access the endpoints using API gateway proxy Invoke URL. You can find this URL from Terraform output screen.*


**Hight Level Architecture Diagram**

![alt text](https://github.com/anand-swaroop-git/UNO/blob/master/diagram/high_level_v3.png?raw=true)

