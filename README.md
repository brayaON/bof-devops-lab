# SupportDesk · BOF Labs
Base de la sesión 1: aplicación Go con una API y una página de tickets ficticios.
Solo utiliza la biblioteca estándar. Sin paquetes externos, Node, Docker ni AWS para arrancar.

## Preparación en Windows
1. Instala una versión estable y soportada de Go: https://go.dev/doc/install
   El módulo requiere como mínimo Go 1.22; usa una versión soportada actual, no instales una antigua solo por ese mínimo.
2. Instala Git y VS Code. La extensión Go es opcional para este ejercicio.
3. Crea y clona tu fork siguiendo la sección "Primer cambio con GitHub". Abre en VS Code la carpeta que contiene go.mod.
4. Abre una nueva terminal PowerShell:
   ```powershell
   go version
   git --version
   go test ./...
   go run .
   ```
5. Visita http://127.0.0.1:8080. Detén la app con Ctrl+C.

Si Windows no reconoce go, cierra y vuelve a abrir VS Code tras instalarlo.
Si 8080 está ocupado: $env:PORT="8081"; go run .
No necesitas activar entornos virtuales ni cambiar políticas de ejecución.

## Endpoints
| Método | Ruta | Respuesta |
|---|---|---|
| GET | / | Página con los tickets |
| GET | /health | JSON: status=ok, service=supportdesk |
| GET | /api/tickets | Array JSON de seis tickets |

Estados: open, in_progress, closed. Prioridades: high, medium, low.
La base todavía NO filtra por estado: implementarlo es el ejercicio.
No se crean ni modifican tickets en esta versión.
El health check solo confirma que el proceso HTTP responde.

## Comprobar desde otra terminal
```powershell
Invoke-RestMethod http://127.0.0.1:8080/health
Invoke-RestMethod http://127.0.0.1:8080/api/tickets
go test ./...
go vet ./...
go fmt ./...
```

## Primer cambio con GitHub

Primero crea una copia del laboratorio en tu cuenta:

1. Inicia sesión en GitHub y abre https://github.com/brayaON/bof-devops-lab.
2. Selecciona **Fork** y después **Create fork**. Conserva el nombre `bof-devops-lab`.
3. GitHub creará `https://github.com/TU_USUARIO/bof-devops-lab`. Esa será tu copia para publicar cambios.

Reemplaza `TU_USUARIO` por tu usuario de GitHub y clona tu fork:

```powershell
git clone https://github.com/TU_USUARIO/bof-devops-lab.git
cd bof-devops-lab
git remote add upstream https://github.com/brayaON/bof-devops-lab.git
git remote -v
git switch -c feat/filter-status
```

`origin` apunta a tu fork y `upstream` al laboratorio original. No trabajes directamente sobre `main`.
Si Git solicita tu identidad, configura user.name y user.email con tus datos.

Tras implementar y validar el ejercicio:

```powershell
git diff
git add main.go main_test.go
git commit -m "Add ticket status filter"
git push -u origin feat/filter-status
```

En GitHub, abre un pull request con esta dirección:

- Origen: `TU_USUARIO/bof-devops-lab`, rama `feat/filter-status`.
- Destino: `brayaON/bof-devops-lab`, rama `main`.

Incluye en el PR el objetivo, el cambio realizado y las pruebas ejecutadas.
La autenticación con GitHub se realiza con el mecanismo que tengas configurado; no pongas tokens en el código.

## Archivos
- main.go: servidor HTTP, datos de ejemplo y rutas.
- index.html: interfaz embebida en el binario.
- main_test.go: pruebas de salud, listado y rutas.
- docs/EJERCICIO.md: tarea de la primera sesión.
- AGENTS.md: contexto e instrucciones para el asistente.

## Uso de IA
Si usas chat web, adjunta main.go, main_test.go y AGENTS.md y copia los cambios propuestos al editor.
Si usas un agente en el editor, dale acceso solo a esta carpeta y revisa sus acciones.
Pide plan, cambio pequeño y evidencia de validación. No compartas credenciales ni datos de tu empresa.

## Alcance del laboratorio
Servidor local de aprendizaje, sin autenticación ni persistencia. No exponerlo directamente a Internet.
HOST predeterminado: 127.0.0.1. PORT: 8080.
En una futura sesión de contenedores se podrá usar HOST=0.0.0.0 dentro del entorno controlado.
El modelo, Docker, Terraform y el pipeline se añaden en sesiones posteriores.
