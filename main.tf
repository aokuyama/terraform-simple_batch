terraform {
  required_version = "~> 1.0.0"
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "self" {}

data "aws_codecommit_repository" "simple_batch" {
  repository_name = "simple_batch"
}

data "aws_ecr_repository" "simple_batch" {
  name = "simple_batch"
}

data "template_file" "buildspec" {
  template = file("./buildspec.yml")

  vars = {
    region         = var.region
    tag            = "${data.aws_ecr_repository.simple_batch.name}:${var.release_tag}"
    repository_tag = "${data.aws_ecr_repository.simple_batch.repository_url}:${var.release_tag}"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name   = "tag:Name"
    values = ["*-public"]
  }
}
