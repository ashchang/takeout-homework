# data "aws_eks_cluster" "cluster" {
#   name = module.eks_cluster.cluster_name
#   depends_on = [ module.eks_cluster ]
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks_cluster.cluster_name
#   depends_on = [ module.eks_cluster ]
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   # token                  = data.aws_eks_cluster_auth.cluster.token
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command = "aws"
#     args = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name, "--profile", var.aws_profile] 
#   }
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     # token                  = data.aws_eks_cluster_auth.cluster.token
#     exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command = "aws"
#     args = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name, "--profile", var.aws_profile] 
#   }
#   }
# }

# module "lb_role" {
#     source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

#     role_name                              = "${var.cluster_name}-lb-controller-role"
#     attach_load_balancer_controller_policy = true

#     oidc_providers = {
#         main = {
#         provider_arn               = module.eks_cluster.oidc_provider_arn
#         namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#         }
#     }
# }

# resource "kubernetes_service_account" "service-account" {
#     metadata {
#         name      = "aws-load-balancer-controller"
#         namespace = "kube-system"
#         labels = {
#             "app.kubernetes.io/name"      = "aws-load-balancer-controller"
#             "app.kubernetes.io/component" = "controller"
#         }
#         annotations = {
#             "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
#             "eks.amazonaws.com/sts-regional-endpoints" = "true"
#         }
#     }
#     depends_on = [
#         module.eks_cluster # 添加对 EKS 集群的依赖
#     ]
# }

# resource "helm_release" "alb-controller" {
#     name       = "aws-load-balancer-controller"
#     repository = "https://aws.github.io/eks-charts"
#     chart      = "aws-load-balancer-controller"
#     namespace  = "kube-system"
#     depends_on = [
#         kubernetes_service_account.service-account
#     ]

#     set {
#         name  = "region"
#         value = data.aws_region.current.name
#     }

#     # set {
#     #     name  = "vpcId"
#     #     value = module.vpc.default_vpc_id
#     # }

#     set {
#         name  = "image.repository"
#         value = "public.ecr.aws/eks/aws-load-balancer-controller"
#     }

#     set {
#         name  = "serviceAccount.create"
#         value = "false"
#     }

#     set {
#         name  = "serviceAccount.name"
#         value = "aws-load-balancer-controller"
#     }

#     set {
#         name  = "clusterName"
#         value = var.cluster_name
#     }
# }