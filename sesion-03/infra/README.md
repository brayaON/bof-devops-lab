# Código base de la sesión 3

Punto de partida para el ejercicio (`../EJERCICIO.md`). La infraestructura de la sesión 2 ahora es un módulo,
y cada entorno guarda su estado en S3.

```
infra/
├── bootstrap/     ← bucket S3 del estado; usa estado local y se aplica una sola vez
├── modules/web/   ← VPC, subnet pública, security group, rol SSM y EC2 con nginx
└── envs/
    └── dev/       ← usa el módulo; estado en s3://<bucket>/sesion-03/dev/terraform.tfstate
```
`envs/prod` lo creas tú en el ejercicio.

Costo aproximado: bucket ≈ USD 0 (unos KB); cada entorno aplicado ≈ USD 0.015/h (EC2 + IPv4 pública).

## Antes de empezar
```bash
aws login --profile devops-lab
export AWS_PROFILE=devops-lab
aws sts get-caller-identity
```
Copia cada `terraform.tfvars.example` a `terraform.tfvars` y complétalo. `owner` forma parte del nombre del
bucket: usa minúsculas y guiones. Tu IP: `curl -s https://checkip.amazonaws.com`.

## Recorrido del código
1. `bootstrap/main.tf`: el bucket del estado con versionado, cifrado, bloqueo público, política solo TLS,
   expiración de versiones antiguas y `prevent_destroy`. El ID de cuenta se lee con `aws_caller_identity`.
2. `modules/web/`: lo mismo que en la sesión 2, con la variable `environment` en los nombres.
3. `envs/dev/main.tf`: el bloque `backend "s3"` (sin el bucket, que se pasa en el `init`), el provider con
   `default_tags` y la llamada al módulo.

## Bucket del estado
```bash
cd bootstrap
terraform init
terraform plan -out=tfplan
terraform apply tfplan
export TF_STATE_BUCKET=$(terraform output -raw bucket)
```
El bucket se conserva para las sesiones siguientes. Para borrarlo al final del programa: quita
`prevent_destroy`, vacía todas las versiones del bucket y ejecuta `terraform destroy` en esta carpeta.

## Entorno dev
```bash
cd envs/dev
terraform init -backend-config="bucket=$TF_STATE_BUCKET"
terraform plan -out=tfplan
terraform apply tfplan
terraform output ssm_command
```

## Ver el bloqueo
Deja un `terraform apply` esperando en el prompt y, en otra terminal de la misma carpeta, ejecuta
`terraform plan`: verás `Error acquiring the state lock`. Responde `no` en la primera terminal para liberar el lock.

## Limpieza
```bash
cd envs/dev && terraform destroy
```
