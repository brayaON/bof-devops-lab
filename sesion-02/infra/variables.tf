variable "region" {
  description = "Región de AWS del laboratorio"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Prefijo para nombrar los recursos"
  type        = string
  default     = "devops-lab"
}

variable "owner" {
  description = "Responsable de los recursos (etiqueta Owner)"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Rango de la subnet pública"
  type        = string
  default     = "10.0.1.0/24"
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
  default     = "0.0.0.0/0"
}
