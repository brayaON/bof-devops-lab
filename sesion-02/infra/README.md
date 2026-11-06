# Código base de la sesión 2

Punto de partida para el ejercicio (`../EJERCICIO.md`): una VPC con subnet pública, Internet Gateway,
security group (solo HTTP), rol IAM para Session Manager y una EC2 t3.micro con nginx.

Costo aproximado: USD 0.015/h (EC2 + IPv4 pública). Destrúyelo al terminar.

## Antes de empezar
- La cuenta del laboratorio solo permite la región **us-east-2**.
- Inicia sesión y confirma la cuenta antes de cualquier comando de Terraform:
  ```bash
  aws login --profile devops-lab
  export AWS_PROFILE=devops-lab
  aws sts get-caller-identity
  ```
- Copia `terraform.tfvars.example` a `terraform.tfvars` y completa `owner` y tu IP
  (`curl -s https://checkip.amazonaws.com`). `terraform.tfvars` no se sube a Git.

## Recorrido del código
`versions.tf` → `variables.tf` → `network.tf` → `security.tf` → `iam.tf` → `compute.tf` → `outputs.tf`.
Observa las referencias entre recursos (`aws_vpc.main.id`), la diferencia entre `data` y `resource`,
los `default_tags` del provider y la `validation` de `instance_type`.

## Ciclo básico
```bash
terraform init
terraform fmt && terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform output url        # nginx puede tardar ~1 min en responder
```

## Ver cómo cambia el plan
- Cambia una etiqueta de la subnet: el plan muestra `~` (cambio en el lugar).
- Cambia el texto del `user_data`: muestra `-/+` (reemplazo).
- Usa `instance_type = "m5.large"`: la validación lo rechaza antes de llamar a AWS.

## Acceso sin SSH
```bash
aws ssm start-session --region us-east-2 --target $(terraform output -raw instance_id)
```

## Limpieza
```bash
terraform destroy
```
Verifica en la consola (región Ohio, us-east-2) que no quedan instancias.
