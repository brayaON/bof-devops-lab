# Contexto de la sesión 3
IaC para trabajar en equipo: estado remoto en S3, bloqueo, drift y entornos separados con un módulo.
El participante viene de infraestructura y VMware; explica cada cambio con lenguaje sencillo.
- Lee la petición y propone el cambio mínimo antes de editar; muestra el diff y el resultado esperado del plan.
- Región us-east-2: la cuenta del laboratorio deniega las demás regiones.
- Fija la versión del provider y usa argumentos vigentes en esa versión; si dudas de uno, dilo.
- El bloque `backend` no admite variables: el bucket se pasa con `-backend-config`. No escribas IDs de cuenta.
- Bloqueo con `use_lockfile = true`; no agregues tablas de DynamoDB ni llaves KMS propias sin justificarlo.
- Cada entorno tiene su propia `key` de backend y rangos de red que no se solapan. Nunca compartas la `key` entre entornos.
- Para refactorizar usa bloques `moved` o `import`; el plan no debe destruir recursos que solo cambian de dirección.
- Ante drift, explica el riesgo y recomienda revertir o incorporar. No uses `ignore_changes` para ocultarlo.
- Permisos mínimos: nada de `"*"` en acciones o recursos IAM. Sin puerto 22 ni key pairs; acceso por Session Manager.
- Evita recursos de costo fijo (NAT Gateway, instancias grandes, IPs elásticas sin uso) y menciona el costo de lo que propongas.
- Puedes ejecutar `terraform fmt`, `validate` y `plan`. No ejecutes `apply`, `destroy`, `force-unlock`
  ni comandos `terraform state` que modifiquen el estado sin aprobación explícita.
- Nunca leas ni compartas `terraform.tfstate`, `terraform.tfvars` ni el contenido del bucket del estado.
- Explica los archivos modificados y las comprobaciones realizadas; si no pudiste ejecutar algo, decláralo.
