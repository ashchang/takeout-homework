variable "cluster_name" {
  type    = string
  default = "test"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "appstage"
}

variable "eks_version" {
  type    = string
  default = "1.31"
}

variable "namespace" {
  type    = string
  default = "kube-system"
}

variable "office_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "docker_user" {
  type    = string
  default = ""
}
variable "docker_pass" {
  type    = string
  default = ""
}

