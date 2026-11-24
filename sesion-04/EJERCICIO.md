# Sesión 4: containerizar SupportDesk
## Objetivo
Convertir la app de la sesión 1 en una imagen de contenedor confiable: que arranque y responda, que sea pequeña,
y que no lleve secretos ni corra como root. En la sesión 5 la publicaremos en Amazon ECR y la desplegaremos en ECS.
El `Dockerfile` de `sesion-04/app/` **funciona a medias a propósito**: tu trabajo es revisarlo con IA,
comprobar cada problema con un comando y corregirlo.

## Criterios de aceptación
- Partes del código base de `sesion-04/app/` (SupportDesk + `Dockerfile` con fallos).
- `docker run -p 8080:8080 <imagen>` responde en `http://localhost:8080/health` y `/api/tickets` **desde tu máquina**.
  Explicas por qué la imagen base arrancaba pero no respondía.
- No modificas `main.go`: la configuración (HOST, PORT) llega por variables de entorno.
- Build multi-stage: la imagen final no contiene el compilador de Go, ni `curl`, `vim` u otros paquetes que la app no usa.
  Tamaño final menor a 50 MB.
- La imagen corre con un usuario sin privilegios: `docker inspect -f '{{.Config.User}}'` no está vacío ni es `root` o `0`.
- No hay secretos en la imagen: el archivo `.env` no está dentro, no hay valores sensibles en `ENV` ni `ARG`
  (revisa `docker history --no-trunc` y `docker inspect`), y existe un `.dockerignore` que excluye `.env` y `.git`.
- Las imágenes base usan una versión fija (nada de `latest`).
- La imagen es `linux/amd64` (la arquitectura que usaremos en Fargate en la sesión 5).
- La descripción del PR incluye una tabla **hallazgo → comando con que lo comprobaste → corrección**, el tamaño
  antes/después y qué aportó la IA, qué corregiste y cómo lo comprobaste.
- `go test ./...` pasa.
- No se sube el archivo `.env`.

## Petición inicial sugerida para la IA
Lee AGENTS.md, el Dockerfile y main.go de sesion-04/app. Primero, sin editar nada, revisa el Dockerfile para
producción y clasifica los problemas en: red, usuario de ejecución, secretos, dependencias y tamaño. Para cada
problema dime con qué comando de docker lo compruebo y qué resultado espero ver. Después propón un Dockerfile
multi-stage para linux/amd64 y un .dockerignore, con versiones fijas y usuario sin privilegios, sin modificar
main.go. Muestra el diff antes de editar.

Si la imagen no responde, pega solo la salida de `docker ps` y `docker logs` (nunca el contenido de `.env`) y pide:
"Formula hipótesis de por qué el contenedor está arriba pero no responde, y para cada una dame un comando que la
confirme o la descarte."

## Comprobaciones
```bash
cd sesion-04/app
go test ./...

# 1. La imagen base: compruébala antes de corregir
cp .env.example .env
docker build --platform linux/amd64 -t supportdesk:base .
docker run -d --name sd-base --env-file .env -p 8080:8080 supportdesk:base
curl -s localhost:8080/health           # ¿responde? revisa docker logs sd-base
docker exec sd-base whoami
docker exec sd-base cat /app/.env
docker image inspect -f '{{.Size}}' supportdesk:base
docker rm -f sd-base

# 2. Tu imagen corregida
docker build --platform linux/amd64 -t supportdesk:local .
docker run -d --name sd --read-only --env-file .env -p 8080:8080 supportdesk:local
curl -s localhost:8080/health
curl -s localhost:8080/api/tickets
docker logs sd
docker inspect -f 'user={{.Config.User}} arch={{.Architecture}}' supportdesk:local
docker history --no-trunc supportdesk:local
docker image inspect -f '{{.Size}}' supportdesk:local
docker rm -f sd

```
En PowerShell los comandos de `docker` y `curl` funcionan igual (usa `curl.exe` si `curl` abre `Invoke-WebRequest`).

Al terminar, elimina los contenedores locales (`docker rm -f`). En la sesión 5 publicaremos esta imagen en ECR y
la desplegaremos en ECS.
