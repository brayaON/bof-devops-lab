# Sesión 2: red e instancia con Terraform
## Objetivo
Partir del código base de `sesion-02/infra/` (una red y una instancia en AWS), entenderlo y ajustarlo
con ayuda de IA, validar el código y revisar el plan antes de aplicar. Justificar permisos, conectividad y costos.

## Criterios de aceptación
- El código vive en `sesion-02/infra/` y parte del código base de esa carpeta.
- Puedes explicar qué hace cada recurso y por qué está ahí.
- Ajustes sobre la base:
  - HTTP limitado a tu IP (`allowed_http_cidr` en `terraform.tfvars`).
  - Una segunda subnet pública en otra zona de disponibilidad, asociada a la misma tabla de rutas.
  - Un output con el comando para conectarse por Session Manager.
- Se mantiene: región `us-east-2`, IMDSv2 obligatorio, sin SSH (puerto 22), sin NAT Gateway, rol IAM con permisos mínimos.
- `terraform fmt -check` y `terraform validate` pasan sin errores.
- No se suben `terraform.tfstate`, `terraform.tfvars` ni la carpeta `.terraform/`.

## Petición inicial sugerida para la IA
Lee AGENTS.md y los archivos .tf de sesion-02/infra. Primero explícame en lenguaje sencillo qué crea este
código y cómo se conectan los recursos. Después quiero agregar una segunda subnet pública en otra zona de
disponibilidad, asociada a la misma tabla de rutas, y un output con el comando de Session Manager.
Propón el cambio mínimo y cómo se verá en el plan antes de editar. No ejecutes apply.

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
