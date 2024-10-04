# Create ECS Cluster
resource "aws_ecs_cluster" "main" {
  for_each = toset(local.environments)

  name = module.eg_ecs_label[each.key].id # Use module output for naming
}

# Create ECS task definition. Image will be updated through the app pipeline. Left the values as default, but ideally this would be a module with all defaults as variables. 
resource "aws_ecs_task_definition" "main" {
  for_each = toset(local.environments)

  family                   = "${module.eg_ecs_label[each.key].id}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"

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
        "awslogs-group"         = "/ecs/${module.eg_ecs_label[each.key].id}-task"
        "awslogs-region"        = "eu-west-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

# Create ECS Services with cloudposse labels for consistent naming
resource "aws_ecs_service" "main" {
  for_each = toset(local.environments)

  name            = module.eg_ecs_label[each.key].id
  cluster         = aws_ecs_cluster.main[each.key].id
  task_definition = aws_ecs_task_definition.main[each.key].arn
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
