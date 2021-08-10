resource "aws_batch_compute_environment" "simple_batch" {
  compute_environment_name = var.project_name
  compute_resources {
    max_vcpus = var.max-vcpus
    security_group_ids = [
      aws_security_group.batch_compute_env.id
    ]
    subnets = data.aws_subnet_ids.selected.ids
    type    = "FARGATE"
  }
  service_role = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/service-role/AWSBatchServiceRole"
  type         = "MANAGED"
}

resource "aws_security_group" "batch_compute_env" {
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
}

resource "aws_batch_job_definition" "simple_batch" {
  name = var.project_name
  type = "container"
  platform_capabilities = [
    "FARGATE"
  ]
  container_properties = jsonencode(
    {
      command     = []
      image       = "${data.aws_ecr_repository.simple_batch.repository_url}:${var.release_tag}"
      environment = var.batch-environment
      linuxParameters = {
        devices = []
        tmpfs   = []
      }
      mountPoints      = []
      secrets          = var.batch-secrets
      ulimits          = []
      volumes          = []
      jobRoleArn       = aws_iam_role.job_role.arn
      executionRoleArn = aws_iam_role.execution_role.arn
      fargatePlatformConfiguration = {
        platformVersion = "1.4.0"
      }
      networkConfiguration = {
        assignPublicIp = "ENABLED"
      }
      resourceRequirements = [
        {
          type  = "VCPU"
          value = tostring(var.task-vcpu)
        },
        {
          type  = "MEMORY"
          value = tostring(var.task-memory)
        }
      ]
    }
  )
}

resource "aws_iam_role" "job_role" {
  assume_role_policy = jsonencode(
    {
      Version = "2008-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
        },
      ]
    }
  )
  managed_policy_arns = []
}

resource "aws_iam_role" "execution_role" {
  assume_role_policy = jsonencode(
    {
      Version = "2008-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com",
          }
        },
      ]
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.secret-param.arn,
  ]
}

resource "aws_batch_job_queue" "simple_batch" {
  name                 = var.project_name
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.simple_batch.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "secret-param" {
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ssm:GetParameters",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
