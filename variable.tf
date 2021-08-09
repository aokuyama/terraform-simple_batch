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

variable "rule_name" {
  type    = string
  default = "simple-batch"
}

variable "schedule" {
  type    = string
  default = "cron(0 10 * * ? *)"
}

variable "description" {
  type    = string
  default = "Job description."
}

variable "command" {
  type    = list(string)
  default = []
}

variable "max-vcpus" {
  type    = number
  default = 1
}

variable "task-vcpu" {
  type    = number
  default = 0.25
}

variable "task-memory" {
  type    = number
  default = 512
}
