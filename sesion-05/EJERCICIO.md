# Sesión 5: publicar SupportDesk en ECR y desplegarla en ECS Fargate
## Objetivo
Llevar la imagen de la sesión 4 a AWS: publicarla en Amazon ECR y desplegarla con Terraform en ECS Fargate detrás
de un balanceador (ALB). El código de `sesion-05/infra/` (`ecr/` y `ecs/`) **ya funciona**: tu trabajo es entender cada pieza,
revisar el plan antes de aplicar, comprobar que la app responde y saber dónde mirar cuando algo falla.

## Criterios de aceptación
- **Imagen en ECR.** Creas el repositorio con Terraform desde `sesion-05/infra/ecr/` (estado en tu bucket, key
  `sesion-05/ecr/terraform.tfstate`) y explicas qué hacen `IMMUTABLE`, `scan_on_push` y la lifecycle policy.
  Publicas la imagen de tu `Dockerfile` de la sesión 4, construida para `linux/amd64`, con la etiqueta igual al
  SHA corto de tu commit (`git rev-parse --short HEAD`), y revisas el resultado del escaneo.
- **Plan revisado.** Antes de aplicar `sesion-05/infra/ecs/`, el PR incluye una tabla
  **recurso → para qué sirve → su equivalente en tu datacenter/VMware** con, al menos: repositorio ECR, VPC y
  subnets, security groups, ALB, target group, cluster, task definition, servicio y rol de ejecución.
- **La app responde en AWS.** `http://<app_url>/health` devuelve `{"status":"ok"...}` y `/api/tickets` la lista,
  desde tu máquina. Explicas por qué no se puede abrir desde otra IP.
- **Sabes dónde mirar.** Muestras en el PR, recortados: los últimos eventos del servicio, unas líneas de logs de la
  app en CloudWatch y el estado `healthy` del target.
- **Puedes explicar**, con tus palabras:
  - la diferencia entre el rol de ejecución (lo usa ECS) y un rol de tarea (lo usaría la app);
  - por qué la tarea tiene IP pública pero no se puede acceder a ella directamente;
  - en qué orden mirarías eventos, logs y salud del target si el servicio no quedara sano.
- `terraform fmt -check` y `terraform validate` pasan. No se suben `terraform.tfvars`, estado, planes ni `.terraform/`.
- Al terminar, `terraform destroy` en `sesion-05/infra/ecs/` (el ALB cobra por hora). El repositorio ECR
  **se conserva** para la sesión 6 (no destruyas `infra/ecr/`).
- La descripción del PR indica qué aportó la IA, qué corregiste y cómo lo comprobaste.

## Petición inicial sugerida para la IA
Lee AGENTS.md y los archivos de sesion-05/infra (ecr y ecs). Sin editar nada, explícame cada recurso como si yo administrara
un datacenter con VMware: qué hace, con qué se conecta y qué pasaría si faltara. Después dibuja en texto el camino
de una petición desde mi navegador hasta el contenedor, indicando en cada salto qué security group la permite.
Por último, dime qué debo revisar en el `terraform plan` antes de aplicarlo.

Si la app no responde, pega solo los eventos del servicio, unas líneas de logs y el estado del target (nunca
secretos ni el contenido de `terraform.tfvars`) y pide: "Formula hipótesis de por qué el servicio no queda sano y,
para cada una, dame un comando que la confirme o la descarte."

## Comprobaciones
```bash
export AWS_PROFILE=devops-lab
aws sts get-caller-identity
export TF_STATE_BUCKET=$(terraform -chdir=sesion-03/infra/bootstrap output -raw bucket)

# 1. Repositorio ECR y publicación de la imagen (desde la raíz del repo)
cd sesion-05/infra/ecr
cp terraform.tfvars.example terraform.tfvars        # tu owner, el mismo de la sesión 3
terraform init -backend-config="bucket=$TF_STATE_BUCKET"
terraform plan -out=tfplan && terraform apply tfplan
REPO=$(terraform output -raw repository_url)
REGISTRY=$(terraform output -raw registry)
terraform fmt -check && terraform validate
cd ../../..

TAG=$(git rev-parse --short HEAD)
docker build --platform linux/amd64 -t supportdesk:$TAG sesion-04/app
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin "$REGISTRY"
docker tag supportdesk:$TAG "$REPO:$TAG"
docker push "$REPO:$TAG"
aws ecr wait image-scan-complete --region us-east-2 --repository-name "${REPO#*/}" --image-id imageTag="$TAG"
aws ecr describe-image-scan-findings --region us-east-2 --repository-name "${REPO#*/}" \
  --image-id imageTag="$TAG" --query 'imageScanFindings.findingSeverityCounts'

# 2. Despliegue en ECS
cd sesion-05/infra/ecs
cp terraform.tfvars.example terraform.tfvars        # owner, tu IP /32 (curl -s https://checkip.amazonaws.com) e image_tag = $TAG
terraform init -backend-config="bucket=$TF_STATE_BUCKET"
terraform fmt -check && terraform validate
terraform plan -out=tfplan                          # revisa antes de aplicar
terraform apply tfplan
aws ecs wait services-stable --region us-east-2 --cluster $(terraform output -raw cluster_name) --services supportdesk
URL=$(terraform output -raw app_url)
curl -s $URL/health
curl -s $URL/api/tickets

# 3. Dónde mirar
aws ecs describe-services --region us-east-2 --cluster $(terraform output -raw cluster_name) \
  --services supportdesk --query 'services[0].events[:5].message'
aws logs tail $(terraform output -raw log_group) --region us-east-2 --since 15m
aws elbv2 describe-target-health --region us-east-2 --target-group-arn $(terraform output -raw target_group_arn) \
  --query 'TargetHealthDescriptions[].TargetHealth.State'

# 4. Al terminar
terraform destroy
```
En PowerShell, `$env:AWS_PROFILE="devops-lab"` reemplaza al `export`, y `$TAG = git rev-parse --short HEAD` define
la etiqueta. El resto de comandos funciona igual. Si el SHA ya fue publicado, haz un commit nuevo: las etiquetas
son inmutables.
