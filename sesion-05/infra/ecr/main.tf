terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Mismo bucket de estado de la sesión 3; el repositorio se conserva para la sesión 6.
  backend "s3" {
    key          = "sesion-05/ecr/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Project   = var.project
      Owner     = var.owner
      ManagedBy = "terraform"
      Session   = "05"
    }
  }
}

resource "aws_ecr_repository" "app" {
  name = "${var.project}/supportdesk-${var.owner}"

  # Una etiqueta publicada no se puede sobrescribir: "a1b2c3d" siempre es la misma imagen.
  image_tag_mutability = "IMMUTABLE"

  # Escaneo básico de vulnerabilidades en cada push (sin costo).
  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  # Si quedan imágenes, el destroy falla en lugar de borrarlas en silencio.
  force_delete = false
}

# Sin limpieza, el registro crece con cada push (como snapshots de VMware que nadie borra).
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Borrar imágenes sin etiqueta después de 1 día"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Conservar solo las últimas 10 imágenes"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
