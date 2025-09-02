resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
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
  container_definitions = jsonencode([
    {
      name      = var.ecs_container_name
      image     = var.ecs_image
      cpu       = 1024
      memory    = 2048
      essential = true
      command   = ["sleep", "infinity"]
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
  desired_count   = 3

  launch_type = "FARGATE"

  network_configuration {
    subnets          = var.vpc_public_subnet_cidrs # make sure these are subnet IDs, not CIDRs
    assign_public_ip = true                        # useful if no NAT in VPC
    # security_groups  = [aws_security_group.ecs.id] # define SG in your module
  }
}

