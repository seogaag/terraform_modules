resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
  
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "service"
  container_definitions = jsonencode([
    {
      name = var.task_name
      image = var.task_image
      cpu = 10
      memory = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
    }
  ])
  
  volume {
    name = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type = memberOf
    expression = "attribute:ecs.availability-zone in [${var.region}a, ${var.region}b]"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name = var.ecs_service_name
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count = 3
  iam_role = aws_iam_role.iam_ecs.arn
  depends_on = [ aws_iam_role_policy.iam_ecs ]

  ordered_placement_strategy {
    type = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name = var.task_image
    container_port = 80
  }
  
  placement_constraints {
    type = memberOf
    expression = "attribute:ecs.availability-zone in [${var.region}a, ${var.region}b]"
  }
}