# Sesión 2: red e instancia con Terraform
## Objetivo
Describir en Terraform una red y una instancia en AWS con ayuda de IA, validar el código
y revisar el plan antes de aplicar. Justificar permisos, conectividad y costos.

## Criterios de aceptación
- El código vive en `sesion-02/infra/`.
- Región `us-east-2`; provider `hashicorp/aws` con versión fijada en `required_providers`.
- VPC con al menos una subnet pública, Internet Gateway y tabla de rutas asociada.
- Una instancia EC2 de tipo pequeño (t3.micro o similar) con IMDSv2 obligatorio.
- Security group sin SSH (puerto 22) abierto a Internet; HTTP limitado a tu IP si es posible.
- Acceso administrativo por Session Manager mediante un rol IAM con permisos mínimos.
- Sin NAT Gateway ni recursos de costo fijo alto.
- Variables con descripción y tipo; outputs con al menos la IP pública y el ID de la instancia.
- `terraform fmt -check` y `terraform validate` pasan sin errores.
- No se suben `terraform.tfstate`, `terraform.tfvars` ni la carpeta `.terraform/`.

## Petición inicial sugerida para la IA
Lee AGENTS.md de esta carpeta. Quiero código Terraform para AWS en us-east-2: una VPC con una subnet
pública, Internet Gateway y tabla de rutas, y una EC2 t3.micro con Amazon Linux 2023 que sirva una página
con nginx. Sin SSH: acceso por Session Manager con un rol IAM de permisos mínimos. IMDSv2 obligatorio.
Sin NAT Gateway. Usa variables y outputs. Propón primero la lista de recursos y explica qué alternativa
descartas en cada decisión (por ejemplo SSH vs SSM). No ejecutes apply.

## Comprobaciones
```bash
cd sesion-02/infra
export AWS_PROFILE=devops-lab
aws sts get-caller-identity
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
```
Lee el plan antes de aplicar: cuántos recursos se crean, qué queda expuesto a Internet
y qué permisos IAM se otorgan. Aplica solo si coincide con lo esperado y destruye al terminar.

## Entregable
Un PR hacia `main` con el código de `sesion-02/infra/` y en la descripción:
- Resumen del plan (línea `Plan: N to add...`) y la URL o salida que confirma que funcionó.
- Justificación de permisos (qué otorga el rol y por qué), conectividad (qué puertos y desde dónde) y costo estimado por hora.
- Qué propuso la IA, qué corregiste y cómo lo comprobaste.
- Confirmación de que ejecutaste `terraform destroy`.
