variable "project" {
  description = "Prefijo para nombrar los recursos"
  type        = string
  default     = "devops-lab"
}

variable "owner" {
  description = "Tu nombre corto, el mismo del repositorio ECR (minúsculas, números y guiones)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.owner))
    error_message = "Usa de 2 a 20 caracteres: minúsculas, números y guiones."
  }
}

variable "allowed_http_cidr" {
  description = "Quién puede abrir la app en el navegador (tu IP /32)"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_http_cidr, 0)) && var.allowed_http_cidr != "0.0.0.0/0"
    error_message = "Usa un CIDR válido y acotado, por ejemplo 203.0.113.10/32."
  }
}

variable "image_tag" {
  description = "Etiqueta de la imagen en ECR (el SHA corto del commit)"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango de la VPC; las subnets se calculan a partir de él"
  type        = string
  default     = "10.50.0.0/16"
}

variable "container_port" {
  description = "Puerto en el que escucha la app dentro del contenedor"
  type        = number
  default     = 8080
}
