# ECS Cluster + Task

resource "aws_ecs_cluster" "main" {
  name = module.eg_staging_ecs_label.id
}

# ECS and ALB

resource "aws_ecs_service" "main" {
  name            = module.eg_staging_ecs_label.id
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.alb_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "tech-test-app"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "tech-test-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512" # Adjust memory size (e.g., 512 MB)
  cpu                      = "256" # Adjust CPU size (e.g., 256 vCPU)

  container_definitions = jsonencode([{
    name      = "tech-test-app"
    image     = "hello-world:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/tech-test-task"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
}
