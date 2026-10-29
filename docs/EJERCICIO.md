# Sesión 1: filtrar tickets por estado
## Objetivo
Completar un cambio pequeño: definir comportamiento, pedir ayuda a IA, revisar, probar y abrir un PR.

## Criterios de aceptación
- GET /api/tickets sigue devolviendo los seis tickets.
- GET /api/tickets?status=open devuelve solo los dos tickets open.
- in_progress y closed también devuelven dos tickets cada uno.
- status vacío equivale a no filtrar.
- Un estado no admitido, como invalid u OPEN, devuelve HTTP 400 y un error JSON claro.
- Se conserva el array JSON como formato de respuesta.
- Los endpoints / y /health siguen funcionando.
- Solo se modifica el backend y sus pruebas; el selector visual queda para después.

## Petición inicial sugerida para la IA
Lee main.go, main_test.go y AGENTS.md. Quiero agregar un filtro opcional por status a GET /api/tickets.
Los valores aceptados son open, in_progress y closed. Sin filtro o con status vacío se conservan todos
los tickets. Un valor inválido debe devolver 400 con un error JSON. Mantén el formato de array.
Propón un plan breve y los casos de prueba antes de modificar código. No agregues dependencias.

## Comprobaciones
Antes del cambio, consulta ?status=open: devuelve seis tickets; ese es el comportamiento por cambiar.
Después, ejecuta go test ./... y prueba desde PowerShell:
```powershell
Invoke-RestMethod "http://127.0.0.1:8080/api/tickets?status=open"
Invoke-RestMethod "http://127.0.0.1:8080/api/tickets?status=closed"
Invoke-RestMethod "http://127.0.0.1:8080/api/tickets?status=invalid"
```
La última llamada debe producir un error HTTP 400. Reinicia go run . tras editar: no hay recarga automática.
Los tests nuevos deben verificar contenidos y códigos HTTP, no solo el número de tickets.
## Cierre
Explica qué cambió, por qué y cómo comprobaste el resultado. Abre el PR.
## Práctica independiente
Agrega filtro por prioridad. Decide y documenta qué debe pasar al combinar status y priority;
se sugiere que ambos deban cumplirse. Verifica combinación sin coincidencias: [] y HTTP 200.
Entrega el PR con un resumen de qué propuso la IA, qué corregiste y evidencia de las pruebas.
