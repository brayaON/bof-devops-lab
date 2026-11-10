terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Estado remoto en S3, una llave por entorno. El bucket se pasa en el init
  # (-backend-config) para no escribir el ID de cuenta en el código.
  backend "s3" {
    key          = "sesion-03/dev/terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true
    use_lockfile = true # bloqueo nativo de S3: un archivo .tflock junto al estado
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      Project     = var.project
      Owner       = var.owner
      Environment = "dev"
      ManagedBy   = "terraform"
      Session     = "03"
    }
  }
}

module "web" {
  source = "../../modules/web"

  project            = var.project
  environment        = "dev"
  vpc_cidr           = "10.10.0.0/16"
  public_subnet_cidr = "10.10.1.0/24"
  instance_type      = "t3.micro"
  allowed_http_cidr  = var.allowed_http_cidr
}
