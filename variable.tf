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
