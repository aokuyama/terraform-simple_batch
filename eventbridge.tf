resource "aws_cloudwatch_event_rule" "batch-rule" {
  name                = var.rule_name
  event_pattern       = null
  schedule_expression = var.schedule
  lifecycle {
    ignore_changes = [
      is_enabled
    ]
  }
  description = var.description
}

resource "aws_cloudwatch_event_target" "batch-target" {
  rule = var.rule_name
  arn  = aws_batch_job_queue.simple_batch.arn
  batch_target {
    job_definition = aws_batch_job_definition.simple_batch.arn
    job_name       = var.project_name
  }
  role_arn = aws_iam_role.event_target.arn
  input = jsonencode(
    {
      ContainerOverrides = {
        Command = var.command
      }
    }
  )
}

resource "aws_iam_role" "event_target" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "events.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.event_target.arn,
  ]
  path = "/service-role/"
}

resource "aws_iam_policy" "event_target" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "batch:SubmitJob",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}
