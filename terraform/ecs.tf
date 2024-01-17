resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.name
}

resource "aws_ecs_task_definition" "my_task_definition" {
  family                   = local.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu                = "2048"
  memory             = "8192"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = <<TASK_DEFINITION
  [
    {
            "name": "app-api",
            "image": "${var.api_image}",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "app-api-80-tcp",
                    "containerPort": 5000,
                    "hostPort": 5000,
                    "protocol": "tcp"
                }
            ],
            "essential": false,
            "environment": [
                {
                    "name": "host",
                    "value": "localhost"
                },
                {
                    "name": "name",
                    "value": "postgres"
                },
                {
                    "name": "password",
                    "value": "example-password"
                },
                {
                    "name": "user",
                    "value": "postgres"
                }
            ],
            "mountPoints": [],
            "volumesFrom": [],
            "dependsOn": [
                {
                    "containerName": "app-db",
                    "condition": "HEALTHY"
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "sample-app",
                    "awslogs-region": "eu-west-1",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            }
        },

    {
            "name": "app-db",
            "image": "${var.db_image}",
            "cpu": 0,
            "memory": 5120,
            "portMappings": [
                {
                    "name": "app-db-5432-tcp",
                    "containerPort": 5432,
                    "hostPort": 5432,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "POSTGRES_PASSWORD",
                    "value": "example-password"
                }
            ],
            "mountPoints": [],
            "volumesFrom": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "sample-app",
                    "awslogs-region": "eu-west-1",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            },
            "healthCheck": {
                "command": [
                    "CMD",
                    "/usr/local/bin/health_check.sh"
                ],
                "interval": 30,
                "timeout": 5,
                "retries": 3
            }
      }
  ]
  TASK_DEFINITION
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.ecs_execution_role.name
}



resource "aws_ecs_service" "my_ecs_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [module.ecs_security_group.security_group_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn

    container_name = "app-api"
    container_port = 5000
  }
}

module "ecs_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "ecs-security-group"
  description = "ECS Security Group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http access from internet"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "allow all within vpc"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}