# BOF Labs · DevOps aplicado en AWS

Laboratorio de la asesoría 1:1. Cada sesión tiene su carpeta con el ejercicio, el contexto para la IA
y, cuando aplica, el código de la demo. El trabajo del participante se entrega por pull request.

## Sesiones
| # | Tema | Carpeta | Estado |
|---|---|---|---|
| 01 | Fundamentos DevOps, Git e IA | [sesion-01](sesion-01/) | ✅ |
| 02 | Infraestructura con Terraform | [sesion-02](sesion-02/) | 🟡 En curso |
| 03 | IaC para trabajar en equipo | — | ⏳ |
| 04 | Contenedores | — | ⏳ |
| 05 | Despliegue en AWS | — | ⏳ |
| 06 | CI/CD y flujos con agentes de IA | — | ⏳ |
| 07 | Observabilidad y confiabilidad | — | ⏳ |
| 08 | Seguridad, costos y aplicación al trabajo | — | ⏳ |
| 09 | Despliegue y consumo de un modelo | — | ⏳ |

## Estructura de cada sesión
```
sesion-NN/
├── EJERCICIO.md   ← objetivo, criterios de aceptación y entregable
├── AGENTS.md      ← instrucciones para el asistente o agente de IA
├── demo/          ← código mostrado en la sesión, si lo hubo
└── ...            ← código del participante (por ejemplo infra/)
```

## Sincronizar tu fork
Cuando se publique una nueva sesión, actualiza tu copia:

```bash
git switch main
git fetch upstream
git merge upstream/main
git push origin main
```

Después crea una rama para el ejercicio de la sesión, por ejemplo `git switch -c feat/sesion-02-infra`.

## Reglas del laboratorio
- Trabaja con permisos mínimos y datos ficticios; no compartas credenciales ni información de tu empresa con la IA.
- Cuenta AWS del laboratorio: región **us-east-2** únicamente. Verifica la cuenta con `aws sts get-caller-identity` antes de aplicar.
- Revisa el diff o el plan antes de aplicar cualquier cambio, y destruye los recursos al terminar.
- En cada entregable registra qué aportó la IA, qué corregiste y cómo lo comprobaste.
