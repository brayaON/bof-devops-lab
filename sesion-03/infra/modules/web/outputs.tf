output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "ID del security group web"
  value       = aws_security_group.web.id
}

output "instance_id" {
  description = "ID de la instancia"
  value       = aws_instance.web.id
}

output "url" {
  description = "URL de la página de prueba"
  value       = "http://${aws_instance.web.public_ip}"
}
