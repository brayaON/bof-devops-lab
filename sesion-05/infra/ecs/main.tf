terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Mismo bucket de estado de la sesión 3, otra key. El bucket se pasa con -backend-config.
  backend "s3" {
    key          = "sesion-05/ecs/terraform.tfstate"
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

locals {
  name = "${var.project}-${var.owner}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# El repositorio de ECR lo crea ../ecr (y se conserva); aquí solo se lee.
data "aws_ecr_repository" "app" {
  name = "${var.project}/supportdesk-${var.owner}"
}
