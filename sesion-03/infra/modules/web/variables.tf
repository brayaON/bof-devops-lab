variable "project" {
  description = "Prefijo para nombrar los recursos"
  type        = string
}

variable "environment" {
  description = "Nombre del entorno (dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "El entorno debe ser dev o prod."
  }
}

variable "vpc_cidr" {
  description = "Rango de la VPC; distinto por entorno para poder conectarlas en el futuro"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Rango de la subnet pública (dentro de vpc_cidr)"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t4g.micro"], var.instance_type)
    error_message = "Solo se permiten tipos pequeños en el laboratorio."
  }
}

variable "allowed_http_cidr" {
  description = "Quién puede acceder al puerto 80 (idealmente tu IP /32)"
  type        = string
}
