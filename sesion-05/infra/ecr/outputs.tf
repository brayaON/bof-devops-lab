output "repository_url" {
  description = "Dirección para docker tag / docker push"
  value       = aws_ecr_repository.app.repository_url
}

output "registry" {
  description = "Servidor del registro, para docker login"
  value       = split("/", aws_ecr_repository.app.repository_url)[0]
}

output "repository_arn" {
  description = "ARN del repositorio, para políticas IAM (sesiones 5 y 6)"
  value       = aws_ecr_repository.app.arn
}
