resource "aws_codebuild_project" "simple_bratch" {
  name         = var.project_name
  service_role = aws_iam_role.codebuild.arn
  source {
    git_clone_depth     = 1
    insecure_ssl        = false
    location            = data.aws_codecommit_repository.simple_bratch.clone_url_http
    report_build_status = false
    type                = "CODECOMMIT"

    git_submodules_config {
      fetch_submodules = false
    }
    buildspec = data.template_file.buildspec.rendered
  }

  source_version = var.release_branch

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
  }
  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    type                   = "NO_ARTIFACTS"
  }
  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
}

resource "aws_iam_role" "codebuild" {
  path = "/service-role/"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  managed_policy_arns = [
    aws_iam_policy.push_ecr.arn,
    aws_iam_policy.git_pull.arn,
    aws_iam_policy.log_codebuild.arn,
    aws_iam_policy.operate_s3.arn,
  ]
}

resource "aws_iam_policy" "push_ecr" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart",
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::codepipeline-${var.region}-*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "git_pull" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "codecommit:GitPull",
          ]
          Effect = "Allow"
          Resource = [
            data.aws_codecommit_repository.simple_bratch.arn
          ]
        }
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "log_codebuild" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${var.project_name}",
            "arn:aws:logs:${var.region}:${data.aws_caller_identity.self.account_id}:log-group:/aws/codebuild/${var.project_name}:*",
          ]
        },
        {
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.self.account_id}:report-group/${var.project_name}-*",
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_policy" "operate_s3" {
  path = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.codepipeline.arn}/*"
          ]
        },
      ]
      Version = "2012-10-17"
    }
  )
}
