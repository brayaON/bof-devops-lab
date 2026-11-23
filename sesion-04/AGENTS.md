# Contexto de la sesión 4
Contenedores: Dockerfile, imágenes, redes, volúmenes, configuración y logs.
El participante viene de infraestructura y VMware; explica cada cambio con lenguaje sencillo.
- Antes de editar, revisa y explica los problemas encontrados; muestra el diff y cómo comprobar cada corrección con un comando.
- No modifiques `main.go` ni las pruebas: la configuración de la app (HOST, PORT) se pasa por variables de entorno.
- Imágenes `linux/amd64`, build multi-stage, imágenes base con versión fija (nunca `latest`) y usuario sin privilegios.
- La imagen final solo lleva lo necesario para ejecutar: sin compilador, gestor de paquetes ni herramientas de depuración.
- Secretos: nunca en el Dockerfile, en `ENV`, en `ARG` ni copiados a la imagen. `.env` va en `.dockerignore` y en `.gitignore`.
  No leas ni muestres el contenido de `.env`.
- La app escribe sus logs en stdout; no agregues archivos de log ni volúmenes que la app no necesita.
- Si un contenedor no responde, formula hipótesis y propone un comando que confirme o descarte cada una antes de cambiar código.
- Puedes ejecutar `go test`, `docker build`, `docker run`, `docker logs` y `docker inspect`.
  No publiques imágenes (`docker push`) ni borres imágenes o contenedores ajenos a la sesión sin aprobación explícita.
- Explica los archivos modificados y las comprobaciones realizadas; si no pudiste ejecutar algo, decláralo.
