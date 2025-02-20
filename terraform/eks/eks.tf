module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"
  # Latest version can be found at https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

  # Name your EKS cluster in whatever name you would like
  cluster_name = var.cluster_name
  # Kubernetes latest version can be found at https://kubernetes.io/releases/
  cluster_version = var.eks_version

  # If you want that cluster plane API would be reachable from public address rather than private - enable this
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = [var.office_ip]

  cluster_service_ipv4_cidr = "172.20.0.0/16"

  # A list of the desired control plane logs to enable. https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Change with the VPC ID into which EKS control plane with nodes will be provisioned
  vpc_id = module.vpc.vpc_id
  # subnet_ids - A list of subnet IDs where the nodes/node groups will be provisioned.
  subnet_ids = module.vpc.public_subnets

  cluster_security_group_name            = "${var.cluster_name}-cluster-sg"
  cluster_security_group_use_name_prefix = false
  cluster_security_group_additional_rules = {
    # private-subnet = {
    #   from_port   = -1
    #   to_port     = -1
    #   protocol    = -1
    #   description = "private subnet"
    #   cidr_blocks = [module.vpc.private_subnets]
    #   type        = "ingress"
    # },
    office-ip = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "office ip"
      cidr_blocks = [var.office_ip]
      type        = "ingress"
    }
  }

  node_security_group_name            = "${var.cluster_name}-node-sg"
  node_security_group_use_name_prefix = false
  node_security_group_additional_rules = {
    # private-subnet = {
    #   from_port   = -1
    #   to_port     = -1
    #   protocol    = -1
    #   description = "private subnet"
    #   cidr_blocks = [module.vpc.private_subnets]
    #   type        = "ingress"
    # },
    public-subnet = {
      from_port   = -1
      to_port     = -1
      protocol    = -1
      description = "public subnet"
      cidr_blocks = ["10.0.0.0/16"]
      type        = "ingress"
    }
  }
  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  # Additional EKS provided addons https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    metrics-server         = {}
  }

  # IRSA enabled to create an OpenID trust between our cluster and IAM, in order to map AWS Roles to Kubernetes SA's
  enable_irsa = true

  # Configuration of nodes that will be provisioned. They will always exist even if
  # karpenter autoscalling will be configured.
  node_iam_role_use_name_prefix = false
  eks_managed_node_groups = {
    node-group = {
      ami_type       = "AL2023_ARM_64_STANDARD"
      instance_types = ["t4g.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks_cluster.cluster_name}"
}