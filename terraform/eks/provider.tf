data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

# data "aws_ecrpublic_authorization_token" "token" {
#   provider = aws.virginia
# }

locals {
  name   = var.cluster_name
  region = var.region
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

# provider "aws" {
#   region  = "us-east-1"
#   alias   = "virginia"
#   profile = var.aws_profile
# }
