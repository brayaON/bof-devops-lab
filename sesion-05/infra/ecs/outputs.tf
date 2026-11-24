output "app_url" {
  description = "URL pública de la app (a través del ALB)"
  value       = "http://${aws_lb.app.dns_name}"
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "service_name" {
  value = aws_ecs_service.app.name
}

output "log_group" {
  value = aws_cloudwatch_log_group.app.name
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}

output "image" {
  description = "Imagen que corre el servicio"
  value       = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
}
