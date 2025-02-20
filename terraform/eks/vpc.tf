module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tf-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1c"]
  public_subnets  = ["10.0.0.0/20", "10.0.16.0/20"]
  private_subnets = ["10.0.32.0/20", "10.0.48.0/20"]

  public_subnet_names  = ["tf-vpc/PublicSubnet1", "tf-vpc/PublicSubnet2"]
  private_subnet_names = ["tf-vpc/PrivateSubnet1", "tf-vpc/PrivateSubnet2"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  single_nat_gateway = true
  enable_nat_gateway = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "karpenter.sh/discovery" = var.cluster_name
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = var.cluster_name
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# VPC ID
output "vpc_id" {
  value = module.vpc.default_vpc_id
}