output "aws_ecs_cluster" {
  value = aws_ecs_cluster.tg-bot-cluster.name
}

output "aws_ecs_task_definition" {
  value = aws_ecs_task_definition.service.family
}

output "aws_ecs_service_bot_ip" {
  value = aws_ecs_service.tg-bot-svc
}
