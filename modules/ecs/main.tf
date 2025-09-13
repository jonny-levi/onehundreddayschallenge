resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_security_group" "allow_egress_only" {
  name        = "allow_egress_only"
  description = "Aallow_egress_only outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_egress_only"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_egress_only.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.allow_egress_only.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Attach the AWS managed policy that allows ECR pull and CloudWatch logs
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "tg-bot-cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.tg-bot-cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = var.task_definition_family_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = var.ecs_container_name
      image     = var.ecs_image
      cpu       = 1024
      memory    = 2048
      essential = true
      environment = [
        for key, value in var.ecs_environment : {
          name  = key
          value = value
        }
      ]
      portMappings = [
        {
          containerPort = var.ecs_containerport
          hostPort      = var.ecs_hostport
        }
      ]
    }
  ])
}
resource "aws_ecs_service" "tg-bot-svc" {
  name            = var.ecs_sevice_name
  cluster         = aws_ecs_cluster.tg-bot-cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.ecs_container_count

  launch_type = "FARGATE"

  network_configuration {
    subnets          = var.vpc_public_subnet_cidrs # make sure these are subnet IDs, not CIDRs
    assign_public_ip = true                        # useful if no NAT in VPC
    security_groups  = [aws_security_group.allow_egress_only.id]
  }
}
