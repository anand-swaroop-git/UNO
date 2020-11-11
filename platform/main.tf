##################################################################################
# NETWORK SETUP |  VPC, SUBNET, IGW, ROUTES
##################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

# --------------------------------------------------------
# VPC
# --------------------------------------------------------
resource "aws_vpc" "aws-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

# --------------------------------------------------------
# Public Subnet 1, EIP1 and NAT 1
# --------------------------------------------------------
resource "aws_subnet" "aws-pub-subnet-1" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.app_name}-pub-subnet-1"
    Environment = var.app_environment
  }
}

resource "aws_eip" "eip1-for-nat-1" {
  tags = {
    Name        = "${var.app_name}-EIP-for-NAT2"
    Environment = var.app_environment
  }
}

resource "aws_nat_gateway" "nat-1-for-pub-sub-1" {
  allocation_id = aws_eip.eip1-for-nat-1.id
  subnet_id     = aws_subnet.aws-pub-subnet-1.id

  tags = {
    Name        = "${var.app_name}-nat-1-for-pub-sub-1"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "pub-rt-1-for-pub-sub-1" {
  vpc_id = aws_vpc.aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-igw.id
  }
  tags = {
    Name        = "${var.app_name}-pub-rt-1-for-pub-sub-1"
    Environment = var.app_environment
  }

}

resource "aws_route_table_association" "pub-1-to-rtpub-1" {
  subnet_id      = aws_subnet.aws-pub-subnet-1.id
  route_table_id = aws_route_table.pub-rt-1-for-pub-sub-1.id
}


# --------------------------------------------------------
# Public Subnet 2, EIP2 and NAT 2
# --------------------------------------------------------
resource "aws_subnet" "aws-pub-subnet-2" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.app_name}-pub-subnet-2"
    Environment = var.app_environment
  }
}
resource "aws_eip" "eip2-for-nat-2" {
  tags = {
    Name        = "${var.app_name}-EIP-for-NAT1"
    Environment = var.app_environment
  }
}
resource "aws_nat_gateway" "nat-2-for-pub-sub-2" {
  allocation_id = aws_eip.eip2-for-nat-2.id
  subnet_id     = aws_subnet.aws-pub-subnet-2.id

  tags = {
    Name        = "${var.app_name}-nat-2-for-pub-sub-2"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "pub-rt-2-for-pub-sub-2" {
  vpc_id = aws_vpc.aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-igw.id
  }
  tags = {
    Name        = "${var.app_name}-pub-rt-2-for-pub-sub-2"
    Environment = var.app_environment
  }

}
resource "aws_route_table_association" "pub-2-to-rtpub-2" {
  subnet_id      = aws_subnet.aws-pub-subnet-2.id
  route_table_id = aws_route_table.pub-rt-2-for-pub-sub-2.id
}

# --------------------------------------------------------
# Private Subnet 1 and RT 1 and Route
# --------------------------------------------------------
resource "aws_subnet" "aws-priv-subnet-1" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-2c"
  tags = {
    Name        = "${var.app_name}-priv-subnet-1"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "priv-rt-1-for-priv-sub-1" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name        = "${var.app_name}-priv-rt-1-for-priv-sub-1"
    Environment = var.app_environment
  }
}
# Add a Route in Private Route Table to allow IpV4 traffic using route to NAT Gateway 
resource "aws_route" "priv1-subnet-inet-access-thru-nat1" {
  route_table_id         = aws_route_table.priv-rt-1-for-priv-sub-1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-1-for-pub-sub-1.id
}

resource "aws_route_table_association" "priv-1-to-rtpriv-1" {
  subnet_id      = aws_subnet.aws-priv-subnet-1.id
  route_table_id = aws_route_table.priv-rt-1-for-priv-sub-1.id
}


# --------------------------------------------------------
# Private Subnet 2 and RT 2 and Route
# --------------------------------------------------------
resource "aws_subnet" "aws-priv-subnet-2" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-southeast-2b"
  tags = {
    Name        = "${var.app_name}-priv-subnet-2"
    Environment = var.app_environment
  }
}
resource "aws_route_table" "priv-rt-2-for-priv-sub-2" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name        = "${var.app_name}-priv-rt-2-for-priv-sub-2"
    Environment = var.app_environment
  }
}

# Add a Route in Private Route Table to allow IpV4 traffic using route to NAT Gateway 
resource "aws_route" "priv2-subnet-inet-access-thru-nat2" {
  route_table_id         = aws_route_table.priv-rt-2-for-priv-sub-2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-2-for-pub-sub-2.id
}

resource "aws_route_table_association" "priv-2-to-rtpriv-2" {
  subnet_id      = aws_subnet.aws-priv-subnet-2.id
  route_table_id = aws_route_table.priv-rt-2-for-priv-sub-2.id
}



# --------------------------------------------------------
# IGW
# --------------------------------------------------------
resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}

##################################################################################
# APPLICATION LOAD BALANCER
##################################################################################


resource "aws_lb" "uno-application-lb" {
  name               = "uno-application-lb"
  internal           = false
  subnets            = [aws_subnet.aws-pub-subnet-1.id, aws_subnet.aws-pub-subnet-2.id, aws_subnet.aws-priv-subnet-1.id]
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-security-group.id]
  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

# Unified Listner on port 80

resource "aws_lb_listener" "uno-application-lb-listener-unified" {
  load_balancer_arn = aws_lb.uno-application-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-create.arn
  }

}

# Create Listener for Application Load Balancer 
resource "aws_lb_listener" "uno-application-lb-listener-create" {
  load_balancer_arn = aws_lb.uno-application-lb.arn
  port              = "5001"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-create.arn
  }

}

