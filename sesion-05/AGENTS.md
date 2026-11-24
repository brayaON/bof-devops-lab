# Contexto de la sesión 5
Despliegue en AWS: Amazon ECR, ECS Fargate, ALB, health checks y permisos (rol de ejecución).
El participante viene de infraestructura y VMware; explica cada recurso con analogías de su mundo y lenguaje sencillo.
- El código de `infra/ecr/` e `infra/ecs/` funciona. Tu tarea principal es **explicar y revisar**, no reescribir. Antes de editar,
  explica el problema, muestra el diff y cómo comprobar el cambio.
- Región `us-east-2` (las demás están bloqueadas). Perfil `devops-lab`. Provider con versión fija, bucket del backend
  por `-backend-config`, sin IDs de cuenta escritos en el código.
- Imagen `linux/amd64` desde `sesion-04/app`; la task definition usa `X86_64`. La etiqueta es el SHA corto del commit.
- ECR (`infra/ecr/`): mantén `IMMUTABLE`, `scan_on_push` y `force_delete = false`. El repositorio se conserva para la
  sesión 6: no propongas destruirlo.
- Secretos: nunca en el código, en `environment`, en el estado de Terraform ni en la conversación. Esta app todavía no
  usa ninguno; si hiciera falta, iría en SSM Parameter Store referenciado por nombre en `secrets`.
- Mantén lo que protege el entorno: security group del ALB solo desde `allowed_http_cidr` (nunca `0.0.0.0/0`), tarea
  accesible solo desde el security group del ALB, `readonlyRootFilesystem`, circuit breaker con rollback, retención
  de logs de 7 días.
- Permisos mínimos: el rol de ejecución solo tiene la política administrada de ECS; nada de `"*"` en acciones ni
  recursos propios.
  `ecr:GetAuthorizationToken` (en la política administrada) solo admite `"*"` como recurso: es la excepción.
  Si propones un permiso nuevo, explica por qué hace falta.
- Sin costo fijo alto: no agregues NAT Gateway, VPC endpoints de interfaz, Container Insights ni más tareas sin
  explicar el costo por hora y pedir aprobación.
- Diagnóstico: formula hipótesis y para cada una propone un comando que la confirme o descarte, en este orden:
  eventos del servicio / motivo de parada de la tarea → logs en CloudWatch → salud del target group.
- Puedes ejecutar `terraform fmt`, `validate`, `plan`, `docker build` y comandos `aws` de solo lectura
  (`describe-*`, `list-*`, `logs tail`). No ejecutes `terraform apply`, `destroy`, `docker push`
  ni nada que cree, cambie o borre recursos sin aprobación explícita.
- Explica los archivos modificados y las comprobaciones realizadas; si no pudiste ejecutar algo, decláralo.
