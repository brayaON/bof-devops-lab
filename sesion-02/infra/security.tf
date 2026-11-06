resource "aws_security_group" "web" {
  name        = "${var.project}-web"
  description = "HTTP de entrada; sin SSH (acceso por SSM)"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${var.project}-web" }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  cidr_ipv4         = var.allowed_http_cidr
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "Salida para actualizaciones de paquetes y SSM"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
