variable "project" {
  description = "Prefijo para nombrar los recursos"
  type        = string
  default     = "devops-lab"
}

variable "owner" {
  description = "Responsable de los recursos; forma parte del nombre del repositorio"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.owner))
    error_message = "Usa minúsculas, números y guiones (2 a 20 caracteres)."
  }
}