resource "aws_lb_listener_rule" "listner-rule-create" {
  listener_arn = aws_lb_listener.uno-application-lb-listener-create.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-create.arn
  }

  condition {
    path_pattern {
      values = ["/create"]
    }
  }
}

resource "aws_lb_listener" "uno-application-lb-listener-read" {
  load_balancer_arn = aws_lb.uno-application-lb.arn
  port              = "5002"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-read.arn
  }

}

resource "aws_lb_listener_rule" "listner-rule-read" {
  listener_arn = aws_lb_listener.uno-application-lb-listener-read.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-read.arn
  }

  condition {
    path_pattern {
      values = ["/read"]
    }
  }
}


resource "aws_lb_listener" "uno-application-lb-listener-update" {
  load_balancer_arn = aws_lb.uno-application-lb.arn
  port              = "5003"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-update.arn
  }

}

resource "aws_lb_listener_rule" "listner-rule-update" {
  listener_arn = aws_lb_listener.uno-application-lb-listener-update.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-update.arn
  }

  condition {
    path_pattern {
      values = ["/update"]
    }
  }
}


# Create target group to forward http request
resource "aws_lb_target_group" "uno-application-lb-tg-create" {
  name        = "uno-application-lb-tg-create"
  target_type = "ip"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws-vpc.id
  health_check {
    healthy_threshold   = 2
    interval            = 15
    path                = "/hc-create"
    timeout             = 10
    unhealthy_threshold = 5
  }
}
resource "aws_lb_target_group" "uno-application-lb-tg-read" {
  name        = "uno-application-lb-tg-read"
  target_type = "ip"
  port        = 5002
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws-vpc.id
  health_check {
    healthy_threshold   = 2
    interval            = 15
    path                = "/hc-read"
    timeout             = 10
    unhealthy_threshold = 5
  }
}
resource "aws_lb_target_group" "uno-application-lb-tg-update" {
  name        = "uno-application-lb-tg-update"
  target_type = "ip"
  port        = 5003
  protocol    = "HTTP"
  vpc_id      = aws_vpc.aws-vpc.id
  health_check {
    healthy_threshold   = 2
    interval            = 15
    path                = "/hc-update"
    timeout             = 10
    unhealthy_threshold = 5
  }
}

resource "aws_security_group" "alb-security-group" {
  name        = "alb-security-group"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.aws-vpc.id


  # HTTP 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.app_name}-ALB-SG"
    Environment = var.app_environment
  }
}


resource "aws_security_group" "ecs-service-sg" {
  name        = "ecs-service-sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.aws-vpc.id


  # HTTP 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.app_name}-ECS-SG"
    Environment = var.app_environment
  }
}

##################################################################################
# AWS ELASTIC CONTAINER SERVICE WITH FARGATE
##################################################################################

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "aws-ecs-cluster"
}

resource "aws_ecs_task_definition" "aws-ecs-task-definition-td" {
  family                   = "aws-ecs-task-definition"
  execution_role_arn       = aws_iam_role.andy-ecs-role.arn
  task_role_arn            = aws_iam_role.andy-ecs-role.arn
  container_definitions    = <<DEFINITION
              [
                {
                "name": "uno_create_container",
                "image": "001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:create_hc_v2",
                "cpu": 256,
                "memory": 512,
                "essential": true,
                "portMappings": [
                  {
                  "containerPort": 5001,
                  "hostPort": 5001
                  }
                ]
                },
                {
                "name": "uno_read_container",
                "image": "001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:read_hc_v2",
                "cpu": 256,
                "memory": 512,
                "essential": true,
                "portMappings": [
                  {
                  "containerPort": 5002,
                  "hostPort": 5002
                  }
                ]
                },
                {
                "name": "uno_update_container",
                "image": "001983725908.dkr.ecr.ap-southeast-2.amazonaws.com/uno_ecr:update_hc_v2",
                "cpu": 256,
                "memory": 512,
                "essential": true,
                "portMappings": [
                  {
                  "containerPort": 5003,
                  "hostPort": 5003
                  }
                ]
                }
             ]
             DEFINITION               
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  tags = {
    Name        = "${var.app_name}-task_definition"
    Environment = var.app_environment
  }
}

resource "aws_ecs_service" "aws-ecs-service-uno" {
  name                               = "uno-multiple-container-service"
  cluster                            = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.aws-ecs-task-definition-td.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100
  launch_type                        = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.aws-priv-subnet-1.id, aws_subnet.aws-priv-subnet-2.id]
    security_groups  = [aws_security_group.ecs-service-sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-create.arn
    container_name   = "uno_create_container"
    container_port   = 5001
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-read.arn
    container_name   = "uno_read_container"
    container_port   = 5002
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.uno-application-lb-tg-update.arn
    container_name   = "uno_update_container"
    container_port   = 5003
  }
  depends_on = [aws_lb_target_group.uno-application-lb-tg-create, aws_lb_target_group.uno-application-lb-tg-read, aws_lb_target_group.uno-application-lb-tg-update, aws_lb.uno-application-lb]

  tags = {
    Name        = "${var.app_name}-service-ecs"
    Environment = var.app_environment
  }
}

##################################################################################
# IAM ROLE FOR ECS
##################################################################################



resource "aws_iam_role" "andy-ecs-role" {
  name = "ecs-task-execution-role-modified"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""    }
  ]
}
EOF

  tags = {
    Name = "${var.app_name}-ROLE"
  }
}

resource "aws_iam_instance_profile" "andy-ecs-profile" {
  name = "Andy-IAM-profile"
  role = aws_iam_role.andy-ecs-role.name
}

resource "aws_iam_role_policy" "andy-role-policy" {
  name = "andy-role-policy"
  role = aws_iam_role.andy-ecs-role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "dynamodb:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
      }
    ]
  }
  EOF
}
