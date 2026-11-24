# Dockerfile base de la sesión 4. Construye y arranca, pero NO está listo para producción:
# revísalo y corrígelo siguiendo EJERCICIO.md.
FROM golang:1.27

RUN apt-get update && apt-get install -y curl vim net-tools

WORKDIR /app
COPY . .
RUN go build -o supportdesk .

EXPOSE 8080
CMD ["./supportdesk"]
