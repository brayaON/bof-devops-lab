# AMI más reciente de Amazon Linux 2023, publicada por AWS en SSM Parameter Store.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  # IMDSv2 obligatorio
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>${var.project}</h1><p>Desplegado con Terraform - Sesion 02</p>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOT

  # Si cambia el user_data, la instancia se reemplaza (útil para ver -/+ en el plan).
  user_data_replace_on_change = true

  tags = { Name = "${var.project}-web" }
}