terraform {
  required_version = "~> 1.0.0"
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "self" {}
