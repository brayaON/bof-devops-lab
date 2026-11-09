output "instance_id" {
  description = "ID de la instancia"
  value       = module.web.instance_id
}

output "security_group_id" {
  description = "ID del security group web"
  value       = module.web.security_group_id
}

output "url" {
  description = "URL de la página de prueba"
  value       = module.web.url
}

output "ssm_command" {
  description = "Comando para entrar a la instancia sin SSH"
  value       = "aws ssm start-session --region us-east-2 --target ${module.web.instance_id}"
}
