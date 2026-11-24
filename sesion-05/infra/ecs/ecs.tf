# Cluster → task definition (la "ficha" del contenedor) → servicio (mantiene N tareas vivas detrás del ALB).

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name}/supportdesk"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled" # tiene costo; lo veremos en la sesión 7
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name}-supportdesk"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 # 0.25 vCPU
  memory                   = 512 # MB
  execution_role_arn       = aws_iam_role.execution.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64" # la imagen se construye para linux/amd64
  }

  container_definitions = jsonencode([
    {
      name      = "supportdesk"
      image     = "${data.aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]

      # Configuración: variables de entorno, igual que docker run -e.
      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = tostring(var.container_port) },
      ]

      readonlyRootFilesystem = true

      # Lo que la app escribe en stdout llega a CloudWatch Logs.
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "supportdesk"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = true # sin NAT: la IP pública permite llegar a ECR; el SG bloquea la entrada
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "supportdesk"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 30

  # Si las tareas nuevas no quedan sanas, ECS detiene el despliegue y vuelve a la versión anterior.
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_lb_listener.http]
}
