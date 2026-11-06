output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "instance_id" {
  description = "ID de la instancia (para conectarse por SSM)"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "IP pública de la instancia"
  value       = aws_instance.web.public_ip
}

output "url" {
  description = "URL de la página de prueba"
  value       = "http://${aws_instance.web.public_ip}"
}
