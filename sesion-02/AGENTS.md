# Contexto de la sesión 2
Infraestructura con Terraform en AWS. El participante aprende IaC; explica cada recurso con lenguaje sencillo.
- Lee la petición y propone la lista de recursos antes de escribir código.
- Región us-east-2: la cuenta del laboratorio deniega las demás regiones.
- Fija la versión del provider y usa argumentos vigentes en esa versión; si dudas de uno, dilo.
- Permisos mínimos: nada de `"*"` en acciones o recursos IAM, ni políticas administradas amplias.
- No abras el puerto 22 ni uses key pairs; el acceso es por Session Manager.
- Evita recursos de costo fijo (NAT Gateway, instancias grandes, IPs elásticas sin uso) y menciona el costo de lo que propongas.
- No escribas credenciales, IDs de cuenta ni secretos en el código.
- Puedes ejecutar `terraform fmt`, `validate` y `plan`. No ejecutes `apply` ni `destroy` sin aprobación explícita.
- Nunca leas ni compartas `terraform.tfstate` ni `terraform.tfvars`.
- Explica los archivos modificados y las comprobaciones realizadas; si no pudiste ejecutar algo, decláralo.
