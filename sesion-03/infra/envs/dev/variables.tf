variable "project" {
  description = "Prefijo para nombrar los recursos"
  type        = string
  default     = "devops-lab"
}

variable "owner" {
  description = "Responsable de los recursos (etiqueta Owner)"
  type        = string
}

variable "allowed_http_cidr" {
  description = "Quién puede acceder al puerto 80 (tu IP /32)"
  type        = string
}
