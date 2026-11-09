terraform {
  required_version = ">= 1.10" # use_lockfile en el backend S3 requiere 1.10+

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # El bootstrap usa estado local: es el "huevo" que crea la "gallina" (el bucket de estado).
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      Owner     = var.owner
      ManagedBy = "terraform"
      Session   = "03"
    }
  }
}

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
  description = "Responsable de los recursos; forma parte del nombre del bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.owner))
    error_message = "Usa minúsculas, números y guiones (2 a 20 caracteres)."
  }
}

# El ID de cuenta se lee en tiempo de ejecución: no se escribe en el código.
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "state" {
  bucket = "${var.project}-${var.owner}-tfstate-${data.aws_caller_identity.current.account_id}"

  # Perder este bucket es perder el inventario de toda la infraestructura.
  lifecycle {
    prevent_destroy = true
  }

  tags = { Name = "${var.project}-tfstate" }
}

# Versionado: cada escritura del estado deja una versión recuperable (como snapshots).
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Cifrado en reposo con llaves administradas por S3 (sin costo, a diferencia de una CMK de KMS).
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Las versiones antiguas del estado se borran a los 90 días para que no crezcan sin límite.
resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expirar-versiones-antiguas"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  depends_on = [aws_s3_bucket_versioning.state]
}

# Solo conexiones cifradas (TLS): el estado puede contener datos sensibles.
data "aws_iam_policy_document" "state_tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.state_tls_only.json

  depends_on = [aws_s3_bucket_public_access_block.state]
}

output "bucket" {
  description = "Bucket del estado remoto (usar en terraform init -backend-config)"
  value       = aws_s3_bucket.state.bucket
}
