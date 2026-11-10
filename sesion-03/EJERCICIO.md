# Sesión 3: estado remoto, drift y entornos
## Objetivo
Llevar la infraestructura de la sesión 2 a un flujo de equipo: estado remoto en S3 con bloqueo, un módulo
reutilizable y entornos separados. Después, introducir un cambio manual en AWS, analizar la diferencia con IA,
comprobarla con Terraform y resolverla mediante un PR con evidencia del plan.

## Criterios de aceptación
- Partes del código base de `sesion-03/infra/`: `bootstrap/` (bucket del estado), `modules/web/` y `envs/dev/`.
- Tu bucket de estado existe, con versionado, cifrado, acceso público bloqueado y solo TLS.
- `envs/dev` usa el backend S3 con `use_lockfile = true`: no queda `terraform.tfstate` local en esa carpeta.
- Creas `envs/prod` a partir de `envs/dev`, con su propia `key` de backend y un rango de VPC que no se solapa
  con dev. Prod solo se planifica: el plan muestra recursos nuevos, sin tocar nada de dev.
- Haces al menos un cambio manual en la consola sobre un recurso de dev y lo detectas con
  `terraform plan -refresh-only`. Decides si revertirlo o incorporarlo al código y lo justificas.
- Pruebas también un cambio que Terraform **no** detecta (por ejemplo, una regla nueva en el security group)
  y explicas por qué no aparece en el plan.
- La descripción del PR incluye la salida del plan antes y después de resolver el drift, y qué aportó la IA,
  qué corregiste y cómo lo comprobaste.
- Se mantiene: región `us-east-2`, IMDSv2 obligatorio, sin SSH (puerto 22), sin NAT Gateway, rol IAM con permisos mínimos.
- `terraform fmt -check -recursive` y `terraform validate` pasan en cada carpeta.
- No se suben `terraform.tfstate`, `terraform.tfvars`, planes guardados ni la carpeta `.terraform/`.

## Petición inicial sugerida para la IA
Lee AGENTS.md y los archivos .tf de sesion-03/infra. Primero explícame cómo se relacionan bootstrap/,
modules/web/ y envs/dev/, y dónde queda guardado el estado de cada uno. Después quiero crear envs/prod a partir
de envs/dev, con su propia key de backend y la VPC 10.20.0.0/16. Muestra el diff propuesto antes de editar
y dime qué esperas ver en el plan. No ejecutes apply.

Para analizar el drift, pega solo la salida de `terraform plan -refresh-only` (nunca el estado) y pide:
"Explica qué cambió fuera de Terraform, el riesgo de cada cambio y si conviene revertirlo o incorporarlo
al código. No propongas comandos de state ni ignore_changes."

## Comprobaciones
```bash
export AWS_PROFILE=devops-lab
aws sts get-caller-identity
cd sesion-03/infra
terraform fmt -check -recursive

# 1. Bucket del estado (una vez; se conserva para las próximas sesiones)
cd bootstrap
terraform init && terraform validate
terraform plan -out=tfplan        # revisa antes de aplicar
terraform apply tfplan
export TF_STATE_BUCKET=$(terraform output -raw bucket)

# 2. Entorno dev con estado remoto
cd ../envs/dev
terraform init -backend-config="bucket=$TF_STATE_BUCKET"
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
aws s3 ls "s3://$TF_STATE_BUCKET/sesion-03/dev/"

# 3. Drift: después del cambio manual
terraform plan -refresh-only
terraform plan -detailed-exitcode; echo "exit=$?"   # 2 = hay diferencias, 0 = ninguna

# 4. Prod: solo plan
cd ../prod
terraform init -backend-config="bucket=$TF_STATE_BUCKET"
terraform plan
```
Al terminar, destruye dev (`terraform destroy` en `envs/dev`) y verifica en la consola (región Ohio, us-east-2)
que no quedan instancias. El bucket del estado **se conserva**.
