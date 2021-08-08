variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-xxxxxxxx"
}

variable "project_name" {
  type    = string
  default = "simple-batch"
}

variable "release_branch" {
  type    = string
  default = "release"
}

variable "release_tag" {
  type    = string
  default = "release"
}

variable "batch-environment" {
  type = list(object({
    name  = string
    value = string
  }))

  default = []
}

variable "batch-secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))

  default = []
}
