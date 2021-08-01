terraform {
  required_version = "~> 1.0.0"
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "self" {}

data "aws_codecommit_repository" "simple_bratch" {
  repository_name = "simple_bratch"
}

data "aws_ecr_repository" "simple_bratch" {
  name = "simple_bratch"
}

data "template_file" "buildspec" {
  template = file("./buildspec.yml")

  vars = {
    region         = var.region
    tag            = "${data.aws_ecr_repository.simple_bratch.name}:${var.release_tag}"
    repository_tag = "${data.aws_ecr_repository.simple_bratch.repository_url}:${var.release_tag}"
  }
}
