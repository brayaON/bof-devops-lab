# SupportDesk · BOF Labs
Base de la sesión 1: aplicación Go con una API y una página de tickets ficticios.
Solo utiliza la biblioteca estándar. Sin paquetes externos, Node, Docker ni AWS para arrancar.

## Preparación en Windows
1. Instala una versión estable y soportada de Go: https://go.dev/doc/install
   El módulo requiere como mínimo Go 1.22; usa una versión soportada actual, no instales una antigua solo por ese mínimo.
2. Instala Git y VS Code. La extensión Go es opcional para este ejercicio.
3. Extrae el ZIP. Abre la carpeta que contiene go.mod en VS Code.
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

## Primer cambio con Git
```powershell
git init -b main
git add .
git commit -m "Initial SupportDesk application"
git switch -c feat/filter-status
```
Si Git solicita tu identidad, configura user.name y user.email con tus datos.
Crea un repositorio vacío en tu GitHub. Luego, reemplazando TU_USUARIO:
```powershell
git remote add origin https://github.com/TU_USUARIO/supportdesk-lab.git
git push -u origin main
```
Tras implementar y validar el ejercicio:
```powershell
git diff
git add main.go main_test.go
git commit -m "Add ticket status filter"
git push -u origin feat/filter-status
```
Abre un PR de feat/filter-status hacia main en GitHub. Incluye objetivo, cambio y pruebas.
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
