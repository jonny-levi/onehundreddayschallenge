resource "aws_ecs_cluster" "tg-bot-cluster" {
  name = "tg-bot-cluster"

  setting {
    name  = "tg-bot-cluster"
    value = "enabled"

  }
}


resource "aws_ecs_task_definition" "service" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}

resource "aws_ecs_service" "tg-bot-svc" {
  name            = "TGBotSVC"
  cluster         = aws_ecs_cluster.tg-bot-cluster.id
  task_definition = aws_ecs_task_definition.mongo.arn
  desired_count   = 3
  iam_role        = aws_iam_role.foo.arn
  depends_on      = [aws_iam_role_policy.foo]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  #   load_balancer {
  #     target_group_arn = aws_lb_target_group.foo.arn
  #     container_name   = "mongo"
  #     container_port   = 8080
  #   }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a]"
  }
}
